using System.Collections.Concurrent;
using QLDACNTT.Api.Models;

namespace QLDACNTT.Api.Data;

public sealed class UserSession
{
    public required string Token { get; init; }
    public required int UserId { get; init; }
    public required string Username { get; init; }
    public required string FullName { get; init; }
    public required string Role { get; init; }
    public int? CustomerId { get; init; }
    public required DateTimeOffset ExpiresAt { get; init; }
}

public sealed class SessionStore
{
    public ConcurrentDictionary<string, UserSession> Sessions { get; } = new();
}
