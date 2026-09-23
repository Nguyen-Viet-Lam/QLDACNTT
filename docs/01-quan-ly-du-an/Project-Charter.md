# Tôn chỉ Dự án (Project Charter)

**Tên dự án:** Hệ thống quản lý tổng thể cho cửa hàng sửa chữa
**Mã đề tài:** LV33-001
**Nhóm:** Nhóm 11 — Lớp 23DTHC6 — Học kỳ 2627HK1A
**Ngày bắt đầu:** 08/09/2026 · **Ngày kết thúc dự kiến:** 03/11/2026 (8 tuần)
**Kinh phí:** 0 VNĐ — sử dụng công cụ mã nguồn mở và tài khoản miễn phí dành cho sinh viên
**Giám đốc dự án:** Nguyễn Viết Lãm — 0332929050 — lamnguyenadc@gmail.com

## 1. Mục tiêu dự án

- Xây dựng hệ thống phần mềm quản lý tổng thể cho cửa hàng sửa chữa, quản lý bốn thực thể lõi: phiếu sửa chữa, linh kiện, khách hàng và bảo hành.
- Hoàn thành sản phẩm khả dụng tối thiểu (MVP) đạt tối thiểu 80% phạm vi baseline và 100% chức năng cốt lõi (Must-have) trong 8 tuần.
- Hệ thống vận hành ổn định, phân quyền chi tiết (RBAC) và tích hợp các báo cáo thống kê cần thiết.

## 2. Danh sách ngôn ngữ và công cụ sử dụng

### Ngôn ngữ lập trình

- **Backend & API:** C# (ASP.NET Core Web API .NET 8) với Entity Framework Core
- **Web Admin:** HTML5, CSS3, JavaScript, Bootstrap 5, Chart.js
- **Mobile App:** Dart (Flutter)
- **Cơ sở dữ liệu:** SQL — Microsoft SQL Server

### Công cụ phần mềm

- **IDE:** Visual Studio
- **Quản lý CSDL:** SQL Server Management Studio (SSMS)
- **Kiểm thử API:** Postman
- **Vẽ sơ đồ thiết kế:** StarUML (Use Case, Sequence, BFD), Draw.io, Figma
- **Quản lý mã nguồn & dự án:** GitHub (Gitflow), Jira Software (Scrum)
- **Làm việc nhóm & lưu hồ sơ:** Google Drive, Zalo, Google Meet

## 3. Cách tiếp cận

- Triển khai theo phương pháp Agile/Scrum, chia thành 8 sprints (1 tuần/sprint).
- Sử dụng WBS để phân rã công việc và biểu đồ Gantt để theo dõi tiến độ.
- Phân chia và gộp 5 vai trò chuyên môn cho 3 thành viên, đảm bảo mỗi thành viên đều có khối lượng công việc độc lập.
- Quản lý mã nguồn theo Gitflow, mọi thay đổi đi qua Pull Request có ít nhất 1 approve.

## 4. Vai trò và trách nhiệm

| Vai trò | Họ tên | MSSV | Lớp | Liên hệ |
|---|---|---|---|---|
| PM / Scrum Master + Backend & API + DevOps | Nguyễn Viết Lãm | 2380601183 | 23DTHC6 | 0332929050 · lamnguyenadc@gmail.com |
| BA / PO + Database | Trần Ngọc Lợi | 2380601292 | 23DTHC6 | 0337536353 · ngocloihdkg@gmail.com |
| UI/UX + Frontend + QA / Tester | Nguyễn Đại Kỳ | 2380601178 | 23DTHC6 | 0798308118 · daikyvctvn123@gmail.com |

## 5. Tiêu chí thành công

- Hoàn thành MVP đúng hạn 8 tuần với đầy đủ chức năng cốt lõi.
- Phân quyền chi tiết (RBAC) và hệ thống báo cáo thống kê hoạt động đúng yêu cầu.
- Linh kiện xuất dùng trừ tồn kho chính xác 100% so với phiếu.
- API xử lý giao dịch phản hồi dưới 1 giây.
- Không còn bug mức Critical và Major khi nghiệm thu.
- Được giảng viên nghiệm thu đạt yêu cầu; demo thành công với dữ liệu mẫu.
- Bàn giao đầy đủ tài liệu theo danh mục sản phẩm chuyển giao.

## 6. Xác nhận (Sign-off)

| Thành viên | Chữ ký | Ngày |
|---|---|---|
| Nguyễn Viết Lãm | | |
| Nguyễn Đại Kỳ | | |
| Trần Ngọc Lợi | | |

**Chú thích:** Nhóm gồm 3 thành viên, đã thống nhất kiêm nhiệm các vai trò (tổng hợp 5 vị trí thành 3 người phụ trách chính) nhằm đáp ứng yêu cầu khối lượng đồ án.
