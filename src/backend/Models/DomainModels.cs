namespace QLDACNTT.Api.Models;

public record UserAccount(int UserId, string Username, string Password, string FullName, string Role, bool IsActive);

public record UserSession(string Token, int UserId, string Username, string FullName, string Role, DateTimeOffset ExpiresAt);

public record CustomerDto(string Code, string FullName, string Phone, string? Email, string? Address);

public record DeviceDto(string Code, string CustomerCode, string DeviceType, string? Brand, string? Model, string? SerialNumber);

public record ServiceTypeDto(string Code, string Name, decimal LaborCost, int WarrantyDays);

public record SparePartDto(string Code, string Name, int StockQuantity, int MinStockLevel, decimal SellingPrice);

public record RepairTicketDto(
    string Code,
    string CustomerCode,
    string DeviceCode,
    string ServiceCode,
    string Status,
    string ReceivedByUsername,
    string? TechnicianUsername,
    string DeviceCondition,
    string? Diagnosis,
    decimal QuotedLaborCost);
