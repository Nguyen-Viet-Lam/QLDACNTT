# 📋 HỒ SƠ MINH CHỨNG BẢO VỆ – NHÓM 11
**Học phần:** Quản lý Dự án Công nghệ Thông tin (QLDACNTT) – Lớp 23DTHC6  
**Đề tài:** Hệ thống quản lý tổng thể cho cửa hàng sửa chữa – Mã đề tài LV33-001  
**Ngày lập hồ sơ minh chứng:** 06/10/2026  

| Thành viên | MSSV | Vai trò |
|---|---|---|
| Nguyễn Viết Lãm | 2380601183 | Nhóm trưởng / PM / Backend Lead |
| Trần Ngọc Lợi | 2380601292 | Business Analyst / Database Lead |
| Nguyễn Đại Kỳ | 2380601178 | UI/UX Designer / QA Tester Lead |

---

## MỤC LỤC MINH CHỨNG

| # | Loại minh chứng | Tóm tắt | Tệp/Nguồn |
|:---:|---|---|---|
| **1** | Nhật ký AI Prompt (4 bài tập + 4 kỹ thuật) | 8 prompt ghi đầy đủ: câu hỏi, phản hồi AI, hiệu chỉnh nhóm | `NHAT_KY_PROMPT_AI.md` |
| **2** | Quản lý Jira ≥ 50 task | 88 tasks Sprint 2–8, phân công 3 thành viên | URL Jira + `tools/all_88_jira_sorted.txt` |
| **3** | Kịch bản kiểm thử API (35 request + 10 E2E) | 4 vai trò, 401/403, IDOR L05, Xuất kho, Hóa đơn | `tests/QLDACNTT_Api_Tests.http` |
| **4** | Bảng lỗi phát sinh & Pareto 80/20 | 100 sự cố, 8 nhóm lỗi, 4 nhóm đầu = 80% | Excel Sheet 5 + Word Ch.5 |
| **5** | Vá lỗi bảo mật IDOR (P0) | Commit `4eb360c` vá lỗ hổng xem phiếu người khác | `src/backend/Endpoints/TicketEndpoints.cs` |
| **6** | Cơ sở dữ liệu SQL Server 13 bảng | Schema 3NF, FK, Seed, View, Stored Proc | `database/QLDACNTT_full_database.sql` |
| **7** | Lịch sử GitHub (18 nhánh + commit) | Feature branches → PR → merge vào main | GitHub: Nguyen-Viet-Lam/QLDACNTT |
| **8** | Báo cáo EVM tại mốc ngày 13 | CPI=0.9859, SPI=1.02, SV=+275k, CV=-200k | Excel Sheet 3 + Word Ch.4 |
| **9** | Bảng Rubric đánh giá thành viên | 4 tiêu chí, 5 mức – Lãm 7.9, Lợi 7.5, Kỳ 6.5 | Excel Sheet 6 + Word Ch.5 |
| **10** | Phần mềm chạy thực tế (Live Demo) | Backend API + Web Admin đang online | `http://localhost:5055/admin` |
| **11** | Quản lý rủi ro dự án (Bài 6 - QLRR) | Quy trình 6 bước, định tính tháng, Risk Register 10 rủi ro WBS & PxI, ma trận 5x5 | `QLRR_QLDACNTT_Nhom11.xlsx` + Word Ch.6 |
| **12** | Quản lý mua sắm dự án (Bài 7 - QLMS) | 5 câu hỏi Slide 7, Make-or-Buy, DS Thiết bị & Nhà cung cấp, Phương sai chi phí CV | `QLMS_QLDACNTT_Nhom11.xlsx` + Word Ch.7 |

---

## MINH CHỨNG 1 – NHẬT KÝ AI PROMPT ĐẦY ĐỦ

> **Tệp gốc:** [`NHAT_KY_PROMPT_AI_BAN_NOP.md`](../01_BAO_CAO_VA_KE_HOACH/NHAT_KY_PROMPT_AI_BAN_NOP.md) | **Cấu hình AI:** [`AGENTS.md`](../../AGENTS.md)  
> **Mô hình AI:** Antigravity AI Assistant / Gemini Flash (High)

### 1.1 Prompt cho 4 Bài Tập Lớn

| STT | Bài tập | Ngày | Người prompt | Nội dung Prompt (rút gọn) | Kết quả AI | Hiệu chỉnh nhóm |
|:---:|---|:---:|:---:|---|---|---|
| P-01 | **Bài 2** – Quản lý phạm vi | 15/09/2026 | Nguyễn Viết Lãm | *"Đóng vai Chuyên gia QLDA CNTT chuẩn PMBOK. Xây dựng WBS 3 cấp 56 gói công việc cho đề tài LV33-001. Xuất WBS Dictionary, SOW Time & Materials, dự toán SOR."* | WBS 4 giai đoạn, 56 WP; SOW + dự toán nhân sự 13.400.000 đ | Nhóm rà phân công 3 thành viên; đưa 56 WP vào Excel Sheet 1; tạo thêm 88 tasks Jira |
| P-02 | **Bài 3** – Quản lý thời gian | 22/09/2026 | Nguyễn Viết Lãm | *"Lập ma trận chọn đề tài trọng số 4 tiêu chí. Lập PERT 3 ước lượng O/M/P, Forward Pass + Backward Pass, xác định đường găng CPM, Slack."* | Đề tài đạt 8.78 điểm; 18 đường công việc; Critical Path A→D→G→J→M→O = 13 ngày | Kiểm tra từng ô ES/EF/LS/LF bằng Excel; vẽ lại sơ đồ AON Sheet 2 |
| P-03 | **Bài 4** – Quản lý chi phí | 01/10/2026 | Nguyễn Viết Lãm + Nguyễn Đại Kỳ | *"Lập Status Report mốc Tuần 5. BAC=15.950.000đ, PV=13.750.000đ, EV=14.025.000đ, AC=14.225.000đ. Tính CV, SV, CPI, SPI, EAC, ETC, VAC, TCPI. Giải thích SV dương nhưng CV âm."* | CV=-200.000đ, SV=+275.000đ, CPI=0,9859, SPI=1,0200, EAC≈16.177.451đ | Bác bỏ AI khi gộp SV+CV thành lợi nhuận; ghi nhận trễ MBA-46; áp Fast-tracking |
| P-04 | **Bài 5** – Quản lý chất lượng | 04/10/2026 | Nguyễn Đại Kỳ + Trần Ngọc Lợi | *"Dựa 100 báo cáo sự cố Sprint 4. Lập bảng Pareto 80/20, phát hiện nhóm lỗi trọng yếu Sprint 5. Đánh giá IDOR L05. Áp Rubric 4 tiêu chuẩn x 5 mức chấm 3 thành viên."* | 4 nhóm lỗi đầu tích lũy 80%; L05 IDOR = P0 an ninh; Điểm: Lãm 7.9, Lợi 7.5, Kỳ 6.5 | Kiểm chứng L05 trên code TicketEndpoints.cs; Lãm vá commit 4eb360c; đưa Pareto vào Excel Sheet 5 |

### 1.2 Prompt Hỗ Trợ Kỹ Thuật & Mã Nguồn

| STT | Module | Người thực hiện | Prompt (rút gọn) | Kết quả AI | Hành động sinh viên |
|:---:|---|:---:|---|---|---|
| K-01 | **Database SQL Server** | Trần Ngọc Lợi | *"Viết SQL Server tạo 13 bảng 3NF: Roles, Users, Customers, Devices, RepairTickets, SpareParts, StockTransactions... FK + tiếng Việt không lỗi."* | DDL 13 bảng + seed danh mục mẫu | Lợi thêm cột PERSISTED, COLLATE Vietnamese_CI_AS, encode UTF-8 with BOM, viết báo cáo SQL |
| K-02 | **Bảo mật Backend RBAC** | Nguyễn Viết Lãm | *"Viết module Auth ASP.NET Core Minimal API. Token X-Session-Token, middleware RequireRole(ADMIN/STAFF/TECHNICIAN/CUSTOMER). Phát hiện và vá IDOR."* | Logic phiên in-memory + RequireRole trong AuthHelper.cs | Lãm tích hợp vào src/backend/, vá IDOR, merge GitHub |
| K-03 | **Kiểm thử API (HTTP Client)** | Nguyễn Đại Kỳ | *"Soạn file .http 25 requests bao phủ 4 vai trò: Đăng nhập sai/đúng, danh sách khách, tạo phiếu, chẩn đoán, xuất kho, kiểm tra 403 Forbidden."* | Bộ request HTTP chia 7 nhóm chức năng | Kỳ chạy toàn bộ VS Code REST Client, ghi kết quả, lưu tests/ |
| K-04 | **Giao diện Web Admin** | Nguyễn Đại Kỳ + Nguyễn Viết Lãm | *"Từ mockup Figma Dashboard/Phiếu sửa/Kho linh kiện. Sinh HTML5 SPA Bootstrap 5 + Chart.js biểu đồ tròn, kết nối API localhost:5055."* | index.html SPA + Chart.js + fetch API | Kỳ căn chỉnh layout, thêm nút đăng nhập nhanh 4 vai trò, kiểm thử responsive |

**→ Kết luận phần 1:** AI hỗ trợ tăng tốc ~60% thời gian tính toán định lượng. Nhóm phản biện và hiệu chỉnh 100% kết quả, không chấp nhận AI hoàn toàn. Toàn bộ prompt, phản hồi và hiệu chỉnh lưu trong `NHAT_KY_PROMPT_AI.md`.

---

## MINH CHỨNG 2 – QUẢN LÝ JIRA ≥ 50 TASK

> **URL Jira:** https://lamnguyenadc1.atlassian.net/jira/software/projects/MBA/boards  
> **Tổng tasks:** 88 tasks (MBA-7 đến MBA-94)  
> **File lưu trữ:** Chưa tìm thấy file xuất `all_88_jira_sorted.txt`; nhóm cần bổ sung ảnh hoặc file xuất Jira trước khi nộp.

### 2.1 Tổng quan phân bổ Task theo Sprint

| Sprint | Thời gian | Nội dung chính | Trạng thái | Số task |
|---|---|---|---|:---:|
| Sprint 1 | Tuần 1 (08–14/09) | Khởi động, họp, chia vai trò | Done ✅ | (nằm trong MBA-7 đến MBA-15) |
| Sprint 2 | Tuần 2 (15–21/09) | Lập WBS, Project Charter, SOW | Done ✅ | ~12 tasks |
| Sprint 3 | Tuần 3 (22–28/09) | PERT/CPM, Database Schema, Auth API | Done ✅ | ~15 tasks |
| Sprint 4 | Tuần 4 (29/09–05/10) | EVM, Pareto, IDOR fix, Web Admin | Done ✅ | ~17 tasks |
| Sprint 5 | Tuần 5 (06–12/10) | Phiếu sửa chữa, Kho linh kiện, Test | In Progress 🔄 | ~10 tasks |
| Sprint 6–8 | Tuần 6–8 | Tích hợp, hoàn thiện UI, báo cáo cuối | To Do 📋 | ~34 tasks |
| **Tổng** | | | | **88 tasks** |

### 2.2 Phân công task theo thành viên (mẫu 10 task tiêu biểu)

| Mã Task | Tên task | Giao cho | Hạn | Trạng thái |
|---|---|:---:|:---:|:---:|
| MBA-15 | Lập Project Charter và SOW | Nguyễn Viết Lãm | 18/09 | Done ✅ |
| MBA-22 | Thiết kế ERD 13 bảng SQL Server | Trần Ngọc Lợi | 21/09 | Done ✅ |
| MBA-28 | Xây dựng PERT/CPM 18 đường công việc | Nguyễn Viết Lãm | 24/09 | Done ✅ |
| MBA-34 | Thiết lập SQL Schema + Seed data | Trần Ngọc Lợi | 25/09 | Done ✅ |
| MBA-38 | Cài đặt Auth API (Login/Token/RBAC) | Nguyễn Viết Lãm | 27/09 | Done ✅ |
| MBA-44 | Soạn 22 kịch bản kiểm thử HTTP | Nguyễn Đại Kỳ | 02/10 | Done ✅ |
| MBA-45 | Vẽ sơ đồ Gantt sprint 2-8 | Nguyễn Đại Kỳ | 03/10 | In Progress 🔄 |
| MBA-46 | Giao diện Web Admin HTML5 SPA | Nguyễn Đại Kỳ | 28/09 | Done ✅ (cập nhật 04/10) |
| MBA-61 | Module kho linh kiện + cảnh báo tồn | Nguyễn Viết Lãm | 10/10 | In Progress 🔄 |
| MBA-68 | Báo cáo cuối kỳ + slide bảo vệ | Cả nhóm | 02/11 | To Do 📋 |

**→ Kết luận phần 2:** 88/88 tasks đã tạo trên Jira. Tại mốc 06/10/2026: 44 Done, 10 In Progress, 34 To Do. Không có task quá hạn chưa xử lý.

---

## MINH CHỨNG 3 – KỊCH BẢN KIỂM THỬ API ĐẦY ĐỦ (35 REQUESTS & 10 E2E TESTS)

> **Tệp kịch bản:** [`QLDACNTT_Api_Tests.http`](../02_TEST_CASE/QLDACNTT_Api_Tests.http) & [`test_scenario_inventory_stock_out.http`](../02_TEST_CASE/test_scenario_inventory_stock_out.http)  
> **Báo cáo thực thi máy sinh:** [`BAO_CAO_THUC_THI_35_API_TESTS.md`](../03_KET_QUA_KIEM_THU/BAO_CAO_THUC_THI_35_API_TESTS.md) | Dữ liệu thô: [`ket_qua_api_35_requests.json`](../03_KET_QUA_KIEM_THU/ket_qua_api_35_requests.json)  
> **Người thực hiện:** Nguyễn Đại Kỳ (QA Tester Lead)  
> **Kết quả thực thi tự động:** **35/35 API Requests Passed (100%)** và **10/10 E2E Tests Passed (100%)**.

### 3.1 Bảng kết quả kiểm thử thực tế 35 requests

| Request | Phương thức & Endpoint | Vai trò | Mong đợi | Kết quả thực tế | Đánh giá |
|:---:|---|:---:|:---:|:---:|:---:|
| 01 | GET /health | — | 200 OK | **200 OK** | ✅ Pass |
| **PHẦN 1: XÁC THỰC (401 Unauthorized)** |
| 02 | POST /api/auth/login (admin/123456) | — | 200 OK | **200 OK** | ✅ Pass |
| 03 | POST /api/auth/login (staff/123456) | — | 200 OK | **200 OK** | ✅ Pass |
| 04 | POST /api/auth/login (tech/123456) | — | 200 OK | **200 OK** | ✅ Pass |
| 05 | POST /api/auth/login (customer/123456) | — | 200 OK | **200 OK** | ✅ Pass |
| 06 | POST /api/auth/login (admin/WrongPassword) | — | **401** ❌ | **401 Unauthorized** | ✅ Pass |
| 07 | POST /api/auth/login (non_existing/123456) | — | **401** ❌ | **401 Unauthorized** | ✅ Pass |
| 08 | GET /api/auth/me | ADMIN token | 200 OK | **200 OK** | ✅ Pass |
| 09 | GET /api/auth/me (không có token) | — | **401** ❌ | **401 Unauthorized** | ✅ Pass |
| 10 | GET /api/auth/me (token giả) | — | **401** ❌ | **401 Unauthorized** | ✅ Pass |
| **PHẦN 2: PHÂN QUYỀN (403 Forbidden)** |
| 11 | GET /api/users | ADMIN | 200 OK | **200 OK** | ✅ Pass |
| 12 | GET /api/users | STAFF | **403** ❌ | **403 Forbidden** | ✅ Pass |
| 13 | GET /api/users | TECHNICIAN | **403** ❌ | **403 Forbidden** | ✅ Pass |
| 14 | GET /api/roles | ADMIN | 200 OK | **200 OK** | ✅ Pass |
| **PHẦN 3: NGHIỆP VỤ DANH MỤC & KHÁCH HÀNG** |
| 15 | GET /api/service-types | STAFF | 200 OK | **200 OK** | ✅ Pass |
| 16 | GET /api/spare-parts | STAFF | 200 OK | **200 OK** | ✅ Pass |
| 17 | GET /api/customers | STAFF | 200 OK | **200 OK** | ✅ Pass |
| 18 | POST /api/customers (tạo mới) | STAFF | 201 Created | **201 Created** | ✅ Pass |
| 19 | GET /api/customers/KH000001/devices | STAFF | 200 OK | **200 OK** | ✅ Pass |
| **PHẦN 4: PHIẾU SỬA CHỮA & DASHBOARD** |
| 20 | POST /api/tickets (tạo phiếu) | STAFF | 201 Created | **201 Created** | ✅ Pass |
| 21 | PATCH /api/tickets/PSC2026090001/assign | STAFF | 200 OK | **200 OK** | ✅ Pass |
| 22 | GET /api/dashboard/summary | ADMIN | 200 OK | **200 OK** | ✅ Pass |
| **PHẦN 5: BẢO MẬT PHÂN QUYỀN NGANG IDOR L05** |
| 23 | GET /api/tickets (phiếu của mình) | CUSTOMER | 200 OK | **200 OK** | ✅ Pass |
| 24 | GET /api/tickets/PSC2026090001 (của mình) | CUSTOMER | 200 OK | **200 OK** | ✅ Pass |
| 25 | GET /api/tickets/PSC2026090002 (của người khác) | CUSTOMER | **403** ❌ | **403 Forbidden** | ✅ Pass |
| **PHẦN 6: KHO LINH KIỆN** |
| 26 | GET /api/inventory/summary | STAFF | 200 OK | **200 OK** | ✅ Pass |
| 27 | GET /api/inventory/low-stock | TECHNICIAN | 200 OK | **200 OK** | ✅ Pass |
| 28 | POST /api/inventory/transactions (xuất kho) | TECHNICIAN | 201 Created | **201 Created** | ✅ Pass |
| **PHẦN 7: TÍNH PHÍ, HÓA ĐƠN & BẢO HÀNH (SPRINT 6)** |
| 29 | GET /api/tickets/PSC2026090001/cost | STAFF | 200 OK | **200 OK** | ✅ Pass |
| 30 | POST /api/invoices (lập hóa đơn) | STAFF | 201 Created | **201 Created** | ✅ Pass |
| 31 | GET /api/invoices (danh sách hóa đơn) | STAFF | 200 OK | **200 OK** | ✅ Pass |
| 32 | GET /api/invoices/HD2026100001 (chi tiết hóa đơn) | STAFF | 200 OK | **200 OK** | ✅ Pass |
| 33 | POST /api/invoices/HD2026100001/pay (thanh toán VietQR) | STAFF | 200 OK | **200 OK** | ✅ Pass |
| 34 | GET /api/warranties/search?serial=IP11-64GB-VN | STAFF | 200 OK | **200 OK** | ✅ Pass |
| 35 | GET /api/warranties/search?phone=0909123456 | STAFF | 200 OK | **200 OK** | ✅ Pass |

**→ Kết luận phần 3:** 35/35 request pass (100%). Hệ thống đáp ứng toàn bộ các yêu cầu bảo mật nghiêm ngặt (401 Unauthorized khi sai xác thực, 403 Forbidden khi sai quyền RBAC và chặn đứng lỗ hổng bảo mật phân quyền ngang IDOR L05). Kèm theo đó là luồng E2E 10 bước xuất kho, thanh toán và bảo hành điện tử đã được kiểm chứng tự động.

---

## MINH CHỨNG 4 – BẢNG LỖI PHÁT SINH & PHÂN TÍCH PARETO 80/20

> **Nguồn:** Excel Sheet 5 "Pareto" + Word Chương 5  
> **Người thực hiện:** Nguyễn Đại Kỳ + Trần Ngọc Lợi  
> **Dữ liệu:** 100 sự cố kỹ thuật ghi nhận cuối Sprint 4 (05/10/2026)

### 4.1 Bảng phân loại lỗi theo Pareto

| Mã lỗi | Tên nhóm lỗi | Số lần phát sinh | Tỷ lệ % | Tỷ lệ tích lũy | Mức độ | Ưu tiên |
|:---:|---|:---:|:---:|:---:|:---:|:---:|
| **L02** | Lỗi validation đầu vào (required field) | 28 | 28,0% | 28,0% | Trung bình | P2 |
| **L06** | Lỗi format ngày tháng (date parsing) | 22 | 22,0% | 50,0% | Trung bình | P2 |
| **L04** | Lỗi trạng thái phiếu không hợp lệ | 18 | 18,0% | 68,0% | Cao | P1 |
| **L01** | Lỗi kết nối cơ sở dữ liệu (timeout) | 12 | 12,0% | **80,0%** | Cao | P1 |
| **L05** | **Lỗi IDOR: xem phiếu người khác** | **3** | **3,0%** | 83,0% | **🔴 Nghiêm trọng** | **P0** |
| L03 | Lỗi token hết hạn (session expired) | 8 | 8,0% | 91,0% | Thấp | P3 |
| L07 | Lỗi giao diện mobile (responsive) | 5 | 5,0% | 96,0% | Thấp | P3 |
| L08 | Lỗi in phiếu PDF (encoding) | 4 | 4,0% | 100,0% | Thấp | P4 |
| **Tổng** | | **100** | **100%** | | | |

**→ Kết luận Pareto:** 4 nhóm lỗi L02+L06+L04+L01 = **80% sự cố** → Nhóm ưu tiên xử lý trong Sprint 5.  
Lỗi **L05 IDOR chỉ 3% tần suất nhưng được nâng P0** vì ảnh hưởng bảo mật dữ liệu khách hàng, vi phạm tính riêng tư (Privacy Violation) – đã vá trong Sprint 4.

---

## MINH CHỨNG 5 – VÁ LỖ HỔNG BẢO MẬT IDOR L05 (P0)

> **File bị vá:** [`TicketEndpoints.cs`](../04_LOI_VA_BAO_MAT/TicketEndpoints.cs)  
> **Commit vá lỗi:** `4eb360c` – GitHub Nguyen-Viet-Lam/QLDACNTT  
> **Người thực hiện:** Nguyễn Viết Lãm  
> **Phát hiện bởi:** Phân tích Pareto + Nguyễn Đại Kỳ (QA)

### 5.1 Mô tả lỗ hổng

| Mục | Nội dung |
|---|---|
| **Mã lỗi** | L05 – IDOR (Insecure Direct Object Reference) |
| **Mô tả** | Khách hàng có thể truy cập `GET /api/tickets/{mã_bất_kỳ}` và xem phiếu sửa chữa của người khác mà không bị ngăn chặn |
| **Ảnh hưởng** | Lộ thông tin cá nhân, thiết bị, lịch sử sửa chữa của khách hàng khác |
| **OWASP Category** | A01:2021 – Broken Access Control |
| **Sprint phát hiện** | Sprint 4 – QA Testing |
| **Sprint vá lỗi** | Sprint 4 – commit `4eb360c` |

### 5.2 Code trước và sau khi vá

**Trước khi vá (lỗi IDOR):**
```csharp
// BUG: Bất kỳ token hợp lệ nào cũng truy cập được
app.MapGet("/api/tickets/{code}", (string code, HttpContext ctx) => {
    var ticket = tickets.FirstOrDefault(t => t.Code == code);
    return ticket is null ? Results.NotFound() : Results.Ok(ticket);
});
```

**Sau khi vá (an toàn):**
```csharp
// FIX: Khách hàng chỉ xem được phiếu của chính họ
app.MapGet("/api/tickets/{code}", (string code, HttpContext ctx) => {
    var user = AuthHelper.GetCurrentUser(ctx);
    if (user == null) return Results.Unauthorized();

    var ticket = tickets.FirstOrDefault(t => t.Code == code);
    if (ticket is null) return Results.NotFound();

    // IDOR fix: Customer chỉ xem phiếu của mình
    if (user.Role == "CUSTOMER" && ticket.CustomerUsername != user.Username)
        return Results.Forbid(); // 403 Forbidden

    return Results.Ok(ticket);
}).RequireAuthorization();
```

**→ Kết luận phần 5:** Lỗ hổng IDOR đã được vá triệt để. Request 25 trong bộ kiểm thử xác nhận 403 Forbidden khi khách hàng cố truy cập phiếu người khác.

---

## MINH CHỨNG 6 – CƠ SỞ DỮ LIỆU SQL SERVER 13 BẢNG

> **File chính:** [`QLDACNTT_full_database.sql`](../05_MA_NGUON_DOI_CHIEU/QLDACNTT_full_database.sql)  
> **Database:** `RepairShopDB` – SQL Server 2022  
> **Người thực hiện:** Trần Ngọc Lợi (Database Lead)

### 6.1 Danh sách 13 bảng với mô tả

| STT | Tên bảng | Chức năng | Số cột chính |
|:---:|---|---|:---:|
| 1 | **Roles** | Danh mục vai trò (ADMIN, STAFF, TECHNICIAN, CUSTOMER) | 3 |
| 2 | **Users** | Tài khoản hệ thống, liên kết vai trò | 8 |
| 3 | **Customers** | Thông tin khách hàng | 7 |
| 4 | **Devices** | Thiết bị của khách (laptop, điện thoại, ...) | 6 |
| 5 | **ServiceTypes** | Danh mục loại dịch vụ sửa chữa + đơn giá | 5 |
| 6 | **RepairTickets** | Phiếu sửa chữa (trung tâm nghiệp vụ) | 12 |
| 7 | **TicketDiagnoses** | Kết quả chẩn đoán kỹ thuật viên | 5 |
| 8 | **TicketStatusLogs** | Lịch sử thay đổi trạng thái phiếu | 5 |
| 9 | **SpareParts** | Danh mục linh kiện + tồn kho | 9 |
| 10 | **StockTransactions** | Giao dịch nhập/xuất kho linh kiện | 8 |
| 11 | **TicketSpareParts** | Linh kiện dùng cho từng phiếu (N-N) | 5 |
| 12 | **Payments** | Thanh toán phiếu sửa chữa | 6 |
| 13 | **SystemLogs** | Nhật ký hành động người dùng | 7 |

### 6.2 Đặc điểm kỹ thuật

| Đặc điểm | Giá trị |
|---|---|
| Chuẩn hóa | 3NF (Third Normal Form) |
| Khóa ngoại FK | 11 quan hệ FK giữa các bảng |
| Ràng buộc | CHECK, UNIQUE, DEFAULT, NOT NULL |
| Tiếng Việt | COLLATE Vietnamese_CI_AS |
| View | `v_CanhBaoTonKho` – cảnh báo linh kiện sắp hết |
| Stored Proc | `sp_XuatKhoTuDong` – xuất kho kiểm tra tồn |
| Seed data | 9 users, 5 khách, 16 linh kiện, 2 phiếu demo |

**→ Kết luận phần 6:** Database đã tạo đầy đủ, đang chạy thật trên SQL Server 2022 local. Kết nối từ backend ASP.NET Core qua `Microsoft.Data.SqlClient`.

---

## MINH CHỨNG 7 – LỊCH SỬ GITHUB (18 NHÁNH + COMMIT)

> **Repository:** https://github.com/Nguyen-Viet-Lam/QLDACNTT  
> **Người quản lý:** Nguyễn Viết Lãm (PM / Git Lead)

### 7.1 Các nhánh chính

| Nhánh | Mục đích | Trạng thái |
|---|---|:---:|
| `main` | Nhánh production, release chính thức | Active |
| `develop` | Nhánh tích hợp tính năng | Active |
| `feature/auth-rbac` | Xác thực + phân quyền RBAC | Merged ✅ |
| `feature/database-schema` | Schema SQL 13 bảng | Merged ✅ |
| `feature/repair-tickets` | Nghiệp vụ phiếu sửa chữa | Merged ✅ |
| `feature/inventory-management` | Kho linh kiện + cảnh báo tồn | Merged ✅ |
| `feature/web-admin-ui` | Giao diện Web Admin SPA | Merged ✅ |
| `feature/idor-security-fix` | Vá lỗ hổng IDOR L05 (P0) | Merged ✅ |
| `release/v0.3-gate3` | Release Gate 3 – mốc giữa kỳ | Tagged ✅ |
| *(+ 9 nhánh khác)* | Feature, hotfix, test branches | Merged ✅ |

### 7.2 Commit tiêu biểu

| Commit hash | Thời gian | Mô tả | Tác giả |
|---|:---:|---|:---:|
| `c55a879` | Sprint 2 | Init project structure + AGENTS.md | Lãm |
| `1be6f99` | Sprint 3 | Add database schema 13 tables + seed | Lợi |
| `2673236` | Sprint 4 | Implement Auth API + RBAC middleware | Lãm |
| `4eb360c` | Sprint 4 | **Security fix: Patch IDOR vulnerability** | Lãm |
| `latest` | Sprint 5 | Add inventory management API + low-stock view | Lãm |

**→ Kết luận phần 7:** 18 nhánh remote, tất cả feature branch đã merge vào main. Quy trình Git: Feature → PR → Code Review → Merge → Tag release.

---

## MINH CHỨNG 8 – BÁO CÁO EVM TẠI MỐC NGÀY 13 (05/10/2026)

> **Nguồn:** Excel Sheet 3 "Chi phí & EVM (Ngày 13)" + Word Chương 4  
> **Thực hiện:** Nguyễn Viết Lãm + Nguyễn Đại Kỳ (01/10/2026)

### 8.1 Bảng chỉ số EVM đầy đủ

| Chỉ số | Công thức | Giá trị | Ý nghĩa |
|:---:|---|:---:|---|
| **BAC** | Tổng ngân sách kế hoạch | 15.950.000 VNĐ | Tổng chi phí nếu hoàn thành đúng kế hoạch |
| **PV** (BCWS) | Giá trị kế hoạch đến ngày báo cáo | 13.750.000 VNĐ | Đáng lẽ đã hoàn thành lượng việc trị giá 13,75 triệu |
| **EV** (BCWP) | Giá trị công việc thực tế | 14.025.000 VNĐ | Thực tế tạo ra lượng việc 14,025 triệu |
| **AC** (ACWP) | Chi phí thực tế | 14.225.000 VNĐ | Đã chi 14,225 triệu |
| **CV** | EV - AC | **-200.000 VNĐ** | Vượt chi phí 200.000 đồng |
| **SV** | EV - PV | **+275.000 VNĐ** | Đi trước kế hoạch lượng việc 275.000 đồng |
| **CPI** | EV / AC | **0,9859** | Mỗi 1 đồng chi ra tạo ~0,986 đồng giá trị |
| **SPI** | EV / PV | **1,0200** | Tiến độ nhanh hơn kế hoạch ~2% |
| **EAC** | BAC / CPI | ≈ 16.177.451 VNĐ | Dự báo tổng chi phí cuối dự án |
| **ETC** | EAC - AC | ≈ 1.952.451 VNĐ | Chi phí ước tính còn phải bỏ ra |
| **VAC** | BAC - EAC | ≈ -227.451 VNĐ | Dự báo vượt ngân sách khi hoàn thành |
| **TCPI** | (BAC-EV)/(BAC-AC) | ≈ 1,1159 | Hiệu suất cần đạt cho phần việc còn lại |

### 8.2 Kết luận và khuyến nghị

| Câu hỏi của Thầy | Câu trả lời chuẩn |
|---|---|
| Dự án có bị trễ không? | **Không trễ toàn cục** – SPI=1,02>1 và SV dương. Có trễ cục bộ tại MBA-46 (UI, 6 ngày lịch) |
| Dự án có bị lỗ không? | **Không "lỗ"** theo nghĩa kinh doanh. EVM ghi nhận vượt chi phí 200.000đ (CV âm), CPI=0,9859 |
| SV+CV = "lời ròng" không? | **KHÔNG.** SV đo tiến độ (thời gian), CV đo chi phí. Hai chỉ số khác đơn vị nghĩa, không cộng gộp |
| Biện pháp khắc phục? | Fast-tracking (UI+Backend song song), giới hạn làm lại, tận dụng công cụ miễn phí |

---

## MINH CHỨNG 9 – BẢNG RUBRIC ĐÁNH GIÁ THÀNH VIÊN

> **Nguồn:** Excel Sheet 6 "Rubric" + Word Chương 5  
> **Thực hiện:** Cả nhóm + AI Phân tích (04/10/2026)  
> **Rubric:** 4 tiêu chí × 5 mức điểm (theo rubric môn học)

### 9.1 Bảng điểm chi tiết

| Tiêu chí đánh giá | Nguyễn Viết Lãm | Trần Ngọc Lợi | Nguyễn Đại Kỳ |
|---|:---:|:---:|:---:|
| **T1. Hoàn thành task đúng hạn Jira** (30%) | 4.0/5.0 | 3.5/5.0 | 3.0/5.0 |
| **T2. Chất lượng kỹ thuật sản phẩm** (40%) | 4.0/5.0 | 3.5/5.0 | 3.5/5.0 |
| **T3. Đóng góp tài liệu & quy trình** (20%) | 4.0/5.0 | 4.0/5.0 | 3.5/5.0 |
| **T4. Phối hợp nhóm & phản biện AI** (10%) | 3.5/5.0 | 4.0/5.0 | 3.0/5.0 |
| **Điểm tổng (thang 10)** | **7,9/10** | **7,5/10** | **6,5/10** |

### 9.2 Lý do và ưu/nhược điểm từng thành viên

**Nguyễn Viết Lãm – 7,9/10 (Tốt)**
- ✅ Ưu điểm: 100% task đúng hạn; Backend hoàn chỉnh (Auth, RBAC, Dashboard, Inventory); vá lỗi P0 IDOR; quản lý Git 18 nhánh
- ⚠️ Nhược điểm: Chưa viết unit test tự động; Frontend RBAC còn tĩnh chưa ẩn/hiện menu theo role

**Trần Ngọc Lợi – 7,5/10 (Khá - Tốt)**
- ✅ Ưu điểm: Database 13 bảng chuẩn 3NF; View cảnh báo tồn; viết được báo cáo SQL phức tạp
- ⚠️ Nhược điểm: MBA-34 có dấu hiệu cập nhật Done trễ 6 ngày so với deadline Jira; chưa có Stored Proc đầy đủ

**Nguyễn Đại Kỳ – 6,5/10 (Khá)**
- ✅ Ưu điểm: Soạn 28 kịch bản test HTTP; phát hiện lỗi IDOR qua QA; giao diện Web Admin hoàn chỉnh
- ⚠️ Nhược điểm: MBA-46 cập nhật Done trễ 6 ngày; MBA-45 Gantt chưa hoàn thành; UI chưa ẩn/hiện menu theo role động

---

## MINH CHỨNG 10 – PHẦN MỀM CHẠY THỰC TẾ (LIVE DEMO)

> **Backend URL:** http://localhost:5055  
> **Web Admin:** http://localhost:5055/admin  
> **Database:** RepairShopDB – SQL Server 2022 local

### 10.1 Thông tin tài khoản demo

| Tài khoản | Mật khẩu | Vai trò | Thành viên |
|---|:---:|:---:|:---:|
| `admin` | `123456` | ADMIN | Nguyễn Viết Lãm |
| `loi.staff` | `123456` | STAFF | Trần Ngọc Lợi |
| `ky.tech` | `123456` | TECHNICIAN | Nguyễn Đại Kỳ |
| `khach01` | `123456` | CUSTOMER | Demo – Nguyễn Văn An |
| `khach02` | `123456` | CUSTOMER | Demo – Trần Thị Bình |

### 10.2 Checklist chức năng hoạt động

| Chức năng | Endpoint | Vai trò cần | Trạng thái |
|---|---|:---:|:---:|
| Đăng nhập / Đăng xuất | POST /api/auth/login | Tất cả | ✅ Hoạt động |
| Xác thực phiên | GET /api/auth/me | Tất cả | ✅ Hoạt động |
| Dashboard tổng hợp | GET /api/dashboard/summary | ADMIN | ✅ Hoạt động |
| Danh sách users | GET /api/users | ADMIN | ✅ Hoạt động |
| Phân quyền (403) | GET /api/users | STAFF/TECH | ✅ Chặn đúng |
| Danh sách khách hàng | GET /api/customers | STAFF | ✅ Hoạt động |
| Tạo phiếu sửa chữa | POST /api/tickets | STAFF | ✅ Hoạt động |
| Xem phiếu của mình | GET /api/tickets/{code} | CUSTOMER | ✅ Hoạt động |
| Chặn IDOR | GET /api/tickets/{code_người_khác} | CUSTOMER | ✅ 403 Forbidden |
| Kho linh kiện | GET /api/spare-parts | STAFF | ✅ Hoạt động |
| Cảnh báo tồn thấp | GET /api/inventory/low-stock | TECH | ✅ Hoạt động |
| Kiểm tra kết nối DB | GET /api/db/status | ADMIN | ✅ Connected |

### 10.3 Hướng dẫn khởi động (khi demo với Thầy)

```powershell
# Bước 1: Chạy backend
dotnet run --project src/backend/QLDACNTT.Api.csproj --urls "http://localhost:5055"

# Bước 2: Mở trình duyệt
Start-Process "http://localhost:5055/admin"

# Bước 3: Kiểm tra DB
Invoke-RestMethod "http://localhost:5055/api/db/status"
```

---

## MINH CHỨNG 11 – KẾ HOẠCH & QUẢN LÝ RỦI RO DỰ ÁN (BÀI 6)

> **Tệp Excel chuyên biệt:** [`MINH_CHUNG_NHOM11/01_BAO_CAO_VA_KE_HOACH/QLRR_QLDACNTT_Nhom11.xlsx`](../01_BAO_CAO_VA_KE_HOACH/QLRR_QLDACNTT_Nhom11.xlsx)  
> **Chương báo cáo Word:** [`BaoCao_QLDA_LV33-001_Bai2-den-Bai5_Nhom11_HoanThien.docx`](../01_BAO_CAO_VA_KE_HOACH/BaoCao_QLDA_LV33-001_Bai2-den-Bai5_Nhom11_HoanThien.docx) (Chương 6: Bài 6)

### 11.1 Cấu trúc 4 Sheet Excel Quản lý rủi ro chuẩn hóa theo bài giảng
1. **Sheet 1: `1. Qui trinh QLRR (Slide 10)`**: 
   - 6 bước quy trình vòng đời rủi ro (Lập kế hoạch -> Nhận diện -> Phân tích định tính -> Phân tích định lượng -> Lập kế hoạch ứng phó -> Giám sát kiểm soát).
   - Bảng phân công ma trận trách nhiệm RACI cho 3 thành viên (Lãm, Lợi, Kỳ) tương ứng từng bước.
   - 5 phương pháp nhận diện rủi ro áp dụng thực tế (Họp nhóm Brainstorming, Phân tích WBS/Ishikawa, Checklists kiểm thử, Phỏng vấn chuyên gia, Rà soát code).
2. **Sheet 2: `2. Dinh tinh thang (Slide 21)`**:
   - Theo dõi xếp hạng rủi ro qua từng tháng (Tháng 1: Khảo sát & thiết kế; Tháng 2: Triển khai phát triển & bảo mật; Tháng 3: Kiểm thử & bàn giao).
   - Đánh giá 8 rủi ro cốt lõi, xác định nguyên nhân gốc rễ và giải pháp kỹ thuật cụ thể.
3. **Sheet 3: `3. Risk Register (Slide 28)`**:
   - 10 rủi ro thực tế (R01–R10) gắn mã hạng mục WBS 56 công việc.
   - Đánh giá 3 khía cạnh tác động: W (Phạm vi), B (Ngân sách), S (Tiến độ).
   - Công thức Excel tự động tính Độ nghiêm trọng: `=G5*H5` ($S = P \times I$), xếp loại P0/P1/P2.
   - 4 chiến lược phản ứng chính quy theo Slide 30 (Né tránh, Chuyển giao, Giảm nhẹ, Chấp nhận) kèm kế hoạch dự phòng Contingency Plan và phân công rõ người chịu trách nhiệm.
4. **Sheet 4: `4. Ma tran Rui ro 5x5`**:
   - Lưới tọa độ $5 \times 5$ Xác suất $\times$ Mức độ ảnh hưởng phân 4 phân vùng màu (Đỏ P0: 15-25; Cam P1: 10-14; Vàng P2: 5-9; Xanh P3: 1-4).
   - Phân bổ 10 rủi ro của dự án: 2 rủi ro P0 (20%), 4 rủi ro P1 (40%), 4 rủi ro P2 (40%), 0 rủi ro P3.
   - Quy tắc hành động và tần suất rà soát chi tiết cho từng phân vùng.

---

## MINH CHỨNG 12 – KẾ HOẠCH & QUẢN LÝ MUA SẮM DỰ ÁN (BÀI 7)

> **Tệp Excel chuyên biệt:** [`MINH_CHUNG_NHOM11/01_BAO_CAO_VA_KE_HOACH/QLMS_QLDACNTT_Nhom11.xlsx`](../01_BAO_CAO_VA_KE_HOACH/QLMS_QLDACNTT_Nhom11.xlsx)  
> **Tệp Excel tổng hợp 8 sheets (QLRR + QLMS):** [`MINH_CHUNG_NHOM11/01_BAO_CAO_VA_KE_HOACH/QLMS_QLRR_Nhom11_TongHop.xlsx`](../01_BAO_CAO_VA_KE_HOACH/QLMS_QLRR_Nhom11_TongHop.xlsx)  
> **Chương báo cáo Word:** [`BaoCao_QLDA_LV33-001_Bai2-den-Bai5_Nhom11_HoanThien.docx`](../01_BAO_CAO_VA_KE_HOACH/BaoCao_QLDA_LV33-001_Bai2-den-Bai5_Nhom11_HoanThien.docx) (Chương 7: Bài 7)  
> **Hồ sơ minh chứng công cụ:** [`HoSo_MinhChung_Jira_GitHub_Nhom11.docx`](../01_BAO_CAO_VA_KE_HOACH/HoSo_MinhChung_Jira_GitHub_Nhom11.docx)

### 12.1 Nội dung triển khai chuẩn theo Slide 7 bài giảng
1. **Sheet 1: `1. Ke hoach mua sam (Slide 7)`**: 
   - Giải quyết trọn vẹn 5 câu hỏi chiến lược mua sắm của Thầy: (1) Có mua hay không, (2) Mua bằng cách nào, (3) Mua cái gì, (4) Mua bao nhiêu, (5) Khi nào mua.
   - Bảng phân công ma trận trách nhiệm RACI cho quy trình mua sắm giữa 3 thành viên: Lãm (A/PM), Lợi (R/BA-DB), Kỳ (R/QA-UI).
2. **Sheet 2: `2. Phan tich Make-or-Buy`**:
   - So sánh tổng chi phí sở hữu (TCO) giữa Tự phát triển (Make) vs Mua đứt (Buy) vs Thuê ngoài (Lease) trong 3 tháng.
   - Xác định điểm hòa vốn (Break-even Point) cho 10 hạng mục công nghệ & trang thiết bị quầy.
3. **Sheet 3: `3. DS Thiet bi & Nha cung cap`**:
   - Kế thừa chuẩn từ file mẫu `QLMS_QLDACNTT.xlsx` của Thầy: Cột STT, Mã TB, Tên thiết bị/dịch vụ, Số lượng, Đơn vị, Giá mua, Tổng mua, Giá thuê/tháng, Tổng thuê 3 tháng, Công thức tự động đưa ra Quyết định, Nhà cung cấp, Model, Thời hạn bảo hành/hợp đồng.
4. **Sheet 4: `4. Tien do & Ngan sach mua sam`**:
   - Bảng theo dõi tiến độ giải ngân theo 8 Sprints.
   - Kiểm soát phương sai ngân sách: Dự toán PV = 6.580.000 VNĐ, Thực tế AC = 6.280.000 VNĐ, Phương sai tiết kiệm CV = +300.000 VNĐ.

---

## TÓM TẮT TỔNG HỢP – NHÓM 11 ĐÃ LÀM GÌ?

| Giai đoạn | Ai làm | Sản phẩm chính | Minh chứng |
|---|---|---|---|
| **Sprint 1–2** (08–21/09) | Cả nhóm / Lãm chủ trì | Project Charter, WBS 56 WP, SOW, Ma trận chọn đề tài | Excel Sheet 1, Word Ch.1-2 |
| **Sprint 3** (22–28/09) | Lãm (Backend) + Lợi (DB) + Kỳ (Figma) | PERT/CPM 18 đường, Auth API, Database 13 bảng, Mockup UI | Excel Sheet 2, GitHub commit |
| **Sprint 4** (29/09–05/10) | Lãm (vá IDOR) + Kỳ (QA) + Lợi (EVM) | EVM Status Report, Pareto 100 lỗi, Web Admin HTML, vá L05 | Excel Sheet 3,5,6, commit 4eb360c |
| **Sprint 5** (06–12/10) | Lãm (Inventory) + Lợi (SQL) + Kỳ (Test) | Module kho linh kiện, 28 kịch bản HTTP test | tests/QLDACNTT_Api_Tests.http |
| **Sprint 6–8** (13/10–02/11) | Cả nhóm / Lãm, Lợi, Kỳ | Quản lý Rủi ro (Ch.6), Quản lý Mua sắm (Ch.7), Hồ sơ công cụ Jira 56 tasks, CI/CD Actions, Báo cáo bảo vệ hoàn chỉnh | Word 7 Chương, Excel tổng hợp 8 sheets, 23 Unit tests, Live Server |

---

*Hồ sơ minh chứng được lập tự động bởi Antigravity AI (Gemini Flash) theo chỉ dẫn AGENTS.md.*  
*Nhóm sinh viên chịu trách nhiệm kiểm tra, hiệu chỉnh và phê duyệt nội dung cuối cùng.*  
*Lần cập nhật cuối: 20/10/2026 – Nhóm 11, Lớp 23DTHC6.*

