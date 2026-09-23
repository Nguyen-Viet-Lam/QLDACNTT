/* ================================================================
   QLDACNTT - Full SQL script
   Chay theo thu tu: tao database, tao bang, seed data, truy van bao cao.
   ================================================================ */


/* ===== BEGIN: database\schema\01_create_database.sql ===== */

/* =====================================================================
   LV33-001 â€” Há»‡ thá»‘ng quáº£n lÃ½ tá»•ng thá»ƒ cho cá»­a hÃ ng sá»­a chá»¯a
   Script 01: Táº¡o cÆ¡ sá»Ÿ dá»¯ liá»‡u
   NgÆ°á»i viáº¿t: Tráº§n Ngá»c Lá»£i (Database)
   ===================================================================== */

USE master;
GO

IF DB_ID('RepairShopDB') IS NULL
BEGIN
    CREATE DATABASE RepairShopDB
    COLLATE Vietnamese_CI_AS;
    PRINT 'Da tao database RepairShopDB.';
END
ELSE
    PRINT 'Database RepairShopDB da ton tai, bo qua.';
GO

ALTER DATABASE RepairShopDB SET RECOVERY SIMPLE;
GO


/* ===== END: database\schema\01_create_database.sql ===== */


/* ===== BEGIN: database\schema\02_create_tables.sql ===== */

/* =====================================================================
   LV33-001 â€” Há»‡ thá»‘ng quáº£n lÃ½ tá»•ng thá»ƒ cho cá»­a hÃ ng sá»­a chá»¯a
   Script 02: Táº¡o báº£ng
   NgÆ°á»i viáº¿t: Tráº§n Ngá»c Lá»£i (Database)

   13 báº£ng: Roles, Users, Customers, Devices, ServiceTypes, RepairTickets,
            TicketStatusHistory, SparePartCategories, SpareParts,
            StockTransactions, TicketParts, Invoices, Warranties
   ===================================================================== */

USE RepairShopDB;
GO

/* Báº¯t buá»™c báº­t 2 tÃ¹y chá»n nÃ y: cÃ¡c báº£ng bÃªn dÆ°á»›i cÃ³ cá»™t tÃ­nh toÃ¡n PERSISTED
   (QuotedTotal, LineTotal, TotalAmount). SSMS báº­t sáºµn nhÆ°ng sqlcmd máº·c Ä‘á»‹nh
   Ä‘á»ƒ QUOTED_IDENTIFIER OFF nÃªn sáº½ lá»—i 1934 náº¿u khÃ´ng set tÆ°á»ng minh. */
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

/* ---------- 1. Vai trÃ² (RBAC) ---------- */
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

/* ---------- 2. NgÆ°á»i dÃ¹ng há»‡ thá»‘ng ---------- */
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

/* ---------- 3. KhÃ¡ch hÃ ng ---------- */
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

/* ---------- 4. Thiáº¿t bá»‹ cá»§a khÃ¡ch ---------- */
IF OBJECT_ID('dbo.Devices') IS NULL
CREATE TABLE dbo.Devices (
    DeviceId        INT IDENTITY(1,1) PRIMARY KEY,
    CustomerId      INT           NOT NULL,
    DeviceType      NVARCHAR(50)  NOT NULL,          -- Äiá»‡n thoáº¡i, Laptop, MÃ¡y in...
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

/* ---------- 5. Loáº¡i dá»‹ch vá»¥ & biá»ƒu giÃ¡ tiá»n cÃ´ng ---------- */
IF OBJECT_ID('dbo.ServiceTypes') IS NULL
CREATE TABLE dbo.ServiceTypes (
    ServiceTypeId    INT IDENTITY(1,1) PRIMARY KEY,
    ServiceCode      VARCHAR(20)    NOT NULL UNIQUE,
    ServiceName      NVARCHAR(100)  NOT NULL,
    LaborCost        DECIMAL(18,2)  NOT NULL DEFAULT 0,
    WarrantyDays     INT            NOT NULL DEFAULT 0,  -- Thá»i háº¡n báº£o hÃ nh máº·c Ä‘á»‹nh
    Description      NVARCHAR(300)  NULL,
    IsActive         BIT            NOT NULL DEFAULT 1,
    CONSTRAINT CK_ServiceTypes_LaborCost    CHECK (LaborCost >= 0),
    CONSTRAINT CK_ServiceTypes_WarrantyDays CHECK (WarrantyDays >= 0)
);
GO

/* ---------- 6. Phiáº¿u sá»­a chá»¯a ---------- */
IF OBJECT_ID('dbo.RepairTickets') IS NULL
CREATE TABLE dbo.RepairTickets (
    TicketId          INT IDENTITY(1,1) PRIMARY KEY,
    TicketCode        VARCHAR(20)    NOT NULL UNIQUE,  -- PSC2026090001
    CustomerId        INT            NOT NULL,
    DeviceId          INT            NOT NULL,
    ServiceTypeId     INT            NULL,
    ReceivedByUserId  INT            NOT NULL,         -- NhÃ¢n viÃªn tiáº¿p nháº­n
    TechnicianUserId  INT            NULL,             -- Ká»¹ thuáº­t viÃªn Ä‘Æ°á»£c phÃ¢n cÃ´ng
    Status            VARCHAR(30)    NOT NULL DEFAULT 'RECEIVED',
    -- RECEIVED, DIAGNOSING, WAITING_CONFIRM, REPAIRING, COMPLETED, DELIVERED, CANCELLED
    DeviceCondition   NVARCHAR(1000) NULL,             -- TÃ¬nh tráº¡ng lÃºc nháº­n
    CustomerRequest   NVARCHAR(1000) NULL,
    Diagnosis         NVARCHAR(1000) NULL,
    QuotedLaborCost   DECIMAL(18,2)  NOT NULL DEFAULT 0,
    QuotedPartsCost   DECIMAL(18,2)  NOT NULL DEFAULT 0,
    QuotedTotal       AS (QuotedLaborCost + QuotedPartsCost) PERSISTED,
    IsWarrantyRepair  BIT            NOT NULL DEFAULT 0,
    OriginalTicketId  INT            NULL,             -- Phiáº¿u gá»‘c náº¿u lÃ  sá»­a báº£o hÃ nh
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

/* ---------- 7. Lá»‹ch sá»­ tráº¡ng thÃ¡i phiáº¿u ---------- */
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

/* ---------- 8. NhÃ³m linh kiá»‡n ---------- */
IF OBJECT_ID('dbo.SparePartCategories') IS NULL
CREATE TABLE dbo.SparePartCategories (
    CategoryId      INT IDENTITY(1,1) PRIMARY KEY,
    CategoryName    NVARCHAR(100) NOT NULL,
    Description     NVARCHAR(300) NULL,
    IsActive        BIT           NOT NULL DEFAULT 1
);
GO

/* ---------- 9. Linh kiá»‡n ---------- */
IF OBJECT_ID('dbo.SpareParts') IS NULL
CREATE TABLE dbo.SpareParts (
    PartId          INT IDENTITY(1,1) PRIMARY KEY,
    PartCode        VARCHAR(30)    NOT NULL UNIQUE,   -- LK00001
    CategoryId      INT            NOT NULL,
    PartName        NVARCHAR(150)  NOT NULL,
    Unit            NVARCHAR(20)   NOT NULL DEFAULT N'CÃ¡i',
    PurchasePrice   DECIMAL(18,2)  NOT NULL DEFAULT 0,
    SellingPrice    DECIMAL(18,2)  NOT NULL DEFAULT 0,
    StockQuantity   INT            NOT NULL DEFAULT 0,
    MinStockLevel   INT            NOT NULL DEFAULT 0, -- Má»©c tá»“n tá»‘i thiá»ƒu Ä‘á»ƒ cáº£nh bÃ¡o
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

/* ---------- 10. Giao dá»‹ch kho (nháº­p / xuáº¥t / Ä‘iá»u chá»‰nh) ---------- */
IF OBJECT_ID('dbo.StockTransactions') IS NULL
CREATE TABLE dbo.StockTransactions (
    TransactionId     INT IDENTITY(1,1) PRIMARY KEY,
    PartId            INT            NOT NULL,
    TransactionType   VARCHAR(20)    NOT NULL,   -- IN, OUT, ADJUST, RETURN
    Quantity          INT            NOT NULL,   -- LuÃ´n dÆ°Æ¡ng, hÆ°á»›ng do TransactionType quyáº¿t Ä‘á»‹nh
    UnitPrice         DECIMAL(18,2)  NOT NULL DEFAULT 0,
    StockBefore       INT            NOT NULL,
    StockAfter        INT            NOT NULL,
    TicketId          INT            NULL,       -- Náº¿u xuáº¥t cho phiáº¿u sá»­a chá»¯a
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

/* ---------- 11. Linh kiá»‡n dÃ¹ng cho phiáº¿u sá»­a chá»¯a ---------- */
IF OBJECT_ID('dbo.TicketParts') IS NULL
CREATE TABLE dbo.TicketParts (
    TicketPartId    INT IDENTITY(1,1) PRIMARY KEY,
    TicketId        INT            NOT NULL,
    PartId          INT            NOT NULL,
    Quantity        INT            NOT NULL,
    UnitPrice       DECIMAL(18,2)  NOT NULL,          -- GiÃ¡ bÃ¡n táº¡i thá»i Ä‘iá»ƒm xuáº¥t
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

/* ---------- 12. HÃ³a Ä‘Æ¡n ---------- */
IF OBJECT_ID('dbo.Invoices') IS NULL
CREATE TABLE dbo.Invoices (
    InvoiceId       INT IDENTITY(1,1) PRIMARY KEY,
    InvoiceCode     VARCHAR(20)    NOT NULL UNIQUE,  -- HD2026090001
    TicketId        INT            NOT NULL UNIQUE,  -- Má»™t phiáº¿u má»™t hÃ³a Ä‘Æ¡n
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

/* ---------- 13. Phiáº¿u báº£o hÃ nh ---------- */
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
    Scope           NVARCHAR(500)  NULL,             -- Pháº¡m vi báº£o hÃ nh
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


/* ===== END: database\schema\02_create_tables.sql ===== */


/* ===== BEGIN: database\seed\01_seed_master_data.sql ===== */

/* =====================================================================
   LV33-001 â€” Há»‡ thá»‘ng quáº£n lÃ½ tá»•ng thá»ƒ cho cá»­a hÃ ng sá»­a chá»¯a
   Script seed 01: Dá»¯ liá»‡u danh má»¥c ná»n (master data)
   NgÆ°á»i viáº¿t: Tráº§n Ngá»c Lá»£i (Database)

   LÆ°u Ã½: toÃ n bá»™ dá»¯ liá»‡u khÃ¡ch hÃ ng lÃ  dá»¯ liá»‡u giáº£ phá»¥c vá»¥ demo.
   Máº­t kháº©u máº«u cá»§a má»i tÃ i khoáº£n: Abc@12345 (hash tháº­t sáº½ do Backend sinh).
   ===================================================================== */

USE RepairShopDB;
GO

/* Báº¯t buá»™c báº­t khi cháº¡y báº±ng sqlcmd â€” cÃ¡c báº£ng phiáº¿u/hÃ³a Ä‘Æ¡n cÃ³ cá»™t tÃ­nh toÃ¡n
   PERSISTED, thiáº¿u 2 dÃ²ng nÃ y thÃ¬ INSERT sáº½ lá»—i 1934. SSMS Ä‘Ã£ báº­t sáºµn. */
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

/* ---------- Vai trÃ² ---------- */
IF NOT EXISTS (SELECT 1 FROM dbo.Roles)
INSERT INTO dbo.Roles (RoleCode, RoleName, Description) VALUES
    ('ADMIN',      N'Quáº£n trá»‹ viÃªn',     N'Chá»§ cá»­a hÃ ng / quáº£n lÃ½, toÃ n quyá»n há»‡ thá»‘ng'),
    ('STAFF',      N'NhÃ¢n viÃªn',          N'Tiáº¿p nháº­n thiáº¿t bá»‹, láº­p phiáº¿u, thu tiá»n'),
    ('TECHNICIAN', N'Ká»¹ thuáº­t viÃªn',      N'Cháº©n Ä‘oÃ¡n, sá»­a chá»¯a, xuáº¥t linh kiá»‡n'),
    ('CUSTOMER',   N'KhÃ¡ch hÃ ng',         N'Tra cá»©u tiáº¿n Ä‘á»™ vÃ  báº£o hÃ nh qua mobile app');
GO

/* ---------- NgÆ°á»i dÃ¹ng ---------- */
IF NOT EXISTS (SELECT 1 FROM dbo.Users)
INSERT INTO dbo.Users (RoleId, Username, PasswordHash, FullName, Email, Phone) VALUES
    ((SELECT RoleId FROM dbo.Roles WHERE RoleCode='ADMIN'),      'admin',   'SEED_REPLACE_ME', N'Chá»§ cá»­a hÃ ng',      'admin@repairshop.local', '0900000001'),
    ((SELECT RoleId FROM dbo.Roles WHERE RoleCode='STAFF'),      'staff01', 'SEED_REPLACE_ME', N'LÃª Thá»‹ Tiáº¿p Nháº­n',  'staff01@repairshop.local','0900000002'),
    ((SELECT RoleId FROM dbo.Roles WHERE RoleCode='TECHNICIAN'), 'tech01',  'SEED_REPLACE_ME', N'Pháº¡m VÄƒn Ká»¹ Thuáº­t', 'tech01@repairshop.local', '0900000003'),
    ((SELECT RoleId FROM dbo.Roles WHERE RoleCode='TECHNICIAN'), 'tech02',  'SEED_REPLACE_ME', N'VÃµ Minh Ká»¹ Thuáº­t',  'tech02@repairshop.local', '0900000004');
GO

/* ---------- Loáº¡i dá»‹ch vá»¥ & biá»ƒu giÃ¡ tiá»n cÃ´ng ---------- */
IF NOT EXISTS (SELECT 1 FROM dbo.ServiceTypes)
INSERT INTO dbo.ServiceTypes (ServiceCode, ServiceName, LaborCost, WarrantyDays, Description) VALUES
    ('DV001', N'Thay mÃ n hÃ¬nh Ä‘iá»‡n thoáº¡i',   150000,  90, N'ThÃ¡o láº¯p vÃ  thay mÃ n hÃ¬nh'),
    ('DV002', N'Thay pin Ä‘iá»‡n thoáº¡i',        100000, 180, N'Thay pin vÃ  kiá»ƒm tra sáº¡c'),
    ('DV003', N'Vá»‡ sinh mÃ¡y, tra keo táº£n nhiá»‡t', 120000, 30, N'Vá»‡ sinh laptop, thay keo táº£n nhiá»‡t'),
    ('DV004', N'CÃ i Ä‘áº·t láº¡i há»‡ Ä‘iá»u hÃ nh',    80000,  15, N'CÃ i Windows, driver, pháº§n má»m cÆ¡ báº£n'),
    ('DV005', N'Sá»­a mainboard',              350000,  60, N'Sá»­a chá»¯a máº¡ch, hÃ n linh kiá»‡n'),
    ('DV006', N'Thay á»• cá»©ng / nÃ¢ng cáº¥p SSD', 100000, 365, N'Thay á»• cá»©ng, sao lÆ°u dá»¯ liá»‡u'),
    ('DV007', N'Sá»­a nguá»“n mÃ¡y tÃ­nh',         180000,  90, N'Kiá»ƒm tra vÃ  sá»­a bá»™ nguá»“n'),
    ('DV008', N'Thay má»±c, sá»­a mÃ¡y in',       130000,  30, N'Vá»‡ sinh, thay má»±c, sá»­a cÆ¡ cáº¥u náº¡p giáº¥y');
GO

/* ---------- NhÃ³m linh kiá»‡n ---------- */
IF NOT EXISTS (SELECT 1 FROM dbo.SparePartCategories)
INSERT INTO dbo.SparePartCategories (CategoryName, Description) VALUES
    (N'MÃ n hÃ¬nh',        N'MÃ n hÃ¬nh Ä‘iá»‡n thoáº¡i, laptop'),
    (N'Pin & Sáº¡c',       N'Pin, adapter, cÃ¡p sáº¡c'),
    (N'á»” cá»©ng & RAM',    N'HDD, SSD, thanh RAM'),
    (N'Mainboard & IC',  N'Bo máº¡ch, IC, chip'),
    (N'Váº­t tÆ° tiÃªu hao', N'Keo táº£n nhiá»‡t, má»±c in, á»‘c vÃ­t'),
    (N'Phá»¥ kiá»‡n khÃ¡c',   N'BÃ n phÃ­m, loa, camera, quáº¡t');
GO

/* ---------- Linh kiá»‡n ---------- */
IF NOT EXISTS (SELECT 1 FROM dbo.SpareParts)
INSERT INTO dbo.SpareParts (PartCode, CategoryId, PartName, Unit, PurchasePrice, SellingPrice, StockQuantity, MinStockLevel, WarrantyDays) VALUES
    ('LK00001', 1, N'MÃ n hÃ¬nh iPhone 11 (linh kiá»‡n)', N'CÃ¡i',  850000, 1200000, 12,  3,  90),
    ('LK00002', 1, N'MÃ n hÃ¬nh Samsung A32',           N'CÃ¡i',  620000,  900000,  8,  3,  90),
    ('LK00003', 1, N'MÃ n hÃ¬nh laptop 15.6" FHD',      N'CÃ¡i',  980000, 1400000,  5,  2,  90),
    ('LK00004', 2, N'Pin iPhone 11',                  N'CÃ¡i',  280000,  450000, 20,  5, 180),
    ('LK00005', 2, N'Pin laptop Dell 3 cell',         N'CÃ¡i',  450000,  700000,  6,  2, 180),
    ('LK00006', 2, N'Adapter laptop 65W',             N'CÃ¡i',  190000,  320000, 15,  4,  90),
    ('LK00007', 3, N'SSD 256GB SATA',                 N'CÃ¡i',  480000,  700000, 18,  5, 365),
    ('LK00008', 3, N'SSD 512GB NVMe',                 N'CÃ¡i',  820000, 1150000, 10,  3, 365),
    ('LK00009', 3, N'RAM DDR4 8GB 3200MHz',           N'Thanh',520000,  750000, 14,  4, 365),
    ('LK00010', 4, N'IC nguá»“n Ä‘iá»‡n thoáº¡i',            N'CÃ¡i',   65000,  150000, 25,  8,  30),
    ('LK00011', 4, N'ChÃ¢n sáº¡c iPhone',                N'CÃ¡i',   45000,  120000, 30, 10,  60),
    ('LK00012', 5, N'Keo táº£n nhiá»‡t MX-4 (tuÃ½p nhá»)',  N'TuÃ½p',  55000,  100000, 22,  6,   0),
    ('LK00013', 5, N'Má»±c in Canon 2900',              N'Há»™p',  120000,  210000,  9,  3,   0),
    ('LK00014', 6, N'BÃ n phÃ­m laptop Dell',           N'CÃ¡i',  230000,  380000,  7,  2,  90),
    ('LK00015', 6, N'Quáº¡t táº£n nhiá»‡t laptop',          N'CÃ¡i',  110000,  200000, 11,  3,  90),
    ('LK00016', 6, N'Loa trong Ä‘iá»‡n thoáº¡i',           N'CÃ¡i',   40000,   95000, 16,  5,  30);
GO

PRINT 'Da nap xong du lieu danh muc nen.';
GO


/* ===== END: database\seed\01_seed_master_data.sql ===== */


/* ===== BEGIN: database\queries\bao_cao_thong_ke.sql ===== */

/* =====================================================================
   LV33-001 â€” Truy váº¥n bÃ¡o cÃ¡o thá»‘ng kÃª
   NgÆ°á»i viáº¿t: Tráº§n Ngá»c Lá»£i (Database)
   CÃ¡c truy váº¥n nÃ y lÃ  nguá»“n dá»¯ liá»‡u cho dashboard vÃ  bÃ¡o cÃ¡o Web Admin.
   ===================================================================== */

USE RepairShopDB;
GO

/* ---------- 1. Doanh thu theo ngÃ y trong khoáº£ng thá»i gian ---------- */
-- Tham sá»‘: @FromDate, @ToDate
DECLARE @FromDate DATE = '2026-09-01', @ToDate DATE = '2026-11-03';

SELECT
    CAST(i.CreatedAt AS DATE)        AS Ngay,
    COUNT(*)                         AS SoHoaDon,
    SUM(i.LaborCost)                 AS TienCong,
    SUM(i.PartsCost)                 AS TienLinhKien,
    SUM(i.DiscountAmount)            AS GiamGia,
    SUM(i.TotalAmount)               AS DoanhThu
FROM dbo.Invoices i
WHERE i.PaymentStatus = 'PAID'
  AND CAST(i.CreatedAt AS DATE) BETWEEN @FromDate AND @ToDate
GROUP BY CAST(i.CreatedAt AS DATE)
ORDER BY Ngay;
GO

/* ---------- 2. Doanh thu theo thÃ¡ng ---------- */
SELECT
    YEAR(i.CreatedAt)                AS Nam,
    MONTH(i.CreatedAt)               AS Thang,
    COUNT(*)                         AS SoHoaDon,
    SUM(i.TotalAmount)               AS DoanhThu,
    AVG(i.TotalAmount)               AS GiaTriTrungBinh
FROM dbo.Invoices i
WHERE i.PaymentStatus = 'PAID'
GROUP BY YEAR(i.CreatedAt), MONTH(i.CreatedAt)
ORDER BY Nam, Thang;
GO

/* ---------- 3. Sá»‘ phiáº¿u theo tráº¡ng thÃ¡i ---------- */
SELECT
    t.Status                         AS TrangThai,
    COUNT(*)                         AS SoPhieu
FROM dbo.RepairTickets t
GROUP BY t.Status
ORDER BY SoPhieu DESC;
GO

/* ---------- 4. Linh kiá»‡n tiÃªu thá»¥ nhiá»u nháº¥t ---------- */
SELECT TOP 10
    p.PartCode                       AS MaLinhKien,
    p.PartName                       AS TenLinhKien,
    SUM(tp.Quantity)                 AS SoLuongDaXuat,
    SUM(tp.LineTotal)                AS DoanhThuLinhKien,
    SUM(tp.Quantity * p.PurchasePrice) AS GiaVon,
    SUM(tp.LineTotal) - SUM(tp.Quantity * p.PurchasePrice) AS LoiNhuanGop
FROM dbo.TicketParts tp
JOIN dbo.SpareParts p ON p.PartId = tp.PartId
GROUP BY p.PartCode, p.PartName
ORDER BY SoLuongDaXuat DESC;
GO

/* ---------- 5. Linh kiá»‡n dÆ°á»›i má»©c tá»“n tá»‘i thiá»ƒu (cáº£nh bÃ¡o) ---------- */
SELECT
    p.PartCode                       AS MaLinhKien,
    p.PartName                       AS TenLinhKien,
    c.CategoryName                   AS NhomLinhKien,
    p.StockQuantity                  AS TonHienTai,
    p.MinStockLevel                  AS TonToiThieu,
    p.MinStockLevel - p.StockQuantity AS CanNhapThem
FROM dbo.SpareParts p
JOIN dbo.SparePartCategories c ON c.CategoryId = p.CategoryId
WHERE p.IsActive = 1
  AND p.StockQuantity <= p.MinStockLevel
ORDER BY CanNhapThem DESC;
GO

/* ---------- 6. Hiá»‡u suáº¥t ká»¹ thuáº­t viÃªn ---------- */
SELECT
    u.FullName                       AS KyThuatVien,
    COUNT(t.TicketId)                AS TongPhieu,
    SUM(CASE WHEN t.Status IN ('COMPLETED','DELIVERED') THEN 1 ELSE 0 END) AS PhieuHoanTat,
    SUM(CASE WHEN t.Status = 'CANCELLED' THEN 1 ELSE 0 END)                AS PhieuHuy,
    AVG(CASE WHEN t.CompletedAt IS NOT NULL
             THEN DATEDIFF(HOUR, t.ReceivedAt, t.CompletedAt) END)         AS GioXuLyTrungBinh,
    SUM(CASE WHEN t.IsWarrantyRepair = 1 THEN 1 ELSE 0 END)                AS PhieuBaoHanh
FROM dbo.Users u
LEFT JOIN dbo.RepairTickets t ON t.TechnicianUserId = u.UserId
WHERE u.RoleId = (SELECT RoleId FROM dbo.Roles WHERE RoleCode = 'TECHNICIAN')
GROUP BY u.FullName
ORDER BY PhieuHoanTat DESC;
GO

/* ---------- 7. Doanh thu theo loáº¡i dá»‹ch vá»¥ ---------- */
SELECT
    s.ServiceName                    AS LoaiDichVu,
    COUNT(t.TicketId)                AS SoPhieu,
    SUM(ISNULL(i.TotalAmount, 0))    AS DoanhThu
FROM dbo.ServiceTypes s
LEFT JOIN dbo.RepairTickets t ON t.ServiceTypeId = s.ServiceTypeId
LEFT JOIN dbo.Invoices i      ON i.TicketId = t.TicketId AND i.PaymentStatus = 'PAID'
GROUP BY s.ServiceName
ORDER BY DoanhThu DESC;
GO

/* ---------- 8. Phiáº¿u báº£o hÃ nh sáº¯p háº¿t háº¡n trong 30 ngÃ y ---------- */
SELECT
    w.WarrantyCode                   AS MaBaoHanh,
    c.FullName                       AS KhachHang,
    c.Phone                          AS SoDienThoai,
    d.DeviceType + N' ' + ISNULL(d.Brand, N'') AS ThietBi,
    w.StartDate                      AS NgayBatDau,
    w.EndDate                        AS NgayHetHan,
    DATEDIFF(DAY, GETDATE(), w.EndDate) AS ConLaiNgay
FROM dbo.Warranties w
JOIN dbo.Customers c ON c.CustomerId = w.CustomerId
JOIN dbo.Devices   d ON d.DeviceId   = w.DeviceId
WHERE w.Status = 'ACTIVE'
  AND w.EndDate BETWEEN CAST(GETDATE() AS DATE) AND DATEADD(DAY, 30, CAST(GETDATE() AS DATE))
ORDER BY ConLaiNgay;
GO

/* ---------- 9. KhÃ¡ch hÃ ng thÃ¢n thiáº¿t (chi nhiá»u nháº¥t) ---------- */
SELECT TOP 10
    c.CustomerCode                   AS MaKhachHang,
    c.FullName                       AS TenKhachHang,
    c.Phone                          AS SoDienThoai,
    COUNT(DISTINCT t.TicketId)       AS SoLanSua,
    SUM(ISNULL(i.TotalAmount, 0))    AS TongChiTieu,
    MAX(t.ReceivedAt)                AS LanGanNhat
FROM dbo.Customers c
JOIN dbo.RepairTickets t ON t.CustomerId = c.CustomerId
LEFT JOIN dbo.Invoices i ON i.TicketId = t.TicketId AND i.PaymentStatus = 'PAID'
GROUP BY c.CustomerCode, c.FullName, c.Phone
ORDER BY TongChiTieu DESC;
GO

/* ---------- 10. Äá»‘i soÃ¡t: linh kiá»‡n Ä‘Ã£ xuáº¥t so vá»›i tiá»n Ä‘Ã£ thu ---------- */
SELECT
    t.TicketCode                     AS MaPhieu,
    t.Status                         AS TrangThai,
    ISNULL(SUM(tp.LineTotal), 0)     AS TienLinhKienTheoPhieu,
    ISNULL(i.PartsCost, 0)           AS TienLinhKienTrenHoaDon,
    ISNULL(SUM(tp.LineTotal), 0) - ISNULL(i.PartsCost, 0) AS ChenhLech
FROM dbo.RepairTickets t
LEFT JOIN dbo.TicketParts tp ON tp.TicketId = t.TicketId
LEFT JOIN dbo.Invoices i     ON i.TicketId  = t.TicketId
GROUP BY t.TicketCode, t.Status, i.PartsCost
HAVING ISNULL(SUM(tp.LineTotal), 0) <> ISNULL(i.PartsCost, 0)
ORDER BY ABS(ISNULL(SUM(tp.LineTotal), 0) - ISNULL(i.PartsCost, 0)) DESC;
GO


/* ===== END: database\queries\bao_cao_thong_ke.sql ===== */

