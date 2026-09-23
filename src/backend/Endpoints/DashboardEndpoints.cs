using QLDACNTT.Api.Data;
using QLDACNTT.Api.Infrastructure;

namespace QLDACNTT.Api.Endpoints;

public static class DashboardEndpoints
{
    public static void MapDashboardEndpoints(this WebApplication app, AppData data)
    {
        app.MapGet("/api/dashboard/summary", (HttpRequest request) =>
        {
            var auth = AuthHelper.RequireRole(request, data, "ADMIN");
            if (auth is not null)
            {
                return auth;
            }

            return Results.Ok(new
            {
                totalCustomers = data.Customers.Count,
                totalDevices = data.Devices.Count,
                totalTickets = data.Tickets.Count,
                ticketsByStatus = data.Tickets.GroupBy(x => x.Status).ToDictionary(x => x.Key, x => x.Count()),
                lowStockParts = data.SpareParts.Count(x => x.StockQuantity <= x.MinStockLevel),
                estimatedRevenue = data.Tickets.Sum(x => x.QuotedLaborCost)
            });
        });
    }
}
