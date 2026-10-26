/* ================================================================
   QLDACNTT - TOAN BO HE THONG CSDL REPAIRSHOPDB (MASTER SQL)
   Phien ban: Chuan hoa 100% Tieng Viet UTF-8 & Du lieu thuc te
   Do an: He thong quan ly tong the cho cua hang sua chua - LV33-001
   Nhom 11 - Lop 23DTHC6
   Thanh vien:
     - Nguyen Viet Lam (Nhom truong - Backend & Web Admin)
     - Tran Ngoc Loi (Phu trach Database & Quy trinh)
     - Nguyen Dai Ky (Phu trach Testing & Tai lieu)
   ================================================================ */

/* =====================================================================
   LV33-001 — Hệ thống quản lý tổng thể cho cửa hàng sửa chữa
   Script 01: Tạo cơ sở dữ liệu
   Người viết: Trần Ngọc Lợi (Database)
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

/* ---------- 2. Khach hang ---------- */
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

/* ---------- 3. Nguoi dung he thong ---------- */
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
    CustomerId      INT           NULL,
    CONSTRAINT FK_Users_Roles     FOREIGN KEY (RoleId) REFERENCES dbo.Roles(RoleId),
    CONSTRAINT FK_Users_Customers FOREIGN KEY (CustomerId) REFERENCES dbo.Customers(CustomerId)
);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Users_RoleId' AND object_id=OBJECT_ID('dbo.Users'))
    CREATE INDEX IX_Users_RoleId ON dbo.Users(RoleId);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Users_CustomerId' AND object_id=OBJECT_ID('dbo.Users'))
    CREATE INDEX IX_Users_CustomerId ON dbo.Users(CustomerId);
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

/* ---------- 14. Bang thanh toan hoa don ---------- */
IF OBJECT_ID('dbo.Payments') IS NULL
CREATE TABLE dbo.Payments (
    PaymentId           INT IDENTITY(1,1) PRIMARY KEY,
    InvoiceId           INT            NOT NULL,
    Amount              DECIMAL(18,2)  NOT NULL,
    PaymentMethod       VARCHAR(20)    NOT NULL, -- CASH, TRANSFER, VNPAY, MOMO
    ReceivedByUserId    INT            NOT NULL,
    PaidAt              DATETIME2      NOT NULL DEFAULT SYSDATETIME(),
    Note                NVARCHAR(500)  NULL,
    CONSTRAINT FK_Payments_Invoices FOREIGN KEY (InvoiceId) REFERENCES dbo.Invoices(InvoiceId),
    CONSTRAINT FK_Payments_Users    FOREIGN KEY (ReceivedByUserId) REFERENCES dbo.Users(UserId),
    CONSTRAINT CK_Payments_Method   CHECK (PaymentMethod IN ('CASH','TRANSFER','VNPAY','MOMO')),
    CONSTRAINT CK_Payments_Amount   CHECK (Amount > 0)
);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Payments_InvoiceId' AND object_id=OBJECT_ID('dbo.Payments'))
    CREATE INDEX IX_Payments_InvoiceId ON dbo.Payments(InvoiceId);
GO

PRINT 'Da tao xong 14 bang cua RepairShopDB.';
GO



/* =====================================================================
   LV33-001 - CAC VIEWS BAO CAO & THONG KE CSDL
   ===================================================================== */
USE RepairShopDB;
GO

-- 1. View Canh bao ton kho toi thieu
CREATE OR ALTER VIEW dbo.v_CanhBaoTonKho
AS
SELECT 
    p.PartId,
    p.PartCode,
    p.PartName,
    c.CategoryName,
    p.StockQuantity,
    p.MinStockLevel,
    p.PurchasePrice,
    p.SellingPrice,
    (p.MinStockLevel - p.StockQuantity) AS QuantityToRestock,
    CASE 
        WHEN p.StockQuantity = 0 THEN N'HET_HANG'
        WHEN p.StockQuantity < p.MinStockLevel THEN N'DUOI_MUC_CANH_BAO'
        WHEN p.StockQuantity = p.MinStockLevel THEN N'CHAM_MUC_CANH_BAO'
        ELSE N'AN_TOAN'
    END AS StockStatus
FROM dbo.SpareParts p
JOIN dbo.SparePartCategories c ON p.CategoryId = c.CategoryId
WHERE p.IsActive = 1 AND p.StockQuantity <= p.MinStockLevel;
GO

-- 2. View Bao cao Doanh thu theo Tho (Ky thuat vien)
CREATE OR ALTER VIEW dbo.v_BaoCaoDoanhThuTheoTho
AS
SELECT 
    u.UserId                                                    AS MaTho,
    u.Username                                                  AS TenDangNhap,
    u.FullName                                                  AS TenKyThuatVien,
    u.Phone                                                     AS SoDienThoai,
    COUNT(t.TicketId)                                           AS TongSoPhieuGiao,
    SUM(CASE WHEN t.Status IN ('COMPLETED', 'DELIVERED', 'PAID') THEN 1 ELSE 0 END) 
                                                                AS SoPhieuHoanTat,
    SUM(CASE WHEN t.Status = 'CANCELLED' THEN 1 ELSE 0 END)     AS SoPhieuHuy,
    SUM(CASE WHEN i.PaymentStatus = 'PAID' THEN 1 ELSE 0 END)   AS SoHoaDonDaThuTien,
    ISNULL(SUM(CASE WHEN i.PaymentStatus = 'PAID' THEN i.LaborCost ELSE 0 END), 0)
                                                                AS DoanhThuTienCong,
    ISNULL(SUM(CASE WHEN i.PaymentStatus = 'PAID' THEN i.PartsCost ELSE 0 END), 0)
                                                                AS DoanhThuLinhKien,
    ISNULL(SUM(CASE WHEN i.PaymentStatus = 'PAID' THEN i.DiscountAmount ELSE 0 END), 0)
                                                                AS TongTienGiamGia,
    ISNULL(SUM(CASE WHEN i.PaymentStatus = 'PAID' THEN i.TotalAmount ELSE 0 END), 0)
                                                                AS TongDoanhThuThucThu,
    CASE 
        WHEN SUM(CASE WHEN i.PaymentStatus = 'PAID' THEN 1 ELSE 0 END) > 0 
        THEN CAST(SUM(CASE WHEN i.PaymentStatus = 'PAID' THEN i.TotalAmount ELSE 0 END) 
             / SUM(CASE WHEN i.PaymentStatus = 'PAID' THEN 1 ELSE 0 END) AS DECIMAL(18,2))
        ELSE 0 
    END                                                         AS DoanhThuTrungBinhMoiPhieu,
    CAST(
        CASE 
            WHEN COUNT(t.TicketId) > 0 
            THEN (SUM(CASE WHEN t.Status IN ('COMPLETED', 'DELIVERED', 'PAID') THEN 1.0 ELSE 0.0 END) / COUNT(t.TicketId)) * 100.0
            ELSE 0.0 
        END AS DECIMAL(5,2)
    )                                                           AS TyLeHoanThanhPhanTram,
    CAST(
        ISNULL(AVG(CASE 
            WHEN t.Status IN ('COMPLETED', 'DELIVERED', 'PAID') AND t.CompletedAt IS NOT NULL 
            THEN DATEDIFF(MINUTE, t.ReceivedAt, t.CompletedAt) / 60.0 
        END), 0) AS DECIMAL(6,2)
    )                                                           AS ThoiGianXuLyTrungBinhGio,
    SUM(CASE WHEN t.IsWarrantyRepair = 1 THEN 1 ELSE 0 END)     AS SoPhieuBaoHanhLai
FROM dbo.Users u
JOIN dbo.Roles r ON u.RoleId = r.RoleId AND r.RoleCode = 'TECHNICIAN'
LEFT JOIN dbo.RepairTickets t ON t.TechnicianUserId = u.UserId
LEFT JOIN dbo.Invoices i ON i.TicketId = t.TicketId
GROUP BY u.UserId, u.Username, u.FullName, u.Phone;
GO

-- 3. View Bao cao Doanh thu theo Dich vu
CREATE OR ALTER VIEW dbo.v_BaoCaoDoanhThuTheoDichVu
AS
WITH TongDoanhThuHeThong AS (
    SELECT ISNULL(SUM(TotalAmount), 0) AS TongToanCuaHang
    FROM dbo.Invoices
    WHERE PaymentStatus = 'PAID'
)
SELECT 
    s.ServiceTypeId                                             AS MaDichVu,
    s.ServiceCode                                               AS MaCodeDichVu,
    s.ServiceName                                               AS TenLoaiDichVu,
    s.LaborCost                                                 AS DonGiaCongNiemYet,
    s.WarrantyDays                                              AS HanBaoHanhMacDinh,
    COUNT(t.TicketId)                                           AS TongSoPhieuYeuCau,
    SUM(CASE WHEN t.Status IN ('COMPLETED', 'DELIVERED', 'PAID') THEN 1 ELSE 0 END) 
                                                                AS SoPhieuHoanThanh,
    SUM(CASE WHEN i.PaymentStatus = 'PAID' THEN 1 ELSE 0 END)   AS SoHoaDonThanhToan,
    ISNULL(SUM(CASE WHEN i.PaymentStatus = 'PAID' THEN i.LaborCost ELSE 0 END), 0)
                                                                AS DoanhThuTienCong,
    ISNULL(SUM(CASE WHEN i.PaymentStatus = 'PAID' THEN i.PartsCost ELSE 0 END), 0)
                                                                AS DoanhThuLinhKien,
    ISNULL(SUM(CASE WHEN i.PaymentStatus = 'PAID' THEN i.TotalAmount ELSE 0 END), 0)
                                                                AS TongDoanhThuDichVu,
    CASE 
        WHEN SUM(CASE WHEN i.PaymentStatus = 'PAID' THEN 1 ELSE 0 END) > 0 
        THEN CAST(SUM(CASE WHEN i.PaymentStatus = 'PAID' THEN i.TotalAmount ELSE 0 END) 
             / SUM(CASE WHEN i.PaymentStatus = 'PAID' THEN 1 ELSE 0 END) AS DECIMAL(18,2))
        ELSE 0 
    END                                                         AS DoanhThuTrungBinhMoiLuot,
    CASE 
        WHEN (SELECT TongToanCuaHang FROM TongDoanhThuHeThong) > 0 
        THEN CAST(ISNULL(SUM(CASE WHEN i.PaymentStatus = 'PAID' THEN i.TotalAmount ELSE 0 END), 0) 
             / (SELECT TongToanCuaHang FROM TongDoanhThuHeThong) * 100.0 AS DECIMAL(5,2))
        ELSE 0 
    END                                                         AS TyTrongDongGopPhanTram
FROM dbo.ServiceTypes s
LEFT JOIN dbo.RepairTickets t ON t.ServiceTypeId = s.ServiceTypeId
LEFT JOIN dbo.Invoices i ON i.TicketId = t.TicketId
GROUP BY s.ServiceTypeId, s.ServiceCode, s.ServiceName, s.LaborCost, s.WarrantyDays;
GO

-- 4. View Linh kien ban chay
CREATE OR ALTER VIEW dbo.v_LinhKienBanChay
AS
WITH ThongKeTieuThu AS (
    SELECT 
        tx.PartId,
        SUM(CASE WHEN tx.TransactionType = 'OUT'    THEN tx.Quantity ELSE 0 END) AS TongXuat,
        SUM(CASE WHEN tx.TransactionType = 'IN'     THEN tx.Quantity ELSE 0 END) AS TongNhap,
        SUM(CASE WHEN tx.TransactionType = 'RETURN' THEN tx.Quantity ELSE 0 END) AS TongHoanTra,
        COUNT(DISTINCT CASE WHEN tx.TransactionType = 'OUT' THEN tx.TicketId END) AS SoPhieuSuDung,
        MAX(CASE WHEN tx.TransactionType = 'OUT' THEN tx.TransactionAt END)       AS LanXuatGanNhat,
        MIN(CASE WHEN tx.TransactionType = 'IN'  THEN tx.TransactionAt END)       AS LanNhapDauTien
    FROM dbo.StockTransactions tx
    GROUP BY tx.PartId
),
TongDoanhThuHeThing AS (
    SELECT ISNULL(SUM(tp.LineTotal), 0) AS TongToanCuaHang
    FROM dbo.TicketParts tp
    JOIN dbo.RepairTickets t ON t.TicketId = tp.TicketId
    WHERE t.Status IN ('COMPLETED','DELIVERED','PAID')
)
SELECT 
    p.PartId,
    p.PartCode                                                  AS MaLinhKien,
    p.PartName                                                  AS TenLinhKien,
    c.CategoryName                                              AS NhomLinhKien,
    p.StockQuantity                                             AS TonHienTai,
    p.MinStockLevel                                             AS TonToiThieu,
    ISNULL(tt.TongXuat, 0)                                     AS TongSoLuongBan,
    ISNULL(tt.TongHoanTra, 0)                                  AS SoLuongHoanTra,
    ISNULL(tt.TongXuat, 0) - ISNULL(tt.TongHoanTra, 0)        AS SoLuongBanThuan,
    ISNULL(tt.SoPhieuSuDung, 0)                                AS SoPhieuSuDung,
    ISNULL(
        (SELECT SUM(tp2.LineTotal) 
         FROM dbo.TicketParts tp2 
         JOIN dbo.RepairTickets t2 ON t2.TicketId = tp2.TicketId 
         WHERE tp2.PartId = p.PartId 
           AND t2.Status IN ('COMPLETED','DELIVERED','PAID')
        ), 0)                                                   AS DoanhThuThucTe,
    ISNULL(
        (SELECT SUM(tp2.LineTotal) - (SUM(tp2.Quantity) * p.PurchasePrice)
         FROM dbo.TicketParts tp2 
         JOIN dbo.RepairTickets t2 ON t2.TicketId = tp2.TicketId 
         WHERE tp2.PartId = p.PartId 
           AND t2.Status IN ('COMPLETED','DELIVERED','PAID')
        ), 0)                                                   AS LoiNhuanGop,
    CASE 
        WHEN (SELECT TongToanCuaHang FROM TongDoanhThuHeThing) > 0 
        THEN CAST(
            ISNULL(
                (SELECT SUM(tp2.LineTotal) 
                 FROM dbo.TicketParts tp2 
                 JOIN dbo.RepairTickets t2 ON t2.TicketId = tp2.TicketId 
                 WHERE tp2.PartId = p.PartId 
                   AND t2.Status IN ('COMPLETED','DELIVERED','PAID')
                ), 0) 
            / (SELECT TongToanCuaHang FROM TongDoanhThuHeThing) * 100.0 
        AS DECIMAL(5,2))
        ELSE 0 
    END                                                         AS TyTrongDoanhThuPhanTram,
    CASE 
        WHEN ISNULL((SELECT SUM(tp2.LineTotal) FROM dbo.TicketParts tp2 JOIN dbo.RepairTickets t2 ON t2.TicketId = tp2.TicketId WHERE tp2.PartId = p.PartId AND t2.Status IN ('COMPLETED','DELIVERED','PAID')), 0) > 0
        THEN CAST(
            ISNULL((SELECT SUM(tp2.LineTotal) - (SUM(tp2.Quantity) * p.PurchasePrice) FROM dbo.TicketParts tp2 JOIN dbo.RepairTickets t2 ON t2.TicketId = tp2.TicketId WHERE tp2.PartId = p.PartId AND t2.Status IN ('COMPLETED','DELIVERED','PAID')), 0)
            / (SELECT SUM(tp2.LineTotal) FROM dbo.TicketParts tp2 JOIN dbo.RepairTickets t2 ON t2.TicketId = tp2.TicketId WHERE tp2.PartId = p.PartId AND t2.Status IN ('COMPLETED','DELIVERED','PAID')) * 100.0
        AS DECIMAL(5,2))
        ELSE 0
    END                                                         AS TyLeLoiNhuanGopPhanTram,
    CAST(
        CASE 
            WHEN (p.StockQuantity + ISNULL(tt.TongXuat, 0)) > 0 
            THEN ISNULL(tt.TongXuat, 0) * 1.0 / ((p.StockQuantity + (p.StockQuantity + ISNULL(tt.TongXuat, 0))) / 2.0)
            ELSE 0 
        END AS DECIMAL(6,2)
    )                                                           AS VongQuayTonKho,
    p.SellingPrice                                              AS GiaBan,
    p.PurchasePrice                                             AS GiaNhap,
    CASE 
        WHEN ISNULL(tt.TongXuat, 0) >= 5 THEN N'A - Bán chạy nhất'
        WHEN ISNULL(tt.TongXuat, 0) >= 2 THEN N'B - Bán ổn định'
        ELSE N'C - Bán chậm'
    END                                                         AS PhanLoaiABC,
    tt.LanXuatGanNhat                                           AS LanBanGanNhat
FROM dbo.SpareParts p
JOIN dbo.SparePartCategories c ON p.CategoryId = c.CategoryId
LEFT JOIN ThongKeTieuThu tt ON tt.PartId = p.PartId
WHERE p.IsActive = 1;
GO

-- 5. View Linh kien ton lau
CREATE OR ALTER VIEW dbo.v_LinhKienTonLau
AS
WITH BienDongCuoi AS (
    SELECT 
        tx.PartId,
        MAX(tx.TransactionAt)                                       AS LanBienDongCuoi,
        MAX(CASE WHEN tx.TransactionType = 'OUT' THEN tx.TransactionAt END) AS LanXuatCuoi,
        MAX(CASE WHEN tx.TransactionType = 'IN'  THEN tx.TransactionAt END) AS LanNhapCuoi,
        COUNT(CASE WHEN tx.TransactionType = 'OUT' THEN 1 END)      AS SoLanXuat,
        COUNT(CASE WHEN tx.TransactionType = 'IN'  THEN 1 END)      AS SoLanNhap
    FROM dbo.StockTransactions tx
    GROUP BY tx.PartId
)
SELECT 
    p.PartId,
    p.PartCode                                                  AS MaLinhKien,
    p.PartName                                                  AS TenLinhKien,
    c.CategoryName                                              AS NhomLinhKien,
    p.StockQuantity                                             AS TonKhoHienTai,
    p.MinStockLevel                                             AS DinhMucToiThieu,
    p.SellingPrice                                              AS GiaNiemYet,
    p.PurchasePrice                                             AS GiaVonNhap,
    CAST(p.StockQuantity * p.PurchasePrice AS DECIMAL(18,2))    AS GiaTriTonKhoGiaVon,
    ISNULL(bd.LanNhapCuoi, p.CreatedAt)                         AS NgayNhapCuoiCung,
    bd.LanXuatCuoi                                              AS NgayXuatCuoiCung,
    DATEDIFF(DAY, ISNULL(bd.LanXuatCuoi, ISNULL(bd.LanNhapCuoi, p.CreatedAt)), GETDATE()) 
                                                                AS SoNgayKhongPhatSinhXuat,
    DATEDIFF(DAY, ISNULL(bd.LanNhapCuoi, p.CreatedAt), GETDATE()) 
                                                                AS SoNgayLuuKho,
    CASE 
        WHEN p.StockQuantity = 0 THEN N'HẾT HÀNG'
        WHEN DATEDIFF(DAY, ISNULL(bd.LanXuatCuoi, ISNULL(bd.LanNhapCuoi, p.CreatedAt)), GETDATE()) >= 90 THEN N'NGUY CƠ ĐỌNG VỐN CAO (>=90 ngày)'
        WHEN DATEDIFF(DAY, ISNULL(bd.LanXuatCuoi, ISNULL(bd.LanNhapCuoi, p.CreatedAt)), GETDATE()) >= 60 THEN N'CẢNH BÁO TỒN LÂU (60-89 ngày)'
        WHEN DATEDIFF(DAY, ISNULL(bd.LanXuatCuoi, ISNULL(bd.LanNhapCuoi, p.CreatedAt)), GETDATE()) >= 30 THEN N'LƯU KHO TRUNG BÌNH (30-59 ngày)'
        ELSE N'BÌNH THƯỜNG'
    END                                                         AS MucDoTonLau,
    CASE 
        WHEN p.StockQuantity = 0 THEN N'Cần tạo đơn đặt hàng bổ sung'
        WHEN DATEDIFF(DAY, ISNULL(bd.LanXuatCuoi, ISNULL(bd.LanNhapCuoi, p.CreatedAt)), GETDATE()) >= 90 THEN N'Giảm giá 15-20% hoặc thanh lý thu hồi vốn'
        WHEN DATEDIFF(DAY, ISNULL(bd.LanXuatCuoi, ISNULL(bd.LanNhapCuoi, p.CreatedAt)), GETDATE()) >= 60 THEN N'Chạy chương trình khuyến mãi kích cầu'
        WHEN DATEDIFF(DAY, ISNULL(bd.LanXuatCuoi, ISNULL(bd.LanNhapCuoi, p.CreatedAt)), GETDATE()) >= 30 THEN N'Theo dõi chặt, ngưng nhập thêm đợt mới'
        ELSE N'Tiếp tục duy trì'
    END                                                         AS DeXuatXuLy
FROM dbo.SpareParts p
JOIN dbo.SparePartCategories c ON p.CategoryId = c.CategoryId
LEFT JOIN BienDongCuoi bd ON bd.PartId = p.PartId
WHERE p.IsActive = 1;
GO


/* =====================================================================
   LV33-001 - He thong quan ly tong the cho cua hang sua chua TechCare
   DULIEU CHUAN: Du lieu thuc te da duoc chuan hoa UTF-8 tieng Viet
   Nhom 11 - Lop 23DTHC6
   ===================================================================== */

USE RepairShopDB;
GO
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
SET NOCOUNT ON;
GO

BEGIN TRANSACTION;

-- Xoa du lieu cu theo thu tu rang buoc FK
DELETE FROM dbo.Payments;
DELETE FROM dbo.TicketStatusHistory;
DELETE FROM dbo.TicketParts;
DELETE FROM dbo.StockTransactions;
DELETE FROM dbo.Warranties;
DELETE FROM dbo.Invoices;
DELETE FROM dbo.RepairTickets;
DELETE FROM dbo.Devices;
DELETE FROM dbo.Users;
DELETE FROM dbo.Customers;
DELETE FROM dbo.SpareParts;
DELETE FROM dbo.SparePartCategories;
DELETE FROM dbo.ServiceTypes;
DELETE FROM dbo.Roles;
GO

-- ----------------------------------------------------
-- Bang: dbo.Roles (4 rows)
-- ----------------------------------------------------
SET IDENTITY_INSERT dbo.[Roles] ON;
INSERT INTO dbo.[Roles] ([RoleId], [RoleCode], [RoleName], [Description], [IsActive], [CreatedAt]) VALUES (1, N'ADMIN', N'Quáº£n trá»‹ viÃªn', N'Chá»§ cá»­a hÃ ng / Quáº£n lÃ½ há»‡ thá»‘ng, toÃ n quyá»n quáº£n trá»‹', 1, '2026-10-06 13:11:36.782');
INSERT INTO dbo.[Roles] ([RoleId], [RoleCode], [RoleName], [Description], [IsActive], [CreatedAt]) VALUES (2, N'STAFF', N'NhÃ¢n viÃªn quáº§y', N'Tiáº¿p nháº­n thiáº¿t bá»‹, láº­p phiáº¿u tiáº¿p nháº­n, thu ngÃ¢n hÃ³a Ä‘Æ¡n', 1, '2026-10-06 13:11:36.782');
INSERT INTO dbo.[Roles] ([RoleId], [RoleCode], [RoleName], [Description], [IsActive], [CreatedAt]) VALUES (3, N'TECHNICIAN', N'Ká»¹ thuáº­t viÃªn', N'Cháº©n Ä‘oÃ¡n, sá»­a chá»¯a pháº§n cá»©ng/pháº§n má»m, xuáº¥t kho linh kiá»‡n', 1, '2026-10-06 13:11:36.782');
INSERT INTO dbo.[Roles] ([RoleId], [RoleCode], [RoleName], [Description], [IsActive], [CreatedAt]) VALUES (4, N'CUSTOMER', N'KhÃ¡ch hÃ ng', N'Tra cá»©u tiáº¿n Ä‘á»™ sá»­a chá»¯a mÃ¡y vÃ  sá»• báº£o hÃ nh Ä‘iá»‡n tá»­', 1, '2026-10-06 13:11:36.782');
SET IDENTITY_INSERT dbo.[Roles] OFF;
GO

-- ----------------------------------------------------
-- Bang: dbo.Customers (29 rows)
-- ----------------------------------------------------
SET IDENTITY_INSERT dbo.[Customers] ON;
INSERT INTO dbo.[Customers] ([CustomerId], [CustomerCode], [FullName], [Phone], [Email], [Address], [Note], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (1, N'KH000001', N'Nguyễn Thành Nam', N'0982345678', N'nam.nguyen@gmail.com', N'142 Võ Văn Tần, Phường 6, Quận 3, TP.HCM', N'Khách hàng VIP doanh nghiệp', 1, '2026-10-05 09:05:12.566', NULL);
INSERT INTO dbo.[Customers] ([CustomerId], [CustomerCode], [FullName], [Phone], [Email], [Address], [Note], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (2, N'KH000002', N'Lê Hoàng Phúc', N'0903124567', N'phuc.le@outlook.com', N'475A Điện Biên Phủ, Phường 25, Bình Thạnh, TP.HCM', N'Giảng viên ĐH HUTECH', 1, '2026-10-07 09:05:12.566', NULL);
INSERT INTO dbo.[Customers] ([CustomerId], [CustomerCode], [FullName], [Phone], [Email], [Address], [Note], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (3, N'KH000003', N'Đặng Minh Tâm', N'0918765432', N'tam.dang@fpt.edu.vn', N'280 An Dương Vương, Phường 4, Quận 5, TP.HCM', N'Lập trình viên Senior', 1, '2026-10-10 09:05:12.566', NULL);
INSERT INTO dbo.[Customers] ([CustomerId], [CustomerCode], [FullName], [Phone], [Email], [Address], [Note], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (4, N'KH000004', N'Võ Hoài Thương', N'0976543210', N'thuong.vo@gmail.com', N'120 Hai Bà Trưng, Phường Đa Kao, Quận 1, TP.HCM', N'Thiết kế đồ họa Studio', 1, '2026-10-13 09:05:12.566', NULL);
INSERT INTO dbo.[Customers] ([CustomerId], [CustomerCode], [FullName], [Phone], [Email], [Address], [Note], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (5, N'KH000005', N'Phan Thanh Tùng', N'0938889900', N'tung.phan@techcorp.vn', N'68 Nguyễn Huệ, Phường Bến Nghé, Quận 1, TP.HCM', N'Khách sửa máy tính PC gaming', 1, '2026-10-15 09:05:12.566', NULL);
INSERT INTO dbo.[Customers] ([CustomerId], [CustomerCode], [FullName], [Phone], [Email], [Address], [Note], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (6, N'KH000006', N'Hoàng Thị Mai Anh', N'0908112233', N'maianh.hoang@gmail.com', N'354 Lê Văn Sỹ, Phường 14, Quận 3, TP.HCM', N'Khách hàng thân thiết', 1, '2026-10-17 09:05:12.566', NULL);
INSERT INTO dbo.[Customers] ([CustomerId], [CustomerCode], [FullName], [Phone], [Email], [Address], [Note], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (7, N'KH000007', N'Trần Đình Trọng', N'0919223344', N'trong.td@gmail.com', N'89 Phan Xích Long, Phường 2, Phú Nhuận, TP.HCM', N'Khách sửa iPad đồ họa', 1, '2026-10-19 09:05:12.566', NULL);
INSERT INTO dbo.[Customers] ([CustomerId], [CustomerCode], [FullName], [Phone], [Email], [Address], [Note], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (8, N'KH000008', N'Bùi Quang Huy', N'0966554433', N'huy.bui@hutech.edu.vn', N'31/2 Ung Văn Khiêm, Phường 25, Bình Thạnh, TP.HCM', N'Sinh viên Khoa CNTT', 1, '2026-10-21 09:05:12.566', NULL);
INSERT INTO dbo.[Customers] ([CustomerId], [CustomerCode], [FullName], [Phone], [Email], [Address], [Note], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (9, N'KH000009', N'Đỗ Phương Thảo', N'0902998877', N'thao.dophuong@gmail.com', N'52 Nguyễn Thị Minh Khai, Quận 1, TP.HCM', N'Khách hàng thay pin iPhone', 1, '2026-10-22 09:05:12.566', NULL);
INSERT INTO dbo.[Customers] ([CustomerId], [CustomerCode], [FullName], [Phone], [Email], [Address], [Note], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (10, N'KH000010', N'Ngô Gia Bảo', N'0913445566', N'bao.ngo@gmail.com', N'215 Hồng Bàng, Phường 11, Quận 5, TP.HCM', N'Khách sửa laptop văn phòng', 1, '2026-10-24 09:05:12.566', NULL);
INSERT INTO dbo.[Customers] ([CustomerId], [CustomerCode], [FullName], [Phone], [Email], [Address], [Note], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (11, N'KH000011', N'Vũ Minh Tuấn', N'0912348899', N'tuan.vu@gmail.com', N'72 Lê Thánh Tôn, Bến Nghé, Quận 1, TP.HCM', N'Khách hàng thân thiết', 1, '2026-10-07 10:01:02.706', NULL);
INSERT INTO dbo.[Customers] ([CustomerId], [CustomerCode], [FullName], [Phone], [Email], [Address], [Note], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (12, N'KH000012', N'Đặng Thu Thảo', N'0987112244', N'thao.dang@vietcombank.com.vn', N'11 Bến Chương Dương, Cầu Kho, Quận 1, TP.HCM', N'Chuyên viên Vietcombank', 1, '2026-10-09 10:01:02.706', NULL);
INSERT INTO dbo.[Customers] ([CustomerId], [CustomerCode], [FullName], [Phone], [Email], [Address], [Note], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (13, N'KH000013', N'Lê Tấn Phát', N'0908776655', N'phat.le@fpt.com', N'29 Lê Duẩn, Bến Nghé, Quận 1, TP.HCM', N'Kỹ sư hệ thống FPT', 1, '2026-10-11 10:01:02.706', NULL);
INSERT INTO dbo.[Customers] ([CustomerId], [CustomerCode], [FullName], [Phone], [Email], [Address], [Note], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (14, N'KH000014', N'Phạm Ngọc Lan', N'0932115599', N'lan.pham@techcombank.com.vn', N'198 Nguyễn Thị Minh Khai, Phường 6, Quận 3, TP.HCM', N'Quản lý Techcombank', 1, '2026-10-12 10:01:02.706', NULL);
INSERT INTO dbo.[Customers] ([CustomerId], [CustomerCode], [FullName], [Phone], [Email], [Address], [Note], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (15, N'KH000015', N'Nguyễn Hữu Trí', N'0978665511', N'tri.nguyenhuu@gmail.com', N'45 Trương Định, Phường 6, Quận 3, TP.HCM', N'Content Creator YouTube', 1, '2026-10-14 10:01:02.706', NULL);
INSERT INTO dbo.[Customers] ([CustomerId], [CustomerCode], [FullName], [Phone], [Email], [Address], [Note], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (16, N'KH000016', N'Trần Bảo Long', N'0919334422', N'long.tranbao@gmail.com', N'209 Nam Kỳ Khởi Nghĩa, Phường 7, Quận 3, TP.HCM', N'Kiến trúc sư xây dựng', 1, '2026-10-16 10:01:02.706', NULL);
INSERT INTO dbo.[Customers] ([CustomerId], [CustomerCode], [FullName], [Phone], [Email], [Address], [Note], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (17, N'KH000017', N'Huỳnh Quốc Dũng', N'0968221177', N'dung.hq@gameloft.com', N'80 Nguyễn Huệ, Phường Bến Nghé, Quận 1, TP.HCM', N'Game Designer Gameloft', 1, '2026-10-17 10:01:02.706', NULL);
INSERT INTO dbo.[Customers] ([CustomerId], [CustomerCode], [FullName], [Phone], [Email], [Address], [Note], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (18, N'KH000018', N'Đoàn Thanh Hương', N'0909554488', N'huong.doan@gmail.com', N'150 Nguyễn Đình Chiểu, Phường 6, Quận 3, TP.HCM', N'Chủ chuỗi cửa hàng hoa tươi', 1, '2026-10-18 10:01:02.706', NULL);
INSERT INTO dbo.[Customers] ([CustomerId], [CustomerCode], [FullName], [Phone], [Email], [Address], [Note], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (19, N'KH000019', N'Hoàng Gia Huy', N'0989332211', N'huy.hoanggia@gmail.com', N'256 Xô Viết Nghệ Tĩnh, Phường 21, Bình Thạnh, TP.HCM', N'Sinh viên ĐH Ngoại Thương', 1, '2026-10-19 10:01:02.706', NULL);
INSERT INTO dbo.[Customers] ([CustomerId], [CustomerCode], [FullName], [Phone], [Email], [Address], [Note], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (20, N'KH000020', N'Đinh Văn Sơn', N'0914667788', N'son.dinhvan@shopee.vn', N'56 Hoàng Diệu, Phường 12, Quận 4, TP.HCM', N'Quản lý sàn TMĐT Shopee', 1, '2026-10-20 10:01:02.706', NULL);
INSERT INTO dbo.[Customers] ([CustomerId], [CustomerCode], [FullName], [Phone], [Email], [Address], [Note], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (21, N'KH000021', N'Trịnh Cẩm Tú', N'0977889900', N'tu.trinhcam@vinamilk.com.vn', N'10 Tân Trào, Tân Phú, Quận 7, TP.HCM', N'Kế toán trưởng Vinamilk', 1, '2026-10-21 10:01:02.706', NULL);
INSERT INTO dbo.[Customers] ([CustomerId], [CustomerCode], [FullName], [Phone], [Email], [Address], [Note], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (22, N'KH000022', N'Bùi Minh Triết', N'0907113355', N'triet.bui@gmail.com', N'38 Nguyễn Văn Trỗi, Phường 15, Phú Nhuận, TP.HCM', N'Nhiếp ảnh gia tự do', 1, '2026-10-22 10:01:02.706', NULL);
INSERT INTO dbo.[Customers] ([CustomerId], [CustomerCode], [FullName], [Phone], [Email], [Address], [Note], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (23, N'KH000023', N'Cao Khánh Linh', N'0983445566', N'linh.caokhanh@gmail.com', N'182 Lê Văn Sỹ, Phường 10, Phú Nhuận, TP.HCM', N'Chủ shop thời trang online', 1, '2026-10-23 10:01:02.706', NULL);
INSERT INTO dbo.[Customers] ([CustomerId], [CustomerCode], [FullName], [Phone], [Email], [Address], [Note], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (24, N'KH000024', N'Lâm Thế Vinh', N'0918223344', N'vinh.lamthe@vng.com.vn', N'182 Ba Tháng Hai, Phường 12, Quận 10, TP.HCM', N'Kỹ sư phần mềm VNG Corp', 1, '2026-10-24 10:01:02.706', NULL);
INSERT INTO dbo.[Customers] ([CustomerId], [CustomerCode], [FullName], [Phone], [Email], [Address], [Note], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (25, N'KH000025', N'Mai Thanh Hà', N'0906778899', N'ha.maithanh@gmail.com', N'91 Sư Vạn Hạnh, Phường 12, Quận 10, TP.HCM', N'Bác sĩ nha khoa Quốc tế', 1, '2026-10-25 10:01:02.706', NULL);
INSERT INTO dbo.[Customers] ([CustomerId], [CustomerCode], [FullName], [Phone], [Email], [Address], [Note], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (26, N'KH000026', N'Kiểm Thử Viên Tự Động', N'0936990058', N'test.auto@repairshop.local', N'123 Đường Kiểm Thử, Quận 1, TP.HCM', NULL, 1, '2026-10-25 10:01:32.265', NULL);
INSERT INTO dbo.[Customers] ([CustomerId], [CustomerCode], [FullName], [Phone], [Email], [Address], [Note], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (27, N'KH000027', N'Kiểm Thử Viên Tự Động (Đã Cập Nhật)', N'0964011961', N'test.updated@repairshop.local', N'456 Đường Mới, Quận 3, TP.HCM', NULL, 1, '2026-10-25 10:02:44.074', '2026-10-25 10:02:44.091');
INSERT INTO dbo.[Customers] ([CustomerId], [CustomerCode], [FullName], [Phone], [Email], [Address], [Note], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (28, N'KH000028', N'Kiểm Thử Viên Tự Động (Đã Cập Nhật)', N'0939944528', N'test.updated@repairshop.local', N'456 Đường Mới, Quận 3, TP.HCM', NULL, 1, '2026-10-25 10:03:57.944', '2026-10-25 10:03:57.991');
INSERT INTO dbo.[Customers] ([CustomerId], [CustomerCode], [FullName], [Phone], [Email], [Address], [Note], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (29, N'KH000029', N'Kiểm Thử Viên Tự Động (Đã Cập Nhật)', N'0974180080', N'test.updated@repairshop.local', N'456 Đường Mới, Quận 3, TP.HCM', NULL, 1, '2026-10-25 10:04:37.944', '2026-10-25 10:04:37.959');
SET IDENTITY_INSERT dbo.[Customers] OFF;
GO

-- ----------------------------------------------------
-- Bang: dbo.Users (8 rows)
-- ----------------------------------------------------
SET IDENTITY_INSERT dbo.[Users] ON;
INSERT INTO dbo.[Users] ([UserId], [RoleId], [Username], [PasswordHash], [FullName], [Email], [Phone], [IsActive], [LastLoginAt], [CreatedAt], [UpdatedAt], [CustomerId]) VALUES (1, 1, N'admin', N'$2a$11$i9HeslXM/Q.w615uRRoWTegplzlqOgpSv1/XHdjgD85ZOA/U1ax3e', N'Nguyá»…n Viáº¿t LÃ£m (Admin / Quáº£n lÃ½)', N'admin@repairshop.local', N'0900000001', 1, '2026-10-25 10:04:37.435', '2026-10-06 13:11:36.794', NULL, NULL);
INSERT INTO dbo.[Users] ([UserId], [RoleId], [Username], [PasswordHash], [FullName], [Email], [Phone], [IsActive], [LastLoginAt], [CreatedAt], [UpdatedAt], [CustomerId]) VALUES (2, 2, N'staff01', N'$2a$11$i9HeslXM/Q.w615uRRoWTegplzlqOgpSv1/XHdjgD85ZOA/U1ax3e', N'Tráº§n Ngá»c Lá»£i (TrÆ°á»Ÿng nhÃ³m lá»… tÃ¢n & CSKH)', N'staff01@repairshop.local', N'0900000002', 1, '2026-10-25 10:04:37.564', '2026-10-06 13:11:36.794', NULL, NULL);
INSERT INTO dbo.[Users] ([UserId], [RoleId], [Username], [PasswordHash], [FullName], [Email], [Phone], [IsActive], [LastLoginAt], [CreatedAt], [UpdatedAt], [CustomerId]) VALUES (3, 3, N'tech01', N'$2a$11$i9HeslXM/Q.w615uRRoWTegplzlqOgpSv1/XHdjgD85ZOA/U1ax3e', N'Pháº¡m VÄƒn Ká»¹ Thuáº­t (ChuyÃªn viÃªn Laptop & PC)', N'tech01@repairshop.local', N'0900000003', 1, '2026-10-25 10:04:37.690', '2026-10-06 13:11:36.794', NULL, NULL);
INSERT INTO dbo.[Users] ([UserId], [RoleId], [Username], [PasswordHash], [FullName], [Email], [Phone], [IsActive], [LastLoginAt], [CreatedAt], [UpdatedAt], [CustomerId]) VALUES (4, 3, N'tech02', N'$2a$11$i9HeslXM/Q.w615uRRoWTegplzlqOgpSv1/XHdjgD85ZOA/U1ax3e', N'Nguyá»…n Äáº¡i Ká»³ (ChuyÃªn viÃªn Mobile & Apple)', N'tech02@repairshop.local', N'0900000004', 1, NULL, '2026-10-06 13:11:36.794', NULL, NULL);
INSERT INTO dbo.[Users] ([UserId], [RoleId], [Username], [PasswordHash], [FullName], [Email], [Phone], [IsActive], [LastLoginAt], [CreatedAt], [UpdatedAt], [CustomerId]) VALUES (18, 4, N'khach01', N'$2a$11$i9HeslXM/Q.w615uRRoWTegplzlqOgpSv1/XHdjgD85ZOA/U1ax3e', N'Nguyá»…n ThÃ nh Nam (KhÃ¡ch hÃ ng VIP)', N'nam.nguyen@gmail.com', N'0982345678', 1, '2026-10-25 10:04:37.811', '2026-10-25 09:05:12.566', NULL, 1);
INSERT INTO dbo.[Users] ([UserId], [RoleId], [Username], [PasswordHash], [FullName], [Email], [Phone], [IsActive], [LastLoginAt], [CreatedAt], [UpdatedAt], [CustomerId]) VALUES (19, 4, N'khach02', N'$2a$11$i9HeslXM/Q.w615uRRoWTegplzlqOgpSv1/XHdjgD85ZOA/U1ax3e', N'LÃª HoÃ ng PhÃºc (KhÃ¡ch hÃ ng)', N'phuc.le@outlook.com', N'0903124567', 1, '2026-10-25 04:05:12.566', '2026-10-25 09:05:12.566', NULL, 2);
INSERT INTO dbo.[Users] ([UserId], [RoleId], [Username], [PasswordHash], [FullName], [Email], [Phone], [IsActive], [LastLoginAt], [CreatedAt], [UpdatedAt], [CustomerId]) VALUES (20, 4, N'khach03', N'$2a$11$i9HeslXM/Q.w615uRRoWTegplzlqOgpSv1/XHdjgD85ZOA/U1ax3e', N'Äáº·ng Minh TÃ¢m (KhÃ¡ch hÃ ng)', N'tam.dang@fpt.edu.vn', N'0918765432', 1, NULL, '2026-10-25 09:05:12.566', NULL, 3);
INSERT INTO dbo.[Users] ([UserId], [RoleId], [Username], [PasswordHash], [FullName], [Email], [Phone], [IsActive], [LastLoginAt], [CreatedAt], [UpdatedAt], [CustomerId]) VALUES (21, 4, N'customer', N'$2a$11$i9HeslXM/Q.w615uRRoWTegplzlqOgpSv1/XHdjgD85ZOA/U1ax3e', N'KhÃ¡ch hÃ ng Demo (Tráº£i nghiá»‡m Portal)', N'customer@example.com', N'0901000003', 1, '2026-10-24 09:05:12.566', '2026-10-25 09:05:12.566', '2026-10-25 10:04:38.326', 1);
SET IDENTITY_INSERT dbo.[Users] OFF;
GO

-- ----------------------------------------------------
-- Bang: dbo.SparePartCategories (6 rows)
-- ----------------------------------------------------
SET IDENTITY_INSERT dbo.[SparePartCategories] ON;
INSERT INTO dbo.[SparePartCategories] ([CategoryId], [CategoryName], [Description], [IsActive]) VALUES (1, N'MÃ n hÃ¬nh Smartphone & Laptop', N'MÃ n hÃ¬nh Super Retina XDR, Dynamic AMOLED 2X, LCD IPS 144Hz', 1);
INSERT INTO dbo.[SparePartCategories] ([CategoryId], [CategoryName], [Description], [IsActive]) VALUES (2, N'Pin & Bá»™ sáº¡c cÃ´ng suáº¥t cao', N'Pin Pisen chÃ­nh hÃ£ng, Pin zin mÃ¡y, Pin Dell/Apple cao cáº¥p', 1);
INSERT INTO dbo.[SparePartCategories] ([CategoryId], [CategoryName], [Description], [IsActive]) VALUES (3, N'á»” cá»©ng SSD NVMe & RAM', N'SSD Samsung 980 PRO, Kingston NV2, RAM Crucial DDR5, Kingston DDR4', 1);
INSERT INTO dbo.[SparePartCategories] ([CategoryId], [CategoryName], [Description], [IsActive]) VALUES (4, N'IC nguá»“n, Chipset & Bo máº¡ch', N'IC PMIC Qualcomm, chip sáº¡c Type-C Thunderbolt, tá»¥ gá»‘m cao táº§n', 1);
INSERT INTO dbo.[SparePartCategories] ([CategoryId], [CategoryName], [Description], [IsActive]) VALUES (5, N'BÃ n phÃ­m, Vá» & Cá»¥m linh kiá»‡n', N'BÃ n phÃ­m ThinkPad, quáº¡t Asus ROG, cÃ¡p Type-C iPhone/iPad', 1);
INSERT INTO dbo.[SparePartCategories] ([CategoryId], [CategoryName], [Description], [IsActive]) VALUES (6, N'Keo táº£n nhiá»‡t & Váº­t tÆ° báº£o dÆ°á»¡ng', N'Keo gá»‘m Thermal Grizzly, dung dá»‹ch táº©y keo Arctic Clean, ron chá»‘ng nÆ°á»›c', 1);
SET IDENTITY_INSERT dbo.[SparePartCategories] OFF;
GO

-- ----------------------------------------------------
-- Bang: dbo.SpareParts (18 rows)
-- ----------------------------------------------------
SET IDENTITY_INSERT dbo.[SpareParts] ON;
INSERT INTO dbo.[SpareParts] ([PartId], [PartCode], [CategoryId], [PartName], [Unit], [PurchasePrice], [SellingPrice], [StockQuantity], [MinStockLevel], [WarrantyDays], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (1, N'LK00001', 1, N'MÃ n hÃ¬nh iPhone 14 Pro Max Super Retina XDR Zin mÃ¡y', N'CÃ¡i', 4800000.00, 5600000.00, 6, 2, 90, 1, '2026-09-25 09:05:12.570', NULL);
INSERT INTO dbo.[SpareParts] ([PartId], [PartCode], [CategoryId], [PartName], [Unit], [PurchasePrice], [SellingPrice], [StockQuantity], [MinStockLevel], [WarrantyDays], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (2, N'LK00002', 1, N'MÃ n hÃ¬nh Samsung Galaxy S23 Ultra Dynamic AMOLED 2X', N'CÃ¡i', 4100000.00, 4900000.00, 4, 2, 90, 1, '2026-09-25 09:05:12.570', NULL);
INSERT INTO dbo.[SpareParts] ([PartId], [PartCode], [CategoryId], [PartName], [Unit], [PurchasePrice], [SellingPrice], [StockQuantity], [MinStockLevel], [WarrantyDays], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (3, N'LK00003', 1, N'MÃ n hÃ¬nh LCD Laptop 15.6" IPS FHD 144Hz Slim', N'CÃ¡i', 1250000.00, 1650000.00, 8, 3, 180, 1, '2026-09-25 09:05:12.570', NULL);
INSERT INTO dbo.[SpareParts] ([PartId], [PartCode], [CategoryId], [PartName], [Unit], [PurchasePrice], [SellingPrice], [StockQuantity], [MinStockLevel], [WarrantyDays], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (4, N'LK00004', 1, N'MÃ n hÃ¬nh MacBook Pro 14" Liquid Retina XDR A2442', N'CÃ¡i', 6800000.00, 7900000.00, 3, 1, 180, 1, '2026-09-25 09:05:12.570', NULL);
INSERT INTO dbo.[SpareParts] ([PartId], [PartCode], [CategoryId], [PartName], [Unit], [PurchasePrice], [SellingPrice], [StockQuantity], [MinStockLevel], [WarrantyDays], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (5, N'LK00005', 2, N'Pin iPhone 14 Pro Max Pisen dung lÆ°á»£ng cao 4323mAh', N'CÃ¡i', 580000.00, 790000.00, 15, 5, 180, 1, '2026-09-25 09:05:12.570', NULL);
INSERT INTO dbo.[SpareParts] ([PartId], [PartCode], [CategoryId], [PartName], [Unit], [PurchasePrice], [SellingPrice], [StockQuantity], [MinStockLevel], [WarrantyDays], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (6, N'LK00006', 2, N'Pin Samsung Galaxy S23 Ultra Zin 5000mAh', N'CÃ¡i', 480000.00, 680000.00, 10, 3, 180, 1, '2026-09-25 09:05:12.570', NULL);
INSERT INTO dbo.[SpareParts] ([PartId], [PartCode], [CategoryId], [PartName], [Unit], [PurchasePrice], [SellingPrice], [StockQuantity], [MinStockLevel], [WarrantyDays], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (7, N'LK00007', 2, N'Pin Laptop Dell XPS 15 86Wh 6-cell chÃ­nh hÃ£ng', N'CÃ¡i', 980000.00, 1350000.00, 2, 2, 180, 1, '2026-09-25 09:05:12.570', NULL);
INSERT INTO dbo.[SpareParts] ([PartId], [PartCode], [CategoryId], [PartName], [Unit], [PurchasePrice], [SellingPrice], [StockQuantity], [MinStockLevel], [WarrantyDays], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (8, N'LK00008', 2, N'Pin MacBook Pro 14" A2442 70Wh Zin', N'CÃ¡i', 1350000.00, 1850000.00, 4, 2, 180, 1, '2026-09-25 09:05:12.570', NULL);
INSERT INTO dbo.[SpareParts] ([PartId], [PartCode], [CategoryId], [PartName], [Unit], [PurchasePrice], [SellingPrice], [StockQuantity], [MinStockLevel], [WarrantyDays], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (9, N'LK00009', 3, N'á»” cá»©ng SSD Samsung 980 PRO 1TB PCIe NVMe 4.0', N'CÃ¡i', 1850000.00, 2250000.00, 12, 4, 365, 1, '2026-09-25 09:05:12.570', NULL);
INSERT INTO dbo.[SpareParts] ([PartId], [PartCode], [CategoryId], [PartName], [Unit], [PurchasePrice], [SellingPrice], [StockQuantity], [MinStockLevel], [WarrantyDays], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (10, N'LK00010', 3, N'á»” cá»©ng SSD Kingston NV2 512GB M.2 PCIe 4.0', N'CÃ¡i', 720000.00, 950000.00, 18, 5, 365, 1, '2026-09-25 09:05:12.570', NULL);
INSERT INTO dbo.[SpareParts] ([PartId], [PartCode], [CategoryId], [PartName], [Unit], [PurchasePrice], [SellingPrice], [StockQuantity], [MinStockLevel], [WarrantyDays], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (11, N'LK00011', 3, N'RAM Laptop Crucial DDR5 16GB 4800MHz', N'Thanh', 980000.00, 1280000.00, 8, 3, 365, 1, '2026-09-25 09:05:12.570', NULL);
INSERT INTO dbo.[SpareParts] ([PartId], [PartCode], [CategoryId], [PartName], [Unit], [PurchasePrice], [SellingPrice], [StockQuantity], [MinStockLevel], [WarrantyDays], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (12, N'LK00012', 3, N'RAM Laptop Kingston Fury DDR4 16GB 3200MHz', N'Thanh', 680000.00, 890000.00, 14, 4, 365, 1, '2026-09-25 09:05:12.570', NULL);
INSERT INTO dbo.[SpareParts] ([PartId], [PartCode], [CategoryId], [PartName], [Unit], [PurchasePrice], [SellingPrice], [StockQuantity], [MinStockLevel], [WarrantyDays], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (13, N'LK00013', 4, N'IC Nguá»“n PMIC Qualcomm Snapdragon SM8550', N'CÃ¡i', 220000.00, 450000.00, 20, 5, 90, 1, '2026-09-25 09:05:12.570', NULL);
INSERT INTO dbo.[SpareParts] ([PartId], [PartCode], [CategoryId], [PartName], [Unit], [PurchasePrice], [SellingPrice], [StockQuantity], [MinStockLevel], [WarrantyDays], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (14, N'LK00014', 5, N'Cá»¥m chÃ¢n sáº¡c Type-C iPhone 14 Pro Max bÃ³c mÃ¡y', N'CÃ¡i', 380000.00, 620000.00, 7, 2, 90, 1, '2026-09-25 09:05:12.570', NULL);
INSERT INTO dbo.[SpareParts] ([PartId], [PartCode], [CategoryId], [PartName], [Unit], [PurchasePrice], [SellingPrice], [StockQuantity], [MinStockLevel], [WarrantyDays], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (15, N'LK00015', 5, N'BÃ n phÃ­m Laptop Lenovo ThinkPad X1 Carbon Led US', N'CÃ¡i', 650000.00, 950000.00, 1, 2, 180, 1, '2026-09-25 09:05:12.570', NULL);
INSERT INTO dbo.[SpareParts] ([PartId], [PartCode], [CategoryId], [PartName], [Unit], [PurchasePrice], [SellingPrice], [StockQuantity], [MinStockLevel], [WarrantyDays], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (16, N'LK00016', 6, N'Keo táº£n nhiá»‡t Thermal Grizzly Kryonaut 1g', N'TuÃ½p', 110000.00, 180000.00, 32, 10, 0, 1, '2026-09-25 09:05:12.570', '2026-10-25 10:04:38.075');
INSERT INTO dbo.[SpareParts] ([PartId], [PartCode], [CategoryId], [PartName], [Unit], [PurchasePrice], [SellingPrice], [StockQuantity], [MinStockLevel], [WarrantyDays], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (17, N'LK00017', 5, N'Cá»¥m quáº¡t táº£n nhiá»‡t Ä‘Ã´i Asus ROG Zephyrus G14', N'Bá»™', 320000.00, 490000.00, 5, 2, 90, 1, '2026-09-25 09:05:12.570', NULL);
INSERT INTO dbo.[SpareParts] ([PartId], [PartCode], [CategoryId], [PartName], [Unit], [PurchasePrice], [SellingPrice], [StockQuantity], [MinStockLevel], [WarrantyDays], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (18, N'LK00018', 1, N'Máº·t kÃ­nh Sapphire cá»¥m camera iPad Pro 11"', N'CÃ¡i', 150000.00, 280000.00, 9, 3, 90, 1, '2026-09-25 09:05:12.570', NULL);
SET IDENTITY_INSERT dbo.[SpareParts] OFF;
GO

-- ----------------------------------------------------
-- Bang: dbo.ServiceTypes (10 rows)
-- ----------------------------------------------------
SET IDENTITY_INSERT dbo.[ServiceTypes] ON;
INSERT INTO dbo.[ServiceTypes] ([ServiceTypeId], [ServiceCode], [ServiceName], [LaborCost], [WarrantyDays], [Description], [IsActive]) VALUES (1, N'DV001', N'Thay mÃ n hÃ¬nh Ä‘iá»‡n thoáº¡i OLED / Super Retina', 150000.00, 90, N'ThÃ¡o rÃ¡p, Ã©p ron chá»‘ng nÆ°á»›c, chuyá»ƒn IC giá»¯ True Tone', 1);
INSERT INTO dbo.[ServiceTypes] ([ServiceTypeId], [ServiceCode], [ServiceName], [LaborCost], [WarrantyDays], [Description], [IsActive]) VALUES (2, N'DV002', N'Thay pin chÃ­nh hÃ£ng Ä‘iá»‡n thoáº¡i / mÃ¡y tÃ­nh báº£ng', 100000.00, 180, N'Thay pin dung lÆ°á»£ng cao, dÃ¡n keo seal chuyÃªn dá»¥ng', 1);
INSERT INTO dbo.[ServiceTypes] ([ServiceTypeId], [ServiceCode], [ServiceName], [LaborCost], [WarrantyDays], [Description], [IsActive]) VALUES (3, N'DV003', N'Vá»‡ sinh tra keo táº£n nhiá»‡t gá»‘m mÃ¡y tÃ­nh & laptop', 150000.00, 30, N'Vá»‡ sinh quáº¡t kÃ©p, tra keo gá»‘m Thermal Grizzly Kryonaut', 1);
INSERT INTO dbo.[ServiceTypes] ([ServiceTypeId], [ServiceCode], [ServiceName], [LaborCost], [WarrantyDays], [Description], [IsActive]) VALUES (4, N'DV004', N'CÃ i Ä‘áº·t há»‡ Ä‘iá»u hÃ nh Windows 11 / macOS & pháº§n má»m', 100000.00, 30, N'CÃ i Ä‘áº·t OS chuáº©n UEFI/GPT, driver Ä‘áº§y Ä‘á»§ vÃ  Office', 1);
INSERT INTO dbo.[ServiceTypes] ([ServiceTypeId], [ServiceCode], [ServiceName], [LaborCost], [WarrantyDays], [Description], [IsActive]) VALUES (5, N'DV005', N'Sá»­a chá»¯a pháº§n cá»©ng mainboard, IC nguá»“n, reball chip', 450000.00, 90, N'Äo Ä‘áº¡c boardview, dÃ² cháº¡m cháº­p báº±ng camera nhiá»‡t FLIR', 1);
INSERT INTO dbo.[ServiceTypes] ([ServiceTypeId], [ServiceCode], [ServiceName], [LaborCost], [WarrantyDays], [Description], [IsActive]) VALUES (6, N'DV006', N'NÃ¢ng cáº¥p á»• cá»©ng SSD NVMe & sao lÆ°u chuyá»ƒn dá»¯ liá»‡u', 120000.00, 365, N'Láº¯p Ä‘áº·t SSD M.2 tá»‘c Ä‘á»™ cao, clone phÃ¢n vÃ¹ng dá»¯ liá»‡u an toÃ n', 1);
INSERT INTO dbo.[ServiceTypes] ([ServiceTypeId], [ServiceCode], [ServiceName], [LaborCost], [WarrantyDays], [Description], [IsActive]) VALUES (7, N'DV007', N'Thay cá»¥m cÃ¡p chÃ¢n sáº¡c Type-C / Lightning vÃ  mic thoáº¡i', 150000.00, 90, N'Thay bo cÃ¡p chÃ¢n sáº¡c zin mÃ¡y, test chuáº©n sáº¡c nhanh PD', 1);
INSERT INTO dbo.[ServiceTypes] ([ServiceTypeId], [ServiceCode], [ServiceName], [LaborCost], [WarrantyDays], [Description], [IsActive]) VALUES (8, N'DV008', N'Ã‰p kÃ­nh mÃ n hÃ¬nh cong / thay máº·t kÃ­nh cáº£m á»©ng', 250000.00, 90, N'Cáº¯t kÃ­nh vá»¡ báº±ng mÃ¡y tÃ¡ch nhiá»‡t, háº¥p bá»t khÃ­ chÃ¢n khÃ´ng', 1);
INSERT INTO dbo.[ServiceTypes] ([ServiceTypeId], [ServiceCode], [ServiceName], [LaborCost], [WarrantyDays], [Description], [IsActive]) VALUES (9, N'DV009', N'Thay bÃ n phÃ­m laptop & báº£o dÆ°á»¡ng switch phÃ­m', 120000.00, 180, N'HÃ n tÃ¡n Ä‘inh rivet bÃ n phÃ­m má»›i, kiá»ƒm tra Ä‘á»™ náº£y tá»«ng phÃ­m', 1);
INSERT INTO dbo.[ServiceTypes] ([ServiceTypeId], [ServiceCode], [ServiceName], [LaborCost], [WarrantyDays], [Description], [IsActive]) VALUES (10, N'DV010', N'Cá»©u phá»¥c há»“i dá»¯ liá»‡u á»• cá»©ng lá»—i bad sector / lá»—i máº¡ch', 500000.00, 30, N'Cá»©u dá»¯ liá»‡u á»• cÆ¡ HDD vÃ  SSD báº±ng thiáº¿t bá»‹ chuyÃªn dá»¥ng PC-3000', 1);
SET IDENTITY_INSERT dbo.[ServiceTypes] OFF;
GO

-- ----------------------------------------------------
-- Bang: dbo.Devices (31 rows)
-- ----------------------------------------------------
SET IDENTITY_INSERT dbo.[Devices] ON;
INSERT INTO dbo.[Devices] ([DeviceId], [CustomerId], [DeviceType], [Brand], [Model], [SerialNumber], [Note], [CreatedAt], [DeviceCode]) VALUES (1, 1, N'Laptop', N'Dell', N'XPS 15 9520 (Core i7-12700H / 32GB / 1TB SSD)', N'DLXPS-9520-VN01', N'MÃ¡y Ä‘á»“ há»a cao cáº¥p', '2026-10-05 09:05:12.566', N'TB000001');
INSERT INTO dbo.[Devices] ([DeviceId], [CustomerId], [DeviceType], [Brand], [Model], [SerialNumber], [Note], [CreatedAt], [DeviceCode]) VALUES (2, 2, N'Äiá»‡n thoáº¡i', N'Apple', N'iPhone 14 Pro Max 256GB Deep Purple', N'F2LX90A4MD6R', N'MÃ¡y chÃ­nh hÃ£ng VNA', '2026-10-07 09:05:12.566', N'TB000002');
INSERT INTO dbo.[Devices] ([DeviceId], [CustomerId], [DeviceType], [Brand], [Model], [SerialNumber], [Note], [CreatedAt], [DeviceCode]) VALUES (3, 3, N'Laptop', N'Apple', N'MacBook Pro 14 M2 Pro 2023 Space Gray', N'C02G90ABMD6T', N'MÃ¡y láº­p trÃ¬nh di Ä‘á»™ng', '2026-10-10 09:05:12.566', N'TB000003');
INSERT INTO dbo.[Devices] ([DeviceId], [CustomerId], [DeviceType], [Brand], [Model], [SerialNumber], [Note], [CreatedAt], [DeviceCode]) VALUES (4, 4, N'Äiá»‡n thoáº¡i', N'Samsung', N'Galaxy S23 Ultra 5G 512GB Phantom Black', N'R5CW20ABXYZ', N'Báº£n chÃ­nh hÃ£ng SSVN', '2026-10-13 09:05:12.566', N'TB000004');
INSERT INTO dbo.[Devices] ([DeviceId], [CustomerId], [DeviceType], [Brand], [Model], [SerialNumber], [Note], [CreatedAt], [DeviceCode]) VALUES (5, 5, N'MÃ¡y tÃ­nh PC', N'ASUS / MSI', N'PC Gaming Core i7-13700K / RTX 3070 8GB', N'PCG-2026-SG01', N'Case Corsair 4000D táº£n nÆ°á»›c', '2026-10-15 09:05:12.566', N'TB000005');
INSERT INTO dbo.[Devices] ([DeviceId], [CustomerId], [DeviceType], [Brand], [Model], [SerialNumber], [Note], [CreatedAt], [DeviceCode]) VALUES (6, 6, N'Laptop', N'Asus', N'ROG Zephyrus G14 (Ryzen 7 6800HS / RX 6700S)', N'GA402RJ-L8035W', N'Laptop gaming má»ng nháº¹', '2026-10-17 09:05:12.566', N'TB000006');
INSERT INTO dbo.[Devices] ([DeviceId], [CustomerId], [DeviceType], [Brand], [Model], [SerialNumber], [Note], [CreatedAt], [DeviceCode]) VALUES (7, 7, N'MÃ¡y tÃ­nh báº£ng', N'Apple', N'iPad Pro 11 M1 128GB Wi-Fi + 5G', N'DMPD30A8MD6M', N'DÃ¹ng váº½ vÃ  Ä‘á»“ há»a Procreate', '2026-10-19 09:05:12.566', N'TB000007');
INSERT INTO dbo.[Devices] ([DeviceId], [CustomerId], [DeviceType], [Brand], [Model], [SerialNumber], [Note], [CreatedAt], [DeviceCode]) VALUES (8, 8, N'Laptop', N'Lenovo', N'ThinkPad X1 Carbon Gen 10 (Core i7-1260P / 16GB)', N'PF3X99AB2023', N'MÃ¡y doanh nhÃ¢n siÃªu bá»n', '2026-10-21 09:05:12.566', N'TB000008');
INSERT INTO dbo.[Devices] ([DeviceId], [CustomerId], [DeviceType], [Brand], [Model], [SerialNumber], [Note], [CreatedAt], [DeviceCode]) VALUES (9, 9, N'Äiá»‡n thoáº¡i', N'Apple', N'iPhone 13 128GB Starlight', N'DX3F40ABMD6N', N'MÃ¡y ná»¯ dÃ¹ng giá»¯ gÃ¬n', '2026-10-22 09:05:12.566', N'TB000009');
INSERT INTO dbo.[Devices] ([DeviceId], [CustomerId], [DeviceType], [Brand], [Model], [SerialNumber], [Note], [CreatedAt], [DeviceCode]) VALUES (10, 10, N'Laptop', N'HP', N'Envy 13-ba1000 Core i5-1135G7 / 8GB RAM', N'5CD2180ABC', N'Laptop vÄƒn phÃ²ng má»ng nháº¹', '2026-10-24 09:05:12.566', N'TB000010');
INSERT INTO dbo.[Devices] ([DeviceId], [CustomerId], [DeviceType], [Brand], [Model], [SerialNumber], [Note], [CreatedAt], [DeviceCode]) VALUES (11, 11, N'Äiá»‡n thoáº¡i', N'Apple', N'iPhone 15 Pro Max 256GB Natural Titanium', N'NM9X20PMAA', N'MÃ¡y má»›i bÃ³c há»™p 3 thÃ¡ng', '2026-10-07 10:01:02.706', N'TB000011');
INSERT INTO dbo.[Devices] ([DeviceId], [CustomerId], [DeviceType], [Brand], [Model], [SerialNumber], [Note], [CreatedAt], [DeviceCode]) VALUES (12, 12, N'Laptop', N'Apple', N'MacBook Air 13 M1 2020 Space Gray', N'C02F99MBAA', N'MÃ¡y vÄƒn phÃ²ng má»ng nháº¹', '2026-10-09 10:01:02.706', N'TB000012');
INSERT INTO dbo.[Devices] ([DeviceId], [CustomerId], [DeviceType], [Brand], [Model], [SerialNumber], [Note], [CreatedAt], [DeviceCode]) VALUES (13, 13, N'Laptop', N'Asus', N'Asus TUF Gaming A15 (Ryzen 7 / RTX 3050)', N'AS-TUF-A15-VN', N'Laptop Ä‘á»“ há»a & game', '2026-10-11 10:01:02.706', N'TB000013');
INSERT INTO dbo.[Devices] ([DeviceId], [CustomerId], [DeviceType], [Brand], [Model], [SerialNumber], [Note], [CreatedAt], [DeviceCode]) VALUES (14, 14, N'Äiá»‡n thoáº¡i', N'Apple', N'iPhone 12 Pro 128GB Pacific Blue', N'F17D9890MD6P', N'MÃ¡y chÃ­nh hÃ£ng LL/A', '2026-10-12 10:01:02.706', N'TB000014');
INSERT INTO dbo.[Devices] ([DeviceId], [CustomerId], [DeviceType], [Brand], [Model], [SerialNumber], [Note], [CreatedAt], [DeviceCode]) VALUES (15, 15, N'MÃ¡y tÃ­nh PC', N'NZXT / Corsair', N'PC Workstation Core i9-13900K / RTX 4080 16GB', N'PCG-CUSTOM-4080', N'Cáº¥u hÃ¬nh dá»±ng phim 4K', '2026-10-14 10:01:02.706', N'TB000015');
INSERT INTO dbo.[Devices] ([DeviceId], [CustomerId], [DeviceType], [Brand], [Model], [SerialNumber], [Note], [CreatedAt], [DeviceCode]) VALUES (16, 16, N'Laptop', N'Lenovo', N'ThinkPad T14 Gen 3 Core i5-1240P / 16GB RAM', N'PF3398T14G3', N'MÃ¡y chuáº©n quÃ¢n Ä‘á»™i Má»¹', '2026-10-16 10:01:02.706', N'TB000016');
INSERT INTO dbo.[Devices] ([DeviceId], [CustomerId], [DeviceType], [Brand], [Model], [SerialNumber], [Note], [CreatedAt], [DeviceCode]) VALUES (17, 17, N'Äiá»‡n thoáº¡i', N'Samsung', N'Galaxy Z Fold5 5G 512GB Icy Blue', N'R5CW88FOLD5', N'MÃ n hÃ¬nh gáº­p cao cáº¥p', '2026-10-17 10:01:02.706', N'TB000017');
INSERT INTO dbo.[Devices] ([DeviceId], [CustomerId], [DeviceType], [Brand], [Model], [SerialNumber], [Note], [CreatedAt], [DeviceCode]) VALUES (18, 18, N'MÃ¡y tÃ­nh báº£ng', N'Apple', N'iPad Air 5 64GB Wi-Fi M1 Purple', N'DMPD98AIR5VN', N'Váº½ minh há»a iPadOS 17', '2026-10-18 10:01:02.706', N'TB000018');
INSERT INTO dbo.[Devices] ([DeviceId], [CustomerId], [DeviceType], [Brand], [Model], [SerialNumber], [Note], [CreatedAt], [DeviceCode]) VALUES (19, 19, N'Laptop', N'Dell', N'Inspiron 5510 Core i7-11370H / 16GB', N'DL-INS-5510-VN', N'Há»c táº­p vÃ  láº­p trÃ¬nh', '2026-10-19 10:01:02.706', N'TB000019');
INSERT INTO dbo.[Devices] ([DeviceId], [CustomerId], [DeviceType], [Brand], [Model], [SerialNumber], [Note], [CreatedAt], [DeviceCode]) VALUES (20, 20, N'Äiá»‡n thoáº¡i', N'Xiaomi', N'Xiaomi 13 Pro 5G Leica 256GB Black', N'XM13P-LEICA-VN', N'Camera há»£p tÃ¡c Leica', '2026-10-20 10:01:02.706', N'TB000020');
INSERT INTO dbo.[Devices] ([DeviceId], [CustomerId], [DeviceType], [Brand], [Model], [SerialNumber], [Note], [CreatedAt], [DeviceCode]) VALUES (21, 21, N'Laptop', N'Apple', N'MacBook Pro 16 M3 Max 36GB / 1TB Space Black', N'C02M3MAX16VN', N'MÃ¡y láº­p trÃ¬nh cao cáº¥p', '2026-10-21 10:01:02.706', N'TB000021');
INSERT INTO dbo.[Devices] ([DeviceId], [CustomerId], [DeviceType], [Brand], [Model], [SerialNumber], [Note], [CreatedAt], [DeviceCode]) VALUES (22, 22, N'Laptop', N'Acer', N'Nitro 5 Tiger AN515-58 Core i5-12500H / RTX 3050Ti', N'NHQFZSV001', N'DÃ¹ng chá»‰nh áº£nh Lightroom', '2026-10-22 10:01:02.706', N'TB000022');
INSERT INTO dbo.[Devices] ([DeviceId], [CustomerId], [DeviceType], [Brand], [Model], [SerialNumber], [Note], [CreatedAt], [DeviceCode]) VALUES (23, 23, N'Äiá»‡n thoáº¡i', N'Apple', N'iPhone 11 64GB Black', N'DX3D88IP11VN', N'MÃ¡y dÃ¹ng livestream bÃ¡n hÃ ng', '2026-10-23 10:01:02.706', N'TB000023');
INSERT INTO dbo.[Devices] ([DeviceId], [CustomerId], [DeviceType], [Brand], [Model], [SerialNumber], [Note], [CreatedAt], [DeviceCode]) VALUES (24, 24, N'Laptop', N'HP', N'Pavilion 15-eg2000 Core i5-1240P / 8GB', N'5CD299HPVN', N'Laptop code Backend', '2026-10-24 10:01:02.706', N'TB000024');
INSERT INTO dbo.[Devices] ([DeviceId], [CustomerId], [DeviceType], [Brand], [Model], [SerialNumber], [Note], [CreatedAt], [DeviceCode]) VALUES (25, 25, N'MÃ¡y tÃ­nh bÃ n', N'Apple', N'iMac 24" 4.5K Retina M1 8-core CPU / 8-core GPU Blue', N'C02G77IMAC24', N'MÃ¡y Ä‘á»ƒ quáº§y lá»… tÃ¢n nha khoa', '2026-10-25 10:01:02.706', N'TB000025');
INSERT INTO dbo.[Devices] ([DeviceId], [CustomerId], [DeviceType], [Brand], [Model], [SerialNumber], [Note], [CreatedAt], [DeviceCode]) VALUES (26, 11, N'Äiá»‡n thoáº¡i', N'Apple', N'iPhone 14 Plus 128GB Midnight', N'F2LX88PLUSVN', N'MÃ¡y phá»¥ dÃ¹ng nghe gá»i', '2026-10-10 10:01:02.706', N'TB000026');
INSERT INTO dbo.[Devices] ([DeviceId], [CustomerId], [DeviceType], [Brand], [Model], [SerialNumber], [Note], [CreatedAt], [DeviceCode]) VALUES (27, 14, N'Laptop', N'Dell', N'XPS 13 Plus 9320 Core i7-1260P Touch', N'DL-9320-PLUS-VN', N'Laptop má»ng nháº¹ doanh nhÃ¢n', '2026-10-15 10:01:02.706', N'TB000027');
INSERT INTO dbo.[Devices] ([DeviceId], [CustomerId], [DeviceType], [Brand], [Model], [SerialNumber], [Note], [CreatedAt], [DeviceCode]) VALUES (28, 16, N'Äiá»‡n thoáº¡i', N'Samsung', N'Galaxy S22+ 5G 128GB Phantom White', N'R5CW66S22P', N'MÃ¡y phá»¥', '2026-10-17 10:01:02.706', N'TB000028');
INSERT INTO dbo.[Devices] ([DeviceId], [CustomerId], [DeviceType], [Brand], [Model], [SerialNumber], [Note], [CreatedAt], [DeviceCode]) VALUES (29, 27, N'Laptop', N'Dell', N'Latitude 7420 Core i7 / 16GB RAM', N'DL-TEST-1792897364095', NULL, '2026-10-25 10:02:44.105', N'TB000029');
INSERT INTO dbo.[Devices] ([DeviceId], [CustomerId], [DeviceType], [Brand], [Model], [SerialNumber], [Note], [CreatedAt], [DeviceCode]) VALUES (30, 28, N'Laptop', N'Dell', N'Latitude 7420 Core i7 / 16GB RAM', N'DL-TEST-1792897437996', NULL, '2026-10-25 10:03:58.004', N'TB000030');
INSERT INTO dbo.[Devices] ([DeviceId], [CustomerId], [DeviceType], [Brand], [Model], [SerialNumber], [Note], [CreatedAt], [DeviceCode]) VALUES (31, 29, N'Laptop', N'Dell', N'Latitude 7420 Core i7 / 16GB RAM', N'DL-TEST-1792897477961', NULL, '2026-10-25 10:04:37.975', N'TB000031');
SET IDENTITY_INSERT dbo.[Devices] OFF;
GO

-- ----------------------------------------------------
-- Bang: dbo.RepairTickets (28 rows)
-- ----------------------------------------------------
SET IDENTITY_INSERT dbo.[RepairTickets] ON;
INSERT INTO dbo.[RepairTickets] ([TicketId], [TicketCode], [CustomerId], [DeviceId], [ServiceTypeId], [ReceivedByUserId], [TechnicianUserId], [Status], [DeviceCondition], [CustomerRequest], [Diagnosis], [QuotedLaborCost], [QuotedPartsCost], [IsWarrantyRepair], [OriginalTicketId], [ReceivedAt], [ExpectedFinishAt], [CompletedAt], [DeliveredAt], [CancelReason], [CreatedAt], [UpdatedAt]) VALUES (1, N'PSC202610001', 1, 1, 3, 2, 3, N'COMPLETED', N'MÃ¡y cháº¡y khoáº£ng 15 phÃºt quáº¡t kÃªu to rÃº rÃ­t, nhiá»‡t Ä‘á»™ Ä‘o CPU 98Â°C, tá»± sáº­p nguá»“n khi render video Premiere.', N'KhÃ¡ch yÃªu cáº§u vá»‡ sinh toÃ n bá»™ mÃ¡y vÃ  thay loáº¡i keo táº£n nhiá»‡t tá»‘t nháº¥t.', N'Keo táº£n nhiá»‡t gá»‘c Ä‘Ã£ bá»‹ khÃ´ cá»©ng chai cá»©ng, cá»¥m lÃ¡ nhÃ´m táº£n nhiá»‡t ngháº¹t xÆ¡ bá»¥i. ÄÃ£ vá»‡ sinh quáº¡t kÃ©p, táº©y keo cÅ© vÃ  tra keo Thermal Grizzly Kryonaut. Stress test Cinebench R23 nhiá»‡t Ä‘á»™ á»•n Ä‘á»‹nh á»Ÿ 72Â°C.', 150000.00, 180000.00, 0, NULL, '2026-10-22 09:05:12.570', '2026-10-23 09:05:12.570', '2026-10-23 09:05:12.570', NULL, NULL, '2026-10-22 09:05:12.570', NULL);
INSERT INTO dbo.[RepairTickets] ([TicketId], [TicketCode], [CustomerId], [DeviceId], [ServiceTypeId], [ReceivedByUserId], [TechnicianUserId], [Status], [DeviceCondition], [CustomerRequest], [Diagnosis], [QuotedLaborCost], [QuotedPartsCost], [IsWarrantyRepair], [OriginalTicketId], [ReceivedAt], [ExpectedFinishAt], [CompletedAt], [DeliveredAt], [CancelReason], [CreatedAt], [UpdatedAt]) VALUES (2, N'PSC202610002', 2, 2, 1, 2, 4, N'REPAIRING', N'RÆ¡i cáº¥n gÃ³c bÃ n kÃ­nh ná»©t máº¡ng nhá»‡n, sá»c xanh dá»c mÃ©p pháº£i mÃ n hÃ¬nh, cáº£m á»©ng gÃ³c dÆ°á»›i bá»‹ Ä‘Æ¡ khÃ´ng pháº£n há»“i.', N'Thay mÃ n hÃ¬nh zin chÃ­nh hÃ£ng, cáº§n giá»¯ láº¡i tÃ­nh nÄƒng Face ID vÃ  True Tone.', N'Táº¥m ná»n OLED bá»‹ ráº¡n panel bÃªn trong. Äang thÃ¡o rÃ¡p thay cá»¥m mÃ n hÃ¬nh Super Retina XDR Zin, chuyá»ƒn chip IC mÃ n hÃ¬nh Ä‘á»ƒ giá»¯ nguyÃªn tÃ­nh nÄƒng True Tone.', 150000.00, 5600000.00, 0, NULL, '2026-10-23 09:05:12.570', '2026-10-26 09:05:12.570', NULL, NULL, NULL, '2026-10-23 09:05:12.570', NULL);
INSERT INTO dbo.[RepairTickets] ([TicketId], [TicketCode], [CustomerId], [DeviceId], [ServiceTypeId], [ReceivedByUserId], [TechnicianUserId], [Status], [DeviceCondition], [CustomerRequest], [Diagnosis], [QuotedLaborCost], [QuotedPartsCost], [IsWarrantyRepair], [OriginalTicketId], [ReceivedAt], [ExpectedFinishAt], [CompletedAt], [DeliveredAt], [CancelReason], [CreatedAt], [UpdatedAt]) VALUES (3, N'PSC202610003', 3, 3, 5, 2, 3, N'DIAGNOSING', N'Cáº¯m sáº¡c MagSafe 3 Ä‘Ã¨n nháº¥p nhÃ¡y cam rá»“i táº¯t háº³n, mÃ¡y hoÃ n toÃ n khÃ´ng lÃªn nguá»“n, pin khÃ´ng nháº­n dÃ²ng sáº¡c.', N'Kiá»ƒm tra vÃ  cá»©u dá»¯ liá»‡u Ä‘á»“ Ã¡n trong mÃ¡y gáº¥p.', N'Äo cháº¡m cháº­p tá»¥ lá»c Ä‘Æ°á»ng cáº¥p nguá»“n chÃ­nh PPBUS_AON 12.6V gáº§n cá»¥m cá»•ng Type-C Thunderbolt. Ká»¹ thuáº­t viÃªn Ä‘ang dÃ² nhiá»‡t FLIR vÃ  Ä‘o Ä‘áº¡c boardview cÃ¡ch ly linh kiá»‡n ngáº¯n máº¡ch.', 450000.00, 0.00, 0, NULL, '2026-10-24 09:05:12.570', '2026-10-27 09:05:12.570', NULL, NULL, NULL, '2026-10-24 09:05:12.570', NULL);
INSERT INTO dbo.[RepairTickets] ([TicketId], [TicketCode], [CustomerId], [DeviceId], [ServiceTypeId], [ReceivedByUserId], [TechnicianUserId], [Status], [DeviceCondition], [CustomerRequest], [Diagnosis], [QuotedLaborCost], [QuotedPartsCost], [IsWarrantyRepair], [OriginalTicketId], [ReceivedAt], [ExpectedFinishAt], [CompletedAt], [DeliveredAt], [CancelReason], [CreatedAt], [UpdatedAt]) VALUES (4, N'PSC202610004', 4, 4, 2, 2, 4, N'WAITING_CONFIRM', N'Pin bá»‹ chai phá»“ng nháº¹ Ä‘áº©y náº¯p lÆ°ng, sáº¡c pin ráº¥t nÃ³ng, dÃ¹ng cÃ²n 25-30% lÃ  sáº­p nguá»“n khá»Ÿi Ä‘á»™ng láº¡i.', N'BÃ¡o giÃ¡ pin chÃ­nh hÃ£ng vÃ  thá»i gian thay tháº¿.', N'Pin lithium Ä‘áº¡t chu ká»³ 860 láº§n sáº¡c, dung lÆ°á»£ng thá»±c táº¿ cÃ²n 64% so vá»›i ban Ä‘áº§u. Cáº§n thay pin Samsung Zin 5000mAh vÃ  dÃ¡n láº¡i ron chá»‘ng nÆ°á»›c khÃ¡ng bá»¥i tiÃªu chuáº©n IP68.', 100000.00, 680000.00, 0, NULL, '2026-10-24 09:05:12.570', '2026-10-26 09:05:12.570', NULL, NULL, NULL, '2026-10-24 09:05:12.570', NULL);
INSERT INTO dbo.[RepairTickets] ([TicketId], [TicketCode], [CustomerId], [DeviceId], [ServiceTypeId], [ReceivedByUserId], [TechnicianUserId], [Status], [DeviceCondition], [CustomerRequest], [Diagnosis], [QuotedLaborCost], [QuotedPartsCost], [IsWarrantyRepair], [OriginalTicketId], [ReceivedAt], [ExpectedFinishAt], [CompletedAt], [DeliveredAt], [CancelReason], [CreatedAt], [UpdatedAt]) VALUES (5, N'PSC202610005', 5, 5, 6, 2, 3, N'DELIVERED', N'Khá»Ÿi Ä‘á»™ng vÃ o Windows ráº¥t cháº­m (máº¥t hÆ¡n 4 phÃºt), chÆ¡i game giáº­t lag bá»‹ Ä‘á»©ng mÃ n hÃ¬nh xanh BSOD, á»• HDD cÅ© kÃªu láº¡ch cáº¡ch.', N'NÃ¢ng cáº¥p SSD NVMe tá»‘c Ä‘á»™ cao 1TB, chuyá»ƒn toÃ n bá»™ dá»¯ liá»‡u game vÃ  Windows cÅ© sang.', N'á»” HDD cÅ© bá»‹ bad sector náº·ng phÃ¢n vÃ¹ng C. ÄÃ£ sao lÆ°u dá»¯ liá»‡u phÃ¢n vÃ¹ng D, láº¯p má»›i SSD Samsung 980 PRO 1TB NVMe Gen 4, cÃ i Windows 11 Pro 64-bit tá»‘i Æ°u hÃ³a cho gaming.', 120000.00, 2250000.00, 0, NULL, '2026-10-20 09:05:12.570', '2026-10-21 09:05:12.570', '2026-10-21 09:05:12.570', '2026-10-21 09:05:12.570', NULL, '2026-10-20 09:05:12.570', NULL);
INSERT INTO dbo.[RepairTickets] ([TicketId], [TicketCode], [CustomerId], [DeviceId], [ServiceTypeId], [ReceivedByUserId], [TechnicianUserId], [Status], [DeviceCondition], [CustomerRequest], [Diagnosis], [QuotedLaborCost], [QuotedPartsCost], [IsWarrantyRepair], [OriginalTicketId], [ReceivedAt], [ExpectedFinishAt], [CompletedAt], [DeliveredAt], [CancelReason], [CreatedAt], [UpdatedAt]) VALUES (6, N'PSC202610006', 6, 6, 3, 2, NULL, N'RECEIVED', N'Quáº¡t táº£n nhiá»‡t bÃªn GPU phÃ¡t ra tiáº¿ng kÃªu cá»c cá»c rÃ­t giÃ³ lá»›n, mÃ¡y chÆ¡i game bá»‹ tá»¥t xung nhá»‹p fps (thermal throttling).', N'KhÃ¡ch mang mÃ¡y Ä‘áº¿n gá»­i táº¡i quáº§y, yÃªu cáº§u kiá»ƒm tra vÃ  thay quáº¡t zin Ãªm Ã¡i.', NULL, 150000.00, 490000.00, 0, NULL, '2026-10-25 09:05:12.570', '2026-10-27 09:05:12.570', NULL, NULL, NULL, '2026-10-25 09:05:12.570', NULL);
INSERT INTO dbo.[RepairTickets] ([TicketId], [TicketCode], [CustomerId], [DeviceId], [ServiceTypeId], [ReceivedByUserId], [TechnicianUserId], [Status], [DeviceCondition], [CustomerRequest], [Diagnosis], [QuotedLaborCost], [QuotedPartsCost], [IsWarrantyRepair], [OriginalTicketId], [ReceivedAt], [ExpectedFinishAt], [CompletedAt], [DeliveredAt], [CancelReason], [CreatedAt], [UpdatedAt]) VALUES (7, N'PSC202610007', 7, 7, 7, 2, 4, N'DELIVERED', N'Cá»•ng sáº¡c Type-C bá»‹ gÃ£y chÃ¢n pin tiáº¿p xÃºc bÃªn trong do cáº¯m giáº­t máº¡nh cÃ¡p sáº¡c, mÃ¡y khÃ´ng nháº­n sáº¡c vÃ  khÃ´ng káº¿t ná»‘i Ä‘Æ°á»£c mÃ¡y tÃ­nh Mac.', N'Thay cá»¥m sáº¡c Type-C zin mÃ¡y, giá»¯ micro thu Ã¢m gá»‘c.', N'Cá»•ng sáº¡c Type-C rÃ¡ch bo cÃ¡p flex. ÄÃ£ thay cá»¥m cÃ¡p sáº¡c Type-C má»›i, test sáº¡c nhanh PD 30W vÃ  truyá»n dá»¯ liá»‡u iTunes 100% bÃ¬nh thÆ°á»ng.', 150000.00, 620000.00, 0, NULL, '2026-10-21 09:05:12.570', '2026-10-22 09:05:12.570', '2026-10-22 09:05:12.570', '2026-10-22 09:05:12.570', NULL, '2026-10-21 09:05:12.570', NULL);
INSERT INTO dbo.[RepairTickets] ([TicketId], [TicketCode], [CustomerId], [DeviceId], [ServiceTypeId], [ReceivedByUserId], [TechnicianUserId], [Status], [DeviceCondition], [CustomerRequest], [Diagnosis], [QuotedLaborCost], [QuotedPartsCost], [IsWarrantyRepair], [OriginalTicketId], [ReceivedAt], [ExpectedFinishAt], [CompletedAt], [DeliveredAt], [CancelReason], [CreatedAt], [UpdatedAt]) VALUES (8, N'PSC202610008', 8, 8, 9, 2, 3, N'RECEIVED', N'Bá»‹ Ä‘á»• nÆ°á»›c ngá»t lÃªn cá»¥m phÃ­m, má»™t hÃ ng phÃ­m ASDFG vÃ  phÃ­m Space bá»‹ dÃ­nh káº¹t cá»©ng, cháº­p tá»± Ä‘á»™ng gÃµ liÃªn tá»¥c chá»¯ D.', N'Thay bÃ n phÃ­m ThinkPad chÃ­nh hÃ£ng cÃ³ Ä‘Ã¨n led ná»n.', N'Tiáº¿p nháº­n táº¡i quáº§y, thÃ¡o pin kháº©n cáº¥p chá»‘ng cháº­p máº¡ch main, cáº§n thay cá»¥m bÃ n phÃ­m ThinkPad Led US má»›i.', 120000.00, 950000.00, 0, NULL, '2026-10-25 09:05:12.570', '2026-10-26 09:05:12.570', NULL, NULL, NULL, '2026-10-25 09:05:12.570', NULL);
INSERT INTO dbo.[RepairTickets] ([TicketId], [TicketCode], [CustomerId], [DeviceId], [ServiceTypeId], [ReceivedByUserId], [TechnicianUserId], [Status], [DeviceCondition], [CustomerRequest], [Diagnosis], [QuotedLaborCost], [QuotedPartsCost], [IsWarrantyRepair], [OriginalTicketId], [ReceivedAt], [ExpectedFinishAt], [CompletedAt], [DeliveredAt], [CancelReason], [CreatedAt], [UpdatedAt]) VALUES (9, N'PSC202610009', 9, 9, 2, 2, 4, N'DELIVERED', N'BÃ¡o pin báº£o trÃ¬ trong CÃ i Ä‘áº·t (Dung lÆ°á»£ng tá»‘i Ä‘a 71%), dÃ¹ng ná»­a ngÃ y lÃ  háº¿t pin.', N'Thay pin Pisen chÃ­nh hÃ£ng báº£o hÃ nh dÃ i háº¡n.', N'ÄÃ£ thay pin Pisen dung lÆ°á»£ng cao chÃ­nh hÃ£ng, test chu ká»³ sáº¡c 100%, sáº¡c Ä‘áº§y ngáº¯t sáº¡c tá»± Ä‘á»™ng tá»‘t.', 100000.00, 750000.00, 0, NULL, '2026-10-23 09:05:12.570', '2026-10-23 09:05:12.570', '2026-10-23 09:05:12.570', '2026-10-23 09:05:12.570', NULL, '2026-10-23 09:05:12.570', NULL);
INSERT INTO dbo.[RepairTickets] ([TicketId], [TicketCode], [CustomerId], [DeviceId], [ServiceTypeId], [ReceivedByUserId], [TechnicianUserId], [Status], [DeviceCondition], [CustomerRequest], [Diagnosis], [QuotedLaborCost], [QuotedPartsCost], [IsWarrantyRepair], [OriginalTicketId], [ReceivedAt], [ExpectedFinishAt], [CompletedAt], [DeliveredAt], [CancelReason], [CreatedAt], [UpdatedAt]) VALUES (10, N'PSC202610010', 10, 10, 4, 2, 3, N'DELIVERED', N'MÃ¡y cháº¡y Ä‘Æ¡ cháº­m, má»Ÿ 10 tab Chrome vÃ  Photoshop bá»‹ trÃ n RAM bÃ¡o lá»—i Out of Memory.', N'NÃ¢ng cáº¥p RAM vÃ  vá»‡ sinh thá»•i bá»¥i.', N'NÃ¢ng cáº¥p thanh RAM 16GB Kingston DDR4 3200MHz, mÃ¡y nháº­n Ä‘á»§ RAM cháº¡y mÆ°á»£t mÃ  Ä‘a nhiá»‡m.', 100000.00, 890000.00, 0, NULL, '2026-10-24 09:05:12.570', '2026-10-24 09:05:12.570', '2026-10-24 09:05:12.570', '2026-10-24 09:05:12.570', NULL, '2026-10-24 09:05:12.570', NULL);
INSERT INTO dbo.[RepairTickets] ([TicketId], [TicketCode], [CustomerId], [DeviceId], [ServiceTypeId], [ReceivedByUserId], [TechnicianUserId], [Status], [DeviceCondition], [CustomerRequest], [Diagnosis], [QuotedLaborCost], [QuotedPartsCost], [IsWarrantyRepair], [OriginalTicketId], [ReceivedAt], [ExpectedFinishAt], [CompletedAt], [DeliveredAt], [CancelReason], [CreatedAt], [UpdatedAt]) VALUES (11, N'PSC202610011', 11, 11, 8, 2, 4, N'WAITING_CONFIRM', N'MÃ¡y bá»‹ rÆ¡i ná»©t máº¡ng nhá»‡n gÃ³c trÃªn kÃ­nh báº£o vá»‡, hiá»ƒn thá»‹ vÃ  cáº£m á»©ng Ä‘a Ä‘iá»ƒm váº«n mÆ°á»£t mÃ  khÃ´ng bá»‹ káº» sá»c.', N'Ã‰p kÃ­nh zin giá»¯ nguyÃªn mÃ n hÃ¬nh gá»‘c Dynamic Island.', N'KÃ­nh ngoÃ i ráº¡n vá»¡, phÃ´i mÃ n hÃ¬nh OLED vÃ  cáº£m á»©ng 120Hz hoÃ n toÃ n bÃ¬nh thÆ°á»ng. ÄÃ£ tÆ° váº¥n khÃ¡ch phÆ°Æ¡ng Ã¡n Ã©p kÃ­nh chÃ¢n khÃ´ng cÃ´ng nghá»‡ OCA chá»‘ng bá»t.', 250000.00, 450000.00, 0, NULL, '2026-10-24 10:01:02.710', '2026-10-26 10:01:02.710', NULL, NULL, NULL, '2026-10-24 10:01:02.710', NULL);
INSERT INTO dbo.[RepairTickets] ([TicketId], [TicketCode], [CustomerId], [DeviceId], [ServiceTypeId], [ReceivedByUserId], [TechnicianUserId], [Status], [DeviceCondition], [CustomerRequest], [Diagnosis], [QuotedLaborCost], [QuotedPartsCost], [IsWarrantyRepair], [OriginalTicketId], [ReceivedAt], [ExpectedFinishAt], [CompletedAt], [DeliveredAt], [CancelReason], [CreatedAt], [UpdatedAt]) VALUES (12, N'PSC202610012', 12, 12, 2, 2, 3, N'REPAIRING', N'Pin bÃ¡o Service Recommended, chu ká»³ sáº¡c 950 láº§n, dÃ¹ng vÄƒn phÃ²ng chá»‰ Ä‘Æ°á»£c hÆ¡n 1.5 tiáº¿ng lÃ  bÃ¡o pin yáº¿u.', N'Thay pin chÃ­nh hÃ£ng vÃ  vá»‡ sinh bo máº¡ch.', N'Pin bá»‹ phÃ¹ nháº¹ khoang giá»¯a. Ká»¹ thuáº­t viÃªn Ä‘ang thÃ¡o rÃ¡p thay cell pin má»›i, dÃ¡n keo seal chá»‘ng rung vÃ  cÄƒn chá»‰nh máº¡ch BMS.', 100000.00, 1250000.00, 0, NULL, '2026-10-24 10:01:02.710', '2026-10-26 10:01:02.710', NULL, NULL, NULL, '2026-10-24 10:01:02.710', NULL);
INSERT INTO dbo.[RepairTickets] ([TicketId], [TicketCode], [CustomerId], [DeviceId], [ServiceTypeId], [ReceivedByUserId], [TechnicianUserId], [Status], [DeviceCondition], [CustomerRequest], [Diagnosis], [QuotedLaborCost], [QuotedPartsCost], [IsWarrantyRepair], [OriginalTicketId], [ReceivedAt], [ExpectedFinishAt], [CompletedAt], [DeliveredAt], [CancelReason], [CreatedAt], [UpdatedAt]) VALUES (13, N'PSC202610013', 13, 13, 3, 2, 3, N'COMPLETED', N'Nhiá»‡t Ä‘á»™ GPU lÃªn 89Â°C khi chÆ¡i CS2, mÃ¡y tá»± háº¡ xung nhá»‹p gÃ¢y giáº­t lag tá»¥t FPS.', N'Vá»‡ sinh toÃ n bá»™ quáº¡t vÃ  tra keo gá»‘m loáº¡i xá»‹n nháº¥t.', N'Há»‡ thá»‘ng táº£n nhiá»‡t bÃ¡m dÃ y sá»£i bÃ´ng bá»¥i. ÄÃ£ vá»‡ sinh quáº¡t kÃ©p, tra keo gá»‘m Kryonaut, nhiá»‡t Ä‘á»™ GPU giáº£m sÃ¢u cÃ²n 74Â°C khi táº£i 100%.', 150000.00, 180000.00, 0, NULL, '2026-10-23 10:01:02.710', '2026-10-24 10:01:02.710', '2026-10-24 10:01:02.710', NULL, NULL, '2026-10-23 10:01:02.710', NULL);
INSERT INTO dbo.[RepairTickets] ([TicketId], [TicketCode], [CustomerId], [DeviceId], [ServiceTypeId], [ReceivedByUserId], [TechnicianUserId], [Status], [DeviceCondition], [CustomerRequest], [Diagnosis], [QuotedLaborCost], [QuotedPartsCost], [IsWarrantyRepair], [OriginalTicketId], [ReceivedAt], [ExpectedFinishAt], [CompletedAt], [DeliveredAt], [CancelReason], [CreatedAt], [UpdatedAt]) VALUES (14, N'PSC202610014', 14, 14, 1, 2, 4, N'DELIVERED', N'RÆ¡i rá»›t nÆ°á»›c ngáº¥m viá»n dÆ°á»›i, mÃ n hÃ¬nh Ä‘en thui chá»›p nhÃ¡y sá»c tráº¯ng, mÃ¡y váº«n Ä‘á»• chuÃ´ng cuá»™c gá»i Ä‘áº¿n.', N'Thay mÃ n hÃ¬nh cháº¥t lÆ°á»£ng cao, giá»¯ Face ID.', N'Cháº­p panel cÃ¡p tÃ­n hiá»‡u MIPI. ÄÃ£ thay tháº¿ mÃ n hÃ¬nh OLED Super Retina, sang IC gá»‘c giá»¯ True Tone, test cáº£m á»©ng vÃ  Face ID hoáº¡t Ä‘á»™ng hoÃ n háº£o.', 150000.00, 3200000.00, 0, NULL, '2026-10-21 10:01:02.710', '2026-10-22 10:01:02.710', '2026-10-22 10:01:02.710', '2026-10-22 10:01:02.710', NULL, '2026-10-21 10:01:02.710', NULL);
INSERT INTO dbo.[RepairTickets] ([TicketId], [TicketCode], [CustomerId], [DeviceId], [ServiceTypeId], [ReceivedByUserId], [TechnicianUserId], [Status], [DeviceCondition], [CustomerRequest], [Diagnosis], [QuotedLaborCost], [QuotedPartsCost], [IsWarrantyRepair], [OriginalTicketId], [ReceivedAt], [ExpectedFinishAt], [CompletedAt], [DeliveredAt], [CancelReason], [CreatedAt], [UpdatedAt]) VALUES (15, N'PSC202610015', 15, 15, 6, 2, 3, N'COMPLETED', N'á»” cá»©ng SSD cÅ© chá»‰ cÃ³ 256GB bá»‹ Ä‘áº§y dung lÆ°á»£ng, render video Premiere bÃ¡o disk full khÃ´ng xuáº¥t file Ä‘Æ°á»£c.', N'Láº¯p thÃªm SSD NVMe 1TB Samsung 980 PRO Gen 4 tá»‘c Ä‘á»™ cao Ä‘á»ƒ lÃ m á»• cache Ä‘á»“ há»a.', N'ÄÃ£ láº¯p Ä‘áº·t SSD Samsung 980 PRO 1TB vÃ o khe M.2 PCIe 4.0 trÃªn mainboard ASUS Z790, Ä‘á»‹nh dáº¡ng NTFS, benchmark tá»‘c Ä‘á»™ Ä‘á»c Ä‘áº¡t 6950 MB/s.', 120000.00, 2250000.00, 0, NULL, '2026-10-24 10:01:02.710', '2026-10-25 10:01:02.710', '2026-10-25 10:01:02.710', NULL, NULL, '2026-10-24 10:01:02.710', NULL);
INSERT INTO dbo.[RepairTickets] ([TicketId], [TicketCode], [CustomerId], [DeviceId], [ServiceTypeId], [ReceivedByUserId], [TechnicianUserId], [Status], [DeviceCondition], [CustomerRequest], [Diagnosis], [QuotedLaborCost], [QuotedPartsCost], [IsWarrantyRepair], [OriginalTicketId], [ReceivedAt], [ExpectedFinishAt], [CompletedAt], [DeliveredAt], [CancelReason], [CreatedAt], [UpdatedAt]) VALUES (16, N'PSC202610016', 16, 16, 4, 2, 3, N'DELIVERED', N'MÃ¡y bá»‹ nhiá»…m virus mÃ£ Ä‘á»™c quáº£ng cÃ¡o, má»Ÿ trÃ¬nh duyá»‡t tá»± nháº£y tab lá»«a Ä‘áº£o, mÃ¡y khá»Ÿi Ä‘á»™ng máº¥t 3 phÃºt.', N'Format sáº¡ch sáº½ cÃ i láº¡i Windows 11 Pro 64-bit vÃ  Office báº£n quyá»n.', N'ÄÃ£ sao lÆ°u thÆ° má»¥c tÃ i liá»‡u Desktop/Documents, phÃ¢n vÃ¹ng láº¡i á»• cá»©ng GPT, cÃ i Ä‘áº·t Windows 11 Pro sáº¡ch, kÃ­ch hoáº¡t báº£o máº­t BitLocker.', 100000.00, 0.00, 0, NULL, '2026-10-22 10:01:02.710', '2026-10-23 10:01:02.710', '2026-10-23 10:01:02.710', '2026-10-23 10:01:02.710', NULL, '2026-10-22 10:01:02.710', NULL);
INSERT INTO dbo.[RepairTickets] ([TicketId], [TicketCode], [CustomerId], [DeviceId], [ServiceTypeId], [ReceivedByUserId], [TechnicianUserId], [Status], [DeviceCondition], [CustomerRequest], [Diagnosis], [QuotedLaborCost], [QuotedPartsCost], [IsWarrantyRepair], [OriginalTicketId], [ReceivedAt], [ExpectedFinishAt], [CompletedAt], [DeliveredAt], [CancelReason], [CreatedAt], [UpdatedAt]) VALUES (17, N'PSC202610017', 17, 17, 5, 2, 4, N'DIAGNOSING', N'Má»Ÿ gáº­p mÃ¡y ra thÃ¬ mÃ n hÃ¬nh trong chá»›p táº¯t máº¥t hiá»ƒn thá»‹, gáº­p láº¡i dÃ¹ng mÃ n hÃ¬nh ngoÃ i thÃ¬ bÃ¬nh thÆ°á»ng.', N'Kiá»ƒm tra cÃ¡p flex báº£n lá» vÃ  bÃ¡o giÃ¡ trÆ°á»›c khi lÃ m.', N'Äá»©t ngáº§m Ä‘Æ°á»ng tÃ­n hiá»‡u cÃ¡p flex ná»‘i giá»¯a 2 ná»­a thÃ¢n mÃ¡y qua trá»¥c báº£n lá». Ká»¹ thuáº­t viÃªn Ä‘ang kiá»ƒm tra má»©c Ä‘á»™ tá»•n thÆ°Æ¡ng bo máº¡ch phá»¥.', 450000.00, 0.00, 0, NULL, '2026-10-25 10:01:02.710', '2026-10-27 10:01:02.710', NULL, NULL, NULL, '2026-10-25 10:01:02.710', NULL);
INSERT INTO dbo.[RepairTickets] ([TicketId], [TicketCode], [CustomerId], [DeviceId], [ServiceTypeId], [ReceivedByUserId], [TechnicianUserId], [Status], [DeviceCondition], [CustomerRequest], [Diagnosis], [QuotedLaborCost], [QuotedPartsCost], [IsWarrantyRepair], [OriginalTicketId], [ReceivedAt], [ExpectedFinishAt], [CompletedAt], [DeliveredAt], [CancelReason], [CreatedAt], [UpdatedAt]) VALUES (18, N'PSC202610018', 18, 18, 7, 2, NULL, N'RECEIVED', N'Cáº¯m sáº¡c qua Ä‘Ãªm bá»‹ quáº¹t chÃ¢n lÃ m gÃ£y cháº¥u Ä‘á»“ng bÃªn trong cá»•ng Type-C, hiá»‡n khÃ´ng nháº­n sáº¡c.', N'Tiáº¿p nháº­n kiá»ƒm tra thay bo cá»•ng sáº¡c zin.', NULL, 150000.00, 620000.00, 0, NULL, '2026-10-25 10:01:02.710', '2026-10-26 10:01:02.710', NULL, NULL, NULL, '2026-10-25 10:01:02.710', NULL);
INSERT INTO dbo.[RepairTickets] ([TicketId], [TicketCode], [CustomerId], [DeviceId], [ServiceTypeId], [ReceivedByUserId], [TechnicianUserId], [Status], [DeviceCondition], [CustomerRequest], [Diagnosis], [QuotedLaborCost], [QuotedPartsCost], [IsWarrantyRepair], [OriginalTicketId], [ReceivedAt], [ExpectedFinishAt], [CompletedAt], [DeliveredAt], [CancelReason], [CreatedAt], [UpdatedAt]) VALUES (19, N'PSC202610019', 19, 19, 9, 2, 3, N'COMPLETED', N'Bá»‹ Ä‘á»• nÆ°á»›c ngá»t dÃ­nh phÃ­m Enter vÃ  hÃ ng sá»‘, gÃµ má»™t phÃ­m nháº£y ra nhiá»u kÃ½ tá»± láº¡.', N'Thay cá»¥m phÃ­m má»›i chÃ­nh hÃ£ng cÃ³ Ä‘Ã¨n ná»n.', N'ÄÃ£ thay má»›i cá»¥m bÃ n phÃ­m Dell Inspiron cÃ³ Ä‘Ã¨n led ná»n, tÃ¡n Ä‘inh nhiá»‡t cá»‘ Ä‘á»‹nh cháº¯c cháº¯n, test toÃ n bá»™ 104 phÃ­m náº£y Ãªm chuáº©n xÃ¡c.', 120000.00, 950000.00, 0, NULL, '2026-10-24 10:01:02.710', '2026-10-25 10:01:02.710', '2026-10-25 10:01:02.710', NULL, NULL, '2026-10-24 10:01:02.710', NULL);
INSERT INTO dbo.[RepairTickets] ([TicketId], [TicketCode], [CustomerId], [DeviceId], [ServiceTypeId], [ReceivedByUserId], [TechnicianUserId], [Status], [DeviceCondition], [CustomerRequest], [Diagnosis], [QuotedLaborCost], [QuotedPartsCost], [IsWarrantyRepair], [OriginalTicketId], [ReceivedAt], [ExpectedFinishAt], [CompletedAt], [DeliveredAt], [CancelReason], [CreatedAt], [UpdatedAt]) VALUES (20, N'PSC202610020', 20, 20, 8, 2, 4, N'DELIVERED', N'Bá»‹ va chÃ¬a khÃ³a ná»©t máº·t kÃ­nh báº£o vá»‡ camera sau, chá»¥p áº£nh bá»‹ lÃ³a sÃ¡ng chÃ³i viá»n.', N'Thay máº·t kÃ­nh camera Sapphire chÃ­nh hÃ£ng.', N'Cá»¥m tháº¥u kÃ­nh bÃªn trong cÃ²n nguyÃªn váº¹n. ÄÃ£ bÃ³c lá»›p kÃ­nh ná»©t, hÃºt chÃ¢n khÃ´ng sáº¡ch bá»¥i cáº£m biáº¿n vÃ  dÃ¡n kÃ­nh Sapphire chá»‘ng tráº§y má»›i.', 150000.00, 280000.00, 0, NULL, '2026-10-23 10:01:02.710', '2026-10-24 10:01:02.710', '2026-10-24 10:01:02.710', '2026-10-24 10:01:02.710', NULL, '2026-10-23 10:01:02.710', NULL);
INSERT INTO dbo.[RepairTickets] ([TicketId], [TicketCode], [CustomerId], [DeviceId], [ServiceTypeId], [ReceivedByUserId], [TechnicianUserId], [Status], [DeviceCondition], [CustomerRequest], [Diagnosis], [QuotedLaborCost], [QuotedPartsCost], [IsWarrantyRepair], [OriginalTicketId], [ReceivedAt], [ExpectedFinishAt], [CompletedAt], [DeliveredAt], [CancelReason], [CreatedAt], [UpdatedAt]) VALUES (21, N'PSC202610021', 21, 21, 3, 2, 3, N'REPAIRING', N'DÃ¹ng render dá»±ng phim 8K quáº¡t hÃº to liÃªn tá»¥c, nhiá»‡t Ä‘á»™ bá» máº·t nhÃ´m kÃª tay ráº¥t nÃ³ng.', N'Vá»‡ sinh báº£o dÆ°á»¡ng Ä‘á»‹nh ká»³ buá»“ng hÆ¡i táº£n nhiá»‡t.', N'Bá»¥i má»‹n bÃ¡m kÃ­n lÃ¡ táº£n nhiá»‡t buá»“ng hÆ¡i Vapor Chamber. Äang tiáº¿n hÃ nh vá»‡ sinh siÃªu Ã¢m cÃ¡nh quáº¡t vÃ  thay má»¡ táº£n nhiá»‡t Ä‘áº·c thÃ¹ cho chip M3 Max.', 150000.00, 180000.00, 0, NULL, '2026-10-25 10:01:02.710', '2026-10-26 10:01:02.710', NULL, NULL, NULL, '2026-10-25 10:01:02.710', NULL);
INSERT INTO dbo.[RepairTickets] ([TicketId], [TicketCode], [CustomerId], [DeviceId], [ServiceTypeId], [ReceivedByUserId], [TechnicianUserId], [Status], [DeviceCondition], [CustomerRequest], [Diagnosis], [QuotedLaborCost], [QuotedPartsCost], [IsWarrantyRepair], [OriginalTicketId], [ReceivedAt], [ExpectedFinishAt], [CompletedAt], [DeliveredAt], [CancelReason], [CreatedAt], [UpdatedAt]) VALUES (22, N'PSC202610022', 22, 22, 10, 2, 3, N'DIAGNOSING', N'MÃ¡y bá»‹ rÆ¡i tá»« trÃªn bÃ n lÃ m viá»‡c xuá»‘ng Ä‘áº¥t, báº­t nguá»“n Ä‘Ã¨n bÃ¡o chá»›p rá»“i vÃ o tháº³ng BIOS khÃ´ng nháº­n á»• cá»©ng.', N'Cá»©u toÃ n bá»™ dá»¯ liá»‡u Ä‘á»“ Ã¡n tá»‘t nghiá»‡p trong á»• cá»©ng.', N'á»” cá»©ng SSD NVMe cháº­p tá»¥ nguá»“n báº£o vá»‡ cá»•ng M.2, ká»¹ thuáº­t viÃªn Ä‘ang cÃ¢u dÃ¢y bypass Ä‘Æ°á»ng 3.3V Ä‘á»ƒ Ä‘á»c chip nhá»› NAND flash.', 500000.00, 0.00, 0, NULL, '2026-10-25 10:01:02.710', '2026-10-27 10:01:02.710', NULL, NULL, NULL, '2026-10-25 10:01:02.710', NULL);
INSERT INTO dbo.[RepairTickets] ([TicketId], [TicketCode], [CustomerId], [DeviceId], [ServiceTypeId], [ReceivedByUserId], [TechnicianUserId], [Status], [DeviceCondition], [CustomerRequest], [Diagnosis], [QuotedLaborCost], [QuotedPartsCost], [IsWarrantyRepair], [OriginalTicketId], [ReceivedAt], [ExpectedFinishAt], [CompletedAt], [DeliveredAt], [CancelReason], [CreatedAt], [UpdatedAt]) VALUES (23, N'PSC202610023', 23, 23, 2, 2, 4, N'DELIVERED', N'Pin chai 68%, sáº¡c Ä‘áº§y dÃ¹ng Ä‘Æ°á»£c khoáº£ng 2 tiáº¿ng lÃ  háº¿t, mÃ¡y hay bá»‹ áº¥m vÃ¹ng pin.', N'Thay pin Pisen chÃ­nh hÃ£ng báº£o hÃ nh dÃ i háº¡n.', N'ÄÃ£ thay pin Pisen dung lÆ°á»£ng cao 3110mAh, kÃ­ch pin chuáº©n chu ká»³ 0 láº§n, kiá»ƒm tra sáº¡c xáº£ á»•n Ä‘á»‹nh.', 100000.00, 580000.00, 0, NULL, '2026-10-22 10:01:02.710', '2026-10-23 10:01:02.710', '2026-10-23 10:01:02.710', '2026-10-23 10:01:02.710', NULL, '2026-10-22 10:01:02.710', NULL);
INSERT INTO dbo.[RepairTickets] ([TicketId], [TicketCode], [CustomerId], [DeviceId], [ServiceTypeId], [ReceivedByUserId], [TechnicianUserId], [Status], [DeviceCondition], [CustomerRequest], [Diagnosis], [QuotedLaborCost], [QuotedPartsCost], [IsWarrantyRepair], [OriginalTicketId], [ReceivedAt], [ExpectedFinishAt], [CompletedAt], [DeliveredAt], [CancelReason], [CreatedAt], [UpdatedAt]) VALUES (24, N'PSC202610024', 24, 24, 6, 2, 3, N'DELIVERED', N'Khá»Ÿi Ä‘á»™ng vÃ o Windows máº¥t gáº§n 5 phÃºt, má»Ÿ file Excel bÃ¡o not responding do á»• HDD cÅ© quay 5400rpm.', N'Thay tháº¿ báº±ng SSD Kingston NV2 512GB tá»‘c Ä‘á»™ cao.', N'ÄÃ£ sao chÃ©p toÃ n bá»™ dá»¯ liá»‡u ngÆ°á»i dÃ¹ng, láº¯p SSD Kingston NV2 PCIe 4.0, khá»Ÿi Ä‘á»™ng mÃ¡y chá»‰ máº¥t 8 giÃ¢y.', 120000.00, 950000.00, 0, NULL, '2026-10-23 10:01:02.710', '2026-10-24 10:01:02.710', '2026-10-24 10:01:02.710', '2026-10-24 10:01:02.710', NULL, '2026-10-23 10:01:02.710', NULL);
INSERT INTO dbo.[RepairTickets] ([TicketId], [TicketCode], [CustomerId], [DeviceId], [ServiceTypeId], [ReceivedByUserId], [TechnicianUserId], [Status], [DeviceCondition], [CustomerRequest], [Diagnosis], [QuotedLaborCost], [QuotedPartsCost], [IsWarrantyRepair], [OriginalTicketId], [ReceivedAt], [ExpectedFinishAt], [CompletedAt], [DeliveredAt], [CancelReason], [CreatedAt], [UpdatedAt]) VALUES (25, N'PSC202610025', 25, 25, 5, 2, 3, N'CANCELLED', N'MÃ n hÃ¬nh iMac tá»± nhiÃªn tá»‘i Ä‘en, Ä‘Ã¨n bÃ¡o nguá»“n mÃ¡y váº«n sÃ¡ng nhÆ°ng khÃ´ng hiá»ƒn thá»‹ gÃ¬.', N'Kiá»ƒm tra bÃ¡o giÃ¡ thay tháº¿ linh kiá»‡n.', N'Cháº­p cá»¥m driver LED backlight trÃªn táº¥m ná»n mÃ n hÃ¬nh 4.5K Retina, cáº§n thay tháº¿ cáº£ cá»¥m mÃ n hÃ¬nh hÃ£ng chi phÃ­ cao.', 450000.00, 7900000.00, 0, NULL, '2026-10-22 10:01:02.710', '2026-10-24 10:01:02.710', NULL, NULL, N'KhÃ¡ch khÃ´ng Ä‘á»“ng Ã½ thay tháº¿ cá»¥m mÃ n hÃ¬nh do chi phÃ­ linh kiá»‡n chÃ­nh hÃ£ng vÆ°á»£t ngÃ¢n sÃ¡ch dá»± kiáº¿n.', '2026-10-22 10:01:02.710', NULL);
INSERT INTO dbo.[RepairTickets] ([TicketId], [TicketCode], [CustomerId], [DeviceId], [ServiceTypeId], [ReceivedByUserId], [TechnicianUserId], [Status], [DeviceCondition], [CustomerRequest], [Diagnosis], [QuotedLaborCost], [QuotedPartsCost], [IsWarrantyRepair], [OriginalTicketId], [ReceivedAt], [ExpectedFinishAt], [CompletedAt], [DeliveredAt], [CancelReason], [CreatedAt], [UpdatedAt]) VALUES (26, N'PSC2026100026', 27, 29, 3, 2, NULL, N'DELIVERED', N'MÃ¡y nÃ³ng ran, quáº¡t kÃªu rÃ­t, tá»± sáº­p khi cháº¡y náº·ng', NULL, N'Quáº¡t táº£n nhiá»‡t ngháº¹t xÆ¡ bá»¥i, keo táº£n nhiá»‡t CPU Ä‘Ã£ khÃ´ cá»©ng. Cáº§n vá»‡ sinh quáº¡t kÃ©p vÃ  tra keo Kryonaut.', 150000.00, 0.00, 0, NULL, '2026-10-25 10:02:44.140', NULL, '2026-10-25 10:02:44.380', '2026-10-25 10:02:44.532', NULL, '2026-10-25 10:02:44.140', '2026-10-25 10:02:44.532');
INSERT INTO dbo.[RepairTickets] ([TicketId], [TicketCode], [CustomerId], [DeviceId], [ServiceTypeId], [ReceivedByUserId], [TechnicianUserId], [Status], [DeviceCondition], [CustomerRequest], [Diagnosis], [QuotedLaborCost], [QuotedPartsCost], [IsWarrantyRepair], [OriginalTicketId], [ReceivedAt], [ExpectedFinishAt], [CompletedAt], [DeliveredAt], [CancelReason], [CreatedAt], [UpdatedAt]) VALUES (27, N'PSC2026100027', 28, 30, 3, 2, NULL, N'DELIVERED', N'MÃ¡y nÃ³ng ran, quáº¡t kÃªu rÃ­t, tá»± sáº­p khi cháº¡y náº·ng', NULL, N'Quáº¡t táº£n nhiá»‡t ngháº¹t xÆ¡ bá»¥i, keo táº£n nhiá»‡t CPU Ä‘Ã£ khÃ´ cá»©ng. Cáº§n vá»‡ sinh quáº¡t kÃ©p vÃ  tra keo Kryonaut.', 150000.00, 0.00, 0, NULL, '2026-10-25 10:03:58.084', NULL, '2026-10-25 10:03:58.420', '2026-10-25 10:03:58.696', NULL, '2026-10-25 10:03:58.084', '2026-10-25 10:03:58.696');
INSERT INTO dbo.[RepairTickets] ([TicketId], [TicketCode], [CustomerId], [DeviceId], [ServiceTypeId], [ReceivedByUserId], [TechnicianUserId], [Status], [DeviceCondition], [CustomerRequest], [Diagnosis], [QuotedLaborCost], [QuotedPartsCost], [IsWarrantyRepair], [OriginalTicketId], [ReceivedAt], [ExpectedFinishAt], [CompletedAt], [DeliveredAt], [CancelReason], [CreatedAt], [UpdatedAt]) VALUES (28, N'PSC2026100028', 29, 31, 3, 2, NULL, N'DELIVERED', N'MÃ¡y nÃ³ng ran, quáº¡t kÃªu rÃ­t, tá»± sáº­p khi cháº¡y náº·ng', NULL, N'Quáº¡t táº£n nhiá»‡t ngháº¹t xÆ¡ bá»¥i, keo táº£n nhiá»‡t CPU Ä‘Ã£ khÃ´ cá»©ng. Cáº§n vá»‡ sinh quáº¡t kÃ©p vÃ  tra keo Kryonaut.', 150000.00, 0.00, 0, NULL, '2026-10-25 10:04:37.995', NULL, '2026-10-25 10:04:38.098', '2026-10-25 10:04:38.159', NULL, '2026-10-25 10:04:37.995', '2026-10-25 10:04:38.159');
SET IDENTITY_INSERT dbo.[RepairTickets] OFF;
GO

-- ----------------------------------------------------
-- Bang: dbo.TicketStatusHistory (64 rows)
-- ----------------------------------------------------
SET IDENTITY_INSERT dbo.[TicketStatusHistory] ON;
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (1, 1, NULL, N'RECEIVED', 2, N'Tiáº¿p nháº­n mÃ¡y Dell XPS 15 tá»« khÃ¡ch Nguyá»…n ThÃ nh Nam táº¡i quáº§y', '2026-10-22 09:05:12.570');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (2, 1, N'RECEIVED', N'DIAGNOSING', 3, N'Ká»¹ thuáº­t viÃªn Pháº¡m VÄƒn Ká»¹ Thuáº­t nháº­n mÃ¡y Ä‘o nhiá»‡t Ä‘á»™ táº£i cao', '2026-10-22 09:05:12.570');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (3, 1, N'DIAGNOSING', N'COMPLETED', 3, N'HoÃ n thÃ nh vá»‡ sinh tra keo táº£n nhiá»‡t Kryonaut, test nhiá»‡t Ä‘á»™ mÃ¡t 72 Ä‘á»™ C', '2026-10-23 09:05:12.570');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (4, 2, NULL, N'RECEIVED', 2, N'Tiáº¿p nháº­n iPhone 14 Pro Max vá»¡ kÃ­nh mÃ©p bÃ n', '2026-10-23 09:05:12.570');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (5, 2, N'RECEIVED', N'REPAIRING', 4, N'KTV Nguyá»…n Äáº¡i Ká»³ tiáº¿n hÃ nh thay mÃ n hÃ¬nh OLED Zin bÃ³c mÃ¡y', '2026-10-24 09:05:12.570');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (6, 3, NULL, N'RECEIVED', 2, N'Tiáº¿p nháº­n MacBook Pro 14 khÃ´ng lÃªn nguá»“n', '2026-10-24 09:05:12.570');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (7, 3, N'RECEIVED', N'DIAGNOSING', 3, N'Äo Ä‘áº¡c sÆ¡ Ä‘á»“ boardview vÃ  dÃ² nhiá»‡t FLIR tá»¥ nguá»“n PPBUS_AON', '2026-10-25 03:05:12.570');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (8, 4, NULL, N'RECEIVED', 2, N'Tiáº¿p nháº­n Galaxy S23 Ultra pin phá»“ng', '2026-10-24 09:05:12.570');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (9, 4, N'RECEIVED', N'WAITING_CONFIRM', 2, N'Gá»­i bÃ¡o giÃ¡ thay pin 780.000Ä‘ qua Zalo cho khÃ¡ch VÃµ HoÃ i ThÆ°Æ¡ng', '2026-10-25 05:05:12.570');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (10, 5, NULL, N'RECEIVED', 2, N'Tiáº¿p nháº­n PC Gaming lá»—i mÃ n hÃ¬nh xanh BSOD', '2026-10-20 09:05:12.570');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (11, 5, N'RECEIVED', N'COMPLETED', 3, N'Láº¯p Ä‘áº·t SSD Samsung 980 PRO 1TB vÃ  cÃ i Windows 11', '2026-10-21 09:05:12.570');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (12, 5, N'COMPLETED', N'DELIVERED', 2, N'KhÃ¡ch kiá»ƒm tra mÃ¡y Æ°ng Ã½, thanh toÃ¡n chuyá»ƒn khoáº£n vÃ  nháº­n mÃ¡y', '2026-10-21 09:05:12.570');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (13, 6, NULL, N'RECEIVED', 2, N'Tiáº¿p nháº­n mÃ¡y Asus ROG Zephyrus G14 gÃ£y cÃ¡nh quáº¡t', '2026-10-25 09:05:12.570');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (14, 7, NULL, N'RECEIVED', 2, N'Tiáº¿p nháº­n iPad Pro 11 há»ng chÃ¢n sáº¡c Type-C', '2026-10-21 09:05:12.570');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (15, 7, N'RECEIVED', N'DELIVERED', 2, N'BÃ n giao iPad Pro sau khi thay cÃ¡p sáº¡c Type-C chuáº©n PD', '2026-10-22 09:05:12.570');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (16, 8, NULL, N'RECEIVED', 2, N'Tiáº¿p nháº­n ThinkPad X1 káº¹t phÃ­m cÃ  phÃª', '2026-10-25 09:05:12.570');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (17, 9, NULL, N'DELIVERED', 2, N'ÄÃ£ hoÃ n thÃ nh thay pin iPhone 13 vÃ  giao khÃ¡ch', '2026-10-23 09:05:12.570');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (18, 10, NULL, N'DELIVERED', 2, N'ÄÃ£ nÃ¢ng cáº¥p RAM Kingston vÃ  thanh toÃ¡n tiá»n máº·t', '2026-10-24 09:05:12.570');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (19, 11, NULL, N'RECEIVED', 2, N'Tiáº¿p nháº­n iPhone 15 Pro Max vá»¡ kÃ­nh mÃ©p', '2026-10-24 10:01:02.716');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (20, 11, N'RECEIVED', N'WAITING_CONFIRM', 2, N'BÃ¡o giÃ¡ Ã©p kÃ­nh 700.000Ä‘ cho khÃ¡ch qua Ä‘iá»‡n thoáº¡i', '2026-10-25 05:01:02.716');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (21, 12, NULL, N'RECEIVED', 2, N'Tiáº¿p nháº­n MacBook Air M1 chai pin', '2026-10-24 10:01:02.716');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (22, 12, N'RECEIVED', N'REPAIRING', 3, N'Tiáº¿n hÃ nh thÃ¡o cá»¥m pin cÅ© thay tháº¿ pin má»›i', '2026-10-25 02:01:02.716');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (23, 13, NULL, N'RECEIVED', 2, N'Tiáº¿p nháº­n Asus TUF nhiá»‡t Ä‘á»™ cao', '2026-10-23 10:01:02.716');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (24, 13, N'RECEIVED', N'COMPLETED', 3, N'Vá»‡ sinh tra keo Kryonaut mÃ¡t 74 Ä‘á»™ C', '2026-10-24 10:01:02.716');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (25, 14, NULL, N'RECEIVED', 2, N'Tiáº¿p nháº­n iPhone 12 Pro sá»c mÃ n hÃ¬nh', '2026-10-21 10:01:02.716');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (26, 14, N'RECEIVED', N'COMPLETED', 4, N'Thay mÃ n hÃ¬nh OLED hoÃ n táº¥t test OK', '2026-10-22 10:01:02.716');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (27, 14, N'COMPLETED', N'DELIVERED', 2, N'KhÃ¡ch Ä‘Ã£ thanh toÃ¡n nháº­n mÃ¡y', '2026-10-22 10:01:02.716');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (28, 15, NULL, N'RECEIVED', 2, N'Tiáº¿p nháº­n PC Workstation nÃ¢ng cáº¥p SSD', '2026-10-24 10:01:02.716');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (29, 15, N'RECEIVED', N'COMPLETED', 3, N'Láº¯p Ä‘áº·t SSD Samsung 980 PRO 1TB', '2026-10-25 10:01:02.716');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (30, 16, NULL, N'RECEIVED', 2, N'Tiáº¿p nháº­n ThinkPad T14 nhiá»…m virus', '2026-10-22 10:01:02.716');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (31, 16, N'RECEIVED', N'DELIVERED', 2, N'CÃ i Ä‘áº·t Windows 11 hoÃ n táº¥t, bÃ n giao khÃ¡ch', '2026-10-23 10:01:02.716');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (32, 17, NULL, N'RECEIVED', 2, N'Tiáº¿p nháº­n Z Fold5 cháº­p mÃ n hÃ¬nh trong', '2026-10-25 10:01:02.716');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (33, 17, N'RECEIVED', N'DIAGNOSING', 4, N'KTV Ä‘ang Ä‘o cÃ¡p gáº­p báº£n lá»', '2026-10-25 10:01:02.716');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (34, 18, NULL, N'RECEIVED', 2, N'Tiáº¿p nháº­n iPad Air 5 gÃ£y chÃ¢n Type-C', '2026-10-25 10:01:02.716');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (35, 19, NULL, N'RECEIVED', 2, N'Tiáº¿p nháº­n Dell Inspiron liá»‡t phÃ­m', '2026-10-24 10:01:02.716');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (36, 19, N'RECEIVED', N'COMPLETED', 3, N'Thay bÃ n phÃ­m má»›i hoÃ n táº¥t', '2026-10-25 10:01:02.716');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (37, 20, NULL, N'RECEIVED', 2, N'Tiáº¿p nháº­n Xiaomi 13 Pro ná»©t kÃ­nh camera', '2026-10-23 10:01:02.716');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (38, 20, N'RECEIVED', N'DELIVERED', 2, N'Thay kÃ­nh Sapphire Leica vÃ  bÃ n giao', '2026-10-24 10:01:02.716');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (39, 21, NULL, N'RECEIVED', 2, N'Tiáº¿p nháº­n MacBook Pro 16 M3 Max', '2026-10-25 10:01:02.716');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (40, 21, N'RECEIVED', N'REPAIRING', 3, N'Äang vá»‡ sinh buá»“ng hÆ¡i táº£n nhiá»‡t', '2026-10-25 10:01:02.716');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (41, 22, NULL, N'RECEIVED', 2, N'Tiáº¿p nháº­n Acer Nitro 5 cá»©u dá»¯ liá»‡u', '2026-10-25 10:01:02.716');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (42, 22, N'RECEIVED', N'DIAGNOSING', 3, N'Äang Ä‘o máº¡ch NAND SSD', '2026-10-25 10:01:02.716');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (43, 23, NULL, N'RECEIVED', 2, N'Tiáº¿p nháº­n iPhone 11 thay pin', '2026-10-22 10:01:02.716');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (44, 23, N'RECEIVED', N'DELIVERED', 2, N'ÄÃ£ thay pin Pisen dung lÆ°á»£ng cao', '2026-10-23 10:01:02.716');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (45, 24, NULL, N'RECEIVED', 2, N'Tiáº¿p nháº­n HP Pavilion nÃ¢ng cáº¥p SSD', '2026-10-23 10:01:02.716');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (46, 24, N'RECEIVED', N'DELIVERED', 2, N'ÄÃ£ nÃ¢ng cáº¥p SSD Kingston 512GB', '2026-10-24 10:01:02.716');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (47, 25, NULL, N'RECEIVED', 2, N'Tiáº¿p nháº­n iMac 24 há»ng mÃ n hÃ¬nh', '2026-10-22 10:01:02.716');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (48, 25, N'RECEIVED', N'CANCELLED', 2, N'KhÃ¡ch há»§y sá»­a chá»¯a do chi phÃ­ linh kiá»‡n cao', '2026-10-24 10:01:02.716');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (49, 26, N'WAITING_CONFIRM', N'DIAGNOSING', 3, N'Cap nhat trang thai tu WAITING_CONFIRM sang DIAGNOSING', '2026-10-25 10:02:44.216');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (50, 26, N'DIAGNOSING', N'WAITING_CONFIRM', 2, N'Cap nhat trang thai tu DIAGNOSING sang WAITING_CONFIRM', '2026-10-25 10:02:44.258');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (51, 26, N'WAITING_CONFIRM', N'REPAIRING', 3, N'Cap nhat trang thai tu WAITING_CONFIRM sang REPAIRING', '2026-10-25 10:02:44.265');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (52, 26, N'REPAIRING', N'COMPLETED', 3, N'Cap nhat trang thai tu REPAIRING sang COMPLETED', '2026-10-25 10:02:44.380');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (53, 26, N'COMPLETED', N'DELIVERED', 2, N'Cap nhat trang thai tu COMPLETED sang DELIVERED', '2026-10-25 10:02:44.533');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (54, 27, N'WAITING_CONFIRM', N'DIAGNOSING', 3, N'Cap nhat trang thai tu WAITING_CONFIRM sang DIAGNOSING', '2026-10-25 10:03:58.212');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (55, 27, N'DIAGNOSING', N'WAITING_CONFIRM', 2, N'Cap nhat trang thai tu DIAGNOSING sang WAITING_CONFIRM', '2026-10-25 10:03:58.266');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (56, 27, N'WAITING_CONFIRM', N'REPAIRING', 3, N'Cap nhat trang thai tu WAITING_CONFIRM sang REPAIRING', '2026-10-25 10:03:58.281');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (57, 27, N'REPAIRING', N'COMPLETED', 3, N'Cap nhat trang thai tu REPAIRING sang COMPLETED', '2026-10-25 10:03:58.422');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (58, 27, N'COMPLETED', N'DELIVERED', 2, N'Cap nhat trang thai tu COMPLETED sang DELIVERED', '2026-10-25 10:03:58.697');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (59, 28, N'WAITING_CONFIRM', N'DIAGNOSING', 3, N'Cap nhat trang thai tu WAITING_CONFIRM sang DIAGNOSING', '2026-10-25 10:04:38.028');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (60, 28, N'DIAGNOSING', N'WAITING_CONFIRM', 2, N'Cap nhat trang thai tu DIAGNOSING sang WAITING_CONFIRM', '2026-10-25 10:04:38.054');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (61, 28, N'WAITING_CONFIRM', N'REPAIRING', 3, N'Cap nhat trang thai tu WAITING_CONFIRM sang REPAIRING', '2026-10-25 10:04:38.069');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (62, 28, N'REPAIRING', N'COMPLETED', 3, N'Cap nhat trang thai tu REPAIRING sang COMPLETED', '2026-10-25 10:04:38.098');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (63, 28, N'COMPLETED', N'COMPLETED', 2, N'Khach hang da thanh toan hoa don HD2026100015 qua TRANSFER.', '2026-10-25 10:04:38.133');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (64, 28, N'COMPLETED', N'DELIVERED', 2, N'Cap nhat trang thai tu COMPLETED sang DELIVERED', '2026-10-25 10:04:38.159');
SET IDENTITY_INSERT dbo.[TicketStatusHistory] OFF;
GO

-- ----------------------------------------------------
-- Bang: dbo.StockTransactions (18 rows)
-- ----------------------------------------------------
SET IDENTITY_INSERT dbo.[StockTransactions] ON;
INSERT INTO dbo.[StockTransactions] ([TransactionId], [PartId], [TransactionType], [Quantity], [UnitPrice], [StockBefore], [StockAfter], [TicketId], [PerformedByUserId], [Note], [TransactionAt]) VALUES (1, 9, N'IN', 15, 1850000.00, 0, 15, NULL, 2, N'Nháº­p kho lÃ´ SSD Samsung 980 PRO tá»« Synnex FPT', '2026-09-30 09:05:12.570');
INSERT INTO dbo.[StockTransactions] ([TransactionId], [PartId], [TransactionType], [Quantity], [UnitPrice], [StockBefore], [StockAfter], [TicketId], [PerformedByUserId], [Note], [TransactionAt]) VALUES (2, 16, N'IN', 40, 110000.00, 0, 40, NULL, 2, N'Nháº­p kho keo táº£n nhiá»‡t Thermal Grizzly Kryonaut', '2026-09-30 09:05:12.570');
INSERT INTO dbo.[StockTransactions] ([TransactionId], [PartId], [TransactionType], [Quantity], [UnitPrice], [StockBefore], [StockAfter], [TicketId], [PerformedByUserId], [Note], [TransactionAt]) VALUES (3, 14, N'IN', 10, 380000.00, 0, 10, NULL, 2, N'Nháº­p cá»¥m cÃ¡p sáº¡c Type-C linh kiá»‡n bÃ³c mÃ¡y', '2026-09-30 09:05:12.570');
INSERT INTO dbo.[StockTransactions] ([TransactionId], [PartId], [TransactionType], [Quantity], [UnitPrice], [StockBefore], [StockAfter], [TicketId], [PerformedByUserId], [Note], [TransactionAt]) VALUES (4, 5, N'IN', 20, 580000.00, 0, 20, NULL, 2, N'Nháº­p lÃ´ pin Pisen dung lÆ°á»£ng cao tá»« nhÃ  phÃ¢n phá»‘i 3A', '2026-09-30 09:05:12.570');
INSERT INTO dbo.[StockTransactions] ([TransactionId], [PartId], [TransactionType], [Quantity], [UnitPrice], [StockBefore], [StockAfter], [TicketId], [PerformedByUserId], [Note], [TransactionAt]) VALUES (5, 12, N'IN', 15, 680000.00, 0, 15, NULL, 2, N'Nháº­p RAM laptop Kingston Fury DDR4', '2026-09-30 09:05:12.570');
INSERT INTO dbo.[StockTransactions] ([TransactionId], [PartId], [TransactionType], [Quantity], [UnitPrice], [StockBefore], [StockAfter], [TicketId], [PerformedByUserId], [Note], [TransactionAt]) VALUES (6, 9, N'OUT', 1, 2250000.00, 15, 14, 5, 3, N'Xuáº¥t thay tháº¿ SSD Samsung 980 PRO cho PC Gaming PSC202610005', '2026-10-21 09:05:12.570');
INSERT INTO dbo.[StockTransactions] ([TransactionId], [PartId], [TransactionType], [Quantity], [UnitPrice], [StockBefore], [StockAfter], [TicketId], [PerformedByUserId], [Note], [TransactionAt]) VALUES (7, 14, N'OUT', 1, 620000.00, 10, 9, 7, 4, N'Xuáº¥t cá»¥m cÃ¡p sáº¡c Type-C thay cho iPad Pro PSC202610007', '2026-10-22 09:05:12.570');
INSERT INTO dbo.[StockTransactions] ([TransactionId], [PartId], [TransactionType], [Quantity], [UnitPrice], [StockBefore], [StockAfter], [TicketId], [PerformedByUserId], [Note], [TransactionAt]) VALUES (8, 16, N'OUT', 1, 180000.00, 40, 39, 1, 3, N'Xuáº¥t tuÃ½p keo táº£n nhiá»‡t gá»‘m tra cho Dell XPS 15 PSC202610001', '2026-10-23 09:05:12.570');
INSERT INTO dbo.[StockTransactions] ([TransactionId], [PartId], [TransactionType], [Quantity], [UnitPrice], [StockBefore], [StockAfter], [TicketId], [PerformedByUserId], [Note], [TransactionAt]) VALUES (9, 5, N'OUT', 1, 790000.00, 20, 19, 9, 4, N'Xuáº¥t pin Pisen thay cho iPhone 13 PSC202610009', '2026-10-23 09:05:12.570');
INSERT INTO dbo.[StockTransactions] ([TransactionId], [PartId], [TransactionType], [Quantity], [UnitPrice], [StockBefore], [StockAfter], [TicketId], [PerformedByUserId], [Note], [TransactionAt]) VALUES (10, 12, N'OUT', 1, 890000.00, 15, 14, 10, 3, N'Xuáº¥t thanh RAM 16GB láº¯p cho HP Envy 13 PSC202610010', '2026-10-24 09:05:12.570');
INSERT INTO dbo.[StockTransactions] ([TransactionId], [PartId], [TransactionType], [Quantity], [UnitPrice], [StockBefore], [StockAfter], [TicketId], [PerformedByUserId], [Note], [TransactionAt]) VALUES (11, 10, N'IN', 20, 720000.00, 0, 20, NULL, 2, N'Nháº­p thÃªm 20 chiáº¿c SSD Kingston NV2 512GB', '2026-10-15 10:01:02.720');
INSERT INTO dbo.[StockTransactions] ([TransactionId], [PartId], [TransactionType], [Quantity], [UnitPrice], [StockBefore], [StockAfter], [TicketId], [PerformedByUserId], [Note], [TransactionAt]) VALUES (12, 18, N'IN', 15, 150000.00, 0, 15, NULL, 2, N'Nháº­p kÃ­nh Sapphire camera', '2026-10-15 10:01:02.720');
INSERT INTO dbo.[StockTransactions] ([TransactionId], [PartId], [TransactionType], [Quantity], [UnitPrice], [StockBefore], [StockAfter], [TicketId], [PerformedByUserId], [Note], [TransactionAt]) VALUES (13, 1, N'OUT', 1, 3200000.00, 6, 5, 14, 4, N'Xuáº¥t mÃ n hÃ¬nh thay cho iPhone 12 Pro PSC202610014', '2026-10-22 10:01:02.720');
INSERT INTO dbo.[StockTransactions] ([TransactionId], [PartId], [TransactionType], [Quantity], [UnitPrice], [StockBefore], [StockAfter], [TicketId], [PerformedByUserId], [Note], [TransactionAt]) VALUES (14, 18, N'OUT', 1, 280000.00, 9, 8, 20, 4, N'Xuáº¥t kÃ­nh camera thay cho Xiaomi 13 Pro PSC202610020', '2026-10-24 10:01:02.720');
INSERT INTO dbo.[StockTransactions] ([TransactionId], [PartId], [TransactionType], [Quantity], [UnitPrice], [StockBefore], [StockAfter], [TicketId], [PerformedByUserId], [Note], [TransactionAt]) VALUES (15, 10, N'OUT', 1, 950000.00, 18, 17, 24, 3, N'Xuáº¥t SSD Kingston thay cho HP Pavilion PSC202610024', '2026-10-24 10:01:02.720');
INSERT INTO dbo.[StockTransactions] ([TransactionId], [PartId], [TransactionType], [Quantity], [UnitPrice], [StockBefore], [StockAfter], [TicketId], [PerformedByUserId], [Note], [TransactionAt]) VALUES (16, 16, N'OUT', 1, 180000.00, 35, 34, 26, 3, N'Xuáº¥t keo táº£n nhiá»‡t Kryonaut cho phiáº¿u kiá»ƒm thá»­', '2026-10-25 10:02:44.305');
INSERT INTO dbo.[StockTransactions] ([TransactionId], [PartId], [TransactionType], [Quantity], [UnitPrice], [StockBefore], [StockAfter], [TicketId], [PerformedByUserId], [Note], [TransactionAt]) VALUES (17, 16, N'OUT', 1, 180000.00, 34, 33, 27, 3, N'Xuáº¥t keo táº£n nhiá»‡t Kryonaut cho phiáº¿u kiá»ƒm thá»­', '2026-10-25 10:03:58.329');
INSERT INTO dbo.[StockTransactions] ([TransactionId], [PartId], [TransactionType], [Quantity], [UnitPrice], [StockBefore], [StockAfter], [TicketId], [PerformedByUserId], [Note], [TransactionAt]) VALUES (18, 16, N'OUT', 1, 180000.00, 33, 32, 28, 3, N'Xuáº¥t keo táº£n nhiá»‡t Kryonaut cho phiáº¿u kiá»ƒm thá»­', '2026-10-25 10:04:38.075');
SET IDENTITY_INSERT dbo.[StockTransactions] OFF;
GO

-- ----------------------------------------------------
-- Bang: dbo.TicketParts (13 rows)
-- ----------------------------------------------------
SET IDENTITY_INSERT dbo.[TicketParts] ON;
INSERT INTO dbo.[TicketParts] ([TicketPartId], [TicketId], [PartId], [Quantity], [UnitPrice], [Note], [CreatedAt]) VALUES (1, 1, 16, 1, 180000.00, N'Keo táº£n nhiá»‡t gá»‘m Thermal Grizzly Kryonaut 1g', '2026-10-23 09:05:12.570');
INSERT INTO dbo.[TicketParts] ([TicketPartId], [TicketId], [PartId], [Quantity], [UnitPrice], [Note], [CreatedAt]) VALUES (2, 2, 1, 1, 5600000.00, N'MÃ n hÃ¬nh iPhone 14 Pro Max Super Retina XDR Zin mÃ¡y', '2026-10-24 09:05:12.570');
INSERT INTO dbo.[TicketParts] ([TicketPartId], [TicketId], [PartId], [Quantity], [UnitPrice], [Note], [CreatedAt]) VALUES (3, 5, 9, 1, 2250000.00, N'á»” cá»©ng SSD Samsung 980 PRO 1TB PCIe NVMe 4.0', '2026-10-21 09:05:12.570');
INSERT INTO dbo.[TicketParts] ([TicketPartId], [TicketId], [PartId], [Quantity], [UnitPrice], [Note], [CreatedAt]) VALUES (4, 7, 14, 1, 620000.00, N'Cá»¥m chÃ¢n sáº¡c Type-C iPad/iPhone bÃ³c mÃ¡y', '2026-10-22 09:05:12.570');
INSERT INTO dbo.[TicketParts] ([TicketPartId], [TicketId], [PartId], [Quantity], [UnitPrice], [Note], [CreatedAt]) VALUES (5, 9, 5, 1, 750000.00, N'Pin iPhone 13/14 Pisen dung lÆ°á»£ng cao', '2026-10-23 09:05:12.570');
INSERT INTO dbo.[TicketParts] ([TicketPartId], [TicketId], [PartId], [Quantity], [UnitPrice], [Note], [CreatedAt]) VALUES (6, 10, 12, 1, 890000.00, N'RAM Laptop Kingston Fury DDR4 16GB 3200MHz', '2026-10-24 09:05:12.570');
INSERT INTO dbo.[TicketParts] ([TicketPartId], [TicketId], [PartId], [Quantity], [UnitPrice], [Note], [CreatedAt]) VALUES (7, 13, 16, 1, 180000.00, N'Keo táº£n nhiá»‡t gá»‘m Kryonaut cho Asus TUF', '2026-10-24 10:01:02.713');
INSERT INTO dbo.[TicketParts] ([TicketPartId], [TicketId], [PartId], [Quantity], [UnitPrice], [Note], [CreatedAt]) VALUES (8, 14, 1, 1, 3200000.00, N'MÃ n hÃ¬nh OLED iPhone 12 Pro zin', '2026-10-22 10:01:02.713');
INSERT INTO dbo.[TicketParts] ([TicketPartId], [TicketId], [PartId], [Quantity], [UnitPrice], [Note], [CreatedAt]) VALUES (9, 15, 9, 1, 2250000.00, N'SSD Samsung 980 PRO 1TB PCIe NVMe', '2026-10-24 10:01:02.713');
INSERT INTO dbo.[TicketParts] ([TicketPartId], [TicketId], [PartId], [Quantity], [UnitPrice], [Note], [CreatedAt]) VALUES (10, 19, 15, 1, 950000.00, N'BÃ n phÃ­m laptop led cÃ³ Ä‘Ã¨n ná»n', '2026-10-24 10:01:02.713');
INSERT INTO dbo.[TicketParts] ([TicketPartId], [TicketId], [PartId], [Quantity], [UnitPrice], [Note], [CreatedAt]) VALUES (11, 20, 18, 1, 280000.00, N'Máº·t kÃ­nh camera Sapphire cao cáº¥p', '2026-10-24 10:01:02.713');
INSERT INTO dbo.[TicketParts] ([TicketPartId], [TicketId], [PartId], [Quantity], [UnitPrice], [Note], [CreatedAt]) VALUES (12, 23, 5, 1, 580000.00, N'Pin Pisen chÃ­nh hÃ£ng iPhone 11', '2026-10-23 10:01:02.713');
INSERT INTO dbo.[TicketParts] ([TicketPartId], [TicketId], [PartId], [Quantity], [UnitPrice], [Note], [CreatedAt]) VALUES (13, 24, 10, 1, 950000.00, N'SSD Kingston NV2 512GB M.2 PCIe', '2026-10-24 10:01:02.713');
SET IDENTITY_INSERT dbo.[TicketParts] OFF;
GO

-- ----------------------------------------------------
-- Bang: dbo.Invoices (15 rows)
-- ----------------------------------------------------
SET IDENTITY_INSERT dbo.[Invoices] ON;
INSERT INTO dbo.[Invoices] ([InvoiceId], [InvoiceCode], [TicketId], [CustomerId], [LaborCost], [PartsCost], [DiscountAmount], [PaymentMethod], [PaymentStatus], [PaidAt], [CreatedByUserId], [Note], [CreatedAt]) VALUES (1, N'HD2026100001', 5, 5, 120000.00, 2250000.00, 0.00, N'TRANSFER', N'PAID', '2026-10-21 09:05:12.570', 2, N'Chuyá»ƒn khoáº£n VietQR NgÃ¢n hÃ ng MBBank', '2026-10-21 09:05:12.570');
INSERT INTO dbo.[Invoices] ([InvoiceId], [InvoiceCode], [TicketId], [CustomerId], [LaborCost], [PartsCost], [DiscountAmount], [PaymentMethod], [PaymentStatus], [PaidAt], [CreatedByUserId], [Note], [CreatedAt]) VALUES (2, N'HD2026100002', 7, 7, 150000.00, 620000.00, 0.00, N'CASH', N'PAID', '2026-10-22 09:05:12.570', 2, N'Thanh toÃ¡n tiá»n máº·t táº¡i quáº§y', '2026-10-22 09:05:12.570');
INSERT INTO dbo.[Invoices] ([InvoiceId], [InvoiceCode], [TicketId], [CustomerId], [LaborCost], [PartsCost], [DiscountAmount], [PaymentMethod], [PaymentStatus], [PaidAt], [CreatedByUserId], [Note], [CreatedAt]) VALUES (3, N'HD2026100003', 1, 1, 150000.00, 180000.00, 0.00, N'TRANSFER', N'PAID', '2026-10-23 09:05:12.570', 2, N'Chuyá»ƒn khoáº£n VietQR', '2026-10-23 09:05:12.570');
INSERT INTO dbo.[Invoices] ([InvoiceId], [InvoiceCode], [TicketId], [CustomerId], [LaborCost], [PartsCost], [DiscountAmount], [PaymentMethod], [PaymentStatus], [PaidAt], [CreatedByUserId], [Note], [CreatedAt]) VALUES (4, N'HD2026100004', 9, 9, 100000.00, 750000.00, 0.00, N'TRANSFER', N'PAID', '2026-10-23 09:05:12.570', 2, N'Chuyá»ƒn khoáº£n VietQR', '2026-10-23 09:05:12.570');
INSERT INTO dbo.[Invoices] ([InvoiceId], [InvoiceCode], [TicketId], [CustomerId], [LaborCost], [PartsCost], [DiscountAmount], [PaymentMethod], [PaymentStatus], [PaidAt], [CreatedByUserId], [Note], [CreatedAt]) VALUES (5, N'HD2026100005', 10, 10, 100000.00, 890000.00, 0.00, N'CASH', N'PAID', '2026-10-24 09:05:12.570', 2, N'Thanh toÃ¡n tiá»n máº·t', '2026-10-24 09:05:12.570');
INSERT INTO dbo.[Invoices] ([InvoiceId], [InvoiceCode], [TicketId], [CustomerId], [LaborCost], [PartsCost], [DiscountAmount], [PaymentMethod], [PaymentStatus], [PaidAt], [CreatedByUserId], [Note], [CreatedAt]) VALUES (6, N'HD2026100006', 14, 14, 150000.00, 3200000.00, 50000.00, N'TRANSFER', N'PAID', '2026-10-22 10:01:02.716', 2, N'KhÃ¡ch thanh toÃ¡n chuyá»ƒn khoáº£n QR, chiáº¿t kháº¥u 50k tri Ã¢n', '2026-10-22 10:01:02.716');
INSERT INTO dbo.[Invoices] ([InvoiceId], [InvoiceCode], [TicketId], [CustomerId], [LaborCost], [PartsCost], [DiscountAmount], [PaymentMethod], [PaymentStatus], [PaidAt], [CreatedByUserId], [Note], [CreatedAt]) VALUES (7, N'HD2026100007', 16, 16, 100000.00, 0.00, 0.00, N'CASH', N'PAID', '2026-10-23 10:01:02.716', 2, N'Thanh toÃ¡n tiá»n máº·t cÃ i Windows', '2026-10-23 10:01:02.716');
INSERT INTO dbo.[Invoices] ([InvoiceId], [InvoiceCode], [TicketId], [CustomerId], [LaborCost], [PartsCost], [DiscountAmount], [PaymentMethod], [PaymentStatus], [PaidAt], [CreatedByUserId], [Note], [CreatedAt]) VALUES (8, N'HD2026100008', 20, 20, 150000.00, 280000.00, 0.00, N'TRANSFER', N'PAID', '2026-10-24 10:01:02.716', 2, N'Chuyá»ƒn khoáº£n Vietcombank', '2026-10-24 10:01:02.716');
INSERT INTO dbo.[Invoices] ([InvoiceId], [InvoiceCode], [TicketId], [CustomerId], [LaborCost], [PartsCost], [DiscountAmount], [PaymentMethod], [PaymentStatus], [PaidAt], [CreatedByUserId], [Note], [CreatedAt]) VALUES (9, N'HD2026100009', 23, 23, 100000.00, 580000.00, 0.00, N'TRANSFER', N'PAID', '2026-10-23 10:01:02.716', 2, N'Chuyá»ƒn khoáº£n MBBank', '2026-10-23 10:01:02.716');
INSERT INTO dbo.[Invoices] ([InvoiceId], [InvoiceCode], [TicketId], [CustomerId], [LaborCost], [PartsCost], [DiscountAmount], [PaymentMethod], [PaymentStatus], [PaidAt], [CreatedByUserId], [Note], [CreatedAt]) VALUES (10, N'HD2026100010', 24, 24, 120000.00, 950000.00, 0.00, N'CASH', N'PAID', '2026-10-24 10:01:02.716', 2, N'Thanh toÃ¡n tiá»n máº·t nÃ¢ng cáº¥p SSD', '2026-10-24 10:01:02.716');
INSERT INTO dbo.[Invoices] ([InvoiceId], [InvoiceCode], [TicketId], [CustomerId], [LaborCost], [PartsCost], [DiscountAmount], [PaymentMethod], [PaymentStatus], [PaidAt], [CreatedByUserId], [Note], [CreatedAt]) VALUES (11, N'HD2026100011', 15, 15, 120000.00, 2250000.00, 0.00, N'TRANSFER', N'UNPAID', '2026-10-24 10:01:02.716', 2, N'HÃ³a Ä‘Æ¡n chá» thanh toÃ¡n khi khÃ¡ch Ä‘áº¿n nháº­n mÃ¡y PC', '2026-10-24 10:01:02.716');
INSERT INTO dbo.[Invoices] ([InvoiceId], [InvoiceCode], [TicketId], [CustomerId], [LaborCost], [PartsCost], [DiscountAmount], [PaymentMethod], [PaymentStatus], [PaidAt], [CreatedByUserId], [Note], [CreatedAt]) VALUES (12, N'HD2026100012', 19, 19, 120000.00, 950000.00, 0.00, N'CASH', N'UNPAID', '2026-10-25 10:01:02.716', 2, N'HÃ³a Ä‘Æ¡n chá» thanh toÃ¡n thay bÃ n phÃ­m Dell Inspiron', '2026-10-25 10:01:02.716');
INSERT INTO dbo.[Invoices] ([InvoiceId], [InvoiceCode], [TicketId], [CustomerId], [LaborCost], [PartsCost], [DiscountAmount], [PaymentMethod], [PaymentStatus], [PaidAt], [CreatedByUserId], [Note], [CreatedAt]) VALUES (13, N'HD2026100013', 26, 27, 150000.00, 180000.00, 30000.00, N'CASH', N'UNPAID', NULL, 2, NULL, '2026-10-25 10:02:44.413');
INSERT INTO dbo.[Invoices] ([InvoiceId], [InvoiceCode], [TicketId], [CustomerId], [LaborCost], [PartsCost], [DiscountAmount], [PaymentMethod], [PaymentStatus], [PaidAt], [CreatedByUserId], [Note], [CreatedAt]) VALUES (14, N'HD2026100014', 27, 28, 150000.00, 180000.00, 30000.00, N'CASH', N'UNPAID', NULL, 2, NULL, '2026-10-25 10:03:58.474');
INSERT INTO dbo.[Invoices] ([InvoiceId], [InvoiceCode], [TicketId], [CustomerId], [LaborCost], [PartsCost], [DiscountAmount], [PaymentMethod], [PaymentStatus], [PaidAt], [CreatedByUserId], [Note], [CreatedAt]) VALUES (15, N'HD2026100015', 28, 29, 150000.00, 180000.00, 30000.00, N'TRANSFER', N'PAID', '2026-10-25 10:04:38.133', 2, NULL, '2026-10-25 10:04:38.119');
SET IDENTITY_INSERT dbo.[Invoices] OFF;
GO

-- ----------------------------------------------------
-- Bang: dbo.Payments (11 rows)
-- ----------------------------------------------------
SET IDENTITY_INSERT dbo.[Payments] ON;
INSERT INTO dbo.[Payments] ([PaymentId], [InvoiceId], [Amount], [PaymentMethod], [ReceivedByUserId], [PaidAt], [Note]) VALUES (1, 1, 2370000.00, N'TRANSFER', 2, '2026-10-21 09:05:12.570', N'Thanh toÃ¡n ban Ä‘áº§u cho hÃ³a Ä‘Æ¡n HD2026100001');
INSERT INTO dbo.[Payments] ([PaymentId], [InvoiceId], [Amount], [PaymentMethod], [ReceivedByUserId], [PaidAt], [Note]) VALUES (2, 2, 770000.00, N'CASH', 2, '2026-10-22 09:05:12.570', N'Thanh toÃ¡n ban Ä‘áº§u cho hÃ³a Ä‘Æ¡n HD2026100002');
INSERT INTO dbo.[Payments] ([PaymentId], [InvoiceId], [Amount], [PaymentMethod], [ReceivedByUserId], [PaidAt], [Note]) VALUES (3, 3, 330000.00, N'TRANSFER', 2, '2026-10-23 09:05:12.570', N'Thanh toÃ¡n ban Ä‘áº§u cho hÃ³a Ä‘Æ¡n HD2026100003');
INSERT INTO dbo.[Payments] ([PaymentId], [InvoiceId], [Amount], [PaymentMethod], [ReceivedByUserId], [PaidAt], [Note]) VALUES (4, 4, 850000.00, N'TRANSFER', 2, '2026-10-23 09:05:12.570', N'Thanh toÃ¡n ban Ä‘áº§u cho hÃ³a Ä‘Æ¡n HD2026100004');
INSERT INTO dbo.[Payments] ([PaymentId], [InvoiceId], [Amount], [PaymentMethod], [ReceivedByUserId], [PaidAt], [Note]) VALUES (5, 5, 990000.00, N'CASH', 2, '2026-10-24 09:05:12.570', N'Thanh toÃ¡n ban Ä‘áº§u cho hÃ³a Ä‘Æ¡n HD2026100005');
INSERT INTO dbo.[Payments] ([PaymentId], [InvoiceId], [Amount], [PaymentMethod], [ReceivedByUserId], [PaidAt], [Note]) VALUES (6, 6, 3300000.00, N'TRANSFER', 2, '2026-10-22 10:01:02.716', N'Thanh toÃ¡n ban Ä‘áº§u cho hÃ³a Ä‘Æ¡n HD2026100006');
INSERT INTO dbo.[Payments] ([PaymentId], [InvoiceId], [Amount], [PaymentMethod], [ReceivedByUserId], [PaidAt], [Note]) VALUES (7, 7, 100000.00, N'CASH', 2, '2026-10-23 10:01:02.716', N'Thanh toÃ¡n ban Ä‘áº§u cho hÃ³a Ä‘Æ¡n HD2026100007');
INSERT INTO dbo.[Payments] ([PaymentId], [InvoiceId], [Amount], [PaymentMethod], [ReceivedByUserId], [PaidAt], [Note]) VALUES (8, 8, 430000.00, N'TRANSFER', 2, '2026-10-24 10:01:02.716', N'Thanh toÃ¡n ban Ä‘áº§u cho hÃ³a Ä‘Æ¡n HD2026100008');
INSERT INTO dbo.[Payments] ([PaymentId], [InvoiceId], [Amount], [PaymentMethod], [ReceivedByUserId], [PaidAt], [Note]) VALUES (9, 9, 680000.00, N'TRANSFER', 2, '2026-10-23 10:01:02.716', N'Thanh toÃ¡n ban Ä‘áº§u cho hÃ³a Ä‘Æ¡n HD2026100009');
INSERT INTO dbo.[Payments] ([PaymentId], [InvoiceId], [Amount], [PaymentMethod], [ReceivedByUserId], [PaidAt], [Note]) VALUES (10, 10, 1070000.00, N'CASH', 2, '2026-10-24 10:01:02.716', N'Thanh toÃ¡n ban Ä‘áº§u cho hÃ³a Ä‘Æ¡n HD2026100010');
INSERT INTO dbo.[Payments] ([PaymentId], [InvoiceId], [Amount], [PaymentMethod], [ReceivedByUserId], [PaidAt], [Note]) VALUES (11, 15, 0.00, N'TRANSFER', 2, '2026-10-25 10:04:38.133', N'Thanh toan hoa don HD2026100015 bang hinh thuc TRANSFER');
SET IDENTITY_INSERT dbo.[Payments] OFF;
GO

-- ----------------------------------------------------
-- Bang: dbo.Warranties (13 rows)
-- ----------------------------------------------------
SET IDENTITY_INSERT dbo.[Warranties] ON;
INSERT INTO dbo.[Warranties] ([WarrantyId], [WarrantyCode], [TicketId], [CustomerId], [DeviceId], [StartDate], [EndDate], [WarrantyDays], [Scope], [Status], [VoidReason], [CreatedAt]) VALUES (1, N'BH2026100001', 5, 5, 5, '2026-10-21 00:00:00.000', '2027-10-21 00:00:00.000', 365, N'Báº£o hÃ nh chÃ­nh hÃ£ng 1 Ä‘á»•i 1 trong 12 thÃ¡ng cho á»• cá»©ng SSD Samsung 980 PRO 1TB NVMe PCIe 4.0.', N'ACTIVE', NULL, '2026-10-21 09:05:12.570');
INSERT INTO dbo.[Warranties] ([WarrantyId], [WarrantyCode], [TicketId], [CustomerId], [DeviceId], [StartDate], [EndDate], [WarrantyDays], [Scope], [Status], [VoidReason], [CreatedAt]) VALUES (2, N'BH2026100002', 7, 7, 7, '2026-10-22 00:00:00.000', '2027-01-20 00:00:00.000', 90, N'Báº£o hÃ nh 03 thÃ¡ng cá»¥m chÃ¢n sáº¡c USB-C vÃ  mic thoáº¡i iPad Pro 11 M1.', N'ACTIVE', NULL, '2026-10-22 09:05:12.570');
INSERT INTO dbo.[Warranties] ([WarrantyId], [WarrantyCode], [TicketId], [CustomerId], [DeviceId], [StartDate], [EndDate], [WarrantyDays], [Scope], [Status], [VoidReason], [CreatedAt]) VALUES (3, N'BH2026100003', 1, 1, 1, '2026-10-23 00:00:00.000', '2026-11-22 00:00:00.000', 30, N'Báº£o hÃ nh 30 ngÃ y hiá»‡u nÄƒng giáº£i nhiá»‡t keo táº£n nhiá»‡t gá»‘m Thermal Grizzly Kryonaut trÃªn laptop Dell XPS 15.', N'ACTIVE', NULL, '2026-10-23 09:05:12.570');
INSERT INTO dbo.[Warranties] ([WarrantyId], [WarrantyCode], [TicketId], [CustomerId], [DeviceId], [StartDate], [EndDate], [WarrantyDays], [Scope], [Status], [VoidReason], [CreatedAt]) VALUES (4, N'BH2026100004', 9, 9, 9, '2026-10-23 00:00:00.000', '2027-04-21 00:00:00.000', 180, N'Báº£o hÃ nh 06 thÃ¡ng pin Pisen dung lÆ°á»£ng cao chÃ­nh hÃ£ng iPhone 13 (chai quÃ¡ 20% Ä‘á»•i má»›i).', N'ACTIVE', NULL, '2026-10-23 09:05:12.570');
INSERT INTO dbo.[Warranties] ([WarrantyId], [WarrantyCode], [TicketId], [CustomerId], [DeviceId], [StartDate], [EndDate], [WarrantyDays], [Scope], [Status], [VoidReason], [CreatedAt]) VALUES (5, N'BH2026100005', 10, 10, 10, '2026-10-24 00:00:00.000', '2027-10-24 00:00:00.000', 365, N'Báº£o hÃ nh 12 thÃ¡ng thanh RAM Laptop Kingston Fury DDR4 16GB 3200MHz.', N'ACTIVE', NULL, '2026-10-24 09:05:12.570');
INSERT INTO dbo.[Warranties] ([WarrantyId], [WarrantyCode], [TicketId], [CustomerId], [DeviceId], [StartDate], [EndDate], [WarrantyDays], [Scope], [Status], [VoidReason], [CreatedAt]) VALUES (6, N'BH2026100006', 14, 14, 14, '2026-10-22 00:00:00.000', '2027-01-20 00:00:00.000', 90, N'Báº£o hÃ nh 03 thÃ¡ng mÃ n hÃ¬nh OLED Super Retina iPhone 12 Pro (bao sá»c, Ä‘Æ¡ cáº£m á»©ng).', N'ACTIVE', NULL, '2026-10-22 10:01:02.720');
INSERT INTO dbo.[Warranties] ([WarrantyId], [WarrantyCode], [TicketId], [CustomerId], [DeviceId], [StartDate], [EndDate], [WarrantyDays], [Scope], [Status], [VoidReason], [CreatedAt]) VALUES (7, N'BH2026100007', 16, 16, 16, '2026-10-23 00:00:00.000', '2026-11-22 00:00:00.000', 30, N'Há»— trá»£ ká»¹ thuáº­t pháº§n má»m vÃ  kÃ­ch hoáº¡t báº£n quyá»n Windows 11 Pro 30 ngÃ y.', N'ACTIVE', NULL, '2026-10-23 10:01:02.720');
INSERT INTO dbo.[Warranties] ([WarrantyId], [WarrantyCode], [TicketId], [CustomerId], [DeviceId], [StartDate], [EndDate], [WarrantyDays], [Scope], [Status], [VoidReason], [CreatedAt]) VALUES (8, N'BH2026100008', 20, 20, 20, '2026-10-24 00:00:00.000', '2027-01-22 00:00:00.000', 90, N'Báº£o hÃ nh máº·t kÃ­nh camera Sapphire Leica 03 thÃ¡ng chá»‘ng bá»¥i, bong keo.', N'ACTIVE', NULL, '2026-10-24 10:01:02.720');
INSERT INTO dbo.[Warranties] ([WarrantyId], [WarrantyCode], [TicketId], [CustomerId], [DeviceId], [StartDate], [EndDate], [WarrantyDays], [Scope], [Status], [VoidReason], [CreatedAt]) VALUES (9, N'BH2026100009', 23, 23, 23, '2026-10-23 00:00:00.000', '2027-04-21 00:00:00.000', 180, N'Báº£o hÃ nh 06 thÃ¡ng pin Pisen iPhone 11 dung lÆ°á»£ng cao, chai quÃ¡ 20% Ä‘á»•i viÃªn má»›i.', N'ACTIVE', NULL, '2026-10-23 10:01:02.720');
INSERT INTO dbo.[Warranties] ([WarrantyId], [WarrantyCode], [TicketId], [CustomerId], [DeviceId], [StartDate], [EndDate], [WarrantyDays], [Scope], [Status], [VoidReason], [CreatedAt]) VALUES (10, N'BH2026100010', 24, 24, 24, '2026-10-24 00:00:00.000', '2027-10-24 00:00:00.000', 365, N'Báº£o hÃ nh 1 Ä‘á»•i 1 trong 365 ngÃ y Ä‘á»‘i vá»›i SSD Kingston NV2 512GB chÃ­nh hÃ£ng SPC.', N'ACTIVE', NULL, '2026-10-24 10:01:02.720');
INSERT INTO dbo.[Warranties] ([WarrantyId], [WarrantyCode], [TicketId], [CustomerId], [DeviceId], [StartDate], [EndDate], [WarrantyDays], [Scope], [Status], [VoidReason], [CreatedAt]) VALUES (11, N'BH2026100011', 13, 13, 13, '2026-09-20 00:00:00.000', '2026-10-20 00:00:00.000', 30, N'Báº£o hÃ nh 30 ngÃ y keo táº£n nhiá»‡t gá»‘m Kryonaut cho laptop Asus TUF (Ä‘Ã£ háº¿t háº¡n báº£o hÃ nh).', N'EXPIRED', NULL, '2026-09-20 10:01:02.720');
INSERT INTO dbo.[Warranties] ([WarrantyId], [WarrantyCode], [TicketId], [CustomerId], [DeviceId], [StartDate], [EndDate], [WarrantyDays], [Scope], [Status], [VoidReason], [CreatedAt]) VALUES (12, N'BH2026100012', 10, 10, 10, '2026-10-24 00:00:00.000', '2027-10-24 00:00:00.000', 365, N'Báº£o hÃ nh 12 thÃ¡ng á»• cá»©ng SSD gáº¯n ngoÃ i.', N'ACTIVE', NULL, '2026-10-24 10:01:02.720');
INSERT INTO dbo.[Warranties] ([WarrantyId], [WarrantyCode], [TicketId], [CustomerId], [DeviceId], [StartDate], [EndDate], [WarrantyDays], [Scope], [Status], [VoidReason], [CreatedAt]) VALUES (13, N'BH2026100013', 28, 29, 31, '2026-10-25 00:00:00.000', '2026-11-24 00:00:00.000', 30, N'Bao hanh dich vu Vá»‡ sinh tra keo táº£n nhiá»‡t gá»‘m mÃ¡y tÃ­nh & laptop', N'ACTIVE', NULL, '2026-10-25 10:04:38.134');
SET IDENTITY_INSERT dbo.[Warranties] OFF;
GO

COMMIT TRANSACTION;
GO
PRINT N'Da nap thanh cong toan bo du lieu mau chuan hoa!';
GO



PRINT N'=== CHUC MUNG! CSDL REPAIRSHOPDB DA DUOC KHOI TAO VA SEED DAY DU THANH CONG! ===';
GO
