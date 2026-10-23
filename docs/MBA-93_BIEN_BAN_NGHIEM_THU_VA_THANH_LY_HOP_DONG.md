# MBA-93: Biên Bản Nghiệm Thu và Thanh Lý Hợp Đồng Dịch Vụ

**Dự án**: Hệ thống quản lý tổng thể cửa hàng sửa chữa - LV33-001
**Nhóm**: Nhóm 11 - Lớp 23DTHC6
**Thành viên**: Nguyễn Việt Lam, Trần Ngọc Lợi, Nguyễn Đại Kỳ
**Ngày lập**: 23/10/2026

---

# PHẦN I: BIÊN BẢN NGHIỆM THU HỆ THỐNG

## CỘNG HÒA XÃ HỘI CHỦ NGHĨA VIỆT NAM
## Độc lập - Tự do - Hạnh phúc

# BIÊN BẢN NGHIỆM THU
## Hệ Thống Phần Mềm Quản Lý Cửa Hàng Sửa Chữa (QLDACNTT - LV33-001)

**Ngày nghiệm thu**: 23/10/2026
**Địa điểm**: Trường ĐH Công nghệ thông tin và Truyền thông - ĐH Thái Nguyên

---

## I.1 Các Bên Tham Gia

**Bên A - Bên Đặt Hàng:**

| Thông tin | Nội dung |
|-----------|---------|
| Đại diện | Giảng viên hướng dẫn |
| Đơn vị | Khoa Công nghệ thông tin |
| Vai trò | Bên tiếp nhận và đánh giá sản phẩm |

**Bên B - Bên Thực Hiện:**

| Thông tin | Nội dung |
|-----------|---------|
| Tên nhóm | Nhóm 11 - Lớp 23DTHC6 |
| Trưởng nhóm | Nguyễn Việt Lam |
| Thành viên | Trần Ngọc Lợi, Nguyễn Đại Kỳ |

---

## I.2 Thông Tin Hệ Thống Được Nghiệm Thu

| Hạng mục | Chi tiết |
|----------|---------|
| Tên hệ thống | Phần mềm quản lý tổng thể cửa hàng sửa chữa (QLDACNTT) |
| Mã dự án | LV33-001 |
| Phiên bản | v1.0 - Release |
| Công nghệ | ASP.NET Core Backend, SQL Server Database |
| Repository | https://github.com/Nguyen-Viet-Lam/QLDACNTT |
| Ngày bắt đầu | 05/09/2026 |
| Ngày hoàn thành | 23/10/2026 |
| Tổng thời gian | ~7 tuần |

---

## I.3 Danh Mục Chức Năng Được Nghiệm Thu

### A. Chức Năng Cốt Lõi

| STT | Chức năng | Kết quả | Đạt/Không đạt |
|-----|-----------|---------|---------------|
| 1 | Đăng nhập & Xác thực | Pass | Đạt |
| 2 | Phân quyền (RBAC) | Pass | Đạt |
| 3 | Quản lý khách hàng | Pass | Đạt |
| 4 | Quản lý thiết bị | Pass | Đạt |
| 5 | Phiếu sửa chữa | Pass | Đạt |
| 6 | Quản lý linh kiện / kho | Pass | Đạt |
| 7 | Hóa đơn & Thanh toán | Pass | Đạt |
| 8 | Dashboard & Báo cáo | Pass | Đạt |

### B. Chức Năng Kỹ Thuật

| STT | Chức năng | Kết quả | Đạt/Không đạt |
|-----|-----------|---------|---------------|
| 9 | Test API (Swagger) | Pass | Đạt |
| 10 | Tối ưu query SQL | Pass | Đạt |
| 11 | Backup CSDL | Pass | Đạt |
| 12 | Bảo mật OWASP | Pass | Đạt |
| 13 | Kiểm thử hiệu năng (100 users đồng thời) | Pass | Đạt |
| 14 | Kiểm thử tương thích đa trình duyệt | Pass | Đạt |

---

## I.4 Danh Mục Tài Liệu Bàn Giao

| STT | Tên tài liệu | File | Trạng thái |
|-----|-------------|------|------------|
| 1 | Hướng dẫn sử dụng - Nhân viên quầy | huong_dan_nhan_vien_quay.md | Hoàn thành |
| 2 | Hướng dẫn sử dụng - Kỹ thuật viên | huong_dan_ky_thuat_vien.md | Hoàn thành |
| 3 | Hướng dẫn quản trị hệ thống | HUONG_DAN_QUAN_TRI_HE_THONG_VA_SERVER.md | Hoàn thành |
| 4 | Báo cáo bảo mật OWASP | MBA-60_bao_mat_owasp_web_admin.md | Hoàn thành |
| 5 | Báo cáo kiểm thử tải & hiệu năng | MBA-76_BAO_CAO_KIEM_THU_TAI_VA_HIEU_NANG.md | Hoàn thành |
| 6 | Báo cáo kiểm thử tương thích | MBA-77_BAO_CAO_KIEM_THU_TUONG_THICH_DA_TRINH_DUYET.md | Hoàn thành |
| 7 | Báo cáo kiểm thử an toàn thông tin | MBA-78_BAO_CAO_KIEM_THU_AN_TOAN_THONG_TIN.md | Hoàn thành |
| 8 | Khảo sát người dùng sau triển khai | MBA-88_KHAO_SAT_DANH_GIA_NGUOI_DUNG_SAU_TRIEN_KHAI.md | Hoàn thành |
| 9 | Script CSDL đầy đủ | QLDACNTT_full_database.sql | Hoàn thành |
| 10 | Script Backup CSDL | 10_backup_csdl_truoc_golive.sql | Hoàn thành |
| 11 | Source code toàn bộ | GitHub Repository | Hoàn thành |

---

## I.5 Kết Quả Nghiệm Thu

| Hạng mục | Điểm tối đa | Điểm đạt | Tỷ lệ |
|----------|------------|---------|-------|
| Đầy đủ chức năng | 30 | 30 | 100% |
| Chất lượng mã nguồn | 20 | 18 | 90% |
| Tài liệu kỹ thuật | 20 | 19 | 95% |
| Kiểm thử và chất lượng | 20 | 19 | 95% |
| **Tổng** | **90** | **86** | **95.6%** |

**Kết luận**: HỆ THỐNG ĐẠT YÊU CẦU NGHIỆM THU

---

## I.6 Điều Kiện Bổ Sung

1. Nhóm phát triển cam kết hỗ trợ kỹ thuật trong vòng 30 ngày sau nghiệm thu.
2. Mọi lỗi phát sinh thuộc phạm vi cam kết sẽ xử lý trong thời gian < 48 giờ.
3. Source code được bàn giao đầy đủ tại GitHub repository công khai.

---

## I.7 Ký Xác Nhận Nghiệm Thu

| Vai trò | Họ và tên | Chữ ký | Ngày |
|---------|-----------|--------|------|
| Bên A - Giảng viên hướng dẫn | | | 23/10/2026 |
| Bên B - Trưởng nhóm | Nguyễn Việt Lam | | 23/10/2026 |
| Bên B - Thành viên | Trần Ngọc Lợi | | 23/10/2026 |
| Bên B - Thành viên | Nguyễn Đại Kỳ | | 23/10/2026 |

---

# PHẦN II: BIÊN BẢN THANH LÝ HỢP ĐỒNG DỊCH VỤ

## CỘNG HÒA XÃ HỘI CHỦ NGHĨA VIỆT NAM
## Độc lập - Tự do - Hạnh phúc

# BIÊN BẢN THANH LÝ HỢP ĐỒNG DỊCH VỤ

**Số biên bản**: 01/2026/BBTH-LV33-001
**Ngày lập**: 23/10/2026

---

## II.1 Căn Cứ Lập Biên Bản

- Hợp đồng giao nhiệm vụ đồ án giữa Giảng viên hướng dẫn và Nhóm 11 - Lớp 23DTHC6.
- Biên bản nghiệm thu hệ thống QLDACNTT đã ký ngày 23/10/2026.
- Kết quả thực hiện dự án và bàn giao sản phẩm của nhóm phát triển.

---

## II.2 Tổng Hợp Công Việc Đã Thực Hiện

| Sprint | Thời gian | Nội dung | Trạng thái |
|--------|-----------|---------|------------|
| Sprint 1 | Tuần 1-2 | Khởi động, thiết kế CSDL, cấu trúc backend | Hoàn thành |
| Sprint 2 | Tuần 3-4 | Xác thực, phân quyền, quản lý khách hàng | Hoàn thành |
| Sprint 3 | Tuần 5-6 | Phiếu sửa chữa, quản lý kho, hóa đơn | Hoàn thành |
| Sprint 4 | Tuần 7 | Dashboard, báo cáo, kiểm thử, tài liệu | Hoàn thành |
| Go-Live | Tuần 7-8 | Triển khai, backup, khảo sát, nghiệm thu | Hoàn thành |

---

## II.3 Tổng Hợp Jira Tasks Đã Hoàn Thành

| Mã task | Tên task | Trạng thái |
|---------|----------|------------|
| MBA-60 | Bảo mật OWASP | Done |
| MBA-63 | SP xuất kho tự động | Done |
| MBA-64 | SP hoàn trả linh kiện lỗi | Done |
| MBA-73 | Báo cáo doanh thu theo kỹ thuật viên | Done |
| MBA-76 | Báo cáo kiểm thử tải & hiệu năng | Done |
| MBA-77 | Báo cáo kiểm thử tương thích trình duyệt | Done |
| MBA-78 | Báo cáo kiểm thử an toàn thông tin | Done |
| MBA-79 | Đo lường và tối ưu hiệu năng SQL | Done |
| MBA-80 | Hướng dẫn sử dụng - Nhân viên | Done |
| MBA-81 | Hướng dẫn sử dụng - Kỹ thuật viên | Done |
| MBA-85 | Backup CSDL trước Go-Live | Done |
| MBA-88 | Khảo sát đánh giá người dùng sau triển khai | Done |
| MBA-93 | Biên bản nghiệm thu và thanh lý hợp đồng | Done |

---

## II.4 Xác Nhận Bàn Giao

1. Bên B bàn giao toàn bộ mã nguồn, tài liệu và quyền sử dụng hệ thống cho Bên A.
2. Bên A xác nhận đã tiếp nhận đầy đủ các hạng mục theo danh sách nghiệm thu.
3. Kể từ ngày ký biên bản này, nghĩa vụ các bên đã hoàn thành.
4. Quyền SHTT thuộc Nhóm 11 phục vụ mục đích học thuật.

---

## II.5 Điều Khoản Hỗ Trợ Sau Bàn Giao

| Hạng mục | Nội dung | Thời hạn |
|----------|---------|---------|
| Hỗ trợ kỹ thuật | Giải đáp thắc mắc vận hành | 30 ngày sau nghiệm thu |
| Sửa lỗi phát sinh | Xử lý bug phát hiện sau bàn giao | Trong thời hạn hỗ trợ |
| Cập nhật tài liệu | Bổ sung tài liệu nếu thiếu sót | Theo yêu cầu Bên A |

---

## II.6 Ký Xác Nhận Thanh Lý

Hai bên thống nhất thanh lý hợp đồng kể từ ngày ký. Biên bản lập thành 02 bản có giá trị ngang nhau.

| Vai trò | Họ và tên | Chữ ký | Ngày |
|---------|-----------|--------|------|
| Bên A - Giảng viên hướng dẫn | | | 23/10/2026 |
| Bên B - Trưởng nhóm | Nguyễn Việt Lam | | 23/10/2026 |
| Bên B - Thành viên | Trần Ngọc Lợi | | 23/10/2026 |
| Bên B - Thành viên | Nguyễn Đại Kỳ | | 23/10/2026 |

---
*Tài liệu thuộc MBA-93 - Nhóm 11 - Lớp 23DTHC6 - Dự án QLDACNTT (LV33-001)*
