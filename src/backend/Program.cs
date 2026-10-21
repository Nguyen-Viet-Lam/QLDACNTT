using Microsoft.EntityFrameworkCore;
using QLDACNTT.Api.Data;
using QLDACNTT.Api.Endpoints;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddCors(options =>
{
    options.AddDefaultPolicy(policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyHeader()
              .AllowAnyMethod();
    });
});

var connectionString = builder.Configuration.GetConnectionString("DefaultConnection")
    ?? "Server=.;Database=RepairShopDB;Integrated Security=True;TrustServerCertificate=True;Connect Timeout=15";

builder.Services.AddDbContext<AppDbContext>(options => options.UseSqlServer(connectionString));
builder.Services.AddSingleton<SessionStore>();

var app = builder.Build();
app.UseCors();

using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
    try
    {
        db.Database.Migrate();
    }
    catch (Exception ex)
    {
        Console.WriteLine($"[INFO] DB Migrate check: {ex.Message}");
    }

    try
    {
        DbSeeder.Seed(db);
    }
    catch (Exception ex)
    {
        Console.WriteLine($"[INFO] DB Seed check: {ex.Message}");
    }
}

app.MapGet("/admin", () => ServeWebIndex(app));
app.MapGet("/portal", () => ServeWebIndex(app));

app.MapGet("/", (HttpContext context) =>
{
    var accept = context.Request.Headers.Accept.ToString();
    if (accept.Contains("application/json") && !accept.Contains("text/html"))
    {
        return Results.Ok(new
        {
            name = "QLDACNTT Backend",
            stage = "He thong quan ly tong the cho cua hang sua chua - LV33-001",
            authHeader = "X-Session-Token",
            accounts = new[]
            {
                "admin / Abc@12345 (Quan tri vien)",
                "staff01 / Abc@12345 (Nhan vien tiep nhan)",
                "tech01 / Abc@12345 (Ky thuat vien)",
                "tech02 / Abc@12345 (Ky thuat vien)",
                "khach01 / Abc@12345 (Khach hang demo)"
            },
            endpointGroups = new[]
            {
                "/api/auth",
                "/api/public",
                "/api/users",
                "/api/customers",
                "/api/service-types",
                "/api/spare-parts",
                "/api/tickets",
                "/api/dashboard/summary",
                "/api/inventory",
                "/api/invoices",
                "/api/warranties",
                "/api/reports"
            }
        });
    }

    return ServeWebIndex(app);
});

static IResult ServeWebIndex(WebApplication app)
{
    var adminHtmlPath = Path.Combine(app.Environment.ContentRootPath, "..", "web-admin", "index.html");
    if (File.Exists(adminHtmlPath))
    {
        return Results.Content(File.ReadAllText(adminHtmlPath), "text/html; charset=utf-8");
    }
    var localPath = Path.Combine(app.Environment.ContentRootPath, "index.html");
    if (File.Exists(localPath))
    {
        return Results.Content(File.ReadAllText(localPath), "text/html; charset=utf-8");
    }
    return Results.NotFound("web-admin index.html not found");
}


app.MapGet("/health", () => Results.Ok(new
{
    status = "ok",
    checkedAt = DateTimeOffset.UtcNow
}));

app.MapGet("/api/db/status", async (AppDbContext db) =>
{
    try
    {
        var canConnect = await db.Database.CanConnectAsync();
        if (!canConnect)
        {
            return Results.Ok(new { status = "DISCONNECTED", database = "RepairShopDB" });
        }

        return Results.Ok(new
        {
            status = "CONNECTED",
            database = "RepairShopDB",
            server = ".\\SQLEXPRESS",
            usersInDb = await db.Users.CountAsync(),
            ticketsInDb = await db.RepairTickets.CountAsync(),
            sparePartsInDb = await db.SpareParts.CountAsync(),
            checkedAt = DateTimeOffset.UtcNow
        });
    }
    catch (Exception ex)
    {
        return Results.Ok(new
        {
            status = "ERROR",
            database = "RepairShopDB",
            error = ex.Message
        });
    }
});

app.MapAuthEndpoints();
app.MapCatalogEndpoints();
app.MapTicketEndpoints();
app.MapDashboardEndpoints();
app.MapInventoryEndpoints();
app.MapBillingAndWarrantyEndpoints();
app.MapReportEndpoints();

app.Run();
