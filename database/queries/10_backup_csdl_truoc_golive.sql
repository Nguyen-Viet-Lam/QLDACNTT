-- ============================================================
-- MBA-85: SAO LƯU DỰ PHÒNG CƠ SỞ DỮ LIỆU TRƯỚC KHI GO-LIVE
-- Dự án  : Hệ thống quản lý tổng thể cửa hàng sửa chữa - LV33-001
-- Nhóm   : Nhóm 11 – Lớp 23DTHC6
-- Thành viên: Nguyễn Việt Lam, Trần Ngọc Lợi, Nguyễn Đại Kỳ
-- Ngày tạo  : 2026-10-23
-- Mô tả     : Script thực hiện Full Backup, Differential Backup,
--              Transaction Log Backup và kiểm tra tính toàn vẹn
--              của CSDL QLDACNTT trước khi chính thức Go-Live.
-- ============================================================

USE master;
GO

-- ============================================================
-- PHẦN 1: KIỂM TRA TRẠNG THÁI CSDL TRƯỚC KHI BACKUP
-- ============================================================

PRINT '=== KIỂM TRA TRẠNG THÁI CƠ SỞ DỮ LIỆU ===';
PRINT 'Thời gian bắt đầu: ' + CONVERT(VARCHAR, GETDATE(), 120);

-- Kiểm tra trạng thái database
SELECT 
    name                    AS TenCSDL,
    state_desc              AS TrangThai,
    recovery_model_desc     AS MoHinhPhucHoi,
    log_reuse_wait_desc     AS TrangThaiLog,
    is_auto_shrink_on       AS TuDongThuNho,
    compatibility_level     AS MucTuongThich,
    create_date             AS NgayTao
FROM sys.databases
WHERE name = 'QLDACNTT';
GO

-- Kiểm tra kích thước file CSDL
PRINT '=== THÔNG TIN KÍCH THƯỚC FILE ===';
SELECT 
    DB_NAME(database_id)                        AS TenCSDL,
    name                                        AS TenFile,
    type_desc                                   AS LoaiFile,
    ROUND(size * 8.0 / 1024, 2)                AS KichThuocMB,
    ROUND(FILEPROPERTY(name, 'SpaceUsed') * 8.0 / 1024, 2) AS DungLuongDaDungMB,
    physical_name                               AS DuongDanVatLy
FROM sys.master_files
WHERE database_id = DB_ID('QLDACNTT');
GO

-- ============================================================
-- PHẦN 2: KIỂM TRA TÍNH TOÀN VẸN DỮ LIỆU TRƯỚC BACKUP
-- ============================================================

PRINT '=== KIỂM TRA TÍNH TOÀN VẸN CSDL (DBCC CHECKDB) ===';

USE QLDACNTT;
GO

DBCC CHECKDB ('QLDACNTT') WITH NO_INFOMSGS, ALL_ERRORMSGS;
GO

PRINT '=== KIỂM TRA HOÀN TẤT ===';
GO

-- ============================================================
-- PHẦN 3: THỐNG KÊ SỐ LIỆU TRƯỚC BACKUP
-- ============================================================

USE QLDACNTT;
GO

PRINT '=== THỐNG KÊ SỐ LƯỢNG BẢN GHI TRƯỚC BACKUP ===';

SELECT 'KhachHang'       AS BangDuLieu, COUNT(*) AS SoBanGhi FROM KhachHang
UNION ALL
SELECT 'NhanVien',                      COUNT(*) FROM NhanVien
UNION ALL
SELECT 'ThietBi',                       COUNT(*) FROM ThietBi
UNION ALL
SELECT 'PhieuSuaChua',                  COUNT(*) FROM PhieuSuaChua
UNION ALL
SELECT 'ChiTietPhieuSuaChua',           COUNT(*) FROM ChiTietPhieuSuaChua
UNION ALL
SELECT 'LinhKien',                      COUNT(*) FROM LinhKien
UNION ALL
SELECT 'KhoLinhKien',                   COUNT(*) FROM KhoLinhKien
UNION ALL
SELECT 'HoaDon',                        COUNT(*) FROM HoaDon;
GO

-- ============================================================
-- PHẦN 4: CẤU HÌNH ĐƯỜNG DẪN VÀ THAM SỐ BACKUP
-- ============================================================

USE master;
GO

-- *** THAY ĐỔI đường dẫn phù hợp với môi trường thực tế ***
DECLARE @BackupFolder       NVARCHAR(500) = N'D:\Backup\QLDACNTT\';
DECLARE @DatabaseName       NVARCHAR(100) = N'QLDACNTT';
DECLARE @DateStamp          NVARCHAR(20)  = CONVERT(NVARCHAR(20), GETDATE(), 112);   -- yyyymmdd
DECLARE @TimeStamp          NVARCHAR(20)  = REPLACE(CONVERT(NVARCHAR(8), GETDATE(), 108), ':', ''); -- hhmmss

-- Tên file backup
DECLARE @FullBackupFile     NVARCHAR(600) = @BackupFolder + @DatabaseName + '_FULL_'   + @DateStamp + '_' + @TimeStamp + '.bak';
DECLARE @DiffBackupFile     NVARCHAR(600) = @BackupFolder + @DatabaseName + '_DIFF_'   + @DateStamp + '_' + @TimeStamp + '.bak';
DECLARE @LogBackupFile      NVARCHAR(600) = @BackupFolder + @DatabaseName + '_LOG_'    + @DateStamp + '_' + @TimeStamp + '.trn';

-- ============================================================
-- PHẦN 5: THỰC HIỆN FULL BACKUP
-- ============================================================

PRINT '=== BẮT ĐẦU FULL BACKUP ===';
PRINT 'File đích: ' + @FullBackupFile;

BACKUP DATABASE @DatabaseName
TO DISK = @FullBackupFile
WITH 
    FORMAT,                             -- Ghi đè media cũ
    INIT,                               -- Tạo backup set mới
    NAME = N'QLDACNTT - Full Backup trước Go-Live',
    DESCRIPTION = N'Full Backup thực hiện ngày ' + @DateStamp + ' trước khi chính thức Go-Live. Nhóm 11 - LV33-001.',
    COMPRESSION,                        -- Nén dữ liệu để tiết kiệm dung lượng
    CHECKSUM,                           -- Tính checksum để kiểm tra toàn vẹn
    STATS = 10;                         -- Hiển thị tiến trình mỗi 10%

PRINT '=== FULL BACKUP HOÀN TẤT ===';
GO

-- ============================================================
-- PHẦN 6: THỰC HIỆN DIFFERENTIAL BACKUP
-- (Chạy sau Full Backup để lưu các thay đổi bổ sung nếu cần)
-- ============================================================

DECLARE @BackupFolder   NVARCHAR(500) = N'D:\Backup\QLDACNTT\';
DECLARE @DatabaseName   NVARCHAR(100) = N'QLDACNTT';
DECLARE @DateStamp      NVARCHAR(20)  = CONVERT(NVARCHAR(20), GETDATE(), 112);
DECLARE @TimeStamp      NVARCHAR(20)  = REPLACE(CONVERT(NVARCHAR(8), GETDATE(), 108), ':', '');
DECLARE @DiffBackupFile NVARCHAR(600) = @BackupFolder + @DatabaseName + '_DIFF_' + @DateStamp + '_' + @TimeStamp + '.bak';

PRINT '=== BẮT ĐẦU DIFFERENTIAL BACKUP ===';
PRINT 'File đích: ' + @DiffBackupFile;

BACKUP DATABASE @DatabaseName
TO DISK = @DiffBackupFile
WITH 
    DIFFERENTIAL,
    NAME = N'QLDACNTT - Differential Backup trước Go-Live',
    DESCRIPTION = N'Differential Backup bổ sung trước Go-Live. Nhóm 11 - LV33-001.',
    COMPRESSION,
    CHECKSUM,
    STATS = 10;

PRINT '=== DIFFERENTIAL BACKUP HOÀN TẤT ===';
GO

-- ============================================================
-- PHẦN 7: THỰC HIỆN TRANSACTION LOG BACKUP
-- (Yêu cầu Recovery Model = FULL hoặc BULK_LOGGED)
-- ============================================================

DECLARE @BackupFolder   NVARCHAR(500) = N'D:\Backup\QLDACNTT\';
DECLARE @DatabaseName   NVARCHAR(100) = N'QLDACNTT';
DECLARE @DateStamp      NVARCHAR(20)  = CONVERT(NVARCHAR(20), GETDATE(), 112);
DECLARE @TimeStamp      NVARCHAR(20)  = REPLACE(CONVERT(NVARCHAR(8), GETDATE(), 108), ':', '');
DECLARE @LogBackupFile  NVARCHAR(600) = @BackupFolder + @DatabaseName + '_LOG_' + @DateStamp + '_' + @TimeStamp + '.trn';

PRINT '=== BẮT ĐẦU TRANSACTION LOG BACKUP ===';
PRINT 'File đích: ' + @LogBackupFile;

BACKUP LOG @DatabaseName
TO DISK = @LogBackupFile
WITH 
    NAME = N'QLDACNTT - Transaction Log Backup trước Go-Live',
    DESCRIPTION = N'Log Backup trước Go-Live. Nhóm 11 - LV33-001.',
    COMPRESSION,
    CHECKSUM,
    STATS = 10;

PRINT '=== LOG BACKUP HOÀN TẤT ===';
GO

-- ============================================================
-- PHẦN 8: XÁC MINH BACKUP SAU KHI THỰC HIỆN
-- ============================================================

USE master;
GO

PRINT '=== DANH SÁCH BACKUP GẦN NHẤT CỦA QLDACNTT ===';

SELECT TOP 10
    bs.backup_set_id                                        AS BackupSetID,
    bs.database_name                                        AS TenCSDL,
    CASE bs.type
        WHEN 'D' THEN 'Full Backup'
        WHEN 'I' THEN 'Differential Backup'
        WHEN 'L' THEN 'Log Backup'
        ELSE 'Khác'
    END                                                     AS LoaiBackup,
    bs.backup_start_date                                    AS ThoiGianBatDau,
    bs.backup_finish_date                                   AS ThoiGianKetThuc,
    DATEDIFF(SECOND, bs.backup_start_date, bs.backup_finish_date) AS ThoiGianThucHienGiay,
    ROUND(bs.backup_size / 1048576.0, 2)                   AS KichThuocGoc_MB,
    ROUND(bs.compressed_backup_size / 1048576.0, 2)        AS KichThuocNen_MB,
    ROUND(100.0 - (bs.compressed_backup_size * 100.0 / bs.backup_size), 1) AS TiLeNenPhanTram,
    bmf.physical_device_name                               AS DuongDanFile
FROM msdb.dbo.backupset bs
JOIN msdb.dbo.backupmediafamily bmf 
    ON bs.media_set_id = bmf.media_set_id
WHERE bs.database_name = 'QLDACNTT'
ORDER BY bs.backup_start_date DESC;
GO

-- ============================================================
-- PHẦN 9: VERIFY BACKUP (Kiểm tra tính hợp lệ của file backup)
-- ============================================================

-- *** Cập nhật đường dẫn file backup cụ thể để verify ***
DECLARE @BackupFileToVerify NVARCHAR(600) = N'D:\Backup\QLDACNTT\QLDACNTT_FULL_20261023_100000.bak';

PRINT '=== XÁC MINH TÍNH TOÀN VẸN FILE BACKUP ===';
PRINT 'File cần xác minh: ' + @BackupFileToVerify;

RESTORE VERIFYONLY
FROM DISK = @BackupFileToVerify
WITH CHECKSUM;

PRINT '=== XÁC MINH HOÀN TẤT ===';
GO

-- ============================================================
-- PHẦN 10: STORED PROCEDURE TỰ ĐỘNG HÓA BACKUP ĐỊNH KỲ
-- ============================================================

USE master;
GO

IF OBJECT_ID('dbo.sp_BackupQldacntt', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_BackupQldacntt;
GO

CREATE PROCEDURE dbo.sp_BackupQldacntt
    @BackupType     NVARCHAR(10)  = 'FULL',         -- 'FULL', 'DIFF', 'LOG'
    @BackupFolder   NVARCHAR(500) = N'D:\Backup\QLDACNTT\'
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @DatabaseName   NVARCHAR(100) = N'QLDACNTT';
    DECLARE @DateStamp      NVARCHAR(20)  = CONVERT(NVARCHAR(20), GETDATE(), 112);
    DECLARE @TimeStamp      NVARCHAR(20)  = REPLACE(CONVERT(NVARCHAR(8), GETDATE(), 108), ':', '');
    DECLARE @BackupFile     NVARCHAR(600);
    DECLARE @BackupName     NVARCHAR(200);
    DECLARE @SQL            NVARCHAR(MAX);

    IF @BackupType = 'FULL'
    BEGIN
        SET @BackupFile = @BackupFolder + @DatabaseName + '_FULL_' + @DateStamp + '_' + @TimeStamp + '.bak';
        SET @BackupName = N'QLDACNTT - Full Backup tự động';
        SET @SQL = N'
            BACKUP DATABASE [' + @DatabaseName + N']
            TO DISK = N''' + @BackupFile + N'''
            WITH FORMAT, INIT, NAME = N''' + @BackupName + N''',
                 COMPRESSION, CHECKSUM, STATS = 10;';
    END
    ELSE IF @BackupType = 'DIFF'
    BEGIN
        SET @BackupFile = @BackupFolder + @DatabaseName + '_DIFF_' + @DateStamp + '_' + @TimeStamp + '.bak';
        SET @BackupName = N'QLDACNTT - Differential Backup tự động';
        SET @SQL = N'
            BACKUP DATABASE [' + @DatabaseName + N']
            TO DISK = N''' + @BackupFile + N'''
            WITH DIFFERENTIAL, NAME = N''' + @BackupName + N''',
                 COMPRESSION, CHECKSUM, STATS = 10;';
    END
    ELSE IF @BackupType = 'LOG'
    BEGIN
        SET @BackupFile = @BackupFolder + @DatabaseName + '_LOG_' + @DateStamp + '_' + @TimeStamp + '.trn';
        SET @BackupName = N'QLDACNTT - Log Backup tự động';
        SET @SQL = N'
            BACKUP LOG [' + @DatabaseName + N']
            TO DISK = N''' + @BackupFile + N'''
            WITH NAME = N''' + @BackupName + N''',
                 COMPRESSION, CHECKSUM, STATS = 10;';
    END
    ELSE
    BEGIN
        RAISERROR(N'Loại backup không hợp lệ. Chỉ chấp nhận: FULL, DIFF, LOG', 16, 1);
        RETURN;
    END

    PRINT 'Đang thực hiện ' + @BackupType + ' Backup...';
    PRINT 'File đích: ' + @BackupFile;

    EXEC sp_executesql @SQL;

    PRINT 'Backup hoàn tất: ' + @BackupFile;
    PRINT 'Thời gian: ' + CONVERT(VARCHAR, GETDATE(), 120);
END;
GO

-- ============================================================
-- VÍ DỤ SỬ DỤNG STORED PROCEDURE
-- ============================================================

-- Full Backup:
-- EXEC dbo.sp_BackupQldacntt @BackupType = 'FULL', @BackupFolder = 'D:\Backup\QLDACNTT\';

-- Differential Backup:
-- EXEC dbo.sp_BackupQldacntt @BackupType = 'DIFF', @BackupFolder = 'D:\Backup\QLDACNTT\';

-- Transaction Log Backup:
-- EXEC dbo.sp_BackupQldacntt @BackupType = 'LOG',  @BackupFolder = 'D:\Backup\QLDACNTT\';

-- ============================================================
-- PHẦN 11: HƯỚNG DẪN PHỤC HỒI DỮ LIỆU (RESTORE)
-- Chỉ thực hiện khi cần khôi phục – KHÔNG chạy tự động
-- ============================================================

/*
-- BƯỚC 1: Phục hồi từ Full Backup
RESTORE DATABASE QLDACNTT
FROM DISK = N'D:\Backup\QLDACNTT\QLDACNTT_FULL_20261023_100000.bak'
WITH NORECOVERY, REPLACE, STATS = 10;

-- BƯỚC 2: Áp dụng Differential Backup (nếu có)
RESTORE DATABASE QLDACNTT
FROM DISK = N'D:\Backup\QLDACNTT\QLDACNTT_DIFF_20261023_110000.bak'
WITH NORECOVERY, STATS = 10;

-- BƯỚC 3: Áp dụng Transaction Log Backup (nếu có)
RESTORE LOG QLDACNTT
FROM DISK = N'D:\Backup\QLDACNTT\QLDACNTT_LOG_20261023_120000.trn'
WITH RECOVERY, STATS = 10;

-- BƯỚC 4: Đưa database về trạng thái sử dụng được
-- (Câu lệnh RECOVERY ở bước 3 đã tự động thực hiện điều này)
*/

PRINT '=== SCRIPT BACKUP MBA-85 HOÀN TẤT ===';
PRINT 'Nhóm 11 - Lớp 23DTHC6 - QLDACNTT';
GO
