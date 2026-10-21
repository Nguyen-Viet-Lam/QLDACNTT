USE RepairShopDB;
GO

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

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
TongDoanhThuHeThong AS (
    SELECT ISNULL(SUM(tp.LineTotal), 0) AS TongToanCuaHang
    FROM dbo.TicketParts tp
    JOIN dbo.RepairTickets t ON t.TicketId = tp.TicketId
    WHERE t.Status IN ('COMPLETED','DELIVERED','PAID')
),
DoanhThuLinhKien AS (
    SELECT 
        tp.PartId,
        SUM(tp.Quantity) AS TongSL,
        SUM(tp.LineTotal) AS TongTien
    FROM dbo.TicketParts tp
    JOIN dbo.RepairTickets t ON t.TicketId = tp.TicketId
    WHERE t.Status IN ('COMPLETED','DELIVERED','PAID')
    GROUP BY tp.PartId
)
SELECT
    p.PartId,
    p.PartCode                                                  AS MaLinhKien,
    p.PartName                                                  AS TenLinhKien,
    c.CategoryName                                              AS NhomLinhKien,
    p.StockQuantity                                             AS TonHienTai,
    p.MinStockLevel                                             AS TonToiThieu,
    ISNULL(tt.TongXuat, 0)                                     AS TongSoLuongBan,
    ISNULL(tt.TongHoanTra, 0)                                  AS SoLuongHoanTra,
    ISNULL(tt.TongXuat, 0) - ISNULL(tt.TongHoanTra, 0)        AS SoLuongBanThuan,
    ISNULL(tt.SoPhieuSuDung, 0)                                AS SoPhieuSuDung,
    ISNULL(dt.TongTien, 0)                                     AS DoanhThuThucTe,
    ISNULL(dt.TongTien - (dt.TongSL * p.PurchasePrice), 0)     AS LoiNhuanGop,
    CASE
        WHEN (SELECT TongToanCuaHang FROM TongDoanhThuHeThong) > 0
        THEN CAST(ISNULL(dt.TongTien, 0) * 100.0 / (SELECT TongToanCuaHang FROM TongDoanhThuHeThong) AS DECIMAL(5,2))
        ELSE 0
    END                                                         AS TyTrongDoanhThuPhanTram,
    tt.LanXuatGanNhat,
    DATEDIFF(DAY, tt.LanXuatGanNhat, GETDATE())                AS SoNgayChuaBanLai,
    p.SellingPrice                                              AS DonGiaBan,
    p.PurchasePrice                                             AS DonGiaNhap
FROM dbo.SpareParts p
JOIN dbo.SparePartCategories c ON c.CategoryId = p.CategoryId
LEFT JOIN ThongKeTieuThu tt ON tt.PartId = p.PartId
LEFT JOIN DoanhThuLinhKien dt ON dt.PartId = p.PartId
WHERE p.IsActive = 1;
GO

