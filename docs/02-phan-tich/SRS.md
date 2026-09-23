# Đặc tả yêu cầu phần mềm (SRS) — LV33-001

**Phụ trách:** Trần Ngọc Lợi (BA / PO)
**Phiên bản:** v1.0 — Sprint 3 (22/09/2026)

## 1. Giới thiệu

### 1.1 Mục đích

Tài liệu này đặc tả yêu cầu chức năng và phi chức năng của Hệ thống quản lý tổng thể cho cửa hàng sửa chữa, làm căn cứ để thiết kế, phát triển và kiểm thử.

### 1.2 Người đọc dự kiến

Thành viên nhóm phát triển, giảng viên hướng dẫn, và chủ cửa hàng với vai trò người dùng nghiệp vụ.

### 1.3 Tác nhân hệ thống

| Tác nhân | Mô tả | Truy cập qua |
|---|---|---|
| **Admin** | Chủ cửa hàng / quản lý. Toàn quyền hệ thống. | Web Admin |
| **Staff** | Nhân viên tiếp nhận. Lập phiếu, thu tiền. | Web Admin |
| **Technician** | Kỹ thuật viên. Chẩn đoán, sửa chữa, xuất linh kiện. | Web Admin |
| **Customer** | Khách hàng. Tra cứu tiến độ và bảo hành. | Mobile App |

## 2. Mô tả tổng quan

### 2.1 Bối cảnh hệ thống

```
┌──────────────┐        ┌──────────────┐
│  Web Admin   │        │  Mobile App  │
│ (Admin/Staff │        │  (Khách hàng)│
│ /Technician) │        │              │
└──────┬───────┘        └──────┬───────┘
       │      HTTPS / JSON     │
       └───────────┬───────────┘
                   ▼
         ┌───────────────────┐
         │  Backend Web API  │
         │  (ASP.NET Core)   │
         └─────────┬─────────┘
                   ▼
         ┌───────────────────┐
         │    SQL Server     │
         │   RepairShopDB    │
         └───────────────────┘
```

### 2.2 Quy trình nghiệp vụ hiện tại và vấn đề

| Khâu | Cách làm hiện tại | Vấn đề |
|---|---|---|
| Tiếp nhận thiết bị | Ghi phiếu giấy 2 bản, 1 giao khách | Thất lạc phiếu, chữ viết khó đọc, không tra được lịch sử |
| Theo dõi tiến độ | Hỏi trực tiếp kỹ thuật viên | Khách gọi điện hỏi liên tục, không ai biết phiếu ở khâu nào |
| Xuất linh kiện | Lấy trực tiếp từ kệ, ghi nhớ | Thất thoát vật tư, không đối soát được với tiền thu |
| Tính tiền | Cộng nhẩm hoặc máy tính tay | Sai số, quên tính linh kiện |
| Bảo hành | Dựa vào phiếu giấy khách giữ | Khách mất phiếu là mất bảo hành, dễ tranh chấp |
| Báo cáo | Không có | Chủ cửa hàng không biết lãi lỗ theo tháng |

## 3. Yêu cầu chức năng

Ký hiệu: **FR** = Functional Requirement. Cột "US" tham chiếu [User Stories](User-Stories.md).

### 3.1 Tài khoản & phân quyền

| Mã | Yêu cầu | US | Ưu tiên |
|---|---|---|---|
| FR-01 | Hệ thống cho phép đăng nhập bằng tên đăng nhập và mật khẩu, trả về token có thời hạn | US-01 | Must |
| FR-02 | Mật khẩu lưu dạng băm, không lưu dạng chữ thường | US-01 | Must |
| FR-03 | Admin tạo, sửa, khóa, mở khóa tài khoản và gán một trong 4 vai trò | US-02 | Must |
| FR-04 | Hệ thống chặn truy cập chức năng ngoài quyền của vai trò, trả mã 403 | US-02 | Must |
| FR-05 | Người dùng đổi được mật khẩu của chính mình | US-01 | Should |

### 3.2 Khách hàng & thiết bị

| Mã | Yêu cầu | US | Ưu tiên |
|---|---|---|---|
| FR-06 | Tạo khách hàng với mã tự sinh, tên và số điện thoại bắt buộc | US-03 | Must |
| FR-07 | Tìm kiếm khách hàng theo tên hoặc số điện thoại, có phân trang | US-03 | Must |
| FR-08 | Chặn tạo trùng số điện thoại khách hàng | US-03 | Must |
| FR-09 | Lưu nhiều thiết bị cho một khách hàng kèm loại, hãng, model, serial | US-04 | Must |
| FR-10 | Tra được lịch sử sửa chữa theo thiết bị hoặc theo số serial | US-04 | Should |

### 3.3 Phiếu sửa chữa

| Mã | Yêu cầu | US | Ưu tiên |
|---|---|---|---|
| FR-11 | Lập phiếu sửa chữa với mã tự sinh, bắt buộc ghi tình trạng thiết bị lúc nhận | US-05 | Must |
| FR-12 | Ghi nhận người tiếp nhận là người đang đăng nhập | US-05 | Must |
| FR-13 | Kỹ thuật viên cập nhật chẩn đoán và báo giá tiền công | US-06 | Must |
| FR-14 | Chuyển trạng thái phiếu theo đúng vòng trạng thái đã định, chặn chuyển không hợp lệ | US-07 | Must |
| FR-15 | Ghi lịch sử mỗi lần đổi trạng thái kèm người thực hiện và thời điểm | US-07 | Must |
| FR-16 | Admin phân công kỹ thuật viên cho phiếu | US-08 | Should |
| FR-17 | Hủy phiếu kèm lý do, tự hoàn trả linh kiện đã xuất về kho | US-07 | Should |
| FR-18 | Lọc danh sách phiếu theo trạng thái, kỹ thuật viên, khoảng ngày | US-05 | Must |

### 3.4 Linh kiện & tồn kho

| Mã | Yêu cầu | US | Ưu tiên |
|---|---|---|---|
| FR-19 | Quản lý danh mục linh kiện theo nhóm, có giá nhập, giá bán, tồn, tồn tối thiểu | US-09 | Must |
| FR-20 | Nhập kho làm tăng tồn và ghi giao dịch kho có tồn trước / tồn sau | US-09 | Must |
| FR-21 | Xuất linh kiện cho phiếu làm giảm tồn và cộng chi phí vào phiếu | US-10 | Must |
| FR-22 | Chặn xuất vượt tồn hiện tại, báo rõ linh kiện nào thiếu bao nhiêu | US-10 | Must |
| FR-23 | Giá bán ghi vào phiếu là giá tại thời điểm xuất, không đổi theo giá sau này | US-10 | Must |
| FR-24 | Toàn bộ thao tác xuất nằm trong một transaction, lỗi thì rollback tất cả | US-10 | Must |
| FR-25 | Hoàn trả linh kiện đã xuất về kho | US-10 | Should |
| FR-26 | Liệt kê linh kiện có tồn dưới hoặc bằng mức tồn tối thiểu | US-11 | Should |

### 3.5 Thanh toán

| Mã | Yêu cầu | US | Ưu tiên |
|---|---|---|---|
| FR-27 | Lập hóa đơn từ phiếu, tổng hợp tiền công và tiền linh kiện | US-12 | Must |
| FR-28 | Chỉ lập hóa đơn khi phiếu ở trạng thái COMPLETED | US-12 | Must |
| FR-29 | Mỗi phiếu chỉ có một hóa đơn | US-12 | Must |
| FR-30 | Ghi nhận thanh toán tiền mặt hoặc chuyển khoản, lưu thời điểm thanh toán | US-12 | Must |
| FR-31 | Áp dụng giảm giá, chặn giảm vượt tổng tiền | US-12 | Should |
| FR-32 | In hóa đơn khổ A5 | US-12 | Could |

### 3.6 Bảo hành

| Mã | Yêu cầu | US | Ưu tiên |
|---|---|---|---|
| FR-33 | Tự sinh phiếu bảo hành khi ghi nhận thanh toán xong | US-13 | Must |
| FR-34 | Thời hạn bảo hành lấy giá trị lớn nhất giữa loại dịch vụ và linh kiện đã thay | US-13 | Must |
| FR-35 | Không sinh bảo hành nếu dịch vụ không bảo hành và không thay linh kiện | US-13 | Must |
| FR-36 | Tra cứu bảo hành theo mã bảo hành, mã phiếu gốc hoặc số serial | US-14 | Must |
| FR-37 | Kiểm tra hiệu lực bảo hành, trả về còn hạn / hết hạn / đã dùng kèm số ngày còn lại | US-14 | Must |
| FR-38 | Lập phiếu sửa chữa bảo hành liên kết phiếu gốc, miễn tiền công | US-14 | Must |
| FR-39 | Liệt kê bảo hành sắp hết hạn trong 30 ngày | US-14 | Could |

### 3.7 Báo cáo

| Mã | Yêu cầu | US | Ưu tiên |
|---|---|---|---|
| FR-40 | Dashboard hiện doanh thu kỳ, số phiếu theo trạng thái, số cảnh báo tồn | US-15 | Must |
| FR-41 | Biểu đồ doanh thu theo ngày và theo tháng | US-15 | Must |
| FR-42 | Doanh thu chỉ tính hóa đơn đã thanh toán | US-15 | Must |
| FR-43 | Top linh kiện tiêu thụ kèm lợi nhuận gộp | US-15 | Should |
| FR-44 | Báo cáo hiệu suất kỹ thuật viên | US-15 | Should |
| FR-45 | Xuất báo cáo ra file CSV | US-15 | Could |

### 3.8 Mobile App cho khách hàng

| Mã | Yêu cầu | US | Ưu tiên |
|---|---|---|---|
| FR-46 | Khách hàng đăng nhập bằng số điện thoại đã đăng ký tại cửa hàng | US-16 | Should |
| FR-47 | Xem danh sách phiếu sửa chữa của chính mình | US-16 | Should |
| FR-48 | Xem chi tiết phiếu: chẩn đoán, báo giá, trạng thái hiện tại | US-16 | Should |
| FR-49 | Tra cứu phiếu bảo hành và số ngày còn lại | US-16 | Should |
| FR-50 | Hệ thống chỉ trả dữ liệu thuộc về khách hàng gắn với token đang dùng | US-16 | Must |

## 4. Yêu cầu phi chức năng

### 4.1 Hiệu năng

| Mã | Yêu cầu |
|---|---|
| NFR-01 | API xử lý giao dịch (lập phiếu, xuất linh kiện, lập hóa đơn) phản hồi dưới 1 giây |
| NFR-02 | API truy vấn danh sách có phân trang, mặc định 20 bản ghi mỗi trang |
| NFR-03 | Truy vấn báo cáo trên 200+ phiếu phản hồi dưới 3 giây |
| NFR-04 | Bảng có truy vấn thường xuyên phải có index phù hợp |

### 4.2 Bảo mật

| Mã | Yêu cầu |
|---|---|
| NFR-05 | Mật khẩu băm bằng BCrypt, không lưu dạng chữ thường |
| NFR-06 | Mọi endpoint trừ đăng nhập yêu cầu JWT hợp lệ |
| NFR-07 | Token hết hạn sau 120 phút |
| NFR-08 | Kiểm tra quyền ở phía Backend, không dựa vào việc client ẩn menu |
| NFR-09 | Dùng tham số hóa truy vấn (EF Core) để tránh SQL injection |
| NFR-10 | Thông báo lỗi không tiết lộ cấu trúc CSDL hay stack trace ra client |
| NFR-11 | Không commit thông tin kết nối và khóa bí mật vào repository |

### 4.3 Tính toàn vẹn dữ liệu

| Mã | Yêu cầu |
|---|---|
| NFR-12 | Mọi thao tác làm thay đổi tồn kho phải ghi vết vào `StockTransactions` |
| NFR-13 | Mọi lần đổi trạng thái phiếu phải ghi vết vào `TicketStatusHistory` |
| NFR-14 | Thao tác liên quan nhiều bảng phải nằm trong transaction |
| NFR-15 | Tồn kho không bao giờ được âm (ràng buộc CHECK ở CSDL) |
| NFR-16 | Xóa khách hàng và linh kiện dùng xóa mềm, giữ lại dữ liệu lịch sử |

### 4.4 Khả dụng & giao diện

| Mã | Yêu cầu |
|---|---|
| NFR-17 | Toàn bộ giao diện tiếng Việt |
| NFR-18 | Số tiền hiển thị định dạng VNĐ có dấu phân cách nghìn |
| NFR-19 | Ngày hiển thị định dạng `dd/MM/yyyy HH:mm` |
| NFR-20 | Thao tác xóa và hủy phải có hộp thoại xác nhận |
| NFR-21 | Mọi form có thông báo lỗi rõ ràng ngay tại trường bị sai |
| NFR-22 | Web Admin chạy được trên Chrome và Edge phiên bản mới |

### 4.5 Khả năng bảo trì

| Mã | Yêu cầu |
|---|---|
| NFR-23 | Logic nghiệp vụ đặt ở lớp Service, không đặt trong Controller |
| NFR-24 | Mã nguồn tuân theo quy ước đặt tên trong `CONTRIBUTING.md` |
| NFR-25 | API có tài liệu Swagger tự sinh |

## 5. Ràng buộc

- Thời gian phát triển 8 tuần với nhóm 3 thành viên làm bán thời gian.
- Kinh phí 0 đồng, chỉ dùng công cụ miễn phí hoặc bản dùng thử cho sinh viên.
- Chạy trên môi trường local hoặc dịch vụ hosting miễn phí, không có hạ tầng đám mây trả phí.
- Mobile App chỉ build cho Android.

## 6. Giả định

- Cửa hàng có máy tính chạy Windows và kết nối internet ổn định.
- Nhân viên biết dùng máy tính ở mức cơ bản.
- Số lượng phiếu sửa chữa khoảng 20–50 phiếu mỗi ngày, không cần thiết kế cho quy mô lớn hơn.
- Dữ liệu lịch sử trước khi dùng hệ thống không cần nhập lại.
