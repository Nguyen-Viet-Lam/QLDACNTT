-- =========================================================================
-- NHÓM 11 - DỰ ÁN QUẢN LÝ CỬA HÀNG SỬA CHỮA (LV33-001)
-- MODULE: QUẢN LÝ KHO & CẢNH BÁO TỒN KHO TỐI THIỂU (SPRINT 6 - IN PROGRESS)
-- PHỤ TRÁCH: TRẦN NGỌC LỢI (BA / DATABASE LEAD) - TASK MBA-63
-- =========================================================================

USE QLDACNTT_CuaHangSuaChua;
GO

-- 1. VIEW: Danh sách linh kiện chạm ngưỡng cảnh báo tồn tối thiểu cần đặt hàng gấp
CREATE OR ALTER VIEW dbo.v_CanhBaoTonKho
AS
SELECT 
    sp.PartId,
    sp.PartCode,
    sp.PartName,
    cat.CategoryName,
    sp.StockQuantity AS TonKhoHienTai,
    sp.MinStockLevel AS MucTonToiThieu,
    (sp.MinStockLevel - sp.StockQuantity) AS SoLuongCanNhapThem,
    sp.PurchasePrice AS DonGiaNhapDuKien,
    ((sp.MinStockLevel - sp.StockQuantity) * sp.PurchasePrice) AS ChiPhiNhapDuKien,
    CASE 
        WHEN sp.StockQuantity = 0 THEN N'HẾT HÀNG (NGHIÊM TRỌNG)'
        WHEN sp.StockQuantity <= sp.MinStockLevel THEN N'CẢNH BÁO: DƯỚI MỨC TỐI THIỂU'
        ELSE N'AN TOÀN'
    END AS TrangThaiCanhBao
FROM dbo.SpareParts sp
JOIN dbo.SparePartCategories cat ON sp.CategoryId = cat.CategoryId
WHERE sp.StockQuantity <= sp.MinStockLevel AND sp.IsActive = 1;
GO

-- 2. Truy vấn mẫu kiểm tra cảnh báo tồn kho
SELECT * FROM dbo.v_CanhBaoTonKho ORDER BY TonKhoHienTai ASC;
GO

-- TODO (Sprint 6 - In Progress): Trần Ngọc Lợi đang viết thêm Stored Procedure tự động cập nhật nhật ký StockTransactions khi duyệt phiếu.
