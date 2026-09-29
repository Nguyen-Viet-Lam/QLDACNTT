/* =====================================================================
   Script sửa trực tiếp dữ liệu tiếng Việt bị lỗi font trong Database
   Chỉ cần mở trong SSMS và bấm Execute (F5) là sạch đẹp ngay 100%!
   ===================================================================== */

USE RepairShopDB;
GO

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

PRINT N'Đang sửa font tiếng Việt bảng Roles...';
UPDATE dbo.Roles SET RoleName = N'Quản trị viên', Description = N'Chủ cửa hàng / quản lý, toàn quyền hệ thống' WHERE RoleCode = 'ADMIN';
UPDATE dbo.Roles SET RoleName = N'Nhân viên', Description = N'Tiếp nhận thiết bị, lập phiếu, thu tiền' WHERE RoleCode = 'STAFF';
UPDATE dbo.Roles SET RoleName = N'Kỹ thuật viên', Description = N'Chẩn đoán, sửa chữa, xuất linh kiện' WHERE RoleCode = 'TECHNICIAN';
UPDATE dbo.Roles SET RoleName = N'Khách hàng', Description = N'Tra cứu tiến độ và bảo hành qua mobile app' WHERE RoleCode = 'CUSTOMER';
GO

PRINT N'Đang sửa font tiếng Việt bảng Users...';
UPDATE dbo.Users SET FullName = N'Chủ cửa hàng' WHERE Username = 'admin';
UPDATE dbo.Users SET FullName = N'Lê Thị Tiếp Nhận' WHERE Username = 'staff01';
UPDATE dbo.Users SET FullName = N'Phạm Văn Kỹ Thuật' WHERE Username = 'tech01';
UPDATE dbo.Users SET FullName = N'Võ Minh Kỹ Thuật' WHERE Username = 'tech02';
GO

PRINT N'Đang sửa font tiếng Việt bảng ServiceTypes...';
UPDATE dbo.ServiceTypes SET ServiceName = N'Thay màn hình điện thoại', Description = N'Tháo lắp và thay màn hình' WHERE ServiceCode = 'DV001';
UPDATE dbo.ServiceTypes SET ServiceName = N'Thay pin điện thoại', Description = N'Thay pin và kiểm tra sạc' WHERE ServiceCode = 'DV002';
UPDATE dbo.ServiceTypes SET ServiceName = N'Vệ sinh máy, tra keo tản nhiệt', Description = N'Vệ sinh laptop, thay keo tản nhiệt' WHERE ServiceCode = 'DV003';
UPDATE dbo.ServiceTypes SET ServiceName = N'Cài đặt lại hệ điều hành', Description = N'Cài Windows, driver, phần mềm cơ bản' WHERE ServiceCode = 'DV004';
UPDATE dbo.ServiceTypes SET ServiceName = N'Sửa mainboard', Description = N'Sửa chữa mạch, hàn linh kiện' WHERE ServiceCode = 'DV005';
UPDATE dbo.ServiceTypes SET ServiceName = N'Thay ổ cứng / nâng cấp SSD', Description = N'Thay ổ cứng, sao lưu dữ liệu' WHERE ServiceCode = 'DV006';
UPDATE dbo.ServiceTypes SET ServiceName = N'Sửa nguồn máy tính', Description = N'Kiểm tra và sửa bộ nguồn' WHERE ServiceCode = 'DV007';
UPDATE dbo.ServiceTypes SET ServiceName = N'Thay mực, sửa máy in', Description = N'Vệ sinh, thay mực, sửa cơ cấu nạp giấy' WHERE ServiceCode = 'DV008';
GO

PRINT N'Đang sửa font tiếng Việt bảng SparePartCategories...';
UPDATE dbo.SparePartCategories SET CategoryName = N'Màn hình', Description = N'Màn hình điện thoại, laptop' WHERE CategoryId = 1;
UPDATE dbo.SparePartCategories SET CategoryName = N'Pin & Sạc', Description = N'Pin, adapter, cáp sạc' WHERE CategoryId = 2;
UPDATE dbo.SparePartCategories SET CategoryName = N'Ổ cứng & RAM', Description = N'HDD, SSD, thanh RAM' WHERE CategoryId = 3;
UPDATE dbo.SparePartCategories SET CategoryName = N'Mainboard & IC', Description = N'Bo mạch, IC, chip' WHERE CategoryId = 4;
UPDATE dbo.SparePartCategories SET CategoryName = N'Vật tư tiêu hao', Description = N'Keo tản nhiệt, mực in, ốc vít' WHERE CategoryId = 5;
UPDATE dbo.SparePartCategories SET CategoryName = N'Phụ kiện khác', Description = N'Bàn phím, loa, camera, quạt' WHERE CategoryId = 6;
GO

PRINT N'Đang sửa font tiếng Việt bảng SpareParts...';
UPDATE dbo.SpareParts SET PartName = N'Màn hình iPhone 11 (linh kiện)', Unit = N'Cái' WHERE PartCode = 'LK00001';
UPDATE dbo.SpareParts SET PartName = N'Màn hình Samsung A32', Unit = N'Cái' WHERE PartCode = 'LK00002';
UPDATE dbo.SpareParts SET PartName = N'Màn hình laptop 15.6" FHD', Unit = N'Cái' WHERE PartCode = 'LK00003';
UPDATE dbo.SpareParts SET PartName = N'Pin iPhone 11', Unit = N'Cái' WHERE PartCode = 'LK00004';
UPDATE dbo.SpareParts SET PartName = N'Pin laptop Dell 3 cell', Unit = N'Cái' WHERE PartCode = 'LK00005';
UPDATE dbo.SpareParts SET PartName = N'Adapter laptop 65W', Unit = N'Cái' WHERE PartCode = 'LK00006';
UPDATE dbo.SpareParts SET PartName = N'SSD 256GB SATA', Unit = N'Cái' WHERE PartCode = 'LK00007';
UPDATE dbo.SpareParts SET PartName = N'SSD 512GB NVMe', Unit = N'Cái' WHERE PartCode = 'LK00008';
UPDATE dbo.SpareParts SET PartName = N'RAM DDR4 8GB 3200MHz', Unit = N'Thanh' WHERE PartCode = 'LK00009';
UPDATE dbo.SpareParts SET PartName = N'IC nguồn điện thoại', Unit = N'Cái' WHERE PartCode = 'LK00010';
UPDATE dbo.SpareParts SET PartName = N'Chân sạc iPhone', Unit = N'Cái' WHERE PartCode = 'LK00011';
UPDATE dbo.SpareParts SET PartName = N'Keo tản nhiệt MX-4 (tuýp nhỏ)', Unit = N'Tuýp' WHERE PartCode = 'LK00012';
UPDATE dbo.SpareParts SET PartName = N'Mực in Canon 2900', Unit = N'Hộp' WHERE PartCode = 'LK00013';
UPDATE dbo.SpareParts SET PartName = N'Bàn phím laptop Dell', Unit = N'Cái' WHERE PartCode = 'LK00014';
UPDATE dbo.SpareParts SET PartName = N'Quạt tản nhiệt laptop', Unit = N'Cái' WHERE PartCode = 'LK00015';
UPDATE dbo.SpareParts SET PartName = N'Loa trong điện thoại', Unit = N'Cái' WHERE PartCode = 'LK00016';
GO

PRINT N'Hoàn tất sửa dữ liệu tiếng Việt!';
GO
