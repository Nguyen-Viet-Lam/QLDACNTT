# BÁO CÁO ĐỐI CHIẾU SỐ LIỆU BẢO VỆ – NHÓM 11

Ngày đối chiếu: 06/10/2026  
Đề tài: Hệ thống quản lý tổng thể cho cửa hàng sửa chữa – LV33-001

## 1. Kết luận ngắn gọn cần trình bày

- Dự án **không bị trễ tổng thể theo EVM** tại mốc 05/10/2026 vì `SPI = 1,0200 > 1` và `SV = +275.000 VNĐ`.
- Dự án **vượt chi phí nhẹ 200.000 VNĐ** vì `CPI = 0,9859 < 1` và `CV = -200.000 VNĐ`.
- `SV = +275.000 VNĐ` là giá trị công việc làm sớm quy đổi theo ngân sách, **không phải tiền lời**.
- Không được cộng `SV + CV = 75.000 VNĐ` rồi gọi là “lời ròng”; hai chỉ số đo hai khía cạnh khác nhau.
- Task giao diện MBA-46 từng có dấu hiệu trễ cục bộ. Jira ghi hạn 28/09/2026 và cập nhật Done ngày 04/10/2026, chênh 6 ngày lịch. Cần nói rõ đây có thể là ngày cập nhật trạng thái muộn, không tự khẳng định là 6 ngày thi công trễ nếu chưa có timesheet.
- Sau khi đối chiếu mã nguồn, Jira có 88 task: 44 Done, 10 In Progress, 34 To Do. Không có task chưa Done nào quá hạn tại ngày 06/10/2026.

## 2. Bảng EVM đúng theo Excel

Nguồn số liệu: sheet `3. Chi phi & EVM (Ngay 13)` tại mốc 05/10/2026.

| Chỉ số | Công thức | Giá trị | Cách nói đúng |
|---|---:|---:|---|
| BAC | Tổng chi phí kế hoạch chi tiết | 15.950.000 VNĐ | Ngân sách hoàn thành theo bảng chi tiết Excel |
| PV/BCWS | Giá trị kế hoạch đến ngày báo cáo | 13.750.000 VNĐ | Đáng lẽ hoàn thành lượng việc trị giá 13,75 triệu |
| EV/BCWP | Giá trị công việc thực sự hoàn thành | 14.025.000 VNĐ | Đã tạo ra lượng công việc trị giá 14,025 triệu |
| AC/ACWP | Chi phí thực tế | 14.225.000 VNĐ | Đã chi 14,225 triệu |
| CV | EV - AC | -200.000 VNĐ | Vượt chi phí 200.000 đồng |
| SV | EV - PV | +275.000 VNĐ | Đi trước kế hoạch một lượng công việc trị giá 275.000 đồng |
| CPI | EV / AC | 0,9859 | Mỗi 1 đồng chi ra tạo được khoảng 0,986 đồng giá trị |
| SPI | EV / PV | 1,0200 | Khối lượng hoàn thành nhanh hơn kế hoạch khoảng 2% |
| EAC | BAC / CPI | khoảng 16.177.451 VNĐ | Nếu hiệu suất chi phí không đổi, tổng chi phí dự báo khoảng 16,177 triệu |
| ETC | EAC - AC | khoảng 1.952.451 VNĐ | Chi phí ước tính còn phải chi |
| VAC | BAC - EAC | khoảng -227.451 VNĐ | Dự báo vượt ngân sách khi hoàn thành khoảng 227.000 đồng |
| TCPI | (BAC - EV) / (BAC - AC) | khoảng 1,1159 | Phần việc còn lại phải đạt hiệu suất chi phí 1,116 để giữ BAC |

### Điểm không khớp cần giải thích

Project Charter ghi BAC ban đầu là 13.400.000 VNĐ, trong khi tổng cột chi phí kế hoạch của sheet EVM là 15.950.000 VNĐ, chênh 2.550.000 VNĐ. Nhóm phải chọn một baseline chính thức. Nếu dùng 15.950.000 VNĐ thì cần ghi đây là baseline cập nhật và bổ sung Change Request/biên bản phê duyệt; nếu chưa có phê duyệt thì không được nói hai con số đều là BAC chính thức.

## 3. Trễ, vượt chi phí và cách khắc phục

| Vấn đề | Bằng chứng | Ảnh hưởng | Khắc phục đã/đang áp dụng | Cách kiểm soát tiếp |
|---|---|---|---|---|
| Giao diện MBA-46 có dấu hiệu trễ cục bộ | Due 28/09, Jira cập nhật Done 04/10 | Nguy cơ ảnh hưởng tích hợp UI–API | Lãm hỗ trợ CORS/endpoint admin; Kỳ làm UI song song với backend | Chia nhỏ UI theo màn hình, demo hằng ngày, không đợi toàn bộ API hoàn tất |
| Vượt chi phí 200.000 VNĐ | CV = -200.000; CPI = 0,9859 | Hiệu suất chi phí thấp hơn kế hoạch khoảng 1,41% | Tận dụng công cụ miễn phí, giới hạn làm lại, ưu tiên đường găng | Theo dõi AC theo task; mọi phát sinh phải có Change Request |
| Jira đánh dấu Done quá sớm | Nhiều task không có mã nguồn tương ứng | Báo cáo sai, dễ bị phản biện | Đã đưa 14 task về To Do/In Progress theo bằng chứng repo | Chỉ Done khi đủ Definition of Done và có commit/test/PR |
| `develop` chậm hơn `main` | Main đi trước develop 5 commit | Quy trình nhánh không nhất quán | Cần đồng bộ main về develop trước task tiếp theo | Feature phải PR vào develop; chỉ release mới vào main |

### Cách trả lời “nhóm bị lỗ bao nhiêu?”

> Nhóm không dùng từ “lỗ” theo nghĩa doanh thu kinh doanh. Theo EVM, tại mốc 05/10 chi phí thực tế cao hơn giá trị thu được 200.000 đồng, nên CV âm 200.000 và CPI bằng 0,9859. Đây là vượt chi phí dự án, không phải lỗ bán hàng. Nếu xu hướng giữ nguyên, EAC khoảng 16,177 triệu, vượt BAC chi tiết khoảng 227.000 đồng.

### Cách trả lời “có bị trễ không?”

> Có trễ cục bộ ở hạng mục giao diện, nhưng chưa trễ toàn dự án tại mốc báo cáo. EVM cho SPI bằng 1,02 và SV dương 275.000 đồng, tức tổng khối lượng đang đi trước kế hoạch khoảng 2%. Nhóm xử lý bằng cách làm UI và backend song song, nhưng chấp nhận rủi ro phải làm lại khi API thay đổi.

## 4. PERT/CPM, tiến tới, quay lui và thời gian chờ

Giả định quan hệ trước–sau dùng để tính nhất quán với 18 đường công việc trong báo cáo:

- A và B khởi động song song.
- C và D chờ cả A và B.
- E, F, G chạy song song sau D.
- H, I, J chạy song song sau G.
- K, L, M chạy song song sau J.
- N và O chạy song song sau M.
- Mốc kết thúc chờ toàn bộ nhánh hoàn thành.

| CV | Thời lượng | Công việc trước | ES | EF | LS | LF | Slack |
|---|---:|---|---:|---:|---:|---:|---:|
| A | 2 | Bắt đầu | 0 | 2 | 0 | 2 | 0 |
| B | 1 | Bắt đầu | 0 | 1 | 1 | 2 | 1 |
| C | 1 | A, B | 2 | 3 | 12 | 13 | 10 |
| D | 2 | A, B | 2 | 4 | 2 | 4 | 0 |
| E | 1 | D | 4 | 5 | 12 | 13 | 8 |
| F | 1 | D | 4 | 5 | 12 | 13 | 8 |
| G | 2 | D | 4 | 6 | 4 | 6 | 0 |
| H | 1 | G | 6 | 7 | 12 | 13 | 6 |
| I | 1 | G | 6 | 7 | 12 | 13 | 6 |
| J | 2 | G | 6 | 8 | 6 | 8 | 0 |
| K | 1 | J | 8 | 9 | 12 | 13 | 4 |
| L | 2 | J | 8 | 10 | 11 | 13 | 3 |
| M | 3 | J | 8 | 11 | 8 | 11 | 0 |
| N | 1 | M | 11 | 12 | 12 | 13 | 1 |
| O | 2 | M | 11 | 13 | 11 | 13 | 0 |

Đường găng: `A → D → G → J → M → O = 13 ngày`. Tất cả công việc trên đường này có Slack bằng 0.

### Tiến tới – Forward Pass

- Bắt đầu từ thời điểm 0.
- `EF = ES + Duration`.
- Nếu một công việc có nhiều công việc trước, `ES = Max(EF của các công việc trước)`.
- Ví dụ D chờ A và B: A xong ngày 2, B xong ngày 1, nên D chỉ bắt đầu ở ngày 2.

Chuỗi găng khi tiến tới: `A [0–2] → D [2–4] → G [4–6] → J [6–8] → M [8–11] → O [11–13]`.

### Quay lui – Backward Pass

- Bắt đầu từ mốc kết thúc ngày 13.
- `LS = LF - Duration`.
- Nếu một công việc có nhiều công việc sau, `LF = Min(LS của các công việc sau)`.

Chuỗi găng khi quay lui: `O [LS=11, LF=13] → M [8,11] → J [6,8] → G [4,6] → D [2,4] → A [0,2]`.

### Thời gian chờ và dự trữ

- B hoàn thành ngày 1 nhưng D phải chờ A đến ngày 2, nên nhánh B có 1 ngày chờ/dự trữ.
- Công việc có Slack lớn có thể lùi trong giới hạn Slack mà chưa làm trễ dự án.
- Công việc đường găng có Slack bằng 0; chậm 1 ngày thì dự án chậm 1 ngày nếu không rút ngắn công việc khác.
- “Thời gian chờ” do phụ thuộc khác với “Slack”: chờ là không thể bắt đầu vì tiền nhiệm chưa xong; Slack là quyền được lùi mà chưa ảnh hưởng mốc cuối.

## 5. Tiến tới, quay lui, song song và rút ngắn tiến độ

| Khái niệm | Nhóm đang áp dụng | Lợi ích | Rủi ro |
|---|---|---|---|
| Làm tuần tự | Task sau chờ task trước đủ điều kiện | Ít làm lại | Thời gian dài |
| Làm song song | UI, backend, SQL và test được làm đồng thời ở các nhánh riêng | Rút ngắn lịch | Dễ lệch API, xung đột merge |
| Fast-tracking | Kỳ làm UI khi Lãm vẫn hoàn thiện API | Nhanh hơn mà không nhất thiết thêm người | Có thể phải sửa UI khi API đổi |
| Crashing | Lãm hỗ trợ CORS/admin và tích hợp cho Kỳ | Rút ngắn task găng bằng thêm nguồn lực | Tăng chi phí, phù hợp với CV âm |
| Quay lui kỹ thuật | Revert commit/PR khi bản tích hợp lỗi | Khôi phục nhanh phiên bản ổn định | Phải kiểm thử lại phần phụ thuộc |

## 6. Trạng thái Jira và GitHub sau đối chiếu

### Jira

| Trạng thái | Số task |
|---|---:|
| Done | 44 |
| In Progress | 10 |
| To Do | 34 |
| Tổng | 88 |

10 task In Progress: MBA-47, MBA-50, MBA-51, MBA-52, MBA-56, MBA-58, MBA-64, MBA-66, MBA-70, MBA-72.

### GitHub Issues

| Trạng thái | Số issue |
|---|---:|
| Closed | 25 |
| Open | 18 |
| Tổng | 43 |

- 27 issue có nhãn Jira đã được đồng bộ trạng thái với Jira và gán cho tài khoản GitHub của Nguyễn Đại Kỳ vì toàn bộ nhóm issue này là task của Kỳ.
- 16 issue Sprint cũ không có mã Jira đã được đóng Completed và gán đúng thành viên theo nhãn.
- GitHub không cần tạo đủ 88 issue nếu nhóm quy ước Jira quản lý toàn bộ công việc còn GitHub chỉ quản lý các việc gắn với mã nguồn. Phải nói rõ quy ước này để tránh hiểu là thiếu task.

## 7. Nhánh Git và việc xóa nhánh

- Repo có 18 nhánh remote: main, develop, release và 15 feature.
- Toàn bộ 17 nhánh ngoài main hiện đã được merge vào main; không có commit feature chưa merge.
- Xóa nhánh feature đã merge thường không làm mất code vì commit vẫn nằm trong main và lịch sử PR.
- Không xóa main, develop, tag `v0.3-gate3` hoặc nhánh release đang dùng làm mốc nghiệm thu.
- Nên xóa feature đã merge để danh sách gọn; nếu cần xem lại thì mở PR/commit hoặc tạo lại nhánh từ commit.
- Không xóa nhánh chưa merge, nhánh đang có người làm, hoặc nhánh chứa commit duy nhất chưa có tag/PR.
- Xóa nhánh không phải là quay lui code. Khi cần quay lui bản đã merge, dùng `git revert` để tạo commit đảo thay đổi và giữ lịch sử kiểm toán.

Quy trình đề nghị: đồng bộ `develop` từ `main` → tạo feature mới từ develop → PR vào develop → kiểm thử → release/main → xóa feature sau merge.

## 8. Những điều tuyệt đối không nên nói khi bảo vệ

- Không nói “dự án lời 75.000 đồng”.
- Không nói `SV` là tiền thu được hoặc lợi nhuận.
- Không nói toàn bộ Web Admin đã hoàn thiện 100%; nhiều màn hình còn là prototype tĩnh.
- Không nói backend đã kết nối SQL Server thật; hiện backend dùng AppData in-memory.
- Không nói đã có React, Unit Test, caching hoặc kiểm thử OWASP khi repo chưa có bằng chứng.
- Không nói 88 task Jira đều có GitHub Issue; hiện GitHub chỉ theo dõi 43 issue.
- Không nói mọi Pull Request đều đi qua develop; PR #46 và #47 đã merge trực tiếp vào main.

