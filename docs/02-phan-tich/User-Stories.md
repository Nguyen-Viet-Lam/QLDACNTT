# User Stories — LV33-001

**Phụ trách:** Trần Ngọc Lợi (BA / PO)
**Tổng số:** 16 User Stories

## Quy ước ước lượng

Story point theo thang Fibonacci: 1, 2, 3, 5, 8. Một story point ≈ nửa ngày làm việc.

## Tổng hợp

| Mã | Tóm tắt | Nhóm chức năng | Ưu tiên | SP | Sprint |
|---|---|---|---|---|---|
| US-01 | Đăng nhập hệ thống | Tài khoản & RBAC | Must | 3 | 4 |
| US-02 | Tạo & phân quyền tài khoản | Tài khoản & RBAC | Must | 5 | 4 |
| US-03 | Tra cứu / tạo khách hàng | Khách hàng | Must | 3 | 4 |
| US-04 | Lưu thiết bị của khách kèm serial | Khách hàng | Must | 3 | 4 |
| US-05 | Lập phiếu sửa chữa | Phiếu sửa chữa | Must | 5 | 5 |
| US-06 | Cập nhật chẩn đoán & báo giá | Phiếu sửa chữa | Must | 3 | 5 |
| US-07 | Chuyển trạng thái phiếu | Phiếu sửa chữa | Must | 5 | 5 |
| US-08 | Phân công kỹ thuật viên | Phiếu sửa chữa | Should | 2 | 5 |
| US-09 | Quản lý danh mục linh kiện & tồn kho | Linh kiện & tồn kho | Must | 5 | 5 |
| US-10 | Xuất linh kiện theo phiếu, trừ tồn | Linh kiện & tồn kho | Must | 8 | 5 |
| US-11 | Cảnh báo linh kiện dưới tồn tối thiểu | Linh kiện & tồn kho | Should | 2 | 5 |
| US-12 | Lập hóa đơn & ghi nhận thanh toán | Thanh toán | Must | 5 | 6 |
| US-13 | Tự sinh phiếu bảo hành khi hoàn tất | Bảo hành | Must | 5 | 6 |
| US-14 | Tra cứu bảo hành & lập phiếu sửa bảo hành | Bảo hành | Must | 5 | 6 |
| US-15 | Dashboard doanh thu & báo cáo | Báo cáo | Must | 8 | 6 |
| US-16 | Khách tra cứu tiến độ & bảo hành qua mobile | Mobile App | Should | 5 | 6 |
| | | | **Tổng** | **72** | |

---

## US-01 — Đăng nhập hệ thống

> Là **người dùng**, tôi muốn **đăng nhập bằng tài khoản được cấp** để **truy cập hệ thống theo đúng quyền của mình**.

**Ưu tiên:** Must · **SP:** 3 · **Sprint:** 4

**Tiêu chí nghiệm thu:**

- [ ] AC1: Nhập đúng tên đăng nhập và mật khẩu thì vào được hệ thống, nhận JWT token có thời hạn 120 phút.
- [ ] AC2: Nhập sai mật khẩu thì hiện thông báo "Tên đăng nhập hoặc mật khẩu không đúng", không tiết lộ sai ở trường nào.
- [ ] AC3: Tài khoản bị khóa (`IsActive = 0`) thì không đăng nhập được, hiện thông báo tài khoản đã bị khóa.
- [ ] AC4: Đăng nhập thành công thì cập nhật `LastLoginAt`.
- [ ] AC5: Token hết hạn thì mọi API trả 401 và giao diện tự chuyển về trang đăng nhập.
- [ ] AC6: Mật khẩu lưu trong CSDL ở dạng băm, không lưu dạng chữ thường.

## US-02 — Tạo & phân quyền tài khoản

> Là **Admin**, tôi muốn **tạo và phân quyền tài khoản theo vai trò** để **giới hạn chức năng mỗi nhân viên được dùng**.

**Ưu tiên:** Must · **SP:** 5 · **Sprint:** 4

**Tiêu chí nghiệm thu:**

- [ ] AC1: Admin tạo được tài khoản mới, chọn một trong 4 vai trò ADMIN / STAFF / TECHNICIAN / CUSTOMER.
- [ ] AC2: Tên đăng nhập trùng thì báo lỗi, không tạo được.
- [ ] AC3: Admin khóa / mở khóa được tài khoản.
- [ ] AC4: Tài khoản vai trò STAFF đăng nhập thì không thấy menu quản lý tài khoản và không gọi được API `/users` (trả 403).
- [ ] AC5: Tài khoản vai trò TECHNICIAN không lập được phiếu sửa chữa nhưng xuất được linh kiện.
- [ ] AC6: Admin không tự khóa được tài khoản của chính mình.

## US-05 — Lập phiếu sửa chữa

> Là **nhân viên tiếp nhận**, tôi muốn **lập phiếu sửa chữa ghi nhận tình trạng thiết bị lúc nhận** để **tránh tranh chấp khi bàn giao**.

**Ưu tiên:** Must · **SP:** 5 · **Sprint:** 5

**Tiêu chí nghiệm thu:**

- [ ] AC1: Chọn được khách hàng có sẵn hoặc tạo mới ngay trên form lập phiếu.
- [ ] AC2: Chọn được thiết bị của khách hoặc thêm thiết bị mới kèm số serial.
- [ ] AC3: Bắt buộc nhập tình trạng thiết bị lúc nhận, tối thiểu 10 ký tự.
- [ ] AC4: Hệ thống tự sinh mã phiếu theo định dạng `PSC` + năm + tháng + số thứ tự, không trùng.
- [ ] AC5: Phiếu mới có trạng thái `RECEIVED` và ghi nhận người tiếp nhận là người đang đăng nhập.
- [ ] AC6: Lập phiếu xong thì ghi một dòng vào lịch sử trạng thái.

## US-10 — Xuất linh kiện theo phiếu, trừ tồn

> Là **kỹ thuật viên**, tôi muốn **xuất linh kiện gắn với phiếu sửa chữa** để **hệ thống tự trừ tồn kho và cộng chi phí vào phiếu**.

**Ưu tiên:** Must · **SP:** 8 · **Sprint:** 5

**Tiêu chí nghiệm thu:**

- [ ] AC1: Xuất được nhiều linh kiện trong một lần cho cùng một phiếu.
- [ ] AC2: Tồn kho giảm đúng bằng số lượng xuất ngay sau khi lưu.
- [ ] AC3: Yêu cầu xuất vượt tồn hiện tại thì bị chặn, báo rõ linh kiện nào thiếu, tồn bao nhiêu, yêu cầu bao nhiêu.
- [ ] AC4: Số lượng bằng 0 hoặc số âm thì bị chặn.
- [ ] AC5: Mỗi lần xuất ghi một dòng `StockTransactions` có tồn trước và tồn sau.
- [ ] AC6: Giá bán ghi vào `TicketParts` là giá tại thời điểm xuất, sau này Admin đổi giá linh kiện thì phiếu cũ không đổi theo.
- [ ] AC7: Chi phí linh kiện trên phiếu bằng đúng tổng `LineTotal` của các dòng đã xuất.
- [ ] AC8: Nếu một linh kiện trong danh sách bị lỗi thì toàn bộ lần xuất đó rollback, không xuất một phần.

## US-13 — Tự sinh phiếu bảo hành khi hoàn tất

> Là **nhân viên**, tôi muốn **hệ thống sinh phiếu bảo hành có thời hạn khi phiếu hoàn tất** để **làm căn cứ khi khách quay lại**.

**Ưu tiên:** Must · **SP:** 5 · **Sprint:** 6

**Tiêu chí nghiệm thu:**

- [ ] AC1: Ghi nhận thanh toán xong thì tự sinh một phiếu bảo hành, mã theo định dạng `BH` + năm + tháng + số thứ tự.
- [ ] AC2: Thời hạn bảo hành lấy theo giá trị lớn nhất giữa thời hạn của loại dịch vụ và thời hạn của các linh kiện đã thay.
- [ ] AC3: Ngày bắt đầu là ngày thanh toán, ngày hết hạn = ngày bắt đầu + số ngày bảo hành.
- [ ] AC4: Phiếu bảo hành mới có trạng thái `ACTIVE`.
- [ ] AC5: Dịch vụ có `WarrantyDays = 0` và không thay linh kiện nào thì không sinh phiếu bảo hành.
- [ ] AC6: Phiếu bảo hành liên kết đúng phiếu sửa chữa, khách hàng và thiết bị.

## US-15 — Dashboard doanh thu & báo cáo

> Là **Admin**, tôi muốn **xem dashboard doanh thu theo kỳ, linh kiện tiêu thụ và số phiếu theo trạng thái** để **ra quyết định**.

**Ưu tiên:** Must · **SP:** 8 · **Sprint:** 6

**Tiêu chí nghiệm thu:**

- [ ] AC1: Dashboard hiện 4 thẻ số liệu: doanh thu kỳ này, số phiếu đang xử lý, số phiếu hoàn tất, số linh kiện cần nhập thêm.
- [ ] AC2: Có biểu đồ đường doanh thu theo ngày trong khoảng ngày người dùng chọn.
- [ ] AC3: Có biểu đồ cột số phiếu theo trạng thái.
- [ ] AC4: Có bảng top 10 linh kiện tiêu thụ nhiều nhất kèm lợi nhuận gộp.
- [ ] AC5: Doanh thu chỉ tính hóa đơn có `PaymentStatus = PAID`.
- [ ] AC6: Số liệu trên dashboard khớp với kết quả chạy truy vấn SQL trực tiếp trên cùng khoảng ngày.
- [ ] AC7: Chỉ vai trò ADMIN xem được, vai trò khác gọi API trả 403.

---

> **Ghi chú:** Các US còn lại (US-03, US-04, US-06, US-07, US-08, US-09, US-11, US-12, US-14, US-16) viết tiêu chí nghiệm thu chi tiết theo cùng khuôn mẫu ở task **T07**. Bảng tổng hợp phía trên đã đủ để đưa lên Jira ở task **T08**.
