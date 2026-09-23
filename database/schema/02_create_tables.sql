/* =====================================================================
   LV33-001 — Hệ thống quản lý tổng thể cho cửa hàng sửa chữa
   Script 02: Tạo bảng
   Người viết: Trần Ngọc Lợi (Database)

   13 bảng: Roles, Users, Customers, Devices, ServiceTypes, RepairTickets,
            TicketStatusHistory, SparePartCategories, SpareParts,
            StockTransactions, TicketParts, Invoices, Warranties
   ===================================================================== */

USE RepairShopDB;
GO

/* Bắt buộc bật 2 tùy chọn này: các bảng bên dưới có cột tính toán PERSISTED
   (QuotedTotal, LineTotal, TotalAmount). SSMS bật sẵn nhưng sqlcmd mặc định
   để QUOTED_IDENTIFIER OFF nên sẽ lỗi 1934 nếu không set tường minh. */
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

/* ---------- 1. Vai trò (RBAC) ---------- */
IF OBJECT_ID('dbo.Roles') IS NULL
CREATE TABLE dbo.Roles (
    RoleId          INT IDENTITY(1,1) PRIMARY KEY,
    RoleCode        VARCHAR(20)   NOT NULL UNIQUE,   -- ADMIN, STAFF, TECHNICIAN, CUSTOMER
    RoleName        NVARCHAR(50)  NOT NULL,
    Description     NVARCHAR(200) NULL,
    IsActive        BIT           NOT NULL DEFAULT 1,
    CreatedAt       DATETIME2     NOT NULL DEFAULT SYSDATETIME()
);
GO

/* ---------- 2. Người dùng hệ thống ---------- */
IF OBJECT_ID('dbo.Users') IS NULL
CREATE TABLE dbo.Users (
    UserId          INT IDENTITY(1,1) PRIMARY KEY,
    RoleId          INT           NOT NULL,
    Username        VARCHAR(50)   NOT NULL UNIQUE,
    PasswordHash    VARCHAR(255)  NOT NULL,
    FullName        NVARCHAR(100) NOT NULL,
    Email           VARCHAR(100)  NULL,
    Phone           VARCHAR(20)   NULL,
    IsActive        BIT           NOT NULL DEFAULT 1,
    LastLoginAt     DATETIME2     NULL,
    CreatedAt       DATETIME2     NOT NULL DEFAULT SYSDATETIME(),
    UpdatedAt       DATETIME2     NULL,
    CONSTRAINT FK_Users_Roles FOREIGN KEY (RoleId) REFERENCES dbo.Roles(RoleId)
);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Users_RoleId' AND object_id=OBJECT_ID('dbo.Users'))
    CREATE INDEX IX_Users_RoleId ON dbo.Users(RoleId);
GO

/* ---------- 3. Khách hàng ---------- */
IF OBJECT_ID('dbo.Customers') IS NULL
CREATE TABLE dbo.Customers (
    CustomerId      INT IDENTITY(1,1) PRIMARY KEY,
    CustomerCode    VARCHAR(20)   NOT NULL UNIQUE,   -- KH000001
    FullName        NVARCHAR(100) NOT NULL,
    Phone           VARCHAR(20)   NOT NULL,
    Email           VARCHAR(100)  NULL,
    Address         NVARCHAR(255) NULL,
    Note            NVARCHAR(500) NULL,
    IsActive        BIT           NOT NULL DEFAULT 1,
    CreatedAt       DATETIME2     NOT NULL DEFAULT SYSDATETIME(),
    UpdatedAt       DATETIME2     NULL
);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Customers_Phone' AND object_id=OBJECT_ID('dbo.Customers'))
    CREATE INDEX IX_Customers_Phone ON dbo.Customers(Phone);
GO

/* ---------- 4. Thiết bị của khách ---------- */
IF OBJECT_ID('dbo.Devices') IS NULL
CREATE TABLE dbo.Devices (
    DeviceId        INT IDENTITY(1,1) PRIMARY KEY,
    CustomerId      INT           NOT NULL,
    DeviceType      NVARCHAR(50)  NOT NULL,          -- Điện thoại, Laptop, Máy in...
    Brand           NVARCHAR(50)  NULL,
    Model           NVARCHAR(100) NULL,
    SerialNumber    VARCHAR(100)  NULL,
    Note            NVARCHAR(500) NULL,
    CreatedAt       DATETIME2     NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT FK_Devices_Customers FOREIGN KEY (CustomerId) REFERENCES dbo.Customers(CustomerId)
);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Devices_CustomerId' AND object_id=OBJECT_ID('dbo.Devices'))
    CREATE INDEX IX_Devices_CustomerId ON dbo.Devices(CustomerId);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Devices_SerialNumber' AND object_id=OBJECT_ID('dbo.Devices'))
    CREATE INDEX IX_Devices_SerialNumber ON dbo.Devices(SerialNumber);
GO

/* ---------- 5. Loại dịch vụ & biểu giá tiền công ---------- */
IF OBJECT_ID('dbo.ServiceTypes') IS NULL
CREATE TABLE dbo.ServiceTypes (
    ServiceTypeId    INT IDENTITY(1,1) PRIMARY KEY,
    ServiceCode      VARCHAR(20)    NOT NULL UNIQUE,
    ServiceName      NVARCHAR(100)  NOT NULL,
    LaborCost        DECIMAL(18,2)  NOT NULL DEFAULT 0,
    WarrantyDays     INT            NOT NULL DEFAULT 0,  -- Thời hạn bảo hành mặc định
    Description      NVARCHAR(300)  NULL,
    IsActive         BIT            NOT NULL DEFAULT 1,
    CONSTRAINT CK_ServiceTypes_LaborCost    CHECK (LaborCost >= 0),
    CONSTRAINT CK_ServiceTypes_WarrantyDays CHECK (WarrantyDays >= 0)
);
GO

/* ---------- 6. Phiếu sửa chữa ---------- */
IF OBJECT_ID('dbo.RepairTickets') IS NULL
CREATE TABLE dbo.RepairTickets (
    TicketId          INT IDENTITY(1,1) PRIMARY KEY,
    TicketCode        VARCHAR(20)    NOT NULL UNIQUE,  -- PSC2026090001
    CustomerId        INT            NOT NULL,
    DeviceId          INT            NOT NULL,
    ServiceTypeId     INT            NULL,
    ReceivedByUserId  INT            NOT NULL,         -- Nhân viên tiếp nhận
    TechnicianUserId  INT            NULL,             -- Kỹ thuật viên được phân công
    Status            VARCHAR(30)    NOT NULL DEFAULT 'RECEIVED',
    -- RECEIVED, DIAGNOSING, WAITING_CONFIRM, REPAIRING, COMPLETED, DELIVERED, CANCELLED
    DeviceCondition   NVARCHAR(1000) NULL,             -- Tình trạng lúc nhận
    CustomerRequest   NVARCHAR(1000) NULL,
    Diagnosis         NVARCHAR(1000) NULL,
    QuotedLaborCost   DECIMAL(18,2)  NOT NULL DEFAULT 0,
    QuotedPartsCost   DECIMAL(18,2)  NOT NULL DEFAULT 0,
    QuotedTotal       AS (QuotedLaborCost + QuotedPartsCost) PERSISTED,
    IsWarrantyRepair  BIT            NOT NULL DEFAULT 0,
    OriginalTicketId  INT            NULL,             -- Phiếu gốc nếu là sửa bảo hành
    ReceivedAt        DATETIME2      NOT NULL DEFAULT SYSDATETIME(),
    ExpectedFinishAt  DATETIME2      NULL,
    CompletedAt       DATETIME2      NULL,
    DeliveredAt       DATETIME2      NULL,
    CancelReason      NVARCHAR(500)  NULL,
    CreatedAt         DATETIME2      NOT NULL DEFAULT SYSDATETIME(),
    UpdatedAt         DATETIME2      NULL,
    CONSTRAINT FK_Tickets_Customers   FOREIGN KEY (CustomerId)       REFERENCES dbo.Customers(CustomerId),
    CONSTRAINT FK_Tickets_Devices     FOREIGN KEY (DeviceId)         REFERENCES dbo.Devices(DeviceId),
    CONSTRAINT FK_Tickets_Services    FOREIGN KEY (ServiceTypeId)    REFERENCES dbo.ServiceTypes(ServiceTypeId),
    CONSTRAINT FK_Tickets_Received    FOREIGN KEY (ReceivedByUserId) REFERENCES dbo.Users(UserId),
    CONSTRAINT FK_Tickets_Technician  FOREIGN KEY (TechnicianUserId) REFERENCES dbo.Users(UserId),
    CONSTRAINT FK_Tickets_Original    FOREIGN KEY (OriginalTicketId) REFERENCES dbo.RepairTickets(TicketId),
    CONSTRAINT CK_Tickets_Status CHECK (Status IN
        ('RECEIVED','DIAGNOSING','WAITING_CONFIRM','REPAIRING','COMPLETED','DELIVERED','CANCELLED'))
);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Tickets_CustomerId' AND object_id=OBJECT_ID('dbo.RepairTickets'))
    CREATE INDEX IX_Tickets_CustomerId ON dbo.RepairTickets(CustomerId);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Tickets_Status' AND object_id=OBJECT_ID('dbo.RepairTickets'))
    CREATE INDEX IX_Tickets_Status ON dbo.RepairTickets(Status);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Tickets_ReceivedAt' AND object_id=OBJECT_ID('dbo.RepairTickets'))
    CREATE INDEX IX_Tickets_ReceivedAt ON dbo.RepairTickets(ReceivedAt);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Tickets_Technician' AND object_id=OBJECT_ID('dbo.RepairTickets'))
    CREATE INDEX IX_Tickets_Technician ON dbo.RepairTickets(TechnicianUserId);
GO

/* ---------- 7. Lịch sử trạng thái phiếu ---------- */
IF OBJECT_ID('dbo.TicketStatusHistory') IS NULL
CREATE TABLE dbo.TicketStatusHistory (
    HistoryId       INT IDENTITY(1,1) PRIMARY KEY,
    TicketId        INT           NOT NULL,
    FromStatus      VARCHAR(30)   NULL,
    ToStatus        VARCHAR(30)   NOT NULL,
    ChangedByUserId INT           NOT NULL,
    Note            NVARCHAR(500) NULL,
    ChangedAt       DATETIME2     NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT FK_History_Tickets FOREIGN KEY (TicketId)        REFERENCES dbo.RepairTickets(TicketId),
    CONSTRAINT FK_History_Users   FOREIGN KEY (ChangedByUserId) REFERENCES dbo.Users(UserId)
);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_History_TicketId' AND object_id=OBJECT_ID('dbo.TicketStatusHistory'))
    CREATE INDEX IX_History_TicketId ON dbo.TicketStatusHistory(TicketId);
GO

/* ---------- 8. Nhóm linh kiện ---------- */
IF OBJECT_ID('dbo.SparePartCategories') IS NULL
CREATE TABLE dbo.SparePartCategories (
    CategoryId      INT IDENTITY(1,1) PRIMARY KEY,
    CategoryName    NVARCHAR(100) NOT NULL,
    Description     NVARCHAR(300) NULL,
    IsActive        BIT           NOT NULL DEFAULT 1
);
GO

/* ---------- 9. Linh kiện ---------- */
IF OBJECT_ID('dbo.SpareParts') IS NULL
CREATE TABLE dbo.SpareParts (
    PartId          INT IDENTITY(1,1) PRIMARY KEY,
    PartCode        VARCHAR(30)    NOT NULL UNIQUE,   -- LK00001
    CategoryId      INT            NOT NULL,
    PartName        NVARCHAR(150)  NOT NULL,
    Unit            NVARCHAR(20)   NOT NULL DEFAULT N'Cái',
    PurchasePrice   DECIMAL(18,2)  NOT NULL DEFAULT 0,
    SellingPrice    DECIMAL(18,2)  NOT NULL DEFAULT 0,
    StockQuantity   INT            NOT NULL DEFAULT 0,
    MinStockLevel   INT            NOT NULL DEFAULT 0, -- Mức tồn tối thiểu để cảnh báo
    WarrantyDays    INT            NOT NULL DEFAULT 0,
    IsActive        BIT            NOT NULL DEFAULT 1,
    CreatedAt       DATETIME2      NOT NULL DEFAULT SYSDATETIME(),
    UpdatedAt       DATETIME2      NULL,
    CONSTRAINT FK_Parts_Categories FOREIGN KEY (CategoryId) REFERENCES dbo.SparePartCategories(CategoryId),
    CONSTRAINT CK_Parts_Stock         CHECK (StockQuantity >= 0),
    CONSTRAINT CK_Parts_MinStock      CHECK (MinStockLevel >= 0),
    CONSTRAINT CK_Parts_PurchasePrice CHECK (PurchasePrice >= 0),
    CONSTRAINT CK_Parts_SellingPrice  CHECK (SellingPrice  >= 0)
);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Parts_CategoryId' AND object_id=OBJECT_ID('dbo.SpareParts'))
    CREATE INDEX IX_Parts_CategoryId ON dbo.SpareParts(CategoryId);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Parts_PartName' AND object_id=OBJECT_ID('dbo.SpareParts'))
    CREATE INDEX IX_Parts_PartName ON dbo.SpareParts(PartName);
GO

/* ---------- 10. Giao dịch kho (nhập / xuất / điều chỉnh) ---------- */
IF OBJECT_ID('dbo.StockTransactions') IS NULL
CREATE TABLE dbo.StockTransactions (
    TransactionId     INT IDENTITY(1,1) PRIMARY KEY,
    PartId            INT            NOT NULL,
    TransactionType   VARCHAR(20)    NOT NULL,   -- IN, OUT, ADJUST, RETURN
    Quantity          INT            NOT NULL,   -- Luôn dương, hướng do TransactionType quyết định
    UnitPrice         DECIMAL(18,2)  NOT NULL DEFAULT 0,
    StockBefore       INT            NOT NULL,
    StockAfter        INT            NOT NULL,
    TicketId          INT            NULL,       -- Nếu xuất cho phiếu sửa chữa
    PerformedByUserId INT            NOT NULL,
    Note              NVARCHAR(500)  NULL,
    TransactionAt     DATETIME2      NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT FK_Stock_Parts   FOREIGN KEY (PartId)            REFERENCES dbo.SpareParts(PartId),
    CONSTRAINT FK_Stock_Tickets FOREIGN KEY (TicketId)          REFERENCES dbo.RepairTickets(TicketId),
    CONSTRAINT FK_Stock_Users   FOREIGN KEY (PerformedByUserId) REFERENCES dbo.Users(UserId),
    CONSTRAINT CK_Stock_Type     CHECK (TransactionType IN ('IN','OUT','ADJUST','RETURN')),
    CONSTRAINT CK_Stock_Quantity CHECK (Quantity > 0)
);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Stock_PartId' AND object_id=OBJECT_ID('dbo.StockTransactions'))
    CREATE INDEX IX_Stock_PartId ON dbo.StockTransactions(PartId);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Stock_TicketId' AND object_id=OBJECT_ID('dbo.StockTransactions'))
    CREATE INDEX IX_Stock_TicketId ON dbo.StockTransactions(TicketId);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Stock_TransactionAt' AND object_id=OBJECT_ID('dbo.StockTransactions'))
    CREATE INDEX IX_Stock_TransactionAt ON dbo.StockTransactions(TransactionAt);
GO

/* ---------- 11. Linh kiện dùng cho phiếu sửa chữa ---------- */
IF OBJECT_ID('dbo.TicketParts') IS NULL
CREATE TABLE dbo.TicketParts (
    TicketPartId    INT IDENTITY(1,1) PRIMARY KEY,
    TicketId        INT            NOT NULL,
    PartId          INT            NOT NULL,
    Quantity        INT            NOT NULL,
    UnitPrice       DECIMAL(18,2)  NOT NULL,          -- Giá bán tại thời điểm xuất
    LineTotal       AS (Quantity * UnitPrice) PERSISTED,
    Note            NVARCHAR(300)  NULL,
    CreatedAt       DATETIME2      NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT FK_TicketParts_Tickets FOREIGN KEY (TicketId) REFERENCES dbo.RepairTickets(TicketId),
    CONSTRAINT FK_TicketParts_Parts   FOREIGN KEY (PartId)   REFERENCES dbo.SpareParts(PartId),
    CONSTRAINT CK_TicketParts_Quantity  CHECK (Quantity  > 0),
    CONSTRAINT CK_TicketParts_UnitPrice CHECK (UnitPrice >= 0)
);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_TicketParts_TicketId' AND object_id=OBJECT_ID('dbo.TicketParts'))
    CREATE INDEX IX_TicketParts_TicketId ON dbo.TicketParts(TicketId);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_TicketParts_PartId' AND object_id=OBJECT_ID('dbo.TicketParts'))
    CREATE INDEX IX_TicketParts_PartId ON dbo.TicketParts(PartId);
GO

/* ---------- 12. Hóa đơn ---------- */
IF OBJECT_ID('dbo.Invoices') IS NULL
CREATE TABLE dbo.Invoices (
    InvoiceId       INT IDENTITY(1,1) PRIMARY KEY,
    InvoiceCode     VARCHAR(20)    NOT NULL UNIQUE,  -- HD2026090001
    TicketId        INT            NOT NULL UNIQUE,  -- Một phiếu một hóa đơn
    CustomerId      INT            NOT NULL,
    LaborCost       DECIMAL(18,2)  NOT NULL DEFAULT 0,
    PartsCost       DECIMAL(18,2)  NOT NULL DEFAULT 0,
    DiscountAmount  DECIMAL(18,2)  NOT NULL DEFAULT 0,
    TotalAmount     AS (LaborCost + PartsCost - DiscountAmount) PERSISTED,
    PaymentMethod   VARCHAR(20)    NOT NULL DEFAULT 'CASH',  -- CASH, TRANSFER
    PaymentStatus   VARCHAR(20)    NOT NULL DEFAULT 'UNPAID', -- UNPAID, PAID, REFUNDED
    PaidAt          DATETIME2      NULL,
    CreatedByUserId INT            NOT NULL,
    Note            NVARCHAR(500)  NULL,
    CreatedAt       DATETIME2      NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT FK_Invoices_Tickets   FOREIGN KEY (TicketId)        REFERENCES dbo.RepairTickets(TicketId),
    CONSTRAINT FK_Invoices_Customers FOREIGN KEY (CustomerId)      REFERENCES dbo.Customers(CustomerId),
    CONSTRAINT FK_Invoices_Users     FOREIGN KEY (CreatedByUserId) REFERENCES dbo.Users(UserId),
    CONSTRAINT CK_Invoices_Method   CHECK (PaymentMethod IN ('CASH','TRANSFER')),
    CONSTRAINT CK_Invoices_Status   CHECK (PaymentStatus IN ('UNPAID','PAID','REFUNDED')),
    CONSTRAINT CK_Invoices_Discount CHECK (DiscountAmount >= 0)
);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Invoices_CustomerId' AND object_id=OBJECT_ID('dbo.Invoices'))
    CREATE INDEX IX_Invoices_CustomerId ON dbo.Invoices(CustomerId);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Invoices_CreatedAt' AND object_id=OBJECT_ID('dbo.Invoices'))
    CREATE INDEX IX_Invoices_CreatedAt ON dbo.Invoices(CreatedAt);
GO

/* ---------- 13. Phiếu bảo hành ---------- */
IF OBJECT_ID('dbo.Warranties') IS NULL
CREATE TABLE dbo.Warranties (
    WarrantyId      INT IDENTITY(1,1) PRIMARY KEY,
    WarrantyCode    VARCHAR(20)    NOT NULL UNIQUE,  -- BH2026090001
    TicketId        INT            NOT NULL,
    CustomerId      INT            NOT NULL,
    DeviceId        INT            NOT NULL,
    StartDate       DATE           NOT NULL,
    EndDate         DATE           NOT NULL,
    WarrantyDays    INT            NOT NULL,
    Scope           NVARCHAR(500)  NULL,             -- Phạm vi bảo hành
    Status          VARCHAR(20)    NOT NULL DEFAULT 'ACTIVE', -- ACTIVE, EXPIRED, VOID, USED
    VoidReason      NVARCHAR(300)  NULL,
    CreatedAt       DATETIME2      NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT FK_Warranties_Tickets   FOREIGN KEY (TicketId)   REFERENCES dbo.RepairTickets(TicketId),
    CONSTRAINT FK_Warranties_Customers FOREIGN KEY (CustomerId) REFERENCES dbo.Customers(CustomerId),
    CONSTRAINT FK_Warranties_Devices   FOREIGN KEY (DeviceId)   REFERENCES dbo.Devices(DeviceId),
    CONSTRAINT CK_Warranties_Status CHECK (Status IN ('ACTIVE','EXPIRED','VOID','USED')),
    CONSTRAINT CK_Warranties_Date   CHECK (EndDate >= StartDate)
);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Warranties_TicketId' AND object_id=OBJECT_ID('dbo.Warranties'))
    CREATE INDEX IX_Warranties_TicketId ON dbo.Warranties(TicketId);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Warranties_CustomerId' AND object_id=OBJECT_ID('dbo.Warranties'))
    CREATE INDEX IX_Warranties_CustomerId ON dbo.Warranties(CustomerId);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Warranties_EndDate' AND object_id=OBJECT_ID('dbo.Warranties'))
    CREATE INDEX IX_Warranties_EndDate ON dbo.Warranties(EndDate);
GO

PRINT 'Da tao xong 13 bang cua RepairShopDB.';
GO
