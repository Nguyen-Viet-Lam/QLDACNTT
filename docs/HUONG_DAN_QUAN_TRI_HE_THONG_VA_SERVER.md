# TÀI LIỆU QUẢN TRỊ HỆ THỐNG VÀ CẤU HÌNH MÁY CHỦ (SERVER DEPLOYMENT MANUAL)

**Đề tài:** Hệ thống Quản lý Tổng thể cho Cửa hàng Sửa chữa - LV33-001  
**Đơn vị thực hiện:** Nhóm 11 - Lớp 23DTHC6  
**Chịu trách nhiệm kỹ thuật & Quản trị hệ thống:** Nguyễn Viết Lãm (Project Manager & Backend/DevOps Lead)  
**Ngày phát hành:** 17/10/2026  
**Mã công việc Jira:** MBA-82 (Soạn tài liệu quản trị hệ thống và cấu hình server)  

---

## 1. TỔNG QUAN KIẾN TRÚC HỆ THỐNG

Hệ thống quản lý cửa hàng sửa chữa TechCare được xây dựng theo mô hình kiến trúc phân tầng (Multi-tier Architecture) hiện đại, hỗ trợ đóng gói container hóa (Docker) và tự động hóa CI/CD.

```
       [ Client: Web Browser / Mobile ]
                     │ (Port 80 / 443)
                     ▼
  ┌─────────────────────────────────────┐
  │   Nginx Reverse Proxy & Static Host │ (techcare_web_admin)
  │   - Phục vụ Web Admin Dashboard SPA │
  │   - Định tuyến /api sang Backend    │
  └──────────────────┬──────────────────┘
                     │ (Internal Port 8080)
                     ▼
  ┌─────────────────────────────────────┐
  │   ASP.NET Core 8 Minimal API        │ (techcare_backend)
  │   - Xử lý nghiệp vụ, Auth, RBAC     │
  │   - Fallback In-Memory AppData      │
  └──────────────────┬──────────────────┘
                     │ (Internal Port 1433)
                     ▼
  ┌─────────────────────────────────────┐
  │   Microsoft SQL Server 2022         │ (techcare_mssql)
  │   - Cơ sở dữ liệu RepairShopDB      │
  │   - Persistent Volume mssql_data    │
  └─────────────────────────────────────┘
```

---

## 2. YÊU CẦU CẤU HÌNH MÁY CHỦ (SYSTEM REQUIREMENTS)

### 2.1. Yêu cầu phần cứng tối thiểu & khuyến nghị

| Thông số | Cấu hình tối thiểu (Staging / Dev) | Cấu hình khuyến nghị (Production) |
|---|---|---|
| **CPU** | 2 vCPU (2.0 GHz trở lên) | 4 vCPU (2.8 GHz trở lên) |
| **RAM** | 4 GB | 8 GB - 16 GB (dành cho SQL Server) |
| **Ổ cứng** | 40 GB SSD trống | 120 GB SSD NVMe (RAID 1/10 khuyến nghị) |
| **Băng thông mạng** | 100 Mbps | 1 Gbps kèm IP tĩnh |

### 2.2. Yêu cầu hệ điều hành & phần mềm máy chủ
- **Hệ điều hành:**
  - Ubuntu Server 22.04 LTS / 24.04 LTS (Khuyến nghị cho triển khai Docker)
  - Hoặc Windows Server 2022 / Windows 11 Pro (với WSL2 & Hyper-V)
- **Công cụ nền tảng:**
  - Docker Engine v24.0+ & Docker Compose v2.20+
  - .NET 8.0 Runtime / ASP.NET Core Runtime (khi chạy không dùng Docker)
  - Microsoft SQL Server 2022 Standard / Developer Edition
  - Git client để đồng bộ mã nguồn

---

## 3. CÀI ĐẶT MÔI TRƯỜNG MÁY CHỦ VÀ DOCKER

### 3.1. Cài đặt trên máy chủ Linux Ubuntu
```bash
# Cập nhật hệ thống
sudo apt update && sudo apt upgrade -y

# Cài đặt các gói phụ trợ
sudo apt install -y ca-certificates curl gnupg lsb-release git

# Cài đặt Docker và Docker Compose Plugin
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Khởi động dịch vụ Docker
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker $USER
```

### 3.2. Cài đặt trên máy chủ Windows Server
1. Cài đặt **Docker Desktop** (hoặc Mirantis Container Runtime cho Windows Server).
2. Kích hoạt tính năng **Hyper-V** và **Containers** trong `Turn Windows features on or off`.
3. Kiểm tra cài đặt thành công:
   ```powershell
   docker --version
   docker compose version
   ```

---

## 4. HƯỚNG DẪN TRIỂN KHAI BẰNG DOCKER COMPOSE (KHUYẾN NGHỊ)

Đây là phương thức triển khai chuẩn, tự động hóa toàn bộ việc dựng CSDL, Backend và Frontend trong 1 câu lệnh duy nhất.

### Bước 1: Sao chép mã nguồn về máy chủ
```bash
git clone https://github.com/Nguyen-Viet-Lam/QLDACNTT.git /opt/techcare-app
cd /opt/techcare-app
```

### Bước 2: Kiểm tra tệp cấu hình docker-compose.yml
Hệ thống sử dụng tệp `docker-compose.yml` tại thư mục gốc với 3 dịch vụ liên kết qua mạng `techcare_network`:
- `mssql`: CSDL SQL Server 2022 (SA Password: `TechCare@2026!Secure`, Port 1433)
- `backend`: ASP.NET Core 8 API (Port 5000 -> 8080 container)
- `web-admin`: Nginx phục vụ SPA giao diện quản trị (Port 80)

### Bước 3: Khởi chạy cụm dịch vụ
```bash
docker compose up -d --build
```

### Bước 4: Kiểm tra trạng thái các container
```bash
docker compose ps
```
Kết quả kỳ vọng:
```
NAME                 STATUS                   PORTS
techcare_mssql       Up (healthy)             0.0.0.0:1433->1433/tcp
techcare_backend     Up                       0.0.0.0:5000->8080/tcp
techcare_web_admin   Up                       0.0.0.0:80->80/tcp
```

### Bước 5: Khởi tạo dữ liệu CSDL lần đầu (Database Migration & Seed)
Nếu CSDL chưa có bảng, thực thi script SQL vào container `techcare_mssql`:
```bash
# Nạp schema và bảng
docker exec -i techcare_mssql /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P 'TechCare@2026!Secure' -C -i /dev/stdin < database/schema/01_create_database.sql
docker exec -i techcare_mssql /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P 'TechCare@2026!Secure' -d RepairShopDB -C -i /dev/stdin < database/schema/02_create_tables.sql

# Nạp dữ liệu danh mục và người dùng mẫu
docker exec -i techcare_mssql /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P 'TechCare@2026!Secure' -d RepairShopDB -C -i /dev/stdin < database/seed/01_seed_master_data.sql
docker exec -i techcare_mssql /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P 'TechCare@2026!Secure' -d RepairShopDB -C -i /dev/stdin < database/seed/02_seed_demo_tickets_and_users.sql
```

---

## 5. HƯỚNG DẪN TRIỂN KHAI THỦ CÔNG KHÔNG DÙNG DOCKER

Dành cho môi trường Windows Server chạy IIS hoặc dịch vụ Windows Service:

### Bước 1: Chuẩn bị CSDL SQL Server
1. Mở **SQL Server Management Studio (SSMS)** kết nối vào SQL Server địa phương.
2. Chạy lần lượt các file script theo thứ tự:
   - `database/schema/01_create_database.sql`
   - `database/schema/02_create_tables.sql`
   - `database/seed/01_seed_master_data.sql`
   - `database/seed/02_seed_demo_tickets_and_users.sql`

### Bước 2: Cấu hình chuỗi kết nối trong appsettings.json
Chỉnh sửa file `src/backend/appsettings.json`:
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost;Database=RepairShopDB;User Id=sa;Password=TechCare@2026!Secure;TrustServerCertificate=True;Connect Timeout=30;"
  },
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*"
}
```

### Bước 3: Build và publish Backend API
```powershell
dotnet publish src/backend/QLDACNTT.Api.csproj -c Release -o C:\inetpub\techcare-api
```

### Bước 4: Cấu hình IIS hoặc chạy trực tiếp
```powershell
# Chạy trực tiếp qua dotnet
cd C:\inetpub\techcare-api
dotnet QLDACNTT.Api.dll --urls="http://0.0.0.0:5000"
```

---

## 6. CẤU HÌNH PHÂN QUYỀN VÀ BẢO MẬT HỆ THỐNG (RBAC)

### 6.1. Ma trận phân quyền 4 vai trò (RBAC)
Hệ thống thiết lập 4 cấp bậc tài khoản chặt chẽ theo tiêu chuẩn bảo mật:

| Vai trò (Role) | Chức năng được phép truy cập | Tài khoản mặc định |
|---|---|---|
| **ADMIN** | Toàn quyền cấu hình hệ thống, quản lý tài khoản, xem dashboard doanh thu, báo cáo tổng thể | `admin` / `123456` |
| **STAFF** | Tiếp nhận máy, tạo phiếu sửa chữa, in biên nhận, lập hóa đơn thanh toán và xuất kho | `staff` / `123456` |
| **TECHNICIAN** | Xem phiếu phân công, cập nhật chẩn đoán lỗi, yêu cầu xuất linh kiện, hoàn thành sửa chữa | `tech` / `123456` |
| **CUSTOMER** | Tra cứu tiến độ phiếu sửa chữa của cá nhân, kiểm tra thời hạn bảo hành điện tử | `customer` / `123456` |

### 6.2. Cơ chế xác thực Session Token
- Sau khi đăng nhập thành công qua endpoint `POST /api/auth/login`, hệ thống cấp một mã định danh ngẫu nhiên dạng GUID: `X-Session-Token`.
- Mọi request vào các endpoint được bảo vệ đều phải đính kèm Header:
  ```http
  X-Session-Token: <Token-Cua-Phien>
  ```
- Token có thời hạn mặc định là 8 giờ làm việc. Nếu quá hạn hoặc đăng xuất (`POST /api/auth/logout`), token tự động bị hủy khỏi bộ nhớ.

---

## 7. GIÁM SÁT HỆ THỐNG VÀ HEALTH CHECKS

Quản trị viên có thể giám sát trạng thái sức khỏe của ứng dụng thông qua các endpoint chuyên dụng:

### 7.1. Liveness Probe (Kiểm tra Backend còn hoạt động)
```bash
curl -s http://localhost:5000/health
```
Phản hồi:
```json
{
  "status": "ok",
  "checkedAt": "2026-10-17T17:40:00Z"
}
```

### 7.2. Database Readiness Probe (Kiểm tra kết nối CSDL SQL Server)
```bash
curl -s http://localhost:5000/api/db/status
```
Phản hồi khi kết nối CSDL thành công:
```json
{
  "status": "CONNECTED",
  "database": "RepairShopDB",
  "server": "Localhost SQL Server (MSSQLSERVER)",
  "tables": 13,
  "usersInDb": 10,
  "ticketsInDb": 8,
  "sparePartsInDb": 15,
  "sqlVersion": "Microsoft SQL Server 2022",
  "checkedAt": "2026-10-17T17:40:00Z"
}
```
*Lưu ý:* Nếu mất kết nối CSDL, hệ thống tự động chuyển sang chế độ an toàn `FALLBACK_IN_MEMORY` để không làm gián đoạn tạm thời quá trình tra cứu.

---

## 8. QUY TRÌNH SAO LƯU DỰ PHÒNG CSDL (BACKUP & RESTORE)

### 8.1. Lập lịch sao lưu tự động hàng ngày (Daily Backup)
Tạo script sao lưu tự động `backup_database.sh` trên máy chủ:
```bash
#!/bin/bash
BACKUP_DIR="/opt/techcare-backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
mkdir -p $BACKUP_DIR

# Sao lưu cơ sở dữ liệu qua sqlcmd
docker exec techcare_mssql /opt/mssql-tools18/bin/sqlcmd \
  -S localhost -U sa -P 'TechCare@2026!Secure' -C \
  -Q "BACKUP DATABASE [RepairShopDB] TO DISK = N'/var/opt/mssql/data/RepairShopDB_${TIMESTAMP}.bak' WITH NOFORMAT, NOINIT, SKIP, NOREWIND, NOUNLOAD, STATS = 10"

# Copy file .bak ra ngoài máy chủ vật lý
docker cp techcare_mssql:/var/opt/mssql/data/RepairShopDB_${TIMESTAMP}.bak $BACKUP_DIR/

# Xóa các bản sao lưu cũ hơn 30 ngày
find $BACKUP_DIR -type f -name "*.bak" -mtime +30 -exec rm {} \;
```

Cấu hình crontab chạy vào lúc 02:00 sáng mỗi ngày:
```bash
0 2 * * * /opt/techcare-app/tools/backup_database.sh >> /var/log/techcare_backup.log 2>&1
```

### 8.2. Quy trình phục hồi CSDL khi gặp sự cố
```bash
docker exec -i techcare_mssql /opt/mssql-tools18/bin/sqlcmd \
  -S localhost -U sa -P 'TechCare@2026!Secure' -C \
  -Q "ALTER DATABASE [RepairShopDB] SET SINGLE_USER WITH ROLLBACK IMMEDIATE; RESTORE DATABASE [RepairShopDB] FROM DISK = N'/var/opt/mssql/data/RepairShopDB_20261017_020000.bak' WITH REPLACE; ALTER DATABASE [RepairShopDB] SET MULTI_USER;"
```

---

## 9. QUY TRÌNH CI/CD GITHUB ACTIONS

Mọi thay đổi mã nguồn được kiểm soát và tự động kiểm thử qua tệp workflow `.github/workflows/ci-cd.yml`:
1. **Kiểm tra cú pháp & biên dịch:** Chạy `dotnet restore` và `dotnet build --configuration Release` trên máy ảo Ubuntu.
2. **Kiểm thử tự động (Unit Test):** Thực thi toàn bộ bộ kiểm thử trong `tests/QLDACNTT.Tests` bằng `dotnet test`. Báo cáo độ bao phủ mã nguồn.
3. **Đóng gói Docker:** Tự động build và xác thực tính hợp lệ của `Dockerfile` backend và `Dockerfile` frontend, kiểm tra cấu hình `docker compose config`.
4. Chỉ khi toàn bộ các bước trên hoàn thành với trạng thái **Passed (Xanh)**, mã nguồn mới được phép hợp nhất vào nhánh `main`.

---

## 10. XỬ LÝ SỰ CỐ THƯỜNG GẶP (TROUBLESHOOTING)

| Hiện tượng | Nguyên nhân có thể | Hướng khắc phục |
|---|---|---|
| Không truy cập được giao diện cổng 80 | Trùng cổng 80 hoặc Nginx chưa khởi động | Kiểm tra cổng bằng `sudo netstat -tulpn \| grep 80`. Đổi cổng ánh xạ trong `docker-compose.yml` thành `8080:80` nếu cần. |
| API trả về lỗi `FALLBACK_IN_MEMORY` | Container SQL Server chưa sẵn sàng hoặc sai mật khẩu SA | Kiểm tra log CSDL: `docker logs techcare_mssql`. Đảm bảo chuỗi kết nối trong `appsettings.json` hoặc biến môi trường đúng mật khẩu SA. |
| Lỗi 401 Unauthorized liên tục | Token phiên làm việc hết hạn sau 8 giờ | Đăng xuất và đăng nhập lại để nhận token mới. Kiểm tra xem header `X-Session-Token` đã được gửi kèm request hay chưa. |
| Container backend bị crash loop | Lỗi cấu hình .NET hoặc thiếu thư viện | Chạy `docker logs techcare_backend` để xem stack trace ngoại lệ chi tiết. |

---

*Tài liệu được biên soạn bởi Nguyễn Viết Lãm - Nhóm 11 (23DTHC6) nhằm chuẩn hóa quy trình chuyển giao và vận hành đồ án Quản lý dự án CNTT.*
