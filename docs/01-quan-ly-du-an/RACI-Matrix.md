# Ma trận RACI - LV33-001

**Dự án:** Hệ thống quản lý tổng thể cho cửa hàng sửa chữa  
**Nhóm:** Nhóm 11 - Lớp 23DTHC6

## Quy ước

| Ký hiệu | Ý nghĩa | Diễn giải |
|---|---|---|
| **R** | Responsible | Người trực tiếp làm |
| **A** | Accountable | Người chịu trách nhiệm cuối cùng, duyệt kết quả |
| **C** | Consulted | Được hỏi ý kiến trước khi làm |
| **I** | Informed | Được thông báo kết quả |

## Thành viên

| Ký hiệu | Thành viên | Vai trò |
|---|---|---|
| **L** | Nguyễn Viết Lãm | PM / Scrum Master + Backend & API + DevOps |
| **Lo** | Trần Ngọc Lợi | BA / PO + Database |
| **K** | Nguyễn Đại Kỳ | UI/UX + Frontend + QA / Tester |
| **GV** | Giảng viên hướng dẫn | Nghiệm thu |

## Ma trận theo giai đoạn WBS

| Mã WBS | Gói công việc | L | Lo | K | GV |
|---|---|---|---|---|---|
| **1** | **Khởi động & Lập kế hoạch** | | | | |
| 1.1 | Lập charter, scope, WBS, phân công | A, R | C | C | I |
| 1.2 | Thiết lập công cụ & môi trường | A, R | I | I | |
| **2** | **Phân tích yêu cầu** | | | | |
| 2.1 | Khảo sát nghiệp vụ cửa hàng | C | A, R | C | I |
| 2.2 | Đặc tả yêu cầu (SRS) | C | A, R | C | I |
| 2.3 | Phân rã User Stories & tiêu chí nghiệm thu | C | A, R | C | I |
| **3** | **Thiết kế hệ thống** | | | | |
| 3.1 | Thiết kế kiến trúc & API | A, R | C | C | I |
| 3.2 | Thiết kế CSDL (ERD, từ điển dữ liệu) | C | A, R | I | I |
| 3.3 | Thiết kế giao diện Web & Mobile | C | C | A, R | I |
| 3.4 | Thiết kế sơ đồ UML (Use Case, Sequence, BFD) | C | A, R | C | I |
| **4** | **Phát triển** | | | | |
| 4.1 | Xây dựng Backend & API | A, R | C | C | |
| 4.2 | Xây dựng Web Admin | C | C | A, R | |
| 4.3 | Xây dựng Mobile App | C | I | A, R | |
| 4.4 | Script CSDL & truy vấn báo cáo | C | A, R | I | |
| **5** | **Tích hợp & Kiểm thử** | | | | |
| 5.1 | Tích hợp các thành phần hệ thống | A, R | C | R | |
| 5.2 | Lập test case & kiểm thử chức năng | C | C | A, R | |
| 5.3 | Kiểm thử API bằng Postman | C | C | A, R | |
| 5.4 | Sửa lỗi Backend | A, R | C | I | |
| 5.5 | Sửa lỗi Web Admin & Mobile | C | I | A, R | |
| **6** | **Triển khai & Nghiệm thu** | | | | |
| 6.1 | Triển khai môi trường demo | A, R | C | I | I |
| 6.2 | Chuẩn bị dữ liệu mẫu & kịch bản demo | C | A, R | C | I |
| 6.3 | Thuyết trình & nghiệm thu | R | R | R | A |
| **7** | **Đóng dự án & Tài liệu** | | | | |
| 7.1 | Tài liệu hướng dẫn sử dụng | C | C | A, R | I |
| 7.2 | Báo cáo kết quả kiểm thử | I | C | A, R | I |
| 7.3 | Báo cáo cuối kỳ & bài học kinh nghiệm | A, R | C | C | I |

## Nguyên tắc áp dụng

- Mỗi gói công việc chỉ có **một người giữ chữ A** để tránh tình trạng không ai chịu trách nhiệm cuối.
- Người giữ **A** là người báo cáo tiến độ gói việc đó trong Daily Standup.
- Người giữ **C** phải phản hồi trong 24 giờ; quá hạn thì người giữ A được quyền quyết định và ghi lại vào báo cáo tiến độ.
- Gói việc 6.3 có cả 3 thành viên giữ R vì mỗi người trình bày phần mình phụ trách; chữ A thuộc giảng viên vì giảng viên là người nghiệm thu.
