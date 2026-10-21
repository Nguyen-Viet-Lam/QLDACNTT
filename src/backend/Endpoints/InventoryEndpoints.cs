using Microsoft.EntityFrameworkCore;
using QLDACNTT.Api.Contracts;
using QLDACNTT.Api.Data;
using QLDACNTT.Api.Infrastructure;
using QLDACNTT.Api.Models;

namespace QLDACNTT.Api.Endpoints;

/// <summary>
/// Module API Quản lý kho linh kiện và Cảnh báo tồn kho
/// Ánh xạ bảng CSDL: dbo.SpareParts, dbo.StockTransactions
/// </summary>
public static class InventoryEndpoints
{
    public static void MapInventoryEndpoints(this WebApplication app)
    {
        // 1. Thống kê tổng quan kho linh kiện
        app.MapGet("/api/inventory/summary", async (HttpRequest request, AppDbContext db, SessionStore store) =>
        {
            var auth = AuthHelper.RequireRole(request, store, "ADMIN", "STAFF");
            if (auth is not null)
            {
                return auth;
            }

            var totalItems = await db.SpareParts.CountAsync();
            var totalQuantity = await db.SpareParts.SumAsync(x => x.StockQuantity);
            var totalValue = await db.SpareParts.SumAsync(x => x.StockQuantity * x.SellingPrice);
            var lowStockCount = await db.SpareParts.CountAsync(x => x.StockQuantity <= x.MinStockLevel);

            return Results.Ok(new
            {
                totalCatalogItems = totalItems,
                totalStockQuantity = totalQuantity,
                estimatedStockValue = totalValue,
                lowStockCount,
                alert = lowStockCount > 0 ? "Co linh kien duoi muc an toan toi thieu can nhap them!" : "Muc ton kho an toan"
            });
        });

        // 2. Lọc danh sách linh kiện chạm ngưỡng cảnh báo tồn tối thiểu
        app.MapGet("/api/inventory/low-stock", async (HttpRequest request, AppDbContext db, SessionStore store) =>
        {
            var auth = AuthHelper.RequireRole(request, store, "ADMIN", "STAFF", "TECHNICIAN");
            if (auth is not null)
            {
                return auth;
            }

            var lowStock = await db.SpareParts
                .Where(x => x.StockQuantity <= x.MinStockLevel)
                .Select(x => new
                {
                    partCode = x.PartCode,
                    partName = x.PartName,
                    currentStock = x.StockQuantity,
                    minRequiredStock = x.MinStockLevel,
                    shortage = x.MinStockLevel - x.StockQuantity,
                    sellingPrice = x.SellingPrice,
                    status = x.StockQuantity == 0 ? "HET_HANG" : "SAP_HET"
                })
                .ToListAsync();

            return Results.Ok(lowStock);
        });

        // 3. Xem lịch sử giao dịch xuất/nhập linh kiện
        app.MapGet("/api/inventory/transactions", async (HttpRequest request, string? partCode, string? ticketCode, AppDbContext db, SessionStore store) =>
        {
            var auth = AuthHelper.RequireRole(request, store, "ADMIN", "STAFF", "TECHNICIAN");
            if (auth is not null)
            {
                return auth;
            }

            var query = db.StockTransactions
                .Include(x => x.Part)
                .Include(x => x.Ticket)
                .Include(x => x.PerformedByUser)
                .AsQueryable();

            if (!string.IsNullOrWhiteSpace(partCode))
            {
                query = query.Where(x => x.Part.PartCode.ToLower() == partCode.ToLower());
            }

            if (!string.IsNullOrWhiteSpace(ticketCode))
            {
                query = query.Where(x => x.Ticket != null && x.Ticket.TicketCode.ToLower() == ticketCode.ToLower());
            }

            var transactions = await query
                .OrderByDescending(x => x.TransactionAt)
                .Select(x => new
                {
                    TransactionId = x.TransactionId,
                    PartCode = x.Part.PartCode,
                    TransactionType = x.TransactionType,
                    x.Quantity,
                    x.StockBefore,
                    x.StockAfter,
                    TicketCode = x.Ticket != null ? x.Ticket.TicketCode : null,
                    PerformedByUsername = x.PerformedByUser.Username,
                    x.TransactionAt,
                    x.Note
                })
                .ToListAsync();

            return Results.Ok(transactions);
        });

        // 4. Tạo giao dịch nhập / xuất linh kiện theo phiếu sửa chữa
        app.MapPost("/api/inventory/transactions", async (HttpRequest request, CreateStockTransactionRequest input, AppDbContext db, SessionStore store) =>
        {
            var auth = AuthHelper.RequireRole(request, store, "ADMIN", "STAFF", "TECHNICIAN");
            if (auth is not null)
            {
                return auth;
            }

            var currentSession = AuthHelper.GetSession(request, store)!;
            var currentUser = await db.Users.FirstOrDefaultAsync(x => x.Username.ToLower() == currentSession.Username.ToLower());
            if (currentUser is null)
            {
                return Results.Unauthorized();
            }

            var partCode = input.PartCode?.Trim();
            if (string.IsNullOrWhiteSpace(partCode))
            {
                return Results.BadRequest(new { message = "Ma linh kien khong duoc de trong" });
            }

            var part = await db.SpareParts.FirstOrDefaultAsync(x => x.PartCode.ToLower() == partCode.ToLower());
            if (part is null)
            {
                return Results.NotFound(new { message = $"Khong tim thay ma linh kien: {partCode}" });
            }

            var type = input.TransactionType?.Trim().ToUpperInvariant();
            if (type is not ("IN" or "OUT" or "ADJUST" or "RETURN"))
            {
                return Results.BadRequest(new { message = "Loai giao dich chi chap nhan: IN, OUT, ADJUST, RETURN" });
            }

            if (input.Quantity <= 0)
            {
                return Results.BadRequest(new { message = "So luong giao dich phai lon hon 0" });
            }

            var ticketCode = input.TicketCode?.Trim();
            RepairTicket? ticket = null;
            if (type == "OUT" && string.IsNullOrWhiteSpace(ticketCode))
            {
                return Results.BadRequest(new { message = "Giao dich OUT phai gan voi mot phieu sua chua" });
            }

            if (!string.IsNullOrWhiteSpace(ticketCode))
            {
                ticket = await db.RepairTickets.FirstOrDefaultAsync(x => x.TicketCode.ToLower() == ticketCode.ToLower());
                if (ticket is null)
                {
                    return Results.BadRequest(new { message = $"Khong tim thay phieu sua chua: {ticketCode}" });
                }
            }

            var stockBefore = part.StockQuantity;
            int stockAfter;

            if (type == "OUT")
            {
                if (input.Quantity > stockBefore)
                {
                    return Results.BadRequest(new
                    {
                        message = $"Khong the xuat kho! So luong ton hien tai ({stockBefore}) khong du de xuat ({input.Quantity})"
                    });
                }

                stockAfter = stockBefore - input.Quantity;
            }
            else
            {
                stockAfter = stockBefore + input.Quantity;
            }

            part.StockQuantity = stockAfter;
            part.UpdatedAt = DateTime.Now;

            var transaction = new StockTransaction
            {
                PartId = part.PartId,
                TransactionType = type,
                Quantity = input.Quantity,
                UnitPrice = part.SellingPrice,
                StockBefore = stockBefore,
                StockAfter = stockAfter,
                TicketId = ticket?.TicketId,
                PerformedByUserId = currentUser.UserId,
                Note = input.Note?.Trim()
            };

            db.StockTransactions.Add(transaction);
            await db.SaveChangesAsync();

            return Results.Created($"/api/inventory/transactions/{transaction.TransactionId}", new
            {
                message = "Giao dich kho thanh cong",
                transaction = new
                {
                    transaction.TransactionId,
                    PartCode = part.PartCode,
                    TransactionType = transaction.TransactionType,
                    transaction.Quantity,
                    transaction.StockBefore,
                    transaction.StockAfter,
                    TicketCode = ticket?.TicketCode,
                    PerformedByUsername = currentUser.Username,
                    transaction.TransactionAt,
                    transaction.Note
                },
                warning = stockAfter <= part.MinStockLevel ? "Canh bao: Linh kien sau giao dich da cham muc ton toi thieu!" : null
            });
        });
    }
}
