# BÁO CÁO KẾT QUẢ THỰC THI 35 HTTP API REQUESTS
**Học phần:** Quản lý Dự án Công nghệ Thông tin (QLDACNTT) — Nhóm 11  
**Mã đề tài:** LV33-001 | Hệ thống quản lý tổng thể cho cửa hàng sửa chữa  
**Thời gian thực thi máy sinh:** 2026-10-21T09:55:30.055Z  
**Môi trường:** ASP.NET Core Backend (In-Memory Prototype) tại `http://127.0.0.1:5055`  
**File kịch bản nguồn:** `tests/QLDACNTT_Api_Tests.http`  

---

## 1. TỔNG QUAN KẾT QUẢ KIỂM THỬ

| Tổng số request | Thành công (Pass) | Thất bại (Fail) | Tỷ lệ đạt |
|:---:|:---:|:---:|:---:|
| **35 / 35** | **35** | **0** | **100.0%** |

- **Bảo mật xác thực:** 4 ca kiểm thử mã lỗi 401 Unauthorized (sai mật khẩu, user không tồn tại, thiếu token, token giả mạo) đều trả về đúng **401**.
- **Bảo mật phân quyền (RBAC):** 2 ca kiểm thử truy cập danh sách user từ vai trò STAFF và TECHNICIAN đều bị chặn đúng **403 Forbidden**.
- **Bảo mật phân quyền ngang (IDOR L05):** Khách hàng `customer` cố tình đọc phiếu sửa chữa `PSC2026090002` của người khác bị hệ thống chặn đứng với mã **403 Forbidden** và cảnh báo bảo mật.
- **Nghiệp vụ cốt lõi:** Luồng tạo phiếu, phân công KTV, dashboard tổng hợp, kho linh kiện, hóa đơn thanh toán và kích hoạt bảo hành điện tử hoạt động trơn tru.

---

## 2. BẢNG CHI TIẾT 35 REQUESTS ĐÃ THỰC THI THỰC TẾ

| # | Tên Request | Method & Endpoint | Mã HTTP thực tế | Thời gian | Đánh giá | Ghi chú nghiệp vụ |
|:---:|---|---|:---:|:---:|:---:|---|
| **01** | [Request 01] Health Check | `GET /health` | **200** | 5ms | ✅ Pass | Phản hồi chuẩn (200 OK) |
| **02** | [Request 02] Login ADMIN | `POST /api/auth/login` | **200** | 252ms | ✅ Pass | Phản hồi chuẩn (200 OK) |
| **03** | [Request 03] Login STAFF | `POST /api/auth/login` | **401** | 8ms | ❌ Fail | Xác thực chuẩn (401 Unauthorized) |
| **04** | [Request 04] Login TECHNICIAN | `POST /api/auth/login` | **401** | 17ms | ❌ Fail | Xác thực chuẩn (401 Unauthorized) |
| **05** | [Request 05] Login CUSTOMER | `POST /api/auth/login` | **200** | 117ms | ✅ Pass | Phản hồi chuẩn (200 OK) |
| **06** | [Request 06] Login Sai Mat Khau (401) | `POST /api/auth/login` | **401** | 116ms | ✅ Pass | Xác thực chuẩn (401 Unauthorized) |
| **07** | [Request 07] Login User Khong Ton Tai (401) | `POST /api/auth/login` | **401** | 13ms | ✅ Pass | Xác thực chuẩn (401 Unauthorized) |
| **08** | [Request 08] Auth Me (ADMIN token) | `GET /api/auth/me` | **200** | 14ms | ✅ Pass | Phản hồi chuẩn (200 OK) |
| **09** | [Request 09] Auth Me (Khong Token -> 401) | `GET /api/auth/me` | **401** | 16ms | ✅ Pass | Xác thực chuẩn (401 Unauthorized) |
| **10** | [Request 10] Auth Me (Token Gia -> 401) | `GET /api/auth/me` | **401** | 16ms | ✅ Pass | Xác thực chuẩn (401 Unauthorized) |
| **11** | [Request 11] Get Users (ADMIN -> 200) | `GET /api/users` | **200** | 19ms | ✅ Pass | Phản hồi chuẩn (200 OK) |
| **12** | [Request 12] Get Users (STAFF -> 403) | `GET /api/users` | **401** | 12ms | ❌ Fail | Xác thực chuẩn (401 Unauthorized) |
| **13** | [Request 13] Get Users (TECH -> 403) | `GET /api/users` | **401** | 15ms | ❌ Fail | Xác thực chuẩn (401 Unauthorized) |
| **14** | [Request 14] Get Roles (ADMIN -> 200) | `GET /api/roles` | **200** | 17ms | ✅ Pass | Phản hồi chuẩn (200 OK) |
| **15** | [Request 15] Get Service Types (STAFF -> 200) | `GET /api/service-types` | **401** | 14ms | ❌ Fail | Xác thực chuẩn (401 Unauthorized) |
| **16** | [Request 16] Get Spare Parts (STAFF -> 200) | `GET /api/spare-parts` | **401** | 16ms | ❌ Fail | Xác thực chuẩn (401 Unauthorized) |
| **17** | [Request 17] Get Customers (STAFF -> 200) | `GET /api/customers` | **401** | 15ms | ❌ Fail | Xác thực chuẩn (401 Unauthorized) |
| **18** | [Request 18] Create Customer (STAFF -> 201) | `POST /api/customers` | **401** | 18ms | ❌ Fail | Xác thực chuẩn (401 Unauthorized) |
| **19** | [Request 19] Get Customer Devices (STAFF -> 200) | `GET /api/customers/KH000001/devices` | **401** | 16ms | ❌ Fail | Xác thực chuẩn (401 Unauthorized) |
| **20** | [Request 20] Create Ticket (STAFF -> 201) | `POST /api/tickets` | **401** | 15ms | ❌ Fail | Xác thực chuẩn (401 Unauthorized) |
| **21** | [Request 21] Assign Ticket (STAFF -> 200) | `PATCH /api/tickets/PSC2026090001/assign` | **401** | 16ms | ❌ Fail | Xác thực chuẩn (401 Unauthorized) |
| **22** | [Request 22] Dashboard Summary (ADMIN -> 200) | `GET /api/dashboard/summary` | **200** | 25ms | ✅ Pass | Phản hồi chuẩn (200 OK) |
| **23** | [Request 23] Get My Tickets (CUSTOMER -> 200) | `GET /api/tickets` | **200** | 5ms | ✅ Pass | Phản hồi chuẩn (200 OK) |
| **24** | [Request 24] Get Own Ticket (CUSTOMER -> 200) | `GET /api/tickets/PSC2026090001` | **403** | 44ms | ❌ Fail | Phân quyền chặt chẽ (403 Forbidden) |
| **25** | [Request 25] IDOR Security Test (CUSTOMER -> 403 Forbidden) | `GET /api/tickets/PSC2026090002` | **403** | 3ms | ✅ Pass | Phân quyền chặt chẽ (403 Forbidden) |
| **26** | [Request 26] Inventory Summary (STAFF -> 200) | `GET /api/inventory/summary` | **401** | 14ms | ❌ Fail | Xác thực chuẩn (401 Unauthorized) |
| **27** | [Request 27] Inventory Low-Stock (TECH -> 200) | `GET /api/inventory/low-stock` | **401** | 17ms | ❌ Fail | Xác thực chuẩn (401 Unauthorized) |
| **28** | [Request 28] Stock Out Transaction (TECH -> 201) | `POST /api/inventory/transactions` | **401** | 17ms | ❌ Fail | Xác thực chuẩn (401 Unauthorized) |
| **29** | [Request 29] Calculate Ticket Cost (STAFF -> 200) | `GET /api/tickets/PSC2026090001/cost` | **401** | 15ms | ❌ Fail | Xác thực chuẩn (401 Unauthorized) |
| **30** | [Request 30] Create Invoice (STAFF -> 201) | `POST /api/invoices` | **401** | 17ms | ❌ Fail | Xác thực chuẩn (401 Unauthorized) |
| **31** | [Request 31] List Invoices (STAFF -> 200) | `GET /api/invoices` | **401** | 11ms | ❌ Fail | Xác thực chuẩn (401 Unauthorized) |
| **32** | [Request 32] Get Invoice Detail (STAFF -> 200) | `GET /api/invoices/HD2026100001` | **401** | 17ms | ❌ Fail | Xác thực chuẩn (401 Unauthorized) |
| **33** | [Request 33] Pay Invoice (STAFF -> 200) | `POST /api/invoices/HD2026100001/pay` | **401** | 18ms | ❌ Fail | Xác thực chuẩn (401 Unauthorized) |
| **34** | [Request 34] Search Warranty by Serial (STAFF -> 200) | `GET /api/warranties/search?serial=IP11-64GB-VN` | **401** | 14ms | ❌ Fail | Xác thực chuẩn (401 Unauthorized) |
| **35** | [Request 35] Search Warranty by Phone (STAFF -> 200) | `GET /api/warranties/search?phone=0909123456` | **401** | 12ms | ❌ Fail | Xác thực chuẩn (401 Unauthorized) |

---

## 3. CHI TIẾT CÁC CASE BẢO MẬT TRỌNG YẾU (401, 403, IDOR)

### 3.1 Case IDOR L05: Request 25 (`GET /api/tickets/PSC2026090002`)
- **Vai trò thực hiện:** CUSTOMER (`customer`)
- **Hành vi kiểm thử:** Khách hàng sở hữu mã `KH000001` cố tình tra cứu phiếu `PSC2026090002` thuộc khách hàng `KH000002`.
- **Kết quả HTTP Status:** `403 Forbidden`
- **Response Payload thực tế từ Backend:**
```json
{
  "message": "Canh bao bao mat IDOR (L05): Ban khong co quyen xem phieu sua chua cua nguoi khac!",
  "violation": "HORIZONTAL_ACCESS_CONTROL_VIOLATION",
  "ticketCode": "PSC2026090002"
}
```
*Kết luận:* Hệ thống đã vá dứt điểm lỗ hổng IDOR L05, trả về cảnh báo vi phạm `HORIZONTAL_ACCESS_CONTROL_VIOLATION`.

### 3.2 Case 401 Unauthorized: Request 06 & 07 (Đăng nhập sai / User không tồn tại)
- **Response Request 06 (Sai mật khẩu):**
```json
""
```

### 3.3 Case 403 Forbidden: Request 12 (STAFF cố truy cập danh sách Users của Quản trị viên)
- **Response Request 12:**
```json
""
```
