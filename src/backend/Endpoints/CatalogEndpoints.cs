using QLDACNTT.Api.Contracts;
using QLDACNTT.Api.Data;
using QLDACNTT.Api.Infrastructure;
using QLDACNTT.Api.Models;

namespace QLDACNTT.Api.Endpoints;

public static class CatalogEndpoints
{
    public static void MapCatalogEndpoints(this WebApplication app, AppData data)
    {
        app.MapGet("/api/customers", (HttpRequest request, string? keyword) =>
        {
            var auth = AuthHelper.RequireRole(request, data, "ADMIN", "STAFF");
            if (auth is not null)
            {
                return auth;
            }

            var query = data.Customers.AsEnumerable();
            if (!string.IsNullOrWhiteSpace(keyword))
            {
                query = query.Where(x =>
                    x.Code.Contains(keyword, StringComparison.OrdinalIgnoreCase)
                    || x.FullName.Contains(keyword, StringComparison.OrdinalIgnoreCase)
                    || x.Phone.Contains(keyword, StringComparison.OrdinalIgnoreCase));
            }

            return Results.Ok(query);
        });

        app.MapPost("/api/customers", (HttpRequest request, CreateCustomerRequest input) =>
        {
            var auth = AuthHelper.RequireRole(request, data, "ADMIN", "STAFF");
            if (auth is not null)
            {
                return auth;
            }

            var customer = new CustomerDto(
                $"KH{data.Customers.Count + 1:000000}",
                input.FullName.Trim(),
                input.Phone.Trim(),
                input.Email,
                input.Address);

            data.Customers.Add(customer);
            return Results.Created($"/api/customers/{customer.Code}", customer);
        });

        app.MapGet("/api/customers/{code}/devices", (HttpRequest request, string code) =>
        {
            var auth = AuthHelper.RequireRole(request, data, "ADMIN", "STAFF", "TECHNICIAN");
            return auth ?? Results.Ok(data.Devices.Where(x => x.CustomerCode.Equals(code, StringComparison.OrdinalIgnoreCase)));
        });

        app.MapPost("/api/customers/{code}/devices", (HttpRequest request, string code, CreateDeviceRequest input) =>
        {
            var auth = AuthHelper.RequireRole(request, data, "ADMIN", "STAFF");
            if (auth is not null)
            {
                return auth;
            }

            if (data.Customers.All(x => !x.Code.Equals(code, StringComparison.OrdinalIgnoreCase)))
            {
                return Results.NotFound(new { message = "Khong tim thay khach hang" });
            }

            var device = new DeviceDto(
                $"TB{data.Devices.Count + 1:000000}",
                code.ToUpperInvariant(),
                input.DeviceType.Trim(),
                input.Brand,
                input.Model,
                input.SerialNumber);

            data.Devices.Add(device);
            return Results.Created($"/api/customers/{code}/devices/{device.Code}", device);
        });

        app.MapGet("/api/service-types", (HttpRequest request) =>
        {
            var auth = AuthHelper.RequireRole(request, data, "ADMIN", "STAFF", "TECHNICIAN");
            return auth ?? Results.Ok(data.ServiceTypes);
        });

        app.MapGet("/api/spare-parts", (HttpRequest request, bool? lowStockOnly) =>
        {
            var auth = AuthHelper.RequireRole(request, data, "ADMIN", "STAFF", "TECHNICIAN");
            if (auth is not null)
            {
                return auth;
            }

            var query = data.SpareParts.AsEnumerable();
            if (lowStockOnly == true)
            {
                query = query.Where(x => x.StockQuantity <= x.MinStockLevel);
            }

            return Results.Ok(query);
        });
    }
}
