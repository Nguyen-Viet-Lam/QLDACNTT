/* =====================================================================
   LV33-001 — Truy vấn báo cáo thống kê
   Người viết: Trần Ngọc Lợi (Database)
   Các truy vấn này là nguồn dữ liệu cho dashboard và báo cáo Web Admin.
   ===================================================================== */

USE RepairShopDB;
GO

/* ---------- 1. Doanh thu theo ngày trong khoảng thời gian ---------- */
-- Tham số: @FromDate, @ToDate
DECLARE @FromDate DATE = '2026-09-01', @ToDate DATE = '2026-11-03';

SELECT
    CAST(i.CreatedAt AS DATE)        AS Ngay,
    COUNT(*)                         AS SoHoaDon,
    SUM(i.LaborCost)                 AS TienCong,
    SUM(i.PartsCost)                 AS TienLinhKien,
    SUM(i.DiscountAmount)            AS GiamGia,
    SUM(i.TotalAmount)               AS DoanhThu
FROM dbo.Invoices i
WHERE i.PaymentStatus = 'PAID'
  AND CAST(i.CreatedAt AS DATE) BETWEEN @FromDate AND @ToDate
GROUP BY CAST(i.CreatedAt AS DATE)
ORDER BY Ngay;
GO

/* ---------- 2. Doanh thu theo tháng ---------- */
SELECT
    YEAR(i.CreatedAt)                AS Nam,
    MONTH(i.CreatedAt)               AS Thang,
    COUNT(*)                         AS SoHoaDon,
    SUM(i.TotalAmount)               AS DoanhThu,
    AVG(i.TotalAmount)               AS GiaTriTrungBinh
FROM dbo.Invoices i
WHERE i.PaymentStatus = 'PAID'
GROUP BY YEAR(i.CreatedAt), MONTH(i.CreatedAt)
ORDER BY Nam, Thang;
GO

/* ---------- 3. Số phiếu theo trạng thái ---------- */
SELECT
    t.Status                         AS TrangThai,
    COUNT(*)                         AS SoPhieu
FROM dbo.RepairTickets t
GROUP BY t.Status
ORDER BY SoPhieu DESC;
GO

/* ---------- 4. Linh kiện tiêu thụ nhiều nhất ---------- */
SELECT TOP 10
    p.PartCode                       AS MaLinhKien,
    p.PartName                       AS TenLinhKien,
    SUM(tp.Quantity)                 AS SoLuongDaXuat,
    SUM(tp.LineTotal)                AS DoanhThuLinhKien,
    SUM(tp.Quantity * p.PurchasePrice) AS GiaVon,
    SUM(tp.LineTotal) - SUM(tp.Quantity * p.PurchasePrice) AS LoiNhuanGop
FROM dbo.TicketParts tp
JOIN dbo.SpareParts p ON p.PartId = tp.PartId
GROUP BY p.PartCode, p.PartName
ORDER BY SoLuongDaXuat DESC;
GO

/* ---------- 5. Linh kiện dưới mức tồn tối thiểu (cảnh báo) ---------- */
SELECT
    p.PartCode                       AS MaLinhKien,
    p.PartName                       AS TenLinhKien,
    c.CategoryName                   AS NhomLinhKien,
    p.StockQuantity                  AS TonHienTai,
    p.MinStockLevel                  AS TonToiThieu,
    p.MinStockLevel - p.StockQuantity AS CanNhapThem
FROM dbo.SpareParts p
JOIN dbo.SparePartCategories c ON c.CategoryId = p.CategoryId
WHERE p.IsActive = 1
  AND p.StockQuantity <= p.MinStockLevel
ORDER BY CanNhapThem DESC;
GO

/* ---------- 6. Hiệu suất kỹ thuật viên ---------- */
SELECT
    u.FullName                       AS KyThuatVien,
    COUNT(t.TicketId)                AS TongPhieu,
    SUM(CASE WHEN t.Status IN ('COMPLETED','DELIVERED') THEN 1 ELSE 0 END) AS PhieuHoanTat,
    SUM(CASE WHEN t.Status = 'CANCELLED' THEN 1 ELSE 0 END)                AS PhieuHuy,
    AVG(CASE WHEN t.CompletedAt IS NOT NULL
             THEN DATEDIFF(HOUR, t.ReceivedAt, t.CompletedAt) END)         AS GioXuLyTrungBinh,
    SUM(CASE WHEN t.IsWarrantyRepair = 1 THEN 1 ELSE 0 END)                AS PhieuBaoHanh
FROM dbo.Users u
LEFT JOIN dbo.RepairTickets t ON t.TechnicianUserId = u.UserId
WHERE u.RoleId = (SELECT RoleId FROM dbo.Roles WHERE RoleCode = 'TECHNICIAN')
GROUP BY u.FullName
ORDER BY PhieuHoanTat DESC;
GO

/* ---------- 7. Doanh thu theo loại dịch vụ ---------- */
SELECT
    s.ServiceName                    AS LoaiDichVu,
    COUNT(t.TicketId)                AS SoPhieu,
    SUM(ISNULL(i.TotalAmount, 0))    AS DoanhThu
FROM dbo.ServiceTypes s
LEFT JOIN dbo.RepairTickets t ON t.ServiceTypeId = s.ServiceTypeId
LEFT JOIN dbo.Invoices i      ON i.TicketId = t.TicketId AND i.PaymentStatus = 'PAID'
GROUP BY s.ServiceName
ORDER BY DoanhThu DESC;
GO

/* ---------- 8. Phiếu bảo hành sắp hết hạn trong 30 ngày ---------- */
SELECT
    w.WarrantyCode                   AS MaBaoHanh,
    c.FullName                       AS KhachHang,
    c.Phone                          AS SoDienThoai,
    d.DeviceType + N' ' + ISNULL(d.Brand, N'') AS ThietBi,
    w.StartDate                      AS NgayBatDau,
    w.EndDate                        AS NgayHetHan,
    DATEDIFF(DAY, GETDATE(), w.EndDate) AS ConLaiNgay
FROM dbo.Warranties w
JOIN dbo.Customers c ON c.CustomerId = w.CustomerId
JOIN dbo.Devices   d ON d.DeviceId   = w.DeviceId
WHERE w.Status = 'ACTIVE'
  AND w.EndDate BETWEEN CAST(GETDATE() AS DATE) AND DATEADD(DAY, 30, CAST(GETDATE() AS DATE))
ORDER BY ConLaiNgay;
GO

/* ---------- 9. Khách hàng thân thiết (chi nhiều nhất) ---------- */
SELECT TOP 10
    c.CustomerCode                   AS MaKhachHang,
    c.FullName                       AS TenKhachHang,
    c.Phone                          AS SoDienThoai,
    COUNT(DISTINCT t.TicketId)       AS SoLanSua,
    SUM(ISNULL(i.TotalAmount, 0))    AS TongChiTieu,
    MAX(t.ReceivedAt)                AS LanGanNhat
FROM dbo.Customers c
JOIN dbo.RepairTickets t ON t.CustomerId = c.CustomerId
LEFT JOIN dbo.Invoices i ON i.TicketId = t.TicketId AND i.PaymentStatus = 'PAID'
GROUP BY c.CustomerCode, c.FullName, c.Phone
ORDER BY TongChiTieu DESC;
GO

/* ---------- 10. Đối soát: linh kiện đã xuất so với tiền đã thu ---------- */
SELECT
    t.TicketCode                     AS MaPhieu,
    t.Status                         AS TrangThai,
    ISNULL(SUM(tp.LineTotal), 0)     AS TienLinhKienTheoPhieu,
    ISNULL(i.PartsCost, 0)           AS TienLinhKienTrenHoaDon,
    ISNULL(SUM(tp.LineTotal), 0) - ISNULL(i.PartsCost, 0) AS ChenhLech
FROM dbo.RepairTickets t
LEFT JOIN dbo.TicketParts tp ON tp.TicketId = t.TicketId
LEFT JOIN dbo.Invoices i     ON i.TicketId  = t.TicketId
GROUP BY t.TicketCode, t.Status, i.PartsCost
HAVING ISNULL(SUM(tp.LineTotal), 0) <> ISNULL(i.PartsCost, 0)
ORDER BY ABS(ISNULL(SUM(tp.LineTotal), 0) - ISNULL(i.PartsCost, 0)) DESC;
GO
