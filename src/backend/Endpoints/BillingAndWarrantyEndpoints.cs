using Microsoft.EntityFrameworkCore;
using QLDACNTT.Api.Contracts;
using QLDACNTT.Api.Data;
using QLDACNTT.Api.Infrastructure;
using QLDACNTT.Api.Models;

namespace QLDACNTT.Api.Endpoints;

public static class BillingAndWarrantyEndpoints
{
    public static void MapBillingAndWarrantyEndpoints(this WebApplication app)
    {
        // =========================================================================
        // MBA-66: API TÍNH CHI PHÍ VÀ LẬP HÓA ĐƠN THANH TOÁN
        // =========================================================================

        // [GET] /api/tickets/{code}/cost - Tính toán chi tiết chi phí (Tiền công + Linh kiện)
        app.MapGet("/api/tickets/{code}/cost", async (HttpRequest request, string code, AppDbContext db, SessionStore store) =>
        {
            var auth = AuthHelper.RequireRole(request, store, "ADMIN", "STAFF", "TECHNICIAN", "CUSTOMER");
            if (auth is not null) return auth;

            var ticket = await db.RepairTickets
                .Include(x => x.Customer)
                .FirstOrDefaultAsync(x => x.TicketCode.ToLower() == code.ToLower());
            if (ticket is null)
            {
                return Results.NotFound(new { message = "Khong tim thay phieu sua chua" });
            }

            var partsUsed = await db.StockTransactions
                .Include(x => x.Part)
                .Where(x => x.Ticket != null && x.Ticket.TicketCode.ToLower() == code.ToLower() && x.TransactionType == "OUT")
                .ToListAsync();

            decimal partsTotal = 0;
            var partsDetails = new List<object>();

            foreach (var tx in partsUsed)
            {
                var price = tx.Part.SellingPrice;
                var subtotal = price * tx.Quantity;
                partsTotal += subtotal;

                partsDetails.Add(new
                {
                    partCode = tx.Part.PartCode,
                    partName = tx.Part.PartName,
                    quantity = tx.Quantity,
                    unitPrice = price,
                    subtotal
                });
            }

            var laborCost = ticket.QuotedLaborCost;
            var grandTotal = laborCost + partsTotal;

            return Results.Ok(new
            {
                ticketCode = ticket.TicketCode,
                customerCode = ticket.Customer.CustomerCode,
                laborCost,
                partsTotal,
                grandTotal,
                partsUsed = partsDetails
            });
        });

        // [POST] /api/invoices - Lập hóa đơn thanh toán cho phiếu sửa chữa
        app.MapPost("/api/invoices", async (HttpRequest request, CreateInvoiceRequest input, AppDbContext db, SessionStore store) =>
        {
            var session = AuthHelper.GetSession(request, store);
            var auth = AuthHelper.RequireSessionRole(session, "ADMIN", "STAFF");
            if (auth is not null) return auth;

            var ticket = await db.RepairTickets
                .Include(x => x.Customer)
                .FirstOrDefaultAsync(x => x.TicketCode.ToLower() == input.TicketCode.ToLower());
            if (ticket is null)
            {
                return Results.BadRequest(new { message = "Phieu sua chua khong ton tai" });
            }

            var existingInvoice = await db.Invoices.FirstOrDefaultAsync(x => x.TicketId == ticket.TicketId);
            if (existingInvoice is not null)
            {
                return Results.Ok(new { message = "Hoa don da ton tai", invoice = ToInvoiceResponse(existingInvoice, ticket.TicketCode, ticket.Customer.CustomerCode) });
            }

            var partsCost = await db.StockTransactions
                .Include(x => x.Part)
                .Where(x => x.Ticket != null && x.Ticket.TicketCode.ToLower() == ticket.TicketCode.ToLower() && x.TransactionType == "OUT")
                .SumAsync(x => x.Part.SellingPrice * x.Quantity);

            var laborCost = ticket.QuotedLaborCost;
            var discount = input.DiscountAmount ?? 0;

            var currentUser = await db.Users.FirstOrDefaultAsync(x => x.Username.ToLower() == session!.Username.ToLower());

            var count = await db.Invoices.CountAsync();
            var invoice = new Invoice
            {
                InvoiceCode = $"HD{DateTime.Now:yyyyMM}{count + 1:0000}",
                TicketId = ticket.TicketId,
                CustomerId = ticket.CustomerId,
                LaborCost = laborCost,
                PartsCost = partsCost,
                DiscountAmount = discount,
                PaymentMethod = "CASH",
                PaymentStatus = "UNPAID",
                CreatedByUserId = currentUser?.UserId ?? ticket.ReceivedByUserId
            };

            db.Invoices.Add(invoice);
            await db.SaveChangesAsync();

            return Results.Created($"/api/invoices/{invoice.InvoiceCode}", ToInvoiceResponse(invoice, ticket.TicketCode, ticket.Customer.CustomerCode));
        });

        // [GET] /api/invoices - Danh sách hóa đơn
        app.MapGet("/api/invoices", async (HttpRequest request, AppDbContext db, SessionStore store) =>
        {
            var auth = AuthHelper.RequireRole(request, store, "ADMIN", "STAFF");
            if (auth is not null) return auth;

            var invoices = await db.Invoices
                .Include(x => x.Ticket)
                .Include(x => x.Customer)
                .Select(x => ToInvoiceResponse(x, x.Ticket.TicketCode, x.Customer.CustomerCode))
                .ToListAsync();

            return Results.Ok(invoices);
        });

        // [GET] /api/invoices/{code} - Chi tiết hóa đơn
        app.MapGet("/api/invoices/{code}", async (HttpRequest request, string code, AppDbContext db, SessionStore store) =>
        {
            var auth = AuthHelper.RequireRole(request, store, "ADMIN", "STAFF", "CUSTOMER");
            if (auth is not null) return auth;

            var invoice = await db.Invoices
                .Include(x => x.Ticket)
                .Include(x => x.Customer)
                .FirstOrDefaultAsync(x => x.InvoiceCode.ToLower() == code.ToLower());

            return invoice is null
                ? Results.NotFound(new { message = "Khong tim thay hoa don" })
                : Results.Ok(ToInvoiceResponse(invoice, invoice.Ticket.TicketCode, invoice.Customer.CustomerCode));
        });

        // =========================================================================
        // MBA-67: XỬ LÝ THANH TOÁN TIỀN MẶT VÀ CHUYỂN KHOẢN
        // =========================================================================

        app.MapPost("/api/invoices/{code}/pay", async (HttpRequest request, string code, ProcessPaymentRequest input, AppDbContext db, SessionStore store) =>
        {
            var session = AuthHelper.GetSession(request, store);
            var auth = AuthHelper.RequireSessionRole(session, "ADMIN", "STAFF");
            if (auth is not null) return auth;

            var invoice = await db.Invoices
                .Include(x => x.Ticket)
                .Include(x => x.Customer)
                .FirstOrDefaultAsync(x => x.InvoiceCode.ToLower() == code.ToLower());
            if (invoice is null)
            {
                return Results.NotFound(new { message = "Khong tim thay hoa don can thanh toan" });
            }

            if (invoice.PaymentStatus == "PAID")
            {
                return Results.BadRequest(new { message = "Hoa don nay da duoc thanh toan truoc do" });
            }

            var method = input.PaymentMethod.ToUpperInvariant();
            if (method is not ("CASH" or "TRANSFER" or "MOMO" or "VNPAY"))
            {
                return Results.BadRequest(new { message = "Phuong thuc thanh toan khong hop le (CASH, TRANSFER, MOMO, VNPAY)" });
            }

            var currentUser = await db.Users.FirstOrDefaultAsync(x => x.Username.ToLower() == session!.Username.ToLower());

            var payment = new Payment
            {
                InvoiceId = invoice.InvoiceId,
                Amount = input.Amount,
                PaymentMethod = method,
                ReceivedByUserId = currentUser?.UserId ?? invoice.CreatedByUserId,
                Note = input.Note ?? $"Thanh toan hoa don {invoice.InvoiceCode} bang hinh thuc {method}"
            };
            db.Payments.Add(payment);

            invoice.PaymentStatus = "PAID";
            invoice.PaymentMethod = method;
            invoice.PaidAt = DateTime.Now;

            var ticket = invoice.Ticket;
            if (ticket is not null)
            {
                ticket.UpdatedAt = DateTime.Now;
                db.TicketStatusHistories.Add(new TicketStatusHistory
                {
                    TicketId = ticket.TicketId,
                    FromStatus = ticket.Status,
                    ToStatus = ticket.Status,
                    ChangedByUserId = currentUser?.UserId ?? invoice.CreatedByUserId,
                    Note = $"Khach hang da thanh toan hoa don {invoice.InvoiceCode} qua {method}."
                });
            }

            // =========================================================================
            // MBA-68: TỰ ĐỘNG KÍCH HOẠT SỔ BẢO HÀNH ĐIỆN TỬ THEO MÁY
            // =========================================================================
            var device = await db.Devices.FirstOrDefaultAsync(x => x.DeviceId == ticket!.DeviceId);
            var service = await db.ServiceTypes.FirstOrDefaultAsync(x => x.ServiceTypeId == ticket!.ServiceTypeId);
            var warrantyDays = service?.WarrantyDays ?? 30;

            var warrantyCount = await db.Warranties.CountAsync();
            var newWarranty = new Warranty
            {
                WarrantyCode = $"BH{DateTime.Now:yyyyMM}{warrantyCount + 1:0000}",
                TicketId = ticket!.TicketId,
                DeviceId = ticket.DeviceId,
                CustomerId = ticket.CustomerId,
                StartDate = DateTime.Now,
                EndDate = DateTime.Now.AddDays(warrantyDays),
                WarrantyDays = warrantyDays,
                Scope = $"Bao hanh dich vu {service?.ServiceName ?? "Sua chua"}",
                Status = "ACTIVE",
                CreatedAt = DateTime.Now
            };
            db.Warranties.Add(newWarranty);

            await db.SaveChangesAsync();

            return Results.Ok(new
            {
                message = "Thanh toan thanh cong va da tu dong kich hoat so bao hanh dien tu!",
                payment = new
                {
                    payment.PaymentId,
                    InvoiceCode = invoice.InvoiceCode,
                    TicketCode = ticket.TicketCode,
                    payment.Amount,
                    payment.PaymentMethod,
                    ReceivedByUsername = currentUser?.Username,
                    payment.PaidAt,
                    payment.Note
                },
                invoice = ToInvoiceResponse(invoice, ticket.TicketCode, invoice.Customer.CustomerCode),
                warrantyActivated = new
                {
                    WarrantyCode = newWarranty.WarrantyCode,
                    TicketCode = ticket.TicketCode,
                    DeviceCode = device?.DeviceCode,
                    CustomerCode = invoice.Customer.CustomerCode,
                    SerialNumber = device?.SerialNumber ?? "CHUA_CO_SERIAL",
                    newWarranty.StartDate,
                    newWarranty.EndDate,
                    newWarranty.WarrantyDays,
                    newWarranty.Status
                }
            });
        });

        // =========================================================================
        // MBA-69: API TRA CỨU THỜI HẠN BẢO HÀNH THEO SERIAL MÁY HOẶC SĐT KHÁCH HÀNG
        // =========================================================================

        // [GET] /api/warranties - Danh sách toàn bộ sổ bảo hành
        app.MapGet("/api/warranties", async (HttpRequest request, AppDbContext db, SessionStore store) =>
        {
            var auth = AuthHelper.RequireRole(request, store, "ADMIN", "STAFF", "CUSTOMER");
            if (auth is not null) return auth;

            var warranties = await db.Warranties
                .Include(x => x.Ticket)
                .Include(x => x.Device)
                .Include(x => x.Customer)
                .Select(w => new
                {
                    WarrantyCode = w.WarrantyCode,
                    TicketCode = w.Ticket.TicketCode,
                    DeviceCode = w.Device.DeviceCode,
                    CustomerCode = w.Customer.CustomerCode,
                    SerialNumber = w.Device.SerialNumber,
                    DeviceModel = $"{w.Device.Brand} {w.Device.Model}",
                    CustomerName = w.Customer.FullName,
                    w.StartDate,
                    w.EndDate,
                    w.WarrantyDays,
                    w.Scope,
                    w.Status
                })
                .ToListAsync();

            return Results.Ok(warranties);
        });

        // [GET] /api/warranties/search - Tra cứu bảo hành điện tử theo Serial / Phone / Ticket / Mã BH
        app.MapGet("/api/warranties/search", async (HttpRequest request, string? serial, string? phone, string? ticketCode, string? warrantyCode, AppDbContext db, SessionStore store) =>
        {
            var auth = AuthHelper.RequireRole(request, store, "ADMIN", "STAFF", "TECHNICIAN", "CUSTOMER");
            if (auth is not null) return auth;

            var query = db.Warranties
                .Include(x => x.Device)
                .Include(x => x.Customer)
                .AsQueryable();

            if (!string.IsNullOrWhiteSpace(serial))
            {
                var s = serial.Trim();
                query = query.Where(w => w.Device.SerialNumber != null && w.Device.SerialNumber.Contains(s));
            }

            if (!string.IsNullOrWhiteSpace(ticketCode))
            {
                var t = ticketCode.Trim();
                query = query.Where(w => db.RepairTickets.Any(rt => rt.TicketId == w.TicketId && rt.TicketCode.ToLower() == t.ToLower()));
            }

            if (!string.IsNullOrWhiteSpace(warrantyCode))
            {
                var wc = warrantyCode.Trim();
                query = query.Where(w => w.WarrantyCode.ToLower() == wc.ToLower());
            }

            if (!string.IsNullOrWhiteSpace(phone))
            {
                var p = phone.Trim();
                query = query.Where(w => w.Customer.Phone.Contains(p));
            }

            var now = DateTime.Now;
            var results = await query
                .Include(x => x.Ticket)
                .Select(w => new
                {
                    w.WarrantyCode,
                    TicketCode = w.Ticket.TicketCode,
                    SerialNumber = w.Device.SerialNumber,
                    deviceType = w.Device.DeviceType,
                    deviceModel = $"{w.Device.Brand} {w.Device.Model}",
                    customerName = w.Customer.FullName,
                    customerPhone = w.Customer.Phone,
                    w.StartDate,
                    w.EndDate,
                    w.WarrantyDays,
                    status = now > w.EndDate ? "EXPIRED" : w.Status,
                    daysRemaining = Math.Max(0, (int)(w.EndDate - now).TotalDays)
                })
                .ToListAsync();

            return Results.Ok(new
            {
                total = results.Count,
                data = results
            });
        });
    }

    private static object ToInvoiceResponse(Invoice invoice, string ticketCode, string customerCode)
    {
        return new
        {
            InvoiceCode = invoice.InvoiceCode,
            TicketCode = ticketCode,
            CustomerCode = customerCode,
            invoice.LaborCost,
            invoice.PartsCost,
            TotalAmount = invoice.LaborCost + invoice.PartsCost - invoice.DiscountAmount,
            invoice.PaymentStatus,
            invoice.CreatedAt
        };
    }
}
