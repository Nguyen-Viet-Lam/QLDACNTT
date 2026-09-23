# Đặc tả API — LV33-001

**Phụ trách:** Nguyễn Viết Lãm
**Base URL:** `https://localhost:7001/api`
**Xác thực:** JWT Bearer token, gửi ở header `Authorization: Bearer <token>`

## 1. Quy ước chung

### Định dạng response

Mọi endpoint trả về cùng một cấu trúc:

```json
{
  "success": true,
  "data": { },
  "message": "Thành công",
  "errors": null
}
```

Khi lỗi:

```json
{
  "success": false,
  "data": null,
  "message": "Số lượng linh kiện trong kho không đủ",
  "errors": [
    { "field": "quantity", "code": "INSUFFICIENT_STOCK", "detail": "Tồn hiện tại: 3, yêu cầu: 5" }
  ]
}
```

### Mã HTTP dùng trong dự án

| Mã | Khi nào dùng |
|---|---|
| 200 | Thành công (GET, PUT, PATCH) |
| 201 | Tạo mới thành công (POST) |
| 400 | Dữ liệu gửi lên sai định dạng hoặc vi phạm quy tắc nghiệp vụ |
| 401 | Chưa đăng nhập hoặc token hết hạn |
| 403 | Đã đăng nhập nhưng không đủ quyền |
| 404 | Không tìm thấy tài nguyên |
| 409 | Xung đột (trùng mã, lập hóa đơn 2 lần cho 1 phiếu) |
| 500 | Lỗi hệ thống |

### Mã lỗi nghiệp vụ

| Mã | Ý nghĩa |
|---|---|
| `INVALID_CREDENTIALS` | Sai tên đăng nhập hoặc mật khẩu |
| `ACCOUNT_LOCKED` | Tài khoản đã bị khóa |
| `DUPLICATE_PHONE` | Số điện thoại khách hàng đã tồn tại |
| `INSUFFICIENT_STOCK` | Tồn kho không đủ để xuất |
| `INVALID_STATUS_TRANSITION` | Chuyển trạng thái phiếu không hợp lệ |
| `TICKET_NOT_COMPLETED` | Phiếu chưa hoàn tất, không thể lập hóa đơn |
| `INVOICE_ALREADY_EXISTS` | Phiếu đã có hóa đơn |
| `DISCOUNT_EXCEEDS_TOTAL` | Giảm giá lớn hơn tổng tiền |
| `WARRANTY_EXPIRED` | Bảo hành đã hết hạn |
| `WARRANTY_ALREADY_USED` | Bảo hành đã được sử dụng |

### Phân trang

Tham số query: `?page=1&pageSize=20&sortBy=createdAt&sortDir=desc`

```json
{
  "success": true,
  "data": {
    "items": [ ],
    "page": 1,
    "pageSize": 20,
    "totalItems": 137,
    "totalPages": 7
  }
}
```

## 2. Vòng trạng thái phiếu sửa chữa

```
                    ┌──────────────┐
                    │   RECEIVED   │  Tiếp nhận
                    └──────┬───────┘
                           ▼
                    ┌──────────────┐
                    │  DIAGNOSING  │  Đang chẩn đoán
                    └──────┬───────┘
                           ▼
                  ┌──────────────────┐
                  │ WAITING_CONFIRM  │  Chờ khách xác nhận báo giá
                  └────┬─────────┬───┘
                       ▼         ▼
              ┌────────────┐  ┌───────────┐
              │ REPAIRING  │  │ CANCELLED │  Khách không đồng ý
              └─────┬──────┘  └───────────┘
                    ▼
              ┌────────────┐
              │ COMPLETED  │  Sửa xong, chờ khách nhận
              └─────┬──────┘
                    ▼
              ┌────────────┐
              │ DELIVERED  │  Đã bàn giao
              └────────────┘
```

### Bảng chuyển trạng thái hợp lệ

| Từ trạng thái | Được chuyển sang |
|---|---|
| `RECEIVED` | `DIAGNOSING`, `CANCELLED` |
| `DIAGNOSING` | `WAITING_CONFIRM`, `CANCELLED` |
| `WAITING_CONFIRM` | `REPAIRING`, `CANCELLED` |
| `REPAIRING` | `COMPLETED`, `CANCELLED` |
| `COMPLETED` | `DELIVERED` |
| `DELIVERED` | *(trạng thái cuối)* |
| `CANCELLED` | *(trạng thái cuối)* |

Mọi cặp chuyển khác trả về `400` với mã `INVALID_STATUS_TRANSITION`. Khi chuyển sang `CANCELLED`, hệ thống hoàn trả toàn bộ linh kiện đã xuất về kho.

## 3. Danh sách endpoint

### 3.1 Xác thực (`/auth`)

| Method | Endpoint | Mô tả | Quyền |
|---|---|---|---|
| POST | `/auth/login` | Đăng nhập, trả JWT | Công khai |
| POST | `/auth/customer-login` | Khách hàng đăng nhập bằng SĐT (mobile) | Công khai |
| GET | `/auth/me` | Thông tin người đang đăng nhập | Đã đăng nhập |
| POST | `/auth/change-password` | Đổi mật khẩu | Đã đăng nhập |

**`POST /auth/login`**

```json
// Request
{ "username": "admin", "password": "Abc@12345" }

// Response 200
{
  "success": true,
  "data": {
    "token": "eyJhbGciOi...",
    "expiresAt": "2026-09-23T12:00:00",
    "user": { "userId": 1, "fullName": "Chủ cửa hàng", "role": "ADMIN" }
  }
}
```

### 3.2 Người dùng (`/users`)

| Method | Endpoint | Mô tả | Quyền |
|---|---|---|---|
| GET | `/users` | Danh sách tài khoản (phân trang) | ADMIN |
| GET | `/users/{id}` | Chi tiết tài khoản | ADMIN |
| POST | `/users` | Tạo tài khoản, gán vai trò | ADMIN |
| PUT | `/users/{id}` | Cập nhật thông tin | ADMIN |
| PATCH | `/users/{id}/status` | Khóa / mở khóa tài khoản | ADMIN |
| GET | `/roles` | Danh sách vai trò | ADMIN |

### 3.3 Khách hàng & thiết bị (`/customers`, `/devices`)

| Method | Endpoint | Mô tả | Quyền |
|---|---|---|---|
| GET | `/customers` | Danh sách, tìm theo tên / SĐT | ADMIN, STAFF, TECHNICIAN |
| GET | `/customers/{id}` | Chi tiết kèm thiết bị | ADMIN, STAFF, TECHNICIAN |
| POST | `/customers` | Tạo khách hàng, tự sinh mã `KH000001` | ADMIN, STAFF |
| PUT | `/customers/{id}` | Cập nhật | ADMIN, STAFF |
| DELETE | `/customers/{id}` | Vô hiệu hóa (xóa mềm) | ADMIN |
| GET | `/customers/{id}/tickets` | Lịch sử phiếu của khách | ADMIN, STAFF, TECHNICIAN |
| GET | `/devices` | Danh sách thiết bị, tìm theo serial | ADMIN, STAFF, TECHNICIAN |
| POST | `/devices` | Thêm thiết bị cho khách | ADMIN, STAFF |
| PUT | `/devices/{id}` | Cập nhật thiết bị | ADMIN, STAFF |
| GET | `/devices/{id}/history` | Lịch sử sửa chữa của thiết bị | ADMIN, STAFF, TECHNICIAN |

### 3.4 Phiếu sửa chữa (`/repair-tickets`)

| Method | Endpoint | Mô tả | Quyền |
|---|---|---|---|
| GET | `/repair-tickets` | Danh sách, lọc theo trạng thái / KTV / khoảng ngày | ADMIN, STAFF, TECHNICIAN |
| GET | `/repair-tickets/{id}` | Chi tiết kèm linh kiện & lịch sử trạng thái | ADMIN, STAFF, TECHNICIAN |
| POST | `/repair-tickets` | Lập phiếu, tự sinh mã `PSC2026100001` | ADMIN, STAFF |
| PUT | `/repair-tickets/{id}/diagnosis` | Cập nhật chẩn đoán & báo giá | ADMIN, TECHNICIAN |
| PATCH | `/repair-tickets/{id}/status` | Chuyển trạng thái | ADMIN, STAFF, TECHNICIAN |
| PATCH | `/repair-tickets/{id}/assign` | Phân công kỹ thuật viên | ADMIN |
| POST | `/repair-tickets/{id}/cancel` | Hủy phiếu kèm lý do | ADMIN, STAFF |
| POST | `/repair-tickets/warranty` | Lập phiếu sửa bảo hành từ phiếu gốc | ADMIN, STAFF |
| GET | `/repair-tickets/{id}/history` | Lịch sử chuyển trạng thái | ADMIN, STAFF, TECHNICIAN |

**`POST /repair-tickets`**

```json
// Request
{
  "customerId": 5,
  "deviceId": 12,
  "serviceTypeId": 1,
  "deviceCondition": "Màn hình nứt góc trên phải, vỏ có vết xước, máy còn lên nguồn",
  "customerRequest": "Thay màn hình, giữ nguyên dữ liệu",
  "expectedFinishAt": "2026-10-08T17:00:00"
}

// Response 201
{
  "success": true,
  "data": { "ticketId": 48, "ticketCode": "PSC2026100048", "status": "RECEIVED" },
  "message": "Đã lập phiếu sửa chữa PSC2026100048"
}
```

### 3.5 Linh kiện & tồn kho (`/spare-parts`, `/inventory`)

| Method | Endpoint | Mô tả | Quyền |
|---|---|---|---|
| GET | `/spare-parts` | Danh sách linh kiện, tìm theo tên / nhóm | ADMIN, STAFF, TECHNICIAN |
| GET | `/spare-parts/{id}` | Chi tiết linh kiện | ADMIN, STAFF, TECHNICIAN |
| POST | `/spare-parts` | Thêm linh kiện, tự sinh mã `LK00001` | ADMIN |
| PUT | `/spare-parts/{id}` | Cập nhật thông tin & giá | ADMIN |
| GET | `/spare-parts/low-stock` | Danh sách dưới mức tồn tối thiểu | ADMIN, STAFF |
| GET | `/part-categories` | Danh sách nhóm linh kiện | Đã đăng nhập |
| POST | `/part-categories` | Thêm nhóm linh kiện | ADMIN |
| POST | `/inventory/stock-in` | Nhập kho | ADMIN |
| POST | `/inventory/issue-to-ticket` | Xuất linh kiện cho phiếu | ADMIN, TECHNICIAN |
| POST | `/inventory/return-from-ticket` | Hoàn trả linh kiện về kho | ADMIN, TECHNICIAN |
| GET | `/inventory/transactions` | Lịch sử giao dịch kho | ADMIN |

**`POST /inventory/issue-to-ticket`**

```json
// Request
{
  "ticketId": 48,
  "items": [
    { "partId": 1, "quantity": 1 },
    { "partId": 12, "quantity": 2 }
  ]
}

// Response 200 — toàn bộ xử lý trong một transaction
{
  "success": true,
  "data": {
    "ticketId": 48,
    "issuedItems": [
      { "partId": 1,  "partName": "Màn hình iPhone 11", "quantity": 1, "unitPrice": 1200000, "lineTotal": 1200000, "stockAfter": 11 },
      { "partId": 12, "partName": "Keo tản nhiệt MX-4", "quantity": 2, "unitPrice": 100000,  "lineTotal": 200000,  "stockAfter": 20 }
    ],
    "totalPartsCost": 1400000
  }
}

// Response 400 khi không đủ tồn
{
  "success": false,
  "message": "Số lượng linh kiện trong kho không đủ",
  "errors": [
    { "field": "items[0].quantity", "code": "INSUFFICIENT_STOCK", "detail": "Màn hình iPhone 11 — tồn: 0, yêu cầu: 1" }
  ]
}
```

### 3.6 Hóa đơn & thanh toán (`/invoices`)

| Method | Endpoint | Mô tả | Quyền |
|---|---|---|---|
| GET | `/invoices` | Danh sách, lọc theo trạng thái & ngày | ADMIN, STAFF |
| GET | `/invoices/{id}` | Chi tiết hóa đơn | ADMIN, STAFF |
| POST | `/invoices` | Lập hóa đơn từ phiếu COMPLETED | ADMIN, STAFF |
| POST | `/invoices/{id}/payment` | Ghi nhận thanh toán | ADMIN, STAFF |
| PATCH | `/invoices/{id}/discount` | Áp dụng giảm giá | ADMIN |

### 3.7 Bảo hành (`/warranties`)

| Method | Endpoint | Mô tả | Quyền |
|---|---|---|---|
| GET | `/warranties` | Danh sách phiếu bảo hành | ADMIN, STAFF |
| GET | `/warranties/lookup` | Tra cứu theo mã BH / mã phiếu / serial | ADMIN, STAFF, TECHNICIAN |
| GET | `/warranties/{id}/check` | Kiểm tra hiệu lực, trả số ngày còn lại | ADMIN, STAFF, TECHNICIAN |
| GET | `/warranties/expiring` | Sắp hết hạn trong 30 ngày | ADMIN |
| PATCH | `/warranties/{id}/void` | Vô hiệu bảo hành kèm lý do | ADMIN |

### 3.8 Báo cáo (`/reports`)

| Method | Endpoint | Mô tả | Quyền |
|---|---|---|---|
| GET | `/reports/dashboard` | Số liệu tổng quan cho dashboard | ADMIN |
| GET | `/reports/revenue/daily` | Doanh thu theo ngày | ADMIN |
| GET | `/reports/revenue/monthly` | Doanh thu theo tháng | ADMIN |
| GET | `/reports/tickets-by-status` | Số phiếu theo trạng thái | ADMIN, STAFF |
| GET | `/reports/top-parts` | Linh kiện tiêu thụ nhiều nhất | ADMIN |
| GET | `/reports/technician-performance` | Hiệu suất kỹ thuật viên | ADMIN |
| GET | `/reports/revenue-by-service` | Doanh thu theo loại dịch vụ | ADMIN |
| GET | `/reports/top-customers` | Khách hàng chi nhiều nhất | ADMIN |

### 3.9 Cổng khách hàng — Mobile (`/customer-portal`)

| Method | Endpoint | Mô tả | Quyền |
|---|---|---|---|
| GET | `/customer-portal/my-tickets` | Phiếu của khách đang đăng nhập | CUSTOMER |
| GET | `/customer-portal/my-tickets/{id}` | Chi tiết phiếu của mình | CUSTOMER |
| GET | `/customer-portal/my-warranties` | Phiếu bảo hành của mình | CUSTOMER |

> Nhóm endpoint này chỉ trả dữ liệu thuộc về khách hàng gắn với token. Backend lọc theo `customerId` lấy từ token, không nhận `customerId` từ client.

## 4. Ma trận phân quyền tổng hợp

| Nhóm chức năng | ADMIN | STAFF | TECHNICIAN | CUSTOMER |
|---|---|---|---|---|
| Quản lý tài khoản & vai trò | ✅ | ❌ | ❌ | ❌ |
| Quản lý khách hàng & thiết bị | ✅ | ✅ | 👁️ Xem | ❌ |
| Lập phiếu sửa chữa | ✅ | ✅ | ❌ | ❌ |
| Cập nhật chẩn đoán & báo giá | ✅ | ❌ | ✅ | ❌ |
| Chuyển trạng thái phiếu | ✅ | ✅ | ✅ | ❌ |
| Phân công kỹ thuật viên | ✅ | ❌ | ❌ | ❌ |
| Quản lý danh mục linh kiện & giá | ✅ | ❌ | ❌ | ❌ |
| Nhập kho | ✅ | ❌ | ❌ | ❌ |
| Xuất linh kiện cho phiếu | ✅ | ❌ | ✅ | ❌ |
| Lập hóa đơn & thu tiền | ✅ | ✅ | ❌ | ❌ |
| Áp dụng giảm giá | ✅ | ❌ | ❌ | ❌ |
| Tra cứu bảo hành | ✅ | ✅ | ✅ | 👁️ Của mình |
| Vô hiệu bảo hành | ✅ | ❌ | ❌ | ❌ |
| Dashboard & báo cáo doanh thu | ✅ | ❌ | ❌ | ❌ |
| Xem phiếu của mình (mobile) | ❌ | ❌ | ❌ | ✅ |

## 5. Quy tắc nghiệp vụ bắt buộc kiểm tra ở Backend

Những quy tắc này không được để client tự kiểm, Backend phải chặn:

1. Chỉ lập hóa đơn khi phiếu ở trạng thái `COMPLETED`.
2. Mỗi phiếu chỉ có một hóa đơn (ràng buộc UNIQUE trên `Invoices.TicketId`).
3. Không xuất linh kiện vượt tồn kho hiện tại.
4. Số lượng xuất và nhập phải là số nguyên dương.
5. Giảm giá không được lớn hơn `LaborCost + PartsCost`.
6. Không chuyển trạng thái ngoài bảng chuyển hợp lệ ở mục 2.
7. Hủy phiếu phải hoàn trả toàn bộ linh kiện đã xuất về kho.
8. Phiếu sửa bảo hành: miễn tiền công, phải có `OriginalTicketId` trỏ tới phiếu gốc còn hạn bảo hành.
9. Thời hạn bảo hành lấy theo giá trị lớn nhất giữa thời hạn của loại dịch vụ và của các linh kiện đã thay.
10. Toàn bộ thao tác xuất linh kiện (trừ tồn + ghi `TicketParts` + ghi `StockTransactions` + cộng chi phí phiếu) phải nằm trong một transaction, lỗi ở bước nào thì rollback tất cả.
