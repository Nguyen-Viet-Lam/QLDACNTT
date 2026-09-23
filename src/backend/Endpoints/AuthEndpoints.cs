using QLDACNTT.Api.Contracts;
using QLDACNTT.Api.Data;
using QLDACNTT.Api.Infrastructure;
using QLDACNTT.Api.Models;

namespace QLDACNTT.Api.Endpoints;

public static class AuthEndpoints
{
    public static void MapAuthEndpoints(this WebApplication app, AppData data)
    {
        app.MapPost("/api/auth/login", (LoginRequest request) =>
        {
            var user = data.Users.FirstOrDefault(x =>
                x.Username.Equals(request.Username, StringComparison.OrdinalIgnoreCase)
                && x.Password == request.Password);

            if (user is null || !user.IsActive)
            {
                return Results.Unauthorized();
            }

            var token = Guid.NewGuid().ToString("N");
            var session = new UserSession(token, user.UserId, user.Username, user.FullName, user.Role, DateTimeOffset.UtcNow.AddHours(2));
            data.Sessions[token] = session;

            return Results.Ok(new
            {
                token,
                expiresAt = session.ExpiresAt,
                user = AuthHelper.ToUserResponse(user)
            });
        });

        app.MapPost("/api/auth/logout", (HttpRequest request) =>
        {
            var session = AuthHelper.GetSession(request, data);
            if (session is null)
            {
                return Results.Unauthorized();
            }

            data.Sessions.TryRemove(session.Token, out _);
            return Results.Ok(new { message = "Da dang xuat" });
        });

        app.MapGet("/api/auth/me", (HttpRequest request) =>
        {
            var session = AuthHelper.GetSession(request, data);
            return session is null
                ? Results.Unauthorized()
                : Results.Ok(new { session.UserId, session.Username, session.FullName, session.Role, session.ExpiresAt });
        });

        app.MapGet("/api/roles", (HttpRequest request) =>
        {
            var auth = AuthHelper.RequireRole(request, data, "ADMIN");
            return auth ?? Results.Ok(AuthHelper.Roles);
        });

        app.MapGet("/api/users", (HttpRequest request) =>
        {
            var auth = AuthHelper.RequireRole(request, data, "ADMIN");
            return auth ?? Results.Ok(data.Users.Select(AuthHelper.ToUserResponse));
        });

        app.MapPost("/api/users", (HttpRequest request, CreateUserRequest input) =>
        {
            var auth = AuthHelper.RequireRole(request, data, "ADMIN");
            if (auth is not null)
            {
                return auth;
            }

            if (data.Users.Any(x => x.Username.Equals(input.Username, StringComparison.OrdinalIgnoreCase)))
            {
                return Results.Conflict(new { message = "Ten dang nhap da ton tai" });
            }

            if (!AuthHelper.IsValidRole(input.Role))
            {
                return Results.BadRequest(new { message = "Vai tro khong hop le" });
            }

            var user = new UserAccount(
                data.Users.Max(x => x.UserId) + 1,
                input.Username.Trim(),
                input.Password,
                input.FullName.Trim(),
                input.Role.ToUpperInvariant(),
                true);

            data.Users.Add(user);
            return Results.Created($"/api/users/{user.Username}", AuthHelper.ToUserResponse(user));
        });

        app.MapPatch("/api/users/{username}/status", (HttpRequest request, string username, UpdateUserStatusRequest input) =>
        {
            var auth = AuthHelper.RequireRole(request, data, "ADMIN");
            if (auth is not null)
            {
                return auth;
            }

            var user = data.Users.FirstOrDefault(x => x.Username.Equals(username, StringComparison.OrdinalIgnoreCase));
            if (user is null)
            {
                return Results.NotFound(new { message = "Khong tim thay tai khoan" });
            }

            var index = data.Users.IndexOf(user);
            data.Users[index] = user with { IsActive = input.IsActive };
            return Results.Ok(AuthHelper.ToUserResponse(data.Users[index]));
        });
    }
}
