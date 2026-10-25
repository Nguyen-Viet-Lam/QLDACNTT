USE RepairShopDB;
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
SET NOCOUNT ON;

BEGIN TRANSACTION;

-- Lấy ID nhân sự
DECLARE @staffId INT = (SELECT TOP 1 UserId FROM dbo.Users WHERE Username = 'staff01');
DECLARE @tech1Id INT = (SELECT TOP 1 UserId FROM dbo.Users WHERE Username = 'tech01');
DECLARE @tech2Id INT = (SELECT TOP 1 UserId FROM dbo.Users WHERE Username = 'tech02');
DECLARE @defaultHash NVARCHAR(255) = '/Q.w615uRRoWTegplzlqOgpSv1/XHdjgD85ZOA/U1ax3e'; -- Abc@12345
DECLARE @custRole INT = (SELECT TOP 1 RoleId FROM dbo.Roles WHERE RoleCode = 'CUSTOMER');

-- 1. BỔ SUNG 15 KHÁCH HÀNG (CustomerId 11 -> 25)
SET IDENTITY_INSERT dbo.Customers ON;
INSERT INTO dbo.Customers (CustomerId, CustomerCode, FullName, Phone, Email, Address, Note, IsActive, CreatedAt) VALUES
(11, 'KH000011', N'Vũ Minh Tuấn', '0912348899', 'tuan.vu@gmail.com', N'72 Lê Thánh Tôn, Bến Nghé, Quận 1, TP.HCM', N'Khách hàng thân thiết', 1, DATEADD(DAY, -18, GETDATE())),
(12, 'KH000012', N'Đặng Thu Thảo', '0987112244', 'thao.dang@vietcombank.com.vn', N'11 Bến Chương Dương, Cầu Kho, Quận 1, TP.HCM', N'Chuyên viên Vietcombank', 1, DATEADD(DAY, -16, GETDATE())),
(13, 'KH000013', N'Lê Tấn Phát', '0908776655', 'phat.le@fpt.com', N'29 Lê Duẩn, Bến Nghé, Quận 1, TP.HCM', N'Kỹ sư hệ thống FPT', 1, DATEADD(DAY, -14, GETDATE())),
(14, 'KH000014', N'Phạm Ngọc Lan', '0932115599', 'lan.pham@techcombank.com.vn', N'198 Nguyễn Thị Minh Khai, Phường 6, Quận 3, TP.HCM', N'Quản lý Techcombank', 1, DATEADD(DAY, -13, GETDATE())),
(15, 'KH000015', N'Nguyễn Hữu Trí', '0978665511', 'tri.nguyenhuu@gmail.com', N'45 Trương Định, Phường 6, Quận 3, TP.HCM', N'Content Creator YouTube', 1, DATEADD(DAY, -11, GETDATE())),
(16, 'KH000016', N'Trần Bảo Long', '0919334422', 'long.tranbao@gmail.com', N'209 Nam Kỳ Khởi Nghĩa, Phường 7, Quận 3, TP.HCM', N'Kiến trúc sư xây dựng', 1, DATEADD(DAY, -9, GETDATE())),
(17, 'KH000017', N'Huỳnh Quốc Dũng', '0968221177', 'dung.hq@gameloft.com', N'80 Nguyễn Huệ, Phường Bến Nghé, Quận 1, TP.HCM', N'Game Designer Gameloft', 1, DATEADD(DAY, -8, GETDATE())),
(18, 'KH000018', N'Đoàn Thanh Hương', '0909554488', 'huong.doan@gmail.com', N'150 Nguyễn Đình Chiểu, Phường 6, Quận 3, TP.HCM', N'Chủ chuỗi cửa hàng hoa tươi', 1, DATEADD(DAY, -7, GETDATE())),
(19, 'KH000019', N'Hoàng Gia Huy', '0989332211', 'huy.hoanggia@gmail.com', N'256 Xô Viết Nghệ Tĩnh, Phường 21, Bình Thạnh, TP.HCM', N'Sinh viên ĐH Ngoại Thương', 1, DATEADD(DAY, -6, GETDATE())),
(20, 'KH000020', N'Đinh Văn Sơn', '0914667788', 'son.dinhvan@shopee.vn', N'56 Hoàng Diệu, Phường 12, Quận 4, TP.HCM', N'Quản lý sàn TMĐT Shopee', 1, DATEADD(DAY, -5, GETDATE())),
(21, 'KH000021', N'Trịnh Cẩm Tú', '0977889900', 'tu.trinhcam@vinamilk.com.vn', N'10 Tân Trào, Tân Phú, Quận 7, TP.HCM', N'Kế toán trưởng Vinamilk', 1, DATEADD(DAY, -4, GETDATE())),
(22, 'KH000022', N'Bùi Minh Triết', '0907113355', 'triet.bui@gmail.com', N'38 Nguyễn Văn Trỗi, Phường 15, Phú Nhuận, TP.HCM', N'Nhiếp ảnh gia tự do', 1, DATEADD(DAY, -3, GETDATE())),
(23, 'KH000023', N'Cao Khánh Linh', '0983445566', 'linh.caokhanh@gmail.com', N'182 Lê Văn Sỹ, Phường 10, Phú Nhuận, TP.HCM', N'Chủ shop thời trang online', 1, DATEADD(DAY, -2, GETDATE())),
(24, 'KH000024', N'Lâm Thế Vinh', '0918223344', 'vinh.lamthe@vng.com.vn', N'182 Ba Tháng Hai, Phường 12, Quận 10, TP.HCM', N'Kỹ sư phần mềm VNG Corp', 1, DATEADD(DAY, -1, GETDATE())),
(25, 'KH000025', N'Mai Thanh Hà', '0906778899', 'ha.maithanh@gmail.com', N'91 Sư Vạn Hạnh, Phường 12, Quận 10, TP.HCM', N'Bác sĩ nha khoa Quốc tế', 1, GETDATE());
SET IDENTITY_INSERT dbo.Customers OFF;

-- 2. BỔ SUNG 18 THIẾT BỊ (DeviceId 11 -> 28)
SET IDENTITY_INSERT dbo.Devices ON;
INSERT INTO dbo.Devices (DeviceId, DeviceCode, CustomerId, DeviceType, Brand, Model, SerialNumber, Note, CreatedAt) VALUES
(11, 'TB000011', 11, N'Điện thoại', 'Apple', N'iPhone 15 Pro Max 256GB Natural Titanium', 'NM9X20PMAA', N'Máy mới bóc hộp 3 tháng', DATEADD(DAY, -18, GETDATE())),
(12, 'TB000012', 12, N'Laptop', 'Apple', N'MacBook Air 13 M1 2020 Space Gray', 'C02F99MBAA', N'Máy văn phòng mỏng nhẹ', DATEADD(DAY, -16, GETDATE())),
(13, 'TB000013', 13, N'Laptop', 'Asus', N'Asus TUF Gaming A15 (Ryzen 7 / RTX 3050)', 'AS-TUF-A15-VN', N'Laptop đồ họa & game', DATEADD(DAY, -14, GETDATE())),
(14, 'TB000014', 14, N'Điện thoại', 'Apple', N'iPhone 12 Pro 128GB Pacific Blue', 'F17D9890MD6P', N'Máy chính hãng LL/A', DATEADD(DAY, -13, GETDATE())),
(15, 'TB000015', 15, N'Máy tính PC', 'NZXT / Corsair', N'PC Workstation Core i9-13900K / RTX 4080 16GB', 'PCG-CUSTOM-4080', N'Cấu hình dựng phim 4K', DATEADD(DAY, -11, GETDATE())),
(16, 'TB000016', 16, N'Laptop', 'Lenovo', N'ThinkPad T14 Gen 3 Core i5-1240P / 16GB RAM', 'PF3398T14G3', N'Máy chuẩn quân đội Mỹ', DATEADD(DAY, -9, GETDATE())),
(17, 'TB000017', 17, N'Điện thoại', 'Samsung', N'Galaxy Z Fold5 5G 512GB Icy Blue', 'R5CW88FOLD5', N'Màn hình gập cao cấp', DATEADD(DAY, -8, GETDATE())),
(18, 'TB000018', 18, N'Máy tính bảng', 'Apple', N'iPad Air 5 64GB Wi-Fi M1 Purple', 'DMPD98AIR5VN', N'Vẽ minh họa iPadOS 17', DATEADD(DAY, -7, GETDATE())),
(19, 'TB000019', 19, N'Laptop', 'Dell', N'Inspiron 5510 Core i7-11370H / 16GB', 'DL-INS-5510-VN', N'Học tập và lập trình', DATEADD(DAY, -6, GETDATE())),
(20, 'TB000020', 20, N'Điện thoại', 'Xiaomi', N'Xiaomi 13 Pro 5G Leica 256GB Black', 'XM13P-LEICA-VN', N'Camera hợp tác Leica', DATEADD(DAY, -5, GETDATE())),
(21, 'TB000021', 21, N'Laptop', 'Apple', N'MacBook Pro 16 M3 Max 36GB / 1TB Space Black', 'C02M3MAX16VN', N'Máy lập trình cao cấp', DATEADD(DAY, -4, GETDATE())),
(22, 'TB000022', 22, N'Laptop', 'Acer', N'Nitro 5 Tiger AN515-58 Core i5-12500H / RTX 3050Ti', 'NHQFZSV001', N'Dùng chỉnh ảnh Lightroom', DATEADD(DAY, -3, GETDATE())),
(23, 'TB000023', 23, N'Điện thoại', 'Apple', N'iPhone 11 64GB Black', 'DX3D88IP11VN', N'Máy dùng livestream bán hàng', DATEADD(DAY, -2, GETDATE())),
(24, 'TB000024', 24, N'Laptop', 'HP', N'Pavilion 15-eg2000 Core i5-1240P / 8GB', '5CD299HPVN', N'Laptop code Backend', DATEADD(DAY, -1, GETDATE())),
(25, 'TB000025', 25, N'Máy tính bàn', 'Apple', N'iMac 24" 4.5K Retina M1 8-core CPU / 8-core GPU Blue', 'C02G77IMAC24', N'Máy để quầy lễ tân nha khoa', GETDATE()),
(26, 'TB000026', 11, N'Điện thoại', 'Apple', N'iPhone 14 Plus 128GB Midnight', 'F2LX88PLUSVN', N'Máy phụ dùng nghe gọi', DATEADD(DAY, -15, GETDATE())),
(27, 'TB000027', 14, N'Laptop', 'Dell', N'XPS 13 Plus 9320 Core i7-1260P Touch', 'DL-9320-PLUS-VN', N'Laptop mỏng nhẹ doanh nhân', DATEADD(DAY, -10, GETDATE())),
(28, 'TB000028', 16, N'Điện thoại', 'Samsung', N'Galaxy S22+ 5G 128GB Phantom White', 'R5CW66S22P', N'Máy phụ', DATEADD(DAY, -8, GETDATE()));
SET IDENTITY_INSERT dbo.Devices OFF;

-- 3. BỔ SUNG 15 PHIẾU SỬA CHỮA (TicketId 11 -> 25)
SET IDENTITY_INSERT dbo.RepairTickets ON;
INSERT INTO dbo.RepairTickets (
    TicketId, TicketCode, CustomerId, DeviceId, ServiceTypeId, ReceivedByUserId, TechnicianUserId,
    Status, DeviceCondition, CustomerRequest, Diagnosis, QuotedLaborCost, QuotedPartsCost,
    IsWarrantyRepair, ReceivedAt, ExpectedFinishAt, CompletedAt, DeliveredAt, CancelReason, CreatedAt
) VALUES
-- 11. WAITING_CONFIRM: iPhone 15 Pro Max nứt mặt kính ngoài
(11, 'PSC202610011', 11, 11, 8, @staffId, @tech2Id,
 'WAITING_CONFIRM',
 N'Máy bị rơi nứt mạng nhện góc trên kính bảo vệ, hiển thị và cảm ứng đa điểm vẫn mượt mà không bị kẻ sọc.',
 N'Ép kính zin giữ nguyên màn hình gốc Dynamic Island.',
 N'Kính ngoài rạn vỡ, phôi màn hình OLED và cảm ứng 120Hz hoàn toàn bình thường. Đã tư vấn khách phương án ép kính chân không công nghệ OCA chống bọt.',
 250000, 450000, 0, DATEADD(DAY, -1, GETDATE()), DATEADD(DAY, 1, GETDATE()), NULL, NULL, NULL, DATEADD(DAY, -1, GETDATE())),

-- 12. REPAIRING: MacBook Air M1 thay pin zin
(12, 'PSC202610012', 12, 12, 2, @staffId, @tech1Id,
 'REPAIRING',
 N'Pin báo Service Recommended, chu kỳ sạc 950 lần, dùng văn phòng chỉ được hơn 1.5 tiếng là báo pin yếu.',
 N'Thay pin chính hãng và vệ sinh bo mạch.',
 N'Pin bị phù nhẹ khoang giữa. Kỹ thuật viên đang tháo ráp thay cell pin mới, dán keo seal chống rung và căn chỉnh mạch BMS.',
 100000, 1250000, 0, DATEADD(DAY, -1, GETDATE()), DATEADD(DAY, 1, GETDATE()), NULL, NULL, NULL, DATEADD(DAY, -1, GETDATE())),

-- 13. COMPLETED: Asus TUF Gaming bảo dưỡng vệ sinh tra keo tản nhiệt
(13, 'PSC202610013', 13, 13, 3, @staffId, @tech1Id,
 'COMPLETED',
 N'Nhiệt độ GPU lên 89°C khi chơi CS2, máy tự hạ xung nhịp gây giật lag tụt FPS.',
 N'Vệ sinh toàn bộ quạt và tra keo gốm loại xịn nhất.',
 N'Hệ thống tản nhiệt bám dày sợi bông bụi. Đã vệ sinh quạt kép, tra keo gốm Kryonaut, nhiệt độ GPU giảm sâu còn 74°C khi tải 100%.',
 150000, 180000, 0, DATEADD(DAY, -2, GETDATE()), DATEADD(DAY, -1, GETDATE()), DATEADD(DAY, -1, GETDATE()), NULL, NULL, DATEADD(DAY, -2, GETDATE())),

-- 14. DELIVERED: iPhone 12 Pro thay màn hình (Đã thanh toán)
(14, 'PSC202610014', 14, 14, 1, @staffId, @tech2Id,
 'DELIVERED',
 N'Rơi rớt nước ngấm viền dưới, màn hình đen thui chớp nháy sọc trắng, máy vẫn đổ chuông cuộc gọi đến.',
 N'Thay màn hình chất lượng cao, giữ Face ID.',
 N'Chập panel cáp tín hiệu MIPI. Đã thay thế màn hình OLED Super Retina, sang IC gốc giữ True Tone, test cảm ứng và Face ID hoạt động hoàn hảo.',
 150000, 3200000, 0, DATEADD(DAY, -4, GETDATE()), DATEADD(DAY, -3, GETDATE()), DATEADD(DAY, -3, GETDATE()), DATEADD(DAY, -3, GETDATE()), NULL, DATEADD(DAY, -4, GETDATE())),

-- 15. COMPLETED: PC Workstation Core i9 nâng cấp SSD Samsung 980 PRO (Chưa thanh toán - UNPAID)
(15, 'PSC202610015', 15, 15, 6, @staffId, @tech1Id,
 'COMPLETED',
 N'Ổ cứng SSD cũ chỉ có 256GB bị đầy dung lượng, render video Premiere báo disk full không xuất file được.',
 N'Lắp thêm SSD NVMe 1TB Samsung 980 PRO Gen 4 tốc độ cao để làm ổ cache đồ họa.',
 N'Đã lắp đặt SSD Samsung 980 PRO 1TB vào khe M.2 PCIe 4.0 trên mainboard ASUS Z790, định dạng NTFS, benchmark tốc độ đọc đạt 6950 MB/s.',
 120000, 2250000, 0, DATEADD(DAY, -1, GETDATE()), GETDATE(), GETDATE(), NULL, NULL, DATEADD(DAY, -1, GETDATE())),

-- 16. DELIVERED: ThinkPad T14 cài đặt hệ điều hành bản quyền (Đã thanh toán)
(16, 'PSC202610016', 16, 16, 4, @staffId, @tech1Id,
 'DELIVERED',
 N'Máy bị nhiễm virus mã độc quảng cáo, mở trình duyệt tự nhảy tab lừa đảo, máy khởi động mất 3 phút.',
 N'Format sạch sẽ cài lại Windows 11 Pro 64-bit và Office bản quyền.',
 N'Đã sao lưu thư mục tài liệu Desktop/Documents, phân vùng lại ổ cứng GPT, cài đặt Windows 11 Pro sạch, kích hoạt bảo mật BitLocker.',
 100000, 0, 0, DATEADD(DAY, -3, GETDATE()), DATEADD(DAY, -2, GETDATE()), DATEADD(DAY, -2, GETDATE()), DATEADD(DAY, -2, GETDATE()), NULL, DATEADD(DAY, -3, GETDATE())),

-- 17. DIAGNOSING: Galaxy Z Fold5 đơ cáp gập
(17, 'PSC202610017', 17, 17, 5, @staffId, @tech2Id,
 'DIAGNOSING',
 N'Mở gập máy ra thì màn hình trong chớp tắt mất hiển thị, gập lại dùng màn hình ngoài thì bình thường.',
 N'Kiểm tra cáp flex bản lề và báo giá trước khi làm.',
 N'Đứt ngầm đường tín hiệu cáp flex nối giữa 2 nửa thân máy qua trục bản lề. Kỹ thuật viên đang kiểm tra mức độ tổn thương bo mạch phụ.',
 450000, 0, 0, GETDATE(), DATEADD(DAY, 2, GETDATE()), NULL, NULL, NULL, GETDATE()),

-- 18. RECEIVED: iPad Air 5 gãy chân sạc Type-C
(18, 'PSC202610018', 18, 18, 7, @staffId, NULL,
 'RECEIVED',
 N'Cắm sạc qua đêm bị quẹt chân làm gãy chấu đồng bên trong cổng Type-C, hiện không nhận sạc.',
 N'Tiếp nhận kiểm tra thay bo cổng sạc zin.',
 NULL,
 150000, 620000, 0, GETDATE(), DATEADD(DAY, 1, GETDATE()), NULL, NULL, NULL, GETDATE()),

-- 19. COMPLETED: Dell Inspiron 5510 thay bàn phím led (Chưa thanh toán - UNPAID)
(19, 'PSC202610019', 19, 19, 9, @staffId, @tech1Id,
 'COMPLETED',
 N'Bị đổ nước ngọt dính phím Enter và hàng số, gõ một phím nhảy ra nhiều ký tự lạ.',
 N'Thay cụm phím mới chính hãng có đèn nền.',
 N'Đã thay mới cụm bàn phím Dell Inspiron có đèn led nền, tán đinh nhiệt cố định chắc chắn, test toàn bộ 104 phím nảy êm chuẩn xác.',
 120000, 950000, 0, DATEADD(DAY, -1, GETDATE()), GETDATE(), GETDATE(), NULL, NULL, DATEADD(DAY, -1, GETDATE())),

-- 20. DELIVERED: Xiaomi 13 Pro thay kính camera Leica (Đã thanh toán)
(20, 'PSC202610020', 20, 20, 8, @staffId, @tech2Id,
 'DELIVERED',
 N'Bị va chìa khóa nứt mặt kính bảo vệ camera sau, chụp ảnh bị lóa sáng chói viền.',
 N'Thay mặt kính camera Sapphire chính hãng.',
 N'Cụm thấu kính bên trong còn nguyên vẹn. Đã bóc lớp kính nứt, hút chân không sạch bụi cảm biến và dán kính Sapphire chống trầy mới.',
 150000, 280000, 0, DATEADD(DAY, -2, GETDATE()), DATEADD(DAY, -1, GETDATE()), DATEADD(DAY, -1, GETDATE()), DATEADD(DAY, -1, GETDATE()), NULL, DATEADD(DAY, -2, GETDATE())),

-- 21. REPAIRING: MacBook Pro 16 M3 Max vệ sinh quạt tản nhiệt
(21, 'PSC202610021', 21, 21, 3, @staffId, @tech1Id,
 'REPAIRING',
 N'Dùng render dựng phim 8K quạt hú to liên tục, nhiệt độ bề mặt nhôm kê tay rất nóng.',
 N'Vệ sinh bảo dưỡng định kỳ buồng hơi tản nhiệt.',
 N'Bụi mịn bám kín lá tản nhiệt buồng hơi Vapor Chamber. Đang tiến hành vệ sinh siêu âm cánh quạt và thay mỡ tản nhiệt đặc thù cho chip M3 Max.',
 150000, 180000, 0, GETDATE(), DATEADD(DAY, 1, GETDATE()), NULL, NULL, NULL, GETDATE()),

-- 22. DIAGNOSING: Acer Nitro 5 cứu dữ liệu ổ cứng
(22, 'PSC202610022', 22, 22, 10, @staffId, @tech1Id,
 'DIAGNOSING',
 N'Máy bị rơi từ trên bàn làm việc xuống đất, bật nguồn đèn báo chớp rồi vào thẳng BIOS không nhận ổ cứng.',
 N'Cứu toàn bộ dữ liệu đồ án tốt nghiệp trong ổ cứng.',
 N'Ổ cứng SSD NVMe chập tụ nguồn bảo vệ cổng M.2, kỹ thuật viên đang câu dây bypass đường 3.3V để đọc chip nhớ NAND flash.',
 500000, 0, 0, GETDATE(), DATEADD(DAY, 2, GETDATE()), NULL, NULL, NULL, GETDATE()),

-- 23. DELIVERED: iPhone 11 thay pin Pisen dung lượng cao (Đã thanh toán)
(23, 'PSC202610023', 23, 23, 2, @staffId, @tech2Id,
 'DELIVERED',
 N'Pin chai 68%, sạc đầy dùng được khoảng 2 tiếng là hết, máy hay bị ấm vùng pin.',
 N'Thay pin Pisen chính hãng bảo hành dài hạn.',
 N'Đã thay pin Pisen dung lượng cao 3110mAh, kích pin chuẩn chu kỳ 0 lần, kiểm tra sạc xả ổn định.',
 100000, 580000, 0, DATEADD(DAY, -3, GETDATE()), DATEADD(DAY, -2, GETDATE()), DATEADD(DAY, -2, GETDATE()), DATEADD(DAY, -2, GETDATE()), NULL, DATEADD(DAY, -3, GETDATE())),

-- 24. DELIVERED: HP Pavilion 15 nâng cấp SSD Kingston 512GB (Đã thanh toán)
(24, 'PSC202610024', 24, 24, 6, @staffId, @tech1Id,
 'DELIVERED',
 N'Khởi động vào Windows mất gần 5 phút, mở file Excel báo not responding do ổ HDD cũ quay 5400rpm.',
 N'Thay thế bằng SSD Kingston NV2 512GB tốc độ cao.',
 N'Đã sao chép toàn bộ dữ liệu người dùng, lắp SSD Kingston NV2 PCIe 4.0, khởi động máy chỉ mất 8 giây.',
 120000, 950000, 0, DATEADD(DAY, -2, GETDATE()), DATEADD(DAY, -1, GETDATE()), DATEADD(DAY, -1, GETDATE()), DATEADD(DAY, -1, GETDATE()), NULL, DATEADD(DAY, -2, GETDATE())),

-- 25. CANCELLED: iMac 24" M1 hỏng mạch cao áp (Khách hủy)
(25, 'PSC202610025', 25, 25, 5, @staffId, @tech1Id,
 'CANCELLED',
 N'Màn hình iMac tự nhiên tối đen, đèn báo nguồn máy vẫn sáng nhưng không hiển thị gì.',
 N'Kiểm tra báo giá thay thế linh kiện.',
 N'Chập cụm driver LED backlight trên tấm nền màn hình 4.5K Retina, cần thay thế cả cụm màn hình hãng chi phí cao.',
 450000, 7900000, 0, DATEADD(DAY, -3, GETDATE()), DATEADD(DAY, -1, GETDATE()), NULL, NULL, N'Khách không đồng ý thay thế cụm màn hình do chi phí linh kiện chính hãng vượt ngân sách dự kiến.', DATEADD(DAY, -3, GETDATE()));
SET IDENTITY_INSERT dbo.RepairTickets OFF;

-- 4. BỔ SUNG TICKET PARTS
INSERT INTO dbo.TicketParts (TicketId, PartId, Quantity, UnitPrice, Note, CreatedAt) VALUES
(13, 16, 1, 180000, N'Keo tản nhiệt gốm Kryonaut cho Asus TUF', DATEADD(DAY, -1, GETDATE())),
(14, 1, 1, 3200000, N'Màn hình OLED iPhone 12 Pro zin', DATEADD(DAY, -3, GETDATE())),
(15, 9, 1, 2250000, N'SSD Samsung 980 PRO 1TB PCIe NVMe', DATEADD(DAY, -1, GETDATE())),
(19, 15, 1, 950000, N'Bàn phím laptop led có đèn nền', DATEADD(DAY, -1, GETDATE())),
(20, 18, 1, 280000, N'Mặt kính camera Sapphire cao cấp', DATEADD(DAY, -1, GETDATE())),
(23, 5, 1, 580000, N'Pin Pisen chính hãng iPhone 11', DATEADD(DAY, -2, GETDATE())),
(24, 10, 1, 950000, N'SSD Kingston NV2 512GB M.2 PCIe', DATEADD(DAY, -1, GETDATE()));

-- 5. BỔ SUNG TICKET STATUS HISTORY
INSERT INTO dbo.TicketStatusHistory (TicketId, FromStatus, ToStatus, ChangedByUserId, Note, ChangedAt) VALUES
(11, NULL, 'RECEIVED', @staffId, N'Tiếp nhận iPhone 15 Pro Max vỡ kính mép', DATEADD(DAY, -1, GETDATE())),
(11, 'RECEIVED', 'WAITING_CONFIRM', @staffId, N'Báo giá ép kính 700.000đ cho khách qua điện thoại', DATEADD(HOUR, -5, GETDATE())),

(12, NULL, 'RECEIVED', @staffId, N'Tiếp nhận MacBook Air M1 chai pin', DATEADD(DAY, -1, GETDATE())),
(12, 'RECEIVED', 'REPAIRING', @tech1Id, N'Tiến hành tháo cụm pin cũ thay thế pin mới', DATEADD(HOUR, -8, GETDATE())),

(13, NULL, 'RECEIVED', @staffId, N'Tiếp nhận Asus TUF nhiệt độ cao', DATEADD(DAY, -2, GETDATE())),
(13, 'RECEIVED', 'COMPLETED', @tech1Id, N'Vệ sinh tra keo Kryonaut mát 74 độ C', DATEADD(DAY, -1, GETDATE())),

(14, NULL, 'RECEIVED', @staffId, N'Tiếp nhận iPhone 12 Pro sọc màn hình', DATEADD(DAY, -4, GETDATE())),
(14, 'RECEIVED', 'COMPLETED', @tech2Id, N'Thay màn hình OLED hoàn tất test OK', DATEADD(DAY, -3, GETDATE())),
(14, 'COMPLETED', 'DELIVERED', @staffId, N'Khách đã thanh toán nhận máy', DATEADD(DAY, -3, GETDATE())),

(15, NULL, 'RECEIVED', @staffId, N'Tiếp nhận PC Workstation nâng cấp SSD', DATEADD(DAY, -1, GETDATE())),
(15, 'RECEIVED', 'COMPLETED', @tech1Id, N'Lắp đặt SSD Samsung 980 PRO 1TB', GETDATE()),

(16, NULL, 'RECEIVED', @staffId, N'Tiếp nhận ThinkPad T14 nhiễm virus', DATEADD(DAY, -3, GETDATE())),
(16, 'RECEIVED', 'DELIVERED', @staffId, N'Cài đặt Windows 11 hoàn tất, bàn giao khách', DATEADD(DAY, -2, GETDATE())),

(17, NULL, 'RECEIVED', @staffId, N'Tiếp nhận Z Fold5 chập màn hình trong', GETDATE()),
(17, 'RECEIVED', 'DIAGNOSING', @tech2Id, N'KTV đang đo cáp gập bản lề', GETDATE()),

(18, NULL, 'RECEIVED', @staffId, N'Tiếp nhận iPad Air 5 gãy chân Type-C', GETDATE()),

(19, NULL, 'RECEIVED', @staffId, N'Tiếp nhận Dell Inspiron liệt phím', DATEADD(DAY, -1, GETDATE())),
(19, 'RECEIVED', 'COMPLETED', @tech1Id, N'Thay bàn phím mới hoàn tất', GETDATE()),

(20, NULL, 'RECEIVED', @staffId, N'Tiếp nhận Xiaomi 13 Pro nứt kính camera', DATEADD(DAY, -2, GETDATE())),
(20, 'RECEIVED', 'DELIVERED', @staffId, N'Thay kính Sapphire Leica và bàn giao', DATEADD(DAY, -1, GETDATE())),

(21, NULL, 'RECEIVED', @staffId, N'Tiếp nhận MacBook Pro 16 M3 Max', GETDATE()),
(21, 'RECEIVED', 'REPAIRING', @tech1Id, N'Đang vệ sinh buồng hơi tản nhiệt', GETDATE()),

(22, NULL, 'RECEIVED', @staffId, N'Tiếp nhận Acer Nitro 5 cứu dữ liệu', GETDATE()),
(22, 'RECEIVED', 'DIAGNOSING', @tech1Id, N'Đang đo mạch NAND SSD', GETDATE()),

(23, NULL, 'RECEIVED', @staffId, N'Tiếp nhận iPhone 11 thay pin', DATEADD(DAY, -3, GETDATE())),
(23, 'RECEIVED', 'DELIVERED', @staffId, N'Đã thay pin Pisen dung lượng cao', DATEADD(DAY, -2, GETDATE())),

(24, NULL, 'RECEIVED', @staffId, N'Tiếp nhận HP Pavilion nâng cấp SSD', DATEADD(DAY, -2, GETDATE())),
(24, 'RECEIVED', 'DELIVERED', @staffId, N'Đã nâng cấp SSD Kingston 512GB', DATEADD(DAY, -1, GETDATE())),

(25, NULL, 'RECEIVED', @staffId, N'Tiếp nhận iMac 24 hỏng màn hình', DATEADD(DAY, -3, GETDATE())),
(25, 'RECEIVED', 'CANCELLED', @staffId, N'Khách hủy sửa chữa do chi phí linh kiện cao', DATEADD(DAY, -1, GETDATE()));

-- 6. BỔ SUNG 7 HÓA ĐƠN (InvoiceId 6 -> 12)
-- Gồm 5 hóa đơn PAID và 2 hóa đơn UNPAID (PSC 15 & 19)
SET IDENTITY_INSERT dbo.Invoices ON;
INSERT INTO dbo.Invoices (
    InvoiceId, InvoiceCode, TicketId, CustomerId, LaborCost, PartsCost, DiscountAmount,
    PaymentMethod, PaymentStatus, PaidAt, CreatedByUserId, Note, CreatedAt
) VALUES
(6, 'HD2026100006', 14, 14, 150000, 3200000, 50000, 'TRANSFER', 'PAID', DATEADD(DAY, -3, GETDATE()), @staffId, N'Khách thanh toán chuyển khoản QR, chiết khấu 50k tri ân', DATEADD(DAY, -3, GETDATE())),
(7, 'HD2026100007', 16, 16, 100000, 0, 0, 'CASH', 'PAID', DATEADD(DAY, -2, GETDATE()), @staffId, N'Thanh toán tiền mặt cài Windows', DATEADD(DAY, -2, GETDATE())),
(8, 'HD2026100008', 20, 20, 150000, 280000, 0, 'TRANSFER', 'PAID', DATEADD(DAY, -1, GETDATE()), @staffId, N'Chuyển khoản Vietcombank', DATEADD(DAY, -1, GETDATE())),
(9, 'HD2026100009', 23, 23, 100000, 580000, 0, 'TRANSFER', 'PAID', DATEADD(DAY, -2, GETDATE()), @staffId, N'Chuyển khoản MBBank', DATEADD(DAY, -2, GETDATE())),
(10, 'HD2026100010', 24, 24, 120000, 950000, 0, 'CASH', 'PAID', DATEADD(DAY, -1, GETDATE()), @staffId, N'Thanh toán tiền mặt nâng cấp SSD', DATEADD(DAY, -1, GETDATE())),
(11, 'HD2026100011', 15, 15, 120000, 2250000, 0, 'TRANSFER', 'UNPAID', DATEADD(DAY, -1, GETDATE()), @staffId, N'Hóa đơn chờ thanh toán khi khách đến nhận máy PC', DATEADD(DAY, -1, GETDATE())),
(12, 'HD2026100012', 19, 19, 120000, 950000, 0, 'CASH', 'UNPAID', GETDATE(), @staffId, N'Hóa đơn chờ thanh toán thay bàn phím Dell Inspiron', GETDATE());
SET IDENTITY_INSERT dbo.Invoices OFF;

-- 7. BỔ SUNG 7 SỔ BẢO HÀNH (WarrantyId 6 -> 12)
SET IDENTITY_INSERT dbo.Warranties ON;
INSERT INTO dbo.Warranties (
    WarrantyId, WarrantyCode, TicketId, CustomerId, DeviceId,
    StartDate, EndDate, WarrantyDays, Scope, Status, CreatedAt
) VALUES
(6, 'BH2026100006', 14, 14, 14, CAST(DATEADD(DAY, -3, GETDATE()) AS DATE), CAST(DATEADD(DAY, 87, GETDATE()) AS DATE), 90,
 N'Bảo hành 03 tháng màn hình OLED Super Retina iPhone 12 Pro (bao sọc, đơ cảm ứng).', 'ACTIVE', DATEADD(DAY, -3, GETDATE())),

(7, 'BH2026100007', 16, 16, 16, CAST(DATEADD(DAY, -2, GETDATE()) AS DATE), CAST(DATEADD(DAY, 28, GETDATE()) AS DATE), 30,
 N'Hỗ trợ kỹ thuật phần mềm và kích hoạt bản quyền Windows 11 Pro 30 ngày.', 'ACTIVE', DATEADD(DAY, -2, GETDATE())),

(8, 'BH2026100008', 20, 20, 20, CAST(DATEADD(DAY, -1, GETDATE()) AS DATE), CAST(DATEADD(DAY, 89, GETDATE()) AS DATE), 90,
 N'Bảo hành mặt kính camera Sapphire Leica 03 tháng chống bụi, bong keo.', 'ACTIVE', DATEADD(DAY, -1, GETDATE())),

(9, 'BH2026100009', 23, 23, 23, CAST(DATEADD(DAY, -2, GETDATE()) AS DATE), CAST(DATEADD(DAY, 178, GETDATE()) AS DATE), 180,
 N'Bảo hành 06 tháng pin Pisen iPhone 11 dung lượng cao, chai quá 20% đổi viên mới.', 'ACTIVE', DATEADD(DAY, -2, GETDATE())),

(10, 'BH2026100010', 24, 24, 24, CAST(DATEADD(DAY, -1, GETDATE()) AS DATE), CAST(DATEADD(DAY, 364, GETDATE()) AS DATE), 365,
 N'Bảo hành 1 đổi 1 trong 365 ngày đối với SSD Kingston NV2 512GB chính hãng SPC.', 'ACTIVE', DATEADD(DAY, -1, GETDATE())),

(11, 'BH2026100011', 13, 13, 13, CAST(DATEADD(DAY, -35, GETDATE()) AS DATE), CAST(DATEADD(DAY, -5, GETDATE()) AS DATE), 30,
 N'Bảo hành 30 ngày keo tản nhiệt gốm Kryonaut cho laptop Asus TUF (đã hết hạn bảo hành).', 'EXPIRED', DATEADD(DAY, -35, GETDATE())),

(12, 'BH2026100012', 10, 10, 10, CAST(DATEADD(DAY, -1, GETDATE()) AS DATE), CAST(DATEADD(DAY, 364, GETDATE()) AS DATE), 365,
 N'Bảo hành 12 tháng ổ cứng SSD gắn ngoài.', 'ACTIVE', DATEADD(DAY, -1, GETDATE()));
SET IDENTITY_INSERT dbo.Warranties OFF;

-- 8. BỔ SUNG LỊCH SỬ KHO (StockTransactions)
INSERT INTO dbo.StockTransactions (PartId, TransactionType, Quantity, UnitPrice, StockBefore, StockAfter, TicketId, PerformedByUserId, Note, TransactionAt) VALUES
(10, 'IN', 20, 720000, 0, 20, NULL, @staffId, N'Nhập thêm 20 chiếc SSD Kingston NV2 512GB', DATEADD(DAY, -10, GETDATE())),
(18, 'IN', 15, 150000, 0, 15, NULL, @staffId, N'Nhập kính Sapphire camera', DATEADD(DAY, -10, GETDATE())),
(1, 'OUT', 1, 3200000, 6, 5, 14, @tech2Id, N'Xuất màn hình thay cho iPhone 12 Pro PSC202610014', DATEADD(DAY, -3, GETDATE())),
(18, 'OUT', 1, 280000, 9, 8, 20, @tech2Id, N'Xuất kính camera thay cho Xiaomi 13 Pro PSC202610020', DATEADD(DAY, -1, GETDATE())),
(10, 'OUT', 1, 950000, 18, 17, 24, @tech1Id, N'Xuất SSD Kingston thay cho HP Pavilion PSC202610024', DATEADD(DAY, -1, GETDATE()));

COMMIT TRANSACTION;
PRINT N'==> Hoàn tất nạp thêm 15 khách hàng, 18 thiết bị, 15 phiếu sửa chữa, 7 hóa đơn, 7 sổ bảo hành!';