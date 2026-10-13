using QLDACNTT.Api.Contracts;
using QLDACNTT.Api.Data;
using QLDACNTT.Api.Infrastructure;
using QLDACNTT.Api.Models;

namespace QLDACNTT.Api.Endpoints;

public static class BillingAndWarrantyEndpoints
{
    public static void MapBillingAndWarrantyEndpoints(this WebApplication app, AppData data)
    {
        // =========================================================================
        // MBA-66: API TÍNH CHI PHÍ VÀ LẬP HÓA ĐƠN THANH TOÁN
        // =========================================================================

        // [GET] /api/tickets/{code}/cost - Tính toán chi tiết chi phí (Tiền công + Linh kiện)
        app.MapGet("/api/tickets/{code}/cost", (HttpRequest request, string code) =>
        {
            var auth = AuthHelper.RequireRole(request, data, "ADMIN", "STAFF", "TECHNICIAN", "CUSTOMER");
            if (auth is not null) return auth;

            var ticket = data.Tickets.FirstOrDefault(x => x.Code.Equals(code, StringComparison.OrdinalIgnoreCase));
            if (ticket is null)
            {
                return Results.NotFound(new { message = "Khong tim thay phieu sua chua" });
            }

            // Tính tiền linh kiện đã xuất cho phiếu này
            var partsUsed = data.StockTransactions
                .Where(x => x.TicketCode != null && x.TicketCode.Equals(code, StringComparison.OrdinalIgnoreCase) && x.TransactionType == "OUT")
                .ToList();

            decimal partsTotal = 0;
            var partsDetails = new List<object>();

            foreach (var tx in partsUsed)
            {
                var part = data.SpareParts.FirstOrDefault(p => p.Code.Equals(tx.PartCode, StringComparison.OrdinalIgnoreCase));
                var price = part?.SellingPrice ?? 0;
                var subtotal = price * tx.Quantity;
                partsTotal += subtotal;

                partsDetails.Add(new
                {
                    partCode = tx.PartCode,
                    partName = part?.Name ?? "Linh kien",
                    quantity = tx.Quantity,
                    unitPrice = price,
                    subtotal
                });
            }

            var laborCost = ticket.QuotedLaborCost;
            var grandTotal = laborCost + partsTotal;

            return Results.Ok(new
            {
                ticketCode = ticket.Code,
                customerCode = ticket.CustomerCode,
                laborCost,
                partsTotal,
                grandTotal,
                partsUsed = partsDetails
            });
        });

        // [POST] /api/invoices - Lập hóa đơn thanh toán cho phiếu sửa chữa
        app.MapPost("/api/invoices", (HttpRequest request, CreateInvoiceRequest input) =>
        {
            var session = AuthHelper.GetSession(request, data);
            var auth = AuthHelper.RequireSessionRole(session, "ADMIN", "STAFF");
            if (auth is not null) return auth;

            var ticket = data.Tickets.FirstOrDefault(x => x.Code.Equals(input.TicketCode, StringComparison.OrdinalIgnoreCase));
            if (ticket is null)
            {
                return Results.BadRequest(new { message = "Phieu sua chua khong ton tai" });
            }

            // Kiểm tra xem đã có hóa đơn chưa
            var existingInvoice = data.Invoices.FirstOrDefault(x => x.TicketCode.Equals(ticket.Code, StringComparison.OrdinalIgnoreCase));
            if (existingInvoice is not null)
            {
                return Results.Ok(new { message = "Hoa don da ton tai", invoice = existingInvoice });
            }

            // Tính tiền linh kiện
            var partsUsed = data.StockTransactions
                .Where(x => x.TicketCode != null && x.TicketCode.Equals(ticket.Code, StringComparison.OrdinalIgnoreCase) && x.TransactionType == "OUT");

            decimal partsCost = partsUsed.Sum(tx =>
            {
                var part = data.SpareParts.FirstOrDefault(p => p.Code.Equals(tx.PartCode, StringComparison.OrdinalIgnoreCase));
                return (part?.SellingPrice ?? 0) * tx.Quantity;
            });

            var laborCost = ticket.QuotedLaborCost;
            var discount = input.DiscountAmount ?? 0;
            var totalAmount = Math.Max(0, laborCost + partsCost - discount);

            var invoice = new InvoiceDto(
                $"HD202610{data.Invoices.Count + 1:0000}",
                ticket.Code,
                ticket.CustomerCode,
                laborCost,
                partsCost,
                totalAmount,
                "UNPAID",
                DateTimeOffset.UtcNow);

            data.Invoices.Add(invoice);

            return Results.Created($"/api/invoices/{invoice.InvoiceCode}", invoice);
        });

        // [GET] /api/invoices - Danh sách hóa đơn
        app.MapGet("/api/invoices", (HttpRequest request) =>
        {
            var auth = AuthHelper.RequireRole(request, data, "ADMIN", "STAFF");
            if (auth is not null) return auth;

            return Results.Ok(data.Invoices);
        });

        // [GET] /api/invoices/{code} - Chi tiết hóa đơn
        app.MapGet("/api/invoices/{code}", (HttpRequest request, string code) =>
        {
            var auth = AuthHelper.RequireRole(request, data, "ADMIN", "STAFF", "CUSTOMER");
            if (auth is not null) return auth;

            var invoice = data.Invoices.FirstOrDefault(x => x.InvoiceCode.Equals(code, StringComparison.OrdinalIgnoreCase));
            return invoice is null ? Results.NotFound(new { message = "Khong tim thay hoa don" }) : Results.Ok(invoice);
        });

        // =========================================================================
        // MBA-67: XỬ LÝ THANH TOÁN TIỀN MẶT VÀ CHUYỂN KHOẢN
        // =========================================================================

        app.MapPost("/api/invoices/{code}/pay", (HttpRequest request, string code, ProcessPaymentRequest input) =>
        {
            var session = AuthHelper.GetSession(request, data);
            var auth = AuthHelper.RequireSessionRole(session, "ADMIN", "STAFF");
            if (auth is not null) return auth;

            var invoice = data.Invoices.FirstOrDefault(x => x.InvoiceCode.Equals(code, StringComparison.OrdinalIgnoreCase));
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

            // Ghi nhận thanh toán
            var payment = new PaymentDto(
                data.Payments.Count + 1,
                invoice.InvoiceCode,
                invoice.TicketCode,
                input.Amount,
                method,
                session!.Username,
                DateTimeOffset.UtcNow,
                input.Note ?? $"Thanh toan hoa don {invoice.InvoiceCode} bang hinh thuc {method}");

            data.Payments.Add(payment);

            // Cập nhật trạng thái hóa đơn sang PAID
            data.Invoices[data.Invoices.IndexOf(invoice)] = invoice with { PaymentStatus = "PAID" };

            // Cập nhật trạng thái phiếu sửa chữa sang PAID
            var ticket = data.Tickets.FirstOrDefault(x => x.Code.Equals(invoice.TicketCode, StringComparison.OrdinalIgnoreCase));
            if (ticket is not null)
            {
                var oldStatus = ticket.Status;
                data.Tickets[data.Tickets.IndexOf(ticket)] = ticket with { Status = "PAID" };

                // Ghi nhận Status Log
                data.StatusLogs.Add(new TicketStatusLogDto(
                    data.StatusLogs.Count + 1,
                    ticket.Code,
                    oldStatus,
                    "PAID",
                    session.Username,
                    DateTimeOffset.UtcNow,
                    $"Khach hang da thanh toan qua {method}. Phieu chuyen sang PAID."));
            }

            // =========================================================================
            // MBA-68: TỰ ĐỘNG KÍCH HOẠT SỔ BẢO HÀNH ĐIỆN TỬ THEO MÁY
            // =========================================================================
            WarrantyCardDto? newWarranty = null;
            if (ticket is not null)
            {
                var device = data.Devices.FirstOrDefault(d => d.Code.Equals(ticket.DeviceCode, StringComparison.OrdinalIgnoreCase));
                var service = data.ServiceTypes.FirstOrDefault(s => s.Code.Equals(ticket.ServiceCode, StringComparison.OrdinalIgnoreCase));
                var warrantyDays = service?.WarrantyDays ?? 30;

                newWarranty = new WarrantyCardDto(
                    $"BH202610{data.Warranties.Count + 1:0000}",
                    ticket.Code,
                    ticket.DeviceCode,
                    ticket.CustomerCode,
                    device?.SerialNumber ?? "CHUA_CO_SERIAL",
                    DateTimeOffset.UtcNow,
                    DateTimeOffset.UtcNow.AddDays(warrantyDays),
                    warrantyDays,
                    "ACTIVE");

                data.Warranties.Add(newWarranty);
            }

            return Results.Ok(new
            {
                message = "Thanh toan thanh cong va da tu dong kich hoat so bao hanh dien tu!",
                payment,
                invoice = data.Invoices.FirstOrDefault(x => x.InvoiceCode.Equals(code, StringComparison.OrdinalIgnoreCase)),
                warrantyActivated = newWarranty
            });
        });

        // =========================================================================
        // MBA-69: API TRA CỨU THỜI HẠN BẢO HÀNH THEO SERIAL MÁY HOẶC SĐT KHÁCH HÀNG
        // =========================================================================

        // [GET] /api/warranties - Danh sách toàn bộ sổ bảo hành
        app.MapGet("/api/warranties", (HttpRequest request) =>
        {
            var auth = AuthHelper.RequireRole(request, data, "ADMIN", "STAFF", "CUSTOMER");
            if (auth is not null) return auth;

            return Results.Ok(data.Warranties);
        });

        // [GET] /api/warranties/search - Tra cứu bảo hành điện tử theo Serial / Phone / Ticket / Mã BH
        app.MapGet("/api/warranties/search", (HttpRequest request, string? serial, string? phone, string? ticketCode, string? warrantyCode) =>
        {
            var auth = AuthHelper.RequireRole(request, data, "ADMIN", "STAFF", "TECHNICIAN", "CUSTOMER");
            if (auth is not null) return auth;

            var query = data.Warranties.AsEnumerable();

            if (!string.IsNullOrWhiteSpace(serial))
            {
                query = query.Where(w => w.SerialNumber.Contains(serial.Trim(), StringComparison.OrdinalIgnoreCase));
            }

            if (!string.IsNullOrWhiteSpace(ticketCode))
            {
                query = query.Where(w => w.TicketCode.Equals(ticketCode.Trim(), StringComparison.OrdinalIgnoreCase));
            }

            if (!string.IsNullOrWhiteSpace(warrantyCode))
            {
                query = query.Where(w => w.WarrantyCode.Equals(warrantyCode.Trim(), StringComparison.OrdinalIgnoreCase));
            }

            if (!string.IsNullOrWhiteSpace(phone))
            {
                var customers = data.Customers.Where(c => c.Phone.Contains(phone.Trim())).Select(c => c.Code).ToHashSet();
                query = query.Where(w => customers.Contains(w.CustomerCode));
            }

            var results = query.Select(w =>
            {
                var dev = data.Devices.FirstOrDefault(d => d.Code.Equals(w.DeviceCode, StringComparison.OrdinalIgnoreCase));
                var cust = data.Customers.FirstOrDefault(c => c.Code.Equals(w.CustomerCode, StringComparison.OrdinalIgnoreCase));
                var daysRemaining = Math.Max(0, (int)(w.EndDate - DateTimeOffset.UtcNow).TotalDays);
                var isExpired = DateTimeOffset.UtcNow > w.EndDate;

                return new
                {
                    w.WarrantyCode,
                    w.TicketCode,
                    w.SerialNumber,
                    deviceType = dev?.DeviceType,
                    deviceModel = $"{dev?.Brand} {dev?.Model}",
                    customerName = cust?.FullName,
                    customerPhone = cust?.Phone,
                    w.StartDate,
                    w.EndDate,
                    w.WarrantyDays,
                    status = isExpired ? "EXPIRED" : w.Status,
                    daysRemaining
                };
            }).ToList();

            return Results.Ok(new
            {
                total = results.Count,
                data = results
            });
        });
    }
}

