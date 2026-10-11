/* =====================================================================
   LV33-001 — Hệ thống quản lý tổng thể cho cửa hàng sửa chữa
   Script seed 02: Dữ liệu mẫu hoàn chỉnh (Users, Khách hàng, Thiết bị, Phiếu sửa chữa)
   Người viết: Trần Ngọc Lợi (Database) & Nguyễn Viết Lãm
   ===================================================================== */

USE RepairShopDB;
GO

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

/* 1. Bổ sung Users Nhóm 11 & Khách hàng */
DECLARE @adminRole INT = (SELECT RoleId FROM dbo.Roles WHERE RoleCode='ADMIN');
DECLARE @staffRole INT = (SELECT RoleId FROM dbo.Roles WHERE RoleCode='STAFF');
DECLARE @techRole INT  = (SELECT RoleId FROM dbo.Roles WHERE RoleCode='TECHNICIAN');
DECLARE @custRole INT  = (SELECT RoleId FROM dbo.Roles WHERE RoleCode='CUSTOMER');

IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE Username='loi.staff')
    INSERT INTO dbo.Users (RoleId, Username, PasswordHash, FullName, Email, Phone)
    VALUES (@staffRole, 'loi.staff', '123456', N'Trần Ngọc Lợi (BA / Lễ tân)', 'loi.tran@repairshop.local', '0901000005');

IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE Username='ky.tech')
    INSERT INTO dbo.Users (RoleId, Username, PasswordHash, FullName, Email, Phone)
    VALUES (@techRole, 'ky.tech', '123456', N'Nguyễn Đại Kỳ (QA / Kỹ thuật)', 'ky.nguyen@repairshop.local', '0901000006');

IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE Username='customer')
    INSERT INTO dbo.Users (RoleId, Username, PasswordHash, FullName, Email, Phone)
    VALUES (@custRole, 'customer', '123456', N'Khách hàng demo', 'customer@repairshop.local', '0901000007');

IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE Username='khach01')
    INSERT INTO dbo.Users (RoleId, Username, PasswordHash, FullName, Email, Phone)
    VALUES (@custRole, 'khach01', '123456', N'Nguyễn Văn An (Khách hàng)', 'an.demo@example.com', '0901000001');

IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE Username='khach02')
    INSERT INTO dbo.Users (RoleId, Username, PasswordHash, FullName, Email, Phone)
    VALUES (@custRole, 'khach02', '123456', N'Trần Thị Bình (Khách hàng)', 'binh.demo@example.com', '0901000002');
GO

/* 2. Dữ liệu Khách hàng */
IF NOT EXISTS (SELECT 1 FROM dbo.Customers WHERE CustomerCode='KH000001')
    INSERT INTO dbo.Customers (CustomerCode, FullName, Phone, Email, Address, Note)
    VALUES ('KH000001', N'Nguyễn Văn An', '0901000001', 'an.demo@example.com', N'Quận 1, TP.HCM', N'Khách VIP');

IF NOT EXISTS (SELECT 1 FROM dbo.Customers WHERE CustomerCode='KH000002')
    INSERT INTO dbo.Customers (CustomerCode, FullName, Phone, Email, Address, Note)
    VALUES ('KH000002', N'Trần Thị Bình', '0901000002', 'binh.demo@example.com', N'Quận 3, TP.HCM', N'Khách quen');
GO

/* 3. Dữ liệu Thiết bị */
DECLARE @c1 INT = (SELECT CustomerId FROM dbo.Customers WHERE CustomerCode='KH000001');
DECLARE @c2 INT = (SELECT CustomerId FROM dbo.Customers WHERE CustomerCode='KH000002');

IF NOT EXISTS (SELECT 1 FROM dbo.Devices WHERE SerialNumber='DL-2026-001')
    INSERT INTO dbo.Devices (CustomerId, DeviceType, Brand, Model, SerialNumber, Note)
    VALUES (@c1, N'Laptop', 'Dell', 'Inspiron 15', 'DL-2026-001', N'Màu Bạc, máy nóng, quạt kêu to, PIN PIN: 1234');

IF NOT EXISTS (SELECT 1 FROM dbo.Devices WHERE SerialNumber='IP12-2026-002')
    INSERT INTO dbo.Devices (CustomerId, DeviceType, Brand, Model, SerialNumber, Note)
    VALUES (@c2, N'Điện thoại', 'Apple', 'iPhone 12', 'IP12-2026-002', N'Màu Xanh dương, pin chai 72%, pass: 112233');
GO

/* 4. Phiếu sửa chữa */
DECLARE @c1 INT = (SELECT CustomerId FROM dbo.Customers WHERE CustomerCode='KH000001');
DECLARE @c2 INT = (SELECT CustomerId FROM dbo.Customers WHERE CustomerCode='KH000002');
DECLARE @d1 INT = (SELECT DeviceId FROM dbo.Devices WHERE SerialNumber='DL-2026-001');
DECLARE @d2 INT = (SELECT DeviceId FROM dbo.Devices WHERE SerialNumber='IP12-2026-002');
DECLARE @sv3 INT = (SELECT ServiceTypeId FROM dbo.ServiceTypes WHERE ServiceCode='DV003');
DECLARE @sv2 INT = (SELECT ServiceTypeId FROM dbo.ServiceTypes WHERE ServiceCode='DV002');
DECLARE @uStaff INT = (SELECT UserId FROM dbo.Users WHERE Username='loi.staff');
DECLARE @uTech INT = (SELECT UserId FROM dbo.Users WHERE Username='ky.tech');

IF @uStaff IS NULL SET @uStaff = 2;
IF @uTech IS NULL SET @uTech = 3;

IF NOT EXISTS (SELECT 1 FROM dbo.RepairTickets WHERE TicketCode='PSC2026090001')
    INSERT INTO dbo.RepairTickets (TicketCode, CustomerId, DeviceId, ServiceTypeId, ReceivedByUserId, TechnicianUserId, Status, DeviceCondition, CustomerRequest, Diagnosis, QuotedLaborCost, QuotedPartsCost)
    VALUES ('PSC2026090001', @c1, @d1, @sv3, @uStaff, @uTech, 'DIAGNOSING', N'Bụi nhiều, keo tản nhiệt khô', N'Vệ sinh máy, tra keo tản nhiệt MX-4', N'Quạt tản nhiệt bám bụi, CPU nóng 92 độ C', 120000, 0);

IF NOT EXISTS (SELECT 1 FROM dbo.RepairTickets WHERE TicketCode='PSC2026090002')
    INSERT INTO dbo.RepairTickets (TicketCode, CustomerId, DeviceId, ServiceTypeId, ReceivedByUserId, TechnicianUserId, Status, DeviceCondition, CustomerRequest, Diagnosis, QuotedLaborCost, QuotedPartsCost)
    VALUES ('PSC2026090002', @c2, @d2, @sv2, @uStaff, @uTech, 'RECEIVED', N'Vỏ trầy xước nhẹ, màn hình hiển thị tốt', N'Thay pin chính hãng iPhone 12', N'Đang chờ chẩn đoán nguồn sạc', 100000, 0);
GO

PRINT N'Hoàn tất nạp dữ liệu mẫu hoàn chỉnh vào RepairShopDB!';
