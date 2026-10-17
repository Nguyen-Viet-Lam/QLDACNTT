/* =========================================================================
   NHÓM 11 - DỰ ÁN QUẢN LÝ CỬA HÀNG SỬA CHỮA (LV33-001)
   MODULE: LỌC VÀ TRUY VẾT LỊCH SỬ XUẤT NHẬP LINH KIỆN (SPRINT 6/7)
   TÁC GIẢ: TRẦN NGỌC LỢI (BA / DATABASE LEAD) - TASK JIRA: MBA-65
   TÊN TÁC VỤ: LỌC VÀ TRUY VẾT LỊCH SỬ XUẤT NHẬP LINH KIỆN
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
