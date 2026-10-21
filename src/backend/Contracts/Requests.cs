namespace QLDACNTT.Api.Contracts;

public record LoginRequest(string Username, string Password);

public record RegisterRequest(string Username, string Password, string FullName, string? Email, string? Phone, string? Role);

public record CreateUserRequest(string Username, string Password, string FullName, string Role);

public record UpdateUserStatusRequest(bool IsActive);

public record CreateCustomerRequest(string FullName, string Phone, string? Email, string? Address);

public record CreateDeviceRequest(string DeviceType, string? Brand, string? Model, string? SerialNumber);

public record UpdateCustomerRequest(string FullName, string Phone, string? Email, string? Address);

public record UpdateDeviceRequest(string DeviceType, string? Brand, string? Model, string? SerialNumber);

public record UpsertServiceTypeRequest(string ServiceName, decimal LaborCost, int WarrantyDays, string? Description);

public record UpsertSparePartRequest(
    string PartName,
    int? CategoryId,
    string? Unit,
    decimal PurchasePrice,
    decimal SellingPrice,
    int MinStockLevel,
    int WarrantyDays);

public record ResetPasswordRequest(string NewPassword);

public record CreateTicketRequest(string CustomerCode, string DeviceCode, string ServiceCode, string DeviceCondition);

public record AssignTechnicianRequest(string TechnicianUsername);

public record UpdateDiagnosisRequest(string Diagnosis, decimal QuotedLaborCost);

public record UpdateTicketStatusRequest(string Status);

public record CreateStockTransactionRequest(
    string PartCode,
    string TransactionType,
    int Quantity,
    string? TicketCode,
    string? Note);

public record UpdateTicketStatusWithNoteRequest(
    string Status,
    string? Note);

public record CreateInvoiceRequest(
    string TicketCode,
    decimal? DiscountAmount);

public record ProcessPaymentRequest(
    string PaymentMethod, // CASH, TRANSFER, MOMO, VNPAY
    decimal Amount,
    string? Note);

public record PublicAppointmentRequest(
    string FullName,
    string Phone,
    string? Email,
    string? Address,
    string? DeviceType,
    string? Brand,
    string? Model,
    string? SerialNumber,
    string? FaultDescription,
    string? PreferredTime);

