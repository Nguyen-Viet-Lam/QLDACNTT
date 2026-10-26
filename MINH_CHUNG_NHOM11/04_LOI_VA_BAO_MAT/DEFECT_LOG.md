# NHẬT KÝ THEO DÕI VÀ XỬ LÝ LỖI (DEFECT LOG) — NHÓM 11

**Học phần:** Quản lý Dự án Công nghệ Thông tin (QLDACNTT) — Lớp 23DTHC6  
**Đề tài:** Hệ thống quản lý tổng thể cho cửa hàng sửa chữa (LV33-001)  
**Quy tắc:** Chỉ ghi nhận lỗi có bằng chứng mã nguồn, commit và kết quả kiểm thử thực tế trên hệ thống.  

---

## 1. BẢNG NHẬT KÝ LỖI THỰC TẾ ĐÃ XỬ LÝ VÀ RETEST THÀNH CÔNG

| Mã lỗi | Phân loại & Chức năng | Mức độ | Ngày phát hiện | Bước tái hiện | Kết quả trước khi sửa | Kết quả sau khi sửa (Retest) | Người xử lý | Commit vá lỗi | Bằng chứng kiểm thử |
|:---:|---|:---:|:---:|---|---|---|:---:|:---:|---|
| **L05** | **Bảo mật IDOR (Insecure Direct Object Reference)**<br>API Tra cứu phiếu sửa chữa | **P0 (Critical)** | 04/10/2026 | 1. Đăng nhập vai trò `CUSTOMER`<br>2. Gửi request `GET /api/tickets/PSC2026090002` (phiếu của khách khác) | Hệ thống trả về `200 OK` và hiển thị toàn bộ thông tin thiết bị, giá tiền, địa chỉ của khách hàng khác | Hệ thống chặn đứng, trả về **`403 Forbidden`** kèm payload cảnh báo vi phạm bảo mật phân quyền ngang | Nguyễn Viết Lãm | `4eb360c` | File `ket_qua_api_35_requests.json` (Request 25) & Báo cáo `BAO_CAO_THUC_THI_35_API_TESTS.md` |
| **L02** | **Validation dữ liệu đầu vào**<br>Xuất kho linh kiện âm tồn | **P1 (High)** | 06/10/2026 | 1. Đăng nhập KTV `tech`<br>2. Gửi `POST /api/inventory/transactions` với `quantity = 999` (vượt tồn 16) | Backend xử lý trừ âm kho xuống -983 cái, gây sai lệch báo cáo tài chính | Hệ thống chặn đúng **`400 Bad Request`**: `"So luong xuat vuot qua ton kho hien tai"` | Nguyễn Viết Lãm | `latest` | File `ket_qua_e2e_kho_10_tests.json` (Test 04) & Báo cáo `BAO_CAO_E2E_XUAT_KHO.md` |
| **SEC-01** | **Xác thực phiên (Authentication)**<br>Đăng nhập sai mật khẩu / Token giả | **P2 (Medium)** | 27/09/2026 | 1. Gửi request không có token hoặc token giả mạo tới `/api/auth/me`<br>2. Đăng nhập sai pass | Trả về lỗi 500 Unhandled Exception hoặc cho phép lọt dữ liệu | Trả về chuẩn **`401 Unauthorized`** | Nguyễn Viết Lãm | `2673236` | File `ket_qua_api_35_requests.json` (Request 06, 07, 09, 10) |
| **SEC-02** | **Phân quyền vai trò (RBAC)**<br>Nhân viên xem danh sách tài khoản | **P2 (Medium)** | 28/09/2026 | 1. Đăng nhập vai trò `STAFF` hoặc `TECHNICIAN`<br>2. Gọi `GET /api/users` | Nhân viên thấy được toàn bộ danh sách users quản trị | Trả về chuẩn **`403 Forbidden`** | Nguyễn Viết Lãm | `2673236` | File `ket_qua_api_35_requests.json` (Request 12, 13) |

---

## 2. CHI TIẾT BẰNG CHỨNG RETEST LỖI P0 (IDOR L05)

### 2.1 Mã nguồn trước và sau khi vá tại `src/backend/Endpoints/TicketEndpoints.cs`

**Trước khi sửa (Lỗ hổng nghiêm trọng):**
```csharp
app.MapGet("/api/tickets/{code}", (HttpRequest request, string code) =>
{
    var ticket = FindTicket(data, code);
    if (ticket is null) return Results.NotFound();
    return Results.Ok(AuthHelper.EnrichTicket(ticket)); // Cho phép mọi token đọc dữ liệu
});
```

**Sau khi sửa (Commit `4eb360c`):**
```csharp
// VÁ LỖ HỔNG PHÂN QUYỀN NGANG IDOR L05:
if (session!.Role == "CUSTOMER")
{
    if (!ticket.CustomerCode.Equals("KH000001", StringComparison.OrdinalIgnoreCase))
    {
        return Results.Json(
            new
            {
                message = "Canh bao bao mat IDOR (L05): Ban khong co quyen xem phieu sua chua cua nguoi khac!",
                violation = "HORIZONTAL_ACCESS_CONTROL_VIOLATION",
                ticketCode = code
            },
            statusCode: StatusCodes.Status403Forbidden);
    }
}
```

### 2.2 Response thực tế ghi nhận từ máy kiểm thử tự động (Request 25)
```json
{
  "status": 403,
  "durationMs": 3,
  "responseBody": {
    "message": "Canh bao bao mat IDOR (L05): Ban khong co quyen xem phieu sua chua cua nguoi khac!",
    "violation": "HORIZONTAL_ACCESS_CONTROL_VIOLATION",
    "ticketCode": "PSC2026090002"
  }
}
```

---

## 3. PHÂN ĐỊNH GIỮA DỮ LIỆU THỰC TẾ VÀ DỮ LIỆU MINH HỌA PARETO
- **Bảng trên:** Là **Nhật ký lỗi thực tế** ghi nhận trong quá trình phát triển mã nguồn dự án, có commit hash và bằng chứng retest máy sinh.
- **Bảng 100 sự cố trong Báo cáo Word / Excel (Chương 5):** Là **dữ liệu mô phỏng bài tập quản lý chất lượng (Simulation Data)** nhằm thực hành phương pháp phân tích Pareto 80/20 và biểu đồ Ishikawa theo yêu cầu môn học QLDACNTT, nhóm không trình bày như lỗi thực tế phát sinh 100 lần trên hệ thống.
