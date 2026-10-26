/* =========================================================================
   NHÓM 11 - DỰ ÁN QUẢN LÝ CỬA HÀNG SỬA CHỮA (LV33-001)
   MODULE: BÁO CÁO THỐNG KÊ LINH KIỆN BÁN CHẠY VÀ TỒN LÂU (SPRINT 7)
   TÁC GIẢ: TRẦN NGỌC LỢI (BA / DATABASE LEAD) - TASK JIRA: MBA-74
   TÊN TÁC VỤ: BÁO CÁO THỐNG KÊ LINH KIỆN BÁN CHẠY VÀ TỒN LÂU
   CSDL: SQL Server 2022 | Database: RepairShopDB
   ========================================================================= */

IF DB_ID('RepairShopDB') IS NOT NULL
    USE RepairShopDB;
ELSE IF DB_ID('QLDACNTT_CuaHangSuaChua') IS NOT NULL
    USE QLDACNTT_CuaHangSuaChua;
GO

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

PRINT N'=========================================================================';
PRINT N'MBA-74: BÁO CÁO THỐNG KÊ LINH KIỆN BÁN CHẠY VÀ TỒN LÂU';
PRINT N'Người thực hiện: Trần Ngọc Lợi (Database Lead - Nhóm 11)';
PRINT N'=========================================================================';
GO

-- =========================================================================
-- PHẦN 1: VIEW LINH KIỆN BÁN CHẠY NHẤT (HOT-SELLING PARTS)
-- Mục đích: Xác định top linh kiện tiêu thụ nhiều nhất để tối ưu dự trữ,
--           tăng biên lợi nhuận và sắp xếp kệ hàng ưu tiên.
-- =========================================================================
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
PRINT N'>> [ĐÃ TẠO]: View dbo.v_LinhKienBanChay';
GO

-- =========================================================================
-- PHẦN 2: VIEW LINH KIỆN TỒN LÂU (SLOW-MOVING / DEAD STOCK)
-- Mục đích: Xác định linh kiện bị tồn kho lâu ngày không bán được,
--           đề xuất biện pháp: giảm giá, thanh lý hoặc điều phối sang kho khác.
-- =========================================================================
CREATE OR ALTER VIEW dbo.v_LinhKienTonLau
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
PRINT N'>> [ĐÃ TẠO]: View dbo.v_LinhKienTonLau';
GO

-- =========================================================================
-- PHẦN 3: STORED PROCEDURE TOÀN DIỆN - BÁO CÁO THỐNG KÊ LINH KIỆN
-- =========================================================================
CREATE OR ALTER PROCEDURE dbo.sp_BaoCaoThongKeLinhKien
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
PRINT N'>> [ĐÃ TẠO]: sp_BaoCaoThongKeLinhKien';
GO

-- =========================================================================
-- PHẦN 4: KỊCH BẢN KIỂM THỬ
-- =========================================================================
PRINT N'-------------------------------------------------------------------------';
PRINT N'DEMO 1: Top 10 linh kiện bán chạy nhất';
PRINT N'-------------------------------------------------------------------------';
EXEC dbo.sp_BaoCaoThongKeLinhKien @LoaiBaoCao = 'BAN_CHAY', @TopN = 10;
GO

PRINT N'-------------------------------------------------------------------------';
PRINT N'DEMO 2: Linh kiện tồn lâu trên 30 ngày';
PRINT N'-------------------------------------------------------------------------';
EXEC dbo.sp_BaoCaoThongKeLinhKien @LoaiBaoCao = 'TON_LAU', @SoNgayTonToiThieu = 30;
GO

PRINT N'-------------------------------------------------------------------------';
PRINT N'DEMO 3: Tổng hợp phân loại ABC';
PRINT N'-------------------------------------------------------------------------';
EXEC dbo.sp_BaoCaoThongKeLinhKien @LoaiBaoCao = 'TONG_HOP';
GO

PRINT N'-------------------------------------------------------------------------';
PRINT N'DEMO 4: View trực tiếp từ v_LinhKienBanChay';
PRINT N'-------------------------------------------------------------------------';
SELECT TOP 20 * FROM dbo.v_LinhKienBanChay ORDER BY TongSoLuongBan DESC;
GO

PRINT N'-------------------------------------------------------------------------';
PRINT N'DEMO 5: View trực tiếp từ v_LinhKienTonLau';
PRINT N'-------------------------------------------------------------------------';
SELECT * FROM dbo.v_LinhKienTonLau ORDER BY SoNgayKhongCoGiaoDich DESC;
GO

PRINT N'=========================================================================';
PRINT N'HOÀN TẤT SCRIPT MBA-74: THỐNG KÊ LINH KIỆN BÁN CHẠY & TỒN LÂU - TRẦN NGỌC LỢI';
PRINT N'=========================================================================';
GO
