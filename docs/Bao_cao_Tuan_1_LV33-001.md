---
title: "Báo cáo Tuần 1 — Đề tài LV33-001"
subtitle: "Hệ thống quản lý tổng thể cho cửa hàng sửa chữa"
lang: vi
---

# 1. Thông tin chung về đề tài

**Mã đề tài:** LV33-001

**Tên đề tài:** Hệ thống quản lý tổng thể cho cửa hàng sửa chữa

**Nhóm:** Nhóm 11 — Lớp 23DTHC6 — Học kỳ 2627HK1A

**Thời gian thực hiện:** 08/09/2026 – 03/11/2026 (8 tuần / 8 sprints)

## Vấn đề cần giải quyết

- Việc tiếp nhận và theo dõi phiếu sửa chữa còn ghi tay trên sổ hoặc file Excel rời rạc, dễ thất lạc phiếu, khó tra lại lịch sử sửa chữa của một thiết bị và không biết phiếu đang nằm ở khâu nào.
- Linh kiện xuất dùng cho từng phiếu không được trừ tồn kho theo thời gian thực, dẫn đến thất thoát vật tư, không đối soát được giữa linh kiện đã xuất và tiền đã thu.
- Thông tin bảo hành (thời hạn, phạm vi, phiếu gốc) không được lưu tập trung nên khi khách quay lại, cửa hàng mất nhiều thời gian xác minh và dễ xảy ra tranh chấp.
- Chủ cửa hàng không có số liệu tổng hợp về doanh thu, linh kiện bán chạy và hiệu suất kỹ thuật viên để ra quyết định.

## Đối tượng sử dụng chính

- **Nhân viên tiếp nhận / Kỹ thuật viên (Staff / Technician):** lập phiếu sửa chữa, chẩn đoán và báo giá, yêu cầu xuất linh kiện, cập nhật trạng thái tiến độ và bàn giao thiết bị.
- **Chủ cửa hàng / Quản lý (Admin):** giám sát dashboard doanh thu, quản lý danh mục linh kiện và tồn kho, cấu hình biểu giá dịch vụ, phân quyền người dùng và xem báo cáo thống kê.
- **Khách hàng (Customer):** tra cứu tiến độ phiếu sửa chữa và tra cứu thông tin bảo hành của thiết bị qua ứng dụng mobile.

# 2. Danh sách thành viên và phân công vai trò

Nhóm gồm 3 thành viên, thống nhất kiêm nhiệm để gộp 5 vị trí chuyên môn thành 3 người phụ trách chính, đảm bảo mỗi thành viên đều có khối lượng công việc độc lập.

| MSSV | Họ và tên | Lớp | Vai trò | Liên hệ |
|---|---|---|---|---|
| 2380601183 | Nguyễn Viết Lãm *(Nhóm trưởng)* | 23DTHC6 | PM / Scrum Master + Backend & API + DevOps | 0332929050 — lamnguyenadc@gmail.com |
| 2380601178 | Nguyễn Đại Kỳ | 23DTHC6 | UI/UX + Frontend + QA / Tester | 0798308118 — daikyvctvn123@gmail.com |
| 2380601292 | Trần Ngọc Lợi | 23DTHC6 | BA / PO + Database | 0337536353 — ngocloihdkg@gmail.com |

## Mô tả trách nhiệm

- **Nguyễn Viết Lãm — PM / Scrum Master + Backend & API + DevOps:** lập và duy trì Project Charter, Scope Statement, WBS và lịch trình; điều phối Sprint Planning, Daily Standup, Sprint Review; thiết kế kiến trúc hệ thống và bộ API; xây dựng Backend; quản trị GitHub theo Gitflow và thiết lập môi trường demo.
- **Trần Ngọc Lợi — BA / PO + Database:** khảo sát nghiệp vụ cửa hàng sửa chữa; đặc tả yêu cầu và thiết kế luồng nghiệp vụ; quản lý Product Backlog; thiết kế ERD, CSDL SQL Server và truy vấn báo cáo.
- **Nguyễn Đại Kỳ — UI/UX + Frontend + QA / Tester:** thiết kế mockup UI; xây dựng Web Admin/Mobile; lập test case, kiểm thử chức năng và kiểm thử API bằng Postman; quản lý bug log và xác nhận sửa lỗi.

# 3. Mục tiêu SMART, quy trình nghiệp vụ & phạm vi dự án

## Mục tiêu SMART

- **S (Specific — Cụ thể):** Xây dựng hệ thống quản lý tổng thể cho cửa hàng sửa chữa gồm Backend API, Web Admin và Mobile App, quản lý bốn thực thể lõi là phiếu sửa chữa, linh kiện, khách hàng và bảo hành, kèm phân quyền chi tiết (RBAC) và báo cáo thống kê doanh thu.
- **M (Measurable — Đo lường được):** Hoàn thành 16 User Stories; đạt tối thiểu 80% phạm vi baseline và 100% chức năng cốt lõi (Must-have); linh kiện xuất dùng được trừ tồn kho chính xác 100% so với phiếu; API xử lý giao dịch phản hồi dưới 1 giây.
- **A (Achievable — Khả thi):** Sử dụng stack công nghệ nhóm đã học (ASP.NET Core Web API hoặc PHP MVC, SQL Server, Bootstrap, Flutter/Android) cùng công cụ miễn phí cho sinh viên, phù hợp năng lực nhóm 3 thành viên làm bán thời gian.
- **R (Relevant — Liên quan):** Giải quyết trực tiếp bài toán thất lạc phiếu sửa chữa, thất thoát linh kiện và tranh chấp bảo hành, đồng thời cung cấp số liệu để chủ cửa hàng ra quyết định.
- **T (Time-bound — Có thời hạn):** Bàn giao MVP cùng toàn bộ tài liệu nghiệm thu trong 8 tuần, từ 08/09/2026 đến 03/11/2026, chia thành 8 sprints (1 tuần/sprint).

## Các quy trình nghiệp vụ lõi (3 quy trình)

**Quy trình 1 — Tiếp nhận & xử lý phiếu sửa chữa:** Nhân viên tiếp nhận thiết bị, tra cứu hoặc tạo mới khách hàng, ghi nhận tình trạng thiết bị lúc nhận và lập phiếu sửa chữa. Kỹ thuật viên chẩn đoán lỗi, lập báo giá gửi khách xác nhận, sau đó cập nhật trạng thái phiếu theo từng bước (Tiếp nhận → Đang chẩn đoán → Chờ khách xác nhận → Đang sửa → Hoàn tất → Đã bàn giao). Khách hàng theo dõi tiến độ phiếu qua ứng dụng mobile.

**Quy trình 2 — Quản lý linh kiện & xuất kho theo phiếu:** Quản lý nhập linh kiện vào danh mục kèm giá nhập, giá bán và tồn kho. Khi sửa chữa, kỹ thuật viên tạo yêu cầu xuất linh kiện gắn với phiếu sửa chữa; hệ thống kiểm tra tồn kho, trừ tồn theo thời gian thực và cộng chi phí linh kiện vào phiếu. Hệ thống cảnh báo khi linh kiện xuống dưới mức tồn tối thiểu để quản lý lên đơn nhập bổ sung.

**Quy trình 3 — Thanh toán, lập bảo hành & tiếp nhận tái bảo hành:** Khi phiếu hoàn tất, hệ thống tổng hợp tiền công dịch vụ cộng chi phí linh kiện để xuất hóa đơn, ghi nhận thanh toán (tiền mặt hoặc chuyển khoản nội bộ) và sinh phiếu bảo hành có thời hạn theo loại dịch vụ và linh kiện thay thế. Khi khách quay lại trong thời hạn, nhân viên tra cứu phiếu bảo hành theo số phiếu gốc hoặc số serial thiết bị, kiểm tra điều kiện còn hiệu lực và lập phiếu sửa chữa bảo hành liên kết với phiếu gốc.

## Phạm vi dự án

**Phạm vi trong dự án (In-Scope):**

- Quản lý tài khoản và phân quyền chi tiết theo vai trò (RBAC).
- Quản lý khách hàng và thiết bị của khách.
- Quản lý phiếu sửa chữa theo vòng trạng thái, báo giá và phân công kỹ thuật viên.
- Quản lý danh mục linh kiện, tồn kho, xuất linh kiện theo phiếu và cảnh báo tồn tối thiểu.
- Quản lý bảo hành: sinh phiếu bảo hành, tra cứu hiệu lực, lập phiếu sửa chữa bảo hành.
- Lập hóa đơn và ghi nhận thanh toán nội bộ (tiền mặt / chuyển khoản).
- Dashboard và báo cáo thống kê: doanh thu theo kỳ, linh kiện tiêu thụ, số phiếu theo trạng thái, hiệu suất kỹ thuật viên.
- Mobile App cho khách hàng: tra cứu tiến độ phiếu và thông tin bảo hành.

**Phạm vi ngoài dự án (Out-of-Scope):**

- Tích hợp cổng thanh toán trực tuyến của ngân hàng hoặc ví điện tử (VNPAY / Momo) — giai đoạn này chỉ ghi nhận tiền mặt và chuyển khoản nội bộ.
- Tích hợp phần mềm kế toán ngoài và xuất hóa đơn điện tử theo chuẩn thuế.
- Quản lý nhân sự, tính lương và chấm công cho kỹ thuật viên.
- Bán hàng online hoặc website thương mại điện tử cho linh kiện.
- Đọc mã vạch / RFID bằng thiết bị phần cứng chuyên dụng.

# 4. Công nghệ dự kiến, nguồn dữ liệu & rủi ro ban đầu

## Công nghệ dự kiến

**Ngôn ngữ lập trình**

- **Backend & API:** C# (ASP.NET Core Web API) hoặc PHP theo mô hình MVC để xử lý logic nghiệp vụ.
- **Web Admin:** HTML5, CSS3, JavaScript kết hợp thư viện Bootstrap để dựng giao diện quản trị.
- **Mobile App (khách hàng):** Java (Android Studio) hoặc Dart (Flutter).
- **Cơ sở dữ liệu:** SQL — Microsoft SQL Server, truy vấn phục vụ nghiệp vụ và báo cáo.

**Công cụ phần mềm**

- **IDE:** Visual Studio.
- **Quản lý CSDL:** SQL Server Management Studio (SSMS).
- **Kiểm thử API:** Postman.
- **Vẽ sơ đồ thiết kế:** StarUML (Use Case, Sequence, BFD); Draw.io / Figma cho luồng và mockup giao diện.
- **Quản lý mã nguồn & dự án:** GitHub theo Gitflow, Jira Software (Scrum framework).
- **Làm việc nhóm & lưu hồ sơ:** Google Drive, Zalo / Google Meet.

## Nguồn dữ liệu

- Dữ liệu khảo sát thực tế từ cửa hàng sửa chữa: mẫu phiếu sửa chữa đang dùng, danh mục linh kiện kèm giá nhập và giá bán, biểu giá tiền công dịch vụ, chính sách và thời hạn bảo hành theo từng loại dịch vụ.
- Dữ liệu mô phỏng (Synthetic / Dummy Data) phục vụ demo và kiểm thử: khoảng 200+ bản ghi phiếu sửa chữa, phiếu xuất linh kiện và phiếu bảo hành trải theo nhiều tháng để dashboard doanh thu và báo cáo thống kê có số liệu đủ ý nghĩa.

## Khó khăn và rủi ro ban đầu

- **Rủi ro nguồn dữ liệu:** Cửa hàng ghi chép thủ công nên dữ liệu lịch sử không đầy đủ và không đúng định dạng để nhập vào hệ thống. *Giải pháp:* chuẩn hóa lại danh mục linh kiện và biểu giá theo biên bản khảo sát, phần lịch sử dùng dữ liệu mô phỏng theo phân phối sát nghiệp vụ.
- **Rủi ro tiến độ:** Nhóm chỉ có 3 thành viên kiêm nhiệm 5 vai trò, trong đó Nhóm trưởng vừa quản lý dự án vừa đảm nhiệm toàn bộ Backend nên dễ trở thành điểm nghẽn. *Giải pháp:* áp dụng Scrum 1 tuần/sprint, Daily Standup ngắn qua Zalo/Meet, ưu tiên hoàn thành nhóm chức năng Must-have trước; BA và QA nhận thêm phần dữ liệu mẫu và tài liệu để giảm tải cho Backend.
- **Rủi ro kỹ thuật:** Nhóm chưa có kinh nghiệm làm Mobile App kết nối API thực tế, dễ mất thời gian ở khâu tích hợp. *Giải pháp:* chốt hợp đồng API sớm ở Sprint 2–3, dựng sẵn Postman collection để Mobile phát triển song song và test độc lập với Backend.
- **Rủi ro phạm vi:** Nghiệp vụ bảo hành và xuất linh kiện dễ phát sinh yêu cầu mới trong quá trình làm, gây phình phạm vi. *Giải pháp:* chốt baseline phạm vi ngay Sprint 1, mọi thay đổi phải qua Product Backlog và được PO xét thứ tự ưu tiên.

# 5. Kế hoạch công việc Tuần 1 và các liên kết minh chứng

## Kết quả Tuần 1 (Sprint 1 Deliverables)

- Thống nhất Project Charter v0.1, Scope Statement và ma trận RACI.
- Hoàn thành WBS 7 giai đoạn kèm phân bổ nguồn lực, công (người-ngày) và lịch trình loại trừ ngày nghỉ.
- Thiết lập GitHub Repository chuẩn Gitflow kèm README.md chi tiết.
- Phác thảo bộ 5 màn hình cốt lõi trên Figma: đăng nhập, danh sách phiếu sửa chữa, chi tiết phiếu & xuất linh kiện, quản lý tồn kho linh kiện, dashboard doanh thu.
- Phân rã 16 User Stories trên Jira Product Backlog; hoàn thành nghiệm thu Sprint 1.

## Liên kết minh chứng đính kèm

| Nội dung minh chứng | Liên kết |
|---|---|
| Thư mục tài liệu Google Drive (Project Charter v0.1, RACI, Scope Statement, WBS) | *[điền link]* |
| Jira Software Backlog & Board | *[điền link]* |
| GitHub Repository [Public] | https://github.com/Nguyen-Viet-Lam/QLDACNTT |
| Figma UI Prototype v0.1 | *[điền link]* |

# Phụ lục: Danh sách 16 User Stories

| # | User Story | Nhóm chức năng | Ưu tiên |
|---|---|---|---|
| US-01 | Là người dùng, tôi muốn đăng nhập bằng tài khoản được cấp để truy cập hệ thống theo đúng quyền của mình. | Tài khoản & RBAC | Must |
| US-02 | Là Admin, tôi muốn tạo và phân quyền tài khoản theo vai trò để giới hạn chức năng mỗi nhân viên được dùng. | Tài khoản & RBAC | Must |
| US-03 | Là nhân viên tiếp nhận, tôi muốn tra cứu hoặc tạo mới khách hàng để gắn vào phiếu sửa chữa. | Khách hàng | Must |
| US-04 | Là nhân viên tiếp nhận, tôi muốn lưu thông tin thiết bị của khách kèm số serial để tra lại lịch sử sửa chữa. | Khách hàng | Must |
| US-05 | Là nhân viên tiếp nhận, tôi muốn lập phiếu sửa chữa ghi nhận tình trạng thiết bị lúc nhận để tránh tranh chấp khi bàn giao. | Phiếu sửa chữa | Must |
| US-06 | Là kỹ thuật viên, tôi muốn cập nhật chẩn đoán và lập báo giá trên phiếu để khách xác nhận trước khi sửa. | Phiếu sửa chữa | Must |
| US-07 | Là kỹ thuật viên, tôi muốn cập nhật trạng thái phiếu theo từng bước để cả nhóm biết phiếu đang ở khâu nào. | Phiếu sửa chữa | Must |
| US-08 | Là Admin, tôi muốn phân công kỹ thuật viên cho từng phiếu để cân đối khối lượng công việc. | Phiếu sửa chữa | Should |
| US-09 | Là Admin, tôi muốn quản lý danh mục linh kiện kèm giá nhập, giá bán và tồn kho để chủ động nguồn vật tư. | Linh kiện & tồn kho | Must |
| US-10 | Là kỹ thuật viên, tôi muốn xuất linh kiện gắn với phiếu sửa chữa để hệ thống tự trừ tồn kho và cộng chi phí vào phiếu. | Linh kiện & tồn kho | Must |
| US-11 | Là Admin, tôi muốn nhận cảnh báo khi linh kiện xuống dưới mức tồn tối thiểu để kịp lên đơn nhập bổ sung. | Linh kiện & tồn kho | Should |
| US-12 | Là nhân viên, tôi muốn lập hóa đơn tổng hợp tiền công và chi phí linh kiện, ghi nhận thanh toán để đối soát dòng tiền. | Thanh toán | Must |
| US-13 | Là nhân viên, tôi muốn hệ thống sinh phiếu bảo hành có thời hạn khi phiếu hoàn tất để làm căn cứ khi khách quay lại. | Bảo hành | Must |
| US-14 | Là nhân viên, tôi muốn tra cứu hiệu lực bảo hành theo số phiếu gốc hoặc serial và lập phiếu sửa chữa bảo hành liên kết phiếu gốc. | Bảo hành | Must |
| US-15 | Là Admin, tôi muốn xem dashboard doanh thu theo kỳ, linh kiện tiêu thụ và số phiếu theo trạng thái để ra quyết định. | Báo cáo | Must |
| US-16 | Là khách hàng, tôi muốn tra cứu tiến độ phiếu sửa chữa và thông tin bảo hành trên ứng dụng mobile để không phải gọi điện hỏi. | Mobile App | Should |

