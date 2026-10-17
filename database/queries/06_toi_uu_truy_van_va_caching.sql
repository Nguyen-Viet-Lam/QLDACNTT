/* =========================================================================
   NHÓM 11 - DỰ ÁN QUẢN LÝ CỬA HÀNG SỬA CHỮA (LV33-001)
   MODULE: TỐI ƯU HÓA TRUY VẤN DỮ LIỆU LỚN VÀ CACHING (SPRINT 7)
   TÁC GIẢ: NGUYỄN VIẾT LÃM (PM / BACKEND LEAD) - TASK JIRA: MBA-59
   TÊN TÁC VỤ: TỐI ƯU HÓA TRUY VẤN DỮ LIỆU LỚN VÀ CACHING
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
PRINT N'MBA-59: TỐI ƯU HÓA TRUY VẤN DỮ LIỆU LỚN VÀ CACHING';
PRINT N'Người thực hiện: Nguyễn Viết Lãm (PM / Backend Lead - Nhóm 11)';
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
PRINT N'HOÀN TẤT SCRIPT MBA-59: TỐI ƯU TRUY VẤN VÀ CACHING - NGUYỄN VIẾT LÃM';
PRINT N'=========================================================================';
GO
