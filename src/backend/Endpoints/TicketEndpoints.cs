using QLDACNTT.Api.Contracts;
using QLDACNTT.Api.Data;
using QLDACNTT.Api.Infrastructure;
using QLDACNTT.Api.Models;

namespace QLDACNTT.Api.Endpoints;

public static class TicketEndpoints
{
    public static void MapTicketEndpoints(this WebApplication app, AppData data)
    {
        app.MapGet("/api/tickets", (HttpRequest request, string? status) =>
        {
            var auth = AuthHelper.RequireRole(request, data, "ADMIN", "STAFF", "TECHNICIAN");
            if (auth is not null)
            {
                return auth;
            }

            var query = data.Tickets.AsEnumerable();
            if (!string.IsNullOrWhiteSpace(status))
            {
                query = query.Where(x => x.Status.Equals(status, StringComparison.OrdinalIgnoreCase));
            }

            return Results.Ok(query.Select(AuthHelper.EnrichTicket));
        });

        app.MapGet("/api/tickets/{code}", (HttpRequest request, string code) =>
        {
            var auth = AuthHelper.RequireRole(request, data, "ADMIN", "STAFF", "TECHNICIAN");
            if (auth is not null)
            {
                return auth;
            }

            var ticket = FindTicket(data, code);
            return ticket is null
                ? Results.NotFound(new { message = "Khong tim thay phieu sua chua" })
                : Results.Ok(AuthHelper.EnrichTicket(ticket));
        });

        app.MapPost("/api/tickets", (HttpRequest request, CreateTicketRequest input) =>
        {
            var session = AuthHelper.GetSession(request, data);
            var auth = AuthHelper.RequireSessionRole(session, "ADMIN", "STAFF");
            if (auth is not null)
            {
                return auth;
            }

            if (data.Customers.All(x => !x.Code.Equals(input.CustomerCode, StringComparison.OrdinalIgnoreCase)))
            {
                return Results.BadRequest(new { message = "Khach hang khong hop le" });
            }

            if (data.Devices.All(x => !x.Code.Equals(input.DeviceCode, StringComparison.OrdinalIgnoreCase)))
            {
                return Results.BadRequest(new { message = "Thiet bi khong hop le" });
            }

            var service = data.ServiceTypes.FirstOrDefault(x => x.Code.Equals(input.ServiceCode, StringComparison.OrdinalIgnoreCase));
            if (service is null)
            {
                return Results.BadRequest(new { message = "Dich vu khong hop le" });
            }

            var ticket = new RepairTicketDto(
                $"PSC202609{data.Tickets.Count + 1:0000}",
                input.CustomerCode.ToUpperInvariant(),
                input.DeviceCode.ToUpperInvariant(),
                service.Code,
                "RECEIVED",
                session!.Username,
                null,
                input.DeviceCondition.Trim(),
                null,
                service.LaborCost);

            data.Tickets.Add(ticket);
            return Results.Created($"/api/tickets/{ticket.Code}", AuthHelper.EnrichTicket(ticket));
        });

        app.MapPatch("/api/tickets/{code}/assign", (HttpRequest request, string code, AssignTechnicianRequest input) =>
        {
            var auth = AuthHelper.RequireRole(request, data, "ADMIN", "STAFF");
            if (auth is not null)
            {
                return auth;
            }

            var ticket = FindTicket(data, code);
            if (ticket is null)
            {
                return Results.NotFound(new { message = "Khong tim thay phieu sua chua" });
            }

            var technician = data.Users.FirstOrDefault(x =>
                x.Username.Equals(input.TechnicianUsername, StringComparison.OrdinalIgnoreCase)
                && x.Role == "TECHNICIAN"
                && x.IsActive);

            if (technician is null)
            {
                return Results.BadRequest(new { message = "Ky thuat vien khong hop le" });
            }

            ReplaceTicket(data, ticket, ticket with { TechnicianUsername = technician.Username, Status = "DIAGNOSING" });
            return Results.Ok(AuthHelper.EnrichTicket(FindTicket(data, code)!));
        });

        app.MapPatch("/api/tickets/{code}/diagnosis", (HttpRequest request, string code, UpdateDiagnosisRequest input) =>
        {
            var auth = AuthHelper.RequireRole(request, data, "ADMIN", "TECHNICIAN");
            if (auth is not null)
            {
                return auth;
            }

            var ticket = FindTicket(data, code);
            if (ticket is null)
            {
                return Results.NotFound(new { message = "Khong tim thay phieu sua chua" });
            }

            ReplaceTicket(data, ticket, ticket with
            {
                Diagnosis = input.Diagnosis.Trim(),
                QuotedLaborCost = input.QuotedLaborCost,
                Status = "WAITING_CONFIRM"
            });

            return Results.Ok(AuthHelper.EnrichTicket(FindTicket(data, code)!));
        });

        app.MapPatch("/api/tickets/{code}/status", (HttpRequest request, string code, UpdateTicketStatusRequest input) =>
        {
            var auth = AuthHelper.RequireRole(request, data, "ADMIN", "STAFF", "TECHNICIAN");
            if (auth is not null)
            {
                return auth;
            }

            if (!AuthHelper.IsValidTicketStatus(input.Status))
            {
                return Results.BadRequest(new { message = "Trang thai phieu khong hop le" });
            }

            var ticket = FindTicket(data, code);
            if (ticket is null)
            {
                return Results.NotFound(new { message = "Khong tim thay phieu sua chua" });
            }

            ReplaceTicket(data, ticket, ticket with { Status = input.Status.ToUpperInvariant() });
            return Results.Ok(AuthHelper.EnrichTicket(FindTicket(data, code)!));
        });
    }

    private static RepairTicketDto? FindTicket(AppData data, string code)
    {
        return data.Tickets.FirstOrDefault(x => x.Code.Equals(code, StringComparison.OrdinalIgnoreCase));
    }

    private static void ReplaceTicket(AppData data, RepairTicketDto current, RepairTicketDto next)
    {
        data.Tickets[data.Tickets.IndexOf(current)] = next;
    }
}
