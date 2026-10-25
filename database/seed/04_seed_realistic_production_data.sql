
USE RepairShopDB;
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
SET NOCOUNT ON;

BEGIN TRANSACTION;

-- 1. Xóa dữ liệu cũ theo đúng thứ tự ràng buộc khóa ngoại (FK)
DELETE FROM dbo.TicketStatusHistory;
DELETE FROM dbo.TicketParts;
DELETE FROM dbo.StockTransactions;
DELETE FROM dbo.Warranties;
DELETE FROM dbo.Invoices;
DELETE FROM dbo.RepairTickets;
DELETE FROM dbo.Devices;
DELETE FROM dbo.Users WHERE Username NOT IN ('admin', 'staff01', 'tech01', 'tech02');
DELETE FROM dbo.Customers;
DELETE FROM dbo.SpareParts;
DELETE FROM dbo.SparePartCategories;
DELETE FROM dbo.ServiceTypes;

-- Reset IDENTITY cho các bảng
DBCC CHECKIDENT ('dbo.Customers', RESEED, 0);
DBCC CHECKIDENT ('dbo.Devices', RESEED, 0);
DBCC CHECKIDENT ('dbo.SparePartCategories', RESEED, 0);
DBCC CHECKIDENT ('dbo.SpareParts', RESEED, 0);
DBCC CHECKIDENT ('dbo.ServiceTypes', RESEED, 0);
DBCC CHECKIDENT ('dbo.RepairTickets', RESEED, 0);
DBCC CHECKIDENT ('dbo.TicketStatusHistory', RESEED, 0);
DBCC CHECKIDENT ('dbo.Invoices', RESEED, 0);
DBCC CHECKIDENT ('dbo.Warranties', RESEED, 0);
DBCC CHECKIDENT ('dbo.StockTransactions', RESEED, 0);
DBCC CHECKIDENT ('dbo.TicketParts', RESEED, 0);

-- 2. CẬP NHẬT ROLES
UPDATE dbo.Roles SET RoleName = N'Quản trị viên', Description = N'Chủ cửa hàng / Quản lý hệ thống, toàn quyền quản trị' WHERE RoleCode = 'ADMIN';
UPDATE dbo.Roles SET RoleName = N'Nhân viên quầy', Description = N'Tiếp nhận thiết bị, lập phiếu tiếp nhận, thu ngân hóa đơn' WHERE RoleCode = 'STAFF';
UPDATE dbo.Roles SET RoleName = N'Kỹ thuật viên', Description = N'Chẩn đoán, sửa chữa phần cứng/phần mềm, xuất kho linh kiện' WHERE RoleCode = 'TECHNICIAN';
UPDATE dbo.Roles SET RoleName = N'Khách hàng', Description = N'Tra cứu tiến độ sửa chữa máy và sổ bảo hành điện tử' WHERE RoleCode = 'CUSTOMER';

-- 3. BẢNG CUSTOMERS (10 Khách hàng thực tế tại TP.HCM)
SET IDENTITY_INSERT dbo.Customers ON;
INSERT INTO dbo.Customers (CustomerId, CustomerCode, FullName, Phone, Email, Address, Note, IsActive, CreatedAt) VALUES
(1, 'KH000001', N'Nguyễn Thành Nam', '0982345678', 'nam.nguyen@gmail.com', N'142 Võ Văn Tần, Phường 6, Quận 3, TP.HCM', N'Khách hàng VIP doanh nghiệp', 1, DATEADD(DAY, -20, GETDATE())),
(2, 'KH000002', N'Lê Hoàng Phúc', '0903124567', 'phuc.le@outlook.com', N'475A Điện Biên Phủ, Phường 25, Bình Thạnh, TP.HCM', N'Giảng viên ĐH HUTECH', 1, DATEADD(DAY, -18, GETDATE())),
(3, 'KH000003', N'Đặng Minh Tâm', '0918765432', 'tam.dang@fpt.edu.vn', N'280 An Dương Vương, Phường 4, Quận 5, TP.HCM', N'Lập trình viên Senior', 1, DATEADD(DAY, -15, GETDATE())),
(4, 'KH000004', N'Võ Hoài Thương', '0976543210', 'thuong.vo@gmail.com', N'120 Hai Bà Trưng, Phường Đa Kao, Quận 1, TP.HCM', N'Thiết kế đồ họa Studio', 1, DATEADD(DAY, -12, GETDATE())),
(5, 'KH000005', N'Phan Thanh Tùng', '0938889900', 'tung.phan@techcorp.vn', N'68 Nguyễn Huệ, Phường Bến Nghé, Quận 1, TP.HCM', N'Khách sửa máy tính PC gaming', 1, DATEADD(DAY, -10, GETDATE())),
(6, 'KH000006', N'Hoàng Thị Mai Anh', '0908112233', 'maianh.hoang@gmail.com', N'354 Lê Văn Sỹ, Phường 14, Quận 3, TP.HCM', N'Khách hàng thân thiết', 1, DATEADD(DAY, -8, GETDATE())),
(7, 'KH000007', N'Trần Đình Trọng', '0919223344', 'trong.td@gmail.com', N'89 Phan Xích Long, Phường 2, Phú Nhuận, TP.HCM', N'Khách sửa iPad đồ họa', 1, DATEADD(DAY, -6, GETDATE())),
(8, 'KH000008', N'Bùi Quang Huy', '0966554433', 'huy.bui@hutech.edu.vn', N'31/2 Ung Văn Khiêm, Phường 25, Bình Thạnh, TP.HCM', N'Sinh viên Khoa CNTT', 1, DATEADD(DAY, -4, GETDATE())),
(9, 'KH000009', N'Đỗ Phương Thảo', '0902998877', 'thao.dophuong@gmail.com', N'52 Nguyễn Thị Minh Khai, Quận 1, TP.HCM', N'Khách hàng thay pin iPhone', 1, DATEADD(DAY, -3, GETDATE())),
(10, 'KH000010', N'Ngô Gia Bảo', '0913445566', 'bao.ngo@gmail.com', N'215 Hồng Bàng, Phường 11, Quận 5, TP.HCM', N'Khách sửa laptop văn phòng', 1, DATEADD(DAY, -1, GETDATE()));
SET IDENTITY_INSERT dbo.Customers OFF;

-- 4. BẢNG USERS (Tài khoản nhân sự và khách hàng liên kết)
DECLARE @defaultHash NVARCHAR(255) = '$2a$11$i9HeslXM/Q.w615uRRoWTegplzlqOgpSv1/XHdjgD85ZOA/U1ax3e'; -- Abc@12345
DECLARE @adminRole INT = (SELECT TOP 1 RoleId FROM dbo.Roles WHERE RoleCode = 'ADMIN');
DECLARE @staffRole INT = (SELECT TOP 1 RoleId FROM dbo.Roles WHERE RoleCode = 'STAFF');
DECLARE @techRole INT = (SELECT TOP 1 RoleId FROM dbo.Roles WHERE RoleCode = 'TECHNICIAN');
DECLARE @custRole INT = (SELECT TOP 1 RoleId FROM dbo.Roles WHERE RoleCode = 'CUSTOMER');

UPDATE dbo.Users SET
    RoleId = @adminRole,
    FullName = N'Nguyễn Viết Lãm (Admin / Quản lý)',
    Email = 'admin@repairshop.local',
    Phone = '0900000001',
    PasswordHash = @defaultHash,
    IsActive = 1,
    CustomerId = NULL
WHERE Username = 'admin';

UPDATE dbo.Users SET
    RoleId = @staffRole,
    FullName = N'Trần Ngọc Lợi (Trưởng nhóm lễ tân & CSKH)',
    Email = 'staff01@repairshop.local',
    Phone = '0900000002',
    PasswordHash = @defaultHash,
    IsActive = 1,
    CustomerId = NULL
WHERE Username = 'staff01';

UPDATE dbo.Users SET
    RoleId = @techRole,
    FullName = N'Phạm Văn Kỹ Thuật (Chuyên viên Laptop & PC)',
    Email = 'tech01@repairshop.local',
    Phone = '0900000003',
    PasswordHash = @defaultHash,
    IsActive = 1,
    CustomerId = NULL
WHERE Username = 'tech01';

UPDATE dbo.Users SET
    RoleId = @techRole,
    FullName = N'Nguyễn Đại Kỳ (Chuyên viên Mobile & Apple)',
    Email = 'tech02@repairshop.local',
    Phone = '0900000004',
    PasswordHash = @defaultHash,
    IsActive = 1,
    CustomerId = NULL
WHERE Username = 'tech02';

-- Tạo các tài khoản khách hàng thực tế để demo Portal
INSERT INTO dbo.Users (RoleId, Username, PasswordHash, FullName, Email, Phone, IsActive, LastLoginAt, CreatedAt, CustomerId)
VALUES
(@custRole, 'khach01', @defaultHash, N'Nguyễn Thành Nam (Khách hàng VIP)', 'nam.nguyen@gmail.com', '0982345678', 1, DATEADD(HOUR, -2, GETDATE()), GETDATE(), 1),
(@custRole, 'khach02', @defaultHash, N'Lê Hoàng Phúc (Khách hàng)', 'phuc.le@outlook.com', '0903124567', 1, DATEADD(HOUR, -5, GETDATE()), GETDATE(), 2),
(@custRole, 'khach03', @defaultHash, N'Đặng Minh Tâm (Khách hàng)', 'tam.dang@fpt.edu.vn', '0918765432', 1, NULL, GETDATE(), 3),
(@custRole, 'customer', @defaultHash, N'Khách hàng Demo (Trải nghiệm Portal)', 'customer@example.com', '0901000003', 1, DATEADD(DAY, -1, GETDATE()), GETDATE(), 1);

-- 5. BẢNG DEVICES (10 Thiết bị điện thoại, laptop, PC)
SET IDENTITY_INSERT dbo.Devices ON;
INSERT INTO dbo.Devices (DeviceId, DeviceCode, CustomerId, DeviceType, Brand, Model, SerialNumber, Note, CreatedAt) VALUES
(1, 'TB000001', 1, N'Laptop', 'Dell', N'XPS 15 9520 (Core i7-12700H / 32GB / 1TB SSD)', 'DLXPS-9520-VN01', N'Máy đồ họa cao cấp', DATEADD(DAY, -20, GETDATE())),
(2, 'TB000002', 2, N'Điện thoại', 'Apple', N'iPhone 14 Pro Max 256GB Deep Purple', 'F2LX90A4MD6R', N'Máy chính hãng VNA', DATEADD(DAY, -18, GETDATE())),
(3, 'TB000003', 3, N'Laptop', 'Apple', N'MacBook Pro 14 M2 Pro 2023 Space Gray', 'C02G90ABMD6T', N'Máy lập trình di động', DATEADD(DAY, -15, GETDATE())),
(4, 'TB000004', 4, N'Điện thoại', 'Samsung', N'Galaxy S23 Ultra 5G 512GB Phantom Black', 'R5CW20ABXYZ', N'Bản chính hãng SSVN', DATEADD(DAY, -12, GETDATE())),
(5, 'TB000005', 5, N'Máy tính PC', 'ASUS / MSI', N'PC Gaming Core i7-13700K / RTX 3070 8GB', 'PCG-2026-SG01', N'Case Corsair 4000D tản nước', DATEADD(DAY, -10, GETDATE())),
(6, 'TB000006', 6, N'Laptop', 'Asus', N'ROG Zephyrus G14 (Ryzen 7 6800HS / RX 6700S)', 'GA402RJ-L8035W', N'Laptop gaming mỏng nhẹ', DATEADD(DAY, -8, GETDATE())),
(7, 'TB000007', 7, N'Máy tính bảng', 'Apple', N'iPad Pro 11 M1 128GB Wi-Fi + 5G', 'DMPD30A8MD6M', N'Dùng vẽ và đồ họa Procreate', DATEADD(DAY, -6, GETDATE())),
(8, 'TB000008', 8, N'Laptop', 'Lenovo', N'ThinkPad X1 Carbon Gen 10 (Core i7-1260P / 16GB)', 'PF3X99AB2023', N'Máy doanh nhân siêu bền', DATEADD(DAY, -4, GETDATE())),
(9, 'TB000009', 9, N'Điện thoại', 'Apple', N'iPhone 13 128GB Starlight', 'DX3F40ABMD6N', N'Máy nữ dùng giữ gìn', DATEADD(DAY, -3, GETDATE())),
(10, 'TB000010', 10, N'Laptop', 'HP', N'Envy 13-ba1000 Core i5-1135G7 / 8GB RAM', '5CD2180ABC', N'Laptop văn phòng mỏng nhẹ', DATEADD(DAY, -1, GETDATE()));
SET IDENTITY_INSERT dbo.Devices OFF;

-- 6. BẢNG SERVICE TYPES (10 Dịch vụ sửa chữa chuyên nghiệp)
SET IDENTITY_INSERT dbo.ServiceTypes ON;
INSERT INTO dbo.ServiceTypes (ServiceTypeId, ServiceCode, ServiceName, LaborCost, WarrantyDays, Description, IsActive) VALUES
(1, 'DV001', N'Thay màn hình điện thoại OLED / Super Retina', 150000, 90, N'Tháo ráp, ép ron chống nước, chuyển IC giữ True Tone', 1),
(2, 'DV002', N'Thay pin chính hãng điện thoại / máy tính bảng', 100000, 180, N'Thay pin dung lượng cao, dán keo seal chuyên dụng', 1),
(3, 'DV003', N'Vệ sinh tra keo tản nhiệt gốm máy tính & laptop', 150000, 30, N'Vệ sinh quạt kép, tra keo gốm Thermal Grizzly Kryonaut', 1),
(4, 'DV004', N'Cài đặt hệ điều hành Windows 11 / macOS & phần mềm', 100000, 30, N'Cài đặt OS chuẩn UEFI/GPT, driver đầy đủ và Office', 1),
(5, 'DV005', N'Sửa chữa phần cứng mainboard, IC nguồn, reball chip', 450000, 90, N'Đo đạc boardview, dò chạm chập bằng camera nhiệt FLIR', 1),
(6, 'DV006', N'Nâng cấp ổ cứng SSD NVMe & sao lưu chuyển dữ liệu', 120000, 365, N'Lắp đặt SSD M.2 tốc độ cao, clone phân vùng dữ liệu an toàn', 1),
(7, 'DV007', N'Thay cụm cáp chân sạc Type-C / Lightning và mic thoại', 150000, 90, N'Thay bo cáp chân sạc zin máy, test chuẩn sạc nhanh PD', 1),
(8, 'DV008', N'Ép kính màn hình cong / thay mặt kính cảm ứng', 250000, 90, N'Cắt kính vỡ bằng máy tách nhiệt, hấp bọt khí chân không', 1),
(9, 'DV009', N'Thay bàn phím laptop & bảo dưỡng switch phím', 120000, 180, N'Hàn tán đinh rivet bàn phím mới, kiểm tra độ nảy từng phím', 1),
(10, 'DV010', N'Cứu phục hồi dữ liệu ổ cứng lỗi bad sector / lỗi mạch', 500000, 30, N'Cứu dữ liệu ổ cơ HDD và SSD bằng thiết bị chuyên dụng PC-3000', 1);
SET IDENTITY_INSERT dbo.ServiceTypes OFF;

-- 7. BẢNG SPARE PART CATEGORIES (6 Danh mục linh kiện)
SET IDENTITY_INSERT dbo.SparePartCategories ON;
INSERT INTO dbo.SparePartCategories (CategoryId, CategoryName, Description, IsActive) VALUES
(1, N'Màn hình Smartphone & Laptop', N'Màn hình Super Retina XDR, Dynamic AMOLED 2X, LCD IPS 144Hz', 1),
(2, N'Pin & Bộ sạc công suất cao', N'Pin Pisen chính hãng, Pin zin máy, Pin Dell/Apple cao cấp', 1),
(3, N'Ổ cứng SSD NVMe & RAM', N'SSD Samsung 980 PRO, Kingston NV2, RAM Crucial DDR5, Kingston DDR4', 1),
(4, N'IC nguồn, Chipset & Bo mạch', N'IC PMIC Qualcomm, chip sạc Type-C Thunderbolt, tụ gốm cao tần', 1),
(5, N'Bàn phím, Vỏ & Cụm linh kiện', N'Bàn phím ThinkPad, quạt Asus ROG, cáp Type-C iPhone/iPad', 1),
(6, N'Keo tản nhiệt & Vật tư bảo dưỡng', N'Keo gốm Thermal Grizzly, dung dịch tẩy keo Arctic Clean, ron chống nước', 1);
SET IDENTITY_INSERT dbo.SparePartCategories OFF;

-- 8. BẢNG SPARE PARTS (18 Linh kiện chi tiết)
SET IDENTITY_INSERT dbo.SpareParts ON;
INSERT INTO dbo.SpareParts (PartId, PartCode, CategoryId, PartName, Unit, PurchasePrice, SellingPrice, StockQuantity, MinStockLevel, WarrantyDays, IsActive, CreatedAt) VALUES
(1, 'LK00001', 1, N'Màn hình iPhone 14 Pro Max Super Retina XDR Zin máy', N'Cái', 4800000, 5600000, 6, 2, 90, 1, DATEADD(DAY, -30, GETDATE())),
(2, 'LK00002', 1, N'Màn hình Samsung Galaxy S23 Ultra Dynamic AMOLED 2X', N'Cái', 4100000, 4900000, 4, 2, 90, 1, DATEADD(DAY, -30, GETDATE())),
(3, 'LK00003', 1, N'Màn hình LCD Laptop 15.6" IPS FHD 144Hz Slim', N'Cái', 1250000, 1650000, 8, 3, 180, 1, DATEADD(DAY, -30, GETDATE())),
(4, 'LK00004', 1, N'Màn hình MacBook Pro 14" Liquid Retina XDR A2442', N'Cái', 6800000, 7900000, 3, 1, 180, 1, DATEADD(DAY, -30, GETDATE())),
(5, 'LK00005', 2, N'Pin iPhone 14 Pro Max Pisen dung lượng cao 4323mAh', N'Cái', 580000, 790000, 15, 5, 180, 1, DATEADD(DAY, -30, GETDATE())),
(6, 'LK00006', 2, N'Pin Samsung Galaxy S23 Ultra Zin 5000mAh', N'Cái', 480000, 680000, 10, 3, 180, 1, DATEADD(DAY, -30, GETDATE())),
(7, 'LK00007', 2, N'Pin Laptop Dell XPS 15 86Wh 6-cell chính hãng', N'Cái', 980000, 1350000, 2, 2, 180, 1, DATEADD(DAY, -30, GETDATE())),
(8, 'LK00008', 2, N'Pin MacBook Pro 14" A2442 70Wh Zin', N'Cái', 1350000, 1850000, 4, 2, 180, 1, DATEADD(DAY, -30, GETDATE())),
(9, 'LK00009', 3, N'Ổ cứng SSD Samsung 980 PRO 1TB PCIe NVMe 4.0', N'Cái', 1850000, 2250000, 12, 4, 365, 1, DATEADD(DAY, -30, GETDATE())),
(10, 'LK00010', 3, N'Ổ cứng SSD Kingston NV2 512GB M.2 PCIe 4.0', N'Cái', 720000, 950000, 18, 5, 365, 1, DATEADD(DAY, -30, GETDATE())),
(11, 'LK00011', 3, N'RAM Laptop Crucial DDR5 16GB 4800MHz', N'Thanh', 980000, 1280000, 8, 3, 365, 1, DATEADD(DAY, -30, GETDATE())),
(12, 'LK00012', 3, N'RAM Laptop Kingston Fury DDR4 16GB 3200MHz', N'Thanh', 680000, 890000, 14, 4, 365, 1, DATEADD(DAY, -30, GETDATE())),
(13, 'LK00013', 4, N'IC Nguồn PMIC Qualcomm Snapdragon SM8550', N'Cái', 220000, 450000, 20, 5, 90, 1, DATEADD(DAY, -30, GETDATE())),
(14, 'LK00014', 5, N'Cụm chân sạc Type-C iPhone 14 Pro Max bóc máy', N'Cái', 380000, 620000, 7, 2, 90, 1, DATEADD(DAY, -30, GETDATE())),
(15, 'LK00015', 5, N'Bàn phím Laptop Lenovo ThinkPad X1 Carbon Led US', N'Cái', 650000, 950000, 1, 2, 180, 1, DATEADD(DAY, -30, GETDATE())),
(16, 'LK00016', 6, N'Keo tản nhiệt Thermal Grizzly Kryonaut 1g', N'Tuýp', 110000, 180000, 35, 10, 0, 1, DATEADD(DAY, -30, GETDATE())),
(17, 'LK00017', 5, N'Cụm quạt tản nhiệt đôi Asus ROG Zephyrus G14', N'Bộ', 320000, 490000, 5, 2, 90, 1, DATEADD(DAY, -30, GETDATE())),
(18, 'LK00018', 1, N'Mặt kính Sapphire cụm camera iPad Pro 11"', N'Cái', 150000, 280000, 9, 3, 90, 1, DATEADD(DAY, -30, GETDATE()));
SET IDENTITY_INSERT dbo.SpareParts OFF;

-- Lấy ID nhân sự
DECLARE @staffId INT = (SELECT TOP 1 UserId FROM dbo.Users WHERE Username = 'staff01');
DECLARE @tech1Id INT = (SELECT TOP 1 UserId FROM dbo.Users WHERE Username = 'tech01');
DECLARE @tech2Id INT = (SELECT TOP 1 UserId FROM dbo.Users WHERE Username = 'tech02');

-- 9. BẢNG REPAIR TICKETS (10 Phiếu sửa chữa thực tế)
SET IDENTITY_INSERT dbo.RepairTickets ON;
INSERT INTO dbo.RepairTickets (
    TicketId, TicketCode, CustomerId, DeviceId, ServiceTypeId, ReceivedByUserId, TechnicianUserId,
    Status, DeviceCondition, CustomerRequest, Diagnosis, QuotedLaborCost, QuotedPartsCost,
    IsWarrantyRepair, ReceivedAt, ExpectedFinishAt, CompletedAt, DeliveredAt, CreatedAt
) VALUES
-- 1. COMPLETED: Dell XPS 15 vệ sinh tra keo tản nhiệt gốm
(1, 'PSC202610001', 1, 1, 3, @staffId, @tech1Id,
 'COMPLETED',
 N'Máy chạy khoảng 15 phút quạt kêu to rú rít, nhiệt độ đo CPU 98°C, tự sập nguồn khi render video Premiere.',
 N'Khách yêu cầu vệ sinh toàn bộ máy và thay loại keo tản nhiệt tốt nhất.',
 N'Keo tản nhiệt gốc đã bị khô cứng chai cứng, cụm lá nhôm tản nhiệt nghẹt xơ bụi. Đã vệ sinh quạt kép, tẩy keo cũ và tra keo Thermal Grizzly Kryonaut. Stress test Cinebench R23 nhiệt độ ổn định ở 72°C.',
 150000, 180000, 0, DATEADD(DAY, -3, GETDATE()), DATEADD(DAY, -2, GETDATE()), DATEADD(DAY, -2, GETDATE()), NULL, DATEADD(DAY, -3, GETDATE())),

-- 2. REPAIRING: iPhone 14 Pro Max thay màn hình OLED zin
(2, 'PSC202610002', 2, 2, 1, @staffId, @tech2Id,
 'REPAIRING',
 N'Rơi cấn góc bàn kính nứt mạng nhện, sọc xanh dọc mép phải màn hình, cảm ứng góc dưới bị đơ không phản hồi.',
 N'Thay màn hình zin chính hãng, cần giữ lại tính năng Face ID và True Tone.',
 N'Tấm nền OLED bị rạn panel bên trong. Đang tháo ráp thay cụm màn hình Super Retina XDR Zin, chuyển chip IC màn hình để giữ nguyên tính năng True Tone.',
 150000, 5600000, 0, DATEADD(DAY, -2, GETDATE()), DATEADD(DAY, 1, GETDATE()), NULL, NULL, DATEADD(DAY, -2, GETDATE())),

-- 3. DIAGNOSING: MacBook Pro 14 M2 sửa nguồn mainboard
(3, 'PSC202610003', 3, 3, 5, @staffId, @tech1Id,
 'DIAGNOSING',
 N'Cắm sạc MagSafe 3 đèn nhấp nháy cam rồi tắt hẳn, máy hoàn toàn không lên nguồn, pin không nhận dòng sạc.',
 N'Kiểm tra và cứu dữ liệu đồ án trong máy gấp.',
 N'Đo chạm chập tụ lọc đường cấp nguồn chính PPBUS_AON 12.6V gần cụm cổng Type-C Thunderbolt. Kỹ thuật viên đang dò nhiệt FLIR và đo đạc boardview cách ly linh kiện ngắn mạch.',
 450000, 0, 0, DATEADD(DAY, -1, GETDATE()), DATEADD(DAY, 2, GETDATE()), NULL, NULL, DATEADD(DAY, -1, GETDATE())),

-- 4. WAITING_CONFIRM: Samsung S23 Ultra pin phồng
(4, 'PSC202610004', 4, 4, 2, @staffId, @tech2Id,
 'WAITING_CONFIRM',
 N'Pin bị chai phồng nhẹ đẩy nắp lưng, sạc pin rất nóng, dùng còn 25-30% là sập nguồn khởi động lại.',
 N'Báo giá pin chính hãng và thời gian thay thế.',
 N'Pin lithium đạt chu kỳ 860 lần sạc, dung lượng thực tế còn 64% so với ban đầu. Cần thay pin Samsung Zin 5000mAh và dán lại ron chống nước kháng bụi tiêu chuẩn IP68.',
 100000, 680000, 0, DATEADD(DAY, -1, GETDATE()), DATEADD(DAY, 1, GETDATE()), NULL, NULL, DATEADD(DAY, -1, GETDATE())),

-- 5. DELIVERED: PC Gaming Core i7 nâng cấp SSD Samsung 980 PRO (Đã thanh toán)
(5, 'PSC202610005', 5, 5, 6, @staffId, @tech1Id,
 'DELIVERED',
 N'Khởi động vào Windows rất chậm (mất hơn 4 phút), chơi game giật lag bị đứng màn hình xanh BSOD, ổ HDD cũ kêu lạch cạch.',
 N'Nâng cấp SSD NVMe tốc độ cao 1TB, chuyển toàn bộ dữ liệu game và Windows cũ sang.',
 N'Ổ HDD cũ bị bad sector nặng phân vùng C. Đã sao lưu dữ liệu phân vùng D, lắp mới SSD Samsung 980 PRO 1TB NVMe Gen 4, cài Windows 11 Pro 64-bit tối ưu hóa cho gaming.',
 120000, 2250000, 0, DATEADD(DAY, -5, GETDATE()), DATEADD(DAY, -4, GETDATE()), DATEADD(DAY, -4, GETDATE()), DATEADD(DAY, -4, GETDATE()), DATEADD(DAY, -5, GETDATE())),

-- 6. RECEIVED: Asus ROG Zephyrus G14 gãy cánh quạt
(6, 'PSC202610006', 6, 6, 3, @staffId, NULL,
 'RECEIVED',
 N'Quạt tản nhiệt bên GPU phát ra tiếng kêu cọc cọc rít gió lớn, máy chơi game bị tụt xung nhịp fps (thermal throttling).',
 N'Khách mang máy đến gửi tại quầy, yêu cầu kiểm tra và thay quạt zin êm ái.',
 NULL,
 150000, 490000, 0, GETDATE(), DATEADD(DAY, 2, GETDATE()), NULL, NULL, GETDATE()),

-- 7. DELIVERED: iPad Pro 11 M1 gãy chân cáp sạc Type-C (Đã thanh toán)
(7, 'PSC202610007', 7, 7, 7, @staffId, @tech2Id,
 'DELIVERED',
 N'Cổng sạc Type-C bị gãy chân pin tiếp xúc bên trong do cắm giật mạnh cáp sạc, máy không nhận sạc và không kết nối được máy tính Mac.',
 N'Thay cụm sạc Type-C zin máy, giữ micro thu âm gốc.',
 N'Cổng sạc Type-C rách bo cáp flex. Đã thay cụm cáp sạc Type-C mới, test sạc nhanh PD 30W và truyền dữ liệu iTunes 100% bình thường.',
 150000, 620000, 0, DATEADD(DAY, -4, GETDATE()), DATEADD(DAY, -3, GETDATE()), DATEADD(DAY, -3, GETDATE()), DATEADD(DAY, -3, GETDATE()), DATEADD(DAY, -4, GETDATE())),

-- 8. RECEIVED: Lenovo ThinkPad X1 kẹt phím do đổ nước
(8, 'PSC202610008', 8, 8, 9, @staffId, @tech1Id,
 'RECEIVED',
 N'Bị đổ nước ngọt lên cụm phím, một hàng phím ASDFG và phím Space bị dính kẹt cứng, chập tự động gõ liên tục chữ D.',
 N'Thay bàn phím ThinkPad chính hãng có đèn led nền.',
 N'Tiếp nhận tại quầy, tháo pin khẩn cấp chống chập mạch main, cần thay cụm bàn phím ThinkPad Led US mới.',
 120000, 950000, 0, GETDATE(), DATEADD(DAY, 1, GETDATE()), NULL, NULL, GETDATE()),

-- 9. DELIVERED: iPhone 13 thay pin Pisen dung lượng cao (Đã thanh toán)
(9, 'PSC202610009', 9, 9, 2, @staffId, @tech2Id,
 'DELIVERED',
 N'Báo pin bảo trì trong Cài đặt (Dung lượng tối đa 71%), dùng nửa ngày là hết pin.',
 N'Thay pin Pisen chính hãng bảo hành dài hạn.',
 N'Đã thay pin Pisen dung lượng cao chính hãng, test chu kỳ sạc 100%, sạc đầy ngắt sạc tự động tốt.',
 100000, 750000, 0, DATEADD(DAY, -2, GETDATE()), DATEADD(DAY, -2, GETDATE()), DATEADD(DAY, -2, GETDATE()), DATEADD(DAY, -2, GETDATE()), DATEADD(DAY, -2, GETDATE())),

-- 10. DELIVERED: Laptop HP Envy 13 nâng cấp RAM (Đã thanh toán)
(10, 'PSC202610010', 10, 10, 4, @staffId, @tech1Id,
 'DELIVERED',
 N'Máy chạy đơ chậm, mở 10 tab Chrome và Photoshop bị tràn RAM báo lỗi Out of Memory.',
 N'Nâng cấp RAM và vệ sinh thổi bụi.',
 N'Nâng cấp thanh RAM 16GB Kingston DDR4 3200MHz, máy nhận đủ RAM chạy mượt mà đa nhiệm.',
 100000, 890000, 0, DATEADD(DAY, -1, GETDATE()), DATEADD(DAY, -1, GETDATE()), DATEADD(DAY, -1, GETDATE()), DATEADD(DAY, -1, GETDATE()), DATEADD(DAY, -1, GETDATE()));
SET IDENTITY_INSERT dbo.RepairTickets OFF;

-- 10. BẢNG TICKET STATUS HISTORY
INSERT INTO dbo.TicketStatusHistory (TicketId, FromStatus, ToStatus, ChangedByUserId, Note, ChangedAt) VALUES
(1, NULL, 'RECEIVED', @staffId, N'Tiếp nhận máy Dell XPS 15 từ khách Nguyễn Thành Nam tại quầy', DATEADD(DAY, -3, GETDATE())),
(1, 'RECEIVED', 'DIAGNOSING', @tech1Id, N'Kỹ thuật viên Phạm Văn Kỹ Thuật nhận máy đo nhiệt độ tải cao', DATEADD(DAY, -3, GETDATE())),
(1, 'DIAGNOSING', 'COMPLETED', @tech1Id, N'Hoàn thành vệ sinh tra keo tản nhiệt Kryonaut, test nhiệt độ mát 72 độ C', DATEADD(DAY, -2, GETDATE())),

(2, NULL, 'RECEIVED', @staffId, N'Tiếp nhận iPhone 14 Pro Max vỡ kính mép bàn', DATEADD(DAY, -2, GETDATE())),
(2, 'RECEIVED', 'REPAIRING', @tech2Id, N'KTV Nguyễn Đại Kỳ tiến hành thay màn hình OLED Zin bóc máy', DATEADD(DAY, -1, GETDATE())),

(3, NULL, 'RECEIVED', @staffId, N'Tiếp nhận MacBook Pro 14 không lên nguồn', DATEADD(DAY, -1, GETDATE())),
(3, 'RECEIVED', 'DIAGNOSING', @tech1Id, N'Đo đạc sơ đồ boardview và dò nhiệt FLIR tụ nguồn PPBUS_AON', DATEADD(HOUR, -6, GETDATE())),

(4, NULL, 'RECEIVED', @staffId, N'Tiếp nhận Galaxy S23 Ultra pin phồng', DATEADD(DAY, -1, GETDATE())),
(4, 'RECEIVED', 'WAITING_CONFIRM', @staffId, N'Gửi báo giá thay pin 780.000đ qua Zalo cho khách Võ Hoài Thương', DATEADD(HOUR, -4, GETDATE())),

(5, NULL, 'RECEIVED', @staffId, N'Tiếp nhận PC Gaming lỗi màn hình xanh BSOD', DATEADD(DAY, -5, GETDATE())),
(5, 'RECEIVED', 'COMPLETED', @tech1Id, N'Lắp đặt SSD Samsung 980 PRO 1TB và cài Windows 11', DATEADD(DAY, -4, GETDATE())),
(5, 'COMPLETED', 'DELIVERED', @staffId, N'Khách kiểm tra máy ưng ý, thanh toán chuyển khoản và nhận máy', DATEADD(DAY, -4, GETDATE())),

(6, NULL, 'RECEIVED', @staffId, N'Tiếp nhận máy Asus ROG Zephyrus G14 gãy cánh quạt', GETDATE()),
(7, NULL, 'RECEIVED', @staffId, N'Tiếp nhận iPad Pro 11 hỏng chân sạc Type-C', DATEADD(DAY, -4, GETDATE())),
(7, 'RECEIVED', 'DELIVERED', @staffId, N'Bàn giao iPad Pro sau khi thay cáp sạc Type-C chuẩn PD', DATEADD(DAY, -3, GETDATE())),

(8, NULL, 'RECEIVED', @staffId, N'Tiếp nhận ThinkPad X1 kẹt phím cà phê', GETDATE()),
(9, NULL, 'DELIVERED', @staffId, N'Đã hoàn thành thay pin iPhone 13 và giao khách', DATEADD(DAY, -2, GETDATE())),
(10, NULL, 'DELIVERED', @staffId, N'Đã nâng cấp RAM Kingston và thanh toán tiền mặt', DATEADD(DAY, -1, GETDATE()));

-- 11. BẢNG TICKET PARTS (Linh kiện xuất dùng cho phiếu)
INSERT INTO dbo.TicketParts (TicketId, PartId, Quantity, UnitPrice, Note, CreatedAt) VALUES
(1, 16, 1, 180000, N'Keo tản nhiệt gốm Thermal Grizzly Kryonaut 1g', DATEADD(DAY, -2, GETDATE())),
(2, 1, 1, 5600000, N'Màn hình iPhone 14 Pro Max Super Retina XDR Zin máy', DATEADD(DAY, -1, GETDATE())),
(5, 9, 1, 2250000, N'Ổ cứng SSD Samsung 980 PRO 1TB PCIe NVMe 4.0', DATEADD(DAY, -4, GETDATE())),
(7, 14, 1, 620000, N'Cụm chân sạc Type-C iPad/iPhone bóc máy', DATEADD(DAY, -3, GETDATE())),
(9, 5, 1, 750000, N'Pin iPhone 13/14 Pisen dung lượng cao', DATEADD(DAY, -2, GETDATE())),
(10, 12, 1, 890000, N'RAM Laptop Kingston Fury DDR4 16GB 3200MHz', DATEADD(DAY, -1, GETDATE()));

-- 12. BẢNG INVOICES (5 Hóa đơn thanh toán - TotalAmount PERSISTED tự tính)
SET IDENTITY_INSERT dbo.Invoices ON;
INSERT INTO dbo.Invoices (
    InvoiceId, InvoiceCode, TicketId, CustomerId, LaborCost, PartsCost, DiscountAmount,
    PaymentMethod, PaymentStatus, PaidAt, CreatedByUserId, Note, CreatedAt
) VALUES
(1, 'HD2026100001', 5, 5, 120000, 2250000, 0, 'TRANSFER', 'PAID', DATEADD(DAY, -4, GETDATE()), @staffId, N'Chuyển khoản VietQR Ngân hàng MBBank', DATEADD(DAY, -4, GETDATE())),
(2, 'HD2026100002', 7, 7, 150000, 620000, 0, 'CASH', 'PAID', DATEADD(DAY, -3, GETDATE()), @staffId, N'Thanh toán tiền mặt tại quầy', DATEADD(DAY, -3, GETDATE())),
(3, 'HD2026100003', 1, 1, 150000, 180000, 0, 'TRANSFER', 'PAID', DATEADD(DAY, -2, GETDATE()), @staffId, N'Chuyển khoản VietQR', DATEADD(DAY, -2, GETDATE())),
(4, 'HD2026100004', 9, 9, 100000, 750000, 0, 'TRANSFER', 'PAID', DATEADD(DAY, -2, GETDATE()), @staffId, N'Chuyển khoản VietQR', DATEADD(DAY, -2, GETDATE())),
(5, 'HD2026100005', 10, 10, 100000, 890000, 0, 'CASH', 'PAID', DATEADD(DAY, -1, GETDATE()), @staffId, N'Thanh toán tiền mặt', DATEADD(DAY, -1, GETDATE()));
SET IDENTITY_INSERT dbo.Invoices OFF;

-- 13. BẢNG WARRANTIES (5 Sổ bảo hành điện tử chính hãng)
SET IDENTITY_INSERT dbo.Warranties ON;
INSERT INTO dbo.Warranties (
    WarrantyId, WarrantyCode, TicketId, CustomerId, DeviceId,
    StartDate, EndDate, WarrantyDays, Scope, Status, CreatedAt
) VALUES
(1, 'BH2026100001', 5, 5, 5, CAST(DATEADD(DAY, -4, GETDATE()) AS DATE), CAST(DATEADD(DAY, 361, GETDATE()) AS DATE), 365,
 N'Bảo hành chính hãng 1 đổi 1 trong 12 tháng cho ổ cứng SSD Samsung 980 PRO 1TB NVMe PCIe 4.0.', 'ACTIVE', DATEADD(DAY, -4, GETDATE())),

(2, 'BH2026100002', 7, 7, 7, CAST(DATEADD(DAY, -3, GETDATE()) AS DATE), CAST(DATEADD(DAY, 87, GETDATE()) AS DATE), 90,
 N'Bảo hành 03 tháng cụm chân sạc USB-C và mic thoại iPad Pro 11 M1.', 'ACTIVE', DATEADD(DAY, -3, GETDATE())),

(3, 'BH2026100003', 1, 1, 1, CAST(DATEADD(DAY, -2, GETDATE()) AS DATE), CAST(DATEADD(DAY, 28, GETDATE()) AS DATE), 30,
 N'Bảo hành 30 ngày hiệu năng giải nhiệt keo tản nhiệt gốm Thermal Grizzly Kryonaut trên laptop Dell XPS 15.', 'ACTIVE', DATEADD(DAY, -2, GETDATE())),

(4, 'BH2026100004', 9, 9, 9, CAST(DATEADD(DAY, -2, GETDATE()) AS DATE), CAST(DATEADD(DAY, 178, GETDATE()) AS DATE), 180,
 N'Bảo hành 06 tháng pin Pisen dung lượng cao chính hãng iPhone 13 (chai quá 20% đổi mới).', 'ACTIVE', DATEADD(DAY, -2, GETDATE())),

(5, 'BH2026100005', 10, 10, 10, CAST(DATEADD(DAY, -1, GETDATE()) AS DATE), CAST(DATEADD(DAY, 364, GETDATE()) AS DATE), 365,
 N'Bảo hành 12 tháng thanh RAM Laptop Kingston Fury DDR4 16GB 3200MHz.', 'ACTIVE', DATEADD(DAY, -1, GETDATE()));
SET IDENTITY_INSERT dbo.Warranties OFF;

-- 14. BẢNG STOCK TRANSACTIONS (Lịch sử nhập xuất kho linh kiện thực tế)
INSERT INTO dbo.StockTransactions (PartId, TransactionType, Quantity, UnitPrice, StockBefore, StockAfter, TicketId, PerformedByUserId, Note, TransactionAt) VALUES
-- Nhập kho đầu kỳ
(9, 'IN', 15, 1850000, 0, 15, NULL, @staffId, N'Nhập kho lô SSD Samsung 980 PRO từ Synnex FPT', DATEADD(DAY, -25, GETDATE())),
(16, 'IN', 40, 110000, 0, 40, NULL, @staffId, N'Nhập kho keo tản nhiệt Thermal Grizzly Kryonaut', DATEADD(DAY, -25, GETDATE())),
(14, 'IN', 10, 380000, 0, 10, NULL, @staffId, N'Nhập cụm cáp sạc Type-C linh kiện bóc máy', DATEADD(DAY, -25, GETDATE())),
(5, 'IN', 20, 580000, 0, 20, NULL, @staffId, N'Nhập lô pin Pisen dung lượng cao từ nhà phân phối 3A', DATEADD(DAY, -25, GETDATE())),
(12, 'IN', 15, 680000, 0, 15, NULL, @staffId, N'Nhập RAM laptop Kingston Fury DDR4', DATEADD(DAY, -25, GETDATE())),

-- Xuất kho cho sửa chữa
(9, 'OUT', 1, 2250000, 15, 14, 5, @tech1Id, N'Xuất thay thế SSD Samsung 980 PRO cho PC Gaming PSC202610005', DATEADD(DAY, -4, GETDATE())),
(14, 'OUT', 1, 620000, 10, 9, 7, @tech2Id, N'Xuất cụm cáp sạc Type-C thay cho iPad Pro PSC202610007', DATEADD(DAY, -3, GETDATE())),
(16, 'OUT', 1, 180000, 40, 39, 1, @tech1Id, N'Xuất tuýp keo tản nhiệt gốm tra cho Dell XPS 15 PSC202610001', DATEADD(DAY, -2, GETDATE())),
(5, 'OUT', 1, 790000, 20, 19, 9, @tech2Id, N'Xuất pin Pisen thay cho iPhone 13 PSC202610009', DATEADD(DAY, -2, GETDATE())),
(12, 'OUT', 1, 890000, 15, 14, 10, @tech1Id, N'Xuất thanh RAM 16GB lắp cho HP Envy 13 PSC202610010', DATEADD(DAY, -1, GETDATE()));

COMMIT TRANSACTION;
PRINT N'==> Hoàn tất nạp dữ liệu thực tế 100% cho RepairShopDB!';
