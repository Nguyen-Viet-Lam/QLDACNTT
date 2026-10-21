using Microsoft.EntityFrameworkCore;
using QLDACNTT.Api.Contracts;
using QLDACNTT.Api.Data;
using QLDACNTT.Api.Infrastructure;
using QLDACNTT.Api.Models;

namespace QLDACNTT.Api.Endpoints;

public static class TicketEndpoints
{
    public static void MapTicketEndpoints(this WebApplication app)
    {
        app.MapGet("/api/tickets", async (HttpRequest request, string? status, AppDbContext db, SessionStore store) =>
        {
            var session = AuthHelper.GetSession(request, store);
            var auth = AuthHelper.RequireSessionRole(session, "ADMIN", "STAFF", "TECHNICIAN", "CUSTOMER");
            if (auth is not null)
            {
                return auth;
            }

            var query = IncludeTicket(db.RepairTickets);

            // VÁ LỖ HỔNG IDOR L05 (Tuần 5 - Sprint 5), hoàn thiện Sprint demo:
            // Khách hàng chỉ xem được danh sách phiếu gắn với CustomerId thật trong session
            // (lấy từ tài khoản đăng nhập của họ, không hard-code).
            if (session!.Role == "CUSTOMER")
            {
                if (session.CustomerId is null)
                {
                    return Results.Ok(Array.Empty<object>());
                }

                query = query.Where(x => x.CustomerId == session.CustomerId);
            }
            // Kỹ thuật viên chỉ xem phiếu được giao cho mình hoặc phiếu chưa phân công
            else if (session.Role == "TECHNICIAN")
            {
                query = query.Where(x => x.TechnicianUserId == null || x.TechnicianUserId == session.UserId);
            }

            if (!string.IsNullOrWhiteSpace(status))
            {
                var statusUpper = status.ToUpperInvariant();
                query = query.Where(x => x.Status == statusUpper);
            }

            var tickets = await query.ToListAsync();
            return Results.Ok(tickets.Select(AuthHelper.EnrichTicket));
        });

        app.MapGet("/api/tickets/{code}", async (HttpRequest request, string code, AppDbContext db, SessionStore store) =>
        {
            var session = AuthHelper.GetSession(request, store);
            var auth = AuthHelper.RequireSessionRole(session, "ADMIN", "STAFF", "TECHNICIAN", "CUSTOMER");
            if (auth is not null)
            {
                return auth;
            }

            var ticket = await FindTicket(db, code);
            if (ticket is null)
            {
                return Results.NotFound(new { message = "Khong tim thay phieu sua chua" });
            }

            // VÁ LỖ HỔNG PHÂN QUYỀN NGANG IDOR L05:
            // Khách hàng tuyệt đối không được xem đơn hàng/phiếu sửa chữa của khách hàng khác!
            if (session!.Role == "CUSTOMER")
            {
                if (session.CustomerId is null || ticket.CustomerId != session.CustomerId)
                {
                    return Results.Json(
                        new
                        {
                            message = "Canh bao bao mat IDOR (L05): Ban khong co quyen xem phieu sua chua cua nguoi khac!",
                            violation = "HORIZONTAL_ACCESS_CONTROL_VIOLATION",
                            ticketCode = code
                        },
                        statusCode: StatusCodes.Status403Forbidden);
                }
            }

            return Results.Ok(AuthHelper.EnrichTicket(ticket));
        });

        app.MapPost("/api/tickets", async (HttpRequest request, CreateTicketRequest input, AppDbContext db, SessionStore store) =>
        {
            var session = AuthHelper.GetSession(request, store);
            var auth = AuthHelper.RequireSessionRole(session, "ADMIN", "STAFF");
            if (auth is not null)
            {
                return auth;
            }

            var customer = await db.Customers.FirstOrDefaultAsync(x => x.CustomerCode.ToLower() == input.CustomerCode.ToLower());
            if (customer is null)
            {
                return Results.BadRequest(new { message = "Khach hang khong hop le" });
            }

            var device = await db.Devices.FirstOrDefaultAsync(x => x.DeviceCode.ToLower() == input.DeviceCode.ToLower());
            if (device is null)
            {
                return Results.BadRequest(new { message = "Thiet bi khong hop le" });
            }

            var service = await db.ServiceTypes.FirstOrDefaultAsync(x => x.ServiceCode.ToLower() == input.ServiceCode.ToLower());
            if (service is null)
            {
                return Results.BadRequest(new { message = "Dich vu khong hop le" });
            }

            var receivedByUser = await db.Users.FirstOrDefaultAsync(x => x.Username.ToLower() == session!.Username.ToLower());
            if (receivedByUser is null)
            {
                return Results.Unauthorized();
            }

            var count = await db.RepairTickets.CountAsync();
            var ticket = new RepairTicket
            {
                TicketCode = $"PSC{DateTime.Now:yyyyMM}{count + 1:0000}",
                CustomerId = customer.CustomerId,
                DeviceId = device.DeviceId,
                ServiceTypeId = service.ServiceTypeId,
                ReceivedByUserId = receivedByUser.UserId,
                Status = "RECEIVED",
                DeviceCondition = input.DeviceCondition.Trim(),
                QuotedLaborCost = service.LaborCost
            };

            db.RepairTickets.Add(ticket);
            await db.SaveChangesAsync();

            var created = await FindTicket(db, ticket.TicketCode);
            return Results.Created($"/api/tickets/{ticket.TicketCode}", AuthHelper.EnrichTicket(created!));
        });

        app.MapPatch("/api/tickets/{code}/assign", async (HttpRequest request, string code, AssignTechnicianRequest input, AppDbContext db, SessionStore store) =>
        {
            var auth = AuthHelper.RequireRole(request, store, "ADMIN", "STAFF");
            if (auth is not null)
            {
                return auth;
            }

            var ticket = await FindTicket(db, code);
            if (ticket is null)
            {
                return Results.NotFound(new { message = "Khong tim thay phieu sua chua" });
            }

            var technician = await db.Users.Include(x => x.Role).FirstOrDefaultAsync(x =>
                x.Username.ToLower() == input.TechnicianUsername.ToLower()
                && x.Role.RoleCode == "TECHNICIAN"
                && x.IsActive);

            if (technician is null)
            {
                return Results.BadRequest(new { message = "Ky thuat vien khong hop le" });
            }

            ticket.TechnicianUserId = technician.UserId;
            ticket.Status = "DIAGNOSING";
            ticket.UpdatedAt = DateTime.Now;
            await db.SaveChangesAsync();

            var updated = await FindTicket(db, code);
            return Results.Ok(AuthHelper.EnrichTicket(updated!));
        });

        app.MapPatch("/api/tickets/{code}/diagnosis", async (HttpRequest request, string code, UpdateDiagnosisRequest input, AppDbContext db, SessionStore store) =>
        {
            var auth = AuthHelper.RequireRole(request, store, "ADMIN", "TECHNICIAN");
            if (auth is not null)
            {
                return auth;
            }

            var ticket = await FindTicket(db, code);
            if (ticket is null)
            {
                return Results.NotFound(new { message = "Khong tim thay phieu sua chua" });
            }

            ticket.Diagnosis = input.Diagnosis.Trim();
            ticket.QuotedLaborCost = input.QuotedLaborCost;
            ticket.Status = "WAITING_CONFIRM";
            ticket.UpdatedAt = DateTime.Now;
            await db.SaveChangesAsync();

            var updated = await FindTicket(db, code);
            return Results.Ok(AuthHelper.EnrichTicket(updated!));
        });

        app.MapPatch("/api/tickets/{code}/status", async (HttpRequest request, string code, UpdateTicketStatusRequest input, AppDbContext db, SessionStore store) =>
        {
            var auth = AuthHelper.RequireRole(request, store, "ADMIN", "STAFF", "TECHNICIAN");
            if (auth is not null)
            {
                return auth;
            }

            if (!AuthHelper.IsValidTicketStatus(input.Status))
            {
                return Results.BadRequest(new { message = "Trang thai phieu khong hop le" });
            }

            var ticket = await FindTicket(db, code);
            if (ticket is null)
            {
                return Results.NotFound(new { message = "Khong tim thay phieu sua chua" });
            }

            var oldStatus = ticket.Status;
            var newStatus = input.Status.ToUpperInvariant();
            ticket.Status = newStatus;
            ticket.UpdatedAt = DateTime.Now;

            if (newStatus == "COMPLETED")
            {
                ticket.CompletedAt = DateTime.Now;
            }
            else if (newStatus == "DELIVERED")
            {
                ticket.DeliveredAt = DateTime.Now;
            }

            // MBA-56: Ghi nhan Transaction nhat ky trang thai phieu (TicketStatusHistory)
            var session = AuthHelper.GetSession(request, store);
            var changedByUsername = (session?.Username ?? "admin").ToLower();
            var changedByUser = await db.Users.FirstOrDefaultAsync(x => x.Username.ToLower() == changedByUsername);

            db.TicketStatusHistories.Add(new TicketStatusHistory
            {
                TicketId = ticket.TicketId,
                FromStatus = oldStatus,
                ToStatus = newStatus,
                ChangedByUserId = changedByUser?.UserId ?? ticket.ReceivedByUserId,
                Note = $"Cap nhat trang thai tu {oldStatus} sang {newStatus}"
            });

            await db.SaveChangesAsync();

            var updated = await FindTicket(db, code);
            return Results.Ok(AuthHelper.EnrichTicket(updated!));
        });

        // MBA-56: API xem lich su chuyen doi trang thai phieu sua chua (Audit Trail)
        app.MapGet("/api/tickets/{code}/logs", async (HttpRequest request, string code, AppDbContext db, SessionStore store) =>
        {
            var auth = AuthHelper.RequireRole(request, store, "ADMIN", "STAFF", "TECHNICIAN");
            if (auth is not null)
            {
                return auth;
            }

            var logs = await db.TicketStatusHistories
                .Include(x => x.Ticket)
                .Include(x => x.ChangedByUser)
                .Where(x => x.Ticket.TicketCode.ToLower() == code.ToLower())
                .OrderBy(x => x.ChangedAt)
                .Select(x => new
                {
                    LogId = x.HistoryId,
                    TicketCode = x.Ticket.TicketCode,
                    OldStatus = x.FromStatus,
                    NewStatus = x.ToStatus,
                    ChangedByUsername = x.ChangedByUser.Username,
                    x.ChangedAt,
                    x.Note
                })
                .ToListAsync();

            return Results.Ok(logs);
        });

        // CỔNG TRA CỨU TIẾN ĐỘ SỬA CHỮA CÔNG KHAI (KHÔNG CẦN ĐĂNG NHẬP)
        app.MapGet("/api/public/track", async (string? query, AppDbContext db) =>
        {
            if (string.IsNullOrWhiteSpace(query))
            {
                return Results.BadRequest(new { message = "Vui lòng nhập mã phiếu hoặc số điện thoại để tra cứu" });
            }

            var cleanQuery = query.Trim().ToLowerInvariant();
            var tickets = await db.RepairTickets
                .Include(x => x.Customer)
                .Include(x => x.Device)
                .Include(x => x.ServiceType)
                .Include(x => x.TechnicianUser)
                .Where(x => x.TicketCode.ToLower() == cleanQuery || (x.Customer != null && x.Customer.Phone.ToLower() == cleanQuery))
                .OrderByDescending(x => x.CreatedAt)
                .Take(5)
                .Select(x => new
                {
                    TicketCode = x.TicketCode,
                    CustomerName = x.Customer != null ? x.Customer.FullName : "Khách hàng",
                    Phone = x.Customer != null ? (x.Customer.Phone.Length > 4 ? x.Customer.Phone.Substring(0, x.Customer.Phone.Length - 4) + "****" : x.Customer.Phone) : "",
                    DeviceModel = x.Device != null ? $"{x.Device.Brand} {x.Device.Model}" : "Thiết bị sửa chữa",
                    DeviceType = x.Device != null ? x.Device.DeviceType : "Thiết bị",
                    SerialNumber = x.Device != null ? x.Device.SerialNumber : "",
                    ServiceName = x.ServiceType != null ? x.ServiceType.ServiceName : "Dịch vụ sửa chữa",
                    FaultDescription = x.CustomerRequest ?? x.DeviceCondition ?? "Kiểm tra và sửa chữa",
                    Diagnosis = x.Diagnosis,
                    Status = x.Status,
                    CreatedAt = x.CreatedAt,
                    ExpectedFinishAt = x.ExpectedFinishAt,
                    CompletedAt = x.CompletedAt,
                    TechnicianName = x.TechnicianUser != null ? x.TechnicianUser.FullName : "Kỹ thuật viên đang tiếp nhận",
                    LaborCost = x.QuotedLaborCost,
                    PartsCost = x.QuotedPartsCost,
                    TotalAmount = x.QuotedLaborCost + x.QuotedPartsCost
                })
                .ToListAsync();

            return Results.Ok(tickets);
        });

        // CỔNG ĐẶT LỊCH HẸN TIẾP NHẬN SỬA CHỮA TRỰC TUYẾN
        app.MapPost("/api/public/appointment", async (PublicAppointmentRequest req, AppDbContext db) =>
        {
            if (string.IsNullOrWhiteSpace(req.FullName) || string.IsNullOrWhiteSpace(req.Phone))
            {
                return Results.BadRequest(new { message = "Họ tên và số điện thoại là bắt buộc" });
            }

            var cleanPhone = req.Phone.Trim();
            var customer = await db.Customers.FirstOrDefaultAsync(x => x.Phone == cleanPhone);
            if (customer == null)
            {
                var custCount = await db.Customers.CountAsync();
                customer = new Customer
                {
                    CustomerCode = $"KH{custCount + 1:D4}",
                    FullName = req.FullName.Trim(),
                    Phone = cleanPhone,
                    Email = req.Email?.Trim(),
                    Address = req.Address?.Trim(),
                    CreatedAt = DateTime.Now
                };
                db.Customers.Add(customer);
                await db.SaveChangesAsync();
            }

            var devCount = await db.Devices.CountAsync();
            var device = new Device
            {
                DeviceCode = $"TB{devCount + 1:D6}",
                CustomerId = customer.CustomerId,
                DeviceType = string.IsNullOrWhiteSpace(req.DeviceType) ? "Thiết bị điện tử" : req.DeviceType.Trim(),
                Brand = string.IsNullOrWhiteSpace(req.Brand) ? "Chưa rõ" : req.Brand.Trim(),
                Model = string.IsNullOrWhiteSpace(req.Model) ? "Thiết bị khách mang đến" : req.Model.Trim(),
                SerialNumber = req.SerialNumber?.Trim()
            };
            db.Devices.Add(device);
            await db.SaveChangesAsync();

            var defaultService = await db.ServiceTypes.FirstOrDefaultAsync();
            var staffUser = await db.Users.Include(u => u.Role).FirstOrDefaultAsync(u => u.Role.RoleCode == "STAFF")
                ?? await db.Users.FirstAsync();

            var ticketCount = await db.RepairTickets.CountAsync();
            var ticket = new RepairTicket
            {
                TicketCode = $"TICK{ticketCount + 1:D4}",
                CustomerId = customer.CustomerId,
                DeviceId = device.DeviceId,
                ServiceTypeId = defaultService?.ServiceTypeId,
                ReceivedByUserId = staffUser.UserId,
                CustomerRequest = string.IsNullOrWhiteSpace(req.FaultDescription) ? "Yêu cầu kiểm tra & sửa chữa trực tuyến" : req.FaultDescription.Trim(),
                DeviceCondition = $"[Đặt hẹn online: {req.PreferredTime ?? "Trong ngày"}]",
                Status = "RECEIVED",
                QuotedLaborCost = defaultService?.LaborCost ?? 0,
                ReceivedAt = DateTime.Now,
                CreatedAt = DateTime.Now,
                ExpectedFinishAt = DateTime.Now.AddDays(1)
            };
            db.RepairTickets.Add(ticket);
            await db.SaveChangesAsync();

            return Results.Ok(new
            {
                message = "Đặt lịch hẹn sửa chữa thành công! Đội ngũ kỹ thuật đã tiếp nhận yêu cầu.",
                ticketCode = ticket.TicketCode,
                customerCode = customer.CustomerCode,
                customerName = customer.FullName,
                phone = customer.Phone,
                deviceModel = $"{device.Brand} {device.Model}"
            });
        });
    }

    private static IQueryable<RepairTicket> IncludeTicket(IQueryable<RepairTicket> query)
    {
        return query
            .Include(x => x.Customer)
            .Include(x => x.Device)
            .Include(x => x.ServiceType)
            .Include(x => x.ReceivedByUser)
            .Include(x => x.TechnicianUser);
    }

    private static Task<RepairTicket?> FindTicket(AppDbContext db, string code)
    {
        return IncludeTicket(db.RepairTickets)
            .FirstOrDefaultAsync(x => x.TicketCode.ToLower() == code.ToLower());
    }
}
