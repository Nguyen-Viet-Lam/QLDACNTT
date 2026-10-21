USE RepairShopDB;
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
        (SELECT SUM(tp2.LineTotal) - SUM(tp2.Quantity * p.PurchasePrice)
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
