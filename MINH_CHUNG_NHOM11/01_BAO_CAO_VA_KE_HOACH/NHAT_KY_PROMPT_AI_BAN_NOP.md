# NHẬT KÝ SỬ DỤNG AI (AI PROMPT LOG) – NHÓM 11
**Học phần:** Quản lý Dự án Công nghệ Thông tin (QLDACNTT) – Lớp 23DTHC6  
**Đề tài:** Hệ thống quản lý tổng thể cho cửa hàng sửa chữa (LV33-001)  
**Nhóm sinh viên thực hiện:**
- Nguyễn Viết Lãm (MSSV: 2380601183) – Nhóm trưởng / PM / Backend Lead
- Trần Ngọc Lợi (MSSV: 2380601292) – BA / Database Lead
- Nguyễn Đại Kỳ (MSSV: 2380601178) – UI/UX Designer / QA Tester Lead

**Tệp cấu hình chỉ dẫn trợ lý AI gốc:** [`AGENTS.md`](./AGENTS.md)  
**Mô hình AI sử dụng:** Antigravity AI Assistant / Gemini 3.8 Flash (High)  

---

## 1. NGUYÊN TẮC VÀ VAI TRÒ SỬ DỤNG AI TRONG DỰ ÁN

1. **Vai trò của AI (AI Role):** Trợ lý Quản lý Dự án CNTT (PM Assistant). Hỗ trợ lập kế hoạch, cấu trúc tài liệu, tính toán các mô hình định lượng (PERT, CPM, EVM, Pareto) và đóng vai trò phản biện logic.
2. **Quy tắc phối hợp (Human-in-the-Loop):**
   - AI **không làm thay** con người và không tự quyết định kỹ thuật.
   - Tập thể sinh viên trực tiếp nhập dữ liệu thực tế, kiểm tra công thức chéo bằng Excel, kiểm thử mã nguồn trên GitHub và phê duyệt kết quả cuối cùng.
   - Tuyệt đối không tự bịa đặt số liệu giả mạo.

---

## 2. BẢNG NHẬT KÝ PROMPT AI CHO CÁC BÀI TẬP LỚN (BÀI 2 ĐẾN BÀI 5)

| STT | Bài tập lớn | Mục tiêu nghiệp vụ | Người prompt & Thời gian | Nội dung câu lệnh (Prompt) chi tiết gửi AI | Kết quả AI phản hồi | Đánh giá phản biện & Hiệu chỉnh của nhóm sinh viên |
|:---:|---|---|:---:|---|---|---|
| **01** | **BÀI 2**<br>Quản lý phạm vi | Xây dựng Project Charter, Statement of Work (SOW) và WBS 3 cấp | **Nguyễn Viết Lãm**<br>*15/09/2026* | *"Đóng vai trò Chuyên gia QLDA CNTT theo chuẩn PMBOK. Hãy xây dựng bảng phân rã công việc WBS 3 cấp gồm 56 gói công việc chi tiết cho đề tài Cửa hàng sửa chữa LV33-001, bắt đầu từ Tuần 2 (bỏ Tuần 1). Xuất bảng WBS Dictionary có mã task, tên công việc, người phụ trách (Lãm, Lợi, Kỳ) và tiêu chí hoàn thành. Lập mẫu SOW theo hợp đồng Time & Materials và dự toán chi phí SOR."* | AI đề xuất cấu trúc WBS 4 giai đoạn, 56 gói công việc (Work Packages), khung điều khoản SOW và bảng dự toán nhân sự 13.400.000 VNĐ. | - **Kiểm tra:** Nhóm rà soát lại khối lượng công việc, thấy phân công cân đối cho 3 thành viên.<br>- **Hiệu chỉnh:** Nhóm đưa 56 WP vào Sheet 1 file Excel và tạo thêm các sub-task kỹ thuật lên Jira thành 88 tasks. |
| **02** | **BÀI 3**<br>Quản lý thời gian | Ma trận chọn đề tài có trọng số, Sơ đồ mạng PERT và Đường găng CPM | **Nguyễn Viết Lãm**<br>*22/09/2026* | *"Hãy thiết lập ma trận chọn đề tài có trọng số (Weighted Scoring Model) với 4 tiêu chí để so sánh giữa 'Cửa hàng sửa chữa' và 'Quản lý quán Cafe'. Tiếp theo, lập sơ đồ mạng PERT với 3 ước lượng O, M, P tính thời gian kỳ vọng Te. Áp dụng thuật toán tiến tới (Forward Pass) và quay lui (Backward Pass) để xác định đường găng thiết yếu (Critical Path), đường ngắn nhất và độ trễ dự trữ Slack."* | AI đưa ra ma trận chọn đề tài đạt 8.78 điểm; phân tích 18 đường công việc, xác định đường găng dài nhất là 13 ngày (chuỗi A->D->G->J->M->O), đường ngắn nhất 2 ngày (B->C), và công thức tính Slack = LS - ES = 0. | - **Kiểm tra:** Nhóm dùng công thức Excel kiểm tra độc lập từng ô $ES, EF, LS, LF$.<br>- **Hiệu chỉnh:** Nhóm vẽ lại sơ đồ nút mạng AON chuẩn trực quan vào Sheet 2 Excel và Mục 3.3 Báo cáo Word. |
| **03** | **BÀI 4**<br>Quản lý chi phí & Status | Báo cáo trạng thái (Status Report) và tính toán bộ chỉ số EVM mốc Ngày 13 | **Nguyễn Viết Lãm & Nguyễn Đại Kỳ**<br>*01/10/2026* | *"Lập Báo cáo trạng thái Status Report tại mốc Tuần 5 (Sprint 5) cho Nhóm 11. Dựa trên số liệu kế hoạch chi tiết BAC = 15.950.000 VNĐ, PV = 13.750.000 VNĐ, EV = 14.025.000 VNĐ, AC = 14.225.000 VNĐ. Hãy tính toán toàn bộ chỉ số EVM: CV, SV, CPI, SPI, EAC, ETC, VAC, TCPI. Giải thích ý nghĩa của việc SV dương nhưng CV âm và đưa ra khuyến nghị quản lý."* | AI tính toán ra: $CV = -200.000\text{ đ}, SV = +275.000\text{ đ}, CPI = 0,9859, SPI = 1,0200, EAC = 16.177.451\text{ đ}, TCPI = 1,1159$. AI phân tích dự án đang đi trước tiến độ 2% nhưng vượt chi phí 200k. | - **Phản biện quan trọng:** AI từng thử cộng $SV + CV = 75.000\text{ đ}$ làm tiền lời; nhóm đã **bác bỏ ngay** vì SV đo tiến độ còn CV đo chi phí.<br>- **Giải trình:** Ghi nhận trễ cục bộ ở task UI MBA-46 và áp dụng Fast-tracking. |
| **04** | **BÀI 5**<br>Quản lý chất lượng & Nhân sự | Phân tích Pareto sự cố lỗi (80/20) và Bảng đánh giá Rubric thành viên | **Nguyễn Đại Kỳ & Trần Ngọc Lợi**<br>*04/10/2026* | *"Dựa trên 100 báo cáo sự cố kỹ thuật ghi nhận cuối Sprint 4, hãy lập bảng thống kê phân loại lỗi, tính tỷ lệ % và tỷ lệ tích lũy để phân tích Pareto theo quy luật 80/20. Phát hiện nhóm lỗi trọng yếu cần ưu tiên Sprint 5. Đánh giá trường hợp lỗi phân quyền IDOR. Áp dụng bảng Rubric 4 tiêu chuẩn x 5 mức điểm của môn học để chấm điểm đóng góp thực tế cho Lãm, Lợi, Kỳ."* | AI phân tích chỉ ra 4 nhóm lỗi đầu tiên (L02, L06, L04, L01) tích lũy đạt đúng 80% sự cố. Cảnh báo lỗi L05 (Xem đơn người khác - IDOR) dù chỉ chiếm 3% nhưng là lỗi an ninh tối nghiêm trọng, phải ưu tiên P0 xử lý ngay. Bảng điểm thành viên: Lãm 7.9, Lợi 7.5, Kỳ 6.5. | - **Kiểm tra:** Nhóm kiểm chứng lỗi L05 trên code thật `TicketEndpoints.cs` và Lãm đã vá dứt điểm (Commit `4eb360c`).<br>- **Hiệu chỉnh:** Nhóm đưa phân tích Pareto vào Sheet 5 và bảng điểm Rubric chuẩn vào Sheet 6 Excel. |

---

## 3. BẢNG NHẬT KÝ PROMPT AI HỖ TRỢ KỸ THUẬT & MÃ NGUỒN (CODE, DATABASE, TEST)

| STT | Module kỹ thuật | Người thực hiện | Câu lệnh Prompt | Kết quả AI sinh ra | Hành động thực tế của sinh viên |
|:---:|---|:---:|---|---|---|
| **01** | **Cơ sở dữ liệu (SQL Server)** | **Trần Ngọc Lợi** | *"Hãy viết kịch bản SQL Server tạo 13 bảng quan hệ 3NF cho cửa hàng sửa chữa (Roles, Users, Customers, Devices, ServiceTypes, RepairTickets, SpareParts, StockTransactions...). Thêm ràng buộc khóa ngoại FK và xử lý font tiếng Việt không bị lỗi."* | Khung DDL 13 bảng và script seed danh mục mẫu. | Lợi bổ sung thuộc tính tính toán `PERSISTED` (QuotedTotal), thêm mã `COLLATE Vietnamese_CI_AS`, chuyển file sang UTF-8 with BOM và viết truy vấn báo cáo. |
| **02** | **Bảo mật Backend & RBAC** | **Nguyễn Viết Lãm** | *"Viết module Auth xác thực trong C# ASP.NET Core Minimal API. Hỗ trợ cấp token X-Session-Token và middleware kiểm tra quyền RequireRole('ADMIN', 'STAFF', 'TECHNICIAN', 'CUSTOMER'). Phát hiện và vá lỗ hổng IDOR trên API lấy chi tiết phiếu sửa chữa."* | Logic xác thực phiên in-memory và phương thức kiểm tra quyền `RequireRole` trong `AuthHelper.cs`. | Lãm tích hợp vào `src/backend/`, vá logic kiểm tra xem người dùng thường chỉ được xem phiếu của chính họ, merge vào nhánh chính GitHub. |
| **03** | **Kiểm thử tự động API (HTTP Client)** | **Nguyễn Đại Kỳ** | *"Soạn file kịch bản kiểm thử API REST theo định dạng .http gồm 25 requests bao phủ 4 vai trò người dùng: Đăng nhập sai/đúng, lấy danh sách khách hàng, tạo phiếu, chẩn đoán, xuất kho linh kiện và kiểm tra lỗi phân quyền 403 Forbidden."* | Bộ request HTTP Client hoàn chỉnh chia theo 7 nhóm chức năng. | Kỳ chạy thử toàn bộ 25 request trên Visual Studio / VS Code REST Client, ghi nhận kết quả và lưu tại `tests/QLDACNTT_Api_Tests.http`. |
| **04** | **Giao diện Web Admin (Figma -> HTML)** | **Nguyễn Đại Kỳ & Nguyễn Viết Lãm** | *"Dựa trên mockup Figma các màn hình Dashboard, Phiếu sửa chữa, Kho linh kiện. Hãy sinh mã nguồn giao diện HTML5 Single Page App sử dụng Bootstrap 5, FontAwesome và Chart.js biểu đồ tròn, kết nối trực tiếp với backend qua API http://localhost:5055."* | Mã nguồn giao diện SPA một trang `index.html` tích hợp Chart.js và gọi fetch API. | Kỳ căn chỉnh lại layout, thêm các nút đăng nhập nhanh 4 vai trò, kiểm thử responsive và lưu tại `src/web-admin/index.html`. |

---

## 4. BẰNG CHỨNG ĐỐI CHIẾU THỰC TẾ TRÊN MÁY TÍNH (EVIDENCE MATRIX)

Khi Giảng viên yêu cầu kiểm tra minh chứng AI trên máy tính, nhóm mở trực tiếp các tệp sau:

1. **Tệp cấu hình quy tắc AI:**  
   👉 [`AGENTS.md`](./AGENTS.md) *(Thư mục gốc)*
2. **Tệp nhật ký Prompt AI này:**  
   👉 [`NHAT_KY_PROMPT_AI.md`](./NHAT_KY_PROMPT_AI.md) *(Thư mục gốc)*
3. **Báo cáo tổng hợp đối chiếu số liệu:**  
   👉 [`docs/BAO_CAO_DOI_CHIEU_BAO_VE_2026-10-06.md`](./docs/BAO_CAO_DOI_CHIEU_BAO_VE_2026-10-06.md)
4. **Mã nguồn kịch bản kiểm thử API đã chạy:**  
   👉 [`tests/QLDACNTT_Api_Tests.http`](./tests/QLDACNTT_Api_Tests.http)
5. **Cơ sở dữ liệu SQL Server 13 bảng:**  
   👉 [`database/QLDACNTT_full_database.sql`](./database/QLDACNTT_full_database.sql)
6. **Mã nguồn Giao diện Web Admin đã tích hợp:**  
   👉 [`src/web-admin/index.html`](./src/web-admin/index.html)

---

## 5. KẾT LUẬN VỀ HIỆU QUẢ SỬ DỤNG AI CỦA NHÓM 11

* **Tăng tốc độ phân tích định lượng:** Nhờ AI hỗ trợ tính toán thuật toán PERT/CPM và bộ chỉ số EVM, nhóm tiết kiệm được hơn 60% thời gian tính toán thủ công và tránh được các sai sót số học.
* **Nâng cao khả năng phản biện:** Quá trình làm việc với AI giúp các thành viên rèn luyện tư duy phản biện (Critical Thinking) – tiêu biểu là việc phát hiện ra lỗi logic gộp $CV + SV$ thành lợi nhuận và việc nâng cấp lỗi bảo mật IDOR L05 lên ưu tiên P0.
* **Tính trung thực học thuật:** Toàn bộ câu lệnh prompt, dữ liệu đưa vào và hiệu chỉnh của sinh viên đều được lưu trữ công khai, minh bạch ngay trong mã nguồn dự án.
