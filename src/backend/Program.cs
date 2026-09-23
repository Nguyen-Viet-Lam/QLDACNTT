using System.Collections.Concurrent;

var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

var users = new List<UserAccount>
{
    new("admin", "123456", "Nguyen Viet Lam", "ADMIN"),
    new("staff", "123456", "Nhan vien tiep nhan", "STAFF"),
    new("tech", "123456", "Ky thuat vien", "TECHNICIAN"),
    new("customer", "123456", "Khach hang demo", "CUSTOMER")
};

var sessions = new ConcurrentDictionary<string, UserSession>();

var customers = new List<CustomerDto>
{
    new("KH000001", "Nguyen Van An", "0901000001"),
    new("KH000002", "Tran Thi Binh", "0901000002")
};

var tickets = new List<RepairTicketDto>
{
    new("PSC2026090001", "KH000001", "Laptop Dell Inspiron", "RECEIVED"),
    new("PSC2026090002", "KH000002", "iPhone 12", "DIAGNOSING")
};

app.MapGet("/", () => Results.Ok(new
{
    name = "QLDACNTT Backend Prototype",
    scope = "Demo API dang nhap, dang xuat va phan quyen toi gian",
    endpoints = new[]
    {
        "POST /api/auth/login",
        "POST /api/auth/logout",
        "GET /api/auth/me",
        "GET /api/customers",
        "GET /api/tickets"
    }
}));

app.MapGet("/health", () => Results.Ok(new
{
    status = "ok",
    checkedAt = DateTimeOffset.UtcNow
}));

app.MapPost("/api/auth/login", (LoginRequest request) =>
{
    var user = users.FirstOrDefault(x =>
        x.Username.Equals(request.Username, StringComparison.OrdinalIgnoreCase)
        && x.Password == request.Password);

    if (user is null)
    {
        return Results.Unauthorized();
    }

    var token = Guid.NewGuid().ToString("N");
    var session = new UserSession(token, user.Username, user.FullName, user.Role, DateTimeOffset.UtcNow.AddHours(2));
    sessions[token] = session;

    return Results.Ok(new
    {
        token,
        expiresAt = session.ExpiresAt,
        user = new
        {
            user.Username,
            user.FullName,
            user.Role
        }
    });
});

app.MapPost("/api/auth/logout", (HttpRequest request) =>
{
    var session = GetSession(request, sessions);
    if (session is null)
    {
        return Results.Unauthorized();
    }

    sessions.TryRemove(session.Token, out _);
    return Results.Ok(new { message = "Da dang xuat" });
});

app.MapGet("/api/auth/me", (HttpRequest request) =>
{
    var session = GetSession(request, sessions);
    if (session is null)
    {
        return Results.Unauthorized();
    }

    return Results.Ok(new
    {
        session.Username,
        session.FullName,
        session.Role,
        session.ExpiresAt
    });
});

app.MapGet("/api/users", (HttpRequest request) =>
{
    var auth = RequireRole(request, sessions, "ADMIN");
    if (auth is not null)
    {
        return auth;
    }

    var result = users.Select(x => new { x.Username, x.FullName, x.Role });
    return Results.Ok(result);
});

app.MapGet("/api/customers", (HttpRequest request) =>
{
    var auth = RequireRole(request, sessions, "ADMIN", "STAFF");
    return auth ?? Results.Ok(customers);
});

app.MapGet("/api/tickets", (HttpRequest request) =>
{
    var auth = RequireRole(request, sessions, "ADMIN", "STAFF", "TECHNICIAN");
    return auth ?? Results.Ok(tickets);
});

app.MapGet("/api/tickets/{code}", (HttpRequest request, string code) =>
{
    var auth = RequireRole(request, sessions, "ADMIN", "STAFF", "TECHNICIAN");
    if (auth is not null)
    {
        return auth;
    }

    var ticket = tickets.FirstOrDefault(x => x.Code.Equals(code, StringComparison.OrdinalIgnoreCase));
    return ticket is null
        ? Results.NotFound(new { message = "Khong tim thay phieu sua chua" })
        : Results.Ok(ticket);
});

app.Run();

static UserSession? GetSession(HttpRequest request, ConcurrentDictionary<string, UserSession> sessions)
{
    var token = request.Headers["X-Session-Token"].FirstOrDefault();
    if (string.IsNullOrWhiteSpace(token))
    {
        return null;
    }

    if (!sessions.TryGetValue(token, out var session))
    {
        return null;
    }

    if (session.ExpiresAt < DateTimeOffset.UtcNow)
    {
        sessions.TryRemove(token, out _);
        return null;
    }

    return session;
}

static IResult? RequireRole(
    HttpRequest request,
    ConcurrentDictionary<string, UserSession> sessions,
    params string[] allowedRoles)
{
    var session = GetSession(request, sessions);
    if (session is null)
    {
        return Results.Unauthorized();
    }

    return allowedRoles.Contains(session.Role)
        ? null
        : Results.StatusCode(StatusCodes.Status403Forbidden);
}

record LoginRequest(string Username, string Password);

record UserAccount(string Username, string Password, string FullName, string Role);

record UserSession(string Token, string Username, string FullName, string Role, DateTimeOffset ExpiresAt);

record CustomerDto(string Code, string FullName, string Phone);

record RepairTicketDto(string Code, string CustomerCode, string DeviceName, string Status);

