using QLDACNTT.Api.Data;
using QLDACNTT.Api.Endpoints;

var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();
var data = AppData.CreateDemo();

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
        "/api/dashboard/summary"
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

app.Run();
