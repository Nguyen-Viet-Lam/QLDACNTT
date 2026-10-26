using Microsoft.AspNetCore.Http;
using QLDACNTT.Api.Data;
using QLDACNTT.Api.Infrastructure;
using QLDACNTT.Api.Models;
using Xunit;

namespace QLDACNTT.Tests;

public class AuthAndRbacTests
{
    [Theory]
    [InlineData("ADMIN", true)]
    [InlineData("STAFF", true)]
    [InlineData("TECHNICIAN", true)]
    [InlineData("CUSTOMER", true)]
    [InlineData("SUPERADMIN", false)]
    [InlineData("GUEST", false)]
    [InlineData("", false)]
    public void IsValidRole_ShouldValidateSystemRolesCorrectly(string role, bool expected)
    {
        var result = AuthHelper.IsValidRole(role);
        Assert.Equal(expected, result);
    }

    [Theory]
    [InlineData("RECEIVED", true)]
    [InlineData("DIAGNOSING", true)]
    [InlineData("WAITING_CONFIRM", true)]
    [InlineData("REPAIRING", true)]
    [InlineData("COMPLETED", true)]
    [InlineData("DELIVERED", true)]
    [InlineData("CANCELLED", true)]
    [InlineData("UNKNOWN_STATUS", false)]
    [InlineData("PENDING", false)]
    public void IsValidTicketStatus_ShouldValidateTicketStatuses(string status, bool expected)
    {
        var result = AuthHelper.IsValidTicketStatus(status);
        Assert.Equal(expected, result);
    }

    [Fact]
    public void RequireSessionRole_WhenSessionIsNull_ReturnsUnauthorized()
    {
        var result = AuthHelper.RequireSessionRole(null, "ADMIN");
        Assert.NotNull(result);
        Assert.IsAssignableFrom<IResult>(result);
    }

    [Fact]
    public void RequireSessionRole_WhenRoleMatches_ReturnsNull()
    {
        var session = new UserSession(
            Token: "token-123",
            UserId: 1,
            Username: "admin",
            FullName: "Nguyen Viet Lam",
            Role: "ADMIN",
            ExpiresAt: DateTimeOffset.UtcNow.AddHours(2)
        );

        var result = AuthHelper.RequireSessionRole(session, "ADMIN", "STAFF");
        Assert.Null(result);
    }

    [Fact]
    public void RequireSessionRole_WhenRoleDoesNotMatch_ReturnsForbidden()
    {
        var session = new UserSession(
            Token: "token-456",
            UserId: 4,
            Username: "customer",
            FullName: "Khach hang demo",
            Role: "CUSTOMER",
            ExpiresAt: DateTimeOffset.UtcNow.AddHours(2)
        );

        var result = AuthHelper.RequireSessionRole(session, "ADMIN", "STAFF");
        Assert.NotNull(result);
    }
}
