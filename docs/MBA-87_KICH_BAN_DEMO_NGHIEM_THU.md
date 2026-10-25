# MBA-87 — Kịch bản demo nghiệm thu đồ án

**Người phụ trách:** Nguyễn Đại Kỳ
**Mục tiêu:** Trình diễn các luồng chính của hệ thống quản lý cửa hàng sửa chữa và để hội đồng đối chiếu kết quả với yêu cầu nghiệp vụ.
**Thời lượng đề xuất:** 12–15 phút, chưa tính phần hỏi đáp.

## 1. Chuẩn bị trước buổi demo

- [ ] Chạy ứng dụng theo cấu hình môi trường demo trong `docker-compose.yml` hoặc hướng dẫn chạy hiện hành; kiểm tra API và cơ sở dữ liệu sẵn sàng.
- [ ] Dùng dữ liệu seed của môi trường demo (`database/seed/`); xác nhận trước một tài khoản cho từng vai trò sẽ trình diễn. Không trình chiếu mật khẩu thật hoặc dữ liệu cá nhân.
- [ ] Mở sẵn Web Admin và chuẩn bị cửa sổ trình duyệt sạch, độ phân giải phù hợp.
- [ ] Chuẩn bị một khách hàng, thiết bị, phiếu sửa chữa và linh kiện dữ liệu demo có thể thao tác; không dùng dữ liệu của khách hàng thật.
- [ ] Mở sẵn tài liệu API/test cần đối chiếu, nhưng chỉ chuyển sang khi hội đồng yêu cầu.
- [ ] Nếu môi trường trực tiếp gặp sự cố, dùng ảnh/chụp màn hình hoặc video dự phòng đã ghi trước; nêu rõ đây là minh chứng dự phòng.

## 2. Kịch bản trình diễn

| Thời gian | Bước | Thao tác và lời dẫn | Kết quả cần quan sát |
|---|---|---|---|
| 0:00–1:00 | Giới thiệu | Nêu bài toán: tiếp nhận, theo dõi sửa chữa, quản lý linh kiện, thanh toán và bảo hành tại cửa hàng. Giới thiệu kiến trúc: Web Admin, ASP.NET Core API và SQL Server. | Người nghe hiểu phạm vi và các vai trò của hệ thống. |
| 1:00–2:30 | Đăng nhập và phân quyền | Đăng nhập bằng tài khoản demo; chỉ ra menu/chức năng theo vai trò. Nếu có tài khoản phù hợp, so sánh quyền nhân viên với quản trị viên. | Đăng nhập thành công; chức năng hiển thị theo quyền được cấp. |
| 2:30–4:00 | Tra cứu khách hàng và thiết bị | Tìm khách hàng demo, mở thông tin thiết bị đã đăng ký; nếu phù hợp, tạo khách hàng/thiết bị demo mới. | Thông tin được tra cứu/lưu và liên kết đúng với nhau. |
| 4:00–6:30 | Tiếp nhận và xử lý phiếu | Tạo phiếu tiếp nhận cho thiết bị demo, ghi tình trạng ban đầu; mở phiếu, phân công kỹ thuật viên và cập nhật tiến độ theo các trạng thái hệ thống hỗ trợ. | Phiếu có mã nhận diện, thông tin khách/thiết bị và lịch sử trạng thái nhất quán. |
| 6:30–8:00 | Linh kiện và chi phí | Trình bày tra cứu tồn kho; thêm linh kiện vào phiếu nếu luồng hiện có cho phép; chỉ ra ảnh hưởng của nghiệp vụ xuất kho và cảnh báo tồn tối thiểu. | Số lượng tồn và chi phí hiển thị phù hợp với thao tác demo. |
| 8:00–10:00 | Hóa đơn và thanh toán | Mở phần lập hóa đơn của phiếu đã xử lý; kiểm tra khoản mục và tổng tiền; trình bày phương thức thanh toán được cấu hình trong môi trường demo. | Hóa đơn gắn đúng phiếu và tổng tiền được tính nhất quán. Không thực hiện giao dịch tiền thật. |
| 10:00–11:30 | Bảo hành | Tra cứu thẻ bảo hành điện tử theo dữ liệu demo và giải thích cách đối chiếu thiết bị/thời hạn. | Thông tin bảo hành gắn với đúng thiết bị hoặc hóa đơn theo luồng đã xây dựng. |
| 11:30–13:00 | Dashboard/báo cáo | Mở dashboard hoặc báo cáo có sẵn; nêu bộ lọc và nguồn dữ liệu ở mức tổng quan. | Số liệu được tải từ môi trường demo và các bộ lọc phản hồi. |
| 13:00–15:00 | Kết luận | Tóm tắt luồng đầu-cuối, nhắc lại các vai trò, kiểm thử và tài liệu bàn giao; mời hội đồng đặt câu hỏi. | Kết thúc đúng phạm vi; ghi nhận câu hỏi cần theo dõi. |

## 3. Quy tắc khi trình diễn

1. Chỉ dùng tài khoản và dữ liệu demo. Không hiển thị token, mật khẩu, chuỗi kết nối, thông tin khách hàng thật hoặc dữ liệu bí mật trong log.
2. Không xác nhận thanh toán thật, gửi QR đến người trả tiền thật hoặc thao tác trên môi trường production.
3. Nêu rõ phần nào là thao tác trực tiếp, phần nào là ảnh/video dự phòng; không mô tả dữ liệu seed như dữ liệu vận hành thực tế.
4. Nếu một luồng không hoạt động, ghi nhận bước và thông báo lỗi, chuyển sang phần tiếp theo; không sửa dữ liệu trực tiếp để làm sai lệch kết quả.
5. Câu hỏi nằm ngoài phạm vi được ghi lại để nhóm trả lời sau khi xác minh.

## 4. Ghi nhận nghiệm thu

| Nội dung | Ghi nhận |
|---|---|
| Ngày/địa điểm demo | Điền khi tổ chức |
| Phiên bản/commit được demo | Ghi mã commit thực tế |
| Môi trường demo | Ghi cấu hình triển khai thực tế, không ghi bí mật |
| Người trình bày | Nguyễn Đại Kỳ |
| Luồng đã trình diễn | Đánh dấu theo các bước ở mục 2 |
| Sự cố/câu hỏi cần xử lý | Ghi nội dung và người theo dõi |
| Kết luận của hội đồng | Điền sau buổi nghiệm thu; không tự điền trước |

