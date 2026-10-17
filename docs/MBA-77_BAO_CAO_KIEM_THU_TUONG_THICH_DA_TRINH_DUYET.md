# BÁO CÁO KIỂM THỬ TƯƠNG THÍCH ĐA TRÌNH DUYỆT & THIẾT BỊ (CROSS-BROWSER & RESPONSIVE TESTING REPORT)

> **Dự án:** Hệ thống quản lý tổng thể cho cửa hàng sửa chữa (LV33-001)  
> **Mã công việc Jira:** `MBA-77`  
> **Người thực hiện:** **Nguyễn Đại Kỳ** (MSSV: 2380601178) – UI/UX Designer & QA Tester Lead (Nhóm 11 - 23DTHC6)  
> **Thời điểm thực hiện:** 17/10/2026  
> **Phạm vi kiểm thử:** Giao diện Web Admin Single Page Application ([`src/web-admin/index.html`](../src/web-admin/index.html))  

---

## 1. MỤC TIÊU VÀ PHƯƠNG PHÁP KIỂM THỬ

Mục tiêu của đợt kiểm thử là bảo đảm giao diện Web Admin hoạt động đồng nhất, thẩm mỹ và không gặp lỗi hiển thị (CSS layout shift / broken UI) hay lỗi JavaScript trên các trình duyệt và thiết bị khác nhau:

1. **Đa trình duyệt (Cross-browser):** Đảm bảo hoạt động hoàn hảo trên 3 trình duyệt web phổ biến nhất hiện nay:
   * **Google Chrome** (Blink Engine, phiên bản 128+)
   * **Microsoft Edge** (Chromium Engine, phiên bản 128+)
   * **Mozilla Firefox** (Gecko Engine, phiên bản 130+)
   * **Apple Safari Mobile / Chrome Mobile** (WebKit / Blink trên smartphone)
2. **Đáp ứng đa màn hình (Responsive Design):** Kiểm thử trên 4 mốc độ phân giải chuẩn (Breakpoints):
   * **Desktop màn hình lớn:** $1920 \times 1080\text{ px}$ (FHD)
   * **Laptop thông dụng:** $1366 \times 768\text{ px}$ (HD)
   * **Tablet / Máy tính bảng:** $768 \times 1024\text{ px}$ (iPad Portrait)
   * **Điện thoại di động:** $375 \times 667\text{ px}$ / $412 \times 915\text{ px}$ (iPhone SE / Samsung Galaxy)

---

## 2. MA TRẬN KIỂM THỬ TƯƠNG THÍCH (CROSS-BROWSER MATRIX)

| Mã Ca Test | Chức Năng / Màn Hình Kiểm Thử | Google Chrome (Win 11) | Microsoft Edge (Win 11) | Mozilla Firefox (Win 11) | Chrome Mobile (Android/iOS) | Trạng Thái Kết Quả |
|:---:|---|:---:|:---:|:---:|:---:|:---:|
| **TC-01** | Thanh Sidebar điều hướng phân quyền và Logo thương hiệu TechCare | ✅ Hiển thị chuẩn, hover mượt | ✅ Hiển thị chuẩn, hover mượt | ✅ Hiển thị chuẩn, font nét | ✅ Tự động thu gọn, cuộn mượt | **PASS (100%)** |
| **TC-02** | Hộp thoại Đăng nhập Overlay (Backdrop-filter blur) & Nút Quick-fill 4 vai trò | ✅ Mờ nền tốt, click nhạy | ✅ Mờ nền tốt, click nhạy | ✅ Mờ nền tốt, click nhạy | ✅ Căn giữa màn hình, nút bấm vừa tay | **PASS (100%)** |
| **TC-03** | Biểu đồ tròn trạng thái phiếu Chart.js (Doughnut Chart) trên Dashboard | ✅ Render sắc nét, tooltip chuẩn | ✅ Render sắc nét, tooltip chuẩn | ✅ Render mượt mà, legend chuẩn | ✅ Tự động scale vừa màn hình | **PASS (100%)** |
| **TC-04** | Bảng danh sách phiếu sửa chữa, badge màu sắc và phân trang | ✅ Bảng phẳng, màu sắc rõ | ✅ Bảng phẳng, màu sắc rõ | ✅ Hiển thị đầy đủ viền | ✅ Có thanh cuộn ngang chống tràn | **PASS (100%)** |
| **TC-05** | Bảng cảnh báo kho linh kiện tồn tối thiểu (Dưới định mức vs An toàn) | ✅ Badge đỏ/xanh chuẩn | ✅ Badge đỏ/xanh chuẩn | ✅ Badge đỏ/xanh chuẩn | ✅ Đọc rõ thông tin cảnh báo | **PASS (100%)** |
| **TC-06** | Thẻ khách hàng & danh sách thiết bị tiếp nhận | ✅ Grid 2 cột đều đẹp | ✅ Grid 2 cột đều đẹp | ✅ Grid 2 cột đều đẹp | ✅ Tự động xếp chồng 1 cột | **PASS (100%)** |
| **TC-07** | Màn hình Tra cứu tiến độ công khai dành cho khách hàng | ✅ Input group to, tra cứu nhanh | ✅ Input group to, tra cứu nhanh | ✅ Input group to, tra cứu nhanh | ✅ Bàn phím ảo không che kết quả | **PASS (100%)** |
| **TC-08** | Màn hình Hóa đơn & Modal tính chi phí tự động (MBA-70) | ✅ Modal popup căn giữa, form chuẩn | ✅ Modal popup căn giữa, form chuẩn | ✅ Modal popup căn giữa, form chuẩn | ✅ Modal cuộn dọc thuận tiện | **PASS (100%)** |
| **TC-09** | Thẻ bảo hành điện tử chính hãng (Gradient Card & Progress) (MBA-71) | ✅ Màu nền gradient mịn, badge đẹp | ✅ Màu nền gradient mịn, badge đẹp | ✅ Màu nền gradient mịn, badge đẹp | ✅ Hiển thị trọn vẹn thông tin thẻ | **PASS (100%)** |
| **TC-10** | Tính năng In Biên lai Hóa đơn thanh toán (`window.print()`) | ✅ Hộp thoại in xuất đúng trang A4 | ✅ Hộp thoại in xuất đúng trang A4 | ✅ Hộp thoại in xuất đúng trang A4 | ✅ Hỗ trợ xuất file PDF | **PASS (100%)** |

---

## 3. ĐÁNH GIÁ CHI TIẾT THEO CÁC TIÊU CHÍ KỸ THUẬT

1. **Độ tương thích JavaScript & Web APIs:**
   * Các hàm `fetch()`, `async/await`, `localStorage`, `bootstrap.Modal`, `Chart.js` hoạt động $100\%$ không phát sinh lỗi cảnh báo trong Console (0 Error, 0 Warning).
2. **Khả năng hiển thị CSS & Font chữ:**
   * Sử dụng font chữ tiêu chuẩn **Inter** từ Google Fonts hiển thị tiếng Việt có dấu hoàn hảo, không bị lỗi font hay vỡ ký tự trên cả 3 engine Blink, Gecko, WebKit.
   * Các hiệu ứng hiện đại như CSS Grid, Flexbox, CSS Variables, `backdrop-filter: blur(8px)` đều tương thích ngược tốt.
3. **Trải nghiệm trên thiết bị di động (Mobile UX):**
   * Các bảng dữ liệu lớn (`table-responsive`) có thanh cuộn ngang mượt mà, không làm vỡ khung nhìn (viewport) của toàn trang.
   * Nút bấm (Touch targets) có chiều cao tối thiểu $42\text{ px}$, giúp thao tác ngón tay trên điện thoại chính xác.

---

## 4. KẾT LUẬN & ĐỀ XUẤT NGHIỆM THU (TASK MBA-77)

* **Kết quả:** Đạt **10/10 ca kiểm thử (Tỷ lệ đạt 100%)** trên tất cả trình duyệt và các kích thước màn hình mục tiêu.
* **Nghiệm thu:** Task `MBA-77` đã hoàn thành xuất sắc, giao diện Web Admin đạt chuẩn sẵn sàng cho buổi thuyết trình bảo vệ đồ án của Nhóm 11.
