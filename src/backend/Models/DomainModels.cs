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

public record StockTransactionDto(
    int TransactionId,
    string PartCode,
    string TransactionType,
    int Quantity,
    int StockBefore,
    int StockAfter,
    string? TicketCode,
    string PerformedByUsername,
    DateTimeOffset TransactionAt,
    string? Note);

public record TicketStatusLogDto(
    int LogId,
    string TicketCode,
    string OldStatus,
    string NewStatus,
    string ChangedByUsername,
    DateTimeOffset ChangedAt,
    string? Note);

public record InvoiceDto(
    string InvoiceCode,
    string TicketCode,
    string CustomerCode,
    decimal LaborCost,
    decimal PartsCost,
    decimal TotalAmount,
    string PaymentStatus, // UNPAID, PAID
    DateTimeOffset CreatedAt);

public record PaymentDto(
    int PaymentId,
    string InvoiceCode,
    string TicketCode,
    decimal Amount,
    string PaymentMethod, // CASH, TRANSFER, MOMO, VNPAY
    string ReceivedByUsername,
    DateTimeOffset PaidAt,
    string? Note);

public record WarrantyCardDto(
    string WarrantyCode,
    string TicketCode,
    string DeviceCode,
    string CustomerCode,
    string SerialNumber,
    DateTimeOffset StartDate,
    DateTimeOffset EndDate,
    int WarrantyDays,
    string Status); // ACTIVE, EXPIRED, VOID

