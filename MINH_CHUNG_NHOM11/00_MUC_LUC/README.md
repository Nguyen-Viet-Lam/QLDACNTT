# BỘ MINH CHỨNG DỰ ÁN NHÓM 11 — LV33-001

**Học phần:** Quản lý dự án Công nghệ thông tin (QLDACNTT)  
**Lớp:** 23DTHC6 | **Mã đề tài:** LV33-001  
**Đề tài:** Hệ thống quản lý tổng thể cho cửa hàng sửa chữa  
**Ngày hoàn thiện hồ sơ:** 20/10/2026  

---

## 1. Cấu trúc cây thư mục minh chứng chuẩn

```text
MINH_CHUNG_NHOM11/
├── 00_MUC_LUC/
│   ├── README.md                              <- Bản tóm tắt tổng quan bộ minh chứng (file này)
│   ├── MINH_CHUNG_BAO_VE_NHOM11.md            <- Hồ sơ minh chứng 10 mục bảo vệ chi tiết
│   └── BAO_CAO_DOI_CHIEU_BAO_VE_2026-10-06.md <- Báo cáo đối chiếu số liệu ban đầu
├── 01_BAO_CAO_VA_KE_HOACH/
│   ├── BaoCao_QLDA_LV33-001_Bai2-den-Bai5_Nhom11_HoanThien.docx <- File Word 1: Báo cáo tổng thể đồ án 7 chương (Chương 1-5 + Chương 6 QLRR + Chương 7 QLMS)
│   ├── HoSo_MinhChung_Jira_GitHub_Nhom11.docx                   <- File Word 2: Hồ sơ bảo vệ & minh chứng công cụ Jira (56 tasks), GitHub, CI/CD & Tests
│   ├── KeHoach_QLDA_LV33-001_Bai2-den-Bai5_Nhom11.xlsx          <- File Excel 1: Kế hoạch tổng thể tích hợp WBS/PERT/Gantt/EVM/Pareto/Rubric
│   ├── QLMS_QLRR_Nhom11_TongHop.xlsx                            <- File Excel 2: Bảng tính tổng hợp 8 sheets Quản lý Rủi ro (Bài 6) & Quản lý Mua sắm (Bài 7)
│   ├── QLRR_QLDACNTT_Nhom11.xlsx                                <- Bảng tính Quản lý rủi ro riêng biệt (4 sheets: Quy trình, Định tính tháng, Risk Register, Ma trận 5x5)
│   ├── QLMS_QLDACNTT_Nhom11.xlsx                                <- Bảng tính Quản lý mua sắm riêng biệt (4 sheets: 5 câu hỏi Slide 7, Make-or-Buy, Thiết bị & NCC, Ngân sách)
│   ├── So_Do_AON_Ve_San.xlsx                                    <- Sơ đồ AON vẽ sẵn
│   ├── NHAT_KY_PROMPT_AI_BAN_NOP.md                             <- Nhật ký prompt AI bản nộp
│   └── NHAT_KY_PROMPT_AI_TREN_GIT.md                            <- Nhật ký prompt AI đồng bộ Git
├── 02_TEST_CASE/
│   ├── QLDACNTT_Api_Tests.http                                  <- 35 requests kiểm thử API phân quyền & nghiệp vụ
│   ├── test_scenario_inventory_stock_out.http                   <- 10 kịch bản E2E xuất kho & thanh toán (Completed)
│   ├── AuthAndRbacTests.cs                                      <- Unit test xác thực và phân quyền RBAC
│   └── BusinessLogicTests.cs                                    <- Unit test logic nghiệp vụ & giá cả
├── 03_KET_QUA_KIEM_THU/
│   ├── ket_qua_dotnet_2026-10-20.trx                            <- Báo cáo xUnit máy sinh (23/23 Passed)
│   ├── ket_qua_api_35_requests.json                             <- Kết quả thực thi máy sinh 35 API requests (100% Pass)
│   ├── BAO_CAO_THUC_THI_35_API_TESTS.md                         <- Báo cáo chi tiết 35 API tests, payload 401/403/IDOR
│   ├── ket_qua_e2e_kho_10_tests.json                            <- Kết quả thực thi máy sinh 10 kịch bản E2E kho
│   ├── BAO_CAO_E2E_XUAT_KHO.md                                  <- Báo cáo E2E xuất kho, chặn âm tồn và thanh toán
│   └── anh_chup/README.md                                       <- Hướng dẫn tra cứu ảnh chụp minh chứng
├── 04_LOI_VA_BAO_MAT/
│   ├── DEFECT_LOG.md                                            <- Nhật ký theo dõi & xử lý lỗi thực tế (P0 IDOR, validation)
│   ├── MBA-60_bao_mat_owasp_web_admin.md                        <- Báo cáo rà soát an ninh OWASP Web Admin
│   └── TicketEndpoints.cs                                       <- Mã nguồn điểm nút có vá lỗ hổng IDOR L05
├── 05_MA_NGUON_DOI_CHIEU/
│   ├── QLDACNTT_full_database.sql                               <- CSDL SQL Server 13 bảng 3NF kèm seed data
│   └── ci-cd.yml                                                <- Pipeline GitHub Actions tự động build & test
├── 06_DANG_BAI_TU_DONG/
│   ├── Lich_Dang_Bai_Hoc_Tu_Dong.xlsx                           <- Lịch đăng bài học tự động (5 bài đã đăng)
│   ├── auto_publish_social.mjs                                  <- Script đăng bài tự động qua API
│   └── social_config.example.json                               <- File mẫu cấu hình an toàn (không lộ token)
└── 07_ANH_MINH_CHUNG_CU/
    ├── README.md                                                <- Bảng chỉ mục và mô tả 8 ảnh minh chứng
    ├── MC01_Tien_Do_Gantt_MS_Project.png                        <- Biểu đồ tiến độ Gantt MS Project Sprint 2-8
    ├── MC02_Kien_Truc_He_Thong_3_Lop.png                        <- Sơ đồ kiến trúc hệ thống 3 lớp
    ├── MC03_So_Do_Mang_PERT_CPM_AON.png                         <- Sơ đồ mạng AON PERT/CPM đường găng 13 ngày
    ├── MC04_Bao_Cao_Trang_Thai_EVM_Ngay13.png                   <- Báo cáo EVM Ngày 13 (CPI=0.9859, SPI=1.0200)
    ├── MC05_Bieu_Do_Pareto_Loi_Ky_Thuat.png                     <- Biểu đồ Pareto 80/20 phân tích 100 sự cố
    ├── MC06_Bieu_Do_Xuong_Ca_Ishikawa_L02.png                   <- Biểu đồ xương cá Ishikawa lỗi L02
    ├── MC07_Giao_Dien_Web_Admin_Dashboard.png                   <- Ảnh chụp Web Admin Dashboard port 5055
    ├── MC08_Cau_Hinh_Chi_Dan_AI_AGENTS_md.png                   <- Ảnh chụp quy tắc trợ lý AI trong AGENTS.md
    └── image1.png ... image8.png                                <- Tệp ảnh gốc để đảm bảo tương thích
```

---

## 2. Tóm tắt kết quả kiểm thử & xác minh kỹ thuật

- **Unit Test (xUnit .NET 8):** **23/23 Passed**, 0 Failed, 0 Skipped.  
  File kết quả TRX: `03_KET_QUA_KIEM_THU/ket_qua_dotnet_2026-10-20.trx`.
- **Bộ kiểm thử API (REST Client):** **35/35 Requests Passed (100%)**.  
  File kết quả JSON: `03_KET_QUA_KIEM_THU/ket_qua_api_35_requests.json`.  
  Báo cáo chi tiết: `03_KET_QUA_KIEM_THU/BAO_CAO_THUC_THI_35_API_TESTS.md`.
- **Kịch bản E2E Xuất kho & Thanh toán:** **10/10 Tests Passed (100%)**.  
  File kết quả JSON: `03_KET_QUA_KIEM_THU/ket_qua_e2e_kho_10_tests.json`.  
  Báo cáo chi tiết: `03_KET_QUA_KIEM_THU/BAO_CAO_E2E_XUAT_KHO.md`.
- **Vá lỗi bảo mật IDOR (P0 - L05):** Đã kiểm thử thực tế và xác nhận trả về `403 Forbidden` kèm mã lỗi vi phạm phân quyền ngang `HORIZONTAL_ACCESS_CONTROL_VIOLATION`.
- **Chặn xuất kho vượt tồn:** Đã kiểm thử cố tình xuất số lượng `999` và hệ thống trả về đúng `400 Bad Request`.

---

## 3. Chính sách an toàn bảo mật (Security Policy)

- Tuyệt đối **không lưu trữ Access Token, Cookie hoặc Mật khẩu thật** trong mã nguồn và bộ hồ sơ minh chứng.
- Token Facebook đã được loại bỏ hoàn toàn khỏi `social_config.json` và thay bằng biến môi trường `FACEBOOK_PAGE_ACCESS_TOKEN`.
- File mẫu cấu hình an toàn được cung cấp tại `06_DANG_BAI_TU_DONG/social_config.example.json`.

---

## 4. Lưu ý cho Giảng viên & Hội đồng chấm thi

1. **Minh chứng 10 mục bảo vệ đầy đủ:** Xem file [`00_MUC_LUC/MINH_CHUNG_BAO_VE_NHOM11.md`](./MINH_CHUNG_BAO_VE_NHOM11.md).
2. **Khởi động Backend Prototype để kiểm tra trực tiếp:**
   ```powershell
   dotnet run --project src/backend/QLDACNTT.Api.csproj --urls "http://localhost:5055"
   ```
   Sau đó mở trình duyệt tại: `http://localhost:5055/admin`.
3. **Phân định dữ liệu:**
   - Dữ liệu lỗi trong `04_LOI_VA_BAO_MAT/DEFECT_LOG.md` là lỗi kỹ thuật thực tế phát hiện trong mã nguồn.
   - Bảng 100 sự cố trong Báo cáo Word / Excel (Chương 5) là dữ liệu mô phỏng bài tập quản lý chất lượng để thực hành phân tích Pareto 80/20 và Ishikawa theo yêu cầu môn học.
