using QLDACNTT.Api.Data;
using QLDACNTT.Api.Models;

namespace QLDACNTT.Api.Infrastructure;

public static class AuthHelper
{
    public static readonly string[] Roles = ["ADMIN", "STAFF", "TECHNICIAN", "CUSTOMER"];

    public static readonly string[] TicketStatuses =
    [
        "RECEIVED",
        "DIAGNOSING",
        "WAITING_CONFIRM",
        "REPAIRING",
        "COMPLETED",
        "DELIVERED",
        "CANCELLED",
        "PAID"
    ];

    public static UserSession? GetSession(HttpRequest request, SessionStore store)
    {
        var token = request.Headers["X-Session-Token"].FirstOrDefault();
        if (string.IsNullOrWhiteSpace(token))
        {
            return null;
        }

        if (!store.Sessions.TryGetValue(token, out var session))
        {
            return null;
        }

        if (session.ExpiresAt < DateTimeOffset.UtcNow)
        {
            store.Sessions.TryRemove(token, out _);
            return null;
        }

        return session;
    }

    public static IResult? RequireRole(HttpRequest request, SessionStore store, params string[] allowedRoles)
    {
        return RequireSessionRole(GetSession(request, store), allowedRoles);
    }

    public static IResult? RequireSessionRole(UserSession? session, params string[] allowedRoles)
    {
        if (session is null)
        {
            return Results.Unauthorized();
        }

        return allowedRoles.Contains(session.Role)
            ? null
            : Results.StatusCode(StatusCodes.Status403Forbidden);
    }

    public static bool IsValidRole(string role)
    {
        return Roles.Contains(role.ToUpperInvariant());
    }

    public static bool IsValidTicketStatus(string status)
    {
        return TicketStatuses.Contains(status.ToUpperInvariant());
    }

    public static object ToUserResponse(User user)
    {
        return new
        {
            user.UserId,
            user.Username,
            user.FullName,
            Role = user.Role?.RoleCode ?? "",
            user.IsActive
        };
    }

    public static object EnrichTicket(RepairTicket ticket)
    {
        return new
        {
            Code = ticket.TicketCode,
            CustomerCode = ticket.Customer?.CustomerCode,
            DeviceCode = ticket.Device?.DeviceCode,
            ServiceCode = ticket.ServiceType?.ServiceCode,
            ticket.Status,
            ReceivedByUsername = ticket.ReceivedByUser?.Username,
            TechnicianUsername = ticket.TechnicianUser?.Username,
            ticket.DeviceCondition,
            ticket.Diagnosis,
            ticket.QuotedLaborCost
        };
    }
}
