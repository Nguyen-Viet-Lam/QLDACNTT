-- =========================================================================
-- NHÓM 11 - DỰ ÁN QUẢN LÝ CỬA HÀNG SỬA CHỮA (LV33-001)
-- MODULE: QUẢN LÝ KHO & HOÀN TRẢ LINH KIỆN LỖI (SPRINT 6)
-- TÁC GIẢ: TRẦN NGỌC LỢI (BA / DATABASE LEAD) - TASK JIRA: MBA-78
-- CSDL: SQL Server 2022 | Database: QLDACNTT_CuaHangSuaChua / RepairShopDB
-- =========================================================================

IF DB_ID('QLDACNTT_CuaHangSuaChua') IS NOT NULL
    USE QLDACNTT_CuaHangSuaChua;
ELSE IF DB_ID('RepairShopDB') IS NOT NULL
    USE RepairShopDB;
GO

-- 1. STORED PROCEDURE: Ghi nhận hoàn trả linh kiện lỗi / hỏng về kho
-- Chức năng: 
--  - Kiểm tra tính hợp lệ của mã linh kiện
--  - Cập nhật tăng số lượng tồn kho trong bảng SpareParts (để nhập lại kho linh kiện hỏng / thu hồi)
--  - Ghi log giao dịch hoàn trả vào StockTransactions với loại giao dịch 'RETURN'
CREATE OR ALTER PROCEDURE dbo.sp_HoanTraLinhKienLoi
    @PartCode VARCHAR(50),
    @Quantity INT,
    @TicketCode VARCHAR(50) = NULL,
    @PerformerUsername NVARCHAR(100),
    @DefectReason NVARCHAR(255),
    @Note NVARCHAR(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;

    BEGIN TRY
        -- A. Kiểm tra số lượng hợp lệ
        IF @Quantity <= 0
        BEGIN
            RAISERROR(N'Lỗi: Số lượng linh kiện hoàn trả phải lớn hơn 0.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN -1;
        END

        -- B. Kiểm tra lý do lỗi không được để trống
        IF ISNULL(@DefectReason, '') = ''
        BEGIN
            RAISERROR(N'Lỗi: Vui lòng cung cấp lý do linh kiện bị lỗi/hỏng.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN -2;
        END

        -- C. Kiểm tra linh kiện có tồn tại trong CSDL không
        DECLARE @PartId INT, @CurrentStock INT, @SellingPrice DECIMAL(18,2);
        SELECT 
            @PartId = PartId, 
            @CurrentStock = StockQuantity,
            @SellingPrice = SellingPrice
        FROM dbo.SpareParts
        WHERE PartCode = @PartCode AND IsActive = 1;

        IF @PartId IS NULL
        BEGIN
            RAISERROR(N'Lỗi: Linh kiện mã %s không tồn tại hoặc đã bị vô hiệu hóa.', 16, 1, @PartCode);
            ROLLBACK TRANSACTION;
            RETURN -3;
        END

        -- D. Cập nhật cộng trả lại số lượng tồn kho trong bảng SpareParts
        DECLARE @StockBefore INT = @CurrentStock;
        DECLARE @StockAfter INT = @CurrentStock + @Quantity;

        UPDATE dbo.SpareParts
        SET StockQuantity = StockQuantity + @Quantity,
            UpdatedAt = GETDATE()
        WHERE PartId = @PartId;

        -- E. Tìm TicketId từ TicketCode nếu có
        DECLARE @TicketId INT = NULL;
        IF @TicketCode IS NOT NULL AND @TicketCode <> ''
        BEGIN
            SELECT @TicketId = TicketId 
            FROM dbo.RepairTickets 
            WHERE TicketCode = @TicketCode;
        END

        -- F. Lấy UserId người thực hiện
        DECLARE @UserId INT;
        SELECT @UserId = UserId FROM dbo.Users WHERE Username = @PerformerUsername;
        IF @UserId IS NULL
        BEGIN
            -- Nếu chưa chọn User cụ thể, mặc định lấy ID của Admin hoặc User hệ thống
            SELECT TOP 1 @UserId = UserId FROM dbo.Users ORDER BY UserId ASC;
        END

        -- G. Ghi nhật ký biến động kho vào bảng StockTransactions (Type = 'RETURN')
        DECLARE @FullNote NVARCHAR(500);
        SET @FullNote = N'[HOÀN TRẢ LỖI] Lý do: ' + @DefectReason + 
                        CASE WHEN @Note IS NOT NULL THEN N' | Ghi chú: ' + @Note ELSE N'' END;

        INSERT INTO dbo.StockTransactions (
            PartId, 
            TransactionType, 
            Quantity, 
            UnitPrice, 
            StockBefore,
            StockAfter,
            TicketId, 
            PerformedByUserId, 
            TransactionAt, 
            Note
        )
        VALUES (
            @PartId,
            'RETURN',
            @Quantity,
            @SellingPrice,
            @StockBefore,
            @StockAfter,
            @TicketId,
            @UserId,
            GETDATE(),
            @FullNote
        );

        COMMIT TRANSACTION;
        PRINT N'>> [THÀNH CÔNG]: Đã nhập hoàn trả ' + CAST(@Quantity AS NVARCHAR) + N' cái linh kiện lỗi ' + @PartCode + N' vào kho. Tồn mới: ' + CAST(@StockAfter AS NVARCHAR);
        RETURN 0;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMsg, 16, 1);
        RETURN -99;
    END CATCH
END;
GO

-- 2. DEMO KỊCH BẢN THỬ NGHIỆM STORED PROCEDURE (TEST RUN)
-- EXEC dbo.sp_HoanTraLinhKienLoi 
--     @PartCode = 'PIN-IP11', 
--     @Quantity = 1, 
--     @TicketCode = 'PSC2026090001', 
--     @PerformerUsername = 'tech', 
--     @DefectReason = N'Pin phồng không tích điện khi test lắp máy',
--     @Note = N'Yêu cầu hoàn trả kho đổi nhà cung cấp';
