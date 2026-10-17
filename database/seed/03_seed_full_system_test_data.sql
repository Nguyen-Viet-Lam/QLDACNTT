/* =====================================================================
   LV33-001 — Hệ thống quản lý tổng thể cho cửa hàng sửa chữa (Nhóm 11)
   Mã công việc Jira: MBA-75
   Nhiệm vụ: Lập bộ dữ liệu kiểm thử hệ thống tổng thể (Full System Test Data)
   Phụ trách: Nguyễn Đại Kỳ (UI/UX Designer & QA Tester Lead - MSSV: 2380601178)

   Quy mô bộ dữ liệu:
   - 50 Khách hàng (Cá nhân, Doanh nghiệp, Khách VIP, Khách mới, Khách vãng lai)
   - 60 Thiết bị (Laptop Dell/HP/Asus/Lenovo/MacBook, Smartphone iPhone/Samsung/Xiaomi, iPad)
   - 100 Phiếu sửa chữa kiểm thử bao phủ toàn bộ các trạng thái vòng đời:
     * RECEIVED (Mới tiếp nhận chờ phân công)
     * DIAGNOSING (Kỹ thuật viên đang chẩn đoán và báo giá)
     * IN_REPAIR (Đang thay thế linh kiện và sửa chữa)
     * COMPLETED (Đã sửa xong, đã test chức năng đạt)
     * DELIVERED (Đã bàn giao cho khách)
     * PAID (Đã lập hóa đơn và thanh toán thành công)
     * CANCELLED (Trường hợp ngoại lệ: Khách không đồng ý giá, máy hỏng nặng trả lại)
   ===================================================================== */

USE RepairShopDB;
GO

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

PRINT N'--> Bắt đầu nạp bộ dữ liệu kiểm thử tổng thể MBA-75 (Nguyễn Đại Kỳ)...';

/* =====================================================================
   1. NẠP 50 KHÁCH HÀNG KIỂM THỬ (KH000003 -> KH000052)
   ===================================================================== */
BEGIN TRANSACTION;

DECLARE @i INT = 3;
DECLARE @custCode VARCHAR(10);
DECLARE @phone VARCHAR(15);
DECLARE @fullName NVARCHAR(100);
DECLARE @email VARCHAR(100);
DECLARE @address NVARCHAR(200);
DECLARE @note NVARCHAR(200);

-- Mảng họ tên mẫu
DECLARE @Ho TABLE (Id INT IDENTITY(1,1), Name NVARCHAR(20));
INSERT INTO @Ho (Name) VALUES (N'Nguyễn'), (N'Trần'), (N'Lê'), (N'Phạm'), (N'Hoàng'), (N'Huỳnh'), (N'Phan'), (N'Vũ'), (N'Võ'), (N'Đặng');

DECLARE @Dem TABLE (Id INT IDENTITY(1,1), Name NVARCHAR(20));
INSERT INTO @Dem (Name) VALUES (N'Văn'), (N'Thị'), (N'Đình'), (N'Hữu'), (N'Minh'), (N'Quốc'), (N'Thanh'), (N'Gia'), (N'Đức'), (N'Xuân');

DECLARE @Ten TABLE (Id INT IDENTITY(1,1), Name NVARCHAR(20));
INSERT INTO @Ten (Name) VALUES (N'Tuấn'), (N'Dũng'), (N'Hương'), (N'Linh'), (N'Hải'), (N'Nam'), (N'Trang'), (N'Khoa'), (N'Phúc'), (N'Thảo');

DECLARE @Quan TABLE (Id INT IDENTITY(1,1), Name NVARCHAR(50));
INSERT INTO @Quan (Name) VALUES (N'Quận 1, TP.HCM'), (N'Quận 3, TP.HCM'), (N'Quận 5, TP.HCM'), (N'Quận 10, TP.HCM'), (N'Quận Bình Thạnh, TP.HCM'), (N'Quận Tân Bình, TP.HCM'), (N'TP. Thủ Đức, TP.HCM'), (N'Quận Phú Nhuận, TP.HCM');

WHILE @i <= 52
BEGIN
    SET @custCode = 'KH' + RIGHT('000000' + CAST(@i AS VARCHAR(6)), 6);
    SET @phone = '09' + RIGHT('00000000' + CAST(10000000 + @i * 137 AS VARCHAR(8)), 8);
    
    SELECT @fullName = h.Name + ' ' + d.Name + ' ' + t.Name 
    FROM @Ho h, @Dem d, @Ten t 
    WHERE h.Id = ((@i % 10) + 1) AND d.Id = (((@i / 2) % 10) + 1) AND t.Id = (((@i / 3) % 10) + 1);

    SET @email = 'khachhang' + CAST(@i AS VARCHAR(5)) + '@testmail.vn';
    SELECT @address = Name FROM @Quan WHERE Id = ((@i % 8) + 1);

    SET @note = CASE 
        WHEN @i % 7 = 0 THEN N'Khách hàng thân thiết VIP (Giảm 10% tiền công)'
        WHEN @i % 5 = 0 THEN N'Khách hàng công ty / Xuất hóa đơn VAT'
        WHEN @i % 4 = 0 THEN N'Khách hàng yêu cầu kiểm tra kỹ màn hình và pin'
        ELSE N'Khách hàng cá nhân vãng lai'
    END;

    IF NOT EXISTS (SELECT 1 FROM dbo.Customers WHERE CustomerCode = @custCode)
    BEGIN
        INSERT INTO dbo.Customers (CustomerCode, FullName, Phone, Email, Address, Note)
        VALUES (@custCode, @fullName, @phone, @email, @address, @note);
    END

    SET @i = @i + 1;
END;

COMMIT TRANSACTION;
PRINT N'   [OK] Đã nạp xong 50 Khách hàng kiểm thử.';

/* =====================================================================
   2. NẠP 60 THIẾT BỊ KIỂM THỬ (Đa dạng Brand, Model, Serial)
   ===================================================================== */
BEGIN TRANSACTION;

DECLARE @j INT = 3;
DECLARE @targetCustId INT;
DECLARE @devType NVARCHAR(50);
DECLARE @brand VARCHAR(50);
DECLARE @model VARCHAR(100);
DECLARE @serial VARCHAR(100);
DECLARE @devNote NVARCHAR(200);

WHILE @j <= 62
BEGIN
    -- Gán xoay vòng cho các khách hàng từ 1 đến 52
    SET @targetCustId = ((@j % 50) + 1);

    IF @j % 4 = 1
    BEGIN
        SET @devType = N'Laptop';
        SET @brand = 'Dell';
        SET @model = 'Inspiron 15 ' + CAST(3000 + (@j * 17) AS VARCHAR(10));
        SET @serial = 'DELL-SN-' + RIGHT('000000' + CAST(@j * 987 AS VARCHAR(10)), 8);
        SET @devNote = N'Cổng sạc lỏng, màn hình chớp tắt ngắt quãng';
    END
    ELSE IF @j % 4 = 2
    BEGIN
        SET @devType = N'Điện thoại';
        SET @brand = 'Apple';
        SET @model = 'iPhone ' + CAST(11 + (@j % 5) AS VARCHAR(5)) + ' Pro';
        SET @serial = 'APPL-IMEI-' + RIGHT('00000000' + CAST(@j * 87654 AS VARCHAR(12)), 10);
        SET @devNote = N'Pin phồng nhẹ, loa trong rè khi gọi thoại';
    END
    ELSE IF @j % 4 = 3
    BEGIN
        SET @devType = N'Laptop';
        SET @brand = 'Asus';
        SET @model = 'ZenBook UX' + CAST(400 + (@j * 5) AS VARCHAR(10));
        SET @serial = 'ASUS-SN-' + RIGHT('000000' + CAST(@j * 5432 AS VARCHAR(10)), 8);
        SET @devNote = N'Bàn phím liệt hàng phím số, máy chạy chậm';
    END
    ELSE
    BEGIN
        SET @devType = N'Điện thoại';
        SET @brand = 'Samsung';
        SET @model = 'Galaxy S' + CAST(20 + (@j % 4) AS VARCHAR(5));
        SET @serial = 'SS-IMEI-' + RIGHT('00000000' + CAST(@j * 99123 AS VARCHAR(12)), 10);
        SET @devNote = N'Nứt kính lưng sau khi rơi rớt, camera mờ';
    END

    IF NOT EXISTS (SELECT 1 FROM dbo.Devices WHERE SerialNumber = @serial)
    BEGIN
        INSERT INTO dbo.Devices (CustomerId, DeviceType, Brand, Model, SerialNumber, Note)
        VALUES (@targetCustId, @devType, @brand, @model, @serial, @devNote);
    END

    SET @j = @j + 1;
END;

COMMIT TRANSACTION;
PRINT N'   [OK] Đã nạp xong 60 Thiết bị kiểm thử.';

/* =====================================================================
   3. NẠP 100 PHIẾU SỬA CHỮA KIỂM THỬ (PSC2026100001 -> PSC2026100100)
   Bao phủ 7 trạng thái, trường hợp ngoại lệ và phân bổ cho KTV
   ===================================================================== */
BEGIN TRANSACTION;

DECLARE @k INT = 1;
DECLARE @tCode VARCHAR(20);
DECLARE @tCustId INT;
DECLARE @tDevId INT;
DECLARE @tSvId INT;
DECLARE @tStaffId INT;
DECLARE @tTechId INT;
DECLARE @status VARCHAR(20);
DECLARE @cond NVARCHAR(255);
DECLARE @req NVARCHAR(255);
DECLARE @diag NVARCHAR(255);
DECLARE @labor DECIMAL(18,2);
DECLARE @parts DECIMAL(18,2);

-- Lấy danh sách ID nhân sự
DECLARE @staffUser1 INT = (SELECT TOP 1 UserId FROM dbo.Users WHERE RoleId = (SELECT RoleId FROM dbo.Roles WHERE RoleCode='STAFF'));
DECLARE @techUser1 INT  = (SELECT TOP 1 UserId FROM dbo.Users WHERE RoleId = (SELECT RoleId FROM dbo.Roles WHERE RoleCode='TECHNICIAN'));
IF @staffUser1 IS NULL SET @staffUser1 = 2;
IF @techUser1 IS NULL SET @techUser1 = 3;

WHILE @k <= 100
BEGIN
    SET @tCode = 'PSC202610' + RIGHT('0000' + CAST(@k AS VARCHAR(4)), 4);
    SET @tCustId = ((@k % 50) + 1);
    SET @tDevId = ((@k % 60) + 1);
    SET @tSvId = ((@k % 8) + 1); -- 8 dịch vụ DV001 -> DV008
    SET @tStaffId = @staffUser1;
    SET @tTechId = @techUser1;

    -- Phân bổ trạng thái theo tỷ lệ thực tế
    SET @status = CASE 
        WHEN @k % 10 = 1 THEN 'RECEIVED'
        WHEN @k % 10 = 2 THEN 'DIAGNOSING'
        WHEN @k % 10 IN (3, 4) THEN 'IN_REPAIR'
        WHEN @k % 10 = 5 THEN 'COMPLETED'
        WHEN @k % 10 IN (6, 7, 8) THEN 'PAID'
        WHEN @k % 10 = 9 THEN 'DELIVERED'
        ELSE 'CANCELLED' -- Trường hợp ngoại lệ khách không sửa
    END;

    -- Đơn giá tiền công theo dịch vụ
    SET @labor = CASE @tSvId
        WHEN 1 THEN 150000.00
        WHEN 2 THEN 100000.00
        WHEN 3 THEN 120000.00
        WHEN 4 THEN 80000.00
        WHEN 5 THEN 350000.00
        WHEN 6 THEN 100000.00
        WHEN 7 THEN 180000.00
        ELSE 130000.00
    END;

    SET @parts = CASE 
        WHEN @status IN ('IN_REPAIR', 'COMPLETED', 'PAID', 'DELIVERED') THEN 450000.00
        ELSE 0.00
    END;

    SET @cond = CASE 
        WHEN @k % 5 = 0 THEN N'Máy mất nguồn hoàn toàn, sạc không báo tín hiệu'
        WHEN @k % 5 = 1 THEN N'Màn hình sọc chỉ đứng, cảm ứng loạn'
        WHEN @k % 5 = 2 THEN N'Pin tụt nhanh 100% về 10% trong 30 phút'
        WHEN @k % 5 = 3 THEN N'Quạt kêu to, CPU nóng 95 độ C, tắt đột ngột'
        ELSE N'Máy vào nước nhẹ, bàn phím gõ nhảy ký tự'
    END;

    SET @req = N'Yêu cầu kiểm tra xử lý dứt điểm tình trạng lỗi; cần gấp trong ngày';
    
    SET @diag = CASE 
        WHEN @status = 'RECEIVED' THEN N'Đang chờ Kỹ thuật viên tiếp nhận kiểm tra chuyên sâu'
        WHEN @status = 'CANCELLED' THEN N'Mainboard bị oxy hóa nặng, chi phí sửa vượt giá trị máy -> Khách quyết định không sửa'
        ELSE N'Đã xác định linh kiện hỏng, báo giá khách hàng đồng ý tiến hành thay thế'
    END;

    IF NOT EXISTS (SELECT 1 FROM dbo.RepairTickets WHERE TicketCode = @tCode)
    BEGIN
        INSERT INTO dbo.RepairTickets (
            TicketCode, CustomerId, DeviceId, ServiceTypeId,
            ReceivedByUserId, TechnicianUserId, Status,
            DeviceCondition, CustomerRequest, Diagnosis,
            QuotedLaborCost, QuotedPartsCost, CreatedAt
        )
        VALUES (
            @tCode, @tCustId, @tDevId, @tSvId,
            @tStaffId, @tTechId, @status,
            @cond, @req, @diag,
            @labor, @parts, DATEADD(DAY, -(@k % 25), GETUTCDATE())
        );
    END

    SET @k = @k + 1;
END;

COMMIT TRANSACTION;
PRINT N'   [OK] Đã nạp xong 100 Phiếu sửa chữa kiểm thử.';

/* =====================================================================
   4. TỔNG KẾT VÀ KIỂM TRA TÍNH TOÀN VẸN DỮ LIỆU KIỂM THỬ
   ===================================================================== */
SELECT 
    'Tong so Khach hang' AS ChiMuc, COUNT(*) AS SoLuong FROM dbo.Customers
UNION ALL
SELECT 
    'Tong so Thiet bi' AS ChiMuc, COUNT(*) AS SoLuong FROM dbo.Devices
UNION ALL
SELECT 
    'Tong so Phieu sua chua' AS ChiMuc, COUNT(*) AS SoLuong FROM dbo.RepairTickets;

SELECT Status AS TrangThai, COUNT(*) AS SoLuongPhieu
FROM dbo.RepairTickets
GROUP BY Status
ORDER BY SoLuongPhieu DESC;

PRINT N'--> [THÀNH CÔNG] Hoàn tất nạp bộ dữ liệu kiểm thử tổng thể 100 phiếu (MBA-75)!';
GO
