# Cấu trúc phân rã công việc & Kế hoạch nguồn lực (WBS)

**Dự án:** Hệ thống quản lý tổng thể cho cửa hàng sửa chữa - LV33-001  
**Nhóm:** Nhóm 11 - Lớp 23DTHC6  
**Thời gian:** 08/09/2026 - 03/11/2026

Dự án chia thành 7 giai đoạn chính, triển khai theo Agile/Scrum trong 8 tuần. Ước lượng công tính theo người-ngày (n/đ); nhóm 3 thành viên làm bán thời gian. Lịch trình đã loại trừ ngày nghỉ Thứ Bảy, Chủ Nhật.

Danh sách task chi tiết nằm ở [docs/TASKS.md](../TASKS.md). Bảng WBS dưới đây là **baseline quản lý cấp cao** dùng để báo cáo tiến độ, phân bổ nguồn lực và tính chi phí quy đổi.

| Mã WBS | Gói công việc / Nhiệm vụ | Sản phẩm chuyển giao | Phụ trách | Tuần | Công (n/đ) | Bắt đầu | Kết thúc |
|---|---|---|---|---|---:|---|---|
| **1** | **Khởi động & Lập kế hoạch** | Kế hoạch dự án | PM | 1 | **3** | 08/09/2026 | 10/09/2026 |
| 1.1 | Lập charter, scope, kế hoạch, phân công | Charter, Scope, WBS | PM (Lãm) | 1 | 2 | 08/09/2026 | 09/09/2026 |
| 1.2 | Thiết lập công cụ & môi trường | Repo, board, môi trường | PM (Lãm) | 1 | 1 | 10/09/2026 | 10/09/2026 |
| **2** | **Phân tích yêu cầu** | Tài liệu đặc tả | BA | 1-2 | **5** | 11/09/2026 | 17/09/2026 |
| 2.1 | Khảo sát nghiệp vụ cửa hàng | Biên bản khảo sát | BA (Lợi) | 1 | 2 | 11/09/2026 | 14/09/2026 |
| 2.2 | Đặc tả yêu cầu & thiết kế luồng | SRS, User Stories | BA (Lợi) | 1-2 | 3 | 15/09/2026 | 17/09/2026 |
| **3** | **Thiết kế hệ thống** | Sơ đồ & Mockup | Nhóm | 2-3 | **9** | 18/09/2026 | 28/09/2026 |
| 3.1 | Thiết kế kiến trúc & API | Sơ đồ kiến trúc, API spec | PM (Lãm) | 2-3 | 2 | 18/09/2026 | 21/09/2026 |
| 3.2 | Thiết kế CSDL (SQL Server) | ERD, CSDL | BA/Database (Lợi) | 2 | 3 | 18/09/2026 | 22/09/2026 |
| 3.3 | Thiết kế giao diện Web & Mobile | Mockup UI | UI/UX (Kỳ) | 2-3 | 4 | 23/09/2026 | 28/09/2026 |
| **4** | **Phát triển** | Hệ thống MVP | Cả nhóm | 3-6 | **28** | 22/09/2026 | 20/10/2026 |
| 4.1 | Xây dựng Backend & API | API, mã nguồn | PM/Backend (Lãm) | 3-6 | 12 | 22/09/2026 | 07/10/2026 |
| 4.2 | Xây dựng Web Admin | Web Admin | Frontend (Kỳ) | 3-6 | 8 | 29/09/2026 | 08/10/2026 |
| 4.3 | Xây dựng Mobile App | Mobile App | Frontend/Mobile (Kỳ) | 4-6 | 8 | 09/10/2026 | 20/10/2026 |
| **5** | **Tích hợp & Kiểm thử** | Bản build & Bug log | Nhóm | 6-7 | **8** | 21/10/2026 | 27/10/2026 |
| 5.1 | Tích hợp các thành phần hệ thống | Bản build tích hợp | PM (Lãm) | 6 | 3 | 21/10/2026 | 23/10/2026 |
| 5.2 | Kiểm thử chức năng & API | Test case, bug log | QA (Kỳ), BA (Lợi) | 6-7 | 5 | 21/10/2026 | 27/10/2026 |
| **6** | **Triển khai & Nghiệm thu** | Hệ thống live | Nhóm | 7-8 | **7** | 28/10/2026 | 03/11/2026 |
| 6.1 | Triển khai môi trường demo | Hệ thống chạy live | PM (Lãm) | 7 | 2 | 28/10/2026 | 29/10/2026 |
| 6.2 | Chuẩn bị dữ liệu mẫu & kịch bản demo | Dữ liệu, kịch bản | BA/Database (Lợi) | 7-8 | 2 | 28/10/2026 | 29/10/2026 |
| 6.3 | Thuyết trình & nghiệm thu | Slide, biên bản | Cả nhóm | 8 | 3 | 30/10/2026 | 03/11/2026 |
| **7** | **Đóng dự án & Tài liệu** | Hồ sơ cuối | PM | 8 | **4** | 02/11/2026 | 03/11/2026 |
| 7.1 | Hoàn thiện tài liệu HDSD | Tài liệu HDSD | UI/UX (Kỳ) | 8 | 2 | 02/11/2026 | 03/11/2026 |
| 7.2 | Báo cáo cuối & bài học kinh nghiệm | Final report | PM (Lãm) | 8 | 2 | 02/11/2026 | 03/11/2026 |
| | | | | | **64** | | |

## Phân bổ nguồn lực

| Thành viên | Vị trí / Vai trò | Trách nhiệm chính | Công (n/đ) | Tỉ lệ |
|---|---|---|---:|---:|
| Nguyễn Viết Lãm | PM/Scrum Master, Backend/API, DevOps | Lập kế hoạch, công cụ/môi trường, kiến trúc & API, Backend, tích hợp, triển khai demo, báo cáo cuối kỳ | 25 | 39.1% |
| Trần Ngọc Lợi | BA/PO, Database | Khảo sát nghiệp vụ, đặc tả yêu cầu, thiết kế luồng, thiết kế CSDL, dữ liệu mẫu, kịch bản demo, hỗ trợ kiểm thử | 13 | 20.3% |
| Nguyễn Đại Kỳ | UI/UX, Frontend, QA/Tester | Mockup UI, Web Admin, Mobile App, kiểm thử chức năng/API, tài liệu HDSD, hỗ trợ thuyết trình | 26 | 40.6% |
| **Tổng cộng** | **3 thành viên** | **Làm bán thời gian trong 8 tuần** | **64** | **100%** |

## Ước lượng chi phí

| Khoản mục | Cơ sở tính | Ước tính (VNĐ) |
|---|---|---:|
| Nhân lực quy đổi | 64 người-ngày x 200.000 VNĐ/người-ngày | 12.800.000 |
| Phân bổ cho Nguyễn Viết Lãm | 25 n/đ x 200.000 VNĐ | 5.000.000 |
| Phân bổ cho Trần Ngọc Lợi | 13 n/đ x 200.000 VNĐ | 2.600.000 |
| Phân bổ cho Nguyễn Đại Kỳ | 26 n/đ x 200.000 VNĐ | 5.200.000 |
| Hạ tầng đám mây / hosting | Công cụ mã nguồn mở, tài khoản miễn phí sinh viên, localhost | 0 |
| Domain, chứng chỉ, thiết bị test | Dùng môi trường local và thiết bị cá nhân | 0 |
| **Tổng chi phí tiền mặt thực tế** | Đồ án môn học, không chi trả thực tế | **0** |
| **Tổng chi phí quy đổi** | Bao gồm nhân lực quy đổi | **12.800.000** |

> Chi phí nhân lực là số **quy đổi để minh họa giá trị công sức**, không phải khoản chi trả thật. Chi phí tiền mặt thực tế của đồ án là 0 VNĐ vì nhóm dùng công cụ miễn phí, môi trường local và thiết bị cá nhân.

## Cột mốc quan trọng

| Cột mốc | Ngày | Điều kiện đạt |
|---|---|---|
| M1 - Chốt kế hoạch & phạm vi | 10/09/2026 | Charter, Scope, WBS được thống nhất |
| M2 - Chốt đặc tả yêu cầu | 17/09/2026 | SRS và User Stories có tiêu chí nghiệm thu |
| M3 - Chốt thiết kế | 28/09/2026 | ERD, API spec, mockup UI hoàn chỉnh |
| M4 - Backend nền tảng chạy được | 05/10/2026 | Đăng nhập, phân quyền, quản lý khách hàng hoạt động |
| M5 - Nghiệp vụ lõi hoàn thành | 12/10/2026 | Lập phiếu, chuyển trạng thái, xuất linh kiện trừ tồn đúng |
| M6 - MVP đầy đủ chức năng | 19/10/2026 | Đủ 16 User Stories, có dashboard và Mobile App |
| M7 - Hệ thống sạch bug nghiêm trọng | 26/10/2026 | Không còn bug Critical và Major |
| M8 - Nghiệm thu | 03/11/2026 | Demo thành công, hồ sơ bàn giao đầy đủ |
