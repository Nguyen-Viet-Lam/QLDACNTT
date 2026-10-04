using QLDACNTT.Api.Contracts;
using QLDACNTT.Api.Data;
using QLDACNTT.Api.Infrastructure;
using QLDACNTT.Api.Models;

namespace QLDACNTT.Api.Endpoints;

/// <summary>
/// Module API Quản lý kho linh kiện và Cảnh báo tồn kho (Sprint 6 - In Progress)
/// Phụ trách: Nguyễn Viết Lãm (PM / Backend Lead)
/// Ánh xạ bảng CSDL: dbo.SpareParts, dbo.StockTransactions
/// </summary>
public static class InventoryEndpoints
{
    public static void MapInventoryEndpoints(this WebApplication app, AppData data)
    {
        // 1. Thống kê tổng quan kho linh kiện
        app.MapGet("/api/inventory/summary", (HttpRequest request) =>
        {
            var auth = AuthHelper.RequireRole(request, data, "ADMIN", "STAFF");
            if (auth is not null)
            {
                return auth;
            }

            var totalItems = data.SpareParts.Count;
            var totalQuantity = data.SpareParts.Sum(x => x.StockQuantity);
            var totalValue = data.SpareParts.Sum(x => x.StockQuantity * x.SellingPrice);
            var lowStockItems = data.SpareParts.Where(x => x.StockQuantity <= x.MinStockLevel).ToList();

            return Results.Ok(new
            {
                totalCatalogItems = totalItems,
                totalStockQuantity = totalQuantity,
                estimatedStockValue = totalValue,
                lowStockCount = lowStockItems.Count,
                alert = lowStockItems.Count > 0 ? "Co linh kien duoi muc an toan toi thieu can nhap them!" : "Muc ton kho an toan"
            });
        });

        // 2. Lọc danh sách linh kiện chạm ngưỡng cảnh báo tồn tối thiểu
        app.MapGet("/api/inventory/low-stock", (HttpRequest request) =>
        {
            var auth = AuthHelper.RequireRole(request, data, "ADMIN", "STAFF", "TECHNICIAN");
            if (auth is not null)
            {
                return auth;
            }

            var lowStock = data.SpareParts
                .Where(x => x.StockQuantity <= x.MinStockLevel)
                .Select(x => new
                {
                    partCode = x.Code,
                    partName = x.Name,
                    currentStock = x.StockQuantity,
                    minRequiredStock = x.MinStockLevel,
                    shortage = x.MinStockLevel - x.StockQuantity,
                    sellingPrice = x.SellingPrice,
                    status = x.StockQuantity == 0 ? "HET_HANG" : "SAP_HET"
                });

            return Results.Ok(lowStock);
        });

        // 3. Xem lịch sử giao dịch xuất/nhập linh kiện
        app.MapGet("/api/inventory/transactions", (HttpRequest request, string? partCode, string? ticketCode) =>
        {
            var auth = AuthHelper.RequireRole(request, data, "ADMIN", "STAFF", "TECHNICIAN");
            if (auth is not null)
            {
                return auth;
            }

            var query = data.StockTransactions.AsEnumerable();
            if (!string.IsNullOrWhiteSpace(partCode))
            {
                query = query.Where(x => x.PartCode.Equals(partCode, StringComparison.OrdinalIgnoreCase));
            }

            if (!string.IsNullOrWhiteSpace(ticketCode))
            {
                query = query.Where(x => x.TicketCode is not null && x.TicketCode.Equals(ticketCode, StringComparison.OrdinalIgnoreCase));
            }

            return Results.Ok(query.OrderByDescending(x => x.TransactionAt));
        });

        // 4. Tạo giao dịch nhập / xuất linh kiện theo phiếu sửa chữa
        // TODO: Dang hoan thien kiem tra rang buoc khoa ngoai voi TicketCode (Sprint 6 - In Progress)
        app.MapPost("/api/inventory/transactions", (HttpRequest request, CreateStockTransactionRequest input) =>
        {
            var auth = AuthHelper.RequireRole(request, data, "ADMIN", "STAFF", "TECHNICIAN");
            if (auth is not null)
            {
                return auth;
            }

            var currentSession = AuthHelper.GetSession(request, data)!;

            var partIndex = data.SpareParts.FindIndex(x => x.Code.Equals(input.PartCode, StringComparison.OrdinalIgnoreCase));
            if (partIndex < 0)
            {
                return Results.NotFound(new { message = $"Khong tim thay ma linh kien: {input.PartCode}" });
            }

            var part = data.SpareParts[partIndex];
            var type = input.TransactionType.ToUpperInvariant();

            if (type is not ("IN" or "OUT" or "ADJUST"))
            {
                return Results.BadRequest(new { message = "Loai giao dich chi chap nhan: IN (Nhap), OUT (Xuat), ADJUST (Dieu chinh)" });
            }

            if (input.Quantity <= 0)
            {
                return Results.BadRequest(new { message = "So luong giao dich phai lon hon 0" });
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

            // Cập nhật số lượng tồn kho mới
            data.SpareParts[partIndex] = part with { StockQuantity = stockAfter };

            // Ghi nhật ký giao dịch kho (StockTransactions)
            var transaction = new StockTransactionDto(
                TransactionId: data.StockTransactions.Count + 1,
                PartCode: part.Code,
                TransactionType: type,
                Quantity: input.Quantity,
                StockBefore: stockBefore,
                StockAfter: stockAfter,
                TicketCode: input.TicketCode?.Trim(),
                PerformedByUsername: currentSession.Username,
                TransactionAt: DateTimeOffset.UtcNow,
                Note: input.Note?.Trim()
            );

            data.StockTransactions.Add(transaction);

            return Results.Created($"/api/inventory/transactions/{transaction.TransactionId}", new
            {
                message = "Giao dich kho thanh cong (Sprint 6 Prototype)",
                transaction,
                warning = stockAfter <= part.MinStockLevel ? "Canh bao: Linh kien sau giao dich da cham muc ton toi thieu!" : null
            });
        });
    }
}
