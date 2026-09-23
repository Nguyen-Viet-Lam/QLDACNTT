# Thiết kế cơ sở dữ liệu — LV33-001

**Phụ trách:** Trần Ngọc Lợi (Database)
**CSDL:** Microsoft SQL Server — `RepairShopDB` — Collation `Vietnamese_CI_AS`
**Số bảng:** 13

Script tạo bảng: [database/schema/02_create_tables.sql](../../database/schema/02_create_tables.sql)

## 1. Sơ đồ quan hệ (ERD dạng văn bản)

```
Roles ──1:N──> Users
                 │
                 ├──1:N──> RepairTickets (ReceivedByUserId)
                 ├──1:N──> RepairTickets (TechnicianUserId)
                 ├──1:N──> TicketStatusHistory
                 ├──1:N──> StockTransactions
                 └──1:N──> Invoices

Customers ──1:N──> Devices
    │                 │
    │                 └──1:N──> RepairTickets
    ├──1:N──> RepairTickets
    ├──1:N──> Invoices
    └──1:N──> Warranties

ServiceTypes ──1:N──> RepairTickets

RepairTickets ──1:N──> TicketStatusHistory
    ├──1:N──> TicketParts
    ├──1:N──> StockTransactions
    ├──1:1──> Invoices
    ├──1:N──> Warranties
    └──1:N──> RepairTickets (OriginalTicketId — tự tham chiếu cho phiếu bảo hành)

SparePartCategories ──1:N──> SpareParts
                                 │
                                 ├──1:N──> TicketParts
                                 └──1:N──> StockTransactions
```

## 2. Từ điển dữ liệu

### 2.1 `Roles` — Vai trò người dùng

| Cột | Kiểu | Ràng buộc | Mô tả |
|---|---|---|---|
| RoleId | INT | PK, IDENTITY | Khóa chính |
| RoleCode | VARCHAR(20) | NOT NULL, UNIQUE | Mã vai trò: ADMIN, STAFF, TECHNICIAN, CUSTOMER |
| RoleName | NVARCHAR(50) | NOT NULL | Tên hiển thị |
| Description | NVARCHAR(200) | NULL | Diễn giải |
| IsActive | BIT | NOT NULL, DEFAULT 1 | Còn hiệu lực |
| CreatedAt | DATETIME2 | NOT NULL, DEFAULT | Thời điểm tạo |

### 2.2 `Users` — Người dùng hệ thống

| Cột | Kiểu | Ràng buộc | Mô tả |
|---|---|---|---|
| UserId | INT | PK, IDENTITY | Khóa chính |
| RoleId | INT | FK → Roles | Vai trò |
| Username | VARCHAR(50) | NOT NULL, UNIQUE | Tên đăng nhập |
| PasswordHash | VARCHAR(255) | NOT NULL | Mật khẩu băm BCrypt |
| FullName | NVARCHAR(100) | NOT NULL | Họ tên |
| Email | VARCHAR(100) | NULL | Email |
| Phone | VARCHAR(20) | NULL | Số điện thoại |
| IsActive | BIT | NOT NULL, DEFAULT 1 | 0 = đã khóa |
| LastLoginAt | DATETIME2 | NULL | Lần đăng nhập gần nhất |

### 2.3 `Customers` — Khách hàng

| Cột | Kiểu | Ràng buộc | Mô tả |
|---|---|---|---|
| CustomerId | INT | PK, IDENTITY | Khóa chính |
| CustomerCode | VARCHAR(20) | NOT NULL, UNIQUE | Mã tự sinh `KH000001` |
| FullName | NVARCHAR(100) | NOT NULL | Họ tên |
| Phone | VARCHAR(20) | NOT NULL, INDEX | Số điện thoại, dùng để tra cứu |
| Email | VARCHAR(100) | NULL | Email |
| Address | NVARCHAR(255) | NULL | Địa chỉ |
| IsActive | BIT | NOT NULL, DEFAULT 1 | Xóa mềm |

### 2.4 `Devices` — Thiết bị của khách

| Cột | Kiểu | Ràng buộc | Mô tả |
|---|---|---|---|
| DeviceId | INT | PK, IDENTITY | Khóa chính |
| CustomerId | INT | FK → Customers | Chủ thiết bị |
| DeviceType | NVARCHAR(50) | NOT NULL | Điện thoại, Laptop, Máy in... |
| Brand | NVARCHAR(50) | NULL | Hãng |
| Model | NVARCHAR(100) | NULL | Dòng máy |
| SerialNumber | VARCHAR(100) | NULL, INDEX | Số serial, dùng tra cứu bảo hành |

### 2.5 `ServiceTypes` — Loại dịch vụ & biểu giá

| Cột | Kiểu | Ràng buộc | Mô tả |
|---|---|---|---|
| ServiceTypeId | INT | PK, IDENTITY | Khóa chính |
| ServiceCode | VARCHAR(20) | NOT NULL, UNIQUE | Mã dịch vụ |
| ServiceName | NVARCHAR(100) | NOT NULL | Tên dịch vụ |
| LaborCost | DECIMAL(18,2) | NOT NULL, CHECK ≥ 0 | Tiền công |
| WarrantyDays | INT | NOT NULL, CHECK ≥ 0 | Số ngày bảo hành mặc định |

### 2.6 `RepairTickets` — Phiếu sửa chữa

| Cột | Kiểu | Ràng buộc | Mô tả |
|---|---|---|---|
| TicketId | INT | PK, IDENTITY | Khóa chính |
| TicketCode | VARCHAR(20) | NOT NULL, UNIQUE | Mã tự sinh `PSC2026100001` |
| CustomerId | INT | FK → Customers | Khách hàng |
| DeviceId | INT | FK → Devices | Thiết bị |
| ServiceTypeId | INT | FK → ServiceTypes, NULL | Loại dịch vụ |
| ReceivedByUserId | INT | FK → Users | Nhân viên tiếp nhận |
| TechnicianUserId | INT | FK → Users, NULL | Kỹ thuật viên được phân công |
| Status | VARCHAR(30) | NOT NULL, CHECK, INDEX | 7 trạng thái, xem [API Spec](API-Specification.md) |
| DeviceCondition | NVARCHAR(1000) | NULL | Tình trạng thiết bị lúc nhận |
| Diagnosis | NVARCHAR(1000) | NULL | Kết quả chẩn đoán |
| QuotedLaborCost | DECIMAL(18,2) | NOT NULL, DEFAULT 0 | Tiền công báo giá |
| QuotedPartsCost | DECIMAL(18,2) | NOT NULL, DEFAULT 0 | Tiền linh kiện |
| QuotedTotal | DECIMAL | COMPUTED, PERSISTED | `QuotedLaborCost + QuotedPartsCost` |
| IsWarrantyRepair | BIT | NOT NULL, DEFAULT 0 | Là phiếu sửa bảo hành |
| OriginalTicketId | INT | FK → RepairTickets, NULL | Phiếu gốc nếu sửa bảo hành |

> `QuotedTotal` là cột tính toán (computed column) có `PERSISTED` nên luôn khớp với hai cột thành phần, không thể ghi sai từ tầng ứng dụng.

### 2.7 `TicketStatusHistory` — Lịch sử trạng thái

| Cột | Kiểu | Ràng buộc | Mô tả |
|---|---|---|---|
| HistoryId | INT | PK, IDENTITY | Khóa chính |
| TicketId | INT | FK → RepairTickets, INDEX | Phiếu |
| FromStatus | VARCHAR(30) | NULL | Trạng thái trước (NULL khi mới lập) |
| ToStatus | VARCHAR(30) | NOT NULL | Trạng thái sau |
| ChangedByUserId | INT | FK → Users | Người thực hiện |
| ChangedAt | DATETIME2 | NOT NULL, DEFAULT | Thời điểm |

### 2.8 `SparePartCategories` — Nhóm linh kiện

| Cột | Kiểu | Ràng buộc | Mô tả |
|---|---|---|---|
| CategoryId | INT | PK, IDENTITY | Khóa chính |
| CategoryName | NVARCHAR(100) | NOT NULL | Tên nhóm |

### 2.9 `SpareParts` — Linh kiện

| Cột | Kiểu | Ràng buộc | Mô tả |
|---|---|---|---|
| PartId | INT | PK, IDENTITY | Khóa chính |
| PartCode | VARCHAR(30) | NOT NULL, UNIQUE | Mã tự sinh `LK00001` |
| CategoryId | INT | FK → SparePartCategories | Nhóm |
| PartName | NVARCHAR(150) | NOT NULL, INDEX | Tên linh kiện |
| Unit | NVARCHAR(20) | NOT NULL | Đơn vị: Cái, Thanh, Hộp... |
| PurchasePrice | DECIMAL(18,2) | NOT NULL, CHECK ≥ 0 | Giá nhập |
| SellingPrice | DECIMAL(18,2) | NOT NULL, CHECK ≥ 0 | Giá bán |
| StockQuantity | INT | NOT NULL, CHECK ≥ 0 | Tồn kho hiện tại |
| MinStockLevel | INT | NOT NULL, CHECK ≥ 0 | Mức tồn tối thiểu để cảnh báo |
| WarrantyDays | INT | NOT NULL | Số ngày bảo hành của linh kiện |

> `CHECK (StockQuantity >= 0)` là lớp bảo vệ cuối: kể cả khi tầng ứng dụng có lỗi logic, CSDL vẫn không cho tồn kho âm.

### 2.10 `StockTransactions` — Giao dịch kho

| Cột | Kiểu | Ràng buộc | Mô tả |
|---|---|---|---|
| TransactionId | INT | PK, IDENTITY | Khóa chính |
| PartId | INT | FK → SpareParts, INDEX | Linh kiện |
| TransactionType | VARCHAR(20) | NOT NULL, CHECK | IN, OUT, ADJUST, RETURN |
| Quantity | INT | NOT NULL, CHECK > 0 | Số lượng, luôn dương |
| StockBefore | INT | NOT NULL | Tồn trước giao dịch |
| StockAfter | INT | NOT NULL | Tồn sau giao dịch |
| TicketId | INT | FK → RepairTickets, NULL | Phiếu liên quan nếu là xuất |
| PerformedByUserId | INT | FK → Users | Người thực hiện |
| TransactionAt | DATETIME2 | NOT NULL, INDEX | Thời điểm |

> Bảng này là sổ ghi vết (audit trail) của kho. Lưu cả `StockBefore` và `StockAfter` để khi đối soát có thể phát hiện ngay giao dịch nào làm lệch tồn.

### 2.11 `TicketParts` — Linh kiện dùng cho phiếu

| Cột | Kiểu | Ràng buộc | Mô tả |
|---|---|---|---|
| TicketPartId | INT | PK, IDENTITY | Khóa chính |
| TicketId | INT | FK → RepairTickets, INDEX | Phiếu |
| PartId | INT | FK → SpareParts, INDEX | Linh kiện |
| Quantity | INT | NOT NULL, CHECK > 0 | Số lượng |
| UnitPrice | DECIMAL(18,2) | NOT NULL, CHECK ≥ 0 | Giá bán tại thời điểm xuất |
| LineTotal | DECIMAL | COMPUTED, PERSISTED | `Quantity * UnitPrice` |

> `UnitPrice` được lưu lại (snapshot) thay vì tham chiếu sang `SpareParts.SellingPrice`. Nhờ vậy khi Admin đổi giá linh kiện, các phiếu và hóa đơn cũ không bị thay đổi theo.

### 2.12 `Invoices` — Hóa đơn

| Cột | Kiểu | Ràng buộc | Mô tả |
|---|---|---|---|
| InvoiceId | INT | PK, IDENTITY | Khóa chính |
| InvoiceCode | VARCHAR(20) | NOT NULL, UNIQUE | Mã tự sinh `HD2026100001` |
| TicketId | INT | FK → RepairTickets, **UNIQUE** | Mỗi phiếu một hóa đơn |
| CustomerId | INT | FK → Customers | Khách hàng |
| LaborCost | DECIMAL(18,2) | NOT NULL | Tiền công |
| PartsCost | DECIMAL(18,2) | NOT NULL | Tiền linh kiện |
| DiscountAmount | DECIMAL(18,2) | NOT NULL, CHECK ≥ 0 | Giảm giá |
| TotalAmount | DECIMAL | COMPUTED, PERSISTED | `LaborCost + PartsCost - DiscountAmount` |
| PaymentMethod | VARCHAR(20) | NOT NULL, CHECK | CASH, TRANSFER |
| PaymentStatus | VARCHAR(20) | NOT NULL, CHECK | UNPAID, PAID, REFUNDED |
| PaidAt | DATETIME2 | NULL | Thời điểm thanh toán |

> Ràng buộc `UNIQUE` trên `TicketId` là cách chặn lập hóa đơn hai lần cho cùng một phiếu ở mức CSDL, không phụ thuộc vào kiểm tra ở tầng ứng dụng.

### 2.13 `Warranties` — Phiếu bảo hành

| Cột | Kiểu | Ràng buộc | Mô tả |
|---|---|---|---|
| WarrantyId | INT | PK, IDENTITY | Khóa chính |
| WarrantyCode | VARCHAR(20) | NOT NULL, UNIQUE | Mã tự sinh `BH2026100001` |
| TicketId | INT | FK → RepairTickets, INDEX | Phiếu sửa chữa gốc |
| CustomerId | INT | FK → Customers, INDEX | Khách hàng |
| DeviceId | INT | FK → Devices | Thiết bị |
| StartDate | DATE | NOT NULL | Ngày bắt đầu |
| EndDate | DATE | NOT NULL, CHECK ≥ StartDate, INDEX | Ngày hết hạn |
| WarrantyDays | INT | NOT NULL | Số ngày bảo hành |
| Status | VARCHAR(20) | NOT NULL, CHECK | ACTIVE, EXPIRED, VOID, USED |

## 3. Quy ước sinh mã

| Loại | Định dạng | Ví dụ | Cách sinh |
|---|---|---|---|
| Khách hàng | `KH` + 6 số | `KH000042` | Số thứ tự tăng dần |
| Phiếu sửa chữa | `PSC` + yyyyMM + 4 số | `PSC2026100048` | Reset số thứ tự mỗi tháng |
| Hóa đơn | `HD` + yyyyMM + 4 số | `HD2026100031` | Reset số thứ tự mỗi tháng |
| Bảo hành | `BH` + yyyyMM + 4 số | `BH2026100029` | Reset số thứ tự mỗi tháng |
| Linh kiện | `LK` + 5 số | `LK00017` | Số thứ tự tăng dần |

## 4. Ghi chú thiết kế

**Vì sao không lưu tổng tiền phiếu thành cột thường:** Ba cột `QuotedTotal`, `LineTotal`, `TotalAmount` đều là computed column có `PERSISTED`. Cách này vừa nhanh khi truy vấn (giá trị được lưu thật, có thể đánh index) vừa không bao giờ lệch với các cột thành phần.

**Vì sao tách `TicketParts` và `StockTransactions`:** `TicketParts` trả lời câu hỏi "phiếu này dùng những linh kiện gì" phục vụ lập hóa đơn. `StockTransactions` trả lời "tồn kho biến động thế nào" phục vụ đối soát. Một lần xuất linh kiện ghi vào cả hai bảng, nhưng khi hoàn trả thì `TicketParts` bị xóa dòng còn `StockTransactions` thêm dòng `RETURN` — giữ nguyên dấu vết.

**Vì sao `RepairTickets` tự tham chiếu:** Phiếu sửa bảo hành là một phiếu sửa chữa đầy đủ, chỉ khác là miễn tiền công và trỏ về phiếu gốc qua `OriginalTicketId`. Cách này tránh phải tạo thêm một bảng gần như trùng lặp.

**Xóa mềm:** `Customers`, `SpareParts`, `Users`, `Roles`, `ServiceTypes` đều có cột `IsActive`. Không xóa cứng vì các bản ghi này bị tham chiếu bởi dữ liệu lịch sử.
