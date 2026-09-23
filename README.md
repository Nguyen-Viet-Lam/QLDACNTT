# LV33-001 - Hệ thống quản lý tổng thể cho cửa hàng sửa chữa

> Đồ án môn **Quản lý dự án CNTT** - Học kỳ 2627HK1A - Lớp 23DTHC6 - Nhóm 11

Repo này lưu hồ sơ dự án đã thực hiện trong **3 tuần đầu**: khởi động dự án, phân tích yêu cầu, thiết kế hệ thống, thiết kế CSDL/API và kế hoạch kiểm thử. Repo có thêm một **backend prototype tối giản** để minh họa hướng triển khai API, nhưng chưa phải hệ thống hoàn chỉnh.

## Thành viên nhóm

| MSSV | Họ và tên | Vai trò |
|---|---|---|
| 2380601183 | Nguyễn Viết Lãm *(Nhóm trưởng)* | PM / Scrum Master + Backend & API + DevOps |
| 2380601292 | Trần Ngọc Lợi | BA / PO + Database |
| 2380601178 | Nguyễn Đại Kỳ | UI/UX + Frontend + QA / Tester |

## Phạm vi hệ thống

**Trong phạm vi**

- Quản lý tài khoản và phân quyền theo vai trò.
- Quản lý khách hàng và thiết bị.
- Quản lý phiếu sửa chữa, trạng thái xử lý, chẩn đoán và báo giá.
- Quản lý linh kiện, nhập/xuất kho và cảnh báo tồn thấp.
- Lập hóa đơn, ghi nhận thanh toán nội bộ.
- Sinh và tra cứu bảo hành.
- Dashboard báo cáo doanh thu, phiếu và linh kiện.
- Mobile App cho khách hàng tra cứu tiến độ và bảo hành.

**Ngoài phạm vi**

- Cổng thanh toán trực tuyến.
- Hóa đơn điện tử theo chuẩn thuế.
- Tích hợp phần mềm kế toán.
- Quản lý nhân sự, lương, chấm công.
- Bán hàng online cho linh kiện.
- Đọc mã vạch/RFID bằng thiết bị chuyên dụng.

## Hiện trạng sau 3 tuần

| Tuần | Trọng tâm | Kết quả |
|---|---|---|
| Tuần 1 | Khởi động & lập kế hoạch | Charter, Scope, WBS, RACI, Cost Baseline |
| Tuần 2 | Phân tích yêu cầu | SRS, User Stories, actor, phạm vi chức năng |
| Tuần 3 | Thiết kế hệ thống | API spec, Database Design, SQL schema/seed/query, Test Plan |

## Thành phần kỹ thuật đã có

| Thành phần | Vị trí | Mục đích |
|---|---|---|
| Use Case tổng quát | `docs/03-thiet-ke/use-case/use-case-tong-quat.drawio` | Sơ đồ 4 actor và các nhóm chức năng chính |
| Database SQL | `database/schema`, `database/seed`, `database/queries` | Script tạo CSDL, dữ liệu nền và truy vấn báo cáo |
| Backend prototype | `src/backend` | API mẫu tối giản để kiểm tra hướng triển khai |

## Cấu trúc repo

```text
QLDACNTT/
├── .github/
│   ├── ISSUE_TEMPLATE/              # Mẫu issue GitHub
│   ├── ISSUES_SPRINT_1_3.md          # Danh sách issue Sprint 1-3 đã chia
│   └── pull_request_template.md
├── database/
│   ├── schema/                       # Script tạo database, bảng, ràng buộc
│   ├── seed/                         # Dữ liệu nền phục vụ demo/kiểm thử
│   └── queries/                      # Truy vấn báo cáo thống kê
├── docs/
│   ├── 01-quan-ly-du-an/             # Charter, Scope, WBS, RACI, Cost Baseline
│   ├── 02-phan-tich/                 # SRS, User Stories
│   ├── 03-thiet-ke/                  # API spec, Database Design, thư mục sơ đồ
│   ├── 04-kiem-thu/                  # Test Plan
│   ├── Bao_cao_Tuan_1_LV33-001.md
│   └── TASKS.md                      # Task đã cấu hình cho 3 tuần đầu
└── src/
    └── backend/                      # Backend prototype tối giản
```

## Tài liệu chính

| Tài liệu | Vị trí |
|---|---|
| Project Charter | [docs/01-quan-ly-du-an/Project-Charter.md](docs/01-quan-ly-du-an/Project-Charter.md) |
| Scope Statement | [docs/01-quan-ly-du-an/Scope-Statement.md](docs/01-quan-ly-du-an/Scope-Statement.md) |
| WBS & phân bổ nguồn lực | [docs/01-quan-ly-du-an/WBS.md](docs/01-quan-ly-du-an/WBS.md) |
| Cost Baseline | [docs/01-quan-ly-du-an/Cost-Baseline.md](docs/01-quan-ly-du-an/Cost-Baseline.md) |
| RACI Matrix | [docs/01-quan-ly-du-an/RACI-Matrix.md](docs/01-quan-ly-du-an/RACI-Matrix.md) |
| Kế hoạch 3 tuần đầu | [docs/01-quan-ly-du-an/Ke-hoach-3-tuan-dau.md](docs/01-quan-ly-du-an/Ke-hoach-3-tuan-dau.md) |
| SRS | [docs/02-phan-tich/SRS.md](docs/02-phan-tich/SRS.md) |
| User Stories | [docs/02-phan-tich/User-Stories.md](docs/02-phan-tich/User-Stories.md) |
| API Specification | [docs/03-thiet-ke/API-Specification.md](docs/03-thiet-ke/API-Specification.md) |
| Database Design | [docs/03-thiet-ke/Database-Design.md](docs/03-thiet-ke/Database-Design.md) |
| Use Case tổng quát | [docs/03-thiet-ke/use-case/use-case-tong-quat.drawio](docs/03-thiet-ke/use-case/use-case-tong-quat.drawio) |
| Test Plan | [docs/04-kiem-thu/Test-Plan.md](docs/04-kiem-thu/Test-Plan.md) |
| GitHub issues Sprint 1-3 | [.github/ISSUES_SPRINT_1_3.md](.github/ISSUES_SPRINT_1_3.md) |

## Chạy thử backend prototype

```bash
cd src/backend
dotnet restore
dotnet run
```

Endpoint mẫu:

- `GET /health`
- `POST /api/auth/login`
- `POST /api/auth/logout`
- `GET /api/auth/me`
- `GET /api/users`
- `GET /api/customers`
- `GET /api/tickets`
- `GET /api/tickets/{code}`

## Số liệu để báo cáo

| Nội dung | Số liệu |
|---|---:|
| Thời gian dự án | 08/09/2026 - 03/11/2026 |
| WBS baseline | 64 người-ngày |
| Lãm | 25 người-ngày |
| Lợi | 13 người-ngày |
| Kỳ | 26 người-ngày |
| Chi phí tiền mặt thực tế | 0 VNĐ |
| Chi phí quy đổi | 12.800.000 VNĐ |

## GitHub

GitHub đang cấu hình các issue cho **Sprint 1-3** theo đúng phần đã làm trong 3 tuần đầu. Mỗi issue có milestone, label sprint và label thành viên (`member:lam`, `member:loi`, `member:ky`).
