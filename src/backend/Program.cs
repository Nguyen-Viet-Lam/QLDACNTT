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

var app = builder.Build();
app.UseCors();
var data = AppData.CreateDemo();

app.MapGet("/admin", () =>
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
});

app.MapGet("/", () => Results.Ok(new
{
    name = "QLDACNTT Backend Prototype",
    stage = "Tuan 3 - backend mau dang nhap, phan quyen va nghiep vu nen",
    authHeader = "X-Session-Token",
    accounts = new[]
    {
        "admin / 123456 (Nguyen Viet Lam - PM / ADMIN)",
        "staff / 123456 (Nhan vien tiep nhan)",
        "loi.staff / 123456 (Tran Ngoc Loi - BA / Tiep nhan)",
        "staff01 / 123456 (Le Thi Tiep Nhan)",
        "tech / 123456 (Ky thuat vien)",
        "ky.tech / 123456 (Nguyen Dai Ky - QA / Ky thuat)",
        "tech01 / 123456 (Pham Van Ky Thuat)",
        "customer / 123456 (Khach hang demo)",
        "khach01 / 123456 (Nguyen Van An)",
        "khach02 / 123456 (Tran Thi Binh)"
    },
    endpointGroups = new[]
    {
        "/api/auth",
        "/api/users",
        "/api/customers",
        "/api/service-types",
        "/api/spare-parts",
        "/api/tickets",
        "/api/dashboard/summary",
        "/api/inventory"
    }
}));

app.MapGet("/health", () => Results.Ok(new
{
    status = "ok",
    checkedAt = DateTimeOffset.UtcNow
}));

var defaultConnStr = builder.Configuration.GetConnectionString("DefaultConnection")
    ?? "Server=.;Database=RepairShopDB;Integrated Security=True;TrustServerCertificate=True;Connect Timeout=5";

app.MapGet("/api/db/status", () =>
{
    try
    {
        using var conn = new Microsoft.Data.SqlClient.SqlConnection(defaultConnStr);
        conn.Open();
        using var cmd = conn.CreateCommand();
        cmd.CommandText = @"
            SELECT
                @@VERSION AS Version,
                (SELECT COUNT(*) FROM sys.tables) AS TableCount,
                (SELECT COUNT(*) FROM dbo.Users) AS UserCount,
                (SELECT COUNT(*) FROM dbo.RepairTickets) AS TicketCount,
                (SELECT COUNT(*) FROM dbo.SpareParts) AS SparePartCount";
        using var reader = cmd.ExecuteReader();
        if (reader.Read())
        {
            return Results.Ok(new
            {
                status = "CONNECTED",
                database = "RepairShopDB",
                server = "Localhost SQL Server (MSSQLSERVER)",
                tables = reader.GetInt32(1),
                usersInDb = reader.GetInt32(2),
                ticketsInDb = reader.GetInt32(3),
                sparePartsInDb = reader.GetInt32(4),
                sqlVersion = reader.GetString(0).Split('\n')[0].Trim(),
                checkedAt = DateTimeOffset.UtcNow
            });
        }
    }
    catch (Exception ex)
    {
        return Results.Ok(new
        {
            status = "FALLBACK_IN_MEMORY",
            database = "RepairShopDB",
            note = "Dang dung bo nho trong AppData",
            error = ex.Message
        });
    }
    return Results.Ok(new { status = "UNKNOWN" });
});

app.MapAuthEndpoints(data);
app.MapCatalogEndpoints(data);
app.MapTicketEndpoints(data);
app.MapDashboardEndpoints(data);
app.MapInventoryEndpoints(data);

app.Run();

