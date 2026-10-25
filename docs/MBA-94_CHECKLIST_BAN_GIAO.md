# MBA-94 — Checklist bàn giao mã nguồn và tài liệu cho trường

**Người phụ trách:** Nguyễn Đại Kỳ
**Mục tiêu:** Chuẩn bị gói bàn giao có thể kiểm tra, tái dựng và nghiệm thu; các ô chưa được xác minh phải để trống cho đến khi người bàn giao hoàn tất.

## 1. Mã nguồn và lịch sử thay đổi

- [ ] Xác nhận repository chính thức: <https://github.com/Nguyen-Viet-Lam/QLDACNTT>.
- [ ] Chốt nhánh/commit bàn giao và ghi mã commit, ngày tạo gói, người tạo.
- [ ] Kiểm tra mã nguồn đã được push; không đưa thư mục `.git`, file build/cache hoặc artefact cá nhân vào gói nộp nếu quy định trường không yêu cầu.
- [ ] Kiểm tra không có API token, mật khẩu, khóa ký, chuỗi kết nối production, dữ liệu cá nhân hoặc tệp cấu hình bí mật trong lịch sử và gói bàn giao.
- [ ] Ghi nhận công nghệ và cấu trúc: `src/backend`, `src/web-admin`, `database`, `tests`, `docs`, `tools`.
- [ ] Bàn giao các script schema/seed cần thiết dưới `database/`; mô tả thứ tự chạy theo môi trường thực tế.

## 2. Tài liệu hiện có trong repository

- [ ] Hướng dẫn quản trị hệ thống/server: `docs/HUONG_DAN_QUAN_TRI_HE_THONG_VA_SERVER.md`.
- [ ] Hướng dẫn nhân viên quầy: `docs/huong_dan_nhan_vien_quay.md`.
- [ ] Hướng dẫn kỹ thuật viên: `docs/huong_dan_ky_thuat_vien.md`.
- [ ] Báo cáo kiểm thử hiệu năng: `docs/MBA-76_BAO_CAO_KIEM_THU_TAI_VA_HIEU_NANG.md`.
- [ ] Báo cáo tương thích trình duyệt: `docs/MBA-77_BAO_CAO_KIEM_THU_TUONG_THICH_DA_TRINH_DUYET.md`.
- [ ] Báo cáo an toàn thông tin: `docs/MBA-78_BAO_CAO_KIEM_THU_AN_TOAN_THONG_TIN.md`.
- [ ] Bổ sung/đối chiếu đề cương, SRS, thiết kế, biên bản nghiệm thu, nhật ký và biểu mẫu theo đúng yêu cầu nộp của trường; ghi tên tệp và phiên bản thực tế.
- [ ] Mở thử các tệp tài liệu, kiểm tra tiếng Việt, liên kết, ảnh minh chứng, mục lục và số trang trước khi đóng gói.

## 3. Tái dựng và vận hành

- [ ] Ghi rõ phiên bản .NET SDK, Node.js và SQL Server cần dùng; xác minh theo cấu hình trong repo trước khi bàn giao.
- [ ] Cung cấp mẫu cấu hình không chứa bí mật và hướng dẫn đặt biến môi trường cho máy mới.
- [ ] Ghi lệnh khôi phục package, tạo/cập nhật database, seed dữ liệu demo, chạy backend và mở web admin; chỉ ghi các lệnh đã xác minh.
- [ ] Ghi cổng, URL health check và cách xử lý lỗi khởi động thường gặp theo cấu hình bàn giao.
- [ ] Đảm bảo tài khoản demo được tạo riêng cho nghiệm thu; chuyển thông tin đăng nhập qua kênh riêng theo quy định trường, không commit vào Git.
- [ ] Xác nhận các dịch vụ ngoài (nếu có) dùng sandbox/mock trong buổi nghiệm thu; không bàn giao khóa production.

## 4. Kiểm tra gói trước khi nộp

- [ ] Đối chiếu tên thư mục/tệp với mẫu nộp và quy cách đặt tên của khoa/trường.
- [ ] Tạo bản sao lưu gói bàn giao và tính checksum SHA-256; lưu ở vị trí được trường/nhóm cho phép.
- [ ] Quét gói để phát hiện secret và tệp thừa; rà soát thủ công mọi phát hiện trước khi gửi.
- [ ] Xác nhận repository/link và quyền truy cập dành cho người nhận hoạt động; chỉ cấp quyền cần thiết.
- [ ] Lập danh mục tệp, phiên bản, người bàn giao và người nhận.
- [ ] Ghi nhận ngày bàn giao, xác nhận tiếp nhận và các mục còn thiếu; không đánh dấu hoàn tất nếu chưa có xác nhận.

## 5. Biên bản bàn giao

| Trường thông tin | Giá trị cần điền khi bàn giao |
|---|---|
| Tên đồ án | Hệ thống quản lý tổng thể cho cửa hàng sửa chữa — LV33-001 |
| Nhóm/lớp | Nhóm 11 / 23DTHC6 |
| Đại diện bàn giao | Nguyễn Đại Kỳ (theo phân công task) |
| Repository và nhánh | Điền nhánh/URL thực tế |
| Commit bàn giao | Điền SHA thực tế |
| Gói tài liệu | Điền đường dẫn/tên gói thực tế |
| Ngày bàn giao | Điền ngày thực tế |
| Người nhận/xác nhận | Điền sau khi trường xác nhận |
| Các mục tồn đọng | Ghi rõ hoặc ghi “Không” sau khi đối chiếu |

