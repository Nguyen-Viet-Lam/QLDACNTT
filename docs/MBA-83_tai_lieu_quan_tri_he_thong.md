# TÀI LIỆU QUẢN TRỊ HỆ THỐNG VÀ CẤU HÌNH SERVER – MBA-83
## NHÓM 11 | LV33-001 | Trần Ngọc Lợi (BA / Database Lead) | 17/10/2026

---

## MỤC LỤC
1. [Tổng quan kiến trúc](#1-tổng-quan-kiến-trúc)
2. [Yêu cầu hệ thống](#2-yêu-cầu-hệ-thống)
3. [Hướng dẫn cài đặt](#3-hướng-dẫn-cài-đặt)
4. [Cấu hình SQL Server](#4-cấu-hình-sql-server)
5. [Cấu hình Backend API](#5-cấu-hình-backend-api)
6. [Quản lý tài khoản & phân quyền](#6-quản-lý-tài-khoản--phân-quyền)
7. [Sao lưu & khôi phục dữ liệu](#7-sao-lưu--khôi-phục-dữ-liệu)
8. [Giám sát & bảo trì](#8-giám-sát--bảo-trì)
9. [Xử lý sự cố thường gặp](#9-xử-lý-sự-cố-thường-gặp)
10. [Checklist triển khai production](#10-checklist-triển-khai-production)

---

## 1. TỔNG QUAN KIẾN TRÚC

```
┌─────────────────────────────────────────────────────┐
│                    CLIENT LAYER                     │
│   Web Admin UI (HTML/Bootstrap/Chart.js)            │
└──────────────────────┬──────────────────────────────┘
                       │ HTTP REST API
┌──────────────────────▼──────────────────────────────┐
│              BACKEND API LAYER                      │
│   ASP.NET Core 8 Minimal API – Port 5055            │
│   Auth | Tickets | Inventory | Billing | Reports    │
└──────────────────────┬──────────────────────────────┘
                       │ Microsoft.Data.SqlClient
┌──────────────────────▼──────────────────────────────┐
│                   DATA LAYER                        │
│   SQL Server 2022 – Database: RepairShopDB          │
│   13 bảng + Views + Stored Procedures + Indexes     │
└─────────────────────────────────────────────────────┘
```

| Thành phần | Công nghệ | Vị trí |
|---|---|---|
| Backend API | ASP.NET Core 8 | `src/backend/` |
| Web Admin UI | HTML5 + Bootstrap 5 + Chart.js | `src/web-admin/` |
| Database | SQL Server 2022 | Instance: `MSSQLSERVER` |
| API Port | 5055 (HTTP) | `launchSettings.json` |

---

## 2. YÊU CẦU HỆ THỐNG

### Phần cứng tối thiểu

| Thành phần | Tối thiểu | Khuyến nghị |
|---|---|---|
| CPU | 2 nhân 2.0 GHz | 4 nhân 3.0 GHz |
| RAM | 4 GB | 8 GB |
| Ổ cứng | 10 GB trống | SSD 30 GB |
| HĐH | Windows 10 x64 | Windows 11 / Server 2022 |

### Phần mềm cần cài đặt

| Phần mềm | Phiên bản | Link tải |
|---|---|---|
| .NET SDK | 8.0 LTS | https://dotnet.microsoft.com/download/dotnet/8.0 |
| SQL Server | 2022 Express (miễn phí) | https://www.microsoft.com/sql-server/sql-server-downloads |
| SSMS | 19.x / 20.x | https://aka.ms/ssmsfullsetup |
| Git | 2.x | https://git-scm.com/ |
| VS Code | Mới nhất | https://code.visualstudio.com/ |

---

## 3. HƯỚNG DẪN CÀI ĐẶT

### Bước 1 – Clone mã nguồn
```bash
git clone https://github.com/Nguyen-Viet-Lam/QLDACNTT.git
cd QLDACNTT
```

### Bước 2 – Khởi tạo database
Mở SSMS, kết nối `.\MSSQLSERVER`, chạy theo thứ tự:
```
1. database/QLDACNTT_full_database.sql        (tạo schema + seed)
2. database/fix_tieng_viet_data.sql           (sửa tiếng Việt)
3. database/queries/02_canh_bao_ton_kho...    (stored procedures)
4. database/queries/03_sp_xuat_kho_tu_dong.sql
5. database/queries/04_sp_hoan_tra_linh_kien_loi.sql
6. database/queries/05_bao_cao_doanh_thu...   (views báo cáo MBA-73)
7. database/queries/06_toi_uu_truy_van...     (indexes + cache MBA-59)
8. database/queries/07_lich_su_xuat_nhap...   (audit MBA-65)
9. database/queries/08_bao_cao_linh_kien...   (thống kê MBA-74)
```

### Bước 3 – Cấu hình `appsettings.json`
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=.;Database=RepairShopDB;Integrated Security=True;TrustServerCertificate=True;Connect Timeout=5"
  }
}
```

### Bước 4 – Khởi động API
```bash
cd src/backend
dotnet restore
dotnet run
```
API chạy tại: **http://localhost:5055**

### Bước 5 – Mở Web Admin
Truy cập: **http://localhost:5055/admin**

---

## 4. CẤU HÌNH SQL SERVER

### Thông tin kết nối mặc định

| Tham số | Giá trị |
|---|---|
| Server | `.\MSSQLSERVER` hoặc `(local)` |
| Database | `RepairShopDB` |
| Auth | Windows Authentication |
| Port | 1433 (mặc định) |

### Cấu trúc database – 13 bảng chính

```
dbo.Roles                 dbo.Users                 dbo.Customers
dbo.Devices               dbo.ServiceTypes          dbo.RepairTickets
dbo.SparePartCategories   dbo.SpareParts            dbo.StockTransactions
dbo.TicketParts           dbo.Invoices              dbo.Payments
dbo.Warranties            dbo.TicketStatusLogs
```

### Stored Procedures chính

| SP | Mục đích | Task |
|---|---|---|
| `sp_XuatKhoTuDong` | Xuất kho tự động | MBA-63 |
| `sp_HoanTraLinhKienLoi` | Hoàn trả linh kiện lỗi | MBA-64 |
| `sp_BaoCaoDoanhThuTheoThoVaDichVu` | Báo cáo doanh thu | MBA-73 |
| `sp_LichSuXuatNhapLinhKien` | Lịch sử kho | MBA-65 |
| `sp_BaoCaoThongKeLinhKien` | Thống kê linh kiện | MBA-74 |
| `sp_DashboardTongQuan` | Cache dashboard | MBA-59 |
| `sp_BaoTriIndex` | Bảo trì index tự động | MBA-59 |
| `sp_DoiChieuTonKho` | Đối chiếu tồn kho | MBA-65 |

### SQL Agent Job – bảo trì tự động (Chủ nhật 2:00 AM)
```sql
USE msdb;
EXEC sp_add_job @job_name = N'QLDACNTT - Bao tri tuan';
EXEC sp_add_jobstep
    @job_name = N'QLDACNTT - Bao tri tuan',
    @step_name = N'Rebuild Index + Lam moi Cache',
    @command = N'
        USE RepairShopDB;
        EXEC dbo.sp_BaoTriIndex;
        EXEC dbo.sp_LamMoiCacheDoanhThu @SoNgayNhin = 90;
    ';
```

---

## 5. CẤU HÌNH BACKEND API

### Cấu trúc project
```
src/backend/
├── Program.cs                      # Entry point, middleware, routes
├── appsettings.json                 # Config
├── Endpoints/
│   ├── AuthEndpoints.cs             # Đăng nhập, phiên làm việc
│   ├── CatalogEndpoints.cs          # Khách hàng, thiết bị, dịch vụ
│   ├── TicketEndpoints.cs           # Phiếu sửa chữa
│   ├── InventoryEndpoints.cs        # Kho linh kiện
│   ├── BillingAndWarrantyEndpoints.cs  # Hóa đơn, thanh toán, bảo hành
│   └── DashboardEndpoints.cs        # Dashboard tổng quan
├── Models/DomainModels.cs           # Record types
├── Data/AppData.cs                  # Demo in-memory data
├── Contracts/RequestContracts.cs    # Request DTOs
└── Infrastructure/AuthHelper.cs     # Auth middleware
```

### Danh sách API Endpoints quan trọng

| Method | Endpoint | Quyền | Mô tả |
|---|---|---|---|
| POST | `/api/auth/login` | Public | Đăng nhập |
| POST | `/api/auth/logout` | Tất cả | Đăng xuất |
| GET | `/api/customers` | ADMIN, STAFF | Danh sách khách hàng |
| GET | `/api/tickets` | ADMIN, STAFF, TECH | Danh sách phiếu |
| POST | `/api/tickets` | ADMIN, STAFF | Tạo phiếu mới |
| GET | `/api/inventory/summary` | ADMIN, STAFF | Tổng quan kho |
| POST | `/api/inventory/transactions` | ADMIN, STAFF, TECH | Giao dịch kho |
| POST | `/api/invoices` | ADMIN, STAFF | Lập hóa đơn |
| POST | `/api/invoices/{code}/pay` | ADMIN, STAFF | Thanh toán |
| GET | `/api/warranties/search` | Tất cả | Tra cứu bảo hành |
| GET | `/api/dashboard/summary` | ADMIN | Dashboard |
| GET | `/health` | Public | Health check |
| GET | `/api/db/status` | Public | Trạng thái DB |

---

## 6. QUẢN LÝ TÀI KHOẢN & PHÂN QUYỀN

### Vai trò hệ thống

| Vai trò | Mã | Quyền chính |
|---|---|---|
| Quản trị viên | ADMIN | Tất cả chức năng |
| Nhân viên tiếp nhận | STAFF | Tạo phiếu, hóa đơn, thanh toán |
| Kỹ thuật viên | TECHNICIAN | Cập nhật phiếu, xuất kho |
| Khách hàng | CUSTOMER | Xem phiếu/bảo hành của mình |

### Tài khoản demo mặc định

| Username | Vai trò | Người đại diện |
|---|---|---|
| `admin / 123456` | ADMIN | Nguyễn Viết Lãm (PM) |
| `loi.staff / 123456` | STAFF | Trần Ngọc Lợi (BA) |
| `ky.tech / 123456` | TECHNICIAN | Nguyễn Đại Kỳ (QA) |
| `khach01 / 123456` | CUSTOMER | Nguyễn Văn An |

> **⚠️ Đổi toàn bộ mật khẩu này trước khi production!**

---

## 7. SAO LƯU & KHÔI PHỤC DỮ LIỆU

### Lịch sao lưu khuyến nghị

| Loại | Tần suất | Giữ lại |
|---|---|---|
| Full Backup | Hàng tuần (CN) | 4 tuần |
| Differential | Hàng ngày (2AM) | 7 ngày |
| Transaction Log | Mỗi giờ | 24 giờ |

### Script sao lưu
```sql
DECLARE @BackupFile NVARCHAR(500) =
    N'C:\Backup\RepairShopDB\RepairShopDB_Full_'
    + FORMAT(GETDATE(), 'yyyyMMdd_HHmmss') + N'.bak';

BACKUP DATABASE RepairShopDB
TO DISK = @BackupFile
WITH COMPRESSION, CHECKSUM, STATS = 10;
```

### Script khôi phục
```sql
-- ⚠️ Sẽ ghi đè database hiện tại!
ALTER DATABASE RepairShopDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
RESTORE DATABASE RepairShopDB
FROM DISK = N'C:\Backup\RepairShopDB\RepairShopDB_Full_YYYYMMDD.bak'
WITH REPLACE, RECOVERY;
ALTER DATABASE RepairShopDB SET MULTI_USER;
```

---

## 8. GIÁM SÁT & BẢO TRÌ

### Kiểm tra sức khỏe hệ thống
```bash
curl http://localhost:5055/health      # API alive
curl http://localhost:5055/api/db/status  # DB connection
```

### Truy vấn giám sát database
```sql
-- Kết nối hiện tại
SELECT session_id, login_name, host_name, status
FROM sys.dm_exec_sessions
WHERE database_id = DB_ID('RepairShopDB');

-- Kích thước từng bảng
SELECT t.name AS TenBang, i.rows AS SoBanGhi,
    CAST(SUM(a.total_pages) * 8.0 / 1024 AS DECIMAL(10,2)) AS TongMB
FROM sys.tables t
JOIN sys.indexes i ON t.object_id = i.object_id
JOIN sys.partitions p ON i.object_id = p.object_id AND i.index_id = p.index_id
JOIN sys.allocation_units a ON p.partition_id = a.container_id
WHERE t.is_ms_shipped = 0
GROUP BY t.name, i.rows ORDER BY TongMB DESC;

-- Câu lệnh chạy lâu hơn 5 giây
SELECT r.session_id, r.total_elapsed_time / 1000 AS GiayDaChay,
    SUBSTRING(t.text, 1, 200) AS SQL
FROM sys.dm_exec_requests r
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) t
WHERE r.total_elapsed_time > 5000 AND r.session_id != @@SPID;
```

### Lịch bảo trì định kỳ

| Tác vụ | Tần suất | Lệnh |
|---|---|---|
| Rebuild/Reorganize Index | Hàng tuần | `EXEC dbo.sp_BaoTriIndex;` |
| Làm mới cache dashboard | Hàng ngày | `EXEC dbo.sp_LamMoiCacheDoanhThu;` |
| Update Statistics | Hàng tuần | `UPDATE STATISTICS dbo.RepairTickets WITH FULLSCAN;` |
| Xác minh backup | Hàng tuần | `RESTORE VERIFYONLY FROM DISK = ...` |

---

## 9. XỬ LÝ SỰ CỐ THƯỜNG GẶP

### Sự cố 1: Port 5055 đã bị chiếm
```powershell
netstat -ano | findstr :5055      # Tìm PID
taskkill /PID <PID> /F            # Dừng tiến trình
```

### Sự cố 2: Lỗi kết nối SQL Server
```powershell
Get-Service -Name "MSSQLSERVER"           # Kiểm tra service
Start-Service -Name "MSSQLSERVER"         # Khởi động nếu chưa chạy
sqlcmd -S . -Q "SELECT @@VERSION"         # Test kết nối
```
→ API tự chuyển sang dữ liệu in-memory (AppData) khi không kết nối được DB. Kiểm tra tại `/api/db/status`.

### Sự cố 3: Lỗi 401 Unauthorized
- Token hết hạn (> 8 giờ) → Đăng nhập lại
- Sai header: phải dùng `X-Session-Token` (không phải `Authorization: Bearer`)
- Server restart → Dữ liệu in-memory bị xóa → Đăng nhập lại

### Sự cố 4: Web Admin không tải dữ liệu
1. F12 → tab Network → xem request lỗi
2. Đảm bảo API đang chạy tại `http://localhost:5055`
3. Đăng nhập lại để lấy token mới

---

## 10. CHECKLIST TRIỂN KHAI PRODUCTION

### 🔐 Bảo mật
- [ ] Đổi toàn bộ mật khẩu tài khoản demo
- [ ] Cài BCrypt hash cho mật khẩu
- [ ] Giới hạn CORS về domain cụ thể
- [ ] Thêm Security Headers HTTP
- [ ] Bật HTTPS với SSL certificate
- [ ] Bảo vệ `/api/db/status` bằng xác thực
- [ ] Thêm Rate Limiting chống brute-force

### 🗄️ Database
- [ ] Chạy đầy đủ tất cả script `database/` theo đúng thứ tự
- [ ] Đổi mật khẩu tài khoản SQL Server SA
- [ ] Tạo SQL Agent Job bảo trì index hàng tuần
- [ ] Cấu hình lịch backup tự động

### 🚀 Backend API
- [ ] Đặt `ASPNETCORE_ENVIRONMENT=Production`
- [ ] Cấu hình logging ra file
- [ ] Đặt phía sau Nginx / IIS reverse proxy
- [ ] Cấu hình tự restart khi crash

### ✅ Kiểm thử cuối
- [ ] Chạy `tests/QLDACNTT_Api_Tests.http` toàn bộ
- [ ] Xác nhận 4 vai trò hoạt động đúng
- [ ] Kiểm tra luồng đầy đủ: Tạo phiếu → Xuất kho → Hóa đơn → Thanh toán → Bảo hành

---

## PHỤ LỤC: THÔNG TIN NHÓM PHÁT TRIỂN

| Thành viên | Vai trò | MSSV | Phụ trách |
|---|---|---|---|
| Nguyễn Viết Lãm | PM / Backend Lead | 2380601183 | Backend API, Kiến trúc |
| Trần Ngọc Lợi | BA / Database Lead | 2380601292 | Database, Stored Procedures |
| Nguyễn Đại Kỳ | UI/UX / QA Lead | 2380601178 | Web Admin, Kiểm thử |

**Repository:** https://github.com/Nguyen-Viet-Lam/QLDACNTT  
**Lớp:** 23DTHC6 | **Nhóm:** 11

---
*Tài liệu soạn ngày 17/10/2026 – Nhóm 11 – Môn QLDACNTT*

---

## 11. HUONG DAN TRIEN KHAI PRODUCTION (STEP BY STEP)

> Danh cho moi truong thuc te - khong can thuc hien trong hoc thuat.

### Buoc 1 - Chuan bi server
```powershell
# Kiem tra .NET Runtime da cai chua
dotnet --version   # Can >= 8.0

# Kiem tra SQL Server
Get-Service -Name MSSQLSERVER
```

### Buoc 2 - Publish ung dung
```bash
cd src/backend
dotnet publish -c Release -o ./publish --self-contained false
```

### Buoc 3 - Dat bien moi truong Production
```powershell
[System.Environment]::SetEnvironmentVariable(
    "ASPNETCORE_ENVIRONMENT", "Production", "Machine")
[System.Environment]::SetEnvironmentVariable(
    "ConnectionStrings__DefaultConnection",
    "Server=.;Database=RepairShopDB;Integrated Security=True;TrustServerCertificate=True",
    "Machine")
```

### Buoc 4 - Cai dat Windows Service (tu khoi dong cung may)
```powershell
sc.exe create "QLDACNTT-API" `
    binpath="dotnet d:\deploy\publish\backend.dll" `
    start=auto `
    DisplayName="QLDACNTT Repair Shop API"
Start-Service -Name "QLDACNTT-API"
Get-Service  -Name "QLDACNTT-API"
```

### Buoc 5 - Xac nhan sau trien khai
```bash
curl http://localhost:5055/health
curl http://localhost:5055/api/db/status
```

---

## 12. SCRIPT GIAM SAT TU DONG

### Health Check PowerShell (chay theo lich - Task Scheduler)
```powershell
# Luu file: C:\Scripts\healthcheck_qldacntt.ps1
param([string]$ApiUrl = "http://localhost:5055/health")
$logFile = "C:\Logs\QLDACNTT\hc_$(Get-Date -Format 'yyyyMMdd').log"
New-Item -ItemType Directory -Force -Path (Split-Path $logFile) | Out-Null
try {
    $r   = Invoke-RestMethod -Uri $ApiUrl -TimeoutSec 10
    $msg = "[OK]   $(Get-Date -Format 'HH:mm:ss') API=$($r.status) DB=$($r.database)"
} catch {
    $msg = "[FAIL] $(Get-Date -Format 'HH:mm:ss') $($_.Exception.Message)"
}
Add-Content -Path $logFile -Value $msg
Write-Host $msg
```

### Dang ky chay moi 5 phut
```powershell
$action  = New-ScheduledTaskAction -Execute "powershell.exe" `
               -Argument "-File C:\Scripts\healthcheck_qldacntt.ps1"
$trigger = New-ScheduledTaskTrigger -RepetitionInterval (New-TimeSpan -Minutes 5) `
               -Once -At (Get-Date)
Register-ScheduledTask -TaskName "QLDACNTT-HealthCheck" `
    -Action $action -Trigger $trigger -RunLevel Highest
```

---

**Phien ban tai lieu:** v1.1 - Hoan thien Sprint 5 (17/10/2026)
