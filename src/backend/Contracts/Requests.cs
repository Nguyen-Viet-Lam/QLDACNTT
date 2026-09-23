namespace QLDACNTT.Api.Contracts;

public record LoginRequest(string Username, string Password);

public record CreateUserRequest(string Username, string Password, string FullName, string Role);

public record UpdateUserStatusRequest(bool IsActive);

public record CreateCustomerRequest(string FullName, string Phone, string? Email, string? Address);

public record CreateDeviceRequest(string DeviceType, string? Brand, string? Model, string? SerialNumber);

public record CreateTicketRequest(string CustomerCode, string DeviceCode, string ServiceCode, string DeviceCondition);

public record AssignTechnicianRequest(string TechnicianUsername);

public record UpdateDiagnosisRequest(string Diagnosis, decimal QuotedLaborCost);

public record UpdateTicketStatusRequest(string Status);
