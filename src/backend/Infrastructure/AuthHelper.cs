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
        "CANCELLED"
    ];

    public static UserSession? GetSession(HttpRequest request, AppData data)
    {
        var token = request.Headers["X-Session-Token"].FirstOrDefault();
        if (string.IsNullOrWhiteSpace(token))
        {
            return null;
        }

        if (!data.Sessions.TryGetValue(token, out var session))
        {
            return null;
        }

        if (session.ExpiresAt < DateTimeOffset.UtcNow)
        {
            data.Sessions.TryRemove(token, out _);
            return null;
        }

        return session;
    }

    public static IResult? RequireRole(HttpRequest request, AppData data, params string[] allowedRoles)
    {
        return RequireSessionRole(GetSession(request, data), allowedRoles);
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

    public static object ToUserResponse(UserAccount user)
    {
        return new
        {
            user.UserId,
            user.Username,
            user.FullName,
            user.Role,
            user.IsActive
        };
    }

    public static object EnrichTicket(RepairTicketDto ticket)
    {
        return new
        {
            ticket.Code,
            ticket.CustomerCode,
            ticket.DeviceCode,
            ticket.ServiceCode,
            ticket.Status,
            ticket.ReceivedByUsername,
            ticket.TechnicianUsername,
            ticket.DeviceCondition,
            ticket.Diagnosis,
            ticket.QuotedLaborCost
        };
    }
}
