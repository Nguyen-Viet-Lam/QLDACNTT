/* =====================================================================
   LV33-001 — Hệ thống quản lý tổng thể cho cửa hàng sửa chữa
   Script 01: Tạo cơ sở dữ liệu
   Người viết: Trần Ngọc Lợi (Database)
   ===================================================================== */

USE master;
GO

IF DB_ID('RepairShopDB') IS NULL
BEGIN
    CREATE DATABASE RepairShopDB
    COLLATE Vietnamese_CI_AS;
    PRINT 'Da tao database RepairShopDB.';
END
ELSE
    PRINT 'Database RepairShopDB da ton tai, bo qua.';
GO

ALTER DATABASE RepairShopDB SET RECOVERY SIMPLE;
GO
