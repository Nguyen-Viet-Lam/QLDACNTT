-- =========================================================================
-- NHÓM 11 - DỰ ÁN QUẢN LÝ CỬA HÀNG SỬA CHỮA (LV33-001)
-- MODULE: QUẢN LÝ KHO & CẢNH BÁO TỒN KHO TỐI THIỂU (SPRINT 5 & 6)
-- TÁC GIẢ: TRẦN NGỌC LỢI (BA / DATABASE LEAD) - TASK JIRA: MBA-63
-- CSDL: SQL Server 2022 | Database: QLDACNTT_CuaHangSuaChua
-- =========================================================================

USE QLDACNTT_CuaHangSuaChua;
GO

-- 1. STORED PROCEDURE: Tự động xuất kho linh kiện phục vụ sửa chữa phiếu
-- Chức năng: Kiểm tra tồn kho, trừ số lượng tồn trong SpareParts, ghi log vào StockTransactions
CREATE OR ALTER PROCEDURE dbo.sp_XuatKhoLinhKienSuaChua
    @PartCode VARCHAR(50),
    @Quantity INT,
    @TicketCode VARCHAR(50),
    @PerformerUsername NVARCHAR(100),
    @Note NVARCHAR(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;

    BEGIN TRY
        -- A. Kiểm tra linh kiện có tồn tại không
        DECLARE @PartId INT, @CurrentStock INT, @MinStock INT, @SellingPrice DECIMAL(18,2);
        SELECT 
            @PartId = PartId, 
            @CurrentStock = StockQuantity, 
            @MinStock = MinStockLevel,
            @SellingPrice = SellingPrice
        FROM dbo.SpareParts
        WHERE PartCode = @PartCode AND IsActive = 1;

        IF @PartId IS NULL
        BEGIN
            RAISERROR(N'Lỗi: Linh kiện mã %s không tồn tại hoặc đã bị vô hiệu hóa.', 16, 1, @PartCode);
            ROLLBACK TRANSACTION;
            RETURN -1;
        END

        -- B. Kiểm tra số lượng tồn kho có đủ để xuất không
        IF @CurrentStock < @Quantity
        BEGIN
            DECLARE @ErrMsg NVARCHAR(200);
            SET @ErrMsg = N'Lỗi: Số lượng tồn kho không đủ (Hiện tồn: ' + CAST(@CurrentStock AS NVARCHAR) + N', Yêu cầu: ' + CAST(@Quantity AS NVARCHAR) + N').';
            RAISERROR(@ErrMsg, 16, 1);
            ROLLBACK TRANSACTION;
            RETURN -2;
        END

        -- C. Thực hiện trừ số lượng tồn kho trong bảng SpareParts
        UPDATE dbo.SpareParts
        SET StockQuantity = StockQuantity - @Quantity,
            UpdatedAt = GETDATE()
        WHERE PartId = @PartId;

        -- D. Ghi nhật ký biến động kho vào bảng StockTransactions
        INSERT INTO dbo.StockTransactions (
            PartId, 
            TransactionType, 
            Quantity, 
            UnitPrice, 
            TicketCode, 
            CreatedBy, 
            CreatedAt, 
            Note
        )
        VALUES (
            @PartId,
            'XUAT_KHO_SUA_CHUA',
            @Quantity,
            @SellingPrice,
            @TicketCode,
            @PerformerUsername,
            GETDATE(),
            ISNULL(@Note, N'Xuất linh kiện phục vụ sửa chữa cho phiếu: ' + @TicketCode)
        );

        -- E. Kiểm tra xem sau khi xuất, tồn kho có chạm ngưỡng tối thiểu không
        DECLARE @NewStock INT = @CurrentStock - @Quantity;
        IF @NewStock <= @MinStock
        BEGIN
            PRINT N'>> [CẢNH BÁO TỒN KHO]: Linh kiện ' + @PartCode + N' hiện còn ' + CAST(@NewStock AS NVARCHAR) + N' cái (<= mức tối thiểu ' + CAST(@MinStock AS NVARCHAR) + N'). Cần đặt hàng nhập thêm!';
        END

        COMMIT TRANSACTION;
        PRINT N'>> [THÀNH CÔNG]: Đã xuất kho ' + CAST(@Quantity AS NVARCHAR) + N' cái linh kiện ' + @PartCode + N' cho phiếu ' + @TicketCode;
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

-- 2. TRIGGER: Cảnh báo tự động khi cập nhật tồn kho dưới định mức an toàn
CREATE OR ALTER TRIGGER dbo.trg_CanhBaoTonKhoToiThieu
ON dbo.SpareParts
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF UPDATE(StockQuantity)
    BEGIN
        IF EXISTS (
            SELECT 1 FROM inserted i
            WHERE i.StockQuantity <= i.MinStockLevel AND i.IsActive = 1
        )
        BEGIN
            PRINT N'>> [TRIGGER THÔNG BÁO]: Có linh kiện chạm ngưỡng cảnh báo tồn tối thiểu trong bảng dbo.SpareParts!';
        END
    END
END;
GO

-- 3. TEST THỬ NGHIỆM STORED PROCEDURE (DEMO RUN)
-- EXEC dbo.sp_XuatKhoLinhKienSuaChua @PartCode = 'PIN-IP11', @Quantity = 1, @TicketCode = 'TC-2026-001', @PerformerUsername = 'tranngocloi', @Note = N'Thay pin cho khách hàng';
-- SELECT * FROM dbo.v_CanhBaoTonKho;
