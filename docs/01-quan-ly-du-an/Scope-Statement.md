# Phát biểu về Phạm vi (Scope Statement)

**Tên dự án:** Hệ thống quản lý tổng thể cho cửa hàng sửa chữa
**Mã đề tài:** LV33-001
**Ngày:** 08/09/2026 · **Người viết:** Nguyễn Viết Lãm

## 1. Lý giải về dự án (Project Justification)

Dự án xây dựng hệ thống phần mềm quản lý tổng thể nhằm chuẩn hóa và số hóa quy trình hoạt động cho cửa hàng sửa chữa. Hiện cửa hàng ghi chép phiếu sửa chữa bằng sổ tay hoặc file Excel rời rạc nên dễ thất lạc phiếu, khó tra lịch sử thiết bị, linh kiện xuất dùng không được trừ tồn theo thời gian thực dẫn đến thất thoát vật tư, và thông tin bảo hành không lưu tập trung nên dễ tranh chấp với khách. Hệ thống giải quyết nhu cầu quản lý tập trung bốn thực thể chính: phiếu sửa chữa, linh kiện, khách hàng và bảo hành.

## 2. Các tính chất và yêu cầu của sản phẩm

- **Quản lý dữ liệu lõi:** nghiệp vụ quản lý phiếu sửa chữa, linh kiện, khách hàng và bảo hành.
- Hệ thống vận hành ổn định, tích hợp cơ chế phân quyền chi tiết (RBAC) cho 4 vai trò.
- Tích hợp các báo cáo thống kê cần thiết phục vụ quản lý.
- **Kiến trúc hệ thống:** Backend & API (ASP.NET Core), Web Admin (HTML5, CSS3, JavaScript, Bootstrap) và Mobile App (Flutter).
- Cơ sở dữ liệu lưu trữ và truy vấn bằng SQL Server.
- **Yêu cầu phi chức năng:** API phản hồi dưới 1 giây, mật khẩu lưu dạng băm, giao diện tiếng Việt, mọi thao tác tác động tồn kho và tiền phải ghi vết (audit trail).

## 3. Phạm vi trong dự án (In-Scope)

| Nhóm chức năng | Nội dung |
|---|---|
| Tài khoản & RBAC | Đăng nhập, tạo tài khoản, gán vai trò, khóa/mở tài khoản |
| Khách hàng & thiết bị | Quản lý khách hàng, thiết bị kèm serial, lịch sử sửa chữa |
| Phiếu sửa chữa | Lập phiếu, chẩn đoán, báo giá, vòng trạng thái, phân công KTV, hủy phiếu |
| Linh kiện & tồn kho | Danh mục linh kiện, nhập kho, xuất theo phiếu, hoàn trả, cảnh báo tồn thấp |
| Thanh toán | Lập hóa đơn, ghi nhận tiền mặt/chuyển khoản, giảm giá, in hóa đơn |
| Bảo hành | Sinh phiếu bảo hành, tra cứu hiệu lực, lập phiếu sửa chữa bảo hành |
| Báo cáo | Dashboard doanh thu, linh kiện tiêu thụ, phiếu theo trạng thái, hiệu suất KTV |
| Mobile App | Khách hàng tra cứu tiến độ phiếu và thông tin bảo hành |

## 4. Phạm vi ngoài dự án (Out-of-Scope)

- Tích hợp cổng thanh toán trực tuyến của ngân hàng hoặc ví điện tử (VNPAY / Momo) — giai đoạn này chỉ ghi nhận tiền mặt và chuyển khoản nội bộ.
- Tích hợp phần mềm kế toán ngoài và xuất hóa đơn điện tử theo chuẩn thuế.
- Quản lý nhân sự, tính lương và chấm công cho kỹ thuật viên.
- Bán hàng online hoặc website thương mại điện tử cho linh kiện.
- Đọc mã vạch / RFID bằng thiết bị phần cứng chuyên dụng.
- Ứng dụng iOS (chỉ build Android).

## 5. Tổng kết về các sản phẩm chuyển giao

### Sản phẩm liên quan đến quản lý dự án

Business case, tôn chỉ dự án (charter), hợp đồng nhóm (team contract), phát biểu phạm vi (scope statement), WBS, ma trận RACI, lịch trình (schedule), đường cơ sở chi phí (cost baseline), báo cáo tiến độ hằng tuần, bài thuyết trình cuối kỳ, báo cáo dự án cuối cùng, báo cáo bài học kinh nghiệm.

### Sản phẩm liên quan đến sản phẩm

- **Phần mềm:** Backend API, Web Admin, Mobile App
- **Tài liệu phân tích:** biên bản khảo sát, SRS, 16 User Stories kèm tiêu chí nghiệm thu, đặc tả 3 quy trình nghiệp vụ
- **Tài liệu thiết kế:** sơ đồ kiến trúc, Use Case, Sequence, BFD (StarUML), ERD và từ điển dữ liệu, đặc tả API, mockup UI (Figma)
- **Cơ sở dữ liệu:** script tạo 13 bảng, script seed dữ liệu, truy vấn báo cáo
- **Tài liệu kiểm thử:** kế hoạch kiểm thử, test case, bug log, Postman collection, báo cáo kết quả kiểm thử
- **Tài liệu bàn giao:** hướng dẫn cài đặt, HDSD cho từng vai trò, kịch bản demo
- **Mã nguồn** lưu trữ trên GitHub theo Gitflow

## 6. Các yêu cầu để đánh giá sự thành công

- Hoàn thành sản phẩm khả dụng tối thiểu (MVP).
- Đạt tối thiểu 80% phạm vi baseline và 100% chức năng cốt lõi (Must-have) trong 8 tuần.
- Hệ thống vận hành ổn định, không còn bug Critical và Major khi nghiệm thu.
- Phân quyền chi tiết (RBAC) và hệ thống báo cáo thống kê hoạt động đúng yêu cầu.
- Tồn kho và số tiền trên hóa đơn khớp 100% khi đối soát bằng truy vấn SQL.
