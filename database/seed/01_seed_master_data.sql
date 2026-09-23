/* =====================================================================
   LV33-001 — Hệ thống quản lý tổng thể cho cửa hàng sửa chữa
   Script seed 01: Dữ liệu danh mục nền (master data)
   Người viết: Trần Ngọc Lợi (Database)

   Lưu ý: toàn bộ dữ liệu khách hàng là dữ liệu giả phục vụ demo.
   Mật khẩu mẫu của mọi tài khoản: Abc@12345 (hash thật sẽ do Backend sinh).
   ===================================================================== */

USE RepairShopDB;
GO

/* Bắt buộc bật khi chạy bằng sqlcmd — các bảng phiếu/hóa đơn có cột tính toán
   PERSISTED, thiếu 2 dòng này thì INSERT sẽ lỗi 1934. SSMS đã bật sẵn. */
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

/* ---------- Vai trò ---------- */
IF NOT EXISTS (SELECT 1 FROM dbo.Roles)
INSERT INTO dbo.Roles (RoleCode, RoleName, Description) VALUES
    ('ADMIN',      N'Quản trị viên',     N'Chủ cửa hàng / quản lý, toàn quyền hệ thống'),
    ('STAFF',      N'Nhân viên',          N'Tiếp nhận thiết bị, lập phiếu, thu tiền'),
    ('TECHNICIAN', N'Kỹ thuật viên',      N'Chẩn đoán, sửa chữa, xuất linh kiện'),
    ('CUSTOMER',   N'Khách hàng',         N'Tra cứu tiến độ và bảo hành qua mobile app');
GO

/* ---------- Người dùng ---------- */
IF NOT EXISTS (SELECT 1 FROM dbo.Users)
INSERT INTO dbo.Users (RoleId, Username, PasswordHash, FullName, Email, Phone) VALUES
    ((SELECT RoleId FROM dbo.Roles WHERE RoleCode='ADMIN'),      'admin',   'SEED_REPLACE_ME', N'Chủ cửa hàng',      'admin@repairshop.local', '0900000001'),
    ((SELECT RoleId FROM dbo.Roles WHERE RoleCode='STAFF'),      'staff01', 'SEED_REPLACE_ME', N'Lê Thị Tiếp Nhận',  'staff01@repairshop.local','0900000002'),
    ((SELECT RoleId FROM dbo.Roles WHERE RoleCode='TECHNICIAN'), 'tech01',  'SEED_REPLACE_ME', N'Phạm Văn Kỹ Thuật', 'tech01@repairshop.local', '0900000003'),
    ((SELECT RoleId FROM dbo.Roles WHERE RoleCode='TECHNICIAN'), 'tech02',  'SEED_REPLACE_ME', N'Võ Minh Kỹ Thuật',  'tech02@repairshop.local', '0900000004');
GO

/* ---------- Loại dịch vụ & biểu giá tiền công ---------- */
IF NOT EXISTS (SELECT 1 FROM dbo.ServiceTypes)
INSERT INTO dbo.ServiceTypes (ServiceCode, ServiceName, LaborCost, WarrantyDays, Description) VALUES
    ('DV001', N'Thay màn hình điện thoại',   150000,  90, N'Tháo lắp và thay màn hình'),
    ('DV002', N'Thay pin điện thoại',        100000, 180, N'Thay pin và kiểm tra sạc'),
    ('DV003', N'Vệ sinh máy, tra keo tản nhiệt', 120000, 30, N'Vệ sinh laptop, thay keo tản nhiệt'),
    ('DV004', N'Cài đặt lại hệ điều hành',    80000,  15, N'Cài Windows, driver, phần mềm cơ bản'),
    ('DV005', N'Sửa mainboard',              350000,  60, N'Sửa chữa mạch, hàn linh kiện'),
    ('DV006', N'Thay ổ cứng / nâng cấp SSD', 100000, 365, N'Thay ổ cứng, sao lưu dữ liệu'),
    ('DV007', N'Sửa nguồn máy tính',         180000,  90, N'Kiểm tra và sửa bộ nguồn'),
    ('DV008', N'Thay mực, sửa máy in',       130000,  30, N'Vệ sinh, thay mực, sửa cơ cấu nạp giấy');
GO

/* ---------- Nhóm linh kiện ---------- */
IF NOT EXISTS (SELECT 1 FROM dbo.SparePartCategories)
INSERT INTO dbo.SparePartCategories (CategoryName, Description) VALUES
    (N'Màn hình',        N'Màn hình điện thoại, laptop'),
    (N'Pin & Sạc',       N'Pin, adapter, cáp sạc'),
    (N'Ổ cứng & RAM',    N'HDD, SSD, thanh RAM'),
    (N'Mainboard & IC',  N'Bo mạch, IC, chip'),
    (N'Vật tư tiêu hao', N'Keo tản nhiệt, mực in, ốc vít'),
    (N'Phụ kiện khác',   N'Bàn phím, loa, camera, quạt');
GO

/* ---------- Linh kiện ---------- */
IF NOT EXISTS (SELECT 1 FROM dbo.SpareParts)
INSERT INTO dbo.SpareParts (PartCode, CategoryId, PartName, Unit, PurchasePrice, SellingPrice, StockQuantity, MinStockLevel, WarrantyDays) VALUES
    ('LK00001', 1, N'Màn hình iPhone 11 (linh kiện)', N'Cái',  850000, 1200000, 12,  3,  90),
    ('LK00002', 1, N'Màn hình Samsung A32',           N'Cái',  620000,  900000,  8,  3,  90),
    ('LK00003', 1, N'Màn hình laptop 15.6" FHD',      N'Cái',  980000, 1400000,  5,  2,  90),
    ('LK00004', 2, N'Pin iPhone 11',                  N'Cái',  280000,  450000, 20,  5, 180),
    ('LK00005', 2, N'Pin laptop Dell 3 cell',         N'Cái',  450000,  700000,  6,  2, 180),
    ('LK00006', 2, N'Adapter laptop 65W',             N'Cái',  190000,  320000, 15,  4,  90),
    ('LK00007', 3, N'SSD 256GB SATA',                 N'Cái',  480000,  700000, 18,  5, 365),
    ('LK00008', 3, N'SSD 512GB NVMe',                 N'Cái',  820000, 1150000, 10,  3, 365),
    ('LK00009', 3, N'RAM DDR4 8GB 3200MHz',           N'Thanh',520000,  750000, 14,  4, 365),
    ('LK00010', 4, N'IC nguồn điện thoại',            N'Cái',   65000,  150000, 25,  8,  30),
    ('LK00011', 4, N'Chân sạc iPhone',                N'Cái',   45000,  120000, 30, 10,  60),
    ('LK00012', 5, N'Keo tản nhiệt MX-4 (tuýp nhỏ)',  N'Tuýp',  55000,  100000, 22,  6,   0),
    ('LK00013', 5, N'Mực in Canon 2900',              N'Hộp',  120000,  210000,  9,  3,   0),
    ('LK00014', 6, N'Bàn phím laptop Dell',           N'Cái',  230000,  380000,  7,  2,  90),
    ('LK00015', 6, N'Quạt tản nhiệt laptop',          N'Cái',  110000,  200000, 11,  3,  90),
    ('LK00016', 6, N'Loa trong điện thoại',           N'Cái',   40000,   95000, 16,  5,  30);
GO

PRINT 'Da nap xong du lieu danh muc nen.';
GO
