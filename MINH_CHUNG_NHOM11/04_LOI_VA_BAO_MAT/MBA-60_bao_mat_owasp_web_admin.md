# RÀ SOÁT AN TOÀN BẢO MẬT OWASP CHO WEB ADMIN – MBA-60
## NHÓM 11 | LV33-001 | Trần Ngọc Lợi (BA / Database Lead) | 17/10/2026

---

## 1. TỔNG QUAN

| Mục | Nội dung |
|-----|----------|
| **Task ID** | MBA-60 |
| **Chuẩn đánh giá** | OWASP Top 10 (2021) |
| **Phạm vi** | Backend API (`src/backend/`) + Web Admin UI (`src/web-admin/`) |
| **Ngày đánh giá** | 17/10/2026 |

---

## 2. BẢNG ĐÁNH GIÁ OWASP TOP 10 (2021)

| # | Hạng mục | Rủi ro | Trạng thái | Ghi chú |
|:---:|---|:---:|:---:|---|
| A01 | Broken Access Control | 🟢 Thấp | ✅ An toàn | IDOR đã vá - commit 4eb360c |
| A02 | Cryptographic Failures | 🟡 TB | ⚠️ Cần cải thiện | Password plain-text ở prototype |
| A03 | Injection | 🟢 Thấp | ✅ An toàn | LINQ in-memory + SP parameterized |
| A04 | Insecure Design | 🟡 TB | ⚠️ Cần bổ sung | Thiếu rate limiting / account lockout |
| A05 | Security Misconfiguration | 🟡 TB | ⚠️ Cần cải thiện | CORS AllowAnyOrigin + thiếu security headers |
| A06 | Outdated Components | 🟢 Thấp | ✅ An toàn | .NET 8, Bootstrap 5.3, Chart.js 4.x |
| A07 | Auth Failures | 🟡 TB | ⚠️ Cần bổ sung | Token hết hạn OK, thiếu brute-force protection |
| A08 | Data Integrity | 🟡 Thấp | ⚠️ Cần bổ sung | CDN chưa có SRI hash |
| A09 | Logging & Monitoring | 🟡 TB | ⚠️ Cần bổ sung | Chưa log auth failure |
| A10 | SSRF | 🟢 Thấp | ✅ An toàn | Không có vector SSRF |

**Điểm tổng: 7/10** – Phù hợp học thuật; cần bổ sung trước production.

---

## 3. CHI TIẾT CÁC MỤC QUAN TRỌNG

### A01 – Broken Access Control ✅ AN TOÀN
- Mọi endpoint có `AuthHelper.RequireRole(...)` kiểm tra quyền
- Lỗi IDOR phiếu sửa chữa (L05 – P0) đã phát hiện qua phân tích Pareto Sprint 4, vá tại commit `4eb360c`
- CUSTOMER chỉ xem được phiếu của chính mình (kiểm tra `ticket.CustomerCode == session.CustomerCode`)

### A02 – Cryptographic Failures ⚠️
```csharp
// ❌ Prototype (KHÔNG dùng production):
if (account.Password != input.Password) ...

// ✅ Production – dùng BCrypt:
// if (!BCrypt.Net.BCrypt.Verify(input.Password, account.PasswordHash)) ...
```

### A05 – Security Misconfiguration ⚠️
```csharp
// ❌ Hiện tại – quá rộng:
policy.AllowAnyOrigin().AllowAnyHeader().AllowAnyMethod();

// ✅ Production:
policy.WithOrigins("https://admin.repairshop.vn").AllowAnyHeader().AllowAnyMethod();

// Thêm Security Headers:
app.Use(async (ctx, next) => {
    ctx.Response.Headers.Add("X-Content-Type-Options", "nosniff");
    ctx.Response.Headers.Add("X-Frame-Options", "DENY");
    await next();
});
```

---

## 4. KIỂM THỬ BẢO MẬT ĐÃ THỰC HIỆN

| Test | Mô tả | Kết quả |
|---|---|:---:|
| IDOR | CUSTOMER xem phiếu người khác | ✅ 403 Forbidden |
| SQL Injection | `?search=' OR 1=1 --` | ✅ Trả về [] |
| Token hết hạn | Dùng token > 8 giờ | ✅ 401 Unauthorized |
| Privilege Escalation | CUSTOMER gọi `/api/dashboard/summary` | ✅ 403 Forbidden |
| Brute-force | Thử sai mật khẩu 20 lần liên tiếp | ❌ Không bị khóa (cần thêm) |

---

## 5. DANH SÁCH LỖI ƯU TIÊN VÁ

### 🔴 P0 – Bắt buộc trước production
1. **Mật khẩu plain-text** → Cài `BCrypt.Net-Next`, hash password
2. **Không có account lockout** → Thêm fail counter, khóa 15 phút
3. **CORS quá rộng** → Whitelist domain cụ thể

### 🟡 P1 – Sprint tiếp theo
4. **Thiếu Security Headers** → Thêm middleware
5. **`/api/db/status` lộ thông tin** → Bảo vệ bằng xác thực ADMIN
6. **CDN không có SRI** → Thêm `integrity` attribute
7. **Không log auth failures** → Thêm bảng `LoginAuditLog`

---

## 6. KẾT LUẬN & ĐÁNH GIÁ TỔNG THỂ

| Chỉ số | Giá trị |
|---|---|
| **Tổng số mục OWASP kiểm tra** | 10 / 10 |
| **Số mục AN TOÀN** | 3 (A01, A03, A06, A10) |
| **Số mục CẦN CẢI THIỆN** | 6 (A02, A04, A05, A07, A08, A09) |
| **Điểm bảo mật tổng** | **6.5 / 10** |
| **Mức độ phù hợp** | ✅ Học thuật (prototype demo) |
| **Sẵn sàng production** | ❌ Cần vá ít nhất 3 lỗi P0 |

### Nhận xét tổng quan
- Hệ thống đã xây dựng nền tảng phân quyền **tốt** với `AuthHelper.RequireRole()` xuyên suốt
- Lỗi nghiêm trọng nhất (**mật khẩu plain-text**) là kỹ thuật nợ từ prototype – **chấp nhận được cho môi trường học thuật** nhưng bắt buộc phải vá trước sản xuất
- Kiến trúc Minimal API + Stored Procedure parameterized giúp **chặn hoàn toàn SQL Injection**
- CORS `AllowAnyOrigin` là điểm yếu phổ biến nhất trong các dự án học thuật – dễ vá

---

## 7. KẾ HOẠCH HÀNH ĐỘNG (ROADMAP BẢO MẬT)

### Sprint hiện tại (trước bảo vệ đề tài)
Ưu tiên tài liệu hóa, không cần vá production do đây là dự án học thuật.

### Sprint tiếp theo (nếu tiếp tục phát triển)

| Ưu tiên | Hạng mục | Thời gian ước tính | Người phụ trách |
|:---:|---|:---:|---|
| P0 | Cài BCrypt hash mật khẩu | 2h | Nguyễn Viết Lãm |
| P0 | Thêm Account Lockout (5 lần sai → khóa 15') | 3h | Nguyễn Viết Lãm |
| P0 | Giới hạn CORS theo whitelist domain | 30' | Nguyễn Viết Lãm |
| P1 | Thêm HTTP Security Headers middleware | 1h | Nguyễn Viết Lãm |
| P1 | Bảo vệ `/api/db/status` endpoint | 30' | Nguyễn Viết Lãm |
| P1 | Thêm SRI hash cho CDN resources | 1h | Nguyễn Đại Kỳ |
| P1 | Tạo bảng `LoginAuditLog` | 2h | Trần Ngọc Lợi |
| P2 | Cài đặt Rate Limiting middleware | 2h | Nguyễn Viết Lãm |
| P2 | Thêm HTTPS + SSL certificate | 1h | Nguyễn Viết Lãm |

### Snippet triển khai Account Lockout
```csharp
// Trong AuthEndpoints.cs – thêm vào POST /api/auth/login
var failKey = $"login_fail_{input.Username}";
var failCount = AppData.LoginFailures.GetValueOrDefault(failKey, 0);

if (failCount >= 5)
{
    var lockUntil = AppData.LockoutUntil.GetValueOrDefault(failKey, DateTime.MinValue);
    if (DateTime.UtcNow < lockUntil)
        return Results.Json(new { message = "Tài khoản bị khóa tạm thời 15 phút" },
            statusCode: 429);
}

if (account.Password != input.Password)
{
    AppData.LoginFailures[failKey] = failCount + 1;
    if (failCount + 1 >= 5)
        AppData.LockoutUntil[failKey] = DateTime.UtcNow.AddMinutes(15);
    return Results.Unauthorized();
}

// Đăng nhập thành công → reset
AppData.LoginFailures.Remove(failKey);
AppData.LockoutUntil.Remove(failKey);
```

### Snippet LoginAuditLog
```sql
CREATE TABLE dbo.LoginAuditLog (
    LogID       INT IDENTITY(1,1) PRIMARY KEY,
    Username    NVARCHAR(100)   NOT NULL,
    IPAddress   NVARCHAR(50)    NOT NULL,
    AttemptTime DATETIME2       NOT NULL DEFAULT SYSDATETIME(),
    IsSuccess   BIT             NOT NULL,
    FailReason  NVARCHAR(200)   NULL
);

-- Index tra cứu nhanh theo Username + thời gian
CREATE INDEX IX_LoginAuditLog_User_Time
    ON dbo.LoginAuditLog (Username, AttemptTime DESC);
```

---

## 8. CHECKLIST KIỂM THỬ BẢO MẬT ĐẦY ĐỦ

### Kiểm thử đã hoàn thành ✅
- [x] IDOR – Customer xem phiếu người khác → 403 Forbidden
- [x] SQL Injection cổ điển → trả về `[]`
- [x] Token hết hạn (>8h) → 401 Unauthorized
- [x] Privilege Escalation CUSTOMER → ADMIN endpoint → 403
- [x] Truy cập endpoint không có token → 401

### Kiểm thử còn thiếu (để nhóm thực hiện)
- [ ] **XSS Stored**: Tạo khách hàng với `<script>alert(1)</script>` trong tên
- [ ] **CSRF**: Thử gửi request từ origin khác không có token
- [ ] **Brute-force login**: Dùng vòng lặp 50 lần → kiểm tra có bị chặn không
- [ ] **Enumeration**: Thử `/api/customers/KH999` để kiểm tra thông báo lỗi có lộ thông tin không
- [ ] **SSRF nâng cao**: Gửi URL nội bộ vào trường nhập liệu
- [ ] **Path Traversal**: Thử `../../../etc/passwd` trong các tham số tên file

---

**Người thực hiện:** Trần Ngọc Lợi (BA / Database Lead – Nhóm 11 – 23DTHC6)  
**Ngày hoàn thành:** 17/10/2026  
**Phiên bản tài liệu:** v1.0 – Phát hành cùng Sprint 5
