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
        "admin / 123456",
        "staff / 123456",
        "tech / 123456",
        "customer / 123456"
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

app.MapAuthEndpoints(data);
app.MapCatalogEndpoints(data);
app.MapTicketEndpoints(data);
app.MapDashboardEndpoints(data);
app.MapInventoryEndpoints(data);

app.Run();

