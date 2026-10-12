/* =========================================================================
   NHÓM 11 - DỰ ÁN QUẢN LÝ CỬA HÀNG SỬA CHỮA (LV33-001)
   MODULE: BÁO CÁO THỐNG KÊ & DOANH THU (SPRINT 6 / SPRINT 7)
   TÁC GIẢ: TRẦN NGỌC LỢI (BA / DATABASE LEAD) - TASK JIRA: MBA-73
   TÊN TÁC VỤ: XÂY DỰNG BÁO CÁO DOANH THU THEO THỢ VÀ DỊCH VỤ
   CSDL: SQL Server 2022 | Database: RepairShopDB / QLDACNTT_CuaHangSuaChua
   ========================================================================= */

-- 0. CẤU HÌNH KẾT NỐI DATABASE VÀ THIẾT LẬP MÔI TRƯỜNG
IF DB_ID('RepairShopDB') IS NOT NULL
    USE RepairShopDB;
ELSE IF DB_ID('QLDACNTT_CuaHangSuaChua') IS NOT NULL
    USE QLDACNTT_CuaHangSuaChua;
GO

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

PRINT N'=========================================================================';
PRINT N'ĐANG KHỞI TẠO BỘ TRUY VẤN VÀ STORED PROCEDURE CHO TASK MBA-73...';
PRINT N'Người thực hiện: Trần Ngọc Lợi (Database Lead - Nhóm 11 - 23DTHC6)';
PRINT N'=========================================================================';
GO

-- =========================================================================
-- PHẦN 1: VIEW TỔNG HỢP DOANH THU VÀ HIỆU SUẤT THEO THỢ (KỸ THUẬT VIÊN)
-- Mục đích: Đánh giá tổng tiền công, tiền linh kiện và tổng doanh thu thực tế
--           do từng kỹ thuật viên mang về (chỉ tính hóa đơn đã thanh toán - PAID).
-- =========================================================================
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

PRINT N'>> [ĐÃ TẠO]: View dbo.v_BaoCaoDoanhThuTheoTho';
GO

-- =========================================================================
-- PHẦN 2: VIEW TỔNG HỢP DOANH THU THEO LOẠI DỊCH VỤ SỬA CHỮA
-- Mục đích: Xác định dịch vụ sửa chữa chủ lực, mang lại doanh thu cao nhất,
--           tỷ lệ linh kiện kèm theo và tỷ trọng đóng góp doanh thu của từng dịch vụ.
-- =========================================================================
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

PRINT N'>> [ĐÃ TẠO]: View dbo.v_BaoCaoDoanhThuTheoDichVu';
GO

-- =========================================================================
-- PHẦN 3: BÁO CÁO DOANH THU MA TRẬN KẾT HỢP (THỢ x DỊCH VỤ)
-- Mục đích: Phân tích thợ nào chuyên về mảng dịch vụ nào (Ví dụ: Thợ A chuyên
--           thay màn hình/pin, Thợ B chuyên sửa nguồn/mainboard).
-- =========================================================================
CREATE OR ALTER VIEW dbo.v_BaoCaoMaTranThoVaDichVu
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

PRINT N'>> [ĐÃ TẠO]: View dbo.v_BaoCaoMaTranThoVaDichVu';
GO

-- =========================================================================
-- PHẦN 4: BÁO CÁO HOA HỒNG & LƯƠNG HIỆU QUẢ CỦA KỸ THUẬT VIÊN (KPI COMMISSION)
-- Cơ chế cửa hàng:
--  - Hoa hồng tiền công: 20% doanh thu tiền công (LaborCost) của các phiếu đã thu tiền.
--  - Hoa hồng linh kiện: 5% doanh thu linh kiện bán ra theo phiếu.
--  - Trừ phạt bảo hành lại: Phạt 50.000 VNĐ cho mỗi phiếu phải làm bảo hành lại do lỗi kỹ thuật.
-- =========================================================================
CREATE OR ALTER VIEW dbo.v_BaoCaoHoaHongKyThuatVien
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

PRINT N'>> [ĐÃ TẠO]: View dbo.v_BaoCaoHoaHongKyThuatVien';
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
CREATE OR ALTER PROCEDURE dbo.sp_BaoCaoDoanhThuTheoThoVaDichVu
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

PRINT N'>> [ĐÃ TẠO]: Stored Procedure dbo.sp_BaoCaoDoanhThuTheoThoVaDichVu';
GO

-- =========================================================================
-- PHẦN 6: DỮ LIỆU BỔ SUNG ĐẢM BẢO TEST CHẠY RA KẾT QUẢ TRỰC QUAN ĐẦY ĐỦ
-- Tự động kiểm tra nếu chưa có đủ hóa đơn PAID trong CSDL thì nạp dữ liệu mẫu
-- để thầy cô và nhóm chạy F5 thấy ngay bảng số liệu sinh động.
-- =========================================================================
IF NOT EXISTS (SELECT 1 FROM dbo.Invoices WHERE PaymentStatus = 'PAID')
BEGIN
    PRINT N'>> Đang nạp thêm dữ liệu hóa đơn demo PAID để kiểm thử báo cáo...';

    -- Lấy ID thợ và dịch vụ mẫu
    DECLARE @techId1 INT = (SELECT TOP 1 UserId FROM dbo.Users WHERE RoleId = (SELECT RoleId FROM dbo.Roles WHERE RoleCode='TECHNICIAN') ORDER BY UserId ASC);
    DECLARE @techId2 INT = (SELECT TOP 1 UserId FROM dbo.Users WHERE RoleId = (SELECT RoleId FROM dbo.Roles WHERE RoleCode='TECHNICIAN') ORDER BY UserId DESC);
    DECLARE @staffId INT = (SELECT TOP 1 UserId FROM dbo.Users WHERE RoleId = (SELECT RoleId FROM dbo.Roles WHERE RoleCode='STAFF'));
    DECLARE @custId1 INT = (SELECT TOP 1 CustomerId FROM dbo.Customers ORDER BY CustomerId ASC);
    DECLARE @devId1  INT = (SELECT TOP 1 DeviceId FROM dbo.Devices ORDER BY DeviceId ASC);
    DECLARE @sv1     INT = (SELECT TOP 1 ServiceTypeId FROM dbo.ServiceTypes WHERE ServiceCode='DV001');
    DECLARE @sv2     INT = (SELECT TOP 1 ServiceTypeId FROM dbo.ServiceTypes WHERE ServiceCode='DV002');
    DECLARE @sv3     INT = (SELECT TOP 1 ServiceTypeId FROM dbo.ServiceTypes WHERE ServiceCode='DV003');

    IF @techId1 IS NOT NULL AND @staffId IS NOT NULL AND @custId1 IS NOT NULL
    BEGIN
        -- Thêm phiếu demo 03 (Đã hoàn thành & có hóa đơn thanh toán)
        IF NOT EXISTS (SELECT 1 FROM dbo.RepairTickets WHERE TicketCode='PSC2026100003')
        BEGIN
            INSERT INTO dbo.RepairTickets (TicketCode, CustomerId, DeviceId, ServiceTypeId, ReceivedByUserId, TechnicianUserId, Status, DeviceCondition, CustomerRequest, Diagnosis, QuotedLaborCost, QuotedPartsCost, CompletedAt, DeliveredAt)
            VALUES ('PSC2026100003', @custId1, @devId1, @sv1, @staffId, @techId1, 'DELIVERED', N'Vỡ kính màn hình', N'Thay màn hình iPhone', N'Màn hình sọc méo hình', 150000, 1200000, DATEADD(DAY, -5, SYSDATETIME()), DATEADD(DAY, -4, SYSDATETIME()));
        END

        -- Thêm phiếu demo 04 (Đã hoàn thành & có hóa đơn thanh toán)
        IF NOT EXISTS (SELECT 1 FROM dbo.RepairTickets WHERE TicketCode='PSC2026100004')
        BEGIN
            INSERT INTO dbo.RepairTickets (TicketCode, CustomerId, DeviceId, ServiceTypeId, ReceivedByUserId, TechnicianUserId, Status, DeviceCondition, CustomerRequest, Diagnosis, QuotedLaborCost, QuotedPartsCost, CompletedAt, DeliveredAt)
            VALUES ('PSC2026100004', @custId1, @devId1, @sv3, @staffId, @techId2, 'DELIVERED', N'Máy nóng', N'Vệ sinh tra keo tản nhiệt', N'Bụi nhiều khô keo', 120000, 100000, DATEADD(DAY, -2, SYSDATETIME()), DATEADD(DAY, -1, SYSDATETIME()));
        END

        -- Thêm hóa đơn cho phiếu 03 (PAID)
        DECLARE @tkId3 INT = (SELECT TicketId FROM dbo.RepairTickets WHERE TicketCode='PSC2026100003');
        IF @tkId3 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.Invoices WHERE TicketId=@tkId3)
        BEGIN
            INSERT INTO dbo.Invoices (InvoiceCode, TicketId, CustomerId, LaborCost, PartsCost, DiscountAmount, PaymentMethod, PaymentStatus, PaidAt, CreatedByUserId, CreatedAt)
            VALUES ('HD2026100001', @tkId3, @custId1, 150000, 1200000, 50000, 'TRANSFER', 'PAID', DATEADD(DAY, -4, SYSDATETIME()), @staffId, DATEADD(DAY, -4, SYSDATETIME()));
        END

        -- Thêm hóa đơn cho phiếu 04 (PAID)
        DECLARE @tkId4 INT = (SELECT TicketId FROM dbo.RepairTickets WHERE TicketCode='PSC2026100004');
        IF @tkId4 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.Invoices WHERE TicketId=@tkId4)
        BEGIN
            INSERT INTO dbo.Invoices (InvoiceCode, TicketId, CustomerId, LaborCost, PartsCost, DiscountAmount, PaymentMethod, PaymentStatus, PaidAt, CreatedByUserId, CreatedAt)
            VALUES ('HD2026100002', @tkId4, @custId1, 120000, 100000, 0, 'CASH', 'PAID', DATEADD(DAY, -1, SYSDATETIME()), @staffId, DATEADD(DAY, -1, SYSDATETIME()));
        END

        PRINT N'>> Đã nạp thành công dữ liệu hóa đơn mẫu phục vụ test báo cáo!';
    END
END
GO

-- =========================================================================
-- PHẦN 7: KỊCH BẢN KIỂM THỬ TRỰC TIẾP (TEST RUN DEMO QUERIES)
-- Trần Ngọc Lợi và nhóm có thể bôi đen từng câu dưới đây trong SSMS để chạy thử:
-- =========================================================================

PRINT N'-------------------------------------------------------------------------';
PRINT N'DEMO 1: BÁO CÁO TỔNG QUAN DOANH THU THEO THỢ (VIEW)';
PRINT N'-------------------------------------------------------------------------';
SELECT * FROM dbo.v_BaoCaoDoanhThuTheoTho ORDER BY TongDoanhThuThucThu DESC;
GO

PRINT N'-------------------------------------------------------------------------';
PRINT N'DEMO 2: BÁO CÁO DOANH THU THEO LOẠI DỊCH VỤ SỬA CHỮA (VIEW)';
PRINT N'-------------------------------------------------------------------------';
SELECT * FROM dbo.v_BaoCaoDoanhThuTheoDichVu ORDER BY TongDoanhThuDichVu DESC;
GO

PRINT N'-------------------------------------------------------------------------';
PRINT N'DEMO 3: MA TRẬN KẾT HỢP DOANH THU (THỢ x DỊCH VỤ)';
PRINT N'-------------------------------------------------------------------------';
SELECT * FROM dbo.v_BaoCaoMaTranThoVaDichVu WHERE SoLuongPhieuThucHien > 0 ORDER BY TenKyThuatVien, TongDoanhThu DESC;
GO

PRINT N'-------------------------------------------------------------------------';
PRINT N'DEMO 4: BÁO CÁO TÍNH HOA HỒNG / THƯỞNG KPI KỸ THUẬT VIÊN';
PRINT N'-------------------------------------------------------------------------';
SELECT * FROM dbo.v_BaoCaoHoaHongKyThuatVien ORDER BY TongHoaHongThucNhan DESC;
GO

PRINT N'-------------------------------------------------------------------------';
PRINT N'DEMO 5: CHẠY STORED PROCEDURE VỚI CÁC BỘ THAM SỐ KHÁC NHAU';
PRINT N'-------------------------------------------------------------------------';
-- Test 5.1: Báo cáo theo thợ trong 30 ngày gần nhất
EXEC dbo.sp_BaoCaoDoanhThuTheoThoVaDichVu @LoaiBaoCao = 'THEO_THO';

-- Test 5.2: Báo cáo theo loại dịch vụ
EXEC dbo.sp_BaoCaoDoanhThuTheoThoVaDichVu @LoaiBaoCao = 'THEO_DICH_VU';

-- Test 5.3: Báo cáo ma trận chéo (Thợ x Dịch vụ)
EXEC dbo.sp_BaoCaoDoanhThuTheoThoVaDichVu @LoaiBaoCao = 'MA_TRAN_CHEO';

-- Test 5.4: Báo cáo hoa hồng cho thợ
EXEC dbo.sp_BaoCaoDoanhThuTheoThoVaDichVu @LoaiBaoCao = 'HOA_HONG';
GO

PRINT N'=========================================================================';
PRINT N'HOÀN TẤT THÀNH CÔNG SCRIPT TASK MBA-73 BỞI TRẦN NGỌC LỢI!';
PRINT N'=========================================================================';
