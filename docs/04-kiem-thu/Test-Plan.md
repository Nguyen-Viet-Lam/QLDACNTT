# Kế hoạch kiểm thử — LV33-001

**Phụ trách:** Nguyễn Đại Kỳ (QA / Tester)
**Phiên bản:** v1.0 — lập tại Sprint 3 (22/09/2026)

## 1. Mục tiêu

Xác nhận hệ thống đáp ứng đủ 16 User Stories với tiêu chí nghiệm thu đã chốt, đặc biệt là tính đúng đắn của ba điểm dễ sai nhất: trừ tồn kho, tính tiền trên hóa đơn, và tính thời hạn bảo hành.

## 2. Phạm vi kiểm thử

**Trong phạm vi:**

- Kiểm thử chức năng theo từng User Story (functional testing)
- Kiểm thử API bằng Postman
- Kiểm thử phân quyền (RBAC) cho 4 vai trò
- Kiểm thử tích hợp ba quy trình nghiệp vụ đầu-cuối
- Kiểm thử biên và ca lỗi (boundary & negative testing)
- Kiểm thử hồi quy sau khi sửa bug
- Kiểm thử hiệu năng cơ bản: đo thời gian phản hồi API chính
- Đối soát dữ liệu: tồn kho, tiền linh kiện, doanh thu

**Ngoài phạm vi:**

- Kiểm thử tải cao (load / stress testing) với hàng nghìn người dùng đồng thời
- Kiểm thử bảo mật chuyên sâu (penetration testing)
- Kiểm thử tương thích trên nhiều dòng thiết bị và nhiều phiên bản Android
- Kiểm thử tự động hóa giao diện (chỉ làm thủ công)

## 3. Chiến lược kiểm thử

| Loại | Cách làm | Ai làm | Khi nào |
|---|---|---|---|
| Unit test | xUnit cho service có logic phức tạp (state machine, trừ tồn) | Lãm | Trong lúc code |
| Kiểm thử API | Postman collection, chạy thủ công theo từng nhóm endpoint | Lợi | Cuối mỗi sprint |
| Kiểm thử chức năng | Thủ công trên Web Admin theo test case | Lợi | Cuối mỗi sprint |
| Kiểm thử phân quyền | Đăng nhập lần lượt 4 vai trò, thử gọi endpoint ngoài quyền | Lợi | Sprint 4 và Sprint 7 |
| Kiểm thử tích hợp | Chạy trọn 3 quy trình nghiệp vụ trên bản build tích hợp | Lợi | Sprint 7 |
| Kiểm thử hồi quy | Chạy lại toàn bộ test case đã có | Lợi | Sprint 7 |
| Đối soát dữ liệu | Chạy truy vấn SQL so sánh với số hiển thị trên giao diện | Lợi | Sprint 5, 6, 7 |

## 4. Môi trường kiểm thử

| Thành phần | Cấu hình |
|---|---|
| Backend API | Chạy local `https://localhost:7001`, cấu hình Development |
| Web Admin | Live Server `http://localhost:5500` |
| Mobile App | Emulator Android + 1 máy thật, API qua `http://10.0.2.2:7001` |
| CSDL | SQL Server local, database `RepairShopDB` |
| Dữ liệu | Seed danh mục nền + 200+ phiếu mô phỏng (task T133) |

Trước mỗi lần kiểm thử hồi quy, khôi phục CSDL về trạng thái sau seed để kết quả có thể tái lập.

## 5. Tiêu chí vào / ra

**Tiêu chí vào (bắt đầu kiểm thử một sprint):**

- Chức năng đã merge vào `develop` và build thành công
- Người phát triển đã tự kiểm luồng chính
- Test case tương ứng đã viết xong

**Tiêu chí ra (kết thúc kiểm thử, cho phép nghiệm thu):**

- 100% test case của chức năng Must-have đã chạy
- Không còn bug mức **Critical** và **Major** nào chưa đóng
- Tỉ lệ test case Pass ≥ 95%
- Bug mức Minor / Trivial còn lại đã ghi vào bug log kèm ghi chú chấp nhận

## 6. Phân loại mức độ bug

| Mức | Định nghĩa | Thời gian phải sửa |
|---|---|---|
| **Critical** | Chặn luồng nghiệp vụ chính, không có cách khắc phục tạm. Ví dụ: không đăng nhập được, không lập được phiếu. | Trong 24 giờ |
| **Major** | Sai nghiệp vụ hoặc sai số liệu. Ví dụ: trừ tồn kho sai, tính tổng tiền sai, phân quyền hở. | Trong sprint |
| **Minor** | Lỗi nhỏ, có cách khắc phục tạm. Ví dụ: thông báo lỗi không rõ nghĩa, phân trang lệch. | Sprint tiếp theo |
| **Trivial** | Lỗi giao diện, chính tả, lệch căn lề. | Nếu còn thời gian |

## 7. Các điểm cần kiểm thử kỹ nhất

Ba nhóm dưới đây là nơi sai sót gây hậu quả nặng nhất, phải kiểm thử cả ca thường và ca biên:

**Tồn kho (US-10)**

- Xuất đúng bằng số tồn còn lại (tồn về 0)
- Xuất vượt tồn 1 đơn vị
- Xuất số lượng 0, số âm, số thập phân
- Xuất nhiều linh kiện, trong đó một linh kiện không đủ tồn — phải rollback toàn bộ
- Hủy phiếu đã xuất linh kiện — tồn phải hoàn về đúng như trước

**Tiền trên hóa đơn (US-12)**

- Tổng tiền = tiền công + tiền linh kiện − giảm giá
- Giảm giá bằng đúng tổng tiền (tổng về 0)
- Giảm giá vượt tổng tiền — phải bị chặn
- Lập hóa đơn 2 lần cho cùng một phiếu — phải bị chặn
- Lập hóa đơn cho phiếu chưa `COMPLETED` — phải bị chặn
- Đổi giá linh kiện sau khi đã xuất — hóa đơn cũ không được thay đổi

**Bảo hành (US-13, US-14)**

- Thời hạn lấy đúng giá trị lớn nhất giữa dịch vụ và linh kiện
- Dịch vụ không bảo hành và không thay linh kiện — không sinh phiếu bảo hành
- Tra cứu bảo hành đúng ngày hết hạn (biên: còn 0 ngày)
- Tra cứu bảo hành đã hết hạn — phải báo hết hạn, không cho lập phiếu bảo hành
- Tra cứu bảo hành đã dùng — phải báo đã sử dụng
- Phiếu sửa bảo hành phải miễn tiền công

## 8. Sản phẩm chuyển giao của kiểm thử

| Tài liệu | Vị trí | Khi nào |
|---|---|---|
| Kế hoạch kiểm thử | tài liệu này | Sprint 3 |
| Test case theo User Story | Sẽ bổ sung trong `docs/04-kiem-thu/` khi bắt đầu kiểm thử | Sprint 4–6 |
| Bug log | `docs/04-kiem-thu/Bug-Log.md` | Liên tục |
| Postman collection | Sẽ bổ sung khi có API thật | Sprint 4–7 |
| Biên bản kiểm thử tích hợp | `docs/04-kiem-thu/` | Sprint 7 |
| Báo cáo kết quả kiểm thử tổng hợp | `docs/04-kiem-thu/Bao-cao-ket-qua-kiem-thu.md` | Sprint 8 |

## 9. Mẫu test case

| Trường | Nội dung |
|---|---|
| Mã test case | `TC-US10-05` |
| User Story | US-10 |
| Tiêu đề | Xuất linh kiện vượt tồn kho phải bị chặn |
| Điều kiện tiên quyết | Đăng nhập vai trò TECHNICIAN; linh kiện LK00003 có tồn = 5; tồn tại phiếu PSC ở trạng thái REPAIRING |
| Các bước | 1. Mở chi tiết phiếu → 2. Chọn linh kiện LK00003 → 3. Nhập số lượng 6 → 4. Bấm Xuất |
| Kết quả mong đợi | Hệ thống chặn, báo "Tồn hiện tại: 5, yêu cầu: 6"; tồn kho vẫn là 5; không ghi dòng nào vào TicketParts |
| Kết quả thực tế | *(điền khi chạy)* |
| Trạng thái | Pass / Fail |
| Mã bug | *(nếu Fail)* |
| Người kiểm thử | Lợi |
| Ngày kiểm thử | |
