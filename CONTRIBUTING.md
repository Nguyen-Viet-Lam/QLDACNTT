# Quy ước làm việc nhóm — LV33-001

Tài liệu này là thỏa thuận làm việc (Team Working Agreement) của Nhóm 11. Mọi thành viên tuân thủ để tránh xung đột mã nguồn và đảm bảo tiến độ.

## 1. Nhịp làm việc Scrum

| Sự kiện | Thời gian | Hình thức |
|---|---|---|
| Sprint Planning | Thứ Hai đầu sprint, 30 phút | Google Meet |
| Daily Standup | Hằng ngày 21:00, 10 phút | Nhóm Zalo (mỗi người nhắn 3 dòng: hôm qua làm gì / hôm nay làm gì / đang vướng gì) |
| Sprint Review | Chủ Nhật cuối sprint, 45 phút | Google Meet, demo phần đã làm |
| Sprint Retrospective | Ngay sau Review, 15 phút | Ghi nhận vào báo cáo tiến độ |

## 2. Phân công vai trò

| Thành viên | Vai trò | Phạm vi phụ trách |
|---|---|---|
| Nguyễn Viết Lãm | PM / Scrum Master + Backend & API + DevOps | Quản lý dự án, kiến trúc, Backend API, GitHub, môi trường demo |
| Nguyễn Đại Kỳ | BA / PO | Khảo sát, SRS, Product Backlog, tiêu chí nghiệm thu, UI/UX, Web Admin, Mobile App |
| Trần Ngọc Lợi | Database + QA / Tester | ERD, CSDL, truy vấn báo cáo, test case, kiểm thử, bug log |

> Ba vai trò trên là trách nhiệm chính. Khi một thành viên quá tải, cả nhóm thống nhất chuyển việc trong Sprint Planning, không tự ý nhận chéo.

## 3. Quy ước Git

### Nhánh

Không commit trực tiếp lên `main` và `develop`. Mọi thay đổi đi qua nhánh riêng và Pull Request.

```
feature/US-05-lap-phieu-sua-chua      # chức năng mới
bugfix/BUG-12-sai-ton-kho             # sửa lỗi
docs/srs-nghiep-vu-bao-hanh           # tài liệu
release/v1.0.0                        # chuẩn bị phát hành
hotfix/loi-dang-nhap                  # sửa lỗi gấp trên main
```

### Commit message

Theo Conventional Commits, viết mô tả bằng tiếng Việt không dấu hoặc có dấu đều được, nhưng phải rõ nghĩa:

```
feat(ticket): thêm API lập phiếu sửa chữa
fix(inventory): sửa lỗi trừ tồn kho khi hủy phiếu xuất
docs(srs): cập nhật đặc tả nghiệp vụ bảo hành
```

Không dùng commit message kiểu `update`, `fix bug`, `abc`, `commit lần 3`.

### Pull Request

- Mỗi PR chỉ giải quyết **một** User Story hoặc **một** lỗi.
- Bắt buộc có **ít nhất 1 approve** từ thành viên khác mới được merge.
- Người review có 24 giờ để phản hồi; quá hạn mà không phản hồi thì PM được quyền merge.
- Tự review lại diff của mình trước khi mở PR.

### Xung đột mã nguồn

- Trước khi bắt đầu việc mới: `git checkout develop && git pull`.
- Mỗi người chỉ làm trong phạm vi thư mục mình phụ trách để giảm xung đột.
- Gặp conflict không tự xử lý được thì báo nhóm Zalo, không tự ý `--force`.

## 4. Quy ước đặt tên

| Đối tượng | Quy ước | Ví dụ |
|---|---|---|
| Bảng CSDL | PascalCase, số nhiều | `RepairTickets`, `SpareParts` |
| Cột CSDL | PascalCase | `TicketId`, `CreatedAt` |
| Class C# | PascalCase | `RepairTicketService` |
| Biến C# | camelCase | `ticketTotal` |
| API endpoint | kebab-case, số nhiều | `/api/repair-tickets` |
| File Dart | snake_case | `ticket_detail_screen.dart` |
| Nhánh Git | kebab-case | `feature/US-10-xuat-linh-kien` |

## 5. Định nghĩa hoàn thành (Definition of Done)

Một task chỉ được đánh dấu Done khi:

- [ ] Code build thành công, không có lỗi biên dịch
- [ ] Đã tự kiểm thử luồng chính (happy path) và ít nhất một luồng lỗi
- [ ] Đã merge vào `develop` qua PR được approve
- [ ] Tài liệu liên quan đã cập nhật (nếu đổi API hoặc CSDL)
- [ ] Không để lại code chết, `Console.WriteLine` debug hoặc `TODO` không có ghi chú
- [ ] QA đã kiểm thử và đóng test case tương ứng (với các US có test case)

## 6. Bảo mật thông tin

- Không commit connection string, mật khẩu, API key. Dùng `appsettings.example.json` làm mẫu.
- File cấu hình thật (`appsettings.Development.json`, `.env`) đã được `.gitignore` chặn.
- Dữ liệu khách hàng trong seed data phải là dữ liệu giả, không dùng thông tin người thật.

## 7. Xử lý khi trễ tiến độ

- Phát hiện không kịp deadline thì báo ngay trong Daily Standup, không chờ đến cuối sprint.
- PM đánh giá và quyết định: giảm phạm vi task, chuyển sang sprint sau, hoặc nhờ thành viên khác hỗ trợ.
- Task chuyển sprint phải ghi rõ lý do vào báo cáo tiến độ tuần.
