/* =========================================================================
   NHÓM 11 - DỰ ÁN QUẢN LÝ CỬA HÀNG SỬA CHỮA (LV33-001)
   MODULE: ĐO LƯỜNG VÀ TỐI ƯU HIỆU NĂNG TRUY VẤN SQL SERVER
   TÁC GIẢ: NGUYỄN VIỆT LAM (PM / DEV LEAD) - TASK JIRA: MBA-79
   TÊN TÁC VỤ: ĐO LƯỜNG VÀ TỐI ƯU HIỆU NĂNG TRUY VẤN SQL SERVER
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
    mig.index_group_id,
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
