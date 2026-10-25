using Microsoft.EntityFrameworkCore;
using QLDACNTT.Api.Data;
using QLDACNTT.Api.Infrastructure;

namespace QLDACNTT.Api.Endpoints;

public static class DashboardEndpoints
{
    public static void MapDashboardEndpoints(this WebApplication app)
    {
        app.MapGet("/api/dashboard/summary", async (HttpRequest request, AppDbContext db, SessionStore store) =>
        {
            var auth = AuthHelper.RequireRole(request, store, "ADMIN");
            if (auth is not null)
            {
                return auth;
            }

            var ticketsByStatus = await db.RepairTickets
                .GroupBy(x => x.Status)
                .Select(g => new { Status = g.Key, Count = g.Count() })
                .ToListAsync();

            var lowStockCount = await db.SpareParts.CountAsync(x => x.StockQuantity <= x.MinStockLevel);
            var activeTickets = await db.RepairTickets.CountAsync(x => x.Status != "COMPLETED" && x.Status != "CANCELLED");
            var unpaidInvoices = await db.Invoices.CountAsync(x => x.PaymentStatus == "UNPAID");

            return Results.Ok(new
            {
                totalCustomers = await db.Customers.CountAsync(),
                totalDevices = await db.Devices.CountAsync(),
                totalTickets = await db.RepairTickets.CountAsync(),
                activeTickets,
                lowStockCount,
                lowStockParts = lowStockCount,
                unpaidInvoices,
                ticketsByStatus = ticketsByStatus.ToDictionary(x => x.Status, x => x.Count),
                estimatedRevenue = await db.RepairTickets.SumAsync(x => x.QuotedLaborCost)
            });
        });
    }
}
