namespace QLDACNTT.Api.Models;

public class Role
{
    public int RoleId { get; set; }
    public string RoleCode { get; set; } = "";
    public string RoleName { get; set; } = "";
    public string? Description { get; set; }
    public bool IsActive { get; set; } = true;
    public DateTime CreatedAt { get; set; } = DateTime.Now;

    public List<User> Users { get; set; } = [];
}

public class User
{
    public int UserId { get; set; }
    public int RoleId { get; set; }
    public string Username { get; set; } = "";
    public string PasswordHash { get; set; } = "";
    public string FullName { get; set; } = "";
    public string? Email { get; set; }
    public string? Phone { get; set; }
    public bool IsActive { get; set; } = true;
    public DateTime? LastLoginAt { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.Now;
    public DateTime? UpdatedAt { get; set; }

    public Role Role { get; set; } = null!;
    public int? CustomerId { get; set; }
    public Customer? Customer { get; set; }
}

public class Customer
{
    public int CustomerId { get; set; }
    public string CustomerCode { get; set; } = "";
    public string FullName { get; set; } = "";
    public string Phone { get; set; } = "";
    public string? Email { get; set; }
    public string? Address { get; set; }
    public string? Note { get; set; }
    public bool IsActive { get; set; } = true;
    public DateTime CreatedAt { get; set; } = DateTime.Now;
    public DateTime? UpdatedAt { get; set; }

    public List<Device> Devices { get; set; } = [];
}

public class Device
{
    public int DeviceId { get; set; }
    public string DeviceCode { get; set; } = "";
    public int CustomerId { get; set; }
    public string DeviceType { get; set; } = "";
    public string? Brand { get; set; }
    public string? Model { get; set; }
    public string? SerialNumber { get; set; }
    public string? Note { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.Now;

    public Customer Customer { get; set; } = null!;
}

public class ServiceType
{
    public int ServiceTypeId { get; set; }
    public string ServiceCode { get; set; } = "";
    public string ServiceName { get; set; } = "";
    public decimal LaborCost { get; set; }
    public int WarrantyDays { get; set; }
    public string? Description { get; set; }
    public bool IsActive { get; set; } = true;
}

public class RepairTicket
{
    public int TicketId { get; set; }
    public string TicketCode { get; set; } = "";
    public int CustomerId { get; set; }
    public int DeviceId { get; set; }
    public int? ServiceTypeId { get; set; }
    public int ReceivedByUserId { get; set; }
    public int? TechnicianUserId { get; set; }
    public string Status { get; set; } = "RECEIVED";
    public string? DeviceCondition { get; set; }
    public string? CustomerRequest { get; set; }
    public string? Diagnosis { get; set; }
    public decimal QuotedLaborCost { get; set; }
    public decimal QuotedPartsCost { get; set; }
    public bool IsWarrantyRepair { get; set; }
    public int? OriginalTicketId { get; set; }
    public DateTime ReceivedAt { get; set; } = DateTime.Now;
    public DateTime? ExpectedFinishAt { get; set; }
    public DateTime? CompletedAt { get; set; }
    public DateTime? DeliveredAt { get; set; }
    public string? CancelReason { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.Now;
    public DateTime? UpdatedAt { get; set; }

    public Customer Customer { get; set; } = null!;
    public Device Device { get; set; } = null!;
    public ServiceType? ServiceType { get; set; }
    public User ReceivedByUser { get; set; } = null!;
    public User? TechnicianUser { get; set; }
}

public class TicketStatusHistory
{
    public int HistoryId { get; set; }
    public int TicketId { get; set; }
    public string? FromStatus { get; set; }
    public string ToStatus { get; set; } = "";
    public int ChangedByUserId { get; set; }
    public string? Note { get; set; }
    public DateTime ChangedAt { get; set; } = DateTime.Now;

    public RepairTicket Ticket { get; set; } = null!;
    public User ChangedByUser { get; set; } = null!;
}

public class SparePartCategory
{
    public int CategoryId { get; set; }
    public string CategoryName { get; set; } = "";
    public string? Description { get; set; }
    public bool IsActive { get; set; } = true;

    public List<SparePart> SpareParts { get; set; } = [];
}

public class SparePart
{
    public int PartId { get; set; }
    public string PartCode { get; set; } = "";
    public int CategoryId { get; set; }
    public string PartName { get; set; } = "";
    public string Unit { get; set; } = "Cái";
    public decimal PurchasePrice { get; set; }
    public decimal SellingPrice { get; set; }
    public int StockQuantity { get; set; }
    public int MinStockLevel { get; set; }
    public int WarrantyDays { get; set; }
    public bool IsActive { get; set; } = true;
    public DateTime CreatedAt { get; set; } = DateTime.Now;
    public DateTime? UpdatedAt { get; set; }

    public SparePartCategory Category { get; set; } = null!;
}

public class StockTransaction
{
    public int TransactionId { get; set; }
    public int PartId { get; set; }
    public string TransactionType { get; set; } = "";
    public int Quantity { get; set; }
    public decimal UnitPrice { get; set; }
    public int StockBefore { get; set; }
    public int StockAfter { get; set; }
    public int? TicketId { get; set; }
    public int PerformedByUserId { get; set; }
    public string? Note { get; set; }
    public DateTime TransactionAt { get; set; } = DateTime.Now;

    public SparePart Part { get; set; } = null!;
    public RepairTicket? Ticket { get; set; }
    public User PerformedByUser { get; set; } = null!;
}

public class Invoice
{
    public int InvoiceId { get; set; }
    public string InvoiceCode { get; set; } = "";
    public int TicketId { get; set; }
    public int CustomerId { get; set; }
    public decimal LaborCost { get; set; }
    public decimal PartsCost { get; set; }
    public decimal DiscountAmount { get; set; }
    public decimal TotalAmount { get; private set; }
    public string PaymentMethod { get; set; } = "CASH";
    public string PaymentStatus { get; set; } = "UNPAID";
    public DateTime? PaidAt { get; set; }
    public int CreatedByUserId { get; set; }
    public string? Note { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.Now;

    public RepairTicket Ticket { get; set; } = null!;
    public Customer Customer { get; set; } = null!;
}

public class Payment
{
    public int PaymentId { get; set; }
    public int InvoiceId { get; set; }
    public decimal Amount { get; set; }
    public string PaymentMethod { get; set; } = "";
    public int ReceivedByUserId { get; set; }
    public DateTime PaidAt { get; set; } = DateTime.Now;
    public string? Note { get; set; }

    public Invoice Invoice { get; set; } = null!;
    public User ReceivedByUser { get; set; } = null!;
}

public class Warranty
{
    public int WarrantyId { get; set; }
    public string WarrantyCode { get; set; } = "";
    public int TicketId { get; set; }
    public int CustomerId { get; set; }
    public int DeviceId { get; set; }
    public DateTime StartDate { get; set; }
    public DateTime EndDate { get; set; }
    public int WarrantyDays { get; set; }
    public string? Scope { get; set; }
    public string Status { get; set; } = "ACTIVE";
    public string? VoidReason { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.Now;

    public RepairTicket Ticket { get; set; } = null!;
    public Customer Customer { get; set; } = null!;
    public Device Device { get; set; } = null!;
}
