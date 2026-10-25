using Microsoft.EntityFrameworkCore;
using QLDACNTT.Api.Contracts;
using QLDACNTT.Api.Data;
using QLDACNTT.Api.Infrastructure;
using QLDACNTT.Api.Models;

namespace QLDACNTT.Api.Endpoints;

public static class CatalogEndpoints
{
    public static void MapCatalogEndpoints(this WebApplication app)
    {
        app.MapGet("/api/customers", async (HttpRequest request, string? keyword, AppDbContext db, SessionStore store) =>
        {
            var auth = AuthHelper.RequireRole(request, store, "ADMIN", "STAFF");
            if (auth is not null)
            {
                return auth;
            }

            var query = db.Customers.AsQueryable();
            if (!string.IsNullOrWhiteSpace(keyword))
            {
                query = query.Where(x =>
                    x.CustomerCode.Contains(keyword)
                    || x.FullName.Contains(keyword)
                    || x.Phone.Contains(keyword));
            }

            var customers = await query.Select(x => new
            {
                x.CustomerId,
                x.CustomerCode,
                Code = x.CustomerCode,
                x.FullName,
                x.Phone,
                x.Email,
                x.Address,
                x.Note,
                x.CreatedAt
            }).ToListAsync();

            return Results.Ok(customers);
        });

        app.MapPost("/api/customers", async (HttpRequest request, CreateCustomerRequest input, AppDbContext db, SessionStore store) =>
        {
            var auth = AuthHelper.RequireRole(request, store, "ADMIN", "STAFF");
            if (auth is not null)
            {
                return auth;
            }

            var count = await db.Customers.CountAsync();
            var customer = new Customer
            {
                CustomerCode = $"KH{count + 1:000000}",
                FullName = input.FullName.Trim(),
                Phone = input.Phone.Trim(),
                Email = input.Email,
                Address = input.Address
            };

            db.Customers.Add(customer);
            await db.SaveChangesAsync();

            return Results.Created($"/api/customers/{customer.CustomerCode}", new
            {
                Code = customer.CustomerCode,
                customer.FullName,
                customer.Phone,
                customer.Email,
                customer.Address
            });
        });

        app.MapGet("/api/customers/{code}/devices", async (HttpRequest request, string code, AppDbContext db, SessionStore store) =>
        {
            var auth = AuthHelper.RequireRole(request, store, "ADMIN", "STAFF", "TECHNICIAN");
            if (auth is not null)
            {
                return auth;
            }

            var devices = await db.Devices
                .Include(x => x.Customer)
                .Where(x => x.Customer.CustomerCode.ToLower() == code.ToLower())
                .Select(x => new
                {
                    Code = x.DeviceCode,
                    CustomerCode = x.Customer.CustomerCode,
                    x.DeviceType,
                    x.Brand,
                    x.Model,
                    x.SerialNumber
                })
                .ToListAsync();

            return Results.Ok(devices);
        });

        app.MapPost("/api/customers/{code}/devices", async (HttpRequest request, string code, CreateDeviceRequest input, AppDbContext db, SessionStore store) =>
        {
            var auth = AuthHelper.RequireRole(request, store, "ADMIN", "STAFF");
            if (auth is not null)
            {
                return auth;
            }

            var customer = await db.Customers.FirstOrDefaultAsync(x => x.CustomerCode.ToLower() == code.ToLower());
            if (customer is null)
            {
                return Results.NotFound(new { message = "Khong tim thay khach hang" });
            }

            var count = await db.Devices.CountAsync();
            var device = new Device
            {
                DeviceCode = $"TB{count + 1:000000}",
                CustomerId = customer.CustomerId,
                DeviceType = input.DeviceType.Trim(),
                Brand = input.Brand,
                Model = input.Model,
                SerialNumber = input.SerialNumber
            };

            db.Devices.Add(device);
            await db.SaveChangesAsync();

            return Results.Created($"/api/customers/{code}/devices/{device.DeviceCode}", new
            {
                Code = device.DeviceCode,
                CustomerCode = customer.CustomerCode,
                device.DeviceType,
                device.Brand,
                device.Model,
                device.SerialNumber
            });
        });

        app.MapGet("/api/service-types", async (HttpRequest request, AppDbContext db, SessionStore store) =>
        {
            var auth = AuthHelper.RequireRole(request, store, "ADMIN", "STAFF", "TECHNICIAN");
            if (auth is not null)
            {
                return auth;
            }

            var serviceTypes = await db.ServiceTypes
                .Where(x => x.IsActive)
                .Select(x => new
                {
                    Code = x.ServiceCode,
                    x.ServiceName,
                    x.LaborCost,
                    x.WarrantyDays
                })
                .ToListAsync();

            return Results.Ok(serviceTypes);
        });

        app.MapGet("/api/spare-parts", async (HttpRequest request, bool? lowStockOnly, AppDbContext db, SessionStore store) =>
        {
            var auth = AuthHelper.RequireRole(request, store, "ADMIN", "STAFF", "TECHNICIAN");
            if (auth is not null)
            {
                return auth;
            }

            var query = db.SpareParts.Where(x => x.IsActive);
            if (lowStockOnly == true)
            {
                query = query.Where(x => x.StockQuantity <= x.MinStockLevel);
            }

            var parts = await query.Include(x => x.Category).Select(x => new
            {
                x.PartId,
                x.PartCode,
                Code = x.PartCode,
                x.PartName,
                Name = x.PartName,
                CategoryName = x.Category != null ? x.Category.CategoryName : "Linh kiện",
                x.CategoryId,
                Unit = x.Unit ?? "Cái",
                x.PurchasePrice,
                x.SellingPrice,
                x.StockQuantity,
                x.MinStockLevel,
                x.WarrantyDays,
                x.IsActive
            }).ToListAsync();

            return Results.Ok(parts);
        });

        app.MapPut("/api/customers/{code}", async (HttpRequest request, string code, UpdateCustomerRequest input, AppDbContext db, SessionStore store) =>
        {
            var auth = AuthHelper.RequireRole(request, store, "ADMIN", "STAFF");
            if (auth is not null) return auth;

            if (string.IsNullOrWhiteSpace(input.FullName) || string.IsNullOrWhiteSpace(input.Phone))
                return Results.BadRequest(new { message = "Ho ten va so dien thoai la bat buoc" });

            var customer = await db.Customers.FirstOrDefaultAsync(x => x.CustomerCode.ToLower() == code.ToLower());
            if (customer is null) return Results.NotFound(new { message = "Khong tim thay khach hang" });

            customer.FullName = input.FullName.Trim();
            customer.Phone = input.Phone.Trim();
            customer.Email = input.Email;
            customer.Address = input.Address;
            customer.UpdatedAt = DateTime.Now;
            await db.SaveChangesAsync();

            return Results.Ok(new { Code = customer.CustomerCode, customer.FullName, customer.Phone, customer.Email, customer.Address });
        });

        app.MapPut("/api/customers/{code}/devices/{deviceCode}", async (HttpRequest request, string code, string deviceCode, UpdateDeviceRequest input, AppDbContext db, SessionStore store) =>
        {
            var auth = AuthHelper.RequireRole(request, store, "ADMIN", "STAFF");
            if (auth is not null) return auth;

            if (string.IsNullOrWhiteSpace(input.DeviceType))
                return Results.BadRequest(new { message = "Loai thiet bi la bat buoc" });

            var device = await db.Devices.Include(x => x.Customer).FirstOrDefaultAsync(x =>
                x.DeviceCode.ToLower() == deviceCode.ToLower() && x.Customer.CustomerCode.ToLower() == code.ToLower());
            if (device is null) return Results.NotFound(new { message = "Khong tim thay thiet bi" });

            device.DeviceType = input.DeviceType.Trim();
            device.Brand = input.Brand;
            device.Model = input.Model;
            device.SerialNumber = input.SerialNumber;
            await db.SaveChangesAsync();

            return Results.Ok(new { Code = device.DeviceCode, CustomerCode = device.Customer.CustomerCode, device.DeviceType, device.Brand, device.Model, device.SerialNumber });
        });

        app.MapPost("/api/service-types", async (HttpRequest request, UpsertServiceTypeRequest input, AppDbContext db, SessionStore store) =>
        {
            var auth = AuthHelper.RequireRole(request, store, "ADMIN");
            if (auth is not null) return auth;

            if (string.IsNullOrWhiteSpace(input.ServiceName) || input.LaborCost < 0 || input.WarrantyDays < 0)
                return Results.BadRequest(new { message = "Du lieu dich vu khong hop le" });

            var count = await db.ServiceTypes.CountAsync();
            var service = new ServiceType
            {
                ServiceCode = $"DV{count + 1:000}",
                ServiceName = input.ServiceName.Trim(),
                LaborCost = input.LaborCost,
                WarrantyDays = input.WarrantyDays,
                Description = input.Description
            };
            db.ServiceTypes.Add(service);
            await db.SaveChangesAsync();

            return Results.Created($"/api/service-types/{service.ServiceCode}", new { Code = service.ServiceCode, service.ServiceName, service.LaborCost, service.WarrantyDays });
        });

        app.MapPut("/api/service-types/{code}", async (HttpRequest request, string code, UpsertServiceTypeRequest input, AppDbContext db, SessionStore store) =>
        {
            var auth = AuthHelper.RequireRole(request, store, "ADMIN");
            if (auth is not null) return auth;

            if (string.IsNullOrWhiteSpace(input.ServiceName) || input.LaborCost < 0 || input.WarrantyDays < 0)
                return Results.BadRequest(new { message = "Du lieu dich vu khong hop le" });

            var service = await db.ServiceTypes.FirstOrDefaultAsync(x => x.ServiceCode.ToLower() == code.ToLower());
            if (service is null) return Results.NotFound(new { message = "Khong tim thay dich vu" });

            service.ServiceName = input.ServiceName.Trim();
            service.LaborCost = input.LaborCost;
            service.WarrantyDays = input.WarrantyDays;
            service.Description = input.Description;
            await db.SaveChangesAsync();

            return Results.Ok(new { Code = service.ServiceCode, service.ServiceName, service.LaborCost, service.WarrantyDays });
        });

        app.MapDelete("/api/service-types/{code}", async (HttpRequest request, string code, AppDbContext db, SessionStore store) =>
        {
            var auth = AuthHelper.RequireRole(request, store, "ADMIN");
            if (auth is not null) return auth;

            var service = await db.ServiceTypes.FirstOrDefaultAsync(x => x.ServiceCode.ToLower() == code.ToLower());
            if (service is null) return Results.NotFound(new { message = "Khong tim thay dich vu" });

            service.IsActive = false;
            await db.SaveChangesAsync();
            return Results.NoContent();
        });

        app.MapPost("/api/spare-parts", async (HttpRequest request, UpsertSparePartRequest input, AppDbContext db, SessionStore store) =>
        {
            var auth = AuthHelper.RequireRole(request, store, "ADMIN");
            if (auth is not null) return auth;

            var error = ValidatePart(input);
            if (error is not null) return Results.BadRequest(new { message = error });

            if (input.CategoryId is null && !await db.SparePartCategories.AnyAsync())
            {
                db.SparePartCategories.Add(new SparePartCategory { CategoryName = "Khac" });
                await db.SaveChangesAsync();
            }

            var categoryId = input.CategoryId ?? await db.SparePartCategories.Select(x => x.CategoryId).FirstOrDefaultAsync();
            if (!await db.SparePartCategories.AnyAsync(x => x.CategoryId == categoryId))
                return Results.BadRequest(new { message = "Danh muc phu tung khong ton tai" });

            var count = await db.SpareParts.CountAsync();
            var part = new SparePart
            {
                PartCode = $"PT{count + 1:0000}",
                CategoryId = categoryId,
                PartName = input.PartName.Trim(),
                Unit = string.IsNullOrWhiteSpace(input.Unit) ? "Cái" : input.Unit.Trim(),
                PurchasePrice = input.PurchasePrice,
                SellingPrice = input.SellingPrice,
                MinStockLevel = input.MinStockLevel,
                WarrantyDays = input.WarrantyDays
            };
            db.SpareParts.Add(part);
            await db.SaveChangesAsync();

            return Results.Created($"/api/spare-parts/{part.PartCode}", new { Code = part.PartCode, Name = part.PartName, part.StockQuantity, part.MinStockLevel, part.SellingPrice });
        });

        app.MapPut("/api/spare-parts/{code}", async (HttpRequest request, string code, UpsertSparePartRequest input, AppDbContext db, SessionStore store) =>
        {
            var auth = AuthHelper.RequireRole(request, store, "ADMIN");
            if (auth is not null) return auth;

            var error = ValidatePart(input);
            if (error is not null) return Results.BadRequest(new { message = error });

            var part = await db.SpareParts.FirstOrDefaultAsync(x => x.PartCode.ToLower() == code.ToLower());
            if (part is null) return Results.NotFound(new { message = "Khong tim thay phu tung" });

            if (input.CategoryId is int cid)
            {
                if (!await db.SparePartCategories.AnyAsync(x => x.CategoryId == cid))
                    return Results.BadRequest(new { message = "Danh muc phu tung khong ton tai" });
                part.CategoryId = cid;
            }
            part.PartName = input.PartName.Trim();
            if (!string.IsNullOrWhiteSpace(input.Unit)) part.Unit = input.Unit.Trim();
            part.PurchasePrice = input.PurchasePrice;
            part.SellingPrice = input.SellingPrice;
            part.MinStockLevel = input.MinStockLevel;
            part.WarrantyDays = input.WarrantyDays;
            part.UpdatedAt = DateTime.Now;
            await db.SaveChangesAsync();

            return Results.Ok(new { Code = part.PartCode, Name = part.PartName, part.StockQuantity, part.MinStockLevel, part.SellingPrice });
        });

        app.MapDelete("/api/spare-parts/{code}", async (HttpRequest request, string code, AppDbContext db, SessionStore store) =>
        {
            var auth = AuthHelper.RequireRole(request, store, "ADMIN");
            if (auth is not null) return auth;

            var part = await db.SpareParts.FirstOrDefaultAsync(x => x.PartCode.ToLower() == code.ToLower());
            if (part is null) return Results.NotFound(new { message = "Khong tim thay phu tung" });

            part.IsActive = false;
            part.UpdatedAt = DateTime.Now;
            await db.SaveChangesAsync();
            return Results.NoContent();
        });

        // CỔNG DỊCH VỤ CÔNG KHAI CHO KHÁCH HÀNG (PUBLIC SERVICE CATALOG)
        app.MapGet("/api/public/services", async (AppDbContext db) =>
        {
            var list = await db.ServiceTypes
                .Where(x => x.IsActive)
                .OrderBy(x => x.ServiceTypeId)
                .Select(x => new
                {
                    Code = x.ServiceCode,
                    Name = x.ServiceName,
                    LaborCost = x.LaborCost,
                    WarrantyDays = x.WarrantyDays,
                    Description = x.Description
                })
                .ToListAsync();
            return Results.Ok(list);
        });
    }

    private static string? ValidatePart(UpsertSparePartRequest input)
    {
        if (string.IsNullOrWhiteSpace(input.PartName)) return "Ten phu tung la bat buoc";
        if (input.PurchasePrice < 0 || input.SellingPrice < 0 || input.MinStockLevel < 0 || input.WarrantyDays < 0)
            return "Gia, ton toi thieu va bao hanh khong duoc am";
        return null;
    }
}
