# HƯỚNG DẪN CẬP NHẬT & CHUẨN HÓA JIRA - NHÓM 11 (LỚP 23DTHC6)

> **Đề tài:** Hệ thống quản lý tổng thể cho cửa hàng sửa chữa (LV33-001)  
> **Mã dự án (Project Key):** `MBA`  
> **Tổng số task:** **56 tasks** (`MBA-01` đến `MBA-56`)  
> **Cột trạng thái:** `TO DO` | `IN PROGRESS` | `DONE`  
> **Mốc thời gian hiện tại:** Đang ở **Sprint 5** (Tuần 5: 05/10 - 12/10/2026)

---

## 1. HƯỚNG DẪN DÀNH CHO NGUYỄN VIẾT LÃM (SCRUM MASTER / PM)

Lãm chịu trách nhiệm quản lý cấu trúc các Sprint và trạng thái của toàn bộ Board:

### Bước 1: Quản lý trạng thái các Sprint (Mục Backlog)
1. **Sprint 2 (Tuần 2: 10/09 - 17/09/2026):** Gồm các task `MBA-01` đến `MBA-08` $\rightarrow$ Đã xong, bấm **Complete Sprint**.
2. **Sprint 3 (Tuần 3: 17/09 - 28/09/2026):** Gồm các task `MBA-09` đến `MBA-20` $\rightarrow$ Đã xong, bấm **Complete Sprint**.
3. **Sprint 4 (Tuần 4: 28/09 - 05/10/2026):** Gồm các task `MBA-21` đến `MBA-35` $\rightarrow$ Đã xong, bấm **Complete Sprint**.
4. **Sprint 5 (Tuần 5: 05/10 - 12/10/2026):** Gồm các task `MBA-36` đến `MBA-48` $\rightarrow$ Bấm **Start Sprint** (đây là **Active Sprint** đang chạy phục vụ buổi chấm Review).
5. **Sprint 6, 7, 8 (Tuần 6 đến Tuần 8):** Gồm các task `MBA-49` đến `MBA-56` $\rightarrow$ Giữ nguyên trạng thái `TO DO` nằm trong mục **Backlog**.

### Bước 2: Cập nhật các task của Lãm tại Sprint 5
- `MBA-38` (Thiết kế kiến trúc 3 lớp): Chuyển sang **`DONE`**.
- `MBA-39` (Backend Auth & RBAC Token): Chuyển sang **`DONE`**.
- `MBA-40` (API Lập phiếu và cập nhật trạng thái): Kéo vào **`IN PROGRESS`**.
- `MBA-41` (API Chẩn đoán & Báo giá linh kiện): Kéo vào **`IN PROGRESS`**.
- `MBA-29` (Vá lỗ hổng bảo mật IDOR L05): Chuyển sang **`DONE`**, để lại comment:
  > *"Đã vá IDOR trên TicketEndpoints.cs và merge vào develop (Commit 4eb360c trên GitHub)"*

---

## 2. HƯỚNG DẪN DÀNH CHO TRẦN NGỌC LỢI (BA / DATABASE LEAD)

Lợi vào Jira, bấm thanh tìm kiếm hoặc lọc theo: **Assignee = Tran Ngoc Loi**

### Bước 1: Kiểm tra task các Sprint cũ (Sprint 2, 3, 4)
Đảm bảo tất cả các task sau đều nằm ở cột **`DONE`**:
- `MBA-04`: Khảo sát quy trình nghiệp vụ cửa hàng sửa chữa.
- `MBA-05`: Phân tích bài toán quản lý và xác định ràng buộc.
- `MBA-11`: Chi tiết hóa 16 User Stories theo các vai trò.
- `MBA-12`: Hoàn thiện tài liệu SRS 8 nhóm chức năng lõi.
- `MBA-14`: Thiết kế sơ đồ Use Case tổng quát.
- `MBA-25`: Thiết kế mô hình dữ liệu ERD 13 bảng 3NF.

### Bước 2: Cập nhật task của Lợi tại Sprint 5
- **Task `MBA-32` (Tạo SQL Schema 13 bảng & Seed Data):** Kéo sang **`DONE`**.
  - **Comment trong task:**
    > *"Đã hoàn thành script schema 13 bảng chuẩn khóa ngoại FK và dữ liệu mẫu UTF-8 BOM"*
- **Task `MBA-33` (Xử lý tiếng Việt & Ràng buộc CSDL):** Kéo sang **`DONE`**.
- **Task `MBA-34` (Viết truy vấn SQL báo cáo thống kê):** Kéo sang **`IN PROGRESS`** (hoặc `DONE`).
  - **Comment trong task:**
    > *"Đã viết xong bộ query báo cáo doanh thu, tồn kho và tiến độ sửa chữa (Commit MBA-34 trên GitHub)"*
- **Task `MBA-35` (Kiểm tra toàn vẹn dữ liệu xuất/nhập kho):** Để ở **`IN PROGRESS`**.

---

## 3. HƯỚNG DẪN DÀNH CHO NGUYỄN ĐẠI KỲ (UI/UX DESIGNER / QA TESTER)

Kỳ vào Jira, bấm thanh tìm kiếm hoặc lọc theo: **Assignee = Nguyen Dai Ky**

### Bước 1: Kiểm tra task các Sprint cũ (Sprint 2, 3, 4)
Đảm bảo tất cả các task sau đều nằm ở cột **`DONE`**:
- `MBA-02`: Lập ma trận RACI cho 3 thành viên.
- `MBA-07`: Lập Test Plan ban đầu cho dự án.
- `MBA-15`: Thiết kế Wireframe & Mockup màn hình Đăng nhập.
- `MBA-18`: Thiết kế Mockup Khách hàng & Thiết bị.

### Bước 2: Cập nhật task của Kỳ tại Sprint 5
- **Task `MBA-44` (Soạn kịch bản kiểm thử HTTP Client 25 requests):** Kéo sang **`DONE`**.
  - **Comment trong task:**
    > *"Đã hoàn thiện file test HTTP Client 25 request kiểm tra 4 vai trò, phát hiện lỗi IDOR L05 đã báo Lãm fix (Commit MBA-44 trên GitHub)"*
- **Task `MBA-46` (Thiết kế Mockup Figma Web Admin Dashboard & Phiếu):** Kéo sang **`IN PROGRESS`** (hoặc `DONE`).
  - **Đính kèm (Attachment):** Kỳ bấm vào task này, tải 1-2 tấm ảnh mockup PNG trong thư mục `minh_chung_hinh_anh/` (ví dụ `figma_mockup_dashboard.png`) đính kèm trực tiếp vào task trên Jira.
- **Task `MBA-47` (Kiểm thử giao diện & Validation Form):** Để ở **`IN PROGRESS`**.
  - **Ghi chú:** Đây chính là task gây trễ hạn nhẹ được ghi trong báo cáo EVM ($SV = -700.000$ đ do phải chỉnh lại form chọn linh kiện). Lãm đã hỗ trợ Kỳ xử lý trong Sprint 5 này.

---

## 4. BÍ QUYẾT TRÌNH BÀY JIRA KHI THẦY CHẤM REVIEW GIỮA KỲ

Khi Thầy yêu cầu mở Jira lên kiểm tra:

1. **Chứng minh số lượng task $\ge 50$:**
   - Mở màn hình **Filters $\rightarrow$ All Issues** (hoặc gõ `project = MBA`).
   - Chỉ vào góc trên hiển thị: **`1-56 of 56 issues`** $\rightarrow$ Thầy thấy ngay nhóm có 56 task, đạt và vượt chỉ tiêu $\ge 50$ task.
2. **Chứng minh quy trình Scrum chuẩn thực tế:**
   - Mở màn hình **Active Sprints**: Cho Thầy thấy Sprint 5 đang chạy, có các cột `TO DO`, `IN PROGRESS`, `DONE` rõ ràng.
   - Các task `DONE` khớp y hệt với mã nguồn commit trên GitHub và nội dung trong Báo cáo Word.
3. **Chứng minh phân công đều cho cả 3 thành viên:**
   - Bấm vào bộ lọc **Assignee** trên Jira board:
     - Chọn **Lãm** $\rightarrow$ Hiển thị 24 task của Lãm (PM/Backend).
     - Chọn **Lợi** $\rightarrow$ Hiển thị 16 task của Lợi (BA/Database).
     - Chọn **Kỳ** $\rightarrow$ Hiển thị 16 task của Kỳ (UI/QA).
   - Thầy sẽ đánh giá nhóm phân công lao động rất rõ ràng, không ai bị trống việc hay làm trùng việc của nhau.
