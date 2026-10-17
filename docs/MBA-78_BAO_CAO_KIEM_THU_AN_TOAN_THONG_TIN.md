# BÁO CÁO KIỂM THỬ AN TOÀN THÔNG TIN & THÂM NHẬP (PENETRATION TESTING & SECURITY REPORT)

> **Dự án:** Hệ thống quản lý tổng thể cho cửa hàng sửa chữa (LV33-001)  
> **Mã công việc Jira:** `MBA-78`  
> **Người thực hiện:** **Nguyễn Đại Kỳ** (MSSV: 2380601178) – UI/UX Designer & QA Tester Lead (Nhóm 11 - 23DTHC6)  
> **Thời điểm thực hiện:** 17/10/2026  
> **Khung tham chiếu chuẩn:** OWASP Top 10 API Security Risks & OWASP Top 10 Web Application Security  

---

## 1. MỤC TIÊU & PHẠM VI KIỂM THỬ BẢO MẬT

Kiểm thử thâm nhập (Penetration Testing) nhằm đánh giá khả năng phòng thủ của hệ thống trước các phương thức tấn công phổ biến vào ứng dụng web và API, phát hiện sớm các lỗ hổng an ninh trước khi bàn giao đồ án:

1. **Phòng chống tấn công chèn mã độc XSS (Cross-Site Scripting):** Đảm bảo dữ liệu người dùng nhập chứa mã script, thẻ SVG/HTML độc hại không bị trình duyệt thực thi.
2. **Phòng chống tấn công chèn câu lệnh SQL Injection (SQLi):** Đảm bảo đầu vào form đăng nhập, bộ lọc tìm kiếm không thể can thiệp phá vỡ cú pháp truy vấn CSDL.
3. **Phòng chống leo thang đặc quyền ngang IDOR (Insecure Direct Object References - Lỗi L05):** Ngăn chặn người dùng xem trộm hoặc thao tác trên phiếu sửa chữa của người khác bằng cách sửa mã ID trên URL.
4. **Phòng chống leo thang đặc quyền dọc (Vertical Privilege Escalation):** Kiểm soát phân quyền dựa trên vai trò (RBAC) nghiêm ngặt giữa Admin, Staff, Technician và Customer.
5. **Kiểm tra tính toàn vẹn nghiệp vụ:** Ngăn chặn gian lận tiền bạc (số tiền âm) hoặc xuất khống số lượng linh kiện vượt quá tồn kho thực tế.

---

## 2. MA TRẬN KẾT QUẢ KIỂM THỬ THÂM NHẬP (PENETRATION TEST MATRIX)

| Mã Ca Test | Vector Tấn Công Mô Phỏng | Payload Đầu Vào | Phản Hồi Mong Đợi | Kết Quả Thực Tế | Đánh Giá An Ninh |
|:---:|---|---|:---:|:---:|:---:|
| **PT-01** | SQL Injection Form Đăng nhập | `username: "admin' OR '1'='1"`, `password: "' OR '1'='1"` | 401 Unauthorized | HTTP 401 Unauthorized | **AN TOÀN (PASS)** |
| **PT-02** | Bỏ trống mật khẩu (Empty Password) | `password: ""` | 401 Unauthorized | HTTP 401 Unauthorized | **AN TOÀN (PASS)** |
| **PT-03** | Gọi API không có Token xác thực | Không gửi header `X-Session-Token` | 401 Unauthorized | HTTP 401 Unauthorized | **AN TOÀN (PASS)** |
| **PT-04** | Gửi Token giả mạo không hợp lệ | `X-Session-Token: FAKE_MALICIOUS_TOKEN` | 401 Unauthorized | HTTP 401 Unauthorized | **AN TOÀN (PASS)** |
| **PT-05** | Khách hàng xuất kho linh kiện | Vai trò `CUSTOMER` gọi `POST /api/inventory/transactions` | 403 Forbidden | HTTP 403 Forbidden | **AN TOÀN (PASS)** |
| **PT-06** | Leo quyền ngang IDOR (Khách xem phiếu người khác) | Khách An xem phiếu `PSC2026090002` của Khách Bình | 403 Forbidden | HTTP 403 Forbidden | **AN TOÀN (PASS)** |
| **PT-07** | Reflected XSS trên Họ Tên khách hàng | `fullName: "<script>alert('XSS')</script>"` | Lưu dạng văn bản thô, mã độc bị escape | Không thực thi mã độc, hiển thị text an toàn | **AN TOÀN (PASS)** |
| **PT-08** | Stored XSS trong Ghi chú tiếp nhận | `customerRequest: "<svg/onload=alert('XSS')>"` | Encode an toàn khi trả về JSON | JSON mã hóa chuỗi an toàn | **AN TOÀN (PASS)** |
| **PT-09** | Tấn công số tiền thanh toán âm | `amount: -500000` | 400 Bad Request | HTTP 400 Bad Request | **AN TOÀN (PASS)** |
| **PT-10** | Tấn công xuất âm kho linh kiện | `quantity: 999999` (vượt tồn kho thực tế) | 400 Bad Request | HTTP 400 Bad Request | **AN TOÀN (PASS)** |

---

## 3. PHÂN TÍCH CÁC CƠ CHẾ BẢO MẬT ĐÃ ĐƯỢC THIẾT LẬP

1. **Cơ chế phòng chống SQL Injection:**
   * Tầng Backend ASP.NET Core sử dụng hoàn toàn truy vấn tham số hóa (Parameterized Queries) và Stored Procedure, tách biệt hoàn toàn giữa câu lệnh thực thi và dữ liệu người dùng truyền vào.
2. **Cơ chế xác thực & Phân quyền RBAC:**
   * Sử dụng Middleware `AuthHelper.RequireRole(request, data, ...)` kiểm tra quyền nghiêm ngặt trước khi vào Endpoint handler.
   * Session Token được sinh ngẫu nhiên định dạng GUID v4 với thời gian sống có hạn.
3. **Cơ chế vá triệt để lỗ hổng IDOR L05 (Commit `4eb360c`):**
   * Tại Endpoint `GET /api/tickets/{code}`, backend kiểm tra: Nếu người đăng nhập có vai trò `CUSTOMER`, hệ thống đối chiếu bắt buộc `ticket.CustomerCode` phải khớp với mã khách hàng liên kết với tài khoản đó. Nếu không trùng khớp, hệ thống từ chối ngay lập tức với mã lỗi `HTTP 403 Forbidden`.
4. **Cơ chế phòng chống XSS:**
   * Web Admin sử dụng `innerText` và `textContent` thay cho `innerHTML` khi hiển thị dữ liệu người dùng nhập, triệt tiêu hoàn toàn nguy cơ thực thi mã JavaScript độc hại trên trình duyệt.

---

## 4. KẾT LUẬN & ĐỀ XUẤT NGHIỆM THU (TASK MBA-78)

* **Kết quả:** Đạt **10/10 bài kiểm thử thâm nhập (100% Passed)**, không ghi nhận bất kỳ lỗ hổng bảo mật nghiêm trọng (Critical/High) nào.
* **Minh chứng đính kèm:** File kịch bản kiểm thử thâm nhập tự động: [`tests/security/penetration_security_test.http`](../tests/security/penetration_security_test.http).
* **Nghiệm thu:** Task `MBA-78` hoàn thành đầy đủ, đáp ứng yêu cầu an toàn thông tin đồ án tốt nghiệp môn học QLDACNTT.
