/* ================================================================
   QLDACNTT - TOAN BO CSDL REPAIRSHOPDB (FILE SQL DUY NHAT)
   Do an: He thong quan ly tong the cho cua hang sua chua - LV33-001
   Nhom 11 - Lop 23DTHC6: Nguyen Viet Lam, Tran Ngoc Loi, Nguyen Dai Ky
   Noi dung: tao CSDL, 13 bang, rang buoc, index, du lieu mau, view, stored procedure, trigger.
   Sinh tu CSDL dang chay ngay 2026-11-02. Chay file nay trong SSMS hoac: sqlcmd -S . -E -C -I -f 65001 -i QLDACNTT_full_database.sql
   ================================================================ */
USE master;
GO
IF DB_ID('RepairShopDB') IS NULL
    CREATE DATABASE RepairShopDB COLLATE Vietnamese_CI_AS;
GO
ALTER DATABASE RepairShopDB SET RECOVERY SIMPLE;
GO
USE RepairShopDB;
GO
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

IF OBJECT_ID(N'dbo.Customers', N'U') IS NULL
CREATE TABLE dbo.[Customers] (
    [CustomerId] int IDENTITY(1,1) NOT NULL,
    [CustomerCode] varchar(20) NOT NULL,
    [FullName] nvarchar(100) NOT NULL,
    [Phone] varchar(20) NOT NULL,
    [Email] varchar(100) NULL,
    [Address] nvarchar(255) NULL,
    [Note] nvarchar(500) NULL,
    [IsActive] bit NOT NULL CONSTRAINT [DF__Customers__IsAct__4316F928] DEFAULT ((1)),
    [CreatedAt] datetime2(7) NOT NULL CONSTRAINT [DF__Customers__Creat__440B1D61] DEFAULT (sysdatetime()),
    [UpdatedAt] datetime2(7) NULL,
    CONSTRAINT [PK__Customer__A4AE64D835AC055A] PRIMARY KEY CLUSTERED (CustomerId)
);
GO

IF OBJECT_ID(N'dbo.Devices', N'U') IS NULL
CREATE TABLE dbo.[Devices] (
    [DeviceId] int IDENTITY(1,1) NOT NULL,
    [CustomerId] int NOT NULL,
    [DeviceType] nvarchar(50) NOT NULL,
    [Brand] nvarchar(50) NULL,
    [Model] nvarchar(100) NULL,
    [SerialNumber] varchar(100) NULL,
    [Note] nvarchar(500) NULL,
    [CreatedAt] datetime2(7) NOT NULL CONSTRAINT [DF__Devices__Created__46E78A0C] DEFAULT (sysdatetime()),
    [DeviceCode] nvarchar(50) NULL,
    CONSTRAINT [PK__Devices__49E1231151D8A1EF] PRIMARY KEY CLUSTERED (DeviceId)
);
GO

IF OBJECT_ID(N'dbo.ServiceTypes', N'U') IS NULL
CREATE TABLE dbo.[ServiceTypes] (
    [ServiceTypeId] int IDENTITY(1,1) NOT NULL,
    [ServiceCode] varchar(20) NOT NULL,
    [ServiceName] nvarchar(100) NOT NULL,
    [LaborCost] decimal(18,2) NOT NULL CONSTRAINT [DF__ServiceTy__Labor__4BAC3F29] DEFAULT ((0)),
    [WarrantyDays] int NOT NULL CONSTRAINT [DF__ServiceTy__Warra__4CA06362] DEFAULT ((0)),
    [Description] nvarchar(300) NULL,
    [IsActive] bit NOT NULL CONSTRAINT [DF__ServiceTy__IsAct__4D94879B] DEFAULT ((1)),
    CONSTRAINT [PK__ServiceT__8ADFAA6CBF347E30] PRIMARY KEY CLUSTERED (ServiceTypeId)
);
GO

IF OBJECT_ID(N'dbo.Roles', N'U') IS NULL
CREATE TABLE dbo.[Roles] (
    [RoleId] int IDENTITY(1,1) NOT NULL,
    [RoleCode] varchar(20) NOT NULL,
    [RoleName] nvarchar(50) NOT NULL,
    [Description] nvarchar(200) NULL,
    [IsActive] bit NOT NULL CONSTRAINT [DF__Roles__IsActive__38996AB5] DEFAULT ((1)),
    [CreatedAt] datetime2(7) NOT NULL CONSTRAINT [DF__Roles__CreatedAt__398D8EEE] DEFAULT (sysdatetime()),
    CONSTRAINT [PK__Roles__8AFACE1ACA6FBE03] PRIMARY KEY CLUSTERED (RoleId)
);
GO

IF OBJECT_ID(N'dbo.Users', N'U') IS NULL
CREATE TABLE dbo.[Users] (
    [UserId] int IDENTITY(1,1) NOT NULL,
    [RoleId] int NOT NULL,
    [Username] varchar(50) NOT NULL,
    [PasswordHash] varchar(255) NOT NULL,
    [FullName] nvarchar(100) NOT NULL,
    [Email] varchar(100) NULL,
    [Phone] varchar(20) NULL,
    [IsActive] bit NOT NULL CONSTRAINT [DF__Users__IsActive__3D5E1FD2] DEFAULT ((1)),
    [LastLoginAt] datetime2(7) NULL,
    [CreatedAt] datetime2(7) NOT NULL CONSTRAINT [DF__Users__CreatedAt__3E52440B] DEFAULT (sysdatetime()),
    [UpdatedAt] datetime2(7) NULL,
    [CustomerId] int NULL,
    CONSTRAINT [PK__Users__1788CC4CEF1E9F30] PRIMARY KEY CLUSTERED (UserId)
);
GO

IF OBJECT_ID(N'dbo.RepairTickets', N'U') IS NULL
CREATE TABLE dbo.[RepairTickets] (
    [TicketId] int IDENTITY(1,1) NOT NULL,
    [TicketCode] varchar(20) NOT NULL,
    [CustomerId] int NOT NULL,
    [DeviceId] int NOT NULL,
    [ServiceTypeId] int NULL,
    [ReceivedByUserId] int NOT NULL,
    [TechnicianUserId] int NULL,
    [Status] varchar(30) NOT NULL CONSTRAINT [DF__RepairTic__Statu__534D60F1] DEFAULT ('RECEIVED'),
    [DeviceCondition] nvarchar(1000) NULL,
    [CustomerRequest] nvarchar(1000) NULL,
    [Diagnosis] nvarchar(1000) NULL,
    [QuotedLaborCost] decimal(18,2) NOT NULL CONSTRAINT [DF__RepairTic__Quote__5441852A] DEFAULT ((0)),
    [QuotedPartsCost] decimal(18,2) NOT NULL CONSTRAINT [DF__RepairTic__Quote__5535A963] DEFAULT ((0)),
    [QuotedTotal] AS ([QuotedLaborCost]+[QuotedPartsCost]) PERSISTED,
    [IsWarrantyRepair] bit NOT NULL CONSTRAINT [DF__RepairTic__IsWar__5629CD9C] DEFAULT ((0)),
    [OriginalTicketId] int NULL,
    [ReceivedAt] datetime2(7) NOT NULL CONSTRAINT [DF__RepairTic__Recei__571DF1D5] DEFAULT (sysdatetime()),
    [ExpectedFinishAt] datetime2(7) NULL,
    [CompletedAt] datetime2(7) NULL,
    [DeliveredAt] datetime2(7) NULL,
    [CancelReason] nvarchar(500) NULL,
    [CreatedAt] datetime2(7) NOT NULL CONSTRAINT [DF__RepairTic__Creat__5812160E] DEFAULT (sysdatetime()),
    [UpdatedAt] datetime2(7) NULL,
    CONSTRAINT [PK__RepairTi__712CC60701CB2D23] PRIMARY KEY CLUSTERED (TicketId)
);
GO

IF OBJECT_ID(N'dbo.Invoices', N'U') IS NULL
CREATE TABLE dbo.[Invoices] (
    [InvoiceId] int IDENTITY(1,1) NOT NULL,
    [InvoiceCode] varchar(20) NOT NULL,
    [TicketId] int NOT NULL,
    [CustomerId] int NOT NULL,
    [LaborCost] decimal(18,2) NOT NULL CONSTRAINT [DF__Invoices__LaborC__09A971A2] DEFAULT ((0)),
    [PartsCost] decimal(18,2) NOT NULL CONSTRAINT [DF__Invoices__PartsC__0A9D95DB] DEFAULT ((0)),
    [DiscountAmount] decimal(18,2) NOT NULL CONSTRAINT [DF__Invoices__Discou__0B91BA14] DEFAULT ((0)),
    [TotalAmount] AS (([LaborCost]+[PartsCost])-[DiscountAmount]) PERSISTED,
    [PaymentMethod] varchar(20) NOT NULL CONSTRAINT [DF__Invoices__Paymen__0C85DE4D] DEFAULT ('CASH'),
    [PaymentStatus] varchar(20) NOT NULL CONSTRAINT [DF__Invoices__Paymen__0D7A0286] DEFAULT ('UNPAID'),
    [PaidAt] datetime2(7) NULL,
    [CreatedByUserId] int NOT NULL,
    [Note] nvarchar(500) NULL,
    [CreatedAt] datetime2(7) NOT NULL CONSTRAINT [DF__Invoices__Create__0E6E26BF] DEFAULT (sysdatetime()),
    CONSTRAINT [PK__Invoices__D796AAB54DF15F93] PRIMARY KEY CLUSTERED (InvoiceId)
);
GO

IF OBJECT_ID(N'dbo.Payments', N'U') IS NULL
CREATE TABLE dbo.[Payments] (
    [PaymentId] int IDENTITY(1,1) NOT NULL,
    [InvoiceId] int NOT NULL,
    [Amount] decimal(18,2) NOT NULL,
    [PaymentMethod] varchar(20) NOT NULL,
    [ReceivedByUserId] int NOT NULL,
    [PaidAt] datetime2(7) NOT NULL CONSTRAINT [DF__Payments__PaidAt__3E1D39E1] DEFAULT (sysdatetime()),
    [Note] nvarchar(500) NULL,
    CONSTRAINT [PK__Payments__9B556A3842285B3B] PRIMARY KEY CLUSTERED (PaymentId)
);
GO

IF OBJECT_ID(N'dbo.SparePartCategories', N'U') IS NULL
CREATE TABLE dbo.[SparePartCategories] (
    [CategoryId] int IDENTITY(1,1) NOT NULL,
    [CategoryName] nvarchar(100) NOT NULL,
    [Description] nvarchar(300) NULL,
    [IsActive] bit NOT NULL CONSTRAINT [DF__SparePart__IsAct__66603565] DEFAULT ((1)),
    CONSTRAINT [PK__SparePar__19093A0BA968D577] PRIMARY KEY CLUSTERED (CategoryId)
);
GO

IF OBJECT_ID(N'dbo.SpareParts', N'U') IS NULL
CREATE TABLE dbo.[SpareParts] (
    [PartId] int IDENTITY(1,1) NOT NULL,
    [PartCode] varchar(30) NOT NULL,
    [CategoryId] int NOT NULL,
    [PartName] nvarchar(150) NOT NULL,
    [Unit] nvarchar(20) NOT NULL CONSTRAINT [DF__SpareParts__Unit__6A30C649] DEFAULT (N'C�i'),
    [PurchasePrice] decimal(18,2) NOT NULL CONSTRAINT [DF__SparePart__Purch__6B24EA82] DEFAULT ((0)),
    [SellingPrice] decimal(18,2) NOT NULL CONSTRAINT [DF__SparePart__Selli__6C190EBB] DEFAULT ((0)),
    [StockQuantity] int NOT NULL CONSTRAINT [DF__SparePart__Stock__6D0D32F4] DEFAULT ((0)),
    [MinStockLevel] int NOT NULL CONSTRAINT [DF__SparePart__MinSt__6E01572D] DEFAULT ((0)),
    [WarrantyDays] int NOT NULL CONSTRAINT [DF__SparePart__Warra__6EF57B66] DEFAULT ((0)),
    [IsActive] bit NOT NULL CONSTRAINT [DF__SparePart__IsAct__6FE99F9F] DEFAULT ((1)),
    [CreatedAt] datetime2(7) NOT NULL CONSTRAINT [DF__SparePart__Creat__70DDC3D8] DEFAULT (sysdatetime()),
    [UpdatedAt] datetime2(7) NULL,
    CONSTRAINT [PK__SparePar__7C3F0D5097A1AC6D] PRIMARY KEY CLUSTERED (PartId)
);
GO

IF OBJECT_ID(N'dbo.StockTransactions', N'U') IS NULL
CREATE TABLE dbo.[StockTransactions] (
    [TransactionId] int IDENTITY(1,1) NOT NULL,
    [PartId] int NOT NULL,
    [TransactionType] varchar(20) NOT NULL,
    [Quantity] int NOT NULL,
    [UnitPrice] decimal(18,2) NOT NULL CONSTRAINT [DF__StockTran__UnitP__787EE5A0] DEFAULT ((0)),
    [StockBefore] int NOT NULL,
    [StockAfter] int NOT NULL,
    [TicketId] int NULL,
    [PerformedByUserId] int NOT NULL,
    [Note] nvarchar(500) NULL,
    [TransactionAt] datetime2(7) NOT NULL CONSTRAINT [DF__StockTran__Trans__797309D9] DEFAULT (sysdatetime()),
    CONSTRAINT [PK__StockTra__55433A6BB62E1DF7] PRIMARY KEY CLUSTERED (TransactionId)
);
GO

IF OBJECT_ID(N'dbo.TicketParts', N'U') IS NULL
CREATE TABLE dbo.[TicketParts] (
    [TicketPartId] int IDENTITY(1,1) NOT NULL,
    [TicketId] int NOT NULL,
    [PartId] int NOT NULL,
    [Quantity] int NOT NULL,
    [UnitPrice] decimal(18,2) NOT NULL,
    [LineTotal] AS ([Quantity]*[UnitPrice]) PERSISTED,
    [Note] nvarchar(300) NULL,
    [CreatedAt] datetime2(7) NOT NULL CONSTRAINT [DF__TicketPar__Creat__01142BA1] DEFAULT (sysdatetime()),
    CONSTRAINT [PK__TicketPa__A2D5A326DCCCEF05] PRIMARY KEY CLUSTERED (TicketPartId)
);
GO

IF OBJECT_ID(N'dbo.TicketStatusHistory', N'U') IS NULL
CREATE TABLE dbo.[TicketStatusHistory] (
    [HistoryId] int IDENTITY(1,1) NOT NULL,
    [TicketId] int NOT NULL,
    [FromStatus] varchar(30) NULL,
    [ToStatus] varchar(30) NOT NULL,
    [ChangedByUserId] int NOT NULL,
    [Note] nvarchar(500) NULL,
    [ChangedAt] datetime2(7) NOT NULL CONSTRAINT [DF__TicketSta__Chang__619B8048] DEFAULT (sysdatetime()),
    CONSTRAINT [PK__TicketSt__4D7B4ABD9D2DD41D] PRIMARY KEY CLUSTERED (HistoryId)
);
GO

IF OBJECT_ID(N'dbo.Warranties', N'U') IS NULL
CREATE TABLE dbo.[Warranties] (
    [WarrantyId] int IDENTITY(1,1) NOT NULL,
    [WarrantyCode] varchar(20) NOT NULL,
    [TicketId] int NOT NULL,
    [CustomerId] int NOT NULL,
    [DeviceId] int NOT NULL,
    [StartDate] date NOT NULL,
    [EndDate] date NOT NULL,
    [WarrantyDays] int NOT NULL,
    [Scope] nvarchar(500) NULL,
    [Status] varchar(20) NOT NULL CONSTRAINT [DF__Warrantie__Statu__17F790F9] DEFAULT ('ACTIVE'),
    [VoidReason] nvarchar(300) NULL,
    [CreatedAt] datetime2(7) NOT NULL CONSTRAINT [DF__Warrantie__Creat__18EBB532] DEFAULT (sysdatetime()),
    CONSTRAINT [PK__Warranti__2ED31813F4624AC2] PRIMARY KEY CLUSTERED (WarrantyId)
);
GO

-- ===== RANG BUOC UNIQUE / CHECK / KHOA NGOAI / INDEX =====
ALTER TABLE dbo.[Customers] ADD CONSTRAINT [UQ__Customer__06678521522872E3] UNIQUE NONCLUSTERED (CustomerCode);
GO
ALTER TABLE dbo.[Invoices] ADD CONSTRAINT [UQ__Invoices__712CC60633C61110] UNIQUE NONCLUSTERED (TicketId);
GO
ALTER TABLE dbo.[Invoices] ADD CONSTRAINT [UQ__Invoices__0D9D7FF3242A830D] UNIQUE NONCLUSTERED (InvoiceCode);
GO
ALTER TABLE dbo.[RepairTickets] ADD CONSTRAINT [UQ__RepairTi__598CF7A3FFB6D80A] UNIQUE NONCLUSTERED (TicketCode);
GO
ALTER TABLE dbo.[Roles] ADD CONSTRAINT [UQ__Roles__D62CB59CF6A5700B] UNIQUE NONCLUSTERED (RoleCode);
GO
ALTER TABLE dbo.[ServiceTypes] ADD CONSTRAINT [UQ__ServiceT__A01D74C9A5664D64] UNIQUE NONCLUSTERED (ServiceCode);
GO
ALTER TABLE dbo.[SpareParts] ADD CONSTRAINT [UQ__SparePar__6525D39D25395B7E] UNIQUE NONCLUSTERED (PartCode);
GO
ALTER TABLE dbo.[Users] ADD CONSTRAINT [UQ__Users__536C85E4FA85B59B] UNIQUE NONCLUSTERED (Username);
GO
ALTER TABLE dbo.[Warranties] ADD CONSTRAINT [UQ__Warranti__551FF6B2080FE327] UNIQUE NONCLUSTERED (WarrantyCode);
GO
ALTER TABLE dbo.[Invoices] ADD CONSTRAINT [CK_Invoices_Discount] CHECK ([DiscountAmount]>=(0));
GO
ALTER TABLE dbo.[Invoices] ADD CONSTRAINT [CK_Invoices_Method] CHECK ([PaymentMethod]='TRANSFER' OR [PaymentMethod]='CASH');
GO
ALTER TABLE dbo.[Invoices] ADD CONSTRAINT [CK_Invoices_Status] CHECK ([PaymentStatus]='REFUNDED' OR [PaymentStatus]='PAID' OR [PaymentStatus]='UNPAID');
GO
ALTER TABLE dbo.[RepairTickets] ADD CONSTRAINT [CK_Tickets_Status] CHECK ([Status]='CANCELLED' OR [Status]='DELIVERED' OR [Status]='COMPLETED' OR [Status]='REPAIRING' OR [Status]='WAITING_CONFIRM' OR [Status]='DIAGNOSING' OR [Status]='RECEIVED');
GO
ALTER TABLE dbo.[ServiceTypes] ADD CONSTRAINT [CK_ServiceTypes_LaborCost] CHECK ([LaborCost]>=(0));
GO
ALTER TABLE dbo.[ServiceTypes] ADD CONSTRAINT [CK_ServiceTypes_WarrantyDays] CHECK ([WarrantyDays]>=(0));
GO
ALTER TABLE dbo.[SpareParts] ADD CONSTRAINT [CK_Parts_MinStock] CHECK ([MinStockLevel]>=(0));
GO
ALTER TABLE dbo.[SpareParts] ADD CONSTRAINT [CK_Parts_PurchasePrice] CHECK ([PurchasePrice]>=(0));
GO
ALTER TABLE dbo.[SpareParts] ADD CONSTRAINT [CK_Parts_SellingPrice] CHECK ([SellingPrice]>=(0));
GO
ALTER TABLE dbo.[SpareParts] ADD CONSTRAINT [CK_Parts_Stock] CHECK ([StockQuantity]>=(0));
GO
ALTER TABLE dbo.[StockTransactions] ADD CONSTRAINT [CK_Stock_Quantity] CHECK ([Quantity]>(0));
GO
ALTER TABLE dbo.[StockTransactions] ADD CONSTRAINT [CK_Stock_Type] CHECK ([TransactionType]='RETURN' OR [TransactionType]='ADJUST' OR [TransactionType]='OUT' OR [TransactionType]='IN');
GO
ALTER TABLE dbo.[TicketParts] ADD CONSTRAINT [CK_TicketParts_Quantity] CHECK ([Quantity]>(0));
GO
ALTER TABLE dbo.[TicketParts] ADD CONSTRAINT [CK_TicketParts_UnitPrice] CHECK ([UnitPrice]>=(0));
GO
ALTER TABLE dbo.[Warranties] ADD CONSTRAINT [CK_Warranties_Date] CHECK ([EndDate]>=[StartDate]);
GO
ALTER TABLE dbo.[Warranties] ADD CONSTRAINT [CK_Warranties_Status] CHECK ([Status]='USED' OR [Status]='VOID' OR [Status]='EXPIRED' OR [Status]='ACTIVE');
GO
ALTER TABLE dbo.[Devices] ADD CONSTRAINT [FK_Devices_Customers] FOREIGN KEY (CustomerId) REFERENCES dbo.[Customers] (CustomerId);
GO
ALTER TABLE dbo.[Invoices] ADD CONSTRAINT [FK_Invoices_Customers] FOREIGN KEY (CustomerId) REFERENCES dbo.[Customers] (CustomerId);
GO
ALTER TABLE dbo.[Invoices] ADD CONSTRAINT [FK_Invoices_Tickets] FOREIGN KEY (TicketId) REFERENCES dbo.[RepairTickets] (TicketId);
GO
ALTER TABLE dbo.[Invoices] ADD CONSTRAINT [FK_Invoices_Users] FOREIGN KEY (CreatedByUserId) REFERENCES dbo.[Users] (UserId);
GO
ALTER TABLE dbo.[Payments] ADD CONSTRAINT [FK_Payments_Invoices] FOREIGN KEY (InvoiceId) REFERENCES dbo.[Invoices] (InvoiceId);
GO
ALTER TABLE dbo.[Payments] ADD CONSTRAINT [FK_Payments_Users] FOREIGN KEY (ReceivedByUserId) REFERENCES dbo.[Users] (UserId);
GO
ALTER TABLE dbo.[RepairTickets] ADD CONSTRAINT [FK_Tickets_Customers] FOREIGN KEY (CustomerId) REFERENCES dbo.[Customers] (CustomerId);
GO
ALTER TABLE dbo.[RepairTickets] ADD CONSTRAINT [FK_Tickets_Devices] FOREIGN KEY (DeviceId) REFERENCES dbo.[Devices] (DeviceId);
GO
ALTER TABLE dbo.[RepairTickets] ADD CONSTRAINT [FK_Tickets_Original] FOREIGN KEY (OriginalTicketId) REFERENCES dbo.[RepairTickets] (TicketId);
GO
ALTER TABLE dbo.[RepairTickets] ADD CONSTRAINT [FK_Tickets_Received] FOREIGN KEY (ReceivedByUserId) REFERENCES dbo.[Users] (UserId);
GO
ALTER TABLE dbo.[RepairTickets] ADD CONSTRAINT [FK_Tickets_Services] FOREIGN KEY (ServiceTypeId) REFERENCES dbo.[ServiceTypes] (ServiceTypeId);
GO
ALTER TABLE dbo.[RepairTickets] ADD CONSTRAINT [FK_Tickets_Technician] FOREIGN KEY (TechnicianUserId) REFERENCES dbo.[Users] (UserId);
GO
ALTER TABLE dbo.[SpareParts] ADD CONSTRAINT [FK_Parts_Categories] FOREIGN KEY (CategoryId) REFERENCES dbo.[SparePartCategories] (CategoryId);
GO
ALTER TABLE dbo.[StockTransactions] ADD CONSTRAINT [FK_Stock_Parts] FOREIGN KEY (PartId) REFERENCES dbo.[SpareParts] (PartId);
GO
ALTER TABLE dbo.[StockTransactions] ADD CONSTRAINT [FK_Stock_Tickets] FOREIGN KEY (TicketId) REFERENCES dbo.[RepairTickets] (TicketId);
GO
ALTER TABLE dbo.[StockTransactions] ADD CONSTRAINT [FK_Stock_Users] FOREIGN KEY (PerformedByUserId) REFERENCES dbo.[Users] (UserId);
GO
ALTER TABLE dbo.[TicketParts] ADD CONSTRAINT [FK_TicketParts_Parts] FOREIGN KEY (PartId) REFERENCES dbo.[SpareParts] (PartId);
GO
ALTER TABLE dbo.[TicketParts] ADD CONSTRAINT [FK_TicketParts_Tickets] FOREIGN KEY (TicketId) REFERENCES dbo.[RepairTickets] (TicketId);
GO
ALTER TABLE dbo.[TicketStatusHistory] ADD CONSTRAINT [FK_History_Tickets] FOREIGN KEY (TicketId) REFERENCES dbo.[RepairTickets] (TicketId);
GO
ALTER TABLE dbo.[TicketStatusHistory] ADD CONSTRAINT [FK_History_Users] FOREIGN KEY (ChangedByUserId) REFERENCES dbo.[Users] (UserId);
GO
ALTER TABLE dbo.[Users] ADD CONSTRAINT [FK_Users_Customers] FOREIGN KEY (CustomerId) REFERENCES dbo.[Customers] (CustomerId);
GO
ALTER TABLE dbo.[Users] ADD CONSTRAINT [FK_Users_Roles] FOREIGN KEY (RoleId) REFERENCES dbo.[Roles] (RoleId);
GO
ALTER TABLE dbo.[Warranties] ADD CONSTRAINT [FK_Warranties_Customers] FOREIGN KEY (CustomerId) REFERENCES dbo.[Customers] (CustomerId);
GO
ALTER TABLE dbo.[Warranties] ADD CONSTRAINT [FK_Warranties_Devices] FOREIGN KEY (DeviceId) REFERENCES dbo.[Devices] (DeviceId);
GO
ALTER TABLE dbo.[Warranties] ADD CONSTRAINT [FK_Warranties_Tickets] FOREIGN KEY (TicketId) REFERENCES dbo.[RepairTickets] (TicketId);
GO
CREATE NONCLUSTERED INDEX [IX_Customers_Phone] ON dbo.[Customers] (Phone);
GO
CREATE NONCLUSTERED INDEX [IX_Devices_CustomerId] ON dbo.[Devices] (CustomerId);
GO
CREATE NONCLUSTERED INDEX [IX_Devices_SerialNumber] ON dbo.[Devices] (SerialNumber);
GO
CREATE NONCLUSTERED INDEX [IX_Invoices_CustomerId] ON dbo.[Invoices] (CustomerId);
GO
CREATE NONCLUSTERED INDEX [IX_Invoices_CreatedAt] ON dbo.[Invoices] (CreatedAt);
GO
CREATE NONCLUSTERED INDEX [IX_Payments_InvoiceId] ON dbo.[Payments] (InvoiceId);
GO
CREATE NONCLUSTERED INDEX [IX_Tickets_CustomerId] ON dbo.[RepairTickets] (CustomerId);
GO
CREATE NONCLUSTERED INDEX [IX_Tickets_Status] ON dbo.[RepairTickets] (Status);
GO
CREATE NONCLUSTERED INDEX [IX_Tickets_ReceivedAt] ON dbo.[RepairTickets] (ReceivedAt);
GO
CREATE NONCLUSTERED INDEX [IX_Tickets_Technician] ON dbo.[RepairTickets] (TechnicianUserId);
GO
CREATE NONCLUSTERED INDEX [IX_Parts_CategoryId] ON dbo.[SpareParts] (CategoryId);
GO
CREATE NONCLUSTERED INDEX [IX_Parts_PartName] ON dbo.[SpareParts] (PartName);
GO
CREATE NONCLUSTERED INDEX [IX_Stock_PartId] ON dbo.[StockTransactions] (PartId);
GO
CREATE NONCLUSTERED INDEX [IX_Stock_TicketId] ON dbo.[StockTransactions] (TicketId);
GO
CREATE NONCLUSTERED INDEX [IX_Stock_TransactionAt] ON dbo.[StockTransactions] (TransactionAt);
GO
CREATE NONCLUSTERED INDEX [IX_TicketParts_TicketId] ON dbo.[TicketParts] (TicketId);
GO
CREATE NONCLUSTERED INDEX [IX_TicketParts_PartId] ON dbo.[TicketParts] (PartId);
GO
CREATE NONCLUSTERED INDEX [IX_History_TicketId] ON dbo.[TicketStatusHistory] (TicketId);
GO
CREATE NONCLUSTERED INDEX [IX_Users_RoleId] ON dbo.[Users] (RoleId);
GO
CREATE NONCLUSTERED INDEX [IX_Users_CustomerId] ON dbo.[Users] (CustomerId);
GO
CREATE NONCLUSTERED INDEX [IX_Warranties_TicketId] ON dbo.[Warranties] (TicketId);
GO
CREATE NONCLUSTERED INDEX [IX_Warranties_CustomerId] ON dbo.[Warranties] (CustomerId);
GO
CREATE NONCLUSTERED INDEX [IX_Warranties_EndDate] ON dbo.[Warranties] (EndDate);
GO

-- ===== DU LIEU =====

-- Customers: 45 dong
SET IDENTITY_INSERT dbo.[Customers] ON;
INSERT INTO dbo.[Customers] ([CustomerId], [CustomerCode], [FullName], [Phone], [Email], [Address], [Note], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (1, N'KH000001', N'Nguyễn Thành Nam', N'0982345678', N'nam.nguyen@gmail.com', N'142 Võ Văn Tần, Phường 6, Quận 3, TP.HCM', N'Khách hàng VIP doanh nghiệp', 1, '2026-10-05T09:05:12.5660000', NULL);
INSERT INTO dbo.[Customers] ([CustomerId], [CustomerCode], [FullName], [Phone], [Email], [Address], [Note], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (2, N'KH000002', N'Lê Hoàng Phúc', N'0903124567', N'phuc.le@outlook.com', N'475A Điện Biên Phủ, Phường 25, Bình Thạnh, TP.HCM', N'Giảng viên ĐH HUTECH', 1, '2026-10-07T09:05:12.5660000', NULL);
INSERT INTO dbo.[Customers] ([CustomerId], [CustomerCode], [FullName], [Phone], [Email], [Address], [Note], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (3, N'KH000003', N'Đặng Minh Tâm', N'0918765432', N'tam.dang@fpt.edu.vn', N'280 An Dương Vương, Phường 4, Quận 5, TP.HCM', N'Lập trình viên Senior', 1, '2026-10-10T09:05:12.5660000', NULL);
INSERT INTO dbo.[Customers] ([CustomerId], [CustomerCode], [FullName], [Phone], [Email], [Address], [Note], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (4, N'KH000004', N'Võ Hoài Thương', N'0976543210', N'thuong.vo@gmail.com', N'120 Hai Bà Trưng, Phường Đa Kao, Quận 1, TP.HCM', N'Thiết kế đồ họa Studio', 1, '2026-10-13T09:05:12.5660000', NULL);
INSERT INTO dbo.[Customers] ([CustomerId], [CustomerCode], [FullName], [Phone], [Email], [Address], [Note], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (5, N'KH000005', N'Phan Thanh Tùng', N'0938889900', N'tung.phan@techcorp.vn', N'68 Nguyễn Huệ, Phường Bến Nghé, Quận 1, TP.HCM', N'Khách sửa máy tính PC gaming', 1, '2026-10-15T09:05:12.5660000', NULL);
INSERT INTO dbo.[Customers] ([CustomerId], [CustomerCode], [FullName], [Phone], [Email], [Address], [Note], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (6, N'KH000006', N'Hoàng Thị Mai Anh', N'0908112233', N'maianh.hoang@gmail.com', N'354 Lê Văn Sỹ, Phường 14, Quận 3, TP.HCM', N'Khách hàng thân thiết', 1, '2026-10-17T09:05:12.5660000', NULL);
INSERT INTO dbo.[Customers] ([CustomerId], [CustomerCode], [FullName], [Phone], [Email], [Address], [Note], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (7, N'KH000007', N'Trần Đình Trọng', N'0919223344', N'trong.td@gmail.com', N'89 Phan Xích Long, Phường 2, Phú Nhuận, TP.HCM', N'Khách sửa iPad đồ họa', 1, '2026-10-19T09:05:12.5660000', NULL);
INSERT INTO dbo.[Customers] ([CustomerId], [CustomerCode], [FullName], [Phone], [Email], [Address], [Note], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (8, N'KH000008', N'Bùi Quang Huy', N'0966554433', N'huy.bui@hutech.edu.vn', N'31/2 Ung Văn Khiêm, Phường 25, Bình Thạnh, TP.HCM', N'Sinh viên Khoa CNTT', 1, '2026-10-21T09:05:12.5660000', NULL);
INSERT INTO dbo.[Customers] ([CustomerId], [CustomerCode], [FullName], [Phone], [Email], [Address], [Note], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (9, N'KH000009', N'Đỗ Phương Thảo', N'0902998877', N'thao.dophuong@gmail.com', N'52 Nguyễn Thị Minh Khai, Quận 1, TP.HCM', N'Khách hàng thay pin iPhone', 1, '2026-10-22T09:05:12.5660000', NULL);
INSERT INTO dbo.[Customers] ([CustomerId], [CustomerCode], [FullName], [Phone], [Email], [Address], [Note], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (10, N'KH000010', N'Ngô Gia Bảo', N'0913445566', N'bao.ngo@gmail.com', N'215 Hồng Bàng, Phường 11, Quận 5, TP.HCM', N'Khách sửa laptop văn phòng', 1, '2026-10-24T09:05:12.5660000', NULL);
INSERT INTO dbo.[Customers] ([CustomerId], [CustomerCode], [FullName], [Phone], [Email], [Address], [Note], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (11, N'KH000011', N'Vũ Minh Tuấn', N'0912348899', N'tuan.vu@gmail.com', N'72 Lê Thánh Tôn, Bến Nghé, Quận 1, TP.HCM', N'Khách hàng thân thiết', 1, '2026-10-07T10:01:02.7060000', NULL);
INSERT INTO dbo.[Customers] ([CustomerId], [CustomerCode], [FullName], [Phone], [Email], [Address], [Note], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (12, N'KH000012', N'Đặng Thu Thảo', N'0987112244', N'thao.dang@vietcombank.com.vn', N'11 Bến Chương Dương, Cầu Kho, Quận 1, TP.HCM', N'Chuyên viên Vietcombank', 1, '2026-10-09T10:01:02.7060000', NULL);
INSERT INTO dbo.[Customers] ([CustomerId], [CustomerCode], [FullName], [Phone], [Email], [Address], [Note], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (13, N'KH000013', N'Lê Tấn Phát', N'0908776655', N'phat.le@fpt.com', N'29 Lê Duẩn, Bến Nghé, Quận 1, TP.HCM', N'Kỹ sư hệ thống FPT', 1, '2026-10-11T10:01:02.7060000', NULL);
INSERT INTO dbo.[Customers] ([CustomerId], [CustomerCode], [FullName], [Phone], [Email], [Address], [Note], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (14, N'KH000014', N'Phạm Ngọc Lan', N'0932115599', N'lan.pham@techcombank.com.vn', N'198 Nguyễn Thị Minh Khai, Phường 6, Quận 3, TP.HCM', N'Quản lý Techcombank', 1, '2026-10-12T10:01:02.7060000', NULL);
INSERT INTO dbo.[Customers] ([CustomerId], [CustomerCode], [FullName], [Phone], [Email], [Address], [Note], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (15, N'KH000015', N'Nguyễn Hữu Trí', N'0978665511', N'tri.nguyenhuu@gmail.com', N'45 Trương Định, Phường 6, Quận 3, TP.HCM', N'Content Creator YouTube', 1, '2026-10-14T10:01:02.7060000', NULL);
INSERT INTO dbo.[Customers] ([CustomerId], [CustomerCode], [FullName], [Phone], [Email], [Address], [Note], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (16, N'KH000016', N'Trần Bảo Long', N'0919334422', N'long.tranbao@gmail.com', N'209 Nam Kỳ Khởi Nghĩa, Phường 7, Quận 3, TP.HCM', N'Kiến trúc sư xây dựng', 1, '2026-10-16T10:01:02.7060000', NULL);
INSERT INTO dbo.[Customers] ([CustomerId], [CustomerCode], [FullName], [Phone], [Email], [Address], [Note], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (17, N'KH000017', N'Huỳnh Quốc Dũng', N'0968221177', N'dung.hq@gameloft.com', N'80 Nguyễn Huệ, Phường Bến Nghé, Quận 1, TP.HCM', N'Game Designer Gameloft', 1, '2026-10-17T10:01:02.7060000', NULL);
INSERT INTO dbo.[Customers] ([CustomerId], [CustomerCode], [FullName], [Phone], [Email], [Address], [Note], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (18, N'KH000018', N'Đoàn Thanh Hương', N'0909554488', N'huong.doan@gmail.com', N'150 Nguyễn Đình Chiểu, Phường 6, Quận 3, TP.HCM', N'Chủ chuỗi cửa hàng hoa tươi', 1, '2026-10-18T10:01:02.7060000', NULL);
INSERT INTO dbo.[Customers] ([CustomerId], [CustomerCode], [FullName], [Phone], [Email], [Address], [Note], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (19, N'KH000019', N'Hoàng Gia Huy', N'0989332211', N'huy.hoanggia@gmail.com', N'256 Xô Viết Nghệ Tĩnh, Phường 21, Bình Thạnh, TP.HCM', N'Sinh viên ĐH Ngoại Thương', 1, '2026-10-19T10:01:02.7060000', NULL);
INSERT INTO dbo.[Customers] ([CustomerId], [CustomerCode], [FullName], [Phone], [Email], [Address], [Note], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (20, N'KH000020', N'Đinh Văn Sơn', N'0914667788', N'son.dinhvan@shopee.vn', N'56 Hoàng Diệu, Phường 12, Quận 4, TP.HCM', N'Quản lý sàn TMĐT Shopee', 1, '2026-10-20T10:01:02.7060000', NULL);
INSERT INTO dbo.[Customers] ([CustomerId], [CustomerCode], [FullName], [Phone], [Email], [Address], [Note], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (21, N'KH000021', N'Trịnh Cẩm Tú', N'0977889900', N'tu.trinhcam@vinamilk.com.vn', N'10 Tân Trào, Tân Phú, Quận 7, TP.HCM', N'Kế toán trưởng Vinamilk', 1, '2026-10-21T10:01:02.7060000', NULL);
INSERT INTO dbo.[Customers] ([CustomerId], [CustomerCode], [FullName], [Phone], [Email], [Address], [Note], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (22, N'KH000022', N'Bùi Minh Triết', N'0907113355', N'triet.bui@gmail.com', N'38 Nguyễn Văn Trỗi, Phường 15, Phú Nhuận, TP.HCM', N'Nhiếp ảnh gia tự do', 1, '2026-10-22T10:01:02.7060000', NULL);
INSERT INTO dbo.[Customers] ([CustomerId], [CustomerCode], [FullName], [Phone], [Email], [Address], [Note], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (23, N'KH000023', N'Cao Khánh Linh', N'0983445566', N'linh.caokhanh@gmail.com', N'182 Lê Văn Sỹ, Phường 10, Phú Nhuận, TP.HCM', N'Chủ shop thời trang online', 1, '2026-10-23T10:01:02.7060000', NULL);
INSERT INTO dbo.[Customers] ([CustomerId], [CustomerCode], [FullName], [Phone], [Email], [Address], [Note], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (24, N'KH000024', N'Lâm Thế Vinh', N'0918223344', N'vinh.lamthe@vng.com.vn', N'182 Ba Tháng Hai, Phường 12, Quận 10, TP.HCM', N'Kỹ sư phần mềm VNG Corp', 1, '2026-10-24T10:01:02.7060000', NULL);
INSERT INTO dbo.[Customers] ([CustomerId], [CustomerCode], [FullName], [Phone], [Email], [Address], [Note], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (25, N'KH000025', N'Mai Thanh Hà', N'0906778899', N'ha.maithanh@gmail.com', N'91 Sư Vạn Hạnh, Phường 12, Quận 10, TP.HCM', N'Bác sĩ nha khoa Quốc tế', 1, '2026-10-25T10:01:02.7060000', NULL);
INSERT INTO dbo.[Customers] ([CustomerId], [CustomerCode], [FullName], [Phone], [Email], [Address], [Note], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (26, N'KH000026', N'Kiểm Thử Viên Tự Động', N'0936990058', N'test.auto@repairshop.local', N'123 Đường Kiểm Thử, Quận 1, TP.HCM', NULL, 1, '2026-10-25T10:01:32.2650000', NULL);
INSERT INTO dbo.[Customers] ([CustomerId], [CustomerCode], [FullName], [Phone], [Email], [Address], [Note], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (27, N'KH000027', N'Kiểm Thử Viên Tự Động (Đã Cập Nhật)', N'0964011961', N'test.updated@repairshop.local', N'456 Đường Mới, Quận 3, TP.HCM', NULL, 1, '2026-10-25T10:02:44.0740000', '2026-10-25T10:02:44.0910000');
INSERT INTO dbo.[Customers] ([CustomerId], [CustomerCode], [FullName], [Phone], [Email], [Address], [Note], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (28, N'KH000028', N'Kiểm Thử Viên Tự Động (Đã Cập Nhật)', N'0939944528', N'test.updated@repairshop.local', N'456 Đường Mới, Quận 3, TP.HCM', NULL, 1, '2026-10-25T10:03:57.9440000', '2026-10-25T10:03:57.9910000');
INSERT INTO dbo.[Customers] ([CustomerId], [CustomerCode], [FullName], [Phone], [Email], [Address], [Note], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (29, N'KH000029', N'Kiểm Thử Viên Tự Động (Đã Cập Nhật)', N'0974180080', N'test.updated@repairshop.local', N'456 Đường Mới, Quận 3, TP.HCM', NULL, 1, '2026-10-25T10:04:37.9440000', '2026-10-25T10:04:37.9590000');
INSERT INTO dbo.[Customers] ([CustomerId], [CustomerCode], [FullName], [Phone], [Email], [Address], [Note], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (30, N'KH000030', N'Kiểm Thử Viên Tự Động (Đã Cập Nhật)', N'0936861485', N'test.updated@repairshop.local', N'456 Đường Mới, Quận 3, TP.HCM', NULL, 1, '2026-10-26T07:50:08.2596083', '2026-10-26T07:50:08.3129999');
INSERT INTO dbo.[Customers] ([CustomerId], [CustomerCode], [FullName], [Phone], [Email], [Address], [Note], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (31, N'KH000031', N'Kiểm Thử Viên Tự Động (Đã Cập Nhật)', N'0980488133', N'test.updated@repairshop.local', N'456 Đường Mới, Quận 3, TP.HCM', NULL, 1, '2026-10-26T07:51:27.7204894', '2026-10-26T07:51:27.7378450');
INSERT INTO dbo.[Customers] ([CustomerId], [CustomerCode], [FullName], [Phone], [Email], [Address], [Note], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (32, N'KH000032', N'Kiểm Thử Viên Tự Động (Đã Cập Nhật)', N'0920600131', N'test.updated@repairshop.local', N'456 Đường Mới, Quận 3, TP.HCM', NULL, 1, '2026-10-26T09:22:16.6521960', '2026-10-26T09:22:16.6627746');
INSERT INTO dbo.[Customers] ([CustomerId], [CustomerCode], [FullName], [Phone], [Email], [Address], [Note], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (33, N'KH000033', N'Trịnh Thùy Linh', N'0908123456', N'thuylinh.trinh@vng.com.vn', N'268 Lý Thường Kiệt, Phường 14, Quận 10, TP.HCM', N'Quản lý sản phẩm Game', 1, '2026-10-28T21:41:41.0233333', '2026-10-28T21:41:41.0233333');
INSERT INTO dbo.[Customers] ([CustomerId], [CustomerCode], [FullName], [Phone], [Email], [Address], [Note], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (34, N'KH000034', N'Hoàng Quốc Bảo', N'0912345678', N'bao.hoang@techcombank.com.vn', N'191 Bà Triệu, Hai Bà Trưng, Hà Nội', N'Khách hàng VIP thẻ Platinum', 1, '2026-10-28T21:41:41.0233333', '2026-10-28T21:41:41.0233333');
INSERT INTO dbo.[Customers] ([CustomerId], [CustomerCode], [FullName], [Phone], [Email], [Address], [Note], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (35, N'KH000035', N'Vũ Minh Trí', N'0934567890', N'tri.vu@fpt.com', N'Lô E2a-7, Đường D1, Khu Công nghệ cao, TP. Thủ Đức', N'Kỹ sư AI & Robotics', 1, '2026-10-28T21:41:41.0300000', '2026-10-28T21:41:41.0300000');
INSERT INTO dbo.[Customers] ([CustomerId], [CustomerCode], [FullName], [Phone], [Email], [Address], [Note], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (36, N'KH000036', N'Đỗ Mai Anh', N'0978901234', N'maianh.do@shopee.vn', N'Tòa nhà Saigon Centre, 65 Lê Lợi, Quận 1, TP.HCM', N'Trưởng phòng Marketing', 1, '2026-10-28T21:41:41.0300000', '2026-10-28T21:41:41.0300000');
INSERT INTO dbo.[Customers] ([CustomerId], [CustomerCode], [FullName], [Phone], [Email], [Address], [Note], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (37, N'KH000037', N'Lâm Bá Khang', N'0987654321', N'khang.lam@viettel.com.vn', N'285 Cách Mạng Tháng 8, Phường 12, Quận 10, TP.HCM', N'Kỹ sư mạng Viễn thông', 1, '2026-10-28T21:41:41.0300000', '2026-10-28T21:41:41.0300000');
INSERT INTO dbo.[Customers] ([CustomerId], [CustomerCode], [FullName], [Phone], [Email], [Address], [Note], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (38, N'KH000038', N'Bùi Kim Ngân', N'0945678901', N'ngan.bui@vingroup.net', N'Khu đô thị Vinhomes Central Park, Bình Thạnh, TP.HCM', N'Bác sĩ Da liễu', 1, '2026-10-28T21:41:41.0333333', '2026-10-28T21:41:41.0333333');
INSERT INTO dbo.[Customers] ([CustomerId], [CustomerCode], [FullName], [Phone], [Email], [Address], [Note], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (39, N'KH000039', N'Cao Văn Dũng', N'0961234567', N'dung.cao@gearvn.com', N'78 Hoàng Hoa Thám, Phường 12, Tân Bình, TP.HCM', N'Streamer & Content Creator', 1, '2026-10-28T21:41:41.0400000', '2026-10-28T21:41:41.0400000');
INSERT INTO dbo.[Customers] ([CustomerId], [CustomerCode], [FullName], [Phone], [Email], [Address], [Note], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (40, N'KH000040', N'Đinh Thu Trang', N'0918765432', N'trang.dinh@vietjetair.com', N'321 Trường Chinh, Phường 14, Tân Bình, TP.HCM', N'Tiếp viên hàng không', 1, '2026-10-28T21:41:41.0400000', '2026-10-28T21:41:41.0400000');
INSERT INTO dbo.[Customers] ([CustomerId], [CustomerCode], [FullName], [Phone], [Email], [Address], [Note], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (41, N'KH000041', N'Hồ Nhật Nam', N'0909876543', N'nam.ho@vinfast.vn', N'Khu đô thị Sala, TP. Thủ Đức, TP.HCM', N'Kỹ sư phần mềm nhúng', 1, '2026-10-28T21:41:41.0433333', '2026-10-28T21:41:41.0433333');
INSERT INTO dbo.[Customers] ([CustomerId], [CustomerCode], [FullName], [Phone], [Email], [Address], [Note], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (42, N'KH000042', N'Ngô Phương Uyên', N'0938765432', N'uyen.ngo@tiktok.com', N'Tòa nhà Deutsches Haus, 33 Lê Duẩn, Quận 1, TP.HCM', N'Creator Partnership Lead', 1, '2026-10-28T21:41:41.0466667', '2026-10-28T21:41:41.0466667');
INSERT INTO dbo.[Customers] ([CustomerId], [CustomerCode], [FullName], [Phone], [Email], [Address], [Note], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (46, N'DEMO-TEST-KH01', N'Nguyễn Thị Ánh Dương', N'0901112233', N'anhduong.nguyen@testmail.vn', N'72/14 Lê Văn Sỹ, Phường 11, Quận Phú Nhuận, TP.HCM', N'Khách hàng test ký tự UTF-8 phức tạp', 1, '2026-10-29T12:58:22.1672248', NULL);
INSERT INTO dbo.[Customers] ([CustomerId], [CustomerCode], [FullName], [Phone], [Email], [Address], [Note], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (47, N'DEMO-TEST-KH02', N'Trịnh Trần Phương Tuấn', N'0902223344', N'tuan.trinh@testmail.vn', N'120 Nguyễn Tri Phương, Phường 7, Quận 5, TP.HCM', N'Khách hàng test chuỗi họ tên 4 âm tiết', 1, '2026-10-29T12:58:22.1672248', NULL);
INSERT INTO dbo.[Customers] ([CustomerId], [CustomerCode], [FullName], [Phone], [Email], [Address], [Note], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (48, N'DEMO-TEST-KH03', N'Võ Hoàng Yến Đan', N'0903334455', N'yendan.vo@testmail.vn', N'45 Hai Bà Trưng, Phường Bến Nghé, Quận 1, TP.HCM', N'Khách hàng test thanh điệu tiếng Việt', 1, '2026-10-29T12:58:22.1672248', NULL);
SET IDENTITY_INSERT dbo.[Customers] OFF;
GO

-- Devices: 47 dong
SET IDENTITY_INSERT dbo.[Devices] ON;
INSERT INTO dbo.[Devices] ([DeviceId], [CustomerId], [DeviceType], [Brand], [Model], [SerialNumber], [Note], [CreatedAt], [DeviceCode]) VALUES (1, 1, N'Laptop', N'Dell', N'XPS 15 9520 (Core i7-12700H / 32GB / 1TB SSD)', N'DLXPS-9520-VN01', N'Máy đồ họa cao cấp', '2026-10-05T09:05:12.5660000', N'TB000001');
INSERT INTO dbo.[Devices] ([DeviceId], [CustomerId], [DeviceType], [Brand], [Model], [SerialNumber], [Note], [CreatedAt], [DeviceCode]) VALUES (2, 2, N'Điện thoại', N'Apple', N'iPhone 14 Pro Max 256GB Deep Purple', N'F2LX90A4MD6R', N'Máy chính hãng VNA', '2026-10-07T09:05:12.5660000', N'TB000002');
INSERT INTO dbo.[Devices] ([DeviceId], [CustomerId], [DeviceType], [Brand], [Model], [SerialNumber], [Note], [CreatedAt], [DeviceCode]) VALUES (3, 3, N'Laptop', N'Apple', N'MacBook Pro 14 M2 Pro 2023 Space Gray', N'C02G90ABMD6T', N'Máy lập trình di động', '2026-10-10T09:05:12.5660000', N'TB000003');
INSERT INTO dbo.[Devices] ([DeviceId], [CustomerId], [DeviceType], [Brand], [Model], [SerialNumber], [Note], [CreatedAt], [DeviceCode]) VALUES (4, 4, N'Điện thoại', N'Samsung', N'Galaxy S23 Ultra 5G 512GB Phantom Black', N'R5CW20ABXYZ', N'Bản chính hãng SSVN', '2026-10-13T09:05:12.5660000', N'TB000004');
INSERT INTO dbo.[Devices] ([DeviceId], [CustomerId], [DeviceType], [Brand], [Model], [SerialNumber], [Note], [CreatedAt], [DeviceCode]) VALUES (5, 5, N'Máy tính PC', N'ASUS / MSI', N'PC Gaming Core i7-13700K / RTX 3070 8GB', N'PCG-2026-SG01', N'Case Corsair 4000D tản nước', '2026-10-15T09:05:12.5660000', N'TB000005');
INSERT INTO dbo.[Devices] ([DeviceId], [CustomerId], [DeviceType], [Brand], [Model], [SerialNumber], [Note], [CreatedAt], [DeviceCode]) VALUES (6, 6, N'Laptop', N'Asus', N'ROG Zephyrus G14 (Ryzen 7 6800HS / RX 6700S)', N'GA402RJ-L8035W', N'Laptop gaming mỏng nhẹ', '2026-10-17T09:05:12.5660000', N'TB000006');
INSERT INTO dbo.[Devices] ([DeviceId], [CustomerId], [DeviceType], [Brand], [Model], [SerialNumber], [Note], [CreatedAt], [DeviceCode]) VALUES (7, 7, N'Máy tính bảng', N'Apple', N'iPad Pro 11 M1 128GB Wi-Fi + 5G', N'DMPD30A8MD6M', N'Dùng vẽ và đồ họa Procreate', '2026-10-19T09:05:12.5660000', N'TB000007');
INSERT INTO dbo.[Devices] ([DeviceId], [CustomerId], [DeviceType], [Brand], [Model], [SerialNumber], [Note], [CreatedAt], [DeviceCode]) VALUES (8, 8, N'Laptop', N'Lenovo', N'ThinkPad X1 Carbon Gen 10 (Core i7-1260P / 16GB)', N'PF3X99AB2023', N'Máy doanh nhân siêu bền', '2026-10-21T09:05:12.5660000', N'TB000008');
INSERT INTO dbo.[Devices] ([DeviceId], [CustomerId], [DeviceType], [Brand], [Model], [SerialNumber], [Note], [CreatedAt], [DeviceCode]) VALUES (9, 9, N'Điện thoại', N'Apple', N'iPhone 13 128GB Starlight', N'DX3F40ABMD6N', N'Máy nữ dùng giữ gìn', '2026-10-22T09:05:12.5660000', N'TB000009');
INSERT INTO dbo.[Devices] ([DeviceId], [CustomerId], [DeviceType], [Brand], [Model], [SerialNumber], [Note], [CreatedAt], [DeviceCode]) VALUES (10, 10, N'Laptop', N'HP', N'Envy 13-ba1000 Core i5-1135G7 / 8GB RAM', N'5CD2180ABC', N'Laptop văn phòng mỏng nhẹ', '2026-10-24T09:05:12.5660000', N'TB000010');
INSERT INTO dbo.[Devices] ([DeviceId], [CustomerId], [DeviceType], [Brand], [Model], [SerialNumber], [Note], [CreatedAt], [DeviceCode]) VALUES (11, 11, N'Điện thoại', N'Apple', N'iPhone 15 Pro Max 256GB Natural Titanium', N'NM9X20PMAA', N'Máy mới bóc hộp 3 tháng', '2026-10-07T10:01:02.7060000', N'TB000011');
INSERT INTO dbo.[Devices] ([DeviceId], [CustomerId], [DeviceType], [Brand], [Model], [SerialNumber], [Note], [CreatedAt], [DeviceCode]) VALUES (12, 12, N'Laptop', N'Apple', N'MacBook Air 13 M1 2020 Space Gray', N'C02F99MBAA', N'Máy văn phòng mỏng nhẹ', '2026-10-09T10:01:02.7060000', N'TB000012');
INSERT INTO dbo.[Devices] ([DeviceId], [CustomerId], [DeviceType], [Brand], [Model], [SerialNumber], [Note], [CreatedAt], [DeviceCode]) VALUES (13, 13, N'Laptop', N'Asus', N'Asus TUF Gaming A15 (Ryzen 7 / RTX 3050)', N'AS-TUF-A15-VN', N'Laptop đồ họa & game', '2026-10-11T10:01:02.7060000', N'TB000013');
INSERT INTO dbo.[Devices] ([DeviceId], [CustomerId], [DeviceType], [Brand], [Model], [SerialNumber], [Note], [CreatedAt], [DeviceCode]) VALUES (14, 14, N'Điện thoại', N'Apple', N'iPhone 12 Pro 128GB Pacific Blue', N'F17D9890MD6P', N'Máy chính hãng LL/A', '2026-10-12T10:01:02.7060000', N'TB000014');
INSERT INTO dbo.[Devices] ([DeviceId], [CustomerId], [DeviceType], [Brand], [Model], [SerialNumber], [Note], [CreatedAt], [DeviceCode]) VALUES (15, 15, N'Máy tính PC', N'NZXT / Corsair', N'PC Workstation Core i9-13900K / RTX 4080 16GB', N'PCG-CUSTOM-4080', N'Cấu hình dựng phim 4K', '2026-10-14T10:01:02.7060000', N'TB000015');
INSERT INTO dbo.[Devices] ([DeviceId], [CustomerId], [DeviceType], [Brand], [Model], [SerialNumber], [Note], [CreatedAt], [DeviceCode]) VALUES (16, 16, N'Laptop', N'Lenovo', N'ThinkPad T14 Gen 3 Core i5-1240P / 16GB RAM', N'PF3398T14G3', N'Máy chuẩn quân đội Mỹ', '2026-10-16T10:01:02.7060000', N'TB000016');
INSERT INTO dbo.[Devices] ([DeviceId], [CustomerId], [DeviceType], [Brand], [Model], [SerialNumber], [Note], [CreatedAt], [DeviceCode]) VALUES (17, 17, N'Điện thoại', N'Samsung', N'Galaxy Z Fold5 5G 512GB Icy Blue', N'R5CW88FOLD5', N'Màn hình gập cao cấp', '2026-10-17T10:01:02.7060000', N'TB000017');
INSERT INTO dbo.[Devices] ([DeviceId], [CustomerId], [DeviceType], [Brand], [Model], [SerialNumber], [Note], [CreatedAt], [DeviceCode]) VALUES (18, 18, N'Máy tính bảng', N'Apple', N'iPad Air 5 64GB Wi-Fi M1 Purple', N'DMPD98AIR5VN', N'Vẽ minh họa iPadOS 17', '2026-10-18T10:01:02.7060000', N'TB000018');
INSERT INTO dbo.[Devices] ([DeviceId], [CustomerId], [DeviceType], [Brand], [Model], [SerialNumber], [Note], [CreatedAt], [DeviceCode]) VALUES (19, 19, N'Laptop', N'Dell', N'Inspiron 5510 Core i7-11370H / 16GB', N'DL-INS-5510-VN', N'Học tập và lập trình', '2026-10-19T10:01:02.7060000', N'TB000019');
INSERT INTO dbo.[Devices] ([DeviceId], [CustomerId], [DeviceType], [Brand], [Model], [SerialNumber], [Note], [CreatedAt], [DeviceCode]) VALUES (20, 20, N'Điện thoại', N'Xiaomi', N'Xiaomi 13 Pro 5G Leica 256GB Black', N'XM13P-LEICA-VN', N'Camera hợp tác Leica', '2026-10-20T10:01:02.7060000', N'TB000020');
INSERT INTO dbo.[Devices] ([DeviceId], [CustomerId], [DeviceType], [Brand], [Model], [SerialNumber], [Note], [CreatedAt], [DeviceCode]) VALUES (21, 21, N'Laptop', N'Apple', N'MacBook Pro 16 M3 Max 36GB / 1TB Space Black', N'C02M3MAX16VN', N'Máy lập trình cao cấp', '2026-10-21T10:01:02.7060000', N'TB000021');
INSERT INTO dbo.[Devices] ([DeviceId], [CustomerId], [DeviceType], [Brand], [Model], [SerialNumber], [Note], [CreatedAt], [DeviceCode]) VALUES (22, 22, N'Laptop', N'Acer', N'Nitro 5 Tiger AN515-58 Core i5-12500H / RTX 3050Ti', N'NHQFZSV001', N'Dùng chỉnh ảnh Lightroom', '2026-10-22T10:01:02.7060000', N'TB000022');
INSERT INTO dbo.[Devices] ([DeviceId], [CustomerId], [DeviceType], [Brand], [Model], [SerialNumber], [Note], [CreatedAt], [DeviceCode]) VALUES (23, 23, N'Điện thoại', N'Apple', N'iPhone 11 64GB Black', N'DX3D88IP11VN', N'Máy dùng livestream bán hàng', '2026-10-23T10:01:02.7060000', N'TB000023');
INSERT INTO dbo.[Devices] ([DeviceId], [CustomerId], [DeviceType], [Brand], [Model], [SerialNumber], [Note], [CreatedAt], [DeviceCode]) VALUES (24, 24, N'Laptop', N'HP', N'Pavilion 15-eg2000 Core i5-1240P / 8GB', N'5CD299HPVN', N'Laptop code Backend', '2026-10-24T10:01:02.7060000', N'TB000024');
INSERT INTO dbo.[Devices] ([DeviceId], [CustomerId], [DeviceType], [Brand], [Model], [SerialNumber], [Note], [CreatedAt], [DeviceCode]) VALUES (25, 25, N'Máy tính bàn', N'Apple', N'iMac 24" 4.5K Retina M1 8-core CPU / 8-core GPU Blue', N'C02G77IMAC24', N'Máy để quầy lễ tân nha khoa', '2026-10-25T10:01:02.7060000', N'TB000025');
INSERT INTO dbo.[Devices] ([DeviceId], [CustomerId], [DeviceType], [Brand], [Model], [SerialNumber], [Note], [CreatedAt], [DeviceCode]) VALUES (26, 11, N'Điện thoại', N'Apple', N'iPhone 14 Plus 128GB Midnight', N'F2LX88PLUSVN', N'Máy phụ dùng nghe gọi', '2026-10-10T10:01:02.7060000', N'TB000026');
INSERT INTO dbo.[Devices] ([DeviceId], [CustomerId], [DeviceType], [Brand], [Model], [SerialNumber], [Note], [CreatedAt], [DeviceCode]) VALUES (27, 14, N'Laptop', N'Dell', N'XPS 13 Plus 9320 Core i7-1260P Touch', N'DL-9320-PLUS-VN', N'Laptop mỏng nhẹ doanh nhân', '2026-10-15T10:01:02.7060000', N'TB000027');
INSERT INTO dbo.[Devices] ([DeviceId], [CustomerId], [DeviceType], [Brand], [Model], [SerialNumber], [Note], [CreatedAt], [DeviceCode]) VALUES (28, 16, N'Điện thoại', N'Samsung', N'Galaxy S22+ 5G 128GB Phantom White', N'R5CW66S22P', N'Máy phụ', '2026-10-17T10:01:02.7060000', N'TB000028');
INSERT INTO dbo.[Devices] ([DeviceId], [CustomerId], [DeviceType], [Brand], [Model], [SerialNumber], [Note], [CreatedAt], [DeviceCode]) VALUES (29, 27, N'Laptop', N'Dell', N'Latitude 7420 Core i7 / 16GB RAM', N'DL-TEST-1792897364095', NULL, '2026-10-25T10:02:44.1050000', N'TB000029');
INSERT INTO dbo.[Devices] ([DeviceId], [CustomerId], [DeviceType], [Brand], [Model], [SerialNumber], [Note], [CreatedAt], [DeviceCode]) VALUES (30, 28, N'Laptop', N'Dell', N'Latitude 7420 Core i7 / 16GB RAM', N'DL-TEST-1792897437996', NULL, '2026-10-25T10:03:58.0040000', N'TB000030');
INSERT INTO dbo.[Devices] ([DeviceId], [CustomerId], [DeviceType], [Brand], [Model], [SerialNumber], [Note], [CreatedAt], [DeviceCode]) VALUES (31, 29, N'Laptop', N'Dell', N'Latitude 7420 Core i7 / 16GB RAM', N'DL-TEST-1792897477961', NULL, '2026-10-25T10:04:37.9750000', N'TB000031');
INSERT INTO dbo.[Devices] ([DeviceId], [CustomerId], [DeviceType], [Brand], [Model], [SerialNumber], [Note], [CreatedAt], [DeviceCode]) VALUES (32, 30, N'Laptop', N'Dell', N'Latitude 7420 Core i7 / 16GB RAM', N'DL-TEST-1792975808317', NULL, '2026-10-26T07:50:08.3375838', N'TB000032');
INSERT INTO dbo.[Devices] ([DeviceId], [CustomerId], [DeviceType], [Brand], [Model], [SerialNumber], [Note], [CreatedAt], [DeviceCode]) VALUES (33, 31, N'Laptop', N'Dell', N'Latitude 7420 Core i7 / 16GB RAM', N'DL-TEST-1792975887741', NULL, '2026-10-26T07:51:27.7521108', N'TB000033');
INSERT INTO dbo.[Devices] ([DeviceId], [CustomerId], [DeviceType], [Brand], [Model], [SerialNumber], [Note], [CreatedAt], [DeviceCode]) VALUES (34, 32, N'Laptop', N'Dell', N'Latitude 7420 Core i7 / 16GB RAM', N'DL-TEST-1792981336666', NULL, '2026-10-26T09:22:16.6775272', N'TB000034');
INSERT INTO dbo.[Devices] ([DeviceId], [CustomerId], [DeviceType], [Brand], [Model], [SerialNumber], [Note], [CreatedAt], [DeviceCode]) VALUES (36, 33, N'Laptop', N'Apple', N'MacBook Pro 16 M3 Max 64GB / 1TB Space Black', N'C02G0011MD6R', N'Máy render đồ họa cao cấp', '2026-10-28T21:43:05.3900000', N'TB000035');
INSERT INTO dbo.[Devices] ([DeviceId], [CustomerId], [DeviceType], [Brand], [Model], [SerialNumber], [Note], [CreatedAt], [DeviceCode]) VALUES (37, 34, N'Điện thoại', N'Apple', N'iPhone 15 Pro Max 512GB Blue Titanium', N'F2LY9999MD6T', N'Máy chính hãng VN/A nguyên hộp', '2026-10-28T21:43:05.4000000', N'TB000036');
INSERT INTO dbo.[Devices] ([DeviceId], [CustomerId], [DeviceType], [Brand], [Model], [SerialNumber], [Note], [CreatedAt], [DeviceCode]) VALUES (38, 35, N'Laptop', N'Dell', N'XPS 16 9640 Core Ultra 7 155H / 32GB RAM', N'DLXPS-9640-VN02', N'Máy kỹ sư lập trình AI', '2026-10-28T21:43:05.4066667', N'TB000037');
INSERT INTO dbo.[Devices] ([DeviceId], [CustomerId], [DeviceType], [Brand], [Model], [SerialNumber], [Note], [CreatedAt], [DeviceCode]) VALUES (39, 36, N'Điện thoại', N'Samsung', N'Galaxy S24 Ultra 5G 512GB Titanium Gray', N'SS-S24U-990088', N'Máy có tích hợp Galaxy AI', '2026-10-28T21:43:05.4100000', N'TB000038');
INSERT INTO dbo.[Devices] ([DeviceId], [CustomerId], [DeviceType], [Brand], [Model], [SerialNumber], [Note], [CreatedAt], [DeviceCode]) VALUES (40, 37, N'Laptop', N'Lenovo', N'ThinkPad X1 Carbon Gen 11 Core i7-1365U', N'TP-X1C11-0022', N'Máy chuẩn doanh nhân mỏng nhẹ', '2026-10-28T21:43:05.4166667', N'TB000039');
INSERT INTO dbo.[Devices] ([DeviceId], [CustomerId], [DeviceType], [Brand], [Model], [SerialNumber], [Note], [CreatedAt], [DeviceCode]) VALUES (41, 38, N'Máy tính bảng', N'Apple', N'iPad Pro 13 M4 OLED 2024 Nano-texture', N'DMPM4-13-8899', N'Bản kính mờ Nano cao cấp', '2026-10-28T21:43:05.4233333', N'TB000040');
INSERT INTO dbo.[Devices] ([DeviceId], [CustomerId], [DeviceType], [Brand], [Model], [SerialNumber], [Note], [CreatedAt], [DeviceCode]) VALUES (42, 39, N'Máy chơi game', N'Asus', N'ASUS ROG Ally Z1 Extreme 512GB', N'ROG-ALLY-VN01', N'Máy gaming cầm tay', '2026-10-28T21:43:05.4300000', N'TB000041');
INSERT INTO dbo.[Devices] ([DeviceId], [CustomerId], [DeviceType], [Brand], [Model], [SerialNumber], [Note], [CreatedAt], [DeviceCode]) VALUES (43, 40, N'Điện thoại', N'Apple', N'iPhone 14 Plus 128GB Purple', N'F2LX7788MD6R', N'Máy nữ dùng', '2026-10-28T21:43:05.4333333', N'TB000042');
INSERT INTO dbo.[Devices] ([DeviceId], [CustomerId], [DeviceType], [Brand], [Model], [SerialNumber], [Note], [CreatedAt], [DeviceCode]) VALUES (44, 41, N'Máy tính PC', N'Custom PC', N'PC Gaming Core i9-14900K / RTX 4090 24GB', N'PC-CUSTOM-4090', N'Dàn tản nhiệt nước Custom Hard Tube', '2026-10-28T21:43:05.4433333', N'TB000043');
INSERT INTO dbo.[Devices] ([DeviceId], [CustomerId], [DeviceType], [Brand], [Model], [SerialNumber], [Note], [CreatedAt], [DeviceCode]) VALUES (45, 42, N'Laptop', N'Apple', N'MacBook Air 15 M2 2023 Midnight', N'C02H1122MD6T', N'Máy văn phòng mỏng nhẹ', '2026-10-28T21:43:05.4500000', N'TB000044');
INSERT INTO dbo.[Devices] ([DeviceId], [CustomerId], [DeviceType], [Brand], [Model], [SerialNumber], [Note], [CreatedAt], [DeviceCode]) VALUES (49, 46, N'Laptop', N'Lenovo', N'ThinkPad X1 Carbon Gen 10 (Core i7-1260P)', N'LNV-X1C10-VN99', N'Thiết bị doanh nhân kiểm thử màn hình 2.8K', '2026-10-29T12:58:22.1680145', N'DEMO-TEST-TB01');
INSERT INTO dbo.[Devices] ([DeviceId], [CustomerId], [DeviceType], [Brand], [Model], [SerialNumber], [Note], [CreatedAt], [DeviceCode]) VALUES (50, 47, N'Điện thoại', N'Apple', N'iPhone 15 Pro Max 512GB Titan Tự Nhiên', N'APL-15PM-512G-VN', N'Thiết bị kiểm thử thay cụm sạc Type-C', '2026-10-29T12:58:22.1680145', N'DEMO-TEST-TB02');
INSERT INTO dbo.[Devices] ([DeviceId], [CustomerId], [DeviceType], [Brand], [Model], [SerialNumber], [Note], [CreatedAt], [DeviceCode]) VALUES (51, 48, N'Máy tính bảng', N'Samsung', N'Galaxy Tab S9 Ultra 14.6 inch 256GB', N'SSG-S9U-256G-VN', N'Thiết bị kiểm thử màn hình Dynamic AMOLED 2X', '2026-10-29T12:58:22.1680145', N'DEMO-TEST-TB03');
SET IDENTITY_INSERT dbo.[Devices] OFF;
GO

-- ServiceTypes: 10 dong
SET IDENTITY_INSERT dbo.[ServiceTypes] ON;
INSERT INTO dbo.[ServiceTypes] ([ServiceTypeId], [ServiceCode], [ServiceName], [LaborCost], [WarrantyDays], [Description], [IsActive]) VALUES (1, N'DV001', N'Thay màn hình điện thoại OLED / Super Retina', 150000.00, 90, N'Tháo ráp, ép ron chống nước, chuyển IC giữ True Tone', 1);
INSERT INTO dbo.[ServiceTypes] ([ServiceTypeId], [ServiceCode], [ServiceName], [LaborCost], [WarrantyDays], [Description], [IsActive]) VALUES (2, N'DV002', N'Thay pin chính hãng điện thoại / máy tính bảng', 100000.00, 180, N'Thay pin dung lượng cao, dán keo seal chuyên dụng', 1);
INSERT INTO dbo.[ServiceTypes] ([ServiceTypeId], [ServiceCode], [ServiceName], [LaborCost], [WarrantyDays], [Description], [IsActive]) VALUES (3, N'DV003', N'Vệ sinh tra keo tản nhiệt gốm máy tính & laptop', 150000.00, 30, N'Vệ sinh quạt kép, tra keo gốm Thermal Grizzly Kryonaut', 1);
INSERT INTO dbo.[ServiceTypes] ([ServiceTypeId], [ServiceCode], [ServiceName], [LaborCost], [WarrantyDays], [Description], [IsActive]) VALUES (4, N'DV004', N'Cài đặt hệ điều hành Windows 11 / macOS & phần mềm', 100000.00, 30, N'Cài đặt OS chuẩn UEFI/GPT, driver đầy đủ và Office', 1);
INSERT INTO dbo.[ServiceTypes] ([ServiceTypeId], [ServiceCode], [ServiceName], [LaborCost], [WarrantyDays], [Description], [IsActive]) VALUES (5, N'DV005', N'Sửa chữa phần cứng mainboard, IC nguồn, reball chip', 450000.00, 90, N'Đo đạc boardview, dò chạm chập bằng camera nhiệt FLIR', 1);
INSERT INTO dbo.[ServiceTypes] ([ServiceTypeId], [ServiceCode], [ServiceName], [LaborCost], [WarrantyDays], [Description], [IsActive]) VALUES (6, N'DV006', N'Nâng cấp ổ cứng SSD NVMe & sao lưu chuyển dữ liệu', 120000.00, 365, N'Lắp đặt SSD M.2 tốc độ cao, clone phân vùng dữ liệu an toàn', 1);
INSERT INTO dbo.[ServiceTypes] ([ServiceTypeId], [ServiceCode], [ServiceName], [LaborCost], [WarrantyDays], [Description], [IsActive]) VALUES (7, N'DV007', N'Thay cụm cáp chân sạc Type-C / Lightning và mic thoại', 150000.00, 90, N'Thay bo cáp chân sạc zin máy, test chuẩn sạc nhanh PD', 1);
INSERT INTO dbo.[ServiceTypes] ([ServiceTypeId], [ServiceCode], [ServiceName], [LaborCost], [WarrantyDays], [Description], [IsActive]) VALUES (8, N'DV008', N'Ép kính màn hình cong / thay mặt kính cảm ứng', 250000.00, 90, N'Cắt kính vỡ bằng máy tách nhiệt, hấp bọt khí chân không', 1);
INSERT INTO dbo.[ServiceTypes] ([ServiceTypeId], [ServiceCode], [ServiceName], [LaborCost], [WarrantyDays], [Description], [IsActive]) VALUES (9, N'DV009', N'Thay bàn phím laptop & bảo dưỡng switch phím', 120000.00, 180, N'Hàn tán đinh rivet bàn phím mới, kiểm tra độ nảy từng phím', 1);
INSERT INTO dbo.[ServiceTypes] ([ServiceTypeId], [ServiceCode], [ServiceName], [LaborCost], [WarrantyDays], [Description], [IsActive]) VALUES (10, N'DV010', N'Cứu phục hồi dữ liệu ổ cứng lỗi bad sector / lỗi mạch', 500000.00, 30, N'Cứu dữ liệu ổ cơ HDD và SSD bằng thiết bị chuyên dụng PC-3000', 1);
SET IDENTITY_INSERT dbo.[ServiceTypes] OFF;
GO

-- Roles: 4 dong
SET IDENTITY_INSERT dbo.[Roles] ON;
INSERT INTO dbo.[Roles] ([RoleId], [RoleCode], [RoleName], [Description], [IsActive], [CreatedAt]) VALUES (1, N'ADMIN', N'Quản trị viên', N'Chủ cửa hàng / Quản lý hệ thống, toàn quyền quản trị', 1, '2026-10-06T13:11:36.7820000');
INSERT INTO dbo.[Roles] ([RoleId], [RoleCode], [RoleName], [Description], [IsActive], [CreatedAt]) VALUES (2, N'STAFF', N'Nhân viên quầy', N'Tiếp nhận thiết bị, lập phiếu tiếp nhận, thu ngân hóa đơn', 1, '2026-10-06T13:11:36.7820000');
INSERT INTO dbo.[Roles] ([RoleId], [RoleCode], [RoleName], [Description], [IsActive], [CreatedAt]) VALUES (3, N'TECHNICIAN', N'Kỹ thuật viên', N'Chẩn đoán, sửa chữa phần cứng/phần mềm, xuất kho linh kiện', 1, '2026-10-06T13:11:36.7820000');
INSERT INTO dbo.[Roles] ([RoleId], [RoleCode], [RoleName], [Description], [IsActive], [CreatedAt]) VALUES (4, N'CUSTOMER', N'Khách hàng', N'Tra cứu tiến độ sửa chữa máy và sổ bảo hành điện tử', 1, '2026-10-06T13:11:36.7820000');
SET IDENTITY_INSERT dbo.[Roles] OFF;
GO

-- Users: 8 dong
SET IDENTITY_INSERT dbo.[Users] ON;
INSERT INTO dbo.[Users] ([UserId], [RoleId], [Username], [PasswordHash], [FullName], [Email], [Phone], [IsActive], [LastLoginAt], [CreatedAt], [UpdatedAt], [CustomerId]) VALUES (1, 1, N'admin', N'$2a$11$V90oo1RvMhNAkWWTBpVhJeC8xuTk8LuCYot8ucD.deZPk6xVm8Vie', N'Nguyễn Viết Lãm (Admin / Quản lý)', N'admin@repairshop.local', N'0900000001', 1, '2026-11-02T08:14:21.9238874', '2026-10-06T13:11:36.7940000', NULL, NULL);
INSERT INTO dbo.[Users] ([UserId], [RoleId], [Username], [PasswordHash], [FullName], [Email], [Phone], [IsActive], [LastLoginAt], [CreatedAt], [UpdatedAt], [CustomerId]) VALUES (2, 2, N'staff01', N'$2a$11$ViOJ7y0BG9Iboq5SAhnpKOov33T2RuJWlrK49F1J9iT1mJR6C8xyS', N'Trần Ngọc Lợi (Trưởng nhóm lễ tân & CSKH)', N'staff01@repairshop.local', N'0900000002', 1, '2026-11-02T08:13:53.7739735', '2026-10-06T13:11:36.7940000', NULL, NULL);
INSERT INTO dbo.[Users] ([UserId], [RoleId], [Username], [PasswordHash], [FullName], [Email], [Phone], [IsActive], [LastLoginAt], [CreatedAt], [UpdatedAt], [CustomerId]) VALUES (3, 3, N'tech01', N'$2a$11$twfvRL1Vt30zJBPeRC6j/.4eSzMQlpUtTgf7TIlisb0U/9tqUTdtO', N'Phạm Văn Kỹ Thuật (Chuyên viên Laptop & PC)', N'tech01@repairshop.local', N'0900000003', 1, '2026-11-02T08:13:53.8966518', '2026-10-06T13:11:36.7940000', NULL, NULL);
INSERT INTO dbo.[Users] ([UserId], [RoleId], [Username], [PasswordHash], [FullName], [Email], [Phone], [IsActive], [LastLoginAt], [CreatedAt], [UpdatedAt], [CustomerId]) VALUES (4, 3, N'tech02', N'$2a$11$i9HeslXM/Q.w615uRRoWTegplzlqOgpSv1/XHdjgD85ZOA/U1ax3e', N'Nguyễn Đại Kỳ (Chuyên viên Mobile & Apple)', N'tech02@repairshop.local', N'0900000004', 1, '2026-10-28T21:20:39.6441050', '2026-10-06T13:11:36.7940000', NULL, NULL);
INSERT INTO dbo.[Users] ([UserId], [RoleId], [Username], [PasswordHash], [FullName], [Email], [Phone], [IsActive], [LastLoginAt], [CreatedAt], [UpdatedAt], [CustomerId]) VALUES (18, 4, N'khach01', N'$2a$11$z4uyALcIBdBtTTT3C9FduO7bng7CCv24uWZ/3TwUi6OVeTesuixQ6', N'Nguyễn Thành Nam (Khách hàng VIP)', N'nam.nguyen@gmail.com', N'0982345678', 1, '2026-11-02T08:13:54.0121459', '2026-10-25T09:05:12.5660000', NULL, 1);
INSERT INTO dbo.[Users] ([UserId], [RoleId], [Username], [PasswordHash], [FullName], [Email], [Phone], [IsActive], [LastLoginAt], [CreatedAt], [UpdatedAt], [CustomerId]) VALUES (19, 4, N'khach02', N'$2a$11$i9HeslXM/Q.w615uRRoWTegplzlqOgpSv1/XHdjgD85ZOA/U1ax3e', N'Lê Hoàng Phúc (Khách hàng)', N'phuc.le@outlook.com', N'0903124567', 1, '2026-10-25T04:05:12.5660000', '2026-10-25T09:05:12.5660000', NULL, 2);
INSERT INTO dbo.[Users] ([UserId], [RoleId], [Username], [PasswordHash], [FullName], [Email], [Phone], [IsActive], [LastLoginAt], [CreatedAt], [UpdatedAt], [CustomerId]) VALUES (20, 4, N'khach03', N'$2a$11$i9HeslXM/Q.w615uRRoWTegplzlqOgpSv1/XHdjgD85ZOA/U1ax3e', N'Đặng Minh Tâm (Khách hàng)', N'tam.dang@fpt.edu.vn', N'0918765432', 1, NULL, '2026-10-25T09:05:12.5660000', NULL, 3);
INSERT INTO dbo.[Users] ([UserId], [RoleId], [Username], [PasswordHash], [FullName], [Email], [Phone], [IsActive], [LastLoginAt], [CreatedAt], [UpdatedAt], [CustomerId]) VALUES (21, 4, N'customer', N'$2a$11$usFrRy.9zcPwa/8mBJMotuWU8BEcGIHC0712.LU8EJrdTRb.cZkiG', N'Khách hàng Demo (Trải nghiệm Portal)', N'customer@example.com', N'0901000003', 1, '2026-11-02T07:58:50.6285882', '2026-10-25T09:05:12.5660000', '2026-10-26T09:22:17.0855389', 1);
SET IDENTITY_INSERT dbo.[Users] OFF;
GO

-- RepairTickets: 60 dong
SET IDENTITY_INSERT dbo.[RepairTickets] ON;
INSERT INTO dbo.[RepairTickets] ([TicketId], [TicketCode], [CustomerId], [DeviceId], [ServiceTypeId], [ReceivedByUserId], [TechnicianUserId], [Status], [DeviceCondition], [CustomerRequest], [Diagnosis], [QuotedLaborCost], [QuotedPartsCost], [IsWarrantyRepair], [OriginalTicketId], [ReceivedAt], [ExpectedFinishAt], [CompletedAt], [DeliveredAt], [CancelReason], [CreatedAt], [UpdatedAt]) VALUES (1, N'PSC202610001', 1, 1, 3, 2, 3, N'COMPLETED', N'Máy chạy khoảng 15 phút quạt kêu to rú rít, nhiệt độ đo CPU 98°C, tự sập nguồn khi render video Premiere.', N'Khách yêu cầu vệ sinh toàn bộ máy và thay loại keo tản nhiệt tốt nhất.', N'Keo tản nhiệt gốc đã bị khô cứng chai cứng, cụm lá nhôm tản nhiệt nghẹt xơ bụi. Đã vệ sinh quạt kép, tẩy keo cũ và tra keo Thermal Grizzly Kryonaut. Stress test Cinebench R23 nhiệt độ ổn định ở 72°C.', 150000.00, 180000.00, 0, NULL, '2026-10-22T09:05:12.5700000', '2026-10-23T09:05:12.5700000', '2026-10-23T09:05:12.5700000', NULL, NULL, '2026-10-22T09:05:12.5700000', NULL);
INSERT INTO dbo.[RepairTickets] ([TicketId], [TicketCode], [CustomerId], [DeviceId], [ServiceTypeId], [ReceivedByUserId], [TechnicianUserId], [Status], [DeviceCondition], [CustomerRequest], [Diagnosis], [QuotedLaborCost], [QuotedPartsCost], [IsWarrantyRepair], [OriginalTicketId], [ReceivedAt], [ExpectedFinishAt], [CompletedAt], [DeliveredAt], [CancelReason], [CreatedAt], [UpdatedAt]) VALUES (2, N'PSC202610002', 2, 2, 1, 2, 4, N'REPAIRING', N'Rơi cấn góc bàn kính nứt mạng nhện, sọc xanh dọc mép phải màn hình, cảm ứng góc dưới bị đơ không phản hồi.', N'Thay màn hình zin chính hãng, cần giữ lại tính năng Face ID và True Tone.', N'Tấm nền OLED bị rạn panel bên trong. Đang tháo ráp thay cụm màn hình Super Retina XDR Zin, chuyển chip IC màn hình để giữ nguyên tính năng True Tone.', 150000.00, 5600000.00, 0, NULL, '2026-10-23T09:05:12.5700000', '2026-10-26T09:05:12.5700000', NULL, NULL, NULL, '2026-10-23T09:05:12.5700000', NULL);
INSERT INTO dbo.[RepairTickets] ([TicketId], [TicketCode], [CustomerId], [DeviceId], [ServiceTypeId], [ReceivedByUserId], [TechnicianUserId], [Status], [DeviceCondition], [CustomerRequest], [Diagnosis], [QuotedLaborCost], [QuotedPartsCost], [IsWarrantyRepair], [OriginalTicketId], [ReceivedAt], [ExpectedFinishAt], [CompletedAt], [DeliveredAt], [CancelReason], [CreatedAt], [UpdatedAt]) VALUES (3, N'PSC202610003', 3, 3, 5, 2, 3, N'DIAGNOSING', N'Cắm sạc MagSafe 3 đèn nhấp nháy cam rồi tắt hẳn, máy hoàn toàn không lên nguồn, pin không nhận dòng sạc.', N'Kiểm tra và cứu dữ liệu đồ án trong máy gấp.', N'Đo chạm chập tụ lọc đường cấp nguồn chính PPBUS_AON 12.6V gần cụm cổng Type-C Thunderbolt. Kỹ thuật viên đang dò nhiệt FLIR và đo đạc boardview cách ly linh kiện ngắn mạch.', 450000.00, 0.00, 0, NULL, '2026-10-24T09:05:12.5700000', '2026-10-27T09:05:12.5700000', NULL, NULL, NULL, '2026-10-24T09:05:12.5700000', NULL);
INSERT INTO dbo.[RepairTickets] ([TicketId], [TicketCode], [CustomerId], [DeviceId], [ServiceTypeId], [ReceivedByUserId], [TechnicianUserId], [Status], [DeviceCondition], [CustomerRequest], [Diagnosis], [QuotedLaborCost], [QuotedPartsCost], [IsWarrantyRepair], [OriginalTicketId], [ReceivedAt], [ExpectedFinishAt], [CompletedAt], [DeliveredAt], [CancelReason], [CreatedAt], [UpdatedAt]) VALUES (4, N'PSC202610004', 4, 4, 2, 2, 4, N'WAITING_CONFIRM', N'Pin bị chai phồng nhẹ đẩy nắp lưng, sạc pin rất nóng, dùng còn 25-30% là sập nguồn khởi động lại.', N'Báo giá pin chính hãng và thời gian thay thế.', N'Pin lithium đạt chu kỳ 860 lần sạc, dung lượng thực tế còn 64% so với ban đầu. Cần thay pin Samsung Zin 5000mAh và dán lại ron chống nước kháng bụi tiêu chuẩn IP68.', 100000.00, 680000.00, 0, NULL, '2026-10-24T09:05:12.5700000', '2026-10-26T09:05:12.5700000', NULL, NULL, NULL, '2026-10-24T09:05:12.5700000', NULL);
INSERT INTO dbo.[RepairTickets] ([TicketId], [TicketCode], [CustomerId], [DeviceId], [ServiceTypeId], [ReceivedByUserId], [TechnicianUserId], [Status], [DeviceCondition], [CustomerRequest], [Diagnosis], [QuotedLaborCost], [QuotedPartsCost], [IsWarrantyRepair], [OriginalTicketId], [ReceivedAt], [ExpectedFinishAt], [CompletedAt], [DeliveredAt], [CancelReason], [CreatedAt], [UpdatedAt]) VALUES (5, N'PSC202610005', 5, 5, 6, 2, 3, N'DELIVERED', N'Khởi động vào Windows rất chậm (mất hơn 4 phút), chơi game giật lag bị đứng màn hình xanh BSOD, ổ HDD cũ kêu lạch cạch.', N'Nâng cấp SSD NVMe tốc độ cao 1TB, chuyển toàn bộ dữ liệu game và Windows cũ sang.', N'Ổ HDD cũ bị bad sector nặng phân vùng C. Đã sao lưu dữ liệu phân vùng D, lắp mới SSD Samsung 980 PRO 1TB NVMe Gen 4, cài Windows 11 Pro 64-bit tối ưu hóa cho gaming.', 120000.00, 2250000.00, 0, NULL, '2026-10-20T09:05:12.5700000', '2026-10-21T09:05:12.5700000', '2026-10-21T09:05:12.5700000', '2026-10-21T09:05:12.5700000', NULL, '2026-10-20T09:05:12.5700000', NULL);
INSERT INTO dbo.[RepairTickets] ([TicketId], [TicketCode], [CustomerId], [DeviceId], [ServiceTypeId], [ReceivedByUserId], [TechnicianUserId], [Status], [DeviceCondition], [CustomerRequest], [Diagnosis], [QuotedLaborCost], [QuotedPartsCost], [IsWarrantyRepair], [OriginalTicketId], [ReceivedAt], [ExpectedFinishAt], [CompletedAt], [DeliveredAt], [CancelReason], [CreatedAt], [UpdatedAt]) VALUES (6, N'PSC202610006', 6, 6, 3, 2, NULL, N'RECEIVED', N'Quạt tản nhiệt bên GPU phát ra tiếng kêu cọc cọc rít gió lớn, máy chơi game bị tụt xung nhịp fps (thermal throttling).', N'Khách mang máy đến gửi tại quầy, yêu cầu kiểm tra và thay quạt zin êm ái.', NULL, 150000.00, 490000.00, 0, NULL, '2026-10-25T09:05:12.5700000', '2026-10-27T09:05:12.5700000', NULL, NULL, NULL, '2026-10-25T09:05:12.5700000', NULL);
INSERT INTO dbo.[RepairTickets] ([TicketId], [TicketCode], [CustomerId], [DeviceId], [ServiceTypeId], [ReceivedByUserId], [TechnicianUserId], [Status], [DeviceCondition], [CustomerRequest], [Diagnosis], [QuotedLaborCost], [QuotedPartsCost], [IsWarrantyRepair], [OriginalTicketId], [ReceivedAt], [ExpectedFinishAt], [CompletedAt], [DeliveredAt], [CancelReason], [CreatedAt], [UpdatedAt]) VALUES (7, N'PSC202610007', 7, 7, 7, 2, 4, N'DELIVERED', N'Cổng sạc Type-C bị gãy chân pin tiếp xúc bên trong do cắm giật mạnh cáp sạc, máy không nhận sạc và không kết nối được máy tính Mac.', N'Thay cụm sạc Type-C zin máy, giữ micro thu âm gốc.', N'Cổng sạc Type-C rách bo cáp flex. Đã thay cụm cáp sạc Type-C mới, test sạc nhanh PD 30W và truyền dữ liệu iTunes 100% bình thường.', 150000.00, 620000.00, 0, NULL, '2026-10-21T09:05:12.5700000', '2026-10-22T09:05:12.5700000', '2026-10-22T09:05:12.5700000', '2026-10-22T09:05:12.5700000', NULL, '2026-10-21T09:05:12.5700000', NULL);
INSERT INTO dbo.[RepairTickets] ([TicketId], [TicketCode], [CustomerId], [DeviceId], [ServiceTypeId], [ReceivedByUserId], [TechnicianUserId], [Status], [DeviceCondition], [CustomerRequest], [Diagnosis], [QuotedLaborCost], [QuotedPartsCost], [IsWarrantyRepair], [OriginalTicketId], [ReceivedAt], [ExpectedFinishAt], [CompletedAt], [DeliveredAt], [CancelReason], [CreatedAt], [UpdatedAt]) VALUES (8, N'PSC202610008', 8, 8, 9, 2, 3, N'RECEIVED', N'Bị đổ nước ngọt lên cụm phím, một hàng phím ASDFG và phím Space bị dính kẹt cứng, chập tự động gõ liên tục chữ D.', N'Thay bàn phím ThinkPad chính hãng có đèn led nền.', N'Tiếp nhận tại quầy, tháo pin khẩn cấp chống chập mạch main, cần thay cụm bàn phím ThinkPad Led US mới.', 120000.00, 950000.00, 0, NULL, '2026-10-25T09:05:12.5700000', '2026-10-26T09:05:12.5700000', NULL, NULL, NULL, '2026-10-25T09:05:12.5700000', NULL);
INSERT INTO dbo.[RepairTickets] ([TicketId], [TicketCode], [CustomerId], [DeviceId], [ServiceTypeId], [ReceivedByUserId], [TechnicianUserId], [Status], [DeviceCondition], [CustomerRequest], [Diagnosis], [QuotedLaborCost], [QuotedPartsCost], [IsWarrantyRepair], [OriginalTicketId], [ReceivedAt], [ExpectedFinishAt], [CompletedAt], [DeliveredAt], [CancelReason], [CreatedAt], [UpdatedAt]) VALUES (9, N'PSC202610009', 9, 9, 2, 2, 4, N'DELIVERED', N'Báo pin bảo trì trong Cài đặt (Dung lượng tối đa 71%), dùng nửa ngày là hết pin.', N'Thay pin Pisen chính hãng bảo hành dài hạn.', N'Đã thay pin Pisen dung lượng cao chính hãng, test chu kỳ sạc 100%, sạc đầy ngắt sạc tự động tốt.', 100000.00, 750000.00, 0, NULL, '2026-10-23T09:05:12.5700000', '2026-10-23T09:05:12.5700000', '2026-10-23T09:05:12.5700000', '2026-10-23T09:05:12.5700000', NULL, '2026-10-23T09:05:12.5700000', NULL);
INSERT INTO dbo.[RepairTickets] ([TicketId], [TicketCode], [CustomerId], [DeviceId], [ServiceTypeId], [ReceivedByUserId], [TechnicianUserId], [Status], [DeviceCondition], [CustomerRequest], [Diagnosis], [QuotedLaborCost], [QuotedPartsCost], [IsWarrantyRepair], [OriginalTicketId], [ReceivedAt], [ExpectedFinishAt], [CompletedAt], [DeliveredAt], [CancelReason], [CreatedAt], [UpdatedAt]) VALUES (10, N'PSC202610010', 10, 10, 4, 2, 3, N'DELIVERED', N'Máy chạy đơ chậm, mở 10 tab Chrome và Photoshop bị tràn RAM báo lỗi Out of Memory.', N'Nâng cấp RAM và vệ sinh thổi bụi.', N'Nâng cấp thanh RAM 16GB Kingston DDR4 3200MHz, máy nhận đủ RAM chạy mượt mà đa nhiệm.', 100000.00, 890000.00, 0, NULL, '2026-10-24T09:05:12.5700000', '2026-10-24T09:05:12.5700000', '2026-10-24T09:05:12.5700000', '2026-10-24T09:05:12.5700000', NULL, '2026-10-24T09:05:12.5700000', NULL);
INSERT INTO dbo.[RepairTickets] ([TicketId], [TicketCode], [CustomerId], [DeviceId], [ServiceTypeId], [ReceivedByUserId], [TechnicianUserId], [Status], [DeviceCondition], [CustomerRequest], [Diagnosis], [QuotedLaborCost], [QuotedPartsCost], [IsWarrantyRepair], [OriginalTicketId], [ReceivedAt], [ExpectedFinishAt], [CompletedAt], [DeliveredAt], [CancelReason], [CreatedAt], [UpdatedAt]) VALUES (11, N'PSC202610011', 11, 11, 8, 2, 4, N'WAITING_CONFIRM', N'Máy bị rơi nứt mạng nhện góc trên kính bảo vệ, hiển thị và cảm ứng đa điểm vẫn mượt mà không bị kẻ sọc.', N'Ép kính zin giữ nguyên màn hình gốc Dynamic Island.', N'Kính ngoài rạn vỡ, phôi màn hình OLED và cảm ứng 120Hz hoàn toàn bình thường. Đã tư vấn khách phương án ép kính chân không công nghệ OCA chống bọt.', 250000.00, 450000.00, 0, NULL, '2026-10-24T10:01:02.7100000', '2026-10-26T10:01:02.7100000', NULL, NULL, NULL, '2026-10-24T10:01:02.7100000', NULL);
INSERT INTO dbo.[RepairTickets] ([TicketId], [TicketCode], [CustomerId], [DeviceId], [ServiceTypeId], [ReceivedByUserId], [TechnicianUserId], [Status], [DeviceCondition], [CustomerRequest], [Diagnosis], [QuotedLaborCost], [QuotedPartsCost], [IsWarrantyRepair], [OriginalTicketId], [ReceivedAt], [ExpectedFinishAt], [CompletedAt], [DeliveredAt], [CancelReason], [CreatedAt], [UpdatedAt]) VALUES (12, N'PSC202610012', 12, 12, 2, 2, 3, N'REPAIRING', N'Pin báo Service Recommended, chu kỳ sạc 950 lần, dùng văn phòng chỉ được hơn 1.5 tiếng là báo pin yếu.', N'Thay pin chính hãng và vệ sinh bo mạch.', N'Pin bị phù nhẹ khoang giữa. Kỹ thuật viên đang tháo ráp thay cell pin mới, dán keo seal chống rung và căn chỉnh mạch BMS.', 100000.00, 1250000.00, 0, NULL, '2026-10-24T10:01:02.7100000', '2026-10-26T10:01:02.7100000', NULL, NULL, NULL, '2026-10-24T10:01:02.7100000', NULL);
INSERT INTO dbo.[RepairTickets] ([TicketId], [TicketCode], [CustomerId], [DeviceId], [ServiceTypeId], [ReceivedByUserId], [TechnicianUserId], [Status], [DeviceCondition], [CustomerRequest], [Diagnosis], [QuotedLaborCost], [QuotedPartsCost], [IsWarrantyRepair], [OriginalTicketId], [ReceivedAt], [ExpectedFinishAt], [CompletedAt], [DeliveredAt], [CancelReason], [CreatedAt], [UpdatedAt]) VALUES (13, N'PSC202610013', 13, 13, 3, 2, 3, N'COMPLETED', N'Nhiệt độ GPU lên 89°C khi chơi CS2, máy tự hạ xung nhịp gây giật lag tụt FPS.', N'Vệ sinh toàn bộ quạt và tra keo gốm loại xịn nhất.', N'Hệ thống tản nhiệt bám dày sợi bông bụi. Đã vệ sinh quạt kép, tra keo gốm Kryonaut, nhiệt độ GPU giảm sâu còn 74°C khi tải 100%.', 150000.00, 180000.00, 0, NULL, '2026-10-23T10:01:02.7100000', '2026-10-24T10:01:02.7100000', '2026-10-24T10:01:02.7100000', NULL, NULL, '2026-10-23T10:01:02.7100000', NULL);
INSERT INTO dbo.[RepairTickets] ([TicketId], [TicketCode], [CustomerId], [DeviceId], [ServiceTypeId], [ReceivedByUserId], [TechnicianUserId], [Status], [DeviceCondition], [CustomerRequest], [Diagnosis], [QuotedLaborCost], [QuotedPartsCost], [IsWarrantyRepair], [OriginalTicketId], [ReceivedAt], [ExpectedFinishAt], [CompletedAt], [DeliveredAt], [CancelReason], [CreatedAt], [UpdatedAt]) VALUES (14, N'PSC202610014', 14, 14, 1, 2, 4, N'DELIVERED', N'Rơi rớt nước ngấm viền dưới, màn hình đen thui chớp nháy sọc trắng, máy vẫn đổ chuông cuộc gọi đến.', N'Thay màn hình chất lượng cao, giữ Face ID.', N'Chập panel cáp tín hiệu MIPI. Đã thay thế màn hình OLED Super Retina, sang IC gốc giữ True Tone, test cảm ứng và Face ID hoạt động hoàn hảo.', 150000.00, 3200000.00, 0, NULL, '2026-10-21T10:01:02.7100000', '2026-10-22T10:01:02.7100000', '2026-10-22T10:01:02.7100000', '2026-10-22T10:01:02.7100000', NULL, '2026-10-21T10:01:02.7100000', NULL);
INSERT INTO dbo.[RepairTickets] ([TicketId], [TicketCode], [CustomerId], [DeviceId], [ServiceTypeId], [ReceivedByUserId], [TechnicianUserId], [Status], [DeviceCondition], [CustomerRequest], [Diagnosis], [QuotedLaborCost], [QuotedPartsCost], [IsWarrantyRepair], [OriginalTicketId], [ReceivedAt], [ExpectedFinishAt], [CompletedAt], [DeliveredAt], [CancelReason], [CreatedAt], [UpdatedAt]) VALUES (15, N'PSC202610015', 15, 15, 6, 2, 3, N'COMPLETED', N'Ổ cứng SSD cũ chỉ có 256GB bị đầy dung lượng, render video Premiere báo disk full không xuất file được.', N'Lắp thêm SSD NVMe 1TB Samsung 980 PRO Gen 4 tốc độ cao để làm ổ cache đồ họa.', N'Đã lắp đặt SSD Samsung 980 PRO 1TB vào khe M.2 PCIe 4.0 trên mainboard ASUS Z790, định dạng NTFS, benchmark tốc độ đọc đạt 6950 MB/s.', 120000.00, 2250000.00, 0, NULL, '2026-10-24T10:01:02.7100000', '2026-10-25T10:01:02.7100000', '2026-10-25T10:01:02.7100000', NULL, NULL, '2026-10-24T10:01:02.7100000', NULL);
INSERT INTO dbo.[RepairTickets] ([TicketId], [TicketCode], [CustomerId], [DeviceId], [ServiceTypeId], [ReceivedByUserId], [TechnicianUserId], [Status], [DeviceCondition], [CustomerRequest], [Diagnosis], [QuotedLaborCost], [QuotedPartsCost], [IsWarrantyRepair], [OriginalTicketId], [ReceivedAt], [ExpectedFinishAt], [CompletedAt], [DeliveredAt], [CancelReason], [CreatedAt], [UpdatedAt]) VALUES (16, N'PSC202610016', 16, 16, 4, 2, 3, N'DELIVERED', N'Máy bị nhiễm virus mã độc quảng cáo, mở trình duyệt tự nhảy tab lừa đảo, máy khởi động mất 3 phút.', N'Format sạch sẽ cài lại Windows 11 Pro 64-bit và Office bản quyền.', N'Đã sao lưu thư mục tài liệu Desktop/Documents, phân vùng lại ổ cứng GPT, cài đặt Windows 11 Pro sạch, kích hoạt bảo mật BitLocker.', 100000.00, 0.00, 0, NULL, '2026-10-22T10:01:02.7100000', '2026-10-23T10:01:02.7100000', '2026-10-23T10:01:02.7100000', '2026-10-23T10:01:02.7100000', NULL, '2026-10-22T10:01:02.7100000', NULL);
INSERT INTO dbo.[RepairTickets] ([TicketId], [TicketCode], [CustomerId], [DeviceId], [ServiceTypeId], [ReceivedByUserId], [TechnicianUserId], [Status], [DeviceCondition], [CustomerRequest], [Diagnosis], [QuotedLaborCost], [QuotedPartsCost], [IsWarrantyRepair], [OriginalTicketId], [ReceivedAt], [ExpectedFinishAt], [CompletedAt], [DeliveredAt], [CancelReason], [CreatedAt], [UpdatedAt]) VALUES (17, N'PSC202610017', 17, 17, 5, 2, 4, N'DIAGNOSING', N'Mở gập máy ra thì màn hình trong chớp tắt mất hiển thị, gập lại dùng màn hình ngoài thì bình thường.', N'Kiểm tra cáp flex bản lề và báo giá trước khi làm.', N'Đứt ngầm đường tín hiệu cáp flex nối giữa 2 nửa thân máy qua trục bản lề. Kỹ thuật viên đang kiểm tra mức độ tổn thương bo mạch phụ.', 450000.00, 0.00, 0, NULL, '2026-10-25T10:01:02.7100000', '2026-10-27T10:01:02.7100000', NULL, NULL, NULL, '2026-10-25T10:01:02.7100000', NULL);
INSERT INTO dbo.[RepairTickets] ([TicketId], [TicketCode], [CustomerId], [DeviceId], [ServiceTypeId], [ReceivedByUserId], [TechnicianUserId], [Status], [DeviceCondition], [CustomerRequest], [Diagnosis], [QuotedLaborCost], [QuotedPartsCost], [IsWarrantyRepair], [OriginalTicketId], [ReceivedAt], [ExpectedFinishAt], [CompletedAt], [DeliveredAt], [CancelReason], [CreatedAt], [UpdatedAt]) VALUES (18, N'PSC202610018', 18, 18, 7, 2, NULL, N'RECEIVED', N'Cắm sạc qua đêm bị quẹt chân làm gãy chấu đồng bên trong cổng Type-C, hiện không nhận sạc.', N'Tiếp nhận kiểm tra thay bo cổng sạc zin.', NULL, 150000.00, 620000.00, 0, NULL, '2026-10-25T10:01:02.7100000', '2026-10-26T10:01:02.7100000', NULL, NULL, NULL, '2026-10-25T10:01:02.7100000', NULL);
INSERT INTO dbo.[RepairTickets] ([TicketId], [TicketCode], [CustomerId], [DeviceId], [ServiceTypeId], [ReceivedByUserId], [TechnicianUserId], [Status], [DeviceCondition], [CustomerRequest], [Diagnosis], [QuotedLaborCost], [QuotedPartsCost], [IsWarrantyRepair], [OriginalTicketId], [ReceivedAt], [ExpectedFinishAt], [CompletedAt], [DeliveredAt], [CancelReason], [CreatedAt], [UpdatedAt]) VALUES (19, N'PSC202610019', 19, 19, 9, 2, 3, N'COMPLETED', N'Bị đổ nước ngọt dính phím Enter và hàng số, gõ một phím nhảy ra nhiều ký tự lạ.', N'Thay cụm phím mới chính hãng có đèn nền.', N'Đã thay mới cụm bàn phím Dell Inspiron có đèn led nền, tán đinh nhiệt cố định chắc chắn, test toàn bộ 104 phím nảy êm chuẩn xác.', 120000.00, 950000.00, 0, NULL, '2026-10-24T10:01:02.7100000', '2026-10-25T10:01:02.7100000', '2026-10-25T10:01:02.7100000', NULL, NULL, '2026-10-24T10:01:02.7100000', NULL);
INSERT INTO dbo.[RepairTickets] ([TicketId], [TicketCode], [CustomerId], [DeviceId], [ServiceTypeId], [ReceivedByUserId], [TechnicianUserId], [Status], [DeviceCondition], [CustomerRequest], [Diagnosis], [QuotedLaborCost], [QuotedPartsCost], [IsWarrantyRepair], [OriginalTicketId], [ReceivedAt], [ExpectedFinishAt], [CompletedAt], [DeliveredAt], [CancelReason], [CreatedAt], [UpdatedAt]) VALUES (20, N'PSC202610020', 20, 20, 8, 2, 4, N'DELIVERED', N'Bị va chìa khóa nứt mặt kính bảo vệ camera sau, chụp ảnh bị lóa sáng chói viền.', N'Thay mặt kính camera Sapphire chính hãng.', N'Cụm thấu kính bên trong còn nguyên vẹn. Đã bóc lớp kính nứt, hút chân không sạch bụi cảm biến và dán kính Sapphire chống trầy mới.', 150000.00, 280000.00, 0, NULL, '2026-10-23T10:01:02.7100000', '2026-10-24T10:01:02.7100000', '2026-10-24T10:01:02.7100000', '2026-10-24T10:01:02.7100000', NULL, '2026-10-23T10:01:02.7100000', NULL);
INSERT INTO dbo.[RepairTickets] ([TicketId], [TicketCode], [CustomerId], [DeviceId], [ServiceTypeId], [ReceivedByUserId], [TechnicianUserId], [Status], [DeviceCondition], [CustomerRequest], [Diagnosis], [QuotedLaborCost], [QuotedPartsCost], [IsWarrantyRepair], [OriginalTicketId], [ReceivedAt], [ExpectedFinishAt], [CompletedAt], [DeliveredAt], [CancelReason], [CreatedAt], [UpdatedAt]) VALUES (21, N'PSC202610021', 21, 21, 3, 2, 3, N'REPAIRING', N'Dùng render dựng phim 8K quạt hú to liên tục, nhiệt độ bề mặt nhôm kê tay rất nóng.', N'Vệ sinh bảo dưỡng định kỳ buồng hơi tản nhiệt.', N'Bụi mịn bám kín lá tản nhiệt buồng hơi Vapor Chamber. Đang tiến hành vệ sinh siêu âm cánh quạt và thay mỡ tản nhiệt đặc thù cho chip M3 Max.', 150000.00, 180000.00, 0, NULL, '2026-10-25T10:01:02.7100000', '2026-10-26T10:01:02.7100000', NULL, NULL, NULL, '2026-10-25T10:01:02.7100000', NULL);
INSERT INTO dbo.[RepairTickets] ([TicketId], [TicketCode], [CustomerId], [DeviceId], [ServiceTypeId], [ReceivedByUserId], [TechnicianUserId], [Status], [DeviceCondition], [CustomerRequest], [Diagnosis], [QuotedLaborCost], [QuotedPartsCost], [IsWarrantyRepair], [OriginalTicketId], [ReceivedAt], [ExpectedFinishAt], [CompletedAt], [DeliveredAt], [CancelReason], [CreatedAt], [UpdatedAt]) VALUES (22, N'PSC202610022', 22, 22, 10, 2, 3, N'DIAGNOSING', N'Máy bị rơi từ trên bàn làm việc xuống đất, bật nguồn đèn báo chớp rồi vào thẳng BIOS không nhận ổ cứng.', N'Cứu toàn bộ dữ liệu đồ án tốt nghiệp trong ổ cứng.', N'Ổ cứng SSD NVMe chập tụ nguồn bảo vệ cổng M.2, kỹ thuật viên đang câu dây bypass đường 3.3V để đọc chip nhớ NAND flash.', 500000.00, 0.00, 0, NULL, '2026-10-25T10:01:02.7100000', '2026-10-27T10:01:02.7100000', NULL, NULL, NULL, '2026-10-25T10:01:02.7100000', NULL);
INSERT INTO dbo.[RepairTickets] ([TicketId], [TicketCode], [CustomerId], [DeviceId], [ServiceTypeId], [ReceivedByUserId], [TechnicianUserId], [Status], [DeviceCondition], [CustomerRequest], [Diagnosis], [QuotedLaborCost], [QuotedPartsCost], [IsWarrantyRepair], [OriginalTicketId], [ReceivedAt], [ExpectedFinishAt], [CompletedAt], [DeliveredAt], [CancelReason], [CreatedAt], [UpdatedAt]) VALUES (23, N'PSC202610023', 23, 23, 2, 2, 4, N'DELIVERED', N'Pin chai 68%, sạc đầy dùng được khoảng 2 tiếng là hết, máy hay bị ấm vùng pin.', N'Thay pin Pisen chính hãng bảo hành dài hạn.', N'Đã thay pin Pisen dung lượng cao 3110mAh, kích pin chuẩn chu kỳ 0 lần, kiểm tra sạc xả ổn định.', 100000.00, 580000.00, 0, NULL, '2026-10-22T10:01:02.7100000', '2026-10-23T10:01:02.7100000', '2026-10-23T10:01:02.7100000', '2026-10-23T10:01:02.7100000', NULL, '2026-10-22T10:01:02.7100000', NULL);
INSERT INTO dbo.[RepairTickets] ([TicketId], [TicketCode], [CustomerId], [DeviceId], [ServiceTypeId], [ReceivedByUserId], [TechnicianUserId], [Status], [DeviceCondition], [CustomerRequest], [Diagnosis], [QuotedLaborCost], [QuotedPartsCost], [IsWarrantyRepair], [OriginalTicketId], [ReceivedAt], [ExpectedFinishAt], [CompletedAt], [DeliveredAt], [CancelReason], [CreatedAt], [UpdatedAt]) VALUES (24, N'PSC202610024', 24, 24, 6, 2, 3, N'DELIVERED', N'Khởi động vào Windows mất gần 5 phút, mở file Excel báo not responding do ổ HDD cũ quay 5400rpm.', N'Thay thế bằng SSD Kingston NV2 512GB tốc độ cao.', N'Đã sao chép toàn bộ dữ liệu người dùng, lắp SSD Kingston NV2 PCIe 4.0, khởi động máy chỉ mất 8 giây.', 120000.00, 950000.00, 0, NULL, '2026-10-23T10:01:02.7100000', '2026-10-24T10:01:02.7100000', '2026-10-24T10:01:02.7100000', '2026-10-24T10:01:02.7100000', NULL, '2026-10-23T10:01:02.7100000', NULL);
INSERT INTO dbo.[RepairTickets] ([TicketId], [TicketCode], [CustomerId], [DeviceId], [ServiceTypeId], [ReceivedByUserId], [TechnicianUserId], [Status], [DeviceCondition], [CustomerRequest], [Diagnosis], [QuotedLaborCost], [QuotedPartsCost], [IsWarrantyRepair], [OriginalTicketId], [ReceivedAt], [ExpectedFinishAt], [CompletedAt], [DeliveredAt], [CancelReason], [CreatedAt], [UpdatedAt]) VALUES (25, N'PSC202610025', 25, 25, 5, 2, 3, N'CANCELLED', N'Màn hình iMac tự nhiên tối đen, đèn báo nguồn máy vẫn sáng nhưng không hiển thị gì.', N'Kiểm tra báo giá thay thế linh kiện.', N'Chập cụm driver LED backlight trên tấm nền màn hình 4.5K Retina, cần thay thế cả cụm màn hình hãng chi phí cao.', 450000.00, 7900000.00, 0, NULL, '2026-10-22T10:01:02.7100000', '2026-10-24T10:01:02.7100000', NULL, NULL, N'Khách không đồng ý thay thế cụm màn hình do chi phí linh kiện chính hãng vượt ngân sách dự kiến.', '2026-10-22T10:01:02.7100000', NULL);
INSERT INTO dbo.[RepairTickets] ([TicketId], [TicketCode], [CustomerId], [DeviceId], [ServiceTypeId], [ReceivedByUserId], [TechnicianUserId], [Status], [DeviceCondition], [CustomerRequest], [Diagnosis], [QuotedLaborCost], [QuotedPartsCost], [IsWarrantyRepair], [OriginalTicketId], [ReceivedAt], [ExpectedFinishAt], [CompletedAt], [DeliveredAt], [CancelReason], [CreatedAt], [UpdatedAt]) VALUES (26, N'PSC2026100026', 27, 29, 3, 2, NULL, N'DELIVERED', N'Máy nóng ran, quạt kêu rít, tự sập khi chạy nặng', NULL, N'Quạt tản nhiệt nghẹt xơ bụi, keo tản nhiệt CPU đã khô cứng. Cần vệ sinh quạt kép và tra keo Kryonaut.', 150000.00, 0.00, 0, NULL, '2026-10-25T10:02:44.1400000', NULL, '2026-10-25T10:02:44.3800000', '2026-10-25T10:02:44.5320000', NULL, '2026-10-25T10:02:44.1400000', '2026-10-25T10:02:44.5320000');
INSERT INTO dbo.[RepairTickets] ([TicketId], [TicketCode], [CustomerId], [DeviceId], [ServiceTypeId], [ReceivedByUserId], [TechnicianUserId], [Status], [DeviceCondition], [CustomerRequest], [Diagnosis], [QuotedLaborCost], [QuotedPartsCost], [IsWarrantyRepair], [OriginalTicketId], [ReceivedAt], [ExpectedFinishAt], [CompletedAt], [DeliveredAt], [CancelReason], [CreatedAt], [UpdatedAt]) VALUES (27, N'PSC2026100027', 28, 30, 3, 2, NULL, N'DELIVERED', N'Máy nóng ran, quạt kêu rít, tự sập khi chạy nặng', NULL, N'Quạt tản nhiệt nghẹt xơ bụi, keo tản nhiệt CPU đã khô cứng. Cần vệ sinh quạt kép và tra keo Kryonaut.', 150000.00, 0.00, 0, NULL, '2026-10-25T10:03:58.0840000', NULL, '2026-10-25T10:03:58.4200000', '2026-10-25T10:03:58.6960000', NULL, '2026-10-25T10:03:58.0840000', '2026-10-25T10:03:58.6960000');
INSERT INTO dbo.[RepairTickets] ([TicketId], [TicketCode], [CustomerId], [DeviceId], [ServiceTypeId], [ReceivedByUserId], [TechnicianUserId], [Status], [DeviceCondition], [CustomerRequest], [Diagnosis], [QuotedLaborCost], [QuotedPartsCost], [IsWarrantyRepair], [OriginalTicketId], [ReceivedAt], [ExpectedFinishAt], [CompletedAt], [DeliveredAt], [CancelReason], [CreatedAt], [UpdatedAt]) VALUES (28, N'PSC2026100028', 29, 31, 3, 2, NULL, N'DELIVERED', N'Máy nóng ran, quạt kêu rít, tự sập khi chạy nặng', NULL, N'Quạt tản nhiệt nghẹt xơ bụi, keo tản nhiệt CPU đã khô cứng. Cần vệ sinh quạt kép và tra keo Kryonaut.', 150000.00, 0.00, 0, NULL, '2026-10-25T10:04:37.9950000', NULL, '2026-10-25T10:04:38.0980000', '2026-10-25T10:04:38.1590000', NULL, '2026-10-25T10:04:37.9950000', '2026-10-25T10:04:38.1590000');
INSERT INTO dbo.[RepairTickets] ([TicketId], [TicketCode], [CustomerId], [DeviceId], [ServiceTypeId], [ReceivedByUserId], [TechnicianUserId], [Status], [DeviceCondition], [CustomerRequest], [Diagnosis], [QuotedLaborCost], [QuotedPartsCost], [IsWarrantyRepair], [OriginalTicketId], [ReceivedAt], [ExpectedFinishAt], [CompletedAt], [DeliveredAt], [CancelReason], [CreatedAt], [UpdatedAt]) VALUES (29, N'PSC2026100029', 30, 32, 3, 2, NULL, N'DELIVERED', N'Máy nóng ran, quạt kêu rít, tự sập khi chạy nặng', NULL, N'Quạt tản nhiệt nghẹt xơ bụi, keo tản nhiệt CPU đã khô cứng. Cần vệ sinh quạt kép và tra keo Kryonaut.', 150000.00, 0.00, 0, NULL, '2026-10-26T07:50:08.3964157', NULL, '2026-10-26T07:50:08.7184757', '2026-10-26T07:50:08.8869357', NULL, '2026-10-26T07:50:08.3964166', '2026-10-26T07:50:08.8869348');
INSERT INTO dbo.[RepairTickets] ([TicketId], [TicketCode], [CustomerId], [DeviceId], [ServiceTypeId], [ReceivedByUserId], [TechnicianUserId], [Status], [DeviceCondition], [CustomerRequest], [Diagnosis], [QuotedLaborCost], [QuotedPartsCost], [IsWarrantyRepair], [OriginalTicketId], [ReceivedAt], [ExpectedFinishAt], [CompletedAt], [DeliveredAt], [CancelReason], [CreatedAt], [UpdatedAt]) VALUES (30, N'PSC2026100030', 31, 33, 3, 2, NULL, N'DELIVERED', N'Máy nóng ran, quạt kêu rít, tự sập khi chạy nặng', NULL, N'Quạt tản nhiệt nghẹt xơ bụi, keo tản nhiệt CPU đã khô cứng. Cần vệ sinh quạt kép và tra keo Kryonaut.', 150000.00, 0.00, 0, NULL, '2026-10-26T07:51:27.7738771', NULL, '2026-10-26T07:51:27.8900028', '2026-10-26T07:51:27.9665351', NULL, '2026-10-26T07:51:27.7738781', '2026-10-26T07:51:27.9665342');
INSERT INTO dbo.[RepairTickets] ([TicketId], [TicketCode], [CustomerId], [DeviceId], [ServiceTypeId], [ReceivedByUserId], [TechnicianUserId], [Status], [DeviceCondition], [CustomerRequest], [Diagnosis], [QuotedLaborCost], [QuotedPartsCost], [IsWarrantyRepair], [OriginalTicketId], [ReceivedAt], [ExpectedFinishAt], [CompletedAt], [DeliveredAt], [CancelReason], [CreatedAt], [UpdatedAt]) VALUES (31, N'PSC2026100031', 32, 34, 3, 2, NULL, N'DELIVERED', N'Máy nóng ran, quạt kêu rít, tự sập khi chạy nặng', NULL, N'Quạt tản nhiệt nghẹt xơ bụi, keo tản nhiệt CPU đã khô cứng. Cần vệ sinh quạt kép và tra keo Kryonaut.', 150000.00, 0.00, 0, NULL, '2026-10-26T09:22:16.6978360', NULL, '2026-10-26T09:22:16.8137479', '2026-10-26T09:22:16.8873260', NULL, '2026-10-26T09:22:16.6978361', '2026-10-26T09:22:16.8873256');
INSERT INTO dbo.[RepairTickets] ([TicketId], [TicketCode], [CustomerId], [DeviceId], [ServiceTypeId], [ReceivedByUserId], [TechnicianUserId], [Status], [DeviceCondition], [CustomerRequest], [Diagnosis], [QuotedLaborCost], [QuotedPartsCost], [IsWarrantyRepair], [OriginalTicketId], [ReceivedAt], [ExpectedFinishAt], [CompletedAt], [DeliveredAt], [CancelReason], [CreatedAt], [UpdatedAt]) VALUES (32, N'PSC202610032', 33, 36, 3, 2, 3, N'COMPLETED', N'Máy chạy render 3D Blender bị nóng ran 96°C, quạt bên trái kêu lạch cạch', N'Vệ sinh toàn bộ quạt kép và tra keo gốm tản nhiệt xịn nhất', N'Quạt tản nhiệt bên trái bị khô dầu bó trục cánh. Đã vệ sinh siêu âm và tra keo Kryonaut. Test Cinebench nhiệt độ ổn định ở 74°C.', 150000.00, 180000.00, 0, NULL, '2026-10-26T21:43:05.3917540', '2026-10-29T21:43:05.3917540', '2026-10-28T16:43:05.3917540', NULL, NULL, '2026-10-26T21:43:05.3917540', '2026-10-28T21:43:05.3917540');
INSERT INTO dbo.[RepairTickets] ([TicketId], [TicketCode], [CustomerId], [DeviceId], [ServiceTypeId], [ReceivedByUserId], [TechnicianUserId], [Status], [DeviceCondition], [CustomerRequest], [Diagnosis], [QuotedLaborCost], [QuotedPartsCost], [IsWarrantyRepair], [OriginalTicketId], [ReceivedAt], [ExpectedFinishAt], [CompletedAt], [DeliveredAt], [CancelReason], [CreatedAt], [UpdatedAt]) VALUES (33, N'PSC202610033', 34, 37, 1, 2, 3, N'REPAIRING', N'Rơi cấn góc bàn đá nứt kính màn hình, sọc trắng ngang góc Dynamic Island', N'Thay màn hình chính hãng bóc máy, giữ nguyên Face ID và True Tone', N'Panel OLED bị đứt đường tín hiệu hiển thị. Đang tiến hành sàn IC và thay cụm màn hình OLED Zin.', 200000.00, 6900000.00, 0, NULL, '2026-10-26T21:43:05.4029460', '2026-10-29T21:43:05.4029460', NULL, NULL, NULL, '2026-10-26T21:43:05.4029460', '2026-10-28T21:43:05.4029460');
INSERT INTO dbo.[RepairTickets] ([TicketId], [TicketCode], [CustomerId], [DeviceId], [ServiceTypeId], [ReceivedByUserId], [TechnicianUserId], [Status], [DeviceCondition], [CustomerRequest], [Diagnosis], [QuotedLaborCost], [QuotedPartsCost], [IsWarrantyRepair], [OriginalTicketId], [ReceivedAt], [ExpectedFinishAt], [CompletedAt], [DeliveredAt], [CancelReason], [CreatedAt], [UpdatedAt]) VALUES (34, N'PSC202610034', 35, 38, 4, 2, 3, N'COMPLETED', N'Máy bị tràn bộ nhớ tạm, Windows hay bị màn hình xanh khi biên dịch mô hình PyTorch', N'Cài đặt lại Windows 11 sạch, cài driver CUDA và tối ưu hóa hệ thống', N'Xung đột driver GPU Intel Arc và NVIDIA. Đã cài lại Windows 11 Pro UEFI, cập nhật BIOS bản mới nhất.', 100000.00, 0.00, 0, NULL, '2026-10-26T21:43:05.4089550', '2026-10-29T21:43:05.4089550', '2026-10-28T16:43:05.4089550', NULL, NULL, '2026-10-26T21:43:05.4089550', '2026-10-28T21:43:05.4089550');
INSERT INTO dbo.[RepairTickets] ([TicketId], [TicketCode], [CustomerId], [DeviceId], [ServiceTypeId], [ReceivedByUserId], [TechnicianUserId], [Status], [DeviceCondition], [CustomerRequest], [Diagnosis], [QuotedLaborCost], [QuotedPartsCost], [IsWarrantyRepair], [OriginalTicketId], [ReceivedAt], [ExpectedFinishAt], [CompletedAt], [DeliveredAt], [CancelReason], [CreatedAt], [UpdatedAt]) VALUES (35, N'PSC202610035', 36, 39, 2, 2, 3, N'COMPLETED', N'Pin sạc nhanh 45W không vào dòng, chỉ nhận sạc thường 5W rất chậm', N'Kiểm tra cụm chân sạc Type-C và báo giá', N'Chân tiếp xúc CC1/CC2 đường sạc nhanh PD bị oxi hóa do dính mồ hôi. Đã vệ sinh tiếp điểm và hàn gia cố bo sạc.', 150000.00, 350000.00, 0, NULL, '2026-10-26T21:43:05.4143800', '2026-10-29T21:43:05.4143800', '2026-10-28T16:43:05.4143800', NULL, NULL, '2026-10-26T21:43:05.4143800', '2026-10-28T21:43:05.4143800');
INSERT INTO dbo.[RepairTickets] ([TicketId], [TicketCode], [CustomerId], [DeviceId], [ServiceTypeId], [ReceivedByUserId], [TechnicianUserId], [Status], [DeviceCondition], [CustomerRequest], [Diagnosis], [QuotedLaborCost], [QuotedPartsCost], [IsWarrantyRepair], [OriginalTicketId], [ReceivedAt], [ExpectedFinishAt], [CompletedAt], [DeliveredAt], [CancelReason], [CreatedAt], [UpdatedAt]) VALUES (36, N'PSC202610036', 37, 40, 5, 2, 3, N'DIAGNOSING', N'Bật nguồn quạt quay 3 giây rồi tắt, đèn phím nguồn nháy chu kỳ 3 lần', N'Cứu gấp máy để kịp thuyết trình dự án chiều mai', N'Chập tụ nguồn 3.3V đường cấp cho chip I/O EC. Kỹ thuật viên đang dò nhiệt FLIR và gắp bỏ tụ chạm chập.', 450000.00, 200000.00, 0, NULL, '2026-10-26T21:43:05.4200670', '2026-10-29T21:43:05.4200670', NULL, NULL, NULL, '2026-10-26T21:43:05.4200670', '2026-10-28T21:43:05.4200670');
INSERT INTO dbo.[RepairTickets] ([TicketId], [TicketCode], [CustomerId], [DeviceId], [ServiceTypeId], [ReceivedByUserId], [TechnicianUserId], [Status], [DeviceCondition], [CustomerRequest], [Diagnosis], [QuotedLaborCost], [QuotedPartsCost], [IsWarrantyRepair], [OriginalTicketId], [ReceivedAt], [ExpectedFinishAt], [CompletedAt], [DeliveredAt], [CancelReason], [CreatedAt], [UpdatedAt]) VALUES (37, N'PSC202610037', 38, 41, 8, 2, 3, N'WAITING_CONFIRM', N'Cấn chìa khóa nứt lớp kính ngoài, cảm ứng đa điểm vẫn mượt bình thường', N'Khách yêu cầu ép kính Nano giữ nguyên tấm nền OLED kép Ultra Retina', NULL, 250000.00, 1800000.00, 0, NULL, '2026-10-26T21:43:05.4259620', '2026-10-29T21:43:05.4259620', NULL, NULL, NULL, '2026-10-26T21:43:05.4259620', '2026-10-28T21:43:05.4259620');
INSERT INTO dbo.[RepairTickets] ([TicketId], [TicketCode], [CustomerId], [DeviceId], [ServiceTypeId], [ReceivedByUserId], [TechnicianUserId], [Status], [DeviceCondition], [CustomerRequest], [Diagnosis], [QuotedLaborCost], [QuotedPartsCost], [IsWarrantyRepair], [OriginalTicketId], [ReceivedAt], [ExpectedFinishAt], [CompletedAt], [DeliveredAt], [CancelReason], [CreatedAt], [UpdatedAt]) VALUES (38, N'PSC202610038', 39, 42, 6, 2, 3, N'DELIVERED', N'Nâng cấp ổ SSD M.2 2230 lên 2TB WD Black, clone hệ điều hành Windows 11', N'Khách mang ổ SSD mới đến nhờ nâng cấp và tra keo tản nhiệt', N'Đã gắn SSD 2TB, clone phân vùng recovery, tra keo kim loại lỏng. Khởi động game mượt mà.', 150000.00, 0.00, 0, NULL, '2026-10-26T21:43:05.4314400', '2026-10-29T21:43:05.4314400', '2026-10-28T16:43:05.4314400', '2026-10-28T20:43:05.4314400', NULL, '2026-10-26T21:43:05.4314400', '2026-10-28T21:43:05.4314400');
INSERT INTO dbo.[RepairTickets] ([TicketId], [TicketCode], [CustomerId], [DeviceId], [ServiceTypeId], [ReceivedByUserId], [TechnicianUserId], [Status], [DeviceCondition], [CustomerRequest], [Diagnosis], [QuotedLaborCost], [QuotedPartsCost], [IsWarrantyRepair], [OriginalTicketId], [ReceivedAt], [ExpectedFinishAt], [CompletedAt], [DeliveredAt], [CancelReason], [CreatedAt], [UpdatedAt]) VALUES (39, N'PSC202610039', 40, 43, 2, 2, 3, N'COMPLETED', N'Pin báo dung lượng tối đa còn 73%, sạc đầy dùng nửa ngày là sập nguồn', N'Thay pin Pisen chính hãng dung lượng chuẩn bảo hành 12 tháng', N'Đã thay pin Pisen dung lượng cao, dán keo seal chống nước. Test chu kỳ sạc 100%.', 100000.00, 850000.00, 0, NULL, '2026-10-26T21:43:05.4401310', '2026-10-29T21:43:05.4401310', '2026-10-28T16:43:05.4401310', NULL, NULL, '2026-10-26T21:43:05.4401310', '2026-10-28T21:43:05.4401310');
INSERT INTO dbo.[RepairTickets] ([TicketId], [TicketCode], [CustomerId], [DeviceId], [ServiceTypeId], [ReceivedByUserId], [TechnicianUserId], [Status], [DeviceCondition], [CustomerRequest], [Diagnosis], [QuotedLaborCost], [QuotedPartsCost], [IsWarrantyRepair], [OriginalTicketId], [ReceivedAt], [ExpectedFinishAt], [CompletedAt], [DeliveredAt], [CancelReason], [CreatedAt], [UpdatedAt]) VALUES (40, N'PSC202610040', 41, 44, 3, 2, 3, N'DELIVERED', N'Nước tản nhiệt bị đục đổi màu sau 1 năm sử dụng, nhiệt độ CPU lên 90°C', N'Súc rửa toàn bộ block nước, thay dung dịch làm mát mới và tra keo', N'Đã súc rửa rad 360, thay nước làm mát chuyên dụng EKWB CryoFuel, tra keo Kryonaut Extreme. Stress test FurMark nhiệt độ 62°C.', 350000.00, 450000.00, 0, NULL, '2026-10-26T21:43:05.4459410', '2026-10-29T21:43:05.4459410', '2026-10-28T16:43:05.4459410', '2026-10-28T20:43:05.4459410', NULL, '2026-10-26T21:43:05.4459410', '2026-10-28T21:43:05.4459410');
INSERT INTO dbo.[RepairTickets] ([TicketId], [TicketCode], [CustomerId], [DeviceId], [ServiceTypeId], [ReceivedByUserId], [TechnicianUserId], [Status], [DeviceCondition], [CustomerRequest], [Diagnosis], [QuotedLaborCost], [QuotedPartsCost], [IsWarrantyRepair], [OriginalTicketId], [ReceivedAt], [ExpectedFinishAt], [CompletedAt], [DeliveredAt], [CancelReason], [CreatedAt], [UpdatedAt]) VALUES (41, N'PSC202610041', 42, 45, 3, 2, 3, N'RECEIVED', N'Bụi bám nghẹt khe hút gió đáy máy, máy nóng khi mở nhiều tab Figma', N'Tiếp nhận kiểm tra vệ sinh tổng quát', NULL, 150000.00, 0.00, 0, NULL, '2026-10-26T21:43:05.4515660', '2026-10-29T21:43:05.4515660', NULL, NULL, NULL, '2026-10-26T21:43:05.4515660', '2026-10-28T21:43:05.4515660');
INSERT INTO dbo.[RepairTickets] ([TicketId], [TicketCode], [CustomerId], [DeviceId], [ServiceTypeId], [ReceivedByUserId], [TechnicianUserId], [Status], [DeviceCondition], [CustomerRequest], [Diagnosis], [QuotedLaborCost], [QuotedPartsCost], [IsWarrantyRepair], [OriginalTicketId], [ReceivedAt], [ExpectedFinishAt], [CompletedAt], [DeliveredAt], [CancelReason], [CreatedAt], [UpdatedAt]) VALUES (50, N'DEMO-TEST-PSC01', 46, 49, 1, 2, 3, N'RECEIVED', N'Phiếu sửa chữa đang chờ linh kiện', N'Khách báo máy sạc không vào điện, cổng USB-C lỏng', N'Chờ kiểm tra cáp nguồn sạc', 150000.00, 0.00, 0, NULL, '2026-10-29T12:58:57.6032225', NULL, NULL, NULL, NULL, '2026-10-29T12:58:57.6032225', '2026-10-29T12:58:57.6032225');
INSERT INTO dbo.[RepairTickets] ([TicketId], [TicketCode], [CustomerId], [DeviceId], [ServiceTypeId], [ReceivedByUserId], [TechnicianUserId], [Status], [DeviceCondition], [CustomerRequest], [Diagnosis], [QuotedLaborCost], [QuotedPartsCost], [IsWarrantyRepair], [OriginalTicketId], [ReceivedAt], [ExpectedFinishAt], [CompletedAt], [DeliveredAt], [CancelReason], [CreatedAt], [UpdatedAt]) VALUES (51, N'DEMO-TEST-PSC02', 46, 49, 10, 2, 3, N'DIAGNOSING', N'Đăng nhập – Quản lý thiết bị', N'Bàn phím gõ kẹt phím cách Spacebar và phím Shift', N'Bụi lọt vào cơ chế xương bướm, cần vệ sinh mạch phím', 120000.00, 0.00, 0, NULL, '2026-10-29T12:58:57.6032225', NULL, NULL, NULL, NULL, '2026-10-29T12:58:57.6032225', '2026-10-29T12:58:57.6032225');
INSERT INTO dbo.[RepairTickets] ([TicketId], [TicketCode], [CustomerId], [DeviceId], [ServiceTypeId], [ReceivedByUserId], [TechnicianUserId], [Status], [DeviceCondition], [CustomerRequest], [Diagnosis], [QuotedLaborCost], [QuotedPartsCost], [IsWarrantyRepair], [OriginalTicketId], [ReceivedAt], [ExpectedFinishAt], [CompletedAt], [DeliveredAt], [CancelReason], [CreatedAt], [UpdatedAt]) VALUES (52, N'DEMO-TEST-PSC03', 47, 50, 1, 2, 3, N'WAITING_CONFIRM', N'Màn hình xuất hiện sọc xanh dọc sau va đập', N'Khách muốn báo giá thay màn hình chính hãng', N'Màn hình vỡ hiển thị OLED trong, chi phí thay cụm zin', 200000.00, 3500000.00, 0, NULL, '2026-10-29T12:58:57.6032225', NULL, NULL, NULL, NULL, '2026-10-29T12:58:57.6032225', '2026-10-29T12:58:57.6032225');
INSERT INTO dbo.[RepairTickets] ([TicketId], [TicketCode], [CustomerId], [DeviceId], [ServiceTypeId], [ReceivedByUserId], [TechnicianUserId], [Status], [DeviceCondition], [CustomerRequest], [Diagnosis], [QuotedLaborCost], [QuotedPartsCost], [IsWarrantyRepair], [OriginalTicketId], [ReceivedAt], [ExpectedFinishAt], [CompletedAt], [DeliveredAt], [CancelReason], [CreatedAt], [UpdatedAt]) VALUES (53, N'DEMO-TEST-PSC04', 47, 50, 10, 2, 3, N'REPAIRING', N'Máy nóng nhanh, pin tụt từ 100% xuống 20% trong 2 giờ', N'Yêu cầu thay pin dung lượng cao', N'Pin chai 71%, đang tháo seal pin và gắn pin Pisen zin', 100000.00, 850000.00, 0, NULL, '2026-10-29T12:58:57.6032225', NULL, NULL, NULL, NULL, '2026-10-29T12:58:57.6032225', '2026-10-29T12:58:57.6032225');
INSERT INTO dbo.[RepairTickets] ([TicketId], [TicketCode], [CustomerId], [DeviceId], [ServiceTypeId], [ReceivedByUserId], [TechnicianUserId], [Status], [DeviceCondition], [CustomerRequest], [Diagnosis], [QuotedLaborCost], [QuotedPartsCost], [IsWarrantyRepair], [OriginalTicketId], [ReceivedAt], [ExpectedFinishAt], [CompletedAt], [DeliveredAt], [CancelReason], [CreatedAt], [UpdatedAt]) VALUES (54, N'DEMO-TEST-PSC05', 48, 51, 1, 2, 3, N'COMPLETED', N'Màn hình nứt kính góc trên, cảm ứng vẫn hoạt động', N'Ép kính giữ lại màn hình hiển thị zin', N'Đã ép kính thủy tinh Gorilla Glass và hút chân không bọt khí', 250000.00, 650000.00, 0, NULL, '2026-10-29T12:58:57.6032225', NULL, NULL, NULL, NULL, '2026-10-29T12:58:57.6032225', '2026-10-29T12:58:57.6032225');
INSERT INTO dbo.[RepairTickets] ([TicketId], [TicketCode], [CustomerId], [DeviceId], [ServiceTypeId], [ReceivedByUserId], [TechnicianUserId], [Status], [DeviceCondition], [CustomerRequest], [Diagnosis], [QuotedLaborCost], [QuotedPartsCost], [IsWarrantyRepair], [OriginalTicketId], [ReceivedAt], [ExpectedFinishAt], [CompletedAt], [DeliveredAt], [CancelReason], [CreatedAt], [UpdatedAt]) VALUES (55, N'DEMO-TEST-PSC06', 48, 51, 10, 2, 3, N'DELIVERED', N'Loa ngoài bị rè khi bật âm lượng trên 70%', N'Thay màng loa hoặc cụm loa ngoài', N'Đã thay cụm loa kép stereo chính hãng, test âm lượng chuẩn', 150000.00, 320000.00, 0, NULL, '2026-10-29T12:58:57.6032225', NULL, NULL, NULL, NULL, '2026-10-29T12:58:57.6032225', '2026-10-29T12:58:57.6032225');
INSERT INTO dbo.[RepairTickets] ([TicketId], [TicketCode], [CustomerId], [DeviceId], [ServiceTypeId], [ReceivedByUserId], [TechnicianUserId], [Status], [DeviceCondition], [CustomerRequest], [Diagnosis], [QuotedLaborCost], [QuotedPartsCost], [IsWarrantyRepair], [OriginalTicketId], [ReceivedAt], [ExpectedFinishAt], [CompletedAt], [DeliveredAt], [CancelReason], [CreatedAt], [UpdatedAt]) VALUES (56, N'DEMO-TEST-PSC07', 46, 49, 1, 2, 3, N'CANCELLED', N'Máy rơi nước biển không lên nguồn', N'Khách yêu cầu kiểm tra cứu dữ liệu ổ cứng', N'Mainboard bị oxy hóa ăn mòn nặng, chi phí vượt dự toán của khách', 0.00, 0.00, 0, NULL, '2026-10-29T12:58:57.6032225', NULL, NULL, NULL, NULL, '2026-10-29T12:58:57.6032225', '2026-10-29T12:58:57.6032225');
INSERT INTO dbo.[RepairTickets] ([TicketId], [TicketCode], [CustomerId], [DeviceId], [ServiceTypeId], [ReceivedByUserId], [TechnicianUserId], [Status], [DeviceCondition], [CustomerRequest], [Diagnosis], [QuotedLaborCost], [QuotedPartsCost], [IsWarrantyRepair], [OriginalTicketId], [ReceivedAt], [ExpectedFinishAt], [CompletedAt], [DeliveredAt], [CancelReason], [CreatedAt], [UpdatedAt]) VALUES (57, N'DEMO-TEST-PSC08', 47, 50, 10, 2, 3, N'DELIVERED', N'Nắp lưng kính sau bị nứt vỡ nhiều đường', N'Thay nắp lưng màu Titan Tự Nhiên nguyên bản', N'Đã thay nắp lưng kính laser, quét keo chống nước chuẩn hãng', 150000.00, 480000.00, 0, NULL, '2026-10-29T12:58:57.6032225', NULL, NULL, NULL, NULL, '2026-10-29T12:58:57.6032225', '2026-10-29T12:58:57.6032225');
INSERT INTO dbo.[RepairTickets] ([TicketId], [TicketCode], [CustomerId], [DeviceId], [ServiceTypeId], [ReceivedByUserId], [TechnicianUserId], [Status], [DeviceCondition], [CustomerRequest], [Diagnosis], [QuotedLaborCost], [QuotedPartsCost], [IsWarrantyRepair], [OriginalTicketId], [ReceivedAt], [ExpectedFinishAt], [CompletedAt], [DeliveredAt], [CancelReason], [CreatedAt], [UpdatedAt]) VALUES (58, N'DEMO-TEST-PSC09', 48, 51, 1, 2, 3, N'RECEIVED', N'Bút cảm ứng S-Pen không nhận sạc nam châm', N'Kiểm tra mạch sạc cảm ứng từ tính mặt lưng', N'Chờ đo điện áp cuộn cảm sạc không dây', 100000.00, 0.00, 0, NULL, '2026-10-29T12:58:57.6032225', NULL, NULL, NULL, NULL, '2026-10-29T12:58:57.6032225', '2026-10-29T12:58:57.6032225');
INSERT INTO dbo.[RepairTickets] ([TicketId], [TicketCode], [CustomerId], [DeviceId], [ServiceTypeId], [ReceivedByUserId], [TechnicianUserId], [Status], [DeviceCondition], [CustomerRequest], [Diagnosis], [QuotedLaborCost], [QuotedPartsCost], [IsWarrantyRepair], [OriginalTicketId], [ReceivedAt], [ExpectedFinishAt], [CompletedAt], [DeliveredAt], [CancelReason], [CreatedAt], [UpdatedAt]) VALUES (59, N'DEMO-TEST-PSC10', 46, 49, 10, 2, 3, N'DIAGNOSING', N'Quạt tản nhiệt kêu ù ù ngắt quãng khi tải nặng', N'Kiểm tra trục bi quạt làm mát', N'Đang đo vòng tua quạt RPM và kiểm tra bụi bẩn', 150000.00, 0.00, 0, NULL, '2026-10-29T12:58:57.6032225', NULL, NULL, NULL, NULL, '2026-10-29T12:58:57.6032225', '2026-10-29T12:58:57.6032225');
INSERT INTO dbo.[RepairTickets] ([TicketId], [TicketCode], [CustomerId], [DeviceId], [ServiceTypeId], [ReceivedByUserId], [TechnicianUserId], [Status], [DeviceCondition], [CustomerRequest], [Diagnosis], [QuotedLaborCost], [QuotedPartsCost], [IsWarrantyRepair], [OriginalTicketId], [ReceivedAt], [ExpectedFinishAt], [CompletedAt], [DeliveredAt], [CancelReason], [CreatedAt], [UpdatedAt]) VALUES (60, N'DEMO-TEST-PSC11', 47, 50, 1, 2, 3, N'WAITING_CONFIRM', N'Camera chính 48MP bị mờ và rung lắc liên tục', N'Khách yêu cầu kiểm tra chống rung OIS', N'Hỏng bộ chống rung quang học, cần thay cụm camera zin', 200000.00, 1850000.00, 0, NULL, '2026-10-29T12:58:57.6032225', NULL, NULL, NULL, NULL, '2026-10-29T12:58:57.6032225', '2026-10-29T12:58:57.6032225');
INSERT INTO dbo.[RepairTickets] ([TicketId], [TicketCode], [CustomerId], [DeviceId], [ServiceTypeId], [ReceivedByUserId], [TechnicianUserId], [Status], [DeviceCondition], [CustomerRequest], [Diagnosis], [QuotedLaborCost], [QuotedPartsCost], [IsWarrantyRepair], [OriginalTicketId], [ReceivedAt], [ExpectedFinishAt], [CompletedAt], [DeliveredAt], [CancelReason], [CreatedAt], [UpdatedAt]) VALUES (61, N'DEMO-TEST-PSC12', 48, 51, 10, 2, 3, N'REPAIRING', N'Cổng sạc Type-C bị cháy đen do dùng sạc trôi nổi', N'Thay thế chân sạc cáp bẹ Type-C', N'Đang hàn chân cáp sạc trên kính hiển vi điện tử', 180000.00, 420000.00, 0, NULL, '2026-10-29T12:58:57.6032225', NULL, NULL, NULL, NULL, '2026-10-29T12:58:57.6032225', '2026-10-29T12:58:57.6032225');
INSERT INTO dbo.[RepairTickets] ([TicketId], [TicketCode], [CustomerId], [DeviceId], [ServiceTypeId], [ReceivedByUserId], [TechnicianUserId], [Status], [DeviceCondition], [CustomerRequest], [Diagnosis], [QuotedLaborCost], [QuotedPartsCost], [IsWarrantyRepair], [OriginalTicketId], [ReceivedAt], [ExpectedFinishAt], [CompletedAt], [DeliveredAt], [CancelReason], [CreatedAt], [UpdatedAt]) VALUES (62, N'DEMO-TEST-PSC13', 46, 49, 1, 2, 3, N'COMPLETED', N'Máy chạy đơ lag, nhiễm mã độc quảng cáo trình duyệt', N'Cài lại hệ điều hành sạch sẽ và backup dữ liệu', N'Đã cài Windows 11 Pro 64-bit chuẩn GPT, quét sạch virus', 100000.00, 0.00, 0, NULL, '2026-10-29T12:58:57.6032225', NULL, NULL, NULL, NULL, '2026-10-29T12:58:57.6032225', '2026-10-29T12:58:57.6032225');
INSERT INTO dbo.[RepairTickets] ([TicketId], [TicketCode], [CustomerId], [DeviceId], [ServiceTypeId], [ReceivedByUserId], [TechnicianUserId], [Status], [DeviceCondition], [CustomerRequest], [Diagnosis], [QuotedLaborCost], [QuotedPartsCost], [IsWarrantyRepair], [OriginalTicketId], [ReceivedAt], [ExpectedFinishAt], [CompletedAt], [DeliveredAt], [CancelReason], [CreatedAt], [UpdatedAt]) VALUES (63, N'DEMO-TEST-PSC14', 47, 50, 10, 2, 3, N'DELIVERED', N'Nút nguồn bị thụt sâu, bấm không có độ nảy', N'Sửa cáp phím nguồn và tăng độ đàn hồi', N'Đã thay cáp phím nguồn mới, độ nảy đàn hồi tốt', 120000.00, 150000.00, 0, NULL, '2026-10-29T12:58:57.6032225', NULL, NULL, NULL, NULL, '2026-10-29T12:58:57.6032225', '2026-10-29T12:58:57.6032225');
INSERT INTO dbo.[RepairTickets] ([TicketId], [TicketCode], [CustomerId], [DeviceId], [ServiceTypeId], [ReceivedByUserId], [TechnicianUserId], [Status], [DeviceCondition], [CustomerRequest], [Diagnosis], [QuotedLaborCost], [QuotedPartsCost], [IsWarrantyRepair], [OriginalTicketId], [ReceivedAt], [ExpectedFinishAt], [CompletedAt], [DeliveredAt], [CancelReason], [CreatedAt], [UpdatedAt]) VALUES (64, N'DEMO-TEST-PSC15', 48, 51, 1, 2, 3, N'RECEIVED', N'Khách muốn nâng cấp dán cường lực cao cấp', N'Dán cường lực KingKong chống nhìn trộm', N'Tiếp nhận dán màn hình tại quầy', 50000.00, 120000.00, 0, NULL, '2026-10-29T12:58:57.6032225', NULL, NULL, NULL, NULL, '2026-10-29T12:58:57.6032225', '2026-10-29T12:58:57.6032225');
INSERT INTO dbo.[RepairTickets] ([TicketId], [TicketCode], [CustomerId], [DeviceId], [ServiceTypeId], [ReceivedByUserId], [TechnicianUserId], [Status], [DeviceCondition], [CustomerRequest], [Diagnosis], [QuotedLaborCost], [QuotedPartsCost], [IsWarrantyRepair], [OriginalTicketId], [ReceivedAt], [ExpectedFinishAt], [CompletedAt], [DeliveredAt], [CancelReason], [CreatedAt], [UpdatedAt]) VALUES (65, N'DEMO-TEST-PSC16', 46, 49, 10, 2, 3, N'DIAGNOSING', N'Touchpad chuột cảm ứng đôi lúc bị loạn nhảy con trỏ', N'Kiểm tra cáp chuột và pin có bị phù kích chuột không', N'Đang mở nắp đáy kiểm tra pin lithium', 100000.00, 0.00, 0, NULL, '2026-10-29T12:58:57.6032225', NULL, NULL, NULL, NULL, '2026-10-29T12:58:57.6032225', '2026-10-29T12:58:57.6032225');
INSERT INTO dbo.[RepairTickets] ([TicketId], [TicketCode], [CustomerId], [DeviceId], [ServiceTypeId], [ReceivedByUserId], [TechnicianUserId], [Status], [DeviceCondition], [CustomerRequest], [Diagnosis], [QuotedLaborCost], [QuotedPartsCost], [IsWarrantyRepair], [OriginalTicketId], [ReceivedAt], [ExpectedFinishAt], [CompletedAt], [DeliveredAt], [CancelReason], [CreatedAt], [UpdatedAt]) VALUES (66, N'DEMO-TEST-PSC17', 47, 50, 1, 2, 3, N'REPAIRING', N'Mic thoại đàm thoại bên kia nghe rất nhỏ và rè', N'Thay lưới chống bụi mic và cụm mic thu âm', N'Đang vệ sinh màng mic và thay IC audio codec', 150000.00, 250000.00, 0, NULL, '2026-10-29T12:58:57.6032225', NULL, NULL, NULL, NULL, '2026-10-29T12:58:57.6032225', '2026-10-29T12:58:57.6032225');
INSERT INTO dbo.[RepairTickets] ([TicketId], [TicketCode], [CustomerId], [DeviceId], [ServiceTypeId], [ReceivedByUserId], [TechnicianUserId], [Status], [DeviceCondition], [CustomerRequest], [Diagnosis], [QuotedLaborCost], [QuotedPartsCost], [IsWarrantyRepair], [OriginalTicketId], [ReceivedAt], [ExpectedFinishAt], [CompletedAt], [DeliveredAt], [CancelReason], [CreatedAt], [UpdatedAt]) VALUES (67, N'DEMO-TEST-PSC18', 48, 51, 10, 2, 3, N'COMPLETED', N'Màn hình có 1 điểm chết pixel màu đỏ góc trái', N'Kiểm tra bảo hành màn hình theo tiêu chuẩn hãng', N'Đã chạy phần mềm kích pixel và cân màu màn hình ổn định', 80000.00, 0.00, 0, NULL, '2026-10-29T12:58:57.6032225', NULL, NULL, NULL, NULL, '2026-10-29T12:58:57.6032225', '2026-10-29T12:58:57.6032225');
INSERT INTO dbo.[RepairTickets] ([TicketId], [TicketCode], [CustomerId], [DeviceId], [ServiceTypeId], [ReceivedByUserId], [TechnicianUserId], [Status], [DeviceCondition], [CustomerRequest], [Diagnosis], [QuotedLaborCost], [QuotedPartsCost], [IsWarrantyRepair], [OriginalTicketId], [ReceivedAt], [ExpectedFinishAt], [CompletedAt], [DeliveredAt], [CancelReason], [CreatedAt], [UpdatedAt]) VALUES (68, N'DEMO-TEST-PSC19', 46, 49, 1, 2, 3, N'COMPLETED', N'Khách mua gói bảo dưỡng định kỳ 6 tháng', N'Vệ sinh toàn diện, tra keo gốm Kryonaut, thổi bụi linh kiện', N'Đã hoàn thành bảo dưỡng, xuất hóa đơn điện tử cho khách', 150000.00, 0.00, 0, NULL, '2026-10-29T12:58:57.6032225', NULL, NULL, NULL, NULL, '2026-10-29T12:58:57.6032225', '2026-10-29T12:58:57.6032225');
SET IDENTITY_INSERT dbo.[RepairTickets] OFF;
GO

-- Invoices: 18 dong
SET IDENTITY_INSERT dbo.[Invoices] ON;
INSERT INTO dbo.[Invoices] ([InvoiceId], [InvoiceCode], [TicketId], [CustomerId], [LaborCost], [PartsCost], [DiscountAmount], [PaymentMethod], [PaymentStatus], [PaidAt], [CreatedByUserId], [Note], [CreatedAt]) VALUES (1, N'HD2026100001', 5, 5, 120000.00, 2250000.00, 0.00, N'TRANSFER', N'PAID', '2026-10-21T09:05:12.5700000', 2, N'Chuyển khoản VietQR Ngân hàng MBBank', '2026-10-21T09:05:12.5700000');
INSERT INTO dbo.[Invoices] ([InvoiceId], [InvoiceCode], [TicketId], [CustomerId], [LaborCost], [PartsCost], [DiscountAmount], [PaymentMethod], [PaymentStatus], [PaidAt], [CreatedByUserId], [Note], [CreatedAt]) VALUES (2, N'HD2026100002', 7, 7, 150000.00, 620000.00, 0.00, N'CASH', N'PAID', '2026-10-22T09:05:12.5700000', 2, N'Thanh toán tiền mặt tại quầy', '2026-10-22T09:05:12.5700000');
INSERT INTO dbo.[Invoices] ([InvoiceId], [InvoiceCode], [TicketId], [CustomerId], [LaborCost], [PartsCost], [DiscountAmount], [PaymentMethod], [PaymentStatus], [PaidAt], [CreatedByUserId], [Note], [CreatedAt]) VALUES (3, N'HD2026100003', 1, 1, 150000.00, 180000.00, 0.00, N'TRANSFER', N'PAID', '2026-10-23T09:05:12.5700000', 2, N'Chuyển khoản VietQR', '2026-10-23T09:05:12.5700000');
INSERT INTO dbo.[Invoices] ([InvoiceId], [InvoiceCode], [TicketId], [CustomerId], [LaborCost], [PartsCost], [DiscountAmount], [PaymentMethod], [PaymentStatus], [PaidAt], [CreatedByUserId], [Note], [CreatedAt]) VALUES (4, N'HD2026100004', 9, 9, 100000.00, 750000.00, 0.00, N'TRANSFER', N'PAID', '2026-10-23T09:05:12.5700000', 2, N'Chuyển khoản VietQR', '2026-10-23T09:05:12.5700000');
INSERT INTO dbo.[Invoices] ([InvoiceId], [InvoiceCode], [TicketId], [CustomerId], [LaborCost], [PartsCost], [DiscountAmount], [PaymentMethod], [PaymentStatus], [PaidAt], [CreatedByUserId], [Note], [CreatedAt]) VALUES (5, N'HD2026100005', 10, 10, 100000.00, 890000.00, 0.00, N'CASH', N'PAID', '2026-10-24T09:05:12.5700000', 2, N'Thanh toán tiền mặt', '2026-10-24T09:05:12.5700000');
INSERT INTO dbo.[Invoices] ([InvoiceId], [InvoiceCode], [TicketId], [CustomerId], [LaborCost], [PartsCost], [DiscountAmount], [PaymentMethod], [PaymentStatus], [PaidAt], [CreatedByUserId], [Note], [CreatedAt]) VALUES (6, N'HD2026100006', 14, 14, 150000.00, 3200000.00, 50000.00, N'TRANSFER', N'PAID', '2026-10-22T10:01:02.7160000', 2, N'Khách thanh toán chuyển khoản QR, chiết khấu 50k tri ân', '2026-10-22T10:01:02.7160000');
INSERT INTO dbo.[Invoices] ([InvoiceId], [InvoiceCode], [TicketId], [CustomerId], [LaborCost], [PartsCost], [DiscountAmount], [PaymentMethod], [PaymentStatus], [PaidAt], [CreatedByUserId], [Note], [CreatedAt]) VALUES (7, N'HD2026100007', 16, 16, 100000.00, 0.00, 0.00, N'CASH', N'PAID', '2026-10-23T10:01:02.7160000', 2, N'Thanh toán tiền mặt cài Windows', '2026-10-23T10:01:02.7160000');
INSERT INTO dbo.[Invoices] ([InvoiceId], [InvoiceCode], [TicketId], [CustomerId], [LaborCost], [PartsCost], [DiscountAmount], [PaymentMethod], [PaymentStatus], [PaidAt], [CreatedByUserId], [Note], [CreatedAt]) VALUES (8, N'HD2026100008', 20, 20, 150000.00, 280000.00, 0.00, N'TRANSFER', N'PAID', '2026-10-24T10:01:02.7160000', 2, N'Chuyển khoản Vietcombank', '2026-10-24T10:01:02.7160000');
INSERT INTO dbo.[Invoices] ([InvoiceId], [InvoiceCode], [TicketId], [CustomerId], [LaborCost], [PartsCost], [DiscountAmount], [PaymentMethod], [PaymentStatus], [PaidAt], [CreatedByUserId], [Note], [CreatedAt]) VALUES (9, N'HD2026100009', 23, 23, 100000.00, 580000.00, 0.00, N'TRANSFER', N'PAID', '2026-10-23T10:01:02.7160000', 2, N'Chuyển khoản MBBank', '2026-10-23T10:01:02.7160000');
INSERT INTO dbo.[Invoices] ([InvoiceId], [InvoiceCode], [TicketId], [CustomerId], [LaborCost], [PartsCost], [DiscountAmount], [PaymentMethod], [PaymentStatus], [PaidAt], [CreatedByUserId], [Note], [CreatedAt]) VALUES (10, N'HD2026100010', 24, 24, 120000.00, 950000.00, 0.00, N'CASH', N'PAID', '2026-10-24T10:01:02.7160000', 2, N'Thanh toán tiền mặt nâng cấp SSD', '2026-10-24T10:01:02.7160000');
INSERT INTO dbo.[Invoices] ([InvoiceId], [InvoiceCode], [TicketId], [CustomerId], [LaborCost], [PartsCost], [DiscountAmount], [PaymentMethod], [PaymentStatus], [PaidAt], [CreatedByUserId], [Note], [CreatedAt]) VALUES (11, N'HD2026100011', 15, 15, 120000.00, 2250000.00, 0.00, N'TRANSFER', N'UNPAID', NULL, 2, N'Hóa đơn chờ thanh toán khi khách đến nhận máy PC', '2026-10-24T10:01:02.7160000');
INSERT INTO dbo.[Invoices] ([InvoiceId], [InvoiceCode], [TicketId], [CustomerId], [LaborCost], [PartsCost], [DiscountAmount], [PaymentMethod], [PaymentStatus], [PaidAt], [CreatedByUserId], [Note], [CreatedAt]) VALUES (12, N'HD2026100012', 19, 19, 120000.00, 950000.00, 0.00, N'CASH', N'UNPAID', '2026-10-25T10:01:02.7160000', 2, N'Hóa đơn chờ thanh toán thay bàn phím Dell Inspiron', '2026-10-25T10:01:02.7160000');
INSERT INTO dbo.[Invoices] ([InvoiceId], [InvoiceCode], [TicketId], [CustomerId], [LaborCost], [PartsCost], [DiscountAmount], [PaymentMethod], [PaymentStatus], [PaidAt], [CreatedByUserId], [Note], [CreatedAt]) VALUES (13, N'HD2026100013', 26, 27, 150000.00, 180000.00, 30000.00, N'CASH', N'UNPAID', NULL, 2, NULL, '2026-10-25T10:02:44.4130000');
INSERT INTO dbo.[Invoices] ([InvoiceId], [InvoiceCode], [TicketId], [CustomerId], [LaborCost], [PartsCost], [DiscountAmount], [PaymentMethod], [PaymentStatus], [PaidAt], [CreatedByUserId], [Note], [CreatedAt]) VALUES (14, N'HD2026100014', 27, 28, 150000.00, 180000.00, 30000.00, N'CASH', N'UNPAID', NULL, 2, NULL, '2026-10-25T10:03:58.4740000');
INSERT INTO dbo.[Invoices] ([InvoiceId], [InvoiceCode], [TicketId], [CustomerId], [LaborCost], [PartsCost], [DiscountAmount], [PaymentMethod], [PaymentStatus], [PaidAt], [CreatedByUserId], [Note], [CreatedAt]) VALUES (15, N'HD2026100015', 28, 29, 150000.00, 180000.00, 30000.00, N'TRANSFER', N'PAID', '2026-10-25T10:04:38.1330000', 2, NULL, '2026-10-25T10:04:38.1190000');
INSERT INTO dbo.[Invoices] ([InvoiceId], [InvoiceCode], [TicketId], [CustomerId], [LaborCost], [PartsCost], [DiscountAmount], [PaymentMethod], [PaymentStatus], [PaidAt], [CreatedByUserId], [Note], [CreatedAt]) VALUES (16, N'HD2026100016', 29, 30, 150000.00, 180000.00, 30000.00, N'TRANSFER', N'PAID', '2026-10-26T07:50:08.8200065', 2, NULL, '2026-10-26T07:50:08.7544982');
INSERT INTO dbo.[Invoices] ([InvoiceId], [InvoiceCode], [TicketId], [CustomerId], [LaborCost], [PartsCost], [DiscountAmount], [PaymentMethod], [PaymentStatus], [PaidAt], [CreatedByUserId], [Note], [CreatedAt]) VALUES (17, N'HD2026100017', 30, 31, 150000.00, 180000.00, 30000.00, N'TRANSFER', N'PAID', '2026-10-26T07:51:27.9419689', 2, NULL, '2026-10-26T07:51:27.9152759');
INSERT INTO dbo.[Invoices] ([InvoiceId], [InvoiceCode], [TicketId], [CustomerId], [LaborCost], [PartsCost], [DiscountAmount], [PaymentMethod], [PaymentStatus], [PaidAt], [CreatedByUserId], [Note], [CreatedAt]) VALUES (18, N'HD2026100018', 31, 32, 150000.00, 180000.00, 30000.00, N'TRANSFER', N'PAID', '2026-10-26T09:22:16.8627774', 2, NULL, '2026-10-26T09:22:16.8362899');
SET IDENTITY_INSERT dbo.[Invoices] OFF;
GO

-- Payments: 14 dong
SET IDENTITY_INSERT dbo.[Payments] ON;
INSERT INTO dbo.[Payments] ([PaymentId], [InvoiceId], [Amount], [PaymentMethod], [ReceivedByUserId], [PaidAt], [Note]) VALUES (1, 1, 2370000.00, N'TRANSFER', 2, '2026-10-21T09:05:12.5700000', N'Thanh toÃ¡n ban Ä‘áº§u cho hÃ³a Ä‘Æ¡n HD2026100001');
INSERT INTO dbo.[Payments] ([PaymentId], [InvoiceId], [Amount], [PaymentMethod], [ReceivedByUserId], [PaidAt], [Note]) VALUES (2, 2, 770000.00, N'CASH', 2, '2026-10-22T09:05:12.5700000', N'Thanh toÃ¡n ban Ä‘áº§u cho hÃ³a Ä‘Æ¡n HD2026100002');
INSERT INTO dbo.[Payments] ([PaymentId], [InvoiceId], [Amount], [PaymentMethod], [ReceivedByUserId], [PaidAt], [Note]) VALUES (3, 3, 330000.00, N'TRANSFER', 2, '2026-10-23T09:05:12.5700000', N'Thanh toÃ¡n ban Ä‘áº§u cho hÃ³a Ä‘Æ¡n HD2026100003');
INSERT INTO dbo.[Payments] ([PaymentId], [InvoiceId], [Amount], [PaymentMethod], [ReceivedByUserId], [PaidAt], [Note]) VALUES (4, 4, 850000.00, N'TRANSFER', 2, '2026-10-23T09:05:12.5700000', N'Thanh toÃ¡n ban Ä‘áº§u cho hÃ³a Ä‘Æ¡n HD2026100004');
INSERT INTO dbo.[Payments] ([PaymentId], [InvoiceId], [Amount], [PaymentMethod], [ReceivedByUserId], [PaidAt], [Note]) VALUES (5, 5, 990000.00, N'CASH', 2, '2026-10-24T09:05:12.5700000', N'Thanh toÃ¡n ban Ä‘áº§u cho hÃ³a Ä‘Æ¡n HD2026100005');
INSERT INTO dbo.[Payments] ([PaymentId], [InvoiceId], [Amount], [PaymentMethod], [ReceivedByUserId], [PaidAt], [Note]) VALUES (6, 6, 3300000.00, N'TRANSFER', 2, '2026-10-22T10:01:02.7160000', N'Thanh toÃ¡n ban Ä‘áº§u cho hÃ³a Ä‘Æ¡n HD2026100006');
INSERT INTO dbo.[Payments] ([PaymentId], [InvoiceId], [Amount], [PaymentMethod], [ReceivedByUserId], [PaidAt], [Note]) VALUES (7, 7, 100000.00, N'CASH', 2, '2026-10-23T10:01:02.7160000', N'Thanh toÃ¡n ban Ä‘áº§u cho hÃ³a Ä‘Æ¡n HD2026100007');
INSERT INTO dbo.[Payments] ([PaymentId], [InvoiceId], [Amount], [PaymentMethod], [ReceivedByUserId], [PaidAt], [Note]) VALUES (8, 8, 430000.00, N'TRANSFER', 2, '2026-10-24T10:01:02.7160000', N'Thanh toÃ¡n ban Ä‘áº§u cho hÃ³a Ä‘Æ¡n HD2026100008');
INSERT INTO dbo.[Payments] ([PaymentId], [InvoiceId], [Amount], [PaymentMethod], [ReceivedByUserId], [PaidAt], [Note]) VALUES (9, 9, 680000.00, N'TRANSFER', 2, '2026-10-23T10:01:02.7160000', N'Thanh toÃ¡n ban Ä‘áº§u cho hÃ³a Ä‘Æ¡n HD2026100009');
INSERT INTO dbo.[Payments] ([PaymentId], [InvoiceId], [Amount], [PaymentMethod], [ReceivedByUserId], [PaidAt], [Note]) VALUES (10, 10, 1070000.00, N'CASH', 2, '2026-10-24T10:01:02.7160000', N'Thanh toÃ¡n ban Ä‘áº§u cho hÃ³a Ä‘Æ¡n HD2026100010');
INSERT INTO dbo.[Payments] ([PaymentId], [InvoiceId], [Amount], [PaymentMethod], [ReceivedByUserId], [PaidAt], [Note]) VALUES (11, 15, 0.00, N'TRANSFER', 2, '2026-10-25T10:04:38.1330000', N'Thanh toan hoa don HD2026100015 bang hinh thuc TRANSFER');
INSERT INTO dbo.[Payments] ([PaymentId], [InvoiceId], [Amount], [PaymentMethod], [ReceivedByUserId], [PaidAt], [Note]) VALUES (12, 16, 0.00, N'TRANSFER', 2, '2026-10-26T07:50:08.8112772', N'Thanh toan hoa don HD2026100016 bang hinh thuc TRANSFER');
INSERT INTO dbo.[Payments] ([PaymentId], [InvoiceId], [Amount], [PaymentMethod], [ReceivedByUserId], [PaidAt], [Note]) VALUES (13, 17, 0.00, N'TRANSFER', 2, '2026-10-26T07:51:27.9418417', N'Thanh toan hoa don HD2026100017 bang hinh thuc TRANSFER');
INSERT INTO dbo.[Payments] ([PaymentId], [InvoiceId], [Amount], [PaymentMethod], [ReceivedByUserId], [PaidAt], [Note]) VALUES (14, 18, 0.00, N'TRANSFER', 2, '2026-10-26T09:22:16.8626424', N'Thanh toan hoa don HD2026100018 bang hinh thuc TRANSFER');
SET IDENTITY_INSERT dbo.[Payments] OFF;
GO

-- SparePartCategories: 6 dong
SET IDENTITY_INSERT dbo.[SparePartCategories] ON;
INSERT INTO dbo.[SparePartCategories] ([CategoryId], [CategoryName], [Description], [IsActive]) VALUES (1, N'Màn hình Smartphone & Laptop', N'Màn hình Super Retina XDR, Dynamic AMOLED 2X, LCD IPS 144Hz', 1);
INSERT INTO dbo.[SparePartCategories] ([CategoryId], [CategoryName], [Description], [IsActive]) VALUES (2, N'Pin & Bộ sạc công suất cao', N'Pin Pisen chính hãng, Pin zin máy, Pin Dell/Apple cao cấp', 1);
INSERT INTO dbo.[SparePartCategories] ([CategoryId], [CategoryName], [Description], [IsActive]) VALUES (3, N'Ổ cứng SSD NVMe & RAM', N'SSD Samsung 980 PRO, Kingston NV2, RAM Crucial DDR5, Kingston DDR4', 1);
INSERT INTO dbo.[SparePartCategories] ([CategoryId], [CategoryName], [Description], [IsActive]) VALUES (4, N'IC nguồn, Chipset & Bo mạch', N'IC PMIC Qualcomm, chip sạc Type-C Thunderbolt, tụ gốm cao tần', 1);
INSERT INTO dbo.[SparePartCategories] ([CategoryId], [CategoryName], [Description], [IsActive]) VALUES (5, N'Bàn phím, Vỏ & Cụm linh kiện', N'Bàn phím ThinkPad, quạt Asus ROG, cáp Type-C iPhone/iPad', 1);
INSERT INTO dbo.[SparePartCategories] ([CategoryId], [CategoryName], [Description], [IsActive]) VALUES (6, N'Keo tản nhiệt & Vật tư bảo dưỡng', N'Keo gốm Thermal Grizzly, dung dịch tẩy keo Arctic Clean, ron chống nước', 1);
SET IDENTITY_INSERT dbo.[SparePartCategories] OFF;
GO

-- SpareParts: 26 dong
SET IDENTITY_INSERT dbo.[SpareParts] ON;
INSERT INTO dbo.[SpareParts] ([PartId], [PartCode], [CategoryId], [PartName], [Unit], [PurchasePrice], [SellingPrice], [StockQuantity], [MinStockLevel], [WarrantyDays], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (1, N'LK00001', 1, N'Màn hình iPhone 14 Pro Max Super Retina XDR Zin máy', N'Cái', 4800000.00, 5600000.00, 6, 2, 90, 1, '2026-09-25T09:05:12.5700000', NULL);
INSERT INTO dbo.[SpareParts] ([PartId], [PartCode], [CategoryId], [PartName], [Unit], [PurchasePrice], [SellingPrice], [StockQuantity], [MinStockLevel], [WarrantyDays], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (2, N'LK00002', 1, N'Màn hình Samsung Galaxy S23 Ultra Dynamic AMOLED 2X', N'Cái', 4100000.00, 4900000.00, 4, 2, 90, 1, '2026-09-25T09:05:12.5700000', NULL);
INSERT INTO dbo.[SpareParts] ([PartId], [PartCode], [CategoryId], [PartName], [Unit], [PurchasePrice], [SellingPrice], [StockQuantity], [MinStockLevel], [WarrantyDays], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (3, N'LK00003', 1, N'Màn hình LCD Laptop 15.6" IPS FHD 144Hz Slim', N'Cái', 1250000.00, 1650000.00, 8, 3, 180, 1, '2026-09-25T09:05:12.5700000', NULL);
INSERT INTO dbo.[SpareParts] ([PartId], [PartCode], [CategoryId], [PartName], [Unit], [PurchasePrice], [SellingPrice], [StockQuantity], [MinStockLevel], [WarrantyDays], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (4, N'LK00004', 1, N'Màn hình MacBook Pro 14" Liquid Retina XDR A2442', N'Cái', 6800000.00, 7900000.00, 3, 1, 180, 1, '2026-09-25T09:05:12.5700000', NULL);
INSERT INTO dbo.[SpareParts] ([PartId], [PartCode], [CategoryId], [PartName], [Unit], [PurchasePrice], [SellingPrice], [StockQuantity], [MinStockLevel], [WarrantyDays], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (5, N'LK00005', 2, N'Pin iPhone 14 Pro Max Pisen dung lượng cao 4323mAh', N'Cái', 580000.00, 790000.00, 15, 5, 180, 1, '2026-09-25T09:05:12.5700000', NULL);
INSERT INTO dbo.[SpareParts] ([PartId], [PartCode], [CategoryId], [PartName], [Unit], [PurchasePrice], [SellingPrice], [StockQuantity], [MinStockLevel], [WarrantyDays], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (6, N'LK00006', 2, N'Pin Samsung Galaxy S23 Ultra Zin 5000mAh', N'Cái', 480000.00, 680000.00, 10, 3, 180, 1, '2026-09-25T09:05:12.5700000', NULL);
INSERT INTO dbo.[SpareParts] ([PartId], [PartCode], [CategoryId], [PartName], [Unit], [PurchasePrice], [SellingPrice], [StockQuantity], [MinStockLevel], [WarrantyDays], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (7, N'LK00007', 2, N'Pin Laptop Dell XPS 15 86Wh 6-cell chính hãng', N'Cái', 980000.00, 1350000.00, 2, 2, 180, 1, '2026-09-25T09:05:12.5700000', NULL);
INSERT INTO dbo.[SpareParts] ([PartId], [PartCode], [CategoryId], [PartName], [Unit], [PurchasePrice], [SellingPrice], [StockQuantity], [MinStockLevel], [WarrantyDays], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (8, N'LK00008', 2, N'Pin MacBook Pro 14" A2442 70Wh Zin', N'Cái', 1350000.00, 1850000.00, 4, 2, 180, 1, '2026-09-25T09:05:12.5700000', NULL);
INSERT INTO dbo.[SpareParts] ([PartId], [PartCode], [CategoryId], [PartName], [Unit], [PurchasePrice], [SellingPrice], [StockQuantity], [MinStockLevel], [WarrantyDays], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (9, N'LK00009', 3, N'Ổ cứng SSD Samsung 980 PRO 1TB PCIe NVMe 4.0', N'Cái', 1850000.00, 2250000.00, 12, 4, 365, 1, '2026-09-25T09:05:12.5700000', NULL);
INSERT INTO dbo.[SpareParts] ([PartId], [PartCode], [CategoryId], [PartName], [Unit], [PurchasePrice], [SellingPrice], [StockQuantity], [MinStockLevel], [WarrantyDays], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (10, N'LK00010', 3, N'Ổ cứng SSD Kingston NV2 512GB M.2 PCIe 4.0', N'Cái', 720000.00, 950000.00, 18, 5, 365, 1, '2026-09-25T09:05:12.5700000', NULL);
INSERT INTO dbo.[SpareParts] ([PartId], [PartCode], [CategoryId], [PartName], [Unit], [PurchasePrice], [SellingPrice], [StockQuantity], [MinStockLevel], [WarrantyDays], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (11, N'LK00011', 3, N'RAM Laptop Crucial DDR5 16GB 4800MHz', N'Thanh', 980000.00, 1280000.00, 8, 3, 365, 1, '2026-09-25T09:05:12.5700000', NULL);
INSERT INTO dbo.[SpareParts] ([PartId], [PartCode], [CategoryId], [PartName], [Unit], [PurchasePrice], [SellingPrice], [StockQuantity], [MinStockLevel], [WarrantyDays], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (12, N'LK00012', 3, N'RAM Laptop Kingston Fury DDR4 16GB 3200MHz', N'Thanh', 680000.00, 890000.00, 14, 4, 365, 1, '2026-09-25T09:05:12.5700000', NULL);
INSERT INTO dbo.[SpareParts] ([PartId], [PartCode], [CategoryId], [PartName], [Unit], [PurchasePrice], [SellingPrice], [StockQuantity], [MinStockLevel], [WarrantyDays], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (13, N'LK00013', 4, N'IC Nguồn PMIC Qualcomm Snapdragon SM8550', N'Cái', 220000.00, 450000.00, 20, 5, 90, 1, '2026-09-25T09:05:12.5700000', NULL);
INSERT INTO dbo.[SpareParts] ([PartId], [PartCode], [CategoryId], [PartName], [Unit], [PurchasePrice], [SellingPrice], [StockQuantity], [MinStockLevel], [WarrantyDays], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (14, N'LK00014', 5, N'Cụm chân sạc Type-C iPhone 14 Pro Max bóc máy', N'Cái', 380000.00, 620000.00, 7, 2, 90, 1, '2026-09-25T09:05:12.5700000', NULL);
INSERT INTO dbo.[SpareParts] ([PartId], [PartCode], [CategoryId], [PartName], [Unit], [PurchasePrice], [SellingPrice], [StockQuantity], [MinStockLevel], [WarrantyDays], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (15, N'LK00015', 5, N'Bàn phím Laptop Lenovo ThinkPad X1 Carbon Led US', N'Cái', 650000.00, 950000.00, 1, 2, 180, 1, '2026-09-25T09:05:12.5700000', NULL);
INSERT INTO dbo.[SpareParts] ([PartId], [PartCode], [CategoryId], [PartName], [Unit], [PurchasePrice], [SellingPrice], [StockQuantity], [MinStockLevel], [WarrantyDays], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (16, N'LK00016', 6, N'Keo tản nhiệt Thermal Grizzly Kryonaut 1g', N'Tuýp', 110000.00, 180000.00, 29, 10, 0, 1, '2026-09-25T09:05:12.5700000', '2026-10-26T09:22:16.7868345');
INSERT INTO dbo.[SpareParts] ([PartId], [PartCode], [CategoryId], [PartName], [Unit], [PurchasePrice], [SellingPrice], [StockQuantity], [MinStockLevel], [WarrantyDays], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (17, N'LK00017', 5, N'Cụm quạt tản nhiệt đôi Asus ROG Zephyrus G14', N'Bộ', 320000.00, 490000.00, 5, 2, 90, 1, '2026-09-25T09:05:12.5700000', NULL);
INSERT INTO dbo.[SpareParts] ([PartId], [PartCode], [CategoryId], [PartName], [Unit], [PurchasePrice], [SellingPrice], [StockQuantity], [MinStockLevel], [WarrantyDays], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (18, N'LK00018', 1, N'Mặt kính Sapphire cụm camera iPad Pro 11"', N'Cái', 150000.00, 280000.00, 9, 3, 90, 1, '2026-09-25T09:05:12.5700000', NULL);
INSERT INTO dbo.[SpareParts] ([PartId], [PartCode], [CategoryId], [PartName], [Unit], [PurchasePrice], [SellingPrice], [StockQuantity], [MinStockLevel], [WarrantyDays], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (19, N'LK00019', 1, N'Màn hình OLED iPhone 15 Pro Max Super Retina XDR 120Hz', N'Cái', 5800000.00, 6900000.00, 8, 2, 90, 1, '2026-10-28T21:41:41.0566667', '2026-10-28T21:41:41.0566667');
INSERT INTO dbo.[SpareParts] ([PartId], [PartCode], [CategoryId], [PartName], [Unit], [PurchasePrice], [SellingPrice], [StockQuantity], [MinStockLevel], [WarrantyDays], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (20, N'LK00020', 2, N'Pin MacBook Pro 16 M3 Max 100Wh Zin chính hãng Apple', N'Cái', 2100000.00, 2650000.00, 5, 2, 180, 1, '2026-10-28T21:41:41.0600000', '2026-10-28T21:41:41.0600000');
INSERT INTO dbo.[SpareParts] ([PartId], [PartCode], [CategoryId], [PartName], [Unit], [PurchasePrice], [SellingPrice], [StockQuantity], [MinStockLevel], [WarrantyDays], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (21, N'LK00021', 3, N'RAM Laptop Crucial DDR5 32GB 5600MHz SO-DIMM', N'Thanh', 1950000.00, 2400000.00, 12, 3, 365, 1, '2026-10-28T21:41:41.0600000', '2026-10-28T21:41:41.0600000');
INSERT INTO dbo.[SpareParts] ([PartId], [PartCode], [CategoryId], [PartName], [Unit], [PurchasePrice], [SellingPrice], [StockQuantity], [MinStockLevel], [WarrantyDays], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (22, N'LK00022', 3, N'Ổ cứng SSD WD Black SN850X 2TB PCIe Gen 4x4 7300MB/s', N'Cái', 3200000.00, 3950000.00, 6, 2, 365, 1, '2026-10-28T21:41:41.0600000', '2026-10-28T21:41:41.0600000');
INSERT INTO dbo.[SpareParts] ([PartId], [PartCode], [CategoryId], [PartName], [Unit], [PurchasePrice], [SellingPrice], [StockQuantity], [MinStockLevel], [WarrantyDays], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (23, N'LK00023', 4, N'IC Sạc nhanh PD & Thunderbolt 4 Cypress CYPD6227', N'Cái', 450000.00, 750000.00, 15, 4, 90, 1, '2026-10-28T21:41:41.0633333', '2026-10-28T21:41:41.0633333');
INSERT INTO dbo.[SpareParts] ([PartId], [PartCode], [CategoryId], [PartName], [Unit], [PurchasePrice], [SellingPrice], [StockQuantity], [MinStockLevel], [WarrantyDays], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (24, N'LK00024', 5, N'Cụm tản nhiệt buồng hơi Vapor Chamber ROG Zephyrus G16', N'Bộ', 1200000.00, 1650000.00, 4, 1, 90, 1, '2026-10-28T21:41:41.0633333', '2026-10-28T21:41:41.0633333');
INSERT INTO dbo.[SpareParts] ([PartId], [PartCode], [CategoryId], [PartName], [Unit], [PurchasePrice], [SellingPrice], [StockQuantity], [MinStockLevel], [WarrantyDays], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (25, N'LK00025', 6, N'Keo kim loại lỏng Thermal Grizzly Conductonaut 1g', N'Tuýp', 260000.00, 380000.00, 14, 5, 30, 1, '2026-10-28T21:41:41.0666667', '2026-10-28T21:41:41.0666667');
INSERT INTO dbo.[SpareParts] ([PartId], [PartCode], [CategoryId], [PartName], [Unit], [PurchasePrice], [SellingPrice], [StockQuantity], [MinStockLevel], [WarrantyDays], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (26, N'LK00026', 1, N'Màn hình Dynamic AMOLED 2X Samsung Galaxy S24 Ultra', N'Cái', 4900000.00, 5850000.00, 7, 2, 90, 1, '2026-10-28T21:41:41.0700000', '2026-10-28T21:41:41.0700000');
SET IDENTITY_INSERT dbo.[SpareParts] OFF;
GO

-- StockTransactions: 21 dong
SET IDENTITY_INSERT dbo.[StockTransactions] ON;
INSERT INTO dbo.[StockTransactions] ([TransactionId], [PartId], [TransactionType], [Quantity], [UnitPrice], [StockBefore], [StockAfter], [TicketId], [PerformedByUserId], [Note], [TransactionAt]) VALUES (1, 9, N'IN', 15, 1850000.00, 0, 15, NULL, 2, N'Nháº­p kho lÃ´ SSD Samsung 980 PRO tá»« Synnex FPT', '2026-09-30T09:05:12.5700000');
INSERT INTO dbo.[StockTransactions] ([TransactionId], [PartId], [TransactionType], [Quantity], [UnitPrice], [StockBefore], [StockAfter], [TicketId], [PerformedByUserId], [Note], [TransactionAt]) VALUES (2, 16, N'IN', 40, 110000.00, 0, 40, NULL, 2, N'Nháº­p kho keo táº£n nhiá»‡t Thermal Grizzly Kryonaut', '2026-09-30T09:05:12.5700000');
INSERT INTO dbo.[StockTransactions] ([TransactionId], [PartId], [TransactionType], [Quantity], [UnitPrice], [StockBefore], [StockAfter], [TicketId], [PerformedByUserId], [Note], [TransactionAt]) VALUES (3, 14, N'IN', 10, 380000.00, 0, 10, NULL, 2, N'Nháº­p cá»¥m cÃ¡p sáº¡c Type-C linh kiá»‡n bÃ³c mÃ¡y', '2026-09-30T09:05:12.5700000');
INSERT INTO dbo.[StockTransactions] ([TransactionId], [PartId], [TransactionType], [Quantity], [UnitPrice], [StockBefore], [StockAfter], [TicketId], [PerformedByUserId], [Note], [TransactionAt]) VALUES (4, 5, N'IN', 20, 580000.00, 0, 20, NULL, 2, N'Nháº­p lÃ´ pin Pisen dung lÆ°á»£ng cao tá»« nhÃ  phÃ¢n phá»‘i 3A', '2026-09-30T09:05:12.5700000');
INSERT INTO dbo.[StockTransactions] ([TransactionId], [PartId], [TransactionType], [Quantity], [UnitPrice], [StockBefore], [StockAfter], [TicketId], [PerformedByUserId], [Note], [TransactionAt]) VALUES (5, 12, N'IN', 15, 680000.00, 0, 15, NULL, 2, N'Nháº­p RAM laptop Kingston Fury DDR4', '2026-09-30T09:05:12.5700000');
INSERT INTO dbo.[StockTransactions] ([TransactionId], [PartId], [TransactionType], [Quantity], [UnitPrice], [StockBefore], [StockAfter], [TicketId], [PerformedByUserId], [Note], [TransactionAt]) VALUES (6, 9, N'OUT', 1, 2250000.00, 15, 14, 5, 3, N'Xuáº¥t thay tháº¿ SSD Samsung 980 PRO cho PC Gaming PSC202610005', '2026-10-21T09:05:12.5700000');
INSERT INTO dbo.[StockTransactions] ([TransactionId], [PartId], [TransactionType], [Quantity], [UnitPrice], [StockBefore], [StockAfter], [TicketId], [PerformedByUserId], [Note], [TransactionAt]) VALUES (7, 14, N'OUT', 1, 620000.00, 10, 9, 7, 4, N'Xuáº¥t cá»¥m cÃ¡p sáº¡c Type-C thay cho iPad Pro PSC202610007', '2026-10-22T09:05:12.5700000');
INSERT INTO dbo.[StockTransactions] ([TransactionId], [PartId], [TransactionType], [Quantity], [UnitPrice], [StockBefore], [StockAfter], [TicketId], [PerformedByUserId], [Note], [TransactionAt]) VALUES (8, 16, N'OUT', 1, 180000.00, 40, 39, 1, 3, N'Xuáº¥t tuÃ½p keo táº£n nhiá»‡t gá»‘m tra cho Dell XPS 15 PSC202610001', '2026-10-23T09:05:12.5700000');
INSERT INTO dbo.[StockTransactions] ([TransactionId], [PartId], [TransactionType], [Quantity], [UnitPrice], [StockBefore], [StockAfter], [TicketId], [PerformedByUserId], [Note], [TransactionAt]) VALUES (9, 5, N'OUT', 1, 790000.00, 20, 19, 9, 4, N'Xuáº¥t pin Pisen thay cho iPhone 13 PSC202610009', '2026-10-23T09:05:12.5700000');
INSERT INTO dbo.[StockTransactions] ([TransactionId], [PartId], [TransactionType], [Quantity], [UnitPrice], [StockBefore], [StockAfter], [TicketId], [PerformedByUserId], [Note], [TransactionAt]) VALUES (10, 12, N'OUT', 1, 890000.00, 15, 14, 10, 3, N'Xuáº¥t thanh RAM 16GB láº¯p cho HP Envy 13 PSC202610010', '2026-10-24T09:05:12.5700000');
INSERT INTO dbo.[StockTransactions] ([TransactionId], [PartId], [TransactionType], [Quantity], [UnitPrice], [StockBefore], [StockAfter], [TicketId], [PerformedByUserId], [Note], [TransactionAt]) VALUES (11, 10, N'IN', 20, 720000.00, 0, 20, NULL, 2, N'Nháº­p thÃªm 20 chiáº¿c SSD Kingston NV2 512GB', '2026-10-15T10:01:02.7200000');
INSERT INTO dbo.[StockTransactions] ([TransactionId], [PartId], [TransactionType], [Quantity], [UnitPrice], [StockBefore], [StockAfter], [TicketId], [PerformedByUserId], [Note], [TransactionAt]) VALUES (12, 18, N'IN', 15, 150000.00, 0, 15, NULL, 2, N'Nháº­p kÃ­nh Sapphire camera', '2026-10-15T10:01:02.7200000');
INSERT INTO dbo.[StockTransactions] ([TransactionId], [PartId], [TransactionType], [Quantity], [UnitPrice], [StockBefore], [StockAfter], [TicketId], [PerformedByUserId], [Note], [TransactionAt]) VALUES (13, 1, N'OUT', 1, 3200000.00, 6, 5, 14, 4, N'Xuáº¥t mÃ n hÃ¬nh thay cho iPhone 12 Pro PSC202610014', '2026-10-22T10:01:02.7200000');
INSERT INTO dbo.[StockTransactions] ([TransactionId], [PartId], [TransactionType], [Quantity], [UnitPrice], [StockBefore], [StockAfter], [TicketId], [PerformedByUserId], [Note], [TransactionAt]) VALUES (14, 18, N'OUT', 1, 280000.00, 9, 8, 20, 4, N'Xuáº¥t kÃ­nh camera thay cho Xiaomi 13 Pro PSC202610020', '2026-10-24T10:01:02.7200000');
INSERT INTO dbo.[StockTransactions] ([TransactionId], [PartId], [TransactionType], [Quantity], [UnitPrice], [StockBefore], [StockAfter], [TicketId], [PerformedByUserId], [Note], [TransactionAt]) VALUES (15, 10, N'OUT', 1, 950000.00, 18, 17, 24, 3, N'Xuáº¥t SSD Kingston thay cho HP Pavilion PSC202610024', '2026-10-24T10:01:02.7200000');
INSERT INTO dbo.[StockTransactions] ([TransactionId], [PartId], [TransactionType], [Quantity], [UnitPrice], [StockBefore], [StockAfter], [TicketId], [PerformedByUserId], [Note], [TransactionAt]) VALUES (16, 16, N'OUT', 1, 180000.00, 35, 34, 26, 3, N'Xuáº¥t keo táº£n nhiá»‡t Kryonaut cho phiáº¿u kiá»ƒm thá»­', '2026-10-25T10:02:44.3050000');
INSERT INTO dbo.[StockTransactions] ([TransactionId], [PartId], [TransactionType], [Quantity], [UnitPrice], [StockBefore], [StockAfter], [TicketId], [PerformedByUserId], [Note], [TransactionAt]) VALUES (17, 16, N'OUT', 1, 180000.00, 34, 33, 27, 3, N'Xuáº¥t keo táº£n nhiá»‡t Kryonaut cho phiáº¿u kiá»ƒm thá»­', '2026-10-25T10:03:58.3290000');
INSERT INTO dbo.[StockTransactions] ([TransactionId], [PartId], [TransactionType], [Quantity], [UnitPrice], [StockBefore], [StockAfter], [TicketId], [PerformedByUserId], [Note], [TransactionAt]) VALUES (18, 16, N'OUT', 1, 180000.00, 33, 32, 28, 3, N'Xuáº¥t keo táº£n nhiá»‡t Kryonaut cho phiáº¿u kiá»ƒm thá»­', '2026-10-25T10:04:38.0750000');
INSERT INTO dbo.[StockTransactions] ([TransactionId], [PartId], [TransactionType], [Quantity], [UnitPrice], [StockBefore], [StockAfter], [TicketId], [PerformedByUserId], [Note], [TransactionAt]) VALUES (19, 16, N'OUT', 1, 180000.00, 32, 31, 29, 3, N'Xuất keo tản nhiệt Kryonaut cho phiếu kiểm thử', '2026-10-26T07:50:08.6423737');
INSERT INTO dbo.[StockTransactions] ([TransactionId], [PartId], [TransactionType], [Quantity], [UnitPrice], [StockBefore], [StockAfter], [TicketId], [PerformedByUserId], [Note], [TransactionAt]) VALUES (20, 16, N'OUT', 1, 180000.00, 31, 30, 30, 3, N'Xuất keo tản nhiệt Kryonaut cho phiếu kiểm thử', '2026-10-26T07:51:27.8629282');
INSERT INTO dbo.[StockTransactions] ([TransactionId], [PartId], [TransactionType], [Quantity], [UnitPrice], [StockBefore], [StockAfter], [TicketId], [PerformedByUserId], [Note], [TransactionAt]) VALUES (21, 16, N'OUT', 1, 180000.00, 30, 29, 31, 3, N'Xuất keo tản nhiệt Kryonaut cho phiếu kiểm thử', '2026-10-26T09:22:16.7868350');
SET IDENTITY_INSERT dbo.[StockTransactions] OFF;
GO

-- TicketParts: 13 dong
SET IDENTITY_INSERT dbo.[TicketParts] ON;
INSERT INTO dbo.[TicketParts] ([TicketPartId], [TicketId], [PartId], [Quantity], [UnitPrice], [Note], [CreatedAt]) VALUES (1, 1, 16, 1, 180000.00, N'Keo táº£n nhiá»‡t gá»‘m Thermal Grizzly Kryonaut 1g', '2026-10-23T09:05:12.5700000');
INSERT INTO dbo.[TicketParts] ([TicketPartId], [TicketId], [PartId], [Quantity], [UnitPrice], [Note], [CreatedAt]) VALUES (2, 2, 1, 1, 5600000.00, N'MÃ n hÃ¬nh iPhone 14 Pro Max Super Retina XDR Zin mÃ¡y', '2026-10-24T09:05:12.5700000');
INSERT INTO dbo.[TicketParts] ([TicketPartId], [TicketId], [PartId], [Quantity], [UnitPrice], [Note], [CreatedAt]) VALUES (3, 5, 9, 1, 2250000.00, N'á»” cá»©ng SSD Samsung 980 PRO 1TB PCIe NVMe 4.0', '2026-10-21T09:05:12.5700000');
INSERT INTO dbo.[TicketParts] ([TicketPartId], [TicketId], [PartId], [Quantity], [UnitPrice], [Note], [CreatedAt]) VALUES (4, 7, 14, 1, 620000.00, N'Cá»¥m chÃ¢n sáº¡c Type-C iPad/iPhone bÃ³c mÃ¡y', '2026-10-22T09:05:12.5700000');
INSERT INTO dbo.[TicketParts] ([TicketPartId], [TicketId], [PartId], [Quantity], [UnitPrice], [Note], [CreatedAt]) VALUES (5, 9, 5, 1, 750000.00, N'Pin iPhone 13/14 Pisen dung lÆ°á»£ng cao', '2026-10-23T09:05:12.5700000');
INSERT INTO dbo.[TicketParts] ([TicketPartId], [TicketId], [PartId], [Quantity], [UnitPrice], [Note], [CreatedAt]) VALUES (6, 10, 12, 1, 890000.00, N'RAM Laptop Kingston Fury DDR4 16GB 3200MHz', '2026-10-24T09:05:12.5700000');
INSERT INTO dbo.[TicketParts] ([TicketPartId], [TicketId], [PartId], [Quantity], [UnitPrice], [Note], [CreatedAt]) VALUES (7, 13, 16, 1, 180000.00, N'Keo táº£n nhiá»‡t gá»‘m Kryonaut cho Asus TUF', '2026-10-24T10:01:02.7130000');
INSERT INTO dbo.[TicketParts] ([TicketPartId], [TicketId], [PartId], [Quantity], [UnitPrice], [Note], [CreatedAt]) VALUES (8, 14, 1, 1, 3200000.00, N'MÃ n hÃ¬nh OLED iPhone 12 Pro zin', '2026-10-22T10:01:02.7130000');
INSERT INTO dbo.[TicketParts] ([TicketPartId], [TicketId], [PartId], [Quantity], [UnitPrice], [Note], [CreatedAt]) VALUES (9, 15, 9, 1, 2250000.00, N'SSD Samsung 980 PRO 1TB PCIe NVMe', '2026-10-24T10:01:02.7130000');
INSERT INTO dbo.[TicketParts] ([TicketPartId], [TicketId], [PartId], [Quantity], [UnitPrice], [Note], [CreatedAt]) VALUES (10, 19, 15, 1, 950000.00, N'BÃ n phÃ­m laptop led cÃ³ Ä‘Ã¨n ná»n', '2026-10-24T10:01:02.7130000');
INSERT INTO dbo.[TicketParts] ([TicketPartId], [TicketId], [PartId], [Quantity], [UnitPrice], [Note], [CreatedAt]) VALUES (11, 20, 18, 1, 280000.00, N'Máº·t kÃ­nh camera Sapphire cao cáº¥p', '2026-10-24T10:01:02.7130000');
INSERT INTO dbo.[TicketParts] ([TicketPartId], [TicketId], [PartId], [Quantity], [UnitPrice], [Note], [CreatedAt]) VALUES (12, 23, 5, 1, 580000.00, N'Pin Pisen chÃ­nh hÃ£ng iPhone 11', '2026-10-23T10:01:02.7130000');
INSERT INTO dbo.[TicketParts] ([TicketPartId], [TicketId], [PartId], [Quantity], [UnitPrice], [Note], [CreatedAt]) VALUES (13, 24, 10, 1, 950000.00, N'SSD Kingston NV2 512GB M.2 PCIe', '2026-10-24T10:01:02.7130000');
SET IDENTITY_INSERT dbo.[TicketParts] OFF;
GO

-- TicketStatusHistory: 82 dong
SET IDENTITY_INSERT dbo.[TicketStatusHistory] ON;
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (1, 1, NULL, N'RECEIVED', 2, N'Tiếp nhận máy Dell XPS 15 từ khách Nguyễn Thành Nam tại quầy', '2026-10-22T09:05:12.5700000');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (2, 1, N'RECEIVED', N'DIAGNOSING', 3, N'Kỹ thuật viên Phạm Văn Kỹ Thuật nhận máy đo nhiệt độ tải cao', '2026-10-22T09:05:12.5700000');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (3, 1, N'DIAGNOSING', N'COMPLETED', 3, N'Hoàn thành vệ sinh tra keo tản nhiệt Kryonaut, test nhiệt độ mát 72 độ C', '2026-10-23T09:05:12.5700000');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (4, 2, NULL, N'RECEIVED', 2, N'Tiếp nhận iPhone 14 Pro Max vỡ kính mép bàn', '2026-10-23T09:05:12.5700000');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (5, 2, N'RECEIVED', N'REPAIRING', 4, N'KTV Nguyễn Đại Kỳ tiến hành thay màn hình OLED Zin bóc máy', '2026-10-24T09:05:12.5700000');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (6, 3, NULL, N'RECEIVED', 2, N'Tiếp nhận MacBook Pro 14 không lên nguồn', '2026-10-24T09:05:12.5700000');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (7, 3, N'RECEIVED', N'DIAGNOSING', 3, N'Đo đạc sơ đồ boardview và dò nhiệt FLIR tụ nguồn PPBUS_AON', '2026-10-25T03:05:12.5700000');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (8, 4, NULL, N'RECEIVED', 2, N'Tiếp nhận Galaxy S23 Ultra pin phồng', '2026-10-24T09:05:12.5700000');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (9, 4, N'RECEIVED', N'WAITING_CONFIRM', 2, N'Gửi báo giá thay pin 780.000đ qua Zalo cho khách Võ Hoài Thương', '2026-10-25T05:05:12.5700000');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (10, 5, NULL, N'RECEIVED', 2, N'Tiếp nhận PC Gaming lỗi màn hình xanh BSOD', '2026-10-20T09:05:12.5700000');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (11, 5, N'RECEIVED', N'COMPLETED', 3, N'Lắp đặt SSD Samsung 980 PRO 1TB và cài Windows 11', '2026-10-21T09:05:12.5700000');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (12, 5, N'COMPLETED', N'DELIVERED', 2, N'Khách kiểm tra máy ưng ý, thanh toán chuyển khoản và nhận máy', '2026-10-21T09:05:12.5700000');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (13, 6, NULL, N'RECEIVED', 2, N'Tiếp nhận máy Asus ROG Zephyrus G14 gãy cánh quạt', '2026-10-25T09:05:12.5700000');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (14, 7, NULL, N'RECEIVED', 2, N'Tiếp nhận iPad Pro 11 hỏng chân sạc Type-C', '2026-10-21T09:05:12.5700000');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (15, 7, N'RECEIVED', N'DELIVERED', 2, N'Bàn giao iPad Pro sau khi thay cáp sạc Type-C chuẩn PD', '2026-10-22T09:05:12.5700000');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (16, 8, NULL, N'RECEIVED', 2, N'Tiếp nhận ThinkPad X1 kẹt phím cà phê', '2026-10-25T09:05:12.5700000');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (17, 9, NULL, N'DELIVERED', 2, N'Đã hoàn thành thay pin iPhone 13 và giao khách', '2026-10-23T09:05:12.5700000');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (18, 10, NULL, N'DELIVERED', 2, N'Đã nâng cấp RAM Kingston và thanh toán tiền mặt', '2026-10-24T09:05:12.5700000');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (19, 11, NULL, N'RECEIVED', 2, N'Tiếp nhận iPhone 15 Pro Max vỡ kính mép', '2026-10-24T10:01:02.7160000');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (20, 11, N'RECEIVED', N'WAITING_CONFIRM', 2, N'Báo giá ép kính 700.000đ cho khách qua điện thoại', '2026-10-25T05:01:02.7160000');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (21, 12, NULL, N'RECEIVED', 2, N'Tiếp nhận MacBook Air M1 chai pin', '2026-10-24T10:01:02.7160000');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (22, 12, N'RECEIVED', N'REPAIRING', 3, N'Tiến hành tháo cụm pin cũ thay thế pin mới', '2026-10-25T02:01:02.7160000');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (23, 13, NULL, N'RECEIVED', 2, N'Tiếp nhận Asus TUF nhiệt độ cao', '2026-10-23T10:01:02.7160000');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (24, 13, N'RECEIVED', N'COMPLETED', 3, N'Vệ sinh tra keo Kryonaut mát 74 độ C', '2026-10-24T10:01:02.7160000');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (25, 14, NULL, N'RECEIVED', 2, N'Tiếp nhận iPhone 12 Pro sọc màn hình', '2026-10-21T10:01:02.7160000');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (26, 14, N'RECEIVED', N'COMPLETED', 4, N'Thay màn hình OLED hoàn tất test OK', '2026-10-22T10:01:02.7160000');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (27, 14, N'COMPLETED', N'DELIVERED', 2, N'Khách đã thanh toán nhận máy', '2026-10-22T10:01:02.7160000');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (28, 15, NULL, N'RECEIVED', 2, N'Tiếp nhận PC Workstation nâng cấp SSD', '2026-10-24T10:01:02.7160000');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (29, 15, N'RECEIVED', N'COMPLETED', 3, N'Lắp đặt SSD Samsung 980 PRO 1TB', '2026-10-25T10:01:02.7160000');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (30, 16, NULL, N'RECEIVED', 2, N'Tiếp nhận ThinkPad T14 nhiễm virus', '2026-10-22T10:01:02.7160000');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (31, 16, N'RECEIVED', N'DELIVERED', 2, N'Cài đặt Windows 11 hoàn tất, bàn giao khách', '2026-10-23T10:01:02.7160000');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (32, 17, NULL, N'RECEIVED', 2, N'Tiếp nhận Z Fold5 chập màn hình trong', '2026-10-25T10:01:02.7160000');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (33, 17, N'RECEIVED', N'DIAGNOSING', 4, N'KTV đang đo cáp gập bản lề', '2026-10-25T10:01:02.7160000');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (34, 18, NULL, N'RECEIVED', 2, N'Tiếp nhận iPad Air 5 gãy chân Type-C', '2026-10-25T10:01:02.7160000');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (35, 19, NULL, N'RECEIVED', 2, N'Tiếp nhận Dell Inspiron liệt phím', '2026-10-24T10:01:02.7160000');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (36, 19, N'RECEIVED', N'COMPLETED', 3, N'Thay bàn phím mới hoàn tất', '2026-10-25T10:01:02.7160000');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (37, 20, NULL, N'RECEIVED', 2, N'Tiếp nhận Xiaomi 13 Pro nứt kính camera', '2026-10-23T10:01:02.7160000');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (38, 20, N'RECEIVED', N'DELIVERED', 2, N'Thay kính Sapphire Leica và bàn giao', '2026-10-24T10:01:02.7160000');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (39, 21, NULL, N'RECEIVED', 2, N'Tiếp nhận MacBook Pro 16 M3 Max', '2026-10-25T10:01:02.7160000');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (40, 21, N'RECEIVED', N'REPAIRING', 3, N'Đang vệ sinh buồng hơi tản nhiệt', '2026-10-25T10:01:02.7160000');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (41, 22, NULL, N'RECEIVED', 2, N'Tiếp nhận Acer Nitro 5 cứu dữ liệu', '2026-10-25T10:01:02.7160000');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (42, 22, N'RECEIVED', N'DIAGNOSING', 3, N'Đang đo mạch NAND SSD', '2026-10-25T10:01:02.7160000');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (43, 23, NULL, N'RECEIVED', 2, N'Tiếp nhận iPhone 11 thay pin', '2026-10-22T10:01:02.7160000');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (44, 23, N'RECEIVED', N'DELIVERED', 2, N'Đã thay pin Pisen dung lượng cao', '2026-10-23T10:01:02.7160000');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (45, 24, NULL, N'RECEIVED', 2, N'Tiếp nhận HP Pavilion nâng cấp SSD', '2026-10-23T10:01:02.7160000');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (46, 24, N'RECEIVED', N'DELIVERED', 2, N'Đã nâng cấp SSD Kingston 512GB', '2026-10-24T10:01:02.7160000');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (47, 25, NULL, N'RECEIVED', 2, N'Tiếp nhận iMac 24 hỏng màn hình', '2026-10-22T10:01:02.7160000');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (48, 25, N'RECEIVED', N'CANCELLED', 2, N'Khách hủy sửa chữa do chi phí linh kiện cao', '2026-10-24T10:01:02.7160000');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (49, 26, N'WAITING_CONFIRM', N'DIAGNOSING', 3, N'Cap nhat trang thai tu WAITING_CONFIRM sang DIAGNOSING', '2026-10-25T10:02:44.2160000');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (50, 26, N'DIAGNOSING', N'WAITING_CONFIRM', 2, N'Cap nhat trang thai tu DIAGNOSING sang WAITING_CONFIRM', '2026-10-25T10:02:44.2580000');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (51, 26, N'WAITING_CONFIRM', N'REPAIRING', 3, N'Cap nhat trang thai tu WAITING_CONFIRM sang REPAIRING', '2026-10-25T10:02:44.2650000');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (52, 26, N'REPAIRING', N'COMPLETED', 3, N'Cap nhat trang thai tu REPAIRING sang COMPLETED', '2026-10-25T10:02:44.3800000');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (53, 26, N'COMPLETED', N'DELIVERED', 2, N'Cap nhat trang thai tu COMPLETED sang DELIVERED', '2026-10-25T10:02:44.5330000');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (54, 27, N'WAITING_CONFIRM', N'DIAGNOSING', 3, N'Cap nhat trang thai tu WAITING_CONFIRM sang DIAGNOSING', '2026-10-25T10:03:58.2120000');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (55, 27, N'DIAGNOSING', N'WAITING_CONFIRM', 2, N'Cap nhat trang thai tu DIAGNOSING sang WAITING_CONFIRM', '2026-10-25T10:03:58.2660000');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (56, 27, N'WAITING_CONFIRM', N'REPAIRING', 3, N'Cap nhat trang thai tu WAITING_CONFIRM sang REPAIRING', '2026-10-25T10:03:58.2810000');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (57, 27, N'REPAIRING', N'COMPLETED', 3, N'Cap nhat trang thai tu REPAIRING sang COMPLETED', '2026-10-25T10:03:58.4220000');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (58, 27, N'COMPLETED', N'DELIVERED', 2, N'Cap nhat trang thai tu COMPLETED sang DELIVERED', '2026-10-25T10:03:58.6970000');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (59, 28, N'WAITING_CONFIRM', N'DIAGNOSING', 3, N'Cap nhat trang thai tu WAITING_CONFIRM sang DIAGNOSING', '2026-10-25T10:04:38.0280000');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (60, 28, N'DIAGNOSING', N'WAITING_CONFIRM', 2, N'Cap nhat trang thai tu DIAGNOSING sang WAITING_CONFIRM', '2026-10-25T10:04:38.0540000');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (61, 28, N'WAITING_CONFIRM', N'REPAIRING', 3, N'Cap nhat trang thai tu WAITING_CONFIRM sang REPAIRING', '2026-10-25T10:04:38.0690000');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (62, 28, N'REPAIRING', N'COMPLETED', 3, N'Cap nhat trang thai tu REPAIRING sang COMPLETED', '2026-10-25T10:04:38.0980000');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (63, 28, N'COMPLETED', N'COMPLETED', 2, N'Khach hang da thanh toan hoa don HD2026100015 qua TRANSFER.', '2026-10-25T10:04:38.1330000');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (64, 28, N'COMPLETED', N'DELIVERED', 2, N'Cap nhat trang thai tu COMPLETED sang DELIVERED', '2026-10-25T10:04:38.1590000');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (65, 29, N'WAITING_CONFIRM', N'DIAGNOSING', 3, N'Cap nhat trang thai tu WAITING_CONFIRM sang DIAGNOSING', '2026-10-26T07:50:08.5435418');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (66, 29, N'DIAGNOSING', N'WAITING_CONFIRM', 2, N'Cap nhat trang thai tu DIAGNOSING sang WAITING_CONFIRM', '2026-10-26T07:50:08.5815749');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (67, 29, N'WAITING_CONFIRM', N'REPAIRING', 3, N'Cap nhat trang thai tu WAITING_CONFIRM sang REPAIRING', '2026-10-26T07:50:08.5972980');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (68, 29, N'REPAIRING', N'COMPLETED', 3, N'Cap nhat trang thai tu REPAIRING sang COMPLETED', '2026-10-26T07:50:08.7191604');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (69, 29, N'COMPLETED', N'COMPLETED', 2, N'Khach hang da thanh toan hoa don HD2026100016 qua TRANSFER.', '2026-10-26T07:50:08.8200909');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (70, 29, N'COMPLETED', N'DELIVERED', 2, N'Cap nhat trang thai tu COMPLETED sang DELIVERED', '2026-10-26T07:50:08.8880232');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (71, 30, N'WAITING_CONFIRM', N'DIAGNOSING', 3, N'Cap nhat trang thai tu WAITING_CONFIRM sang DIAGNOSING', '2026-10-26T07:51:27.8078707');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (72, 30, N'DIAGNOSING', N'WAITING_CONFIRM', 2, N'Cap nhat trang thai tu DIAGNOSING sang WAITING_CONFIRM', '2026-10-26T07:51:27.8296084');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (73, 30, N'WAITING_CONFIRM', N'REPAIRING', 3, N'Cap nhat trang thai tu WAITING_CONFIRM sang REPAIRING', '2026-10-26T07:51:27.8452559');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (74, 30, N'REPAIRING', N'COMPLETED', 3, N'Cap nhat trang thai tu REPAIRING sang COMPLETED', '2026-10-26T07:51:27.8904887');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (75, 30, N'COMPLETED', N'COMPLETED', 2, N'Khach hang da thanh toan hoa don HD2026100017 qua TRANSFER.', '2026-10-26T07:51:27.9419766');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (76, 30, N'COMPLETED', N'DELIVERED', 2, N'Cap nhat trang thai tu COMPLETED sang DELIVERED', '2026-10-26T07:51:27.9670292');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (77, 31, N'WAITING_CONFIRM', N'DIAGNOSING', 3, N'Cap nhat trang thai tu WAITING_CONFIRM sang DIAGNOSING', '2026-10-26T09:22:16.7321820');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (78, 31, N'DIAGNOSING', N'WAITING_CONFIRM', 2, N'Cap nhat trang thai tu DIAGNOSING sang WAITING_CONFIRM', '2026-10-26T09:22:16.7526172');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (79, 31, N'WAITING_CONFIRM', N'REPAIRING', 3, N'Cap nhat trang thai tu WAITING_CONFIRM sang REPAIRING', '2026-10-26T09:22:16.7680084');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (80, 31, N'REPAIRING', N'COMPLETED', 3, N'Cap nhat trang thai tu REPAIRING sang COMPLETED', '2026-10-26T09:22:16.8142918');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (81, 31, N'COMPLETED', N'COMPLETED', 2, N'Khach hang da thanh toan hoa don HD2026100018 qua TRANSFER.', '2026-10-26T09:22:16.8627831');
INSERT INTO dbo.[TicketStatusHistory] ([HistoryId], [TicketId], [FromStatus], [ToStatus], [ChangedByUserId], [Note], [ChangedAt]) VALUES (82, 31, N'COMPLETED', N'DELIVERED', 2, N'Cap nhat trang thai tu COMPLETED sang DELIVERED', '2026-10-26T09:22:16.8881649');
SET IDENTITY_INSERT dbo.[TicketStatusHistory] OFF;
GO

-- Warranties: 16 dong
SET IDENTITY_INSERT dbo.[Warranties] ON;
INSERT INTO dbo.[Warranties] ([WarrantyId], [WarrantyCode], [TicketId], [CustomerId], [DeviceId], [StartDate], [EndDate], [WarrantyDays], [Scope], [Status], [VoidReason], [CreatedAt]) VALUES (1, N'BH2026100001', 5, 5, 5, '2026-10-21', '2027-10-21', 365, N'Bảo hành chính hãng 1 đổi 1 trong 12 tháng cho ổ cứng SSD Samsung 980 PRO 1TB NVMe PCIe 4.0.', N'ACTIVE', NULL, '2026-10-21T09:05:12.5700000');
INSERT INTO dbo.[Warranties] ([WarrantyId], [WarrantyCode], [TicketId], [CustomerId], [DeviceId], [StartDate], [EndDate], [WarrantyDays], [Scope], [Status], [VoidReason], [CreatedAt]) VALUES (2, N'BH2026100002', 7, 7, 7, '2026-10-22', '2027-01-20', 90, N'Bảo hành 03 tháng cụm chân sạc USB-C và mic thoại iPad Pro 11 M1.', N'ACTIVE', NULL, '2026-10-22T09:05:12.5700000');
INSERT INTO dbo.[Warranties] ([WarrantyId], [WarrantyCode], [TicketId], [CustomerId], [DeviceId], [StartDate], [EndDate], [WarrantyDays], [Scope], [Status], [VoidReason], [CreatedAt]) VALUES (3, N'BH2026100003', 1, 1, 1, '2026-10-23', '2026-11-22', 30, N'Bảo hành 30 ngày hiệu năng giải nhiệt keo tản nhiệt gốm Thermal Grizzly Kryonaut trên laptop Dell XPS 15.', N'ACTIVE', NULL, '2026-10-23T09:05:12.5700000');
INSERT INTO dbo.[Warranties] ([WarrantyId], [WarrantyCode], [TicketId], [CustomerId], [DeviceId], [StartDate], [EndDate], [WarrantyDays], [Scope], [Status], [VoidReason], [CreatedAt]) VALUES (4, N'BH2026100004', 9, 9, 9, '2026-10-23', '2027-04-21', 180, N'Bảo hành 06 tháng pin Pisen dung lượng cao chính hãng iPhone 13 (chai quá 20% đổi mới).', N'ACTIVE', NULL, '2026-10-23T09:05:12.5700000');
INSERT INTO dbo.[Warranties] ([WarrantyId], [WarrantyCode], [TicketId], [CustomerId], [DeviceId], [StartDate], [EndDate], [WarrantyDays], [Scope], [Status], [VoidReason], [CreatedAt]) VALUES (5, N'BH2026100005', 10, 10, 10, '2026-10-24', '2027-10-24', 365, N'Bảo hành 12 tháng thanh RAM Laptop Kingston Fury DDR4 16GB 3200MHz.', N'ACTIVE', NULL, '2026-10-24T09:05:12.5700000');
INSERT INTO dbo.[Warranties] ([WarrantyId], [WarrantyCode], [TicketId], [CustomerId], [DeviceId], [StartDate], [EndDate], [WarrantyDays], [Scope], [Status], [VoidReason], [CreatedAt]) VALUES (6, N'BH2026100006', 14, 14, 14, '2026-10-22', '2027-01-20', 90, N'Bảo hành 03 tháng màn hình OLED Super Retina iPhone 12 Pro (bao sọc, đơ cảm ứng).', N'ACTIVE', NULL, '2026-10-22T10:01:02.7200000');
INSERT INTO dbo.[Warranties] ([WarrantyId], [WarrantyCode], [TicketId], [CustomerId], [DeviceId], [StartDate], [EndDate], [WarrantyDays], [Scope], [Status], [VoidReason], [CreatedAt]) VALUES (7, N'BH2026100007', 16, 16, 16, '2026-10-23', '2026-11-22', 30, N'Hỗ trợ kỹ thuật phần mềm và kích hoạt bản quyền Windows 11 Pro 30 ngày.', N'ACTIVE', NULL, '2026-10-23T10:01:02.7200000');
INSERT INTO dbo.[Warranties] ([WarrantyId], [WarrantyCode], [TicketId], [CustomerId], [DeviceId], [StartDate], [EndDate], [WarrantyDays], [Scope], [Status], [VoidReason], [CreatedAt]) VALUES (8, N'BH2026100008', 20, 20, 20, '2026-10-24', '2027-01-22', 90, N'Bảo hành mặt kính camera Sapphire Leica 03 tháng chống bụi, bong keo.', N'ACTIVE', NULL, '2026-10-24T10:01:02.7200000');
INSERT INTO dbo.[Warranties] ([WarrantyId], [WarrantyCode], [TicketId], [CustomerId], [DeviceId], [StartDate], [EndDate], [WarrantyDays], [Scope], [Status], [VoidReason], [CreatedAt]) VALUES (9, N'BH2026100009', 23, 23, 23, '2026-10-23', '2027-04-21', 180, N'Bảo hành 06 tháng pin Pisen iPhone 11 dung lượng cao, chai quá 20% đổi viên mới.', N'ACTIVE', NULL, '2026-10-23T10:01:02.7200000');
INSERT INTO dbo.[Warranties] ([WarrantyId], [WarrantyCode], [TicketId], [CustomerId], [DeviceId], [StartDate], [EndDate], [WarrantyDays], [Scope], [Status], [VoidReason], [CreatedAt]) VALUES (10, N'BH2026100010', 24, 24, 24, '2026-10-24', '2027-10-24', 365, N'Bảo hành 1 đổi 1 trong 365 ngày đối với SSD Kingston NV2 512GB chính hãng SPC.', N'ACTIVE', NULL, '2026-10-24T10:01:02.7200000');
INSERT INTO dbo.[Warranties] ([WarrantyId], [WarrantyCode], [TicketId], [CustomerId], [DeviceId], [StartDate], [EndDate], [WarrantyDays], [Scope], [Status], [VoidReason], [CreatedAt]) VALUES (11, N'BH2026100011', 13, 13, 13, '2026-09-20', '2026-10-20', 30, N'Bảo hành 30 ngày keo tản nhiệt gốm Kryonaut cho laptop Asus TUF (đã hết hạn bảo hành).', N'EXPIRED', NULL, '2026-09-20T10:01:02.7200000');
INSERT INTO dbo.[Warranties] ([WarrantyId], [WarrantyCode], [TicketId], [CustomerId], [DeviceId], [StartDate], [EndDate], [WarrantyDays], [Scope], [Status], [VoidReason], [CreatedAt]) VALUES (12, N'BH2026100012', 10, 10, 10, '2026-10-24', '2027-10-24', 365, N'Bảo hành 12 tháng ổ cứng SSD gắn ngoài.', N'ACTIVE', NULL, '2026-10-24T10:01:02.7200000');
INSERT INTO dbo.[Warranties] ([WarrantyId], [WarrantyCode], [TicketId], [CustomerId], [DeviceId], [StartDate], [EndDate], [WarrantyDays], [Scope], [Status], [VoidReason], [CreatedAt]) VALUES (13, N'BH2026100013', 28, 29, 31, '2026-10-25', '2026-11-24', 30, N'Bao hanh dich vu Vệ sinh tra keo tản nhiệt gốm máy tính & laptop', N'ACTIVE', NULL, '2026-10-25T10:04:38.1340000');
INSERT INTO dbo.[Warranties] ([WarrantyId], [WarrantyCode], [TicketId], [CustomerId], [DeviceId], [StartDate], [EndDate], [WarrantyDays], [Scope], [Status], [VoidReason], [CreatedAt]) VALUES (14, N'BH2026100014', 29, 30, 32, '2026-10-26', '2026-11-25', 30, N'Bao hanh dich vu Vệ sinh tra keo tản nhiệt gốm máy tính & laptop', N'ACTIVE', NULL, '2026-10-26T07:50:08.8325409');
INSERT INTO dbo.[Warranties] ([WarrantyId], [WarrantyCode], [TicketId], [CustomerId], [DeviceId], [StartDate], [EndDate], [WarrantyDays], [Scope], [Status], [VoidReason], [CreatedAt]) VALUES (15, N'BH2026100015', 30, 31, 33, '2026-10-26', '2026-11-25', 30, N'Bao hanh dich vu Vệ sinh tra keo tản nhiệt gốm máy tính & laptop', N'ACTIVE', NULL, '2026-10-26T07:51:27.9456053');
INSERT INTO dbo.[Warranties] ([WarrantyId], [WarrantyCode], [TicketId], [CustomerId], [DeviceId], [StartDate], [EndDate], [WarrantyDays], [Scope], [Status], [VoidReason], [CreatedAt]) VALUES (16, N'BH2026100016', 31, 32, 34, '2026-10-26', '2026-11-25', 30, N'Bao hanh dich vu Vệ sinh tra keo tản nhiệt gốm máy tính & laptop', N'ACTIVE', NULL, '2026-10-26T09:22:16.8660766');
SET IDENTITY_INSERT dbo.[Warranties] OFF;
GO

-- ===== VIEW / STORED PROCEDURE / TRIGGER =====

-- =========================================================================
-- PHẦN 2: VIEW TỔNG HỢP DOANH THU THEO LOẠI DỊCH VỤ SỬA CHỮA
-- Mục đích: Xác định dịch vụ sửa chữa chủ lực, mang lại doanh thu cao nhất,
--           tỷ lệ linh kiện kèm theo và tỷ trọng đóng góp doanh thu của từng dịch vụ.
-- =========================================================================
CREATE   VIEW dbo.v_BaoCaoDoanhThuTheoDichVu
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
    
    -- Doanh thu tiền công từ dịch vụ
    ISNULL(SUM(CASE WHEN i.PaymentStatus = 'PAID' THEN i.LaborCost ELSE 0 END), 0)
                                                                AS DoanhThuTienCong,
    -- Doanh thu linh kiện gắn liền dịch vụ
    ISNULL(SUM(CASE WHEN i.PaymentStatus = 'PAID' THEN i.PartsCost ELSE 0 END), 0)
                                                                AS DoanhThuLinhKien,
    -- Tổng doanh thu của loại dịch vụ
    ISNULL(SUM(CASE WHEN i.PaymentStatus = 'PAID' THEN i.TotalAmount ELSE 0 END), 0)
                                                                AS TongDoanhThuDichVu,

    -- Giá trị đơn hàng trung bình của loại dịch vụ
    CASE 
        WHEN SUM(CASE WHEN i.PaymentStatus = 'PAID' THEN 1 ELSE 0 END) > 0 
        THEN CAST(SUM(CASE WHEN i.PaymentStatus = 'PAID' THEN i.TotalAmount ELSE 0 END) 
             / SUM(CASE WHEN i.PaymentStatus = 'PAID' THEN 1 ELSE 0 END) AS DECIMAL(18,2))
        ELSE 0 
    END                                                         AS DoanhThuTrungBinhMoiLuot,

    -- Tỷ trọng doanh thu dịch vụ trên tổng doanh thu toàn cửa hàng (%)
    CAST(
        CASE 
            WHEN (SELECT TongToanCuaHang FROM TongDoanhThuHeThong) > 0 
            THEN (ISNULL(SUM(CASE WHEN i.PaymentStatus = 'PAID' THEN i.TotalAmount ELSE 0 END), 0) 
                  / (SELECT TongToanCuaHang FROM TongDoanhThuHeThong)) * 100.0
            ELSE 0.0 
        END AS DECIMAL(5,2)
    )                                                           AS TyTrongDongGopPhanTram
FROM dbo.ServiceTypes s
LEFT JOIN dbo.RepairTickets t ON t.ServiceTypeId = s.ServiceTypeId
LEFT JOIN dbo.Invoices i      ON i.TicketId = t.TicketId
WHERE s.IsActive = 1
GROUP BY s.ServiceTypeId, s.ServiceCode, s.ServiceName, s.LaborCost, s.WarrantyDays;
GO

-- =========================================================================
-- PHẦN 1: VIEW TỔNG HỢP DOANH THU VÀ HIỆU SUẤT THEO THỢ (KỸ THUẬT VIÊN)
-- Mục đích: Đánh giá tổng tiền công, tiền linh kiện và tổng doanh thu thực tế
--           do từng kỹ thuật viên mang về (chỉ tính hóa đơn đã thanh toán - PAID).
-- =========================================================================
CREATE   VIEW dbo.v_BaoCaoDoanhThuTheoTho
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
    
    -- Doanh thu tiền công sửa chữa thực thu
    ISNULL(SUM(CASE WHEN i.PaymentStatus = 'PAID' THEN i.LaborCost ELSE 0 END), 0)
                                                                AS DoanhThuTienCong,
    -- Doanh thu linh kiện thay thế kèm phiếu thực thu
    ISNULL(SUM(CASE WHEN i.PaymentStatus = 'PAID' THEN i.PartsCost ELSE 0 END), 0)
                                                                AS DoanhThuLinhKien,
    -- Tổng chiết khấu giảm giá
    ISNULL(SUM(CASE WHEN i.PaymentStatus = 'PAID' THEN i.DiscountAmount ELSE 0 END), 0)
                                                                AS TongTienGiamGia,
    -- Tổng doanh thu thực tế thu về cho cửa hàng
    ISNULL(SUM(CASE WHEN i.PaymentStatus = 'PAID' THEN i.TotalAmount ELSE 0 END), 0)
                                                                AS TongDoanhThuThucThu,
                                                                
    -- Giá trị trung bình mỗi phiếu sửa chữa đã thanh toán
    CASE 
        WHEN SUM(CASE WHEN i.PaymentStatus = 'PAID' THEN 1 ELSE 0 END) > 0 
        THEN CAST(SUM(CASE WHEN i.PaymentStatus = 'PAID' THEN i.TotalAmount ELSE 0 END) 
             / SUM(CASE WHEN i.PaymentStatus = 'PAID' THEN 1 ELSE 0 END) AS DECIMAL(18,2))
        ELSE 0 
    END                                                         AS DoanhThuTrungBinhMoiPhieu,

    -- Tỷ lệ hoàn thành phiếu (%)
    CAST(
        CASE 
            WHEN COUNT(t.TicketId) > 0 
            THEN (SUM(CASE WHEN t.Status IN ('COMPLETED', 'DELIVERED', 'PAID') THEN 1.0 ELSE 0.0 END) / COUNT(t.TicketId)) * 100.0
            ELSE 0.0 
        END AS DECIMAL(5,2)
    )                                                           AS TyLeHoanThanhPhanTram,

    -- Thời gian xử lý trung bình từ lúc tiếp nhận đến khi hoàn thành (tính theo giờ)
    CAST(
        AVG(CASE 
            WHEN t.CompletedAt IS NOT NULL AND t.ReceivedAt IS NOT NULL 
            THEN DATEDIFF(MINUTE, t.ReceivedAt, t.CompletedAt) / 60.0 
            ELSE NULL 
        END) AS DECIMAL(6,2)
    )                                                           AS ThoiGianXuLyTrungBinhGio,

    -- Số phiếu sửa bảo hành phát sinh (chỉ số chất lượng tay nghề)
    SUM(CASE WHEN t.IsWarrantyRepair = 1 THEN 1 ELSE 0 END)     AS SoPhieuBaoHanhLai
FROM dbo.Users u
LEFT JOIN dbo.RepairTickets t ON t.TechnicianUserId = u.UserId
LEFT JOIN dbo.Invoices i      ON i.TicketId = t.TicketId
WHERE u.RoleId = (SELECT RoleId FROM dbo.Roles WHERE RoleCode = 'TECHNICIAN')
  AND u.IsActive = 1
GROUP BY u.UserId, u.Username, u.FullName, u.Phone;
GO

-- =========================================================================
-- PHẦN 4: BÁO CÁO HOA HỒNG & LƯƠNG HIỆU QUẢ CỦA KỸ THUẬT VIÊN (KPI COMMISSION)
-- Cơ chế cửa hàng:
--  - Hoa hồng tiền công: 20% doanh thu tiền công (LaborCost) của các phiếu đã thu tiền.
--  - Hoa hồng linh kiện: 5% doanh thu linh kiện bán ra theo phiếu.
--  - Trừ phạt bảo hành lại: Phạt 50.000 VNĐ cho mỗi phiếu phải làm bảo hành lại do lỗi kỹ thuật.
-- =========================================================================
CREATE   VIEW dbo.v_BaoCaoHoaHongKyThuatVien
AS
SELECT 
    u.UserId                                                    AS MaTho,
    u.FullName                                                  AS TenKyThuatVien,
    SUM(CASE WHEN i.PaymentStatus = 'PAID' THEN 1 ELSE 0 END)   AS SoPhieuDaThanhToan,
    ISNULL(SUM(CASE WHEN i.PaymentStatus = 'PAID' THEN i.LaborCost ELSE 0 END), 0)
                                                                AS DoanhThuTienCong,
    ISNULL(SUM(CASE WHEN i.PaymentStatus = 'PAID' THEN i.PartsCost ELSE 0 END), 0)
                                                                AS DoanhThuLinhKien,
    -- Hoa hồng tiền công 20%
    CAST(ISNULL(SUM(CASE WHEN i.PaymentStatus = 'PAID' THEN i.LaborCost ELSE 0 END), 0) * 0.20 AS DECIMAL(18,2))
                                                                AS ThuongTienCong20Pct,
    -- Hoa hồng linh kiện 5%
    CAST(ISNULL(SUM(CASE WHEN i.PaymentStatus = 'PAID' THEN i.PartsCost ELSE 0 END), 0) * 0.05 AS DECIMAL(18,2))
                                                                AS ThuongLinhKien5Pct,
    -- Số phiếu bảo hành lại
    SUM(CASE WHEN t.IsWarrantyRepair = 1 THEN 1 ELSE 0 END)     AS SoPhieuBaoHanhLai,
    -- Trừ phạt bảo hành
    CAST(SUM(CASE WHEN t.IsWarrantyRepair = 1 THEN 1 ELSE 0 END) * 50000 AS DECIMAL(18,2))
                                                                AS TienTruPhatBaoHanh,
    -- Tổng thu nhập hoa hồng thực nhận
    CAST(
        (ISNULL(SUM(CASE WHEN i.PaymentStatus = 'PAID' THEN i.LaborCost ELSE 0 END), 0) * 0.20)
        + (ISNULL(SUM(CASE WHEN i.PaymentStatus = 'PAID' THEN i.PartsCost ELSE 0 END), 0) * 0.05)
        - (SUM(CASE WHEN t.IsWarrantyRepair = 1 THEN 1 ELSE 0 END) * 50000)
        AS DECIMAL(18,2)
    )                                                           AS TongHoaHongThucNhan
FROM dbo.Users u
LEFT JOIN dbo.RepairTickets t ON t.TechnicianUserId = u.UserId
LEFT JOIN dbo.Invoices i      ON i.TicketId = t.TicketId
WHERE u.RoleId = (SELECT RoleId FROM dbo.Roles WHERE RoleCode = 'TECHNICIAN')
  AND u.IsActive = 1
GROUP BY u.UserId, u.FullName;
GO

-- =========================================================================
-- PHẦN 3: BÁO CÁO DOANH THU MA TRẬN KẾT HỢP (THỢ x DỊCH VỤ)
-- Mục đích: Phân tích thợ nào chuyên về mảng dịch vụ nào (Ví dụ: Thợ A chuyên
--           thay màn hình/pin, Thợ B chuyên sửa nguồn/mainboard).
-- =========================================================================
CREATE   VIEW dbo.v_BaoCaoMaTranThoVaDichVu
AS
SELECT 
    u.UserId                                                    AS MaTho,
    u.FullName                                                  AS TenKyThuatVien,
    s.ServiceTypeId                                             AS MaDichVu,
    s.ServiceName                                               AS TenLoaiDichVu,
    COUNT(t.TicketId)                                           AS SoLuongPhieuThucHien,
    SUM(CASE WHEN i.PaymentStatus = 'PAID' THEN 1 ELSE 0 END)   AS SoHoaDonDaThuTien,
    ISNULL(SUM(CASE WHEN i.PaymentStatus = 'PAID' THEN i.LaborCost ELSE 0 END), 0)
                                                                AS TienCongThucThu,
    ISNULL(SUM(CASE WHEN i.PaymentStatus = 'PAID' THEN i.PartsCost ELSE 0 END), 0)
                                                                AS TienLinhKienThucThu,
    ISNULL(SUM(CASE WHEN i.PaymentStatus = 'PAID' THEN i.TotalAmount ELSE 0 END), 0)
                                                                AS TongDoanhThu
FROM dbo.Users u
CROSS JOIN dbo.ServiceTypes s
LEFT JOIN dbo.RepairTickets t ON t.TechnicianUserId = u.UserId AND t.ServiceTypeId = s.ServiceTypeId
LEFT JOIN dbo.Invoices i      ON i.TicketId = t.TicketId
WHERE u.RoleId = (SELECT RoleId FROM dbo.Roles WHERE RoleCode = 'TECHNICIAN')
  AND u.IsActive = 1
  AND s.IsActive = 1
GROUP BY u.UserId, u.FullName, s.ServiceTypeId, s.ServiceName;
GO

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

-- =========================================================================
-- PHẦN 1: VIEW LINH KIỆN BÁN CHẠY NHẤT (HOT-SELLING PARTS)
-- Mục đích: Xác định top linh kiện tiêu thụ nhiều nhất để tối ưu dự trữ,
--           tăng biên lợi nhuận và sắp xếp kệ hàng ưu tiên.
-- =========================================================================
CREATE   VIEW dbo.v_LinhKienBanChay
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
    -- Số lượng xuất kho (bán ra)
    ISNULL(tt.TongXuat, 0)                                     AS TongSoLuongBan,
    -- Số lượng hoàn trả lại
    ISNULL(tt.TongHoanTra, 0)                                  AS SoLuongHoanTra,
    -- Số lượng bán thuần (sau hoàn trả)
    ISNULL(tt.TongXuat, 0) - ISNULL(tt.TongHoanTra, 0)        AS SoLuongBanThuan,
    -- Số lần được sử dụng trong phiếu sửa chữa
    ISNULL(tt.SoPhieuSuDung, 0)                                AS SoPhieuSuDung,
    -- Doanh thu linh kiện thực tế (từ TicketParts)
    ISNULL(
        (SELECT SUM(tp2.LineTotal)
         FROM dbo.TicketParts tp2
         JOIN dbo.RepairTickets t2 ON t2.TicketId = tp2.TicketId
         WHERE tp2.PartId = p.PartId
           AND t2.Status IN ('COMPLETED','DELIVERED','PAID')
        ), 0)                                                   AS DoanhThuThucTe,
    -- Ước tính lợi nhuận gộp (doanh thu bán - giá vốn)
    ISNULL(
        (SELECT SUM(tp2.LineTotal) - (SUM(tp2.Quantity) * p.PurchasePrice)
         FROM dbo.TicketParts tp2
         JOIN dbo.RepairTickets t2 ON t2.TicketId = tp2.TicketId
         WHERE tp2.PartId = p.PartId
           AND t2.Status IN ('COMPLETED','DELIVERED','PAID')
        ), 0)                                                   AS LoiNhuanGop,
    -- Tỷ trọng doanh thu linh kiện (%)
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
    p.SellingPrice                                              AS GiaBan,
    p.PurchasePrice                                             AS GiaNhap,
    -- Tỷ lệ lợi nhuận gộp trên mỗi đơn vị (%)
    CASE
        WHEN p.SellingPrice > 0
        THEN CAST((p.SellingPrice - p.PurchasePrice) / p.SellingPrice * 100.0 AS DECIMAL(5,2))
        ELSE 0
    END                                                         AS TyLeLoiNhuanGopPhanTram,
    -- Vòng quay hàng tồn kho (lần/tháng ước tính)
    CASE
        WHEN p.StockQuantity > 0
        THEN CAST(ISNULL(tt.TongXuat, 0) * 1.0 / NULLIF(p.StockQuantity, 0) AS DECIMAL(6,2))
        ELSE 0
    END                                                         AS VongQuayTonKho,
    tt.LanXuatGanNhat                                          AS LanBanGanNhat,
    -- Phân loại ABC (A: top 20% SKU = 80% doanh thu; B: 30%; C: 50%)
    CASE
        WHEN ISNULL(tt.TongXuat, 0) = 0 THEN N'C - Không có giao dịch'
        WHEN ISNULL(tt.TongXuat, 0) >= 20 THEN N'A - Bán chạy cao'
        WHEN ISNULL(tt.TongXuat, 0) >= 5  THEN N'B - Bán ổn định'
        ELSE N'C - Bán chậm'
    END                                                         AS PhanLoaiABC
FROM dbo.SpareParts p
LEFT JOIN dbo.SparePartCategories c  ON c.CategoryId = p.CategoryId
LEFT JOIN ThongKeTieuThu         tt  ON tt.PartId = p.PartId
WHERE p.IsActive = 1;
GO

-- =========================================================================
-- PHẦN 2: VIEW LINH KIỆN TỒN LÂU (SLOW-MOVING / DEAD STOCK)
-- Mục đích: Xác định linh kiện bị tồn kho lâu ngày không bán được,
--           đề xuất biện pháp: giảm giá, thanh lý hoặc điều phối sang kho khác.
-- =========================================================================
CREATE   VIEW dbo.v_LinhKienTonLau
AS
WITH LanXuatGanNhat AS (
    SELECT
        tx.PartId,
        MAX(CASE WHEN tx.TransactionType = 'OUT' THEN tx.TransactionAt END) AS LanBanGanNhat,
        MIN(CASE WHEN tx.TransactionType = 'IN'  THEN tx.TransactionAt END) AS LanNhapDauTien,
        SUM(CASE WHEN tx.TransactionType = 'OUT' THEN tx.Quantity ELSE 0 END) AS TongDaBan
    FROM dbo.StockTransactions tx
    GROUP BY tx.PartId
)
SELECT
    p.PartCode                                              AS MaLinhKien,
    p.PartName                                              AS TenLinhKien,
    c.CategoryName                                          AS NhomLinhKien,
    p.StockQuantity                                         AS TonKhoHienTai,
    p.MinStockLevel                                         AS TonToiThieu,
    p.SellingPrice                                          AS GiaBan,
    p.PurchasePrice                                         AS GiaNhap,
    -- Giá trị hàng tồn (chi phí vốn đang bị "treo")
    p.StockQuantity * p.PurchasePrice                       AS GiaTriTonKho,
    ISNULL(lx.LanNhapDauTien, p.CreatedAt)                AS NgayNhapDauTien,
    lx.LanBanGanNhat                                       AS LanBanGanNhat,
    ISNULL(lx.TongDaBan, 0)                               AS TongDaBan,
    -- Số ngày chưa bán (kể từ lần bán cuối hoặc ngày nhập đầu tiên)
    DATEDIFF(DAY,
        ISNULL(lx.LanBanGanNhat, ISNULL(lx.LanNhapDauTien, p.CreatedAt)),
        SYSDATETIME()
    )                                                       AS SoNgayKhongCoGiaoDich,
    -- Phân loại tồn lâu
    CASE
        WHEN lx.TongDaBan IS NULL OR lx.TongDaBan = 0  THEN N'CHET - Chưa bao giờ bán'
        WHEN DATEDIFF(DAY, lx.LanBanGanNhat, SYSDATETIME()) > 180 THEN N'TỒN LÂU NGHIÊM TRỌNG (>6 tháng)'
        WHEN DATEDIFF(DAY, lx.LanBanGanNhat, SYSDATETIME()) > 90  THEN N'TỒN LÂU (>3 tháng)'
        WHEN DATEDIFF(DAY, lx.LanBanGanNhat, SYSDATETIME()) > 30  THEN N'CHẬM BÁN (>1 tháng)'
        ELSE N'BÌNH THƯỜNG'
    END                                                     AS MucDo,
    -- Đề xuất xử lý
    CASE
        WHEN lx.TongDaBan IS NULL OR lx.TongDaBan = 0  THEN N'Xem xét thanh lý hoặc trả nhà cung cấp'
        WHEN DATEDIFF(DAY, lx.LanBanGanNhat, SYSDATETIME()) > 180 THEN N'Giảm giá mạnh 30-50% hoặc thanh lý'
        WHEN DATEDIFF(DAY, lx.LanBanGanNhat, SYSDATETIME()) > 90  THEN N'Chạy khuyến mãi, bundle với dịch vụ'
        WHEN DATEDIFF(DAY, lx.LanBanGanNhat, SYSDATETIME()) > 30  THEN N'Theo dõi, cân nhắc giảm giá nhẹ'
        ELSE N'Tiếp tục duy trì'
    END                                                     AS DeXuat
FROM dbo.SpareParts p
LEFT JOIN dbo.SparePartCategories c  ON c.CategoryId = p.CategoryId
LEFT JOIN LanXuatGanNhat lx          ON lx.PartId = p.PartId
WHERE p.IsActive = 1
  AND p.StockQuantity > 0;  -- Chỉ xét hàng còn tồn kho
GO

-- =========================================================================
-- PHẦN 5: STORED PROCEDURE TOÀN DIỆN CHO WEB ADMIN DASHBOARD / BACKEND API
-- Tên: dbo.sp_BaoCaoDoanhThuTheoThoVaDichVu
-- Tham số:
--  - @TuNgay DATE: Ngày bắt đầu lọc (mặc định 30 ngày trước)
--  - @DenNgay DATE: Ngày kết thúc lọc (mặc định hôm nay)
--  - @TechnicianUserId INT: Lọc theo thợ cụ thể (NULL = tất cả)
--  - @ServiceTypeId INT: Lọc theo loại dịch vụ cụ thể (NULL = tất cả)
--  - @LoaiBaoCao VARCHAR(30):
--      + 'THEO_THO'     : Báo cáo tổng hợp theo kỹ thuật viên
--      + 'THEO_DICH_VU' : Báo cáo tổng hợp theo loại dịch vụ sửa chữa
--      + 'MA_TRAN_CHEO' : Chi tiết kết hợp thợ x dịch vụ
--      + 'XU_HUONG_NGAY': Doanh thu theo từng ngày trong khoảng lọc
--      + 'HOA_HONG'     : Tính toán thưởng/hoa hồng cho thợ
-- =========================================================================
CREATE   PROCEDURE dbo.sp_BaoCaoDoanhThuTheoThoVaDichVu
    @TuNgay            DATE        = NULL,
    @DenNgay           DATE        = NULL,
    @TechnicianUserId  INT         = NULL,
    @ServiceTypeId     INT         = NULL,
    @LoaiBaoCao        VARCHAR(30) = 'THEO_THO'
AS
BEGIN
    SET NOCOUNT ON;

    -- Thiết lập giá trị mặc định nếu tham số NULL
    IF @DenNgay IS NULL
        SET @DenNgay = CAST(SYSDATETIME() AS DATE);

    IF @TuNgay IS NULL
        SET @TuNgay = DATEADD(DAY, -30, @DenNgay);

    -- Kiểm tra tính hợp lệ của khoảng thời gian
    IF @TuNgay > @DenNgay
    BEGIN
        RAISERROR(N'Lỗi nghiệp vụ: Ngày bắt đầu (@TuNgay) không được lớn hơn ngày kết thúc (@DenNgay).', 16, 1);
        RETURN -1;
    END

    -- TH1: BÁO CÁO THEO KỸ THUẬT VIÊN
    IF @LoaiBaoCao = 'THEO_THO'
    BEGIN
        SELECT 
            u.UserId                                                    AS MaTho,
            u.Username                                                  AS TenDangNhap,
            u.FullName                                                  AS TenKyThuatVien,
            COUNT(t.TicketId)                                           AS TongSoPhieuNhan,
            SUM(CASE WHEN t.Status IN ('COMPLETED', 'DELIVERED', 'PAID') THEN 1 ELSE 0 END) 
                                                                        AS SoPhieuHoanTat,
            SUM(CASE WHEN i.PaymentStatus = 'PAID' THEN 1 ELSE 0 END)   AS SoHoaDonDaThuTien,
            ISNULL(SUM(CASE WHEN i.PaymentStatus = 'PAID' THEN i.LaborCost ELSE 0 END), 0) 
                                                                        AS DoanhThuTienCong,
            ISNULL(SUM(CASE WHEN i.PaymentStatus = 'PAID' THEN i.PartsCost ELSE 0 END), 0) 
                                                                        AS DoanhThuLinhKien,
            ISNULL(SUM(CASE WHEN i.PaymentStatus = 'PAID' THEN i.DiscountAmount ELSE 0 END), 0) 
                                                                        AS TongGiamGia,
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
            )                                                           AS TyLeHoanThanhPhanTram
        FROM dbo.Users u
        LEFT JOIN dbo.RepairTickets t ON t.TechnicianUserId = u.UserId 
                                      AND CAST(t.ReceivedAt AS DATE) BETWEEN @TuNgay AND @DenNgay
        LEFT JOIN dbo.Invoices i      ON i.TicketId = t.TicketId
        WHERE u.RoleId = (SELECT RoleId FROM dbo.Roles WHERE RoleCode = 'TECHNICIAN')
          AND u.IsActive = 1
          AND (@TechnicianUserId IS NULL OR u.UserId = @TechnicianUserId)
          AND (@ServiceTypeId IS NULL OR t.ServiceTypeId = @ServiceTypeId)
        GROUP BY u.UserId, u.Username, u.FullName
        ORDER BY TongDoanhThuThucThu DESC;
        RETURN 0;
    END

    -- TH2: BÁO CÁO THEO LOẠI DỊCH VỤ SỬA CHỮA
    ELSE IF @LoaiBaoCao = 'THEO_DICH_VU'
    BEGIN
        SELECT 
            s.ServiceTypeId                                             AS MaDichVu,
            s.ServiceCode                                               AS MaCodeDichVu,
            s.ServiceName                                               AS TenDichVu,
            s.LaborCost                                                 AS GiaCongNiemYet,
            COUNT(t.TicketId)                                           AS SoLuotYeuCau,
            SUM(CASE WHEN t.Status IN ('COMPLETED', 'DELIVERED', 'PAID') THEN 1 ELSE 0 END) 
                                                                        AS SoPhieuHoanThanh,
            SUM(CASE WHEN i.PaymentStatus = 'PAID' THEN 1 ELSE 0 END)   AS SoHoaDonDaThuTien,
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
            END                                                         AS DoanhThuTrungBinhMoiLuot
        FROM dbo.ServiceTypes s
        LEFT JOIN dbo.RepairTickets t ON t.ServiceTypeId = s.ServiceTypeId 
                                      AND CAST(t.ReceivedAt AS DATE) BETWEEN @TuNgay AND @DenNgay
        LEFT JOIN dbo.Invoices i      ON i.TicketId = t.TicketId
        WHERE s.IsActive = 1
          AND (@ServiceTypeId IS NULL OR s.ServiceTypeId = @ServiceTypeId)
          AND (@TechnicianUserId IS NULL OR t.TechnicianUserId = @TechnicianUserId)
        GROUP BY s.ServiceTypeId, s.ServiceCode, s.ServiceName, s.LaborCost
        ORDER BY TongDoanhThuDichVu DESC;
        RETURN 0;
    END

    -- TH3: MA TRẬN KẾT HỢP (THỢ x DỊCH VỤ)
    ELSE IF @LoaiBaoCao = 'MA_TRAN_CHEO'
    BEGIN
        SELECT 
            u.FullName                                                  AS TenKyThuatVien,
            s.ServiceName                                               AS TenDichVu,
            COUNT(t.TicketId)                                           AS SoPhieuThucHien,
            SUM(CASE WHEN i.PaymentStatus = 'PAID' THEN 1 ELSE 0 END)   AS SoHoaDonDaThu,
            ISNULL(SUM(CASE WHEN i.PaymentStatus = 'PAID' THEN i.LaborCost ELSE 0 END), 0) 
                                                                        AS DoanhThuTienCong,
            ISNULL(SUM(CASE WHEN i.PaymentStatus = 'PAID' THEN i.PartsCost ELSE 0 END), 0) 
                                                                        AS DoanhThuLinhKien,
            ISNULL(SUM(CASE WHEN i.PaymentStatus = 'PAID' THEN i.TotalAmount ELSE 0 END), 0) 
                                                                        AS TongDoanhThu
        FROM dbo.Users u
        CROSS JOIN dbo.ServiceTypes s
        LEFT JOIN dbo.RepairTickets t ON t.TechnicianUserId = u.UserId 
                                      AND t.ServiceTypeId = s.ServiceTypeId
                                      AND CAST(t.ReceivedAt AS DATE) BETWEEN @TuNgay AND @DenNgay
        LEFT JOIN dbo.Invoices i      ON i.TicketId = t.TicketId
        WHERE u.RoleId = (SELECT RoleId FROM dbo.Roles WHERE RoleCode = 'TECHNICIAN')
          AND u.IsActive = 1
          AND s.IsActive = 1
          AND (@TechnicianUserId IS NULL OR u.UserId = @TechnicianUserId)
          AND (@ServiceTypeId IS NULL OR s.ServiceTypeId = @ServiceTypeId)
        GROUP BY u.FullName, s.ServiceName
        HAVING COUNT(t.TicketId) > 0  -- Chỉ lấy các cặp thợ - dịch vụ có phát sinh công việc
        ORDER BY u.FullName ASC, TongDoanhThu DESC;
        RETURN 0;
    END

    -- TH4: BIẾN ĐỘNG DOANH THU THEO TỪNG NGÀY TRONG KHOẢNG THỜI GIAN
    ELSE IF @LoaiBaoCao = 'XU_HUONG_NGAY'
    BEGIN
        SELECT 
            CAST(i.CreatedAt AS DATE)                                   AS Ngay,
            u.FullName                                                  AS TenKyThuatVien,
            s.ServiceName                                               AS TenDichVu,
            COUNT(DISTINCT t.TicketId)                                  AS SoPhieuSua,
            SUM(i.LaborCost)                                            AS DoanhThuTienCong,
            SUM(i.PartsCost)                                            AS DoanhThuLinhKien,
            SUM(i.TotalAmount)                                          AS TongDoanhThuNgay
        FROM dbo.Invoices i
        JOIN dbo.RepairTickets t ON t.TicketId = i.TicketId
        JOIN dbo.Users u         ON u.UserId = t.TechnicianUserId
        JOIN dbo.ServiceTypes s  ON s.ServiceTypeId = t.ServiceTypeId
        WHERE i.PaymentStatus = 'PAID'
          AND CAST(i.CreatedAt AS DATE) BETWEEN @TuNgay AND @DenNgay
          AND (@TechnicianUserId IS NULL OR u.UserId = @TechnicianUserId)
          AND (@ServiceTypeId IS NULL OR s.ServiceTypeId = @ServiceTypeId)
        GROUP BY CAST(i.CreatedAt AS DATE), u.FullName, s.ServiceName
        ORDER BY Ngay ASC, TongDoanhThuNgay DESC;
        RETURN 0;
    END

    -- TH5: HOA HỒNG VÀ THƯỞNG HIỆU SUẤT
    ELSE IF @LoaiBaoCao = 'HOA_HONG'
    BEGIN
        SELECT 
            u.UserId                                                    AS MaTho,
            u.FullName                                                  AS TenKyThuatVien,
            SUM(CASE WHEN i.PaymentStatus = 'PAID' THEN 1 ELSE 0 END)   AS SoPhieuHoanTatThuTien,
            ISNULL(SUM(CASE WHEN i.PaymentStatus = 'PAID' THEN i.LaborCost ELSE 0 END), 0)
                                                                        AS DoanhThuTienCong,
            CAST(ISNULL(SUM(CASE WHEN i.PaymentStatus = 'PAID' THEN i.LaborCost ELSE 0 END), 0) * 0.20 AS DECIMAL(18,2))
                                                                        AS HoaHongTienCong20Pct,
            CAST(ISNULL(SUM(CASE WHEN i.PaymentStatus = 'PAID' THEN i.PartsCost ELSE 0 END), 0) * 0.05 AS DECIMAL(18,2))
                                                                        AS HoaHongLinhKien5Pct,
            SUM(CASE WHEN t.IsWarrantyRepair = 1 THEN 1 ELSE 0 END)     AS SoPhieuBaoHanhLai,
            CAST(SUM(CASE WHEN t.IsWarrantyRepair = 1 THEN 1 ELSE 0 END) * 50000 AS DECIMAL(18,2))
                                                                        AS TruPhatBaoHanh,
            CAST(
                (ISNULL(SUM(CASE WHEN i.PaymentStatus = 'PAID' THEN i.LaborCost ELSE 0 END), 0) * 0.20)
                + (ISNULL(SUM(CASE WHEN i.PaymentStatus = 'PAID' THEN i.PartsCost ELSE 0 END), 0) * 0.05)
                - (SUM(CASE WHEN t.IsWarrantyRepair = 1 THEN 1 ELSE 0 END) * 50000)
                AS DECIMAL(18,2)
            )                                                           AS TongHoaHongThucNhan
        FROM dbo.Users u
        LEFT JOIN dbo.RepairTickets t ON t.TechnicianUserId = u.UserId 
                                      AND CAST(t.ReceivedAt AS DATE) BETWEEN @TuNgay AND @DenNgay
        LEFT JOIN dbo.Invoices i      ON i.TicketId = t.TicketId
        WHERE u.RoleId = (SELECT RoleId FROM dbo.Roles WHERE RoleCode = 'TECHNICIAN')
          AND u.IsActive = 1
          AND (@TechnicianUserId IS NULL OR u.UserId = @TechnicianUserId)
        GROUP BY u.UserId, u.FullName
        ORDER BY TongHoaHongThucNhan DESC;
        RETURN 0;
    END

    ELSE
    BEGIN
        RAISERROR(N'Loại báo cáo không hợp lệ. Chọn một trong các loại: THEO_THO, THEO_DICH_VU, MA_TRAN_CHEO, XU_HUONG_NGAY, HOA_HONG.', 16, 1);
        RETURN -2;
    END
END;
GO

-- =========================================================================
-- PHẦN 3: STORED PROCEDURE TOÀN DIỆN - BÁO CÁO THỐNG KÊ LINH KIỆN
-- =========================================================================
CREATE   PROCEDURE dbo.sp_BaoCaoThongKeLinhKien
    @LoaiBaoCao     NVARCHAR(30)  = 'BAN_CHAY',  -- BAN_CHAY | TON_LAU | TONG_HOP | LÃNG_PHI | TOP_N
    @NhomLinhKien   NVARCHAR(100) = NULL,
    @TuNgay         DATE          = NULL,
    @DenNgay        DATE          = NULL,
    @TopN           INT           = 10,            -- Dùng cho loại TOP_N
    @SoNgayTonToiThieu INT        = 30             -- Ngưỡng tồn lâu (ngày)
AS
BEGIN
    SET NOCOUNT ON;

    IF @DenNgay IS NULL SET @DenNgay = CAST(SYSDATETIME() AS DATE);
    IF @TuNgay  IS NULL SET @TuNgay  = DATEADD(DAY, -90, @DenNgay);

    -- ===================================================
    -- BAN_CHAY: Top N linh kiện bán chạy nhất
    -- ===================================================
    IF @LoaiBaoCao = 'BAN_CHAY'
    BEGIN
        SELECT TOP (@TopN)
            v.MaLinhKien,
            v.TenLinhKien,
            v.NhomLinhKien,
            v.TongSoLuongBan,
            v.SoLuongBanThuan,
            v.SoPhieuSuDung,
            v.DoanhThuThucTe,
            v.LoiNhuanGop,
            v.TyTrongDoanhThuPhanTram,
            v.TyLeLoiNhuanGopPhanTram,
            v.VongQuayTonKho,
            v.TonHienTai,
            v.GiaBan,
            v.PhanLoaiABC,
            v.LanBanGanNhat
        FROM dbo.v_LinhKienBanChay v
        WHERE (@NhomLinhKien IS NULL OR v.NhomLinhKien = @NhomLinhKien)
          AND v.TongSoLuongBan > 0
        ORDER BY v.TongSoLuongBan DESC;
        RETURN 0;
    END

    -- ===================================================
    -- TON_LAU: Linh kiện tồn lâu cần xử lý
    -- ===================================================
    ELSE IF @LoaiBaoCao = 'TON_LAU'
    BEGIN
        SELECT
            v.MaLinhKien,
            v.TenLinhKien,
            v.NhomLinhKien,
            v.TonKhoHienTai,
            v.GiaBan,
            v.GiaNhap,
            v.GiaTriTonKho,
            v.NgayNhapDauTien,
            v.LanBanGanNhat,
            v.TongDaBan,
            v.SoNgayKhongCoGiaoDich,
            v.MucDo,
            v.DeXuat
        FROM dbo.v_LinhKienTonLau v
        WHERE v.SoNgayKhongCoGiaoDich >= @SoNgayTonToiThieu
          AND (@NhomLinhKien IS NULL OR v.NhomLinhKien = @NhomLinhKien)
        ORDER BY v.SoNgayKhongCoGiaoDich DESC, v.GiaTriTonKho DESC;
        RETURN 0;
    END

    -- ===================================================
    -- TONG_HOP: Tổng hợp toàn bộ kho theo phân loại ABC
    -- ===================================================
    ELSE IF @LoaiBaoCao = 'TONG_HOP'
    BEGIN
        SELECT
            v.PhanLoaiABC,
            COUNT(*)                                AS SoLinhKien,
            SUM(v.TongSoLuongBan)                   AS TongSoLuongDaBan,
            SUM(v.DoanhThuThucTe)                   AS TongDoanhThu,
            SUM(v.LoiNhuanGop)                      AS TongLoiNhuan,
            CAST(AVG(v.TyLeLoiNhuanGopPhanTram) AS DECIMAL(5,2)) AS LoiNhuanTrungBinhPct,
            SUM(v.TonHienTai * v.GiaNhap)           AS GiaTriTonKhoHienTai
        FROM dbo.v_LinhKienBanChay v
        WHERE (@NhomLinhKien IS NULL OR v.NhomLinhKien = @NhomLinhKien)
        GROUP BY v.PhanLoaiABC
        ORDER BY v.PhanLoaiABC;
        RETURN 0;
    END

    -- ===================================================
    -- LANG_PHI: Linh kiện hoàn trả nhiều - chất lượng kém
    -- ===================================================
    ELSE IF @LoaiBaoCao = 'LANG_PHI'
    BEGIN
        SELECT TOP (@TopN)
            p.PartCode                      AS MaLinhKien,
            p.PartName                      AS TenLinhKien,
            c.CategoryName                  AS NhomLinhKien,
            SUM(CASE WHEN tx.TransactionType='OUT'    THEN tx.Quantity ELSE 0 END) AS TongXuat,
            SUM(CASE WHEN tx.TransactionType='RETURN' THEN tx.Quantity ELSE 0 END) AS TongHoanTra,
            CAST(
                CASE WHEN SUM(CASE WHEN tx.TransactionType='OUT' THEN tx.Quantity ELSE 0 END) > 0
                THEN SUM(CASE WHEN tx.TransactionType='RETURN' THEN tx.Quantity ELSE 0 END) * 100.0
                     / SUM(CASE WHEN tx.TransactionType='OUT' THEN tx.Quantity ELSE 0 END)
                ELSE 0 END
            AS DECIMAL(5,2))               AS TyLeHoanTraPhanTram,
            SUM(CASE WHEN tx.TransactionType='RETURN' THEN tx.Quantity * p.PurchasePrice ELSE 0 END) AS GiaTriHoanTraLai,
            p.SellingPrice,
            p.PurchasePrice
        FROM dbo.StockTransactions tx
        JOIN dbo.SpareParts p ON p.PartId = tx.PartId
        LEFT JOIN dbo.SparePartCategories c ON c.CategoryId = p.CategoryId
        WHERE tx.TransactionAt >= @TuNgay
          AND (@NhomLinhKien IS NULL OR c.CategoryName = @NhomLinhKien)
        GROUP BY p.PartId, p.PartCode, p.PartName, c.CategoryName, p.SellingPrice, p.PurchasePrice
        HAVING SUM(CASE WHEN tx.TransactionType='RETURN' THEN tx.Quantity ELSE 0 END) > 0
        ORDER BY TyLeHoanTraPhanTram DESC, TongHoanTra DESC;
        RETURN 0;
    END

    ELSE
    BEGIN
        RAISERROR(N'Loại báo cáo không hợp lệ. Chọn: BAN_CHAY, TON_LAU, TONG_HOP, LANG_PHI.', 16, 1);
        RETURN -1;
    END
END;
GO

-- ===== STORED PROCEDURE / INDEX BO SUNG (gop tu cac file truy van cu) =====
USE RepairShopDB;
GO

/* ---- sp_XuatKhoLinhKienSuaChua + trigger cảnh báo tồn tối thiểu ---- */
-- =========================================================================
-- NHÓM 11 - DỰ ÁN QUẢN LÝ CỬA HÀNG SỬA CHỮA (LV33-001)
-- MODULE: QUẢN LÝ KHO & CẢNH BÁO TỒN KHO TỐI THIỂU (SPRINT 5 & 6)
-- TÁC GIẢ: TRẦN NGỌC LỢI (BA / DATABASE LEAD) - TASK JIRA: MBA-63
-- CSDL: SQL Server 2022 | Database: QLDACNTT_CuaHangSuaChua
-- =========================================================================

USE RepairShopDB;
GO

-- 1. STORED PROCEDURE: Tự động xuất kho linh kiện phục vụ sửa chữa phiếu
-- Chức năng: Kiểm tra tồn kho, trừ số lượng tồn trong SpareParts, ghi log vào StockTransactions
CREATE OR ALTER PROCEDURE dbo.sp_XuatKhoLinhKienSuaChua
    @PartCode VARCHAR(50),
    @Quantity INT,
    @TicketCode VARCHAR(50),
    @PerformerUsername NVARCHAR(100),
    @Note NVARCHAR(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;

    BEGIN TRY
        -- A. Kiểm tra linh kiện có tồn tại không
        DECLARE @PartId INT, @CurrentStock INT, @MinStock INT, @SellingPrice DECIMAL(18,2);
        SELECT 
            @PartId = PartId, 
            @CurrentStock = StockQuantity, 
            @MinStock = MinStockLevel,
            @SellingPrice = SellingPrice
        FROM dbo.SpareParts
        WHERE PartCode = @PartCode AND IsActive = 1;

        IF @PartId IS NULL
        BEGIN
            RAISERROR(N'Lỗi: Linh kiện mã %s không tồn tại hoặc đã bị vô hiệu hóa.', 16, 1, @PartCode);
            ROLLBACK TRANSACTION;
            RETURN -1;
        END

        -- B. Kiểm tra số lượng tồn kho có đủ để xuất không
        IF @CurrentStock < @Quantity
        BEGIN
            DECLARE @ErrMsg NVARCHAR(200);
            SET @ErrMsg = N'Lỗi: Số lượng tồn kho không đủ (Hiện tồn: ' + CAST(@CurrentStock AS NVARCHAR) + N', Yêu cầu: ' + CAST(@Quantity AS NVARCHAR) + N').';
            RAISERROR(@ErrMsg, 16, 1);
            ROLLBACK TRANSACTION;
            RETURN -2;
        END

        -- C. Thực hiện trừ số lượng tồn kho trong bảng SpareParts
        UPDATE dbo.SpareParts
        SET StockQuantity = StockQuantity - @Quantity,
            UpdatedAt = GETDATE()
        WHERE PartId = @PartId;

        -- D. Ghi nhật ký biến động kho vào bảng StockTransactions
        INSERT INTO dbo.StockTransactions (PartId, TransactionType, Quantity, UnitPrice, StockBefore, StockAfter, TicketId, PerformedByUserId, Note, TransactionAt)
        VALUES (
            @PartId, N'OUT', @Quantity, @SellingPrice, @CurrentStock, @CurrentStock - @Quantity,
            (SELECT TicketId FROM dbo.RepairTickets WHERE TicketCode = @TicketCode),
            (SELECT UserId FROM dbo.Users WHERE Username = @PerformerUsername),
            ISNULL(@Note, N'Xuất linh kiện phục vụ sửa chữa cho phiếu: ' + @TicketCode),
            SYSDATETIME()
        );

        -- E. Kiểm tra xem sau khi xuất, tồn kho có chạm ngưỡng tối thiểu không
        DECLARE @NewStock INT = @CurrentStock - @Quantity;
        IF @NewStock <= @MinStock
        BEGIN
            PRINT N'>> [CẢNH BÁO TỒN KHO]: Linh kiện ' + @PartCode + N' hiện còn ' + CAST(@NewStock AS NVARCHAR) + N' cái (<= mức tối thiểu ' + CAST(@MinStock AS NVARCHAR) + N'). Cần đặt hàng nhập thêm!';
        END

        COMMIT TRANSACTION;
        PRINT N'>> [THÀNH CÔNG]: Đã xuất kho ' + CAST(@Quantity AS NVARCHAR) + N' cái linh kiện ' + @PartCode + N' cho phiếu ' + @TicketCode;
        RETURN 0;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMsg, 16, 1);
        RETURN -99;
    END CATCH
END;
GO

-- 2. TRIGGER: Cảnh báo tự động khi cập nhật tồn kho dưới định mức an toàn
CREATE OR ALTER TRIGGER dbo.trg_CanhBaoTonKhoToiThieu
ON dbo.SpareParts
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF UPDATE(StockQuantity)
    BEGIN
        IF EXISTS (
            SELECT 1 FROM inserted i
            WHERE i.StockQuantity <= i.MinStockLevel AND i.IsActive = 1
        )
        BEGIN
            PRINT N'>> [TRIGGER THÔNG BÁO]: Có linh kiện chạm ngưỡng cảnh báo tồn tối thiểu trong bảng dbo.SpareParts!';
        END
    END
END;
GO

-- 3. TEST THỬ NGHIỆM STORED PROCEDURE (DEMO RUN)
-- EXEC dbo.sp_XuatKhoLinhKienSuaChua @PartCode = 'PIN-IP11', @Quantity = 1, @TicketCode = 'TC-2026-001', @PerformerUsername = 'tranngocloi', @Note = N'Thay pin cho khách hàng';
-- SELECT * FROM dbo.v_CanhBaoTonKho;
GO
USE RepairShopDB;
GO

/* ---- sp_HoanTraLinhKienLoi ---- */
-- =========================================================================
-- NHÓM 11 - DỰ ÁN QUẢN LÝ CỬA HÀNG SỬA CHỮA (LV33-001)
-- MODULE: QUẢN LÝ KHO & HOÀN TRẢ LINH KIỆN LỖI (SPRINT 6)
-- TÁC GIẢ: TRẦN NGỌC LỢI (BA / DATABASE LEAD) - TASK JIRA: MBA-78
-- CSDL: SQL Server 2022 | Database: QLDACNTT_CuaHangSuaChua / RepairShopDB
-- =========================================================================

IF DB_ID('RepairShopDB') IS NOT NULL
    USE RepairShopDB;
ELSE IF DB_ID('RepairShopDB') IS NOT NULL
    USE RepairShopDB;
GO

-- 1. STORED PROCEDURE: Ghi nhận hoàn trả linh kiện lỗi / hỏng về kho
-- Chức năng: 
--  - Kiểm tra tính hợp lệ của mã linh kiện
--  - Cập nhật tăng số lượng tồn kho trong bảng SpareParts (để nhập lại kho linh kiện hỏng / thu hồi)
--  - Ghi log giao dịch hoàn trả vào StockTransactions với loại giao dịch 'RETURN'
CREATE OR ALTER PROCEDURE dbo.sp_HoanTraLinhKienLoi
    @PartCode VARCHAR(50),
    @Quantity INT,
    @TicketCode VARCHAR(50) = NULL,
    @PerformerUsername NVARCHAR(100),
    @DefectReason NVARCHAR(255),
    @Note NVARCHAR(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;

    BEGIN TRY
        -- A. Kiểm tra số lượng hợp lệ
        IF @Quantity <= 0
        BEGIN
            RAISERROR(N'Lỗi: Số lượng linh kiện hoàn trả phải lớn hơn 0.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN -1;
        END

        -- B. Kiểm tra lý do lỗi không được để trống
        IF ISNULL(@DefectReason, '') = ''
        BEGIN
            RAISERROR(N'Lỗi: Vui lòng cung cấp lý do linh kiện bị lỗi/hỏng.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN -2;
        END

        -- C. Kiểm tra linh kiện có tồn tại trong CSDL không
        DECLARE @PartId INT, @CurrentStock INT, @SellingPrice DECIMAL(18,2);
        SELECT 
            @PartId = PartId, 
            @CurrentStock = StockQuantity,
            @SellingPrice = SellingPrice
        FROM dbo.SpareParts
        WHERE PartCode = @PartCode AND IsActive = 1;

        IF @PartId IS NULL
        BEGIN
            RAISERROR(N'Lỗi: Linh kiện mã %s không tồn tại hoặc đã bị vô hiệu hóa.', 16, 1, @PartCode);
            ROLLBACK TRANSACTION;
            RETURN -3;
        END

        -- D. Cập nhật cộng trả lại số lượng tồn kho trong bảng SpareParts
        DECLARE @StockBefore INT = @CurrentStock;
        DECLARE @StockAfter INT = @CurrentStock + @Quantity;

        UPDATE dbo.SpareParts
        SET StockQuantity = StockQuantity + @Quantity,
            UpdatedAt = GETDATE()
        WHERE PartId = @PartId;

        -- E. Tìm TicketId từ TicketCode nếu có
        DECLARE @TicketId INT = NULL;
        IF @TicketCode IS NOT NULL AND @TicketCode <> ''
        BEGIN
            SELECT @TicketId = TicketId 
            FROM dbo.RepairTickets 
            WHERE TicketCode = @TicketCode;
        END

        -- F. Lấy UserId người thực hiện
        DECLARE @UserId INT;
        SELECT @UserId = UserId FROM dbo.Users WHERE Username = @PerformerUsername;
        IF @UserId IS NULL
        BEGIN
            -- Nếu chưa chọn User cụ thể, mặc định lấy ID của Admin hoặc User hệ thống
            SELECT TOP 1 @UserId = UserId FROM dbo.Users ORDER BY UserId ASC;
        END

        -- G. Ghi nhật ký biến động kho vào bảng StockTransactions (Type = 'RETURN')
        DECLARE @FullNote NVARCHAR(500);
        SET @FullNote = N'[HOÀN TRẢ LỖI] Lý do: ' + @DefectReason + 
                        CASE WHEN @Note IS NOT NULL THEN N' | Ghi chú: ' + @Note ELSE N'' END;

        INSERT INTO dbo.StockTransactions (
            PartId, 
            TransactionType, 
            Quantity, 
            UnitPrice, 
            StockBefore,
            StockAfter,
            TicketId, 
            PerformedByUserId, 
            TransactionAt, 
            Note
        )
        VALUES (
            @PartId,
            'RETURN',
            @Quantity,
            @SellingPrice,
            @StockBefore,
            @StockAfter,
            @TicketId,
            @UserId,
            GETDATE(),
            @FullNote
        );

        COMMIT TRANSACTION;
        PRINT N'>> [THÀNH CÔNG]: Đã nhập hoàn trả ' + CAST(@Quantity AS NVARCHAR) + N' cái linh kiện lỗi ' + @PartCode + N' vào kho. Tồn mới: ' + CAST(@StockAfter AS NVARCHAR);
        RETURN 0;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMsg, 16, 1);
        RETURN -99;
    END CATCH
END;
GO

-- 2. DEMO KỊCH BẢN THỬ NGHIỆM STORED PROCEDURE (TEST RUN)
-- EXEC dbo.sp_HoanTraLinhKienLoi 
--     @PartCode = 'PIN-IP11', 
--     @Quantity = 1, 
--     @TicketCode = 'PSC2026090001', 
--     @PerformerUsername = 'tech', 
--     @DefectReason = N'Pin phồng không tích điện khi test lắp máy',
--     @Note = N'Yêu cầu hoàn trả kho đổi nhà cung cấp';
GO
USE RepairShopDB;
GO

/* ---- Index tối ưu + sp_DashboardTongQuan, sp_DanhSachPhieuPhanTrang ---- */
/* =========================================================================
   NHÓM 11 - DỰ ÁN QUẢN LÝ CỬA HÀNG SỬA CHỮA (LV33-001)
   MODULE: TỐI ƯU HÓA TRUY VẤN DỮ LIỆU LỚN VÀ CACHING (SPRINT 7)
   TÁC GIẢ: TRẦN NGỌC LỢI (BA / DATABASE LEAD) - TASK JIRA: MBA-59
   TÊN TÁC VỤ: TỐI ƯU HÓA TRUY VẤN DỮ LIỆU LỚN VÀ CACHING
   CSDL: SQL Server 2022 | Database: RepairShopDB
   ========================================================================= */

IF DB_ID('RepairShopDB') IS NOT NULL
    USE RepairShopDB;
ELSE IF DB_ID('RepairShopDB') IS NOT NULL
    USE RepairShopDB;
GO

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

PRINT N'=========================================================================';
PRINT N'MBA-59: TỐI ƯU HÓA TRUY VẤN DỮ LIỆU LỚN VÀ CACHING';
PRINT N'Người thực hiện: Trần Ngọc Lợi (BA / Database Lead - Nhóm 11)';
PRINT N'=========================================================================';
GO

-- =========================================================================
-- PHẦN 1: TẠO CHỈ SỐ (INDEX) BỔ SUNG ĐỂ TĂNG TỐC CÁC TRUY VẤN PHỔ BIẾN
-- Mục đích: Giảm thời gian truy vấn từ Table Scan → Index Seek / Index Scan
-- =========================================================================

PRINT N'>> Phần 1: Tạo chỉ số tối ưu hóa...';
GO

-- [IX-01] Index tổng hợp cho RepairTickets - Lọc theo trạng thái và ngày tiếp nhận
-- Phục vụ: Dashboard, báo cáo tiến độ, lọc theo khoảng thời gian
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID('dbo.RepairTickets')
      AND name = 'IX_RepairTickets_Status_ReceivedAt'
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_RepairTickets_Status_ReceivedAt
    ON dbo.RepairTickets (Status, ReceivedAt DESC)
    INCLUDE (TicketCode, CustomerId, TechnicianUserId, ServiceTypeId, QuotedLaborCost, QuotedPartsCost)
    WITH (
        FILLFACTOR = 85,
        ONLINE = OFF,   -- Đặt OFF nếu không có Enterprise Edition
        STATISTICS_NORECOMPUTE = OFF
    );
    PRINT N'>> [ĐÃ TẠO]: IX_RepairTickets_Status_ReceivedAt';
END
ELSE
    PRINT N'>> [EXISTED]: IX_RepairTickets_Status_ReceivedAt';
GO

-- [IX-02] Index cho RepairTickets theo TechnicianUserId - Báo cáo theo kỹ thuật viên
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID('dbo.RepairTickets')
      AND name = 'IX_RepairTickets_TechnicianUserId_Status'
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_RepairTickets_TechnicianUserId_Status
    ON dbo.RepairTickets (TechnicianUserId, Status)
    INCLUDE (TicketCode, ServiceTypeId, ReceivedAt, CompletedAt, IsWarrantyRepair)
    WITH (FILLFACTOR = 85, ONLINE = OFF);
    PRINT N'>> [ĐÃ TẠO]: IX_RepairTickets_TechnicianUserId_Status';
END
ELSE
    PRINT N'>> [EXISTED]: IX_RepairTickets_TechnicianUserId_Status';
GO

-- [IX-03] Index cho Invoices theo PaymentStatus và ngày tạo - Báo cáo doanh thu
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID('dbo.Invoices')
      AND name = 'IX_Invoices_PaymentStatus_CreatedAt'
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_Invoices_PaymentStatus_CreatedAt
    ON dbo.Invoices (PaymentStatus, CreatedAt DESC)
    INCLUDE (TicketId, CustomerId, LaborCost, PartsCost, DiscountAmount, TotalAmount, PaidAt)
    WITH (FILLFACTOR = 85, ONLINE = OFF);
    PRINT N'>> [ĐÃ TẠO]: IX_Invoices_PaymentStatus_CreatedAt';
END
ELSE
    PRINT N'>> [EXISTED]: IX_Invoices_PaymentStatus_CreatedAt';
GO

-- [IX-04] Index cho StockTransactions - Tra cứu lịch sử linh kiện theo phiếu / mã linh kiện
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID('dbo.StockTransactions')
      AND name = 'IX_StockTransactions_PartId_Type_At'
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_StockTransactions_PartId_Type_At
    ON dbo.StockTransactions (PartId, TransactionType, TransactionAt DESC)
    INCLUDE (TicketId, Quantity, StockBefore, StockAfter, Note, PerformedByUserId)
    WITH (FILLFACTOR = 85, ONLINE = OFF);
    PRINT N'>> [ĐÃ TẠO]: IX_StockTransactions_PartId_Type_At';
END
ELSE
    PRINT N'>> [EXISTED]: IX_StockTransactions_PartId_Type_At';
GO

-- [IX-05] Index cho SpareParts - Cảnh báo tồn kho tối thiểu (scan nhanh)
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID('dbo.SpareParts')
      AND name = 'IX_SpareParts_IsActive_StockQuantity'
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_SpareParts_IsActive_StockQuantity
    ON dbo.SpareParts (IsActive, StockQuantity)
    INCLUDE (PartCode, PartName, CategoryId, MinStockLevel, SellingPrice, PurchasePrice)
    WITH (FILLFACTOR = 90, ONLINE = OFF);
    PRINT N'>> [ĐÃ TẠO]: IX_SpareParts_IsActive_StockQuantity';
END
ELSE
    PRINT N'>> [EXISTED]: IX_SpareParts_IsActive_StockQuantity';
GO

-- [IX-06] Index cho Users - Tra cứu theo Role (hay dùng cho báo cáo kỹ thuật viên)
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID('dbo.Users')
      AND name = 'IX_Users_RoleId_IsActive'
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_Users_RoleId_IsActive
    ON dbo.Users (RoleId, IsActive)
    INCLUDE (Username, FullName, Phone, Email)
    WITH (FILLFACTOR = 90, ONLINE = OFF);
    PRINT N'>> [ĐÃ TẠO]: IX_Users_RoleId_IsActive';
END
ELSE
    PRINT N'>> [EXISTED]: IX_Users_RoleId_IsActive';
GO

-- =========================================================================
-- PHẦN 2: THỐNG KÊ CHỈ SỐ (UPDATE STATISTICS) ĐỂ SQL SERVER CHỌN PLAN TỐT NHẤT
-- =========================================================================
PRINT N'>> Phần 2: Cập nhật thống kê bảng...';
GO

UPDATE STATISTICS dbo.RepairTickets WITH FULLSCAN;
UPDATE STATISTICS dbo.Invoices      WITH FULLSCAN;
UPDATE STATISTICS dbo.SpareParts    WITH FULLSCAN;
UPDATE STATISTICS dbo.StockTransactions WITH FULLSCAN;
UPDATE STATISTICS dbo.Users         WITH FULLSCAN;
UPDATE STATISTICS dbo.Customers     WITH FULLSCAN;
PRINT N'>> [DONE]: Update Statistics cho 6 bảng chính';
GO

-- =========================================================================
-- PHẦN 3: STORED PROCEDURE DASHBOARD TỔNG QUAN (CÓ CACHE IN-DB QUA TEMP TABLE)
-- Mục đích: Thay vì thực thi lại 6 truy vấn phức tạp mỗi lần tải dashboard,
--           cache kết quả trong bảng tạm #DashboardCache và trả về ngay.
-- =========================================================================
CREATE OR ALTER PROCEDURE dbo.sp_DashboardTongQuan
    @ForceRefresh BIT = 0  -- 0 = dùng cache nếu có, 1 = luôn tính lại
AS
BEGIN
    SET NOCOUNT ON;

    -- Tạo bảng tạm lưu cache kết quả dashboard
    CREATE TABLE #DashboardCache (
        MetricKey   NVARCHAR(100) NOT NULL,
        MetricValue NVARCHAR(500) NULL
    );

    DECLARE @today DATE = CAST(SYSDATETIME() AS DATE);
    DECLARE @month1Start DATE = DATEFROMPARTS(YEAR(@today), MONTH(@today), 1);
    DECLARE @month1End   DATE = EOMONTH(@today);
    DECLARE @prevStart   DATE = DATEADD(MONTH, -1, @month1Start);
    DECLARE @prevEnd     DATE = DATEADD(DAY, -1, @month1Start);

    -- [1] Tổng số phiếu theo trạng thái
    INSERT INTO #DashboardCache
    SELECT
        N'phieu_' + Status,
        CAST(COUNT(*) AS NVARCHAR(50))
    FROM dbo.RepairTickets WITH (NOLOCK)
    GROUP BY Status;

    -- [2] Doanh thu tháng hiện tại (PAID)
    INSERT INTO #DashboardCache
    SELECT N'doanh_thu_thang_hien_tai',
        CAST(ISNULL(SUM(TotalAmount), 0) AS NVARCHAR(50))
    FROM dbo.Invoices WITH (NOLOCK)
    WHERE PaymentStatus = 'PAID'
      AND CAST(CreatedAt AS DATE) BETWEEN @month1Start AND @month1End;

    -- [3] Doanh thu tháng trước (so sánh tăng/giảm)
    INSERT INTO #DashboardCache
    SELECT N'doanh_thu_thang_truoc',
        CAST(ISNULL(SUM(TotalAmount), 0) AS NVARCHAR(50))
    FROM dbo.Invoices WITH (NOLOCK)
    WHERE PaymentStatus = 'PAID'
      AND CAST(CreatedAt AS DATE) BETWEEN @prevStart AND @prevEnd;

    -- [4] Tổng khách hàng đang hoạt động
    INSERT INTO #DashboardCache
    SELECT N'tong_khach_hang', CAST(COUNT(*) AS NVARCHAR(50))
    FROM dbo.Customers WITH (NOLOCK)
    WHERE IsActive = 1;

    -- [5] Số linh kiện dưới mức tồn tối thiểu
    INSERT INTO #DashboardCache
    SELECT N'linh_kien_can_nhap', CAST(COUNT(*) AS NVARCHAR(50))
    FROM dbo.SpareParts WITH (NOLOCK)
    WHERE IsActive = 1 AND StockQuantity <= MinStockLevel;

    -- [6] Số phiếu bảo hành sắp hết hạn (30 ngày tới)
    INSERT INTO #DashboardCache
    SELECT N'bao_hanh_sap_het', CAST(COUNT(*) AS NVARCHAR(50))
    FROM dbo.Warranties WITH (NOLOCK)
    WHERE Status = 'ACTIVE'
      AND EndDate BETWEEN SYSDATETIME() AND DATEADD(DAY, 30, SYSDATETIME());

    -- [7] Top 5 kỹ thuật viên theo doanh thu tháng hiện tại
    INSERT INTO #DashboardCache
    SELECT N'top_tho_' + CAST(ROW_NUMBER() OVER (ORDER BY SUM(i.TotalAmount) DESC) AS NVARCHAR(10)),
           u.FullName + N':' + CAST(ISNULL(SUM(i.TotalAmount),0) AS NVARCHAR(50))
    FROM dbo.Users u WITH (NOLOCK)
    JOIN dbo.RepairTickets t WITH (NOLOCK) ON t.TechnicianUserId = u.UserId
    JOIN dbo.Invoices i      WITH (NOLOCK) ON i.TicketId = t.TicketId
    WHERE u.IsActive = 1
      AND i.PaymentStatus = 'PAID'
      AND CAST(i.CreatedAt AS DATE) BETWEEN @month1Start AND @month1End
    GROUP BY u.UserId, u.FullName
    ORDER BY SUM(i.TotalAmount) DESC
    OFFSET 0 ROWS FETCH NEXT 5 ROWS ONLY;

    -- Trả về kết quả
    SELECT MetricKey, MetricValue FROM #DashboardCache ORDER BY MetricKey;

    DROP TABLE #DashboardCache;
END;
GO
PRINT N'>> [ĐÃ TẠO]: sp_DashboardTongQuan (với NOLOCK cache pattern)';
GO

-- =========================================================================
-- PHẦN 4: STORED PROCEDURE PHÂN TRANG DỮ LIỆU LỚN (KEYSET PAGINATION)
-- Mục đích: Thay vì OFFSET/FETCH đơn thuần (chậm khi dữ liệu > 100k rows),
--           dùng Keyset Pagination (con trỏ TicketId) để lướt nhanh.
-- =========================================================================
CREATE OR ALTER PROCEDURE dbo.sp_DanhSachPhieuPhanTrang
    @LastTicketId   INT         = 0,     -- ID cuối của trang trước (0 = trang đầu)
    @PageSize       INT         = 20,    -- Số bản ghi mỗi trang (tối đa 100)
    @Status         NVARCHAR(20)= NULL,  -- Lọc theo trạng thái
    @TechUserId     INT         = NULL,  -- Lọc theo kỹ thuật viên
    @TuNgay         DATE        = NULL,
    @DenNgay        DATE        = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Giới hạn kích thước trang để bảo vệ hiệu năng
    IF @PageSize > 100 SET @PageSize = 100;
    IF @PageSize < 1   SET @PageSize = 10;

    -- Keyset pagination: TicketId > @LastTicketId (index-friendly)
    SELECT TOP (@PageSize)
        t.TicketId,
        t.TicketCode,
        c.FullName      AS TenKhachHang,
        c.Phone         AS SoDienThoai,
        s.ServiceName   AS LoaiDichVu,
        u.FullName      AS TenKyThuatVien,
        t.Status        AS TrangThai,
        t.ReceivedAt    AS NgayTiepNhan,
        t.CompletedAt   AS NgayHoanThanh,
        ISNULL(i.TotalAmount, 0)    AS TongTienHoaDon,
        i.PaymentStatus AS TrangThaiThanhToan
    FROM dbo.RepairTickets t WITH (NOLOCK)
    JOIN dbo.Customers    c WITH (NOLOCK) ON c.CustomerId = t.CustomerId
    JOIN dbo.ServiceTypes s WITH (NOLOCK) ON s.ServiceTypeId = t.ServiceTypeId
    LEFT JOIN dbo.Users   u WITH (NOLOCK) ON u.UserId = t.TechnicianUserId
    LEFT JOIN dbo.Invoices i WITH (NOLOCK) ON i.TicketId = t.TicketId
    WHERE t.TicketId > @LastTicketId
      AND (@Status    IS NULL OR t.Status = @Status)
      AND (@TechUserId IS NULL OR t.TechnicianUserId = @TechUserId)
      AND (@TuNgay    IS NULL OR CAST(t.ReceivedAt AS DATE) >= @TuNgay)
      AND (@DenNgay   IS NULL OR CAST(t.ReceivedAt AS DATE) <= @DenNgay)
    ORDER BY t.TicketId ASC;
END;
GO
PRINT N'>> [ĐÃ TẠO]: sp_DanhSachPhieuPhanTrang (Keyset Pagination)';
GO

-- =========================================================================
-- PHẦN 5: BẢNG CACHE DOANH THU THEO NGÀY (MATERIALIZED CACHE TABLE)
-- Mục đích: Lưu kết quả tổng hợp doanh thu theo ngày để dashboard đọc nhanh,
--           thay vì tính lại từ đầu dữ liệu mỗi lần.
-- =========================================================================
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'CacheDoanhThuNgay' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.CacheDoanhThuNgay (
        Ngay            DATE            NOT NULL,
        SoHoaDon        INT             NOT NULL DEFAULT 0,
        TongTienCong    DECIMAL(18,2)   NOT NULL DEFAULT 0,
        TongLinhKien    DECIMAL(18,2)   NOT NULL DEFAULT 0,
        TongGiamGia     DECIMAL(18,2)   NOT NULL DEFAULT 0,
        TongDoanhThu    DECIMAL(18,2)   NOT NULL DEFAULT 0,
        SoPhieuMoi      INT             NOT NULL DEFAULT 0,
        SoPhieuHoanThanh INT           NOT NULL DEFAULT 0,
        RefreshedAt     DATETIME2       NOT NULL DEFAULT SYSDATETIME(),
        CONSTRAINT PK_CacheDoanhThuNgay PRIMARY KEY CLUSTERED (Ngay DESC)
    );
    PRINT N'>> [ĐÃ TẠO]: Bảng dbo.CacheDoanhThuNgay (Materialized Cache)';
END
ELSE
    PRINT N'>> [EXISTED]: Bảng dbo.CacheDoanhThuNgay';
GO

-- Stored Procedure làm mới cache doanh thu ngày
CREATE OR ALTER PROCEDURE dbo.sp_LamMoiCacheDoanhThu
    @SoNgayNhin INT = 90  -- Làm mới cache cho N ngày gần nhất
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @TuNgay DATE = DATEADD(DAY, -@SoNgayNhin, CAST(SYSDATETIME() AS DATE));
    DECLARE @DenNgay DATE = CAST(SYSDATETIME() AS DATE);

    -- Xóa cache cũ trong khoảng ngày đang làm mới
    DELETE FROM dbo.CacheDoanhThuNgay
    WHERE Ngay BETWEEN @TuNgay AND @DenNgay;

    -- Nạp lại cache từ dữ liệu thực
    INSERT INTO dbo.CacheDoanhThuNgay
        (Ngay, SoHoaDon, TongTienCong, TongLinhKien, TongGiamGia, TongDoanhThu, RefreshedAt)
    SELECT
        CAST(i.CreatedAt AS DATE)       AS Ngay,
        COUNT(*)                        AS SoHoaDon,
        ISNULL(SUM(i.LaborCost),0)      AS TongTienCong,
        ISNULL(SUM(i.PartsCost),0)      AS TongLinhKien,
        ISNULL(SUM(i.DiscountAmount),0) AS TongGiamGia,
        ISNULL(SUM(i.TotalAmount),0)    AS TongDoanhThu,
        SYSDATETIME()
    FROM dbo.Invoices i
    WHERE i.PaymentStatus = 'PAID'
      AND CAST(i.CreatedAt AS DATE) BETWEEN @TuNgay AND @DenNgay
    GROUP BY CAST(i.CreatedAt AS DATE);

    -- Cập nhật số phiếu mới và hoàn thành vào cache
    UPDATE c
    SET
        c.SoPhieuMoi = sub.SoPhieuMoi,
        c.SoPhieuHoanThanh = sub.SoPhieuHoanThanh
    FROM dbo.CacheDoanhThuNgay c
    JOIN (
        SELECT
            CAST(t.ReceivedAt AS DATE) AS Ngay,
            COUNT(*) AS SoPhieuMoi,
            SUM(CASE WHEN t.Status IN ('COMPLETED','DELIVERED','PAID') THEN 1 ELSE 0 END) AS SoPhieuHoanThanh
        FROM dbo.RepairTickets t
        WHERE CAST(t.ReceivedAt AS DATE) BETWEEN @TuNgay AND @DenNgay
        GROUP BY CAST(t.ReceivedAt AS DATE)
    ) sub ON sub.Ngay = c.Ngay;

    PRINT N'>> Cache doanh thu đã được làm mới cho ' + CAST(@SoNgayNhin AS NVARCHAR(10)) + N' ngày';
END;
GO
PRINT N'>> [ĐÃ TẠO]: sp_LamMoiCacheDoanhThu';
GO

-- =========================================================================
-- PHẦN 6: VIEW TỐI ƯU VỚI SCHEMABINDING (CHO INDEXED VIEW NẾU CẦN)
-- Mục đích: View tổng hợp nhanh trang thái phiếu dùng NOLOCK
-- =========================================================================
CREATE OR ALTER VIEW dbo.v_TomTatPhieuHienTai
WITH SCHEMABINDING
AS
SELECT
    t.Status,
    COUNT_BIG(*) AS SoPhieu,
    SUM(t.QuotedLaborCost + t.QuotedPartsCost) AS TongGiaTri
FROM dbo.RepairTickets t
GROUP BY t.Status;
GO
PRINT N'>> [ĐÃ TẠO]: View dbo.v_TomTatPhieuHienTai (SCHEMABINDING)';
GO

-- =========================================================================
-- PHẦN 7: PHÂN TÍCH HIỆU NĂNG - KIỂM TRA INDEX USAGE
-- Chạy truy vấn này sau khi hệ thống đã hoạt động một thời gian để đánh giá
-- index nào được dùng nhiều, index nào không dùng (có thể xóa bớt).
-- =========================================================================
PRINT N'-------------------------------------------------------------------------';
PRINT N'PHÂN TÍCH: Danh sách Index và mức độ sử dụng';
PRINT N'-------------------------------------------------------------------------';
SELECT
    OBJECT_NAME(s.object_id)        AS TenBang,
    i.name                          AS TenIndex,
    i.type_desc                     AS LoaiIndex,
    s.user_seeks                    AS LanTimKiem,
    s.user_scans                    AS LanQuet,
    s.user_lookups                  AS LanLookup,
    s.user_updates                  AS LanCapNhat,
    s.last_user_seek                AS LanTimKiemGanNhat,
    -- Chi phí duy trì: nếu update >> seeks+scans thì xem xét bỏ index
    CAST(
        CASE WHEN (s.user_seeks + s.user_scans + s.user_lookups) > 0
        THEN s.user_updates * 1.0 / (s.user_seeks + s.user_scans + s.user_lookups)
        ELSE 0 END
    AS DECIMAL(8,2))               AS TyLeChiPhiDuyTri
FROM sys.dm_db_index_usage_stats s
JOIN sys.indexes i ON i.object_id = s.object_id AND i.index_id = s.index_id
WHERE s.database_id = DB_ID()
  AND OBJECT_NAME(s.object_id) IN ('RepairTickets','Invoices','SpareParts','StockTransactions','Users','Customers')
  AND i.name IS NOT NULL
ORDER BY (s.user_seeks + s.user_scans) DESC;
GO

-- =========================================================================
-- PHẦN 8: KIỂM TRA PHÂN MẢNH INDEX VÀ GỢI Ý REBUILD / REORGANIZE
-- =========================================================================
PRINT N'-------------------------------------------------------------------------';
PRINT N'PHÂN TÍCH: Phân mảnh Index cần bảo trì';
PRINT N'-------------------------------------------------------------------------';
SELECT
    OBJECT_NAME(ips.object_id)      AS TenBang,
    i.name                          AS TenIndex,
    CAST(ips.avg_fragmentation_in_percent AS DECIMAL(6,2)) AS PhanManhPhanTram,
    ips.page_count                  AS SoTrang,
    CASE
        WHEN ips.avg_fragmentation_in_percent < 5   THEN N'OK - Khong can bao tri'
        WHEN ips.avg_fragmentation_in_percent < 30  THEN N'REORGANIZE - Sap xep lai'
        ELSE                                              N'REBUILD - Xay dung lai'
    END                             AS GopY
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'LIMITED') ips
JOIN sys.indexes i ON i.object_id = ips.object_id AND i.index_id = ips.index_id
WHERE ips.page_count > 100
  AND i.name IS NOT NULL
ORDER BY ips.avg_fragmentation_in_percent DESC;
GO

-- =========================================================================
-- PHẦN 9: SCRIPT BẢO TRÌ INDEX TỰ ĐỘNG (CHẠY QUA SQL AGENT JOB HÀNG TUẦN)
-- =========================================================================
CREATE OR ALTER PROCEDURE dbo.sp_BaoTriIndex
    @ThresholdReorganize FLOAT = 5.0,   -- % phân mảnh → REORGANIZE
    @ThresholdRebuild    FLOAT = 30.0   -- % phân mảnh → REBUILD
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @sql NVARCHAR(2000);
    DECLARE @tbl  NVARCHAR(256);
    DECLARE @idx  NVARCHAR(256);
    DECLARE @frag FLOAT;

    DECLARE cur CURSOR FAST_FORWARD READ_ONLY FOR
        SELECT
            OBJECT_NAME(ips.object_id),
            i.name,
            ips.avg_fragmentation_in_percent
        FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'LIMITED') ips
        JOIN sys.indexes i ON i.object_id = ips.object_id AND i.index_id = ips.index_id
        WHERE ips.page_count > 100
          AND i.name IS NOT NULL
          AND OBJECT_NAME(ips.object_id) IN
              ('RepairTickets','Invoices','SpareParts','StockTransactions','Users','Customers','Warranties')
        ORDER BY ips.avg_fragmentation_in_percent DESC;

    OPEN cur;
    FETCH NEXT FROM cur INTO @tbl, @idx, @frag;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF @frag >= @ThresholdRebuild
        BEGIN
            SET @sql = N'ALTER INDEX ' + QUOTENAME(@idx) + N' ON dbo.' + QUOTENAME(@tbl) + N' REBUILD WITH (ONLINE = OFF)';
            EXEC sp_executesql @sql;
            PRINT N'REBUILD: ' + @tbl + N'.' + @idx + N' (' + CAST(CAST(@frag AS INT) AS NVARCHAR) + N'% fragmentation)';
        END
        ELSE IF @frag >= @ThresholdReorganize
        BEGIN
            SET @sql = N'ALTER INDEX ' + QUOTENAME(@idx) + N' ON dbo.' + QUOTENAME(@tbl) + N' REORGANIZE';
            EXEC sp_executesql @sql;
            PRINT N'REORGANIZE: ' + @tbl + N'.' + @idx + N' (' + CAST(CAST(@frag AS INT) AS NVARCHAR) + N'% fragmentation)';
        END

        FETCH NEXT FROM cur INTO @tbl, @idx, @frag;
    END

    CLOSE cur;
    DEALLOCATE cur;

    PRINT N'>> Bảo trì Index hoàn tất!';
END;
GO
PRINT N'>> [ĐÃ TẠO]: sp_BaoTriIndex (Tự động REBUILD/REORGANIZE)';
GO

-- =========================================================================
-- TEST CHẠY THỬ
-- =========================================================================
PRINT N'-------------------------------------------------------------------------';
PRINT N'TEST: Chạy Dashboard với cache pattern';
PRINT N'-------------------------------------------------------------------------';
EXEC dbo.sp_DashboardTongQuan;
GO

PRINT N'-------------------------------------------------------------------------';
PRINT N'TEST: Phân trang phiếu sửa chữa - Trang đầu';
PRINT N'-------------------------------------------------------------------------';
EXEC dbo.sp_DanhSachPhieuPhanTrang @LastTicketId = 0, @PageSize = 10;
GO

PRINT N'=========================================================================';
PRINT N'HOÀN TẤT SCRIPT MBA-59: TỐI ƯU TRUY VẤN VÀ CACHING - TRẦN NGỌC LỢI';
PRINT N'=========================================================================';
GO
GO
USE RepairShopDB;
GO

/* ---- v_LichSuGiaoDichKho, sp_LichSuXuatNhapLinhKien, sp_DoiChieuTonKho ---- */
/* =========================================================================
   NHÓM 11 - DỰ ÁN QUẢN LÝ CỬA HÀNG SỬA CHỮA (LV33-001)
   MODULE: LỌC VÀ TRUY VẾT LỊCH SỬ XUẤT NHẬP LINH KIỆN (SPRINT 6/7)
   TÁC GIẢ: TRẦN NGỌC LỢI (BA / DATABASE LEAD) - TASK JIRA: MBA-65
   TÊN TÁC VỤ: LỌC VÀ TRUY VẾT LỊCH SỬ XUẤT NHẬP LINH KIỆN
   CSDL: SQL Server 2022 | Database: RepairShopDB
   ========================================================================= */

IF DB_ID('RepairShopDB') IS NOT NULL
    USE RepairShopDB;
ELSE IF DB_ID('RepairShopDB') IS NOT NULL
    USE RepairShopDB;
GO

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

PRINT N'=========================================================================';
PRINT N'MBA-65: LỌC VÀ TRUY VẾT LỊCH SỬ XUẤT NHẬP LINH KIỆN';
PRINT N'Người thực hiện: Trần Ngọc Lợi (BA / Database Lead - Nhóm 11)';
PRINT N'=========================================================================';
GO

-- =========================================================================
-- PHẦN 1: VIEW LỊCH SỬ GIAO DỊCH KHO - ĐẦY ĐỦ THÔNG TIN TRUY VẾT
-- Mục đích: Cung cấp nguồn dữ liệu chính cho tất cả các báo cáo xuất/nhập kho.
--           Nối đủ thông tin linh kiện, người thực hiện, phiếu liên quan.
-- =========================================================================
CREATE OR ALTER VIEW dbo.v_LichSuGiaoDichKho
AS
SELECT
    tx.TransactionId                                        AS MaGiaoDich,
    tx.TransactionAt                                        AS ThoiGianGiaoDich,
    p.PartCode                                              AS MaLinhKien,
    p.PartName                                              AS TenLinhKien,
    cat.CategoryName                                        AS NhomLinhKien,
    tx.TransactionType                                      AS LoaiGiaoDich,
    -- Mô tả loại giao dịch bằng tiếng Việt
    CASE tx.TransactionType
        WHEN 'IN'     THEN N'Nhập kho'
        WHEN 'OUT'    THEN N'Xuất kho sửa chữa'
        WHEN 'RETURN' THEN N'Hoàn trả linh kiện lỗi'
        WHEN 'ADJUST' THEN N'Điều chỉnh tồn kho'
        ELSE tx.TransactionType
    END                                                     AS TenLoaiGiaoDich,
    tx.Quantity                                             AS SoLuong,
    tx.StockBefore                                          AS TonTruoc,
    tx.StockAfter                                           AS TonSau,
    -- Biến động tồn kho (dương = nhập, âm = xuất)
    tx.StockAfter - tx.StockBefore                         AS BienDongTon,
    p.PurchasePrice                                         AS GiaNhap,
    p.SellingPrice                                          AS GiaBan,
    -- Giá trị giao dịch (tiền) - tính theo loại
    CASE tx.TransactionType
        WHEN 'IN'     THEN tx.Quantity * p.PurchasePrice
        WHEN 'OUT'    THEN tx.Quantity * p.SellingPrice
        WHEN 'RETURN' THEN -(tx.Quantity * p.PurchasePrice)
        ELSE 0
    END                                                     AS GiaTriGiaoDich,
    -- Thông tin phiếu sửa chữa liên quan (nếu có)
    t.TicketCode                                            AS MaPhieuLienQuan,
    t.Status                                                AS TrangThaiPhieu,
    cu.FullName                                             AS TenKhachHang,
    cu.Phone                                                AS SDT_KhachHang,
    s.ServiceName                                           AS DichVuSuaChua,
    -- Thông tin người thực hiện giao dịch
    tx.PerformedByUserId                                    AS MaNguoiThucHien,
    u.FullName                                              AS NguoiThucHien,
    u_role.RoleCode                                         AS VaiTroNguoiThucHien,
    tx.Note                                                 AS GhiChu
FROM dbo.StockTransactions tx
JOIN dbo.SpareParts     p         ON p.PartId = tx.PartId
LEFT JOIN dbo.SparePartCategories cat ON cat.CategoryId = p.CategoryId
LEFT JOIN dbo.RepairTickets t     ON t.TicketId = tx.TicketId
LEFT JOIN dbo.Customers cu        ON cu.CustomerId = t.CustomerId
LEFT JOIN dbo.ServiceTypes s      ON s.ServiceTypeId = t.ServiceTypeId
LEFT JOIN dbo.Users u             ON u.UserId = tx.PerformedByUserId
LEFT JOIN dbo.Roles u_role        ON u_role.RoleId = u.RoleId;
GO
PRINT N'>> [ĐÃ TẠO]: View dbo.v_LichSuGiaoDichKho';
GO

-- =========================================================================
-- PHẦN 2: STORED PROCEDURE LỌC VÀ TRUY VẾT LỊCH SỬ LINH KIỆN
-- Tham số lọc linh hoạt: theo mã linh kiện, phiếu sửa, loại giao dịch, thời gian
-- =========================================================================
CREATE OR ALTER PROCEDURE dbo.sp_LichSuXuatNhapLinhKien
    @MaLinhKien     NVARCHAR(50)  = NULL,   -- Lọc theo mã linh kiện (PartCode)
    @TenLinhKien    NVARCHAR(200) = NULL,   -- Tìm theo tên (LIKE)
    @NhomLinhKien   NVARCHAR(100) = NULL,   -- Lọc theo nhóm/danh mục
    @LoaiGiaoDich   NVARCHAR(20)  = NULL,   -- IN / OUT / RETURN / ADJUST / NULL=tất cả
    @MaPhieu        NVARCHAR(50)  = NULL,   -- Lọc theo mã phiếu sửa chữa
    @NguoiThucHien  NVARCHAR(100) = NULL,   -- Lọc theo username người thực hiện
    @TuNgay         DATETIME2     = NULL,
    @DenNgay        DATETIME2     = NULL,
    @LoaiBaoCao     NVARCHAR(30)  = 'CHI_TIET',  -- CHI_TIET | TONG_HOP_LINH_KIEN | TONG_HOP_NGAY | BIEN_DONG
    @TrangHienTai   INT           = 1,
    @SoBanGhiTrang  INT           = 50
AS
BEGIN
    SET NOCOUNT ON;

    -- Xử lý mặc định khoảng thời gian
    IF @DenNgay IS NULL  SET @DenNgay = SYSDATETIME();
    IF @TuNgay IS NULL   SET @TuNgay  = DATEADD(DAY, -30, @DenNgay);

    -- Giới hạn phân trang an toàn
    IF @SoBanGhiTrang > 200 SET @SoBanGhiTrang = 200;
    IF @TrangHienTai  < 1   SET @TrangHienTai  = 1;

    DECLARE @Offset INT = (@TrangHienTai - 1) * @SoBanGhiTrang;

    -- ===========================================================
    -- TH1: CHI TIẾT TỪNG GIAO DỊCH (AUDIT TRAIL)
    -- ===========================================================
    IF @LoaiBaoCao = 'CHI_TIET'
    BEGIN
        SELECT
            v.MaGiaoDich,
            v.ThoiGianGiaoDich,
            v.MaLinhKien,
            v.TenLinhKien,
            v.NhomLinhKien,
            v.TenLoaiGiaoDich,
            v.SoLuong,
            v.TonTruoc,
            v.TonSau,
            v.BienDongTon,
            v.GiaTriGiaoDich,
            v.MaPhieuLienQuan,
            v.TenKhachHang,
            v.DichVuSuaChua,
            v.NguoiThucHien,
            v.VaiTroNguoiThucHien,
            v.GhiChu
        FROM dbo.v_LichSuGiaoDichKho v
        WHERE v.ThoiGianGiaoDich BETWEEN @TuNgay AND @DenNgay
          AND (@MaLinhKien      IS NULL OR v.MaLinhKien    = @MaLinhKien)
          AND (@TenLinhKien     IS NULL OR v.TenLinhKien   LIKE N'%' + @TenLinhKien + N'%')
          AND (@NhomLinhKien    IS NULL OR v.NhomLinhKien  = @NhomLinhKien)
          AND (@LoaiGiaoDich    IS NULL OR v.LoaiGiaoDich  = @LoaiGiaoDich)
          AND (@MaPhieu         IS NULL OR v.MaPhieuLienQuan = @MaPhieu)
          AND (@NguoiThucHien   IS NULL OR v.NguoiThucHien LIKE N'%' + @NguoiThucHien + N'%')
        ORDER BY v.ThoiGianGiaoDich DESC
        OFFSET @Offset ROWS FETCH NEXT @SoBanGhiTrang ROWS ONLY;
        RETURN 0;
    END

    -- ===========================================================
    -- TH2: TỔNG HỢP THEO LINH KIỆN (BIẾN ĐỘNG NHẬP/XUẤT)
    -- ===========================================================
    ELSE IF @LoaiBaoCao = 'TONG_HOP_LINH_KIEN'
    BEGIN
        SELECT
            v.MaLinhKien,
            v.TenLinhKien,
            v.NhomLinhKien,
            SUM(CASE WHEN v.LoaiGiaoDich = 'IN'     THEN v.SoLuong ELSE 0 END) AS TongSoLuongNhap,
            SUM(CASE WHEN v.LoaiGiaoDich = 'OUT'    THEN v.SoLuong ELSE 0 END) AS TongSoLuongXuat,
            SUM(CASE WHEN v.LoaiGiaoDich = 'RETURN' THEN v.SoLuong ELSE 0 END) AS TongSoLuongHoanTra,
            SUM(CASE WHEN v.LoaiGiaoDich = 'ADJUST' THEN v.BienDongTon ELSE 0 END) AS TongDieuChinh,
            SUM(CASE WHEN v.LoaiGiaoDich = 'IN'     THEN v.GiaTriGiaoDich ELSE 0 END)  AS TongTienNhap,
            SUM(CASE WHEN v.LoaiGiaoDich = 'OUT'    THEN v.GiaTriGiaoDich ELSE 0 END)  AS TongTienXuat,
            COUNT(*)                                                             AS TongSoGiaoDich,
            MAX(v.ThoiGianGiaoDich)                                             AS LanGiaoDichGanNhat
        FROM dbo.v_LichSuGiaoDichKho v
        WHERE v.ThoiGianGiaoDich BETWEEN @TuNgay AND @DenNgay
          AND (@MaLinhKien   IS NULL OR v.MaLinhKien  = @MaLinhKien)
          AND (@TenLinhKien  IS NULL OR v.TenLinhKien LIKE N'%' + @TenLinhKien + N'%')
          AND (@NhomLinhKien IS NULL OR v.NhomLinhKien = @NhomLinhKien)
        GROUP BY v.MaLinhKien, v.TenLinhKien, v.NhomLinhKien
        ORDER BY TongSoLuongXuat DESC;
        RETURN 0;
    END

    -- ===========================================================
    -- TH3: TỔNG HỢP THEO NGÀY (BIẾN ĐỘNG KHO HẰNG NGÀY)
    -- ===========================================================
    ELSE IF @LoaiBaoCao = 'TONG_HOP_NGAY'
    BEGIN
        SELECT
            CAST(v.ThoiGianGiaoDich AS DATE)                                    AS Ngay,
            SUM(CASE WHEN v.LoaiGiaoDich = 'IN'  THEN v.SoLuong ELSE 0 END)    AS TongNhap,
            SUM(CASE WHEN v.LoaiGiaoDich = 'OUT' THEN v.SoLuong ELSE 0 END)    AS TongXuat,
            SUM(CASE WHEN v.LoaiGiaoDich = 'RETURN' THEN v.SoLuong ELSE 0 END) AS TongHoanTra,
            COUNT(DISTINCT v.MaLinhKien)                                        AS SoLoaiLinhKien,
            COUNT(DISTINCT v.MaPhieuLienQuan)                                   AS SoPhieuPhatSinh,
            SUM(CASE WHEN v.LoaiGiaoDich = 'IN'  THEN v.GiaTriGiaoDich ELSE 0 END) AS TienNhap,
            SUM(CASE WHEN v.LoaiGiaoDich = 'OUT' THEN v.GiaTriGiaoDich ELSE 0 END) AS TienXuat
        FROM dbo.v_LichSuGiaoDichKho v
        WHERE v.ThoiGianGiaoDich BETWEEN @TuNgay AND @DenNgay
          AND (@LoaiGiaoDich IS NULL OR v.LoaiGiaoDich = @LoaiGiaoDich)
        GROUP BY CAST(v.ThoiGianGiaoDich AS DATE)
        ORDER BY Ngay DESC;
        RETURN 0;
    END

    -- ===========================================================
    -- TH4: BIẾN ĐỘNG TỒN KHO - TRUY VẾT TỪNG LINH KIỆN CỤ THỂ
    -- (Dạng sổ nhật ký: tồn đầu kỳ → các giao dịch → tồn cuối kỳ)
    -- ===========================================================
    ELSE IF @LoaiBaoCao = 'BIEN_DONG'
    BEGIN
        IF @MaLinhKien IS NULL
        BEGIN
            RAISERROR(N'Loại báo cáo BIEN_DONG yêu cầu @MaLinhKien cụ thể.', 16, 1);
            RETURN -1;
        END

        -- Tồn kho đầu kỳ (snapshot trước @TuNgay)
        DECLARE @TonDauKy INT;
        SELECT @TonDauKy = COALESCE(
            (
                SELECT TOP 1 tx.StockAfter
                FROM dbo.StockTransactions tx
                JOIN dbo.SpareParts p ON p.PartId = tx.PartId
                WHERE p.PartCode = @MaLinhKien
                  AND tx.TransactionAt < @TuNgay
                ORDER BY tx.TransactionAt DESC
            ),
            (SELECT StockQuantity FROM dbo.SpareParts WHERE PartCode = @MaLinhKien),
            0
        );

        -- Trả về header tồn đầu kỳ
        SELECT
            0                               AS MaGiaoDich,
            @TuNgay                         AS ThoiGianGiaoDich,
            @MaLinhKien                     AS MaLinhKien,
            N'--- TỒN ĐẦU KỲ ---'          AS TenLoaiGiaoDich,
            0                               AS SoLuong,
            @TonDauKy                       AS TonTruoc,
            @TonDauKy                       AS TonSau,
            N''                             AS NguoiThucHien,
            N''                             AS MaPhieuLienQuan;

        -- Chi tiết từng giao dịch trong kỳ
        SELECT
            v.MaGiaoDich,
            v.ThoiGianGiaoDich,
            v.MaLinhKien,
            v.TenLoaiGiaoDich,
            v.SoLuong,
            v.TonTruoc,
            v.TonSau,
            v.NguoiThucHien,
            v.MaPhieuLienQuan
        FROM dbo.v_LichSuGiaoDichKho v
        WHERE v.MaLinhKien = @MaLinhKien
          AND v.ThoiGianGiaoDich BETWEEN @TuNgay AND @DenNgay
        ORDER BY v.ThoiGianGiaoDich ASC;

        RETURN 0;
    END

    ELSE
    BEGIN
        RAISERROR(N'Loại báo cáo không hợp lệ. Chọn: CHI_TIET, TONG_HOP_LINH_KIEN, TONG_HOP_NGAY, BIEN_DONG.', 16, 1);
        RETURN -2;
    END
END;
GO
PRINT N'>> [ĐÃ TẠO]: sp_LichSuXuatNhapLinhKien';
GO

-- =========================================================================
-- PHẦN 3: STORED PROCEDURE KIỂM TRA SỰ KHÁC BIỆT / CHÊNH LỆCH KHO
-- Mục đích: Đối chiếu tổng giao dịch với tồn kho hiện tại để phát hiện lỗi
-- =========================================================================
CREATE OR ALTER PROCEDURE dbo.sp_DoiChieuTonKho
AS
BEGIN
    SET NOCOUNT ON;

    PRINT N'>> Đang đối chiếu tồn kho thực tế vs tổng các giao dịch...';

    SELECT
        p.PartCode                  AS MaLinhKien,
        p.PartName                  AS TenLinhKien,
        p.StockQuantity             AS TonHienTai,
        -- Tính lại từ giao dịch: nhập + hoàn trả - xuất + điều chỉnh
        ISNULL(SUM(CASE
            WHEN tx.TransactionType = 'IN'     THEN  tx.Quantity
            WHEN tx.TransactionType = 'OUT'    THEN -tx.Quantity
            WHEN tx.TransactionType = 'RETURN' THEN  tx.Quantity
            WHEN tx.TransactionType = 'ADJUST' THEN (tx.StockAfter - tx.StockBefore)
            ELSE 0
        END), 0)                    AS TonTinhTuGiaoDich,
        -- Chênh lệch
        p.StockQuantity - ISNULL(SUM(CASE
            WHEN tx.TransactionType = 'IN'     THEN  tx.Quantity
            WHEN tx.TransactionType = 'OUT'    THEN -tx.Quantity
            WHEN tx.TransactionType = 'RETURN' THEN  tx.Quantity
            WHEN tx.TransactionType = 'ADJUST' THEN (tx.StockAfter - tx.StockBefore)
            ELSE 0
        END), 0)                    AS ChenhLech,
        COUNT(tx.TransactionId)     AS TongGiaoDich,
        CASE
            WHEN p.StockQuantity = ISNULL(SUM(CASE
                WHEN tx.TransactionType = 'IN'     THEN  tx.Quantity
                WHEN tx.TransactionType = 'OUT'    THEN -tx.Quantity
                WHEN tx.TransactionType = 'RETURN' THEN  tx.Quantity
                WHEN tx.TransactionType = 'ADJUST' THEN (tx.StockAfter - tx.StockBefore)
                ELSE 0
            END), 0) THEN N'KHỚP'
            ELSE N'⚠ CHÊNH LỆCH - Cần kiểm tra!'
        END                         AS KetQuaDoiChieu
    FROM dbo.SpareParts p
    LEFT JOIN dbo.StockTransactions tx ON tx.PartId = p.PartId
    WHERE p.IsActive = 1
    GROUP BY p.PartId, p.PartCode, p.PartName, p.StockQuantity
    ORDER BY ABS(p.StockQuantity - ISNULL(SUM(CASE
        WHEN tx.TransactionType = 'IN'     THEN  tx.Quantity
        WHEN tx.TransactionType = 'OUT'    THEN -tx.Quantity
        WHEN tx.TransactionType = 'RETURN' THEN  tx.Quantity
        WHEN tx.TransactionType = 'ADJUST' THEN (tx.StockAfter - tx.StockBefore)
        ELSE 0
    END), 0)) DESC;
END;
GO
PRINT N'>> [ĐÃ TẠO]: sp_DoiChieuTonKho';
GO

-- =========================================================================
-- PHẦN 4: KỊCH BẢN KIỂM THỬ
-- =========================================================================
PRINT N'-------------------------------------------------------------------------';
PRINT N'TEST 1: Lịch sử giao dịch 30 ngày gần nhất (CHI_TIET)';
PRINT N'-------------------------------------------------------------------------';
EXEC dbo.sp_LichSuXuatNhapLinhKien @LoaiBaoCao = 'CHI_TIET';
GO

PRINT N'-------------------------------------------------------------------------';
PRINT N'TEST 2: Tổng hợp biến động theo linh kiện';
PRINT N'-------------------------------------------------------------------------';
EXEC dbo.sp_LichSuXuatNhapLinhKien @LoaiBaoCao = 'TONG_HOP_LINH_KIEN';
GO

PRINT N'-------------------------------------------------------------------------';
PRINT N'TEST 3: Tổng hợp biến động theo ngày';
PRINT N'-------------------------------------------------------------------------';
EXEC dbo.sp_LichSuXuatNhapLinhKien @LoaiBaoCao = 'TONG_HOP_NGAY';
GO

PRINT N'-------------------------------------------------------------------------';
PRINT N'TEST 4: Đối chiếu tồn kho – phát hiện chênh lệch';
PRINT N'-------------------------------------------------------------------------';
EXEC dbo.sp_DoiChieuTonKho;
GO

PRINT N'=========================================================================';
PRINT N'HOÀN TẤT SCRIPT MBA-65: LỊCH SỬ XUẤT NHẬP LINH KIỆN - TRẦN NGỌC LỢI';
PRINT N'=========================================================================';
GO
GO
USE RepairShopDB;
GO

/* ---- sp_DoLuongHieuNang, sp_BenchmarkTruyVan + index hiệu năng ---- */
/* =========================================================================
   NHÓM 11 - DỰ ÁN QUẢN LÝ CỬA HÀNG SỬA CHỮA (LV33-001)
   MODULE: ĐO LƯỜNG VÀ TỐI ƯU HIỆU NĂNG TRUY VẤN SQL SERVER
   TÁC GIẢ: NGUYỄN VIỆT LAM (PM / DEV LEAD) - TASK JIRA: MBA-79
   TÊN TÁC VỤ: ĐO LƯỜNG VÀ TỐI ƯU HIỆU NĂNG TRUY VẤN SQL SERVER
   CSDL: SQL Server 2022 | Database: RepairShopDB
   ========================================================================= */

IF DB_ID('RepairShopDB') IS NOT NULL
    USE RepairShopDB;
ELSE IF DB_ID('RepairShopDB') IS NOT NULL
    USE RepairShopDB;
GO

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

PRINT N'=========================================================================';
PRINT N'MBA-79: ĐO LƯỜNG VÀ TỐI ƯU HIỆU NĂNG TRUY VẤN SQL SERVER';
PRINT N'Người thực hiện: Nguyễn Việt Lam (PM / Dev Lead - Nhóm 11)';
PRINT N'=========================================================================';
GO

-- =========================================================================
-- PHẦN 1: BẬT THỐNG KÊ HIỆU NĂNG ĐỂ ĐO LƯỜNG (SET STATISTICS)
-- Mục đích: Ghi lại thời gian thực thi và số lần đọc I/O của từng truy vấn
--           trước và sau khi tối ưu để so sánh hiệu quả.
-- =========================================================================
PRINT N'>> Phần 1: Cấu hình đo lường hiệu năng...';
GO

-- Bật đo thời gian và I/O (chỉ chạy trong session đo lường, không dùng production)
SET STATISTICS TIME ON;
SET STATISTICS IO ON;
GO

-- =========================================================================
-- PHẦN 2: BASELINE TRUY VẤN TRƯỚC KHI TỐI ƯU
-- Mục đích: Ghi lại hiệu năng gốc (baseline) của các truy vấn phổ biến
--           trong hệ thống để có điểm so sánh sau khi tối ưu.
-- =========================================================================
PRINT N'-------------------------------------------------------------------------';
PRINT N'PHẦN 2: BASELINE - Truy vấn phổ biến TRƯỚC tối ưu';
PRINT N'-------------------------------------------------------------------------';
GO

-- [BL-01] BASELINE: Danh sách phiếu sửa chữa lọc theo trạng thái (không dùng index composite)
-- Đây là truy vấn hay xuất hiện trong dashboard → cần nhanh
PRINT N'>> [BL-01] Baseline: Lọc phiếu theo trạng thái REPAIRING';
SELECT
    t.TicketId,
    t.TicketCode,
    c.FullName      AS TenKhachHang,
    c.Phone,
    st.ServiceName  AS LoaiDichVu,
    u.FullName      AS KyThuatVien,
    t.ReceivedAt,
    t.Status
FROM dbo.RepairTickets t
JOIN dbo.Customers   c  ON c.CustomerId   = t.CustomerId
JOIN dbo.ServiceTypes st ON st.ServiceTypeId = t.ServiceTypeId
LEFT JOIN dbo.Users  u  ON u.UserId       = t.TechnicianUserId
WHERE t.Status = 'REPAIRING'
ORDER BY t.ReceivedAt DESC;
GO

-- [BL-02] BASELINE: Báo cáo doanh thu tháng hiện tại (không dùng cache)
PRINT N'>> [BL-02] Baseline: Doanh thu tháng hiện tại (không cache)';
DECLARE @thang1Start DATE = DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1);
DECLARE @thang1End   DATE = EOMONTH(GETDATE());
SELECT
    SUM(TotalAmount)    AS TongDoanhThu,
    COUNT(*)            AS SoHoaDon,
    AVG(TotalAmount)    AS TrungBinhHoaDon
FROM dbo.Invoices
WHERE PaymentStatus = 'PAID'
  AND CAST(CreatedAt AS DATE) BETWEEN @thang1Start AND @thang1End;
GO

-- [BL-03] BASELINE: Top kỹ thuật viên theo số phiếu hoàn thành (full scan)
PRINT N'>> [BL-03] Baseline: Top KTV theo số phiếu (full scan)';
SELECT
    u.FullName              AS TenKyThuatVien,
    COUNT(t.TicketId)       AS SoPhieuHoanThanh,
    ISNULL(SUM(i.TotalAmount), 0) AS TongDoanhThu
FROM dbo.Users u
JOIN dbo.RepairTickets t ON t.TechnicianUserId = u.UserId
LEFT JOIN dbo.Invoices  i ON i.TicketId = t.TicketId AND i.PaymentStatus = 'PAID'
WHERE t.Status IN ('COMPLETED', 'DELIVERED')
GROUP BY u.UserId, u.FullName
ORDER BY SoPhieuHoanThanh DESC;
GO

SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;
GO

-- =========================================================================
-- PHẦN 3: PHÂN TÍCH EXECUTION PLAN VÀ MISSING INDEX
-- Mục đích: Truy xuất các index "bị thiếu" mà SQL Server đề xuất
--           thông qua Dynamic Management Views (DMV).
-- =========================================================================
PRINT N'-------------------------------------------------------------------------';
PRINT N'PHẦN 3: Missing Index - DMV Analysis';
PRINT N'-------------------------------------------------------------------------';
GO

-- [MI-01] Danh sách index bị thiếu mà SQL Server đề xuất, sắp xếp theo mức cải thiện dự kiến
SELECT TOP 20
    mig.index_group_handle AS index_group_id,
    mid.object_id,
    OBJECT_NAME(mid.object_id)              AS TenBang,
    mid.equality_columns                    AS CotBangNhau,
    mid.inequality_columns                  AS CotKhongBangNhau,
    mid.included_columns                    AS CotInclude,
    migs.user_seeks                         AS SoLanTimKiem,
    migs.user_scans                         AS SoLanQuet,
    CAST(migs.avg_user_impact AS DECIMAL(6,2)) AS CaiThienDuKien_Pct,
    CAST(migs.avg_total_user_cost AS DECIMAL(10,4)) AS ChiPhiTrungBinh,
    -- Điểm ưu tiên = chi phí × (seeks + scans) × mức cải thiện
    CAST(
        migs.avg_total_user_cost * (migs.user_seeks + migs.user_scans) * migs.avg_user_impact / 100.0
    AS DECIMAL(14,2))                       AS DiemUuTien,
    -- Script tạo index gợi ý
    N'CREATE NONCLUSTERED INDEX [IX_' + OBJECT_NAME(mid.object_id)
        + ISNULL('_' + REPLACE(mid.equality_columns, N', ', N'_'), N'')
        + ISNULL('_' + REPLACE(mid.inequality_columns, N', ', N'_'), N'')
        + N'] ON dbo.' + QUOTENAME(OBJECT_NAME(mid.object_id))
        + N' (' + ISNULL(mid.equality_columns, N'') 
        + CASE WHEN mid.equality_columns IS NOT NULL AND mid.inequality_columns IS NOT NULL THEN N', ' ELSE N'' END
        + ISNULL(mid.inequality_columns, N'')
        + N')' + ISNULL(N' INCLUDE (' + mid.included_columns + N')', N'')
        + N';'                              AS ScriptTaoIndex
FROM sys.dm_db_missing_index_groups mig
JOIN sys.dm_db_missing_index_group_stats migs
    ON migs.group_handle = mig.index_group_handle
JOIN sys.dm_db_missing_index_details mid
    ON mid.index_handle = mig.index_handle
WHERE mid.database_id = DB_ID()
ORDER BY DiemUuTien DESC;
GO

-- =========================================================================
-- PHẦN 4: STORED PROCEDURE ĐO LƯỜNG HIỆU NĂNG TỔNG HỢP
-- Mục đích: SP tập trung thu thập metrics quan trọng để theo dõi định kỳ
-- =========================================================================
PRINT N'>> Phần 4: Tạo stored procedure đo lường tổng hợp...';
GO

CREATE OR ALTER PROCEDURE dbo.sp_DoLuongHieuNang
    @CheDo NVARCHAR(30) = 'ALL'
    -- 'ALL'       : Chạy tất cả phân tích
    -- 'INDEX'     : Chỉ phân tích index usage + missing
    -- 'QUERY'     : Chỉ phân tích top slow queries
    -- 'TABLE'     : Chỉ phân tích kích thước bảng
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @DanhSachBang TABLE (TenBang NVARCHAR(128));
    INSERT INTO @DanhSachBang VALUES
        (N'RepairTickets'), (N'Invoices'), (N'SpareParts'),
        (N'StockTransactions'), (N'Users'), (N'Customers'),
        (N'Warranties'), (N'TicketParts'), (N'TicketStatusHistory');

    -- -------------------------------------------------------------------
    -- [A] KẾT QUẢ 1: Kích thước và số dòng từng bảng
    -- -------------------------------------------------------------------
    IF @CheDo IN ('ALL', 'TABLE')
    BEGIN
        PRINT N'>> [A] Kích thước bảng và số bản ghi:';
        SELECT
            t.NAME                          AS TenBang,
            p.rows                          AS SoBanGhi,
            CAST(SUM(a.total_pages) * 8.0 / 1024 AS DECIMAL(10,2)) AS TongDungLuong_MB,
            CAST(SUM(a.used_pages)  * 8.0 / 1024 AS DECIMAL(10,2)) AS DungLuongDuLieu_MB,
            CAST((SUM(a.total_pages) - SUM(a.used_pages)) * 8.0 / 1024 AS DECIMAL(10,2)) AS DungLuongIndex_MB
        FROM sys.tables t
        JOIN sys.indexes i      ON t.OBJECT_ID = i.object_id
        JOIN sys.partitions p   ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
        JOIN sys.allocation_units a ON p.partition_id = a.container_id
        WHERE t.NAME IN (SELECT TenBang FROM @DanhSachBang)
          AND t.is_ms_shipped = 0
        GROUP BY t.Name, p.Rows
        ORDER BY TongDungLuong_MB DESC;
    END

    -- -------------------------------------------------------------------
    -- [B] KẾT QUẢ 2: Mức sử dụng Index (seeks, scans, lookups, updates)
    -- -------------------------------------------------------------------
    IF @CheDo IN ('ALL', 'INDEX')
    BEGIN
        PRINT N'>> [B] Index Usage Statistics:';
        SELECT
            OBJECT_NAME(s.object_id)            AS TenBang,
            i.name                              AS TenIndex,
            i.type_desc                         AS LoaiIndex,
            s.user_seeks                        AS TimKiem,
            s.user_scans                        AS QuetToan,
            s.user_lookups                      AS TraCuu,
            s.user_updates                      AS CapNhat,
            s.last_user_seek                    AS LanCuoiTimKiem,
            s.last_user_scan                    AS LanCuoiQuet,
            -- Tỷ lệ chi phí bảo trì: nếu > 10 → xem xét bỏ index
            CAST(
                CASE WHEN (s.user_seeks + s.user_scans + s.user_lookups) > 0
                THEN s.user_updates * 1.0 / (s.user_seeks + s.user_scans + s.user_lookups)
                ELSE 999.0 END
            AS DECIMAL(8,2))                    AS TyLeChiPhiBaoTri,
            CASE
                WHEN (s.user_seeks + s.user_scans + s.user_lookups) = 0
                     AND s.user_updates > 0     THEN N'⚠ Không dùng - xem xét xóa'
                WHEN s.user_seeks + s.user_scans + s.user_lookups > 100
                     AND s.user_updates * 1.0 /
                         (s.user_seeks + s.user_scans + s.user_lookups) > 10
                                                THEN N'⚠ Chi phí bảo trì cao'
                WHEN s.user_seeks > 1000        THEN N'✓ Hiệu quả cao'
                ELSE                                 N'- Bình thường'
            END                                 AS DanhGia
        FROM sys.dm_db_index_usage_stats s
        JOIN sys.indexes i ON i.object_id = s.object_id AND i.index_id = s.index_id
        WHERE s.database_id = DB_ID()
          AND OBJECT_NAME(s.object_id) IN (SELECT TenBang FROM @DanhSachBang)
          AND i.name IS NOT NULL
        ORDER BY (s.user_seeks + s.user_scans) DESC;
    END

    -- -------------------------------------------------------------------
    -- [C] KẾT QUẢ 3: Top 20 truy vấn chậm nhất (Query Store / Plan Cache)
    -- -------------------------------------------------------------------
    IF @CheDo IN ('ALL', 'QUERY')
    BEGIN
        PRINT N'>> [C] Top 20 truy vấn chậm nhất từ Plan Cache:';
        SELECT TOP 20
            SUBSTRING(qt.text, (qs.statement_start_offset/2)+1,
                ((CASE qs.statement_end_offset
                    WHEN -1 THEN DATALENGTH(qt.text)
                    ELSE qs.statement_end_offset
                  END - qs.statement_start_offset)/2)+1)   AS NoiDungTruyVan,
            qs.execution_count                             AS SoLanChay,
            CAST(qs.total_elapsed_time / 1000.0 AS DECIMAL(14,2)) AS TongThoiGian_ms,
            CAST(qs.total_elapsed_time * 1.0 / qs.execution_count / 1000.0
                AS DECIMAL(14,2))                          AS TrungBinhThoiGian_ms,
            CAST(qs.total_worker_time / 1000.0 AS DECIMAL(14,2))  AS TongCPU_ms,
            CAST(qs.total_logical_reads AS BIGINT)         AS TongDocLogical,
            CAST(qs.total_logical_reads * 1.0 / qs.execution_count
                AS DECIMAL(14,2))                          AS TrungBinhDocLogical,
            qs.last_execution_time                         AS LanCuoiChay,
            qp.query_plan                                  AS KeFhoachThucThi
        FROM sys.dm_exec_query_stats qs
        CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle)  qt
        CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp
        WHERE qt.text NOT LIKE '%sys.%'
          AND qt.text NOT LIKE '%dm_exec%'
          AND qs.execution_count > 1
        ORDER BY TrungBinhThoiGian_ms DESC;
    END

    -- -------------------------------------------------------------------
    -- [D] KẾT QUẢ 4: Phân mảnh Index hiện tại
    -- -------------------------------------------------------------------
    IF @CheDo IN ('ALL', 'INDEX')
    BEGIN
        PRINT N'>> [D] Phân tích phân mảnh Index:';
        SELECT
            OBJECT_NAME(ips.object_id)      AS TenBang,
            i.name                          AS TenIndex,
            i.type_desc                     AS LoaiIndex,
            CAST(ips.avg_fragmentation_in_percent AS DECIMAL(6,2)) AS PhanManh_Pct,
            ips.page_count                  AS SoTrang,
            ips.record_count                AS SoBanGhi,
            CASE
                WHEN ips.avg_fragmentation_in_percent < 5  THEN N'✓ OK'
                WHEN ips.avg_fragmentation_in_percent < 30 THEN N'⚠ REORGANIZE'
                ELSE                                            N'✗ REBUILD'
            END                             AS HanhDongDeXuat,
            -- Script bảo trì tương ứng
            CASE
                WHEN ips.avg_fragmentation_in_percent >= 30
                    THEN N'ALTER INDEX [' + i.name + N'] ON dbo.[' + OBJECT_NAME(ips.object_id) + N'] REBUILD WITH (ONLINE = OFF);'
                WHEN ips.avg_fragmentation_in_percent >= 5
                    THEN N'ALTER INDEX [' + i.name + N'] ON dbo.[' + OBJECT_NAME(ips.object_id) + N'] REORGANIZE;'
                ELSE N'-- Không cần bảo trì'
            END                             AS ScriptBaoTri
        FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'LIMITED') ips
        JOIN sys.indexes i ON i.object_id = ips.object_id AND i.index_id = ips.index_id
        WHERE ips.page_count > 50
          AND i.name IS NOT NULL
          AND OBJECT_NAME(ips.object_id) IN (SELECT TenBang FROM @DanhSachBang)
        ORDER BY ips.avg_fragmentation_in_percent DESC;
    END

END;
GO
PRINT N'>> [ĐÃ TẠO]: sp_DoLuongHieuNang (Đo lường & phân tích toàn diện)';
GO

-- =========================================================================
-- PHẦN 5: STORED PROCEDURE ĐO LƯỜNG TRUY VẤN CỤ THỂ (BENCHMARK)
-- Mục đích: Đo thời gian thực thi thực tế của một truy vấn cụ thể,
--           chạy N lần và trả về min/max/avg để so sánh trước-sau tối ưu.
-- =========================================================================
CREATE OR ALTER PROCEDURE dbo.sp_BenchmarkTruyVan
    @TenTruyVan     NVARCHAR(100),       -- Tên mô tả truy vấn đang đo
    @SoLanChay      INT = 5,             -- Chạy bao nhiêu lần (mặc định 5)
    @TrangThai      NVARCHAR(20) = NULL, -- Tham số lọc trạng thái (tuỳ chọn)
    @TuNgay         DATE = NULL,
    @DenNgay        DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Bảng tạm lưu kết quả từng lần chạy
    CREATE TABLE #KetQuaBenchmark (
        LanChay     INT,
        ThoiGian_ms BIGINT,
        SoLanDocIO  BIGINT
    );

    DECLARE @i INT = 1;
    DECLARE @t1 DATETIME2, @t2 DATETIME2, @ms BIGINT;
    DECLARE @dem INT;

    WHILE @i <= @SoLanChay
    BEGIN
        SET @t1 = SYSDATETIME();

        -- Truy vấn mẫu: lọc phiếu sửa chữa (đại diện cho các query phổ biến)
        SELECT @dem = COUNT(*)
        FROM dbo.RepairTickets t WITH (NOLOCK)
        JOIN dbo.Customers c WITH (NOLOCK) ON c.CustomerId = t.CustomerId
        LEFT JOIN dbo.Invoices i WITH (NOLOCK) ON i.TicketId = t.TicketId
        WHERE (@TrangThai IS NULL OR t.Status = @TrangThai)
          AND (@TuNgay    IS NULL OR CAST(t.ReceivedAt AS DATE) >= @TuNgay)
          AND (@DenNgay   IS NULL OR CAST(t.ReceivedAt AS DATE) <= @DenNgay);

        SET @t2 = SYSDATETIME();
        SET @ms = DATEDIFF(MICROSECOND, @t1, @t2) / 1000;

        INSERT INTO #KetQuaBenchmark VALUES (@i, @ms, @dem);
        SET @i = @i + 1;
    END

    -- Trả về kết quả benchmark
    SELECT
        @TenTruyVan         AS TenTruyVan,
        @SoLanChay          AS SoLanChay,
        MIN(ThoiGian_ms)    AS ThoiGianNhoNhat_ms,
        MAX(ThoiGian_ms)    AS ThoiGianLonNhat_ms,
        AVG(ThoiGian_ms)    AS ThoiGianTrungBinh_ms,
        SUM(ThoiGian_ms)    AS TongThoiGian_ms
    FROM #KetQuaBenchmark;

    DROP TABLE #KetQuaBenchmark;
END;
GO
PRINT N'>> [ĐÃ TẠO]: sp_BenchmarkTruyVan (Đo thời gian thực thi N lần)';
GO

-- =========================================================================
-- PHẦN 6: TỐI ƯU BỔ SUNG - INDEX COMPOSITE MỚI DỰA TRÊN ĐO LƯỜNG
-- Mục đích: Thêm các index tổng hợp mới nhắm vào các truy vấn phổ biến
--           được phát hiện qua phân tích ở Phần 2-3.
-- =========================================================================
PRINT N'>> Phần 6: Bổ sung Index composite dựa trên phân tích đo lường...';
GO

-- [IX-NEW-01] Index composite cho RepairTickets: lọc Status + khoảng ngày
-- Phục vụ truy vấn báo cáo tiến độ theo ngày (hay dùng trong dashboard)
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID('dbo.RepairTickets')
      AND name = 'IX_RepairTickets_Status_ReceivedAt_Tech'
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_RepairTickets_Status_ReceivedAt_Tech
    ON dbo.RepairTickets (Status, ReceivedAt DESC, TechnicianUserId)
    INCLUDE (TicketCode, CustomerId, ServiceTypeId, QuotedLaborCost, QuotedPartsCost, CompletedAt)
    WITH (FILLFACTOR = 85, ONLINE = OFF, STATISTICS_NORECOMPUTE = OFF);
    PRINT N'>> [ĐÃ TẠO]: IX_RepairTickets_Status_ReceivedAt_Tech';
END
ELSE
    PRINT N'>> [EXISTED]: IX_RepairTickets_Status_ReceivedAt_Tech';
GO

-- [IX-NEW-02] Index cho Invoices: lọc PaymentStatus + ngày thanh toán
-- Phục vụ báo cáo doanh thu theo ngày/tháng
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID('dbo.Invoices')
      AND name = 'IX_Invoices_PaymentStatus_PaidAt'
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_Invoices_PaymentStatus_PaidAt
    ON dbo.Invoices (PaymentStatus, PaidAt DESC)
    INCLUDE (TicketId, CustomerId, LaborCost, PartsCost, DiscountAmount, TotalAmount, CreatedByUserId)
    WITH (FILLFACTOR = 85, ONLINE = OFF);
    PRINT N'>> [ĐÃ TẠO]: IX_Invoices_PaymentStatus_PaidAt';
END
ELSE
    PRINT N'>> [EXISTED]: IX_Invoices_PaymentStatus_PaidAt';
GO

-- [IX-NEW-03] Index cho Customers: tìm kiếm theo tên và số điện thoại
-- Phục vụ chức năng tra cứu khách hàng nhanh từ quầy tiếp nhận
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID('dbo.Customers')
      AND name = 'IX_Customers_Phone_IsActive'
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_Customers_Phone_IsActive
    ON dbo.Customers (Phone, IsActive)
    INCLUDE (CustomerCode, FullName, Email, Address)
    WITH (FILLFACTOR = 90, ONLINE = OFF);
    PRINT N'>> [ĐÃ TẠO]: IX_Customers_Phone_IsActive';
END
ELSE
    PRINT N'>> [EXISTED]: IX_Customers_Phone_IsActive';
GO

-- [IX-NEW-04] Index cho Warranties: tra cứu bảo hành theo khách hàng + ngày hết hạn
-- Phục vụ màn hình tra cứu bảo hành và cảnh báo sắp hết hạn
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID('dbo.Warranties')
      AND name = 'IX_Warranties_CustomerId_EndDate_Status'
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_Warranties_CustomerId_EndDate_Status
    ON dbo.Warranties (CustomerId, EndDate DESC, Status)
    INCLUDE (WarrantyCode, TicketId, DeviceId, StartDate, Scope)
    WITH (FILLFACTOR = 85, ONLINE = OFF);
    PRINT N'>> [ĐÃ TẠO]: IX_Warranties_CustomerId_EndDate_Status';
END
ELSE
    PRINT N'>> [EXISTED]: IX_Warranties_CustomerId_EndDate_Status';
GO

-- [IX-NEW-05] Index cho TicketStatusHistory: tra cứu lịch sử theo phiếu + thời gian
-- Phục vụ chức năng xem timeline trạng thái phiếu
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID('dbo.TicketStatusHistory')
      AND name = 'IX_TicketStatusHistory_TicketId_ChangedAt'
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_TicketStatusHistory_TicketId_ChangedAt
    ON dbo.TicketStatusHistory (TicketId, ChangedAt DESC)
    INCLUDE (FromStatus, ToStatus, ChangedByUserId, Note)
    WITH (FILLFACTOR = 85, ONLINE = OFF);
    PRINT N'>> [ĐÃ TẠO]: IX_TicketStatusHistory_TicketId_ChangedAt';
END
ELSE
    PRINT N'>> [EXISTED]: IX_TicketStatusHistory_TicketId_ChangedAt';
GO

-- =========================================================================
-- PHẦN 7: STORED PROCEDURE KIỂM TRA SỨC KHỎE DATABASE (HEALTH CHECK)
-- Mục đích: Chạy định kỳ (tuần/tháng) để đánh giá tổng thể hiệu năng DB
-- =========================================================================
CREATE OR ALTER PROCEDURE dbo.sp_KiemTraSucKhoeDB
AS
BEGIN
    SET NOCOUNT ON;

    PRINT N'====================================================================='
    PRINT N'BÁO CÁO SỨC KHỎE DATABASE: ' + DB_NAME() + N' lúc ' + CONVERT(NVARCHAR(30), SYSDATETIME(), 120);
    PRINT N'=====================================================================';

    -- [1] Kích thước tổng database
    PRINT N'>> [1] Thông tin Database:';
    SELECT
        name                        AS TenFile,
        type_desc                   AS LoaiFile,
        CAST(size * 8.0 / 1024 AS DECIMAL(10,2)) AS KichThuoc_MB,
        CAST(FILEPROPERTY(name, 'SpaceUsed') * 8.0 / 1024 AS DECIMAL(10,2)) AS DaYeu_MB,
        physical_name               AS DuongDan
    FROM sys.database_files;

    -- [2] Top 5 bảng lớn nhất
    PRINT N'>> [2] Top 5 bảng lớn nhất:';
    SELECT TOP 5
        t.name                      AS TenBang,
        p.rows                      AS SoBanGhi,
        CAST(SUM(a.total_pages) * 8.0 / 1024 AS DECIMAL(10,2)) AS DungLuong_MB
    FROM sys.tables t
    JOIN sys.indexes i    ON t.OBJECT_ID = i.object_id  AND i.index_id < 2
    JOIN sys.partitions p ON i.object_id = p.OBJECT_ID  AND i.index_id = p.index_id
    JOIN sys.allocation_units a ON p.partition_id = a.container_id
    WHERE t.is_ms_shipped = 0
    GROUP BY t.name, p.rows
    ORDER BY DungLuong_MB DESC;

    -- [3] Số lượng kết nối hiện tại
    PRINT N'>> [3] Kết nối hiện tại:';
    SELECT
        DB_NAME(database_id)        AS TenDatabase,
        COUNT(*)                    AS SoKetNoi,
        SUM(CASE WHEN status='running' THEN 1 ELSE 0 END) AS DangChay,
        SUM(CASE WHEN status='sleeping' THEN 1 ELSE 0 END) AS DangNgu
    FROM sys.dm_exec_sessions
    WHERE is_user_process = 1
    GROUP BY database_id
    ORDER BY SoKetNoi DESC;

    -- [4] Deadlock và Wait Stats gần đây
    PRINT N'>> [4] Wait Stats hàng đầu:';
    SELECT TOP 10
        wait_type                   AS LoaiWait,
        waiting_tasks_count         AS SoTaskDangCho,
        CAST(wait_time_ms / 1000.0 AS DECIMAL(14,2)) AS TongCho_s,
        CAST(wait_time_ms * 1.0 / NULLIF(waiting_tasks_count, 0) AS DECIMAL(10,2)) AS TrungBinhCho_ms
    FROM sys.dm_os_wait_stats
    WHERE wait_type NOT IN (
        'SLEEP_TASK','BROKER_TO_FLUSH','BROKER_TASK_STOP','CLR_AUTO_EVENT',
        'DISPATCHER_QUEUE_SEMAPHORE','FT_IFTS_SCHEDULER_IDLE_WAIT',
        'HADR_FILESTREAM_IOMGR_IOCOMPLETION','HADR_WORK_QUEUE',
        'ONDEMAND_TASK_QUEUE','REQUEST_FOR_DEADLOCK_SEARCH',
        'RESOURCE_QUEUE','SERVER_IDLE_CHECK','SLEEP_DBSTARTUP',
        'SLEEP_DBTIMEDELTA','SLEEP_MASTERDBREADY','SLEEP_MASTERMDREADY',
        'SLEEP_MASTERUPGRADED','SLEEP_MSDBSTARTUP','SLEEP_SYSTEMTASK',
        'SLEEP_TEMPDBSTARTUP','SNI_HTTP_ACCEPT','SP_SERVER_DIAGNOSTICS_SLEEP',
        'SQLTRACE_BUFFER_FLUSH','WAITFOR','XE_DISPATCHER_WAIT',
        'XE_TIMER_EVENT','BROKER_EVENTHANDLER','CHECKPOINT_QUEUE',
        'DBMIRROR_EVENTS_QUEUE','SQLTRACE_INCREMENTAL_FLUSH_SLEEP',
        'WAIT_XTP_OFFLINE_CKPT_NEW_LOG'
    )
    ORDER BY wait_time_ms DESC;

    -- [5] Buffer cache hit ratio (>95% là tốt)
    PRINT N'>> [5] Buffer Cache Hit Ratio:';
    SELECT
        CAST(
            (cntr_value * 1.0)
            / NULLIF((SELECT cntr_value FROM sys.dm_os_performance_counters
                      WHERE counter_name = 'Buffer cache hit ratio base'
                        AND object_name LIKE '%Buffer Manager%'), 0) * 100.0
        AS DECIMAL(6,2))            AS BufferCacheHitRatio_Pct,
        CASE
            WHEN (cntr_value * 1.0)
                 / NULLIF((SELECT cntr_value FROM sys.dm_os_performance_counters
                           WHERE counter_name = 'Buffer cache hit ratio base'
                             AND object_name LIKE '%Buffer Manager%'), 0) * 100.0 >= 95
            THEN N'✓ Tốt (>= 95%)'
            ELSE N'⚠ Cần xem xét tăng RAM (< 95%)'
        END                         AS DanhGia
    FROM sys.dm_os_performance_counters
    WHERE counter_name = 'Buffer cache hit ratio'
      AND object_name LIKE '%Buffer Manager%';

    PRINT N'>> Kiểm tra sức khỏe database hoàn tất!';
END;
GO
PRINT N'>> [ĐÃ TẠO]: sp_KiemTraSucKhoeDB (Health check tổng thể)';
GO

-- =========================================================================
-- PHẦN 8: CẬP NHẬT STATISTICS SAU KHI BỔ SUNG INDEX MỚI
-- =========================================================================
PRINT N'>> Phần 8: Cập nhật Statistics...';
GO

UPDATE STATISTICS dbo.RepairTickets     WITH FULLSCAN;
UPDATE STATISTICS dbo.Invoices          WITH FULLSCAN;
UPDATE STATISTICS dbo.SpareParts        WITH FULLSCAN;
UPDATE STATISTICS dbo.StockTransactions WITH FULLSCAN;
UPDATE STATISTICS dbo.Users             WITH FULLSCAN;
UPDATE STATISTICS dbo.Customers         WITH FULLSCAN;
UPDATE STATISTICS dbo.Warranties        WITH FULLSCAN;
UPDATE STATISTICS dbo.TicketStatusHistory WITH FULLSCAN;
UPDATE STATISTICS dbo.TicketParts       WITH FULLSCAN;
PRINT N'>> [DONE]: Update Statistics cho 9 bảng chính';
GO

-- =========================================================================
-- PHẦN 9: AFTER OPTIMIZE - ĐO LẠI SAU KHI TỐI ƯU (SO SÁNH VỚI BASELINE)
-- =========================================================================
PRINT N'-------------------------------------------------------------------------';
PRINT N'PHẦN 9: AFTER OPTIMIZE - Đo lại sau khi tối ưu';
PRINT N'-------------------------------------------------------------------------';
GO

SET STATISTICS TIME ON;
SET STATISTICS IO ON;
GO

-- [AO-01] Cùng truy vấn BL-01 nhưng bây giờ tận dụng index composite mới
PRINT N'>> [AO-01] After Optimize: Lọc phiếu theo trạng thái (có index composite)';
SELECT
    t.TicketId,
    t.TicketCode,
    c.FullName      AS TenKhachHang,
    c.Phone,
    st.ServiceName  AS LoaiDichVu,
    u.FullName      AS KyThuatVien,
    t.ReceivedAt,
    t.Status
FROM dbo.RepairTickets t WITH (NOLOCK)
JOIN dbo.Customers   c  WITH (NOLOCK) ON c.CustomerId   = t.CustomerId
JOIN dbo.ServiceTypes st WITH (NOLOCK) ON st.ServiceTypeId = t.ServiceTypeId
LEFT JOIN dbo.Users  u  WITH (NOLOCK) ON u.UserId       = t.TechnicianUserId
WHERE t.Status = 'REPAIRING'
ORDER BY t.ReceivedAt DESC;
GO

-- [AO-02] Doanh thu tháng hiện tại qua cache thay vì tính trực tiếp
PRINT N'>> [AO-02] After Optimize: Doanh thu tháng (qua CacheDoanhThuNgay)';
DECLARE @thangDau DATE = DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1);
DECLARE @thangCuoi DATE = EOMONTH(GETDATE());
SELECT
    SUM(TongDoanhThu)   AS TongDoanhThu,
    SUM(SoHoaDon)       AS SoHoaDon,
    CASE WHEN SUM(SoHoaDon) > 0
         THEN SUM(TongDoanhThu) / SUM(SoHoaDon)
         ELSE 0
    END                 AS TrungBinhHoaDon
FROM dbo.CacheDoanhThuNgay
WHERE Ngay BETWEEN @thangDau AND @thangCuoi;
GO

SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;
GO

-- =========================================================================
-- PHẦN 10: TEST CHẠY THỬ CÁC STORED PROCEDURE ĐO LƯỜNG
-- =========================================================================
PRINT N'-------------------------------------------------------------------------';
PRINT N'PHẦN 10: TEST - Chạy thử các SP đo lường';
PRINT N'-------------------------------------------------------------------------';
GO

-- Chạy đo lường toàn diện
EXEC dbo.sp_DoLuongHieuNang @CheDo = 'ALL';
GO

-- Benchmark truy vấn lọc phiếu 5 lần
EXEC dbo.sp_BenchmarkTruyVan
    @TenTruyVan = N'Lọc phiếu REPAIRING',
    @SoLanChay  = 5,
    @TrangThai  = N'REPAIRING';
GO

-- Kiểm tra sức khỏe database
EXEC dbo.sp_KiemTraSucKhoeDB;
GO

PRINT N'=========================================================================';
PRINT N'HOÀN TẤT SCRIPT MBA-79: ĐO LƯỜNG VÀ TỐI ƯU HIỆU NĂNG - NGUYỄN VIỆT LAM';
PRINT N'=========================================================================';
GO
GO
USE RepairShopDB;
GO
