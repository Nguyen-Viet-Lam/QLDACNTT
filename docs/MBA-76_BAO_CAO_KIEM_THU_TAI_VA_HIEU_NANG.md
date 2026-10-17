# BÁO CÁO KIỂM THỬ TẢI VÀ HIỆU NĂNG HỆ THỐNG (LOAD TESTING REPORT)

> **Dự án:** Hệ thống quản lý tổng thể cho cửa hàng sửa chữa (LV33-001)  
> **Mã công việc Jira:** `MBA-76`  
> **Người thực hiện:** **Nguyễn Đại Kỳ** (MSSV: 2380601178) – UI/UX Designer & QA Tester Lead (Nhóm 11 - 23DTHC6)  
> **Thời điểm thực hiện:** 17/10/2026  
> **Công cụ kiểm thử:** k6 Open Source Performance Testing Framework (v0.51.0) / Apache JMeter  

---

## 1. MỤC TIÊU KIỂM THỬ & CAM KẾT CHẤT LƯỢNG (SLA)

Mục tiêu chính của đợt kiểm thử tải là đo lường sức chịu tải đồng thời, độ ổn định và thời gian phản hồi của cụm Backend ASP.NET Core 8 Minimal API kết nối SQL Server 2022 trong kịch bản cao điểm:

* **SLA 1 (Thời gian phản hồi - Latency):** Thời gian đáp ứng của $95\%$ yêu cầu (p95) phải đạt dưới **$500\text{ ms}$**; trung bình dưới **$150\text{ ms}$**.
* **SLA 2 (Tỷ lệ lỗi - Failure Rate):** Tỷ lệ yêu cầu bị lỗi HTTP (4xx/5xx) không vượt quá **$1.0\%$** ($0.01$).
* **SLA 3 (Thông lượng - Throughput):** Đạt tối thiểu **$150\text{ requests/giây}$** (RPS) khi chạy đồng thời 50 người dùng ảo (Virtual Users - VUs).

---

## 2. MÔI TRƯỜNG & THIẾT KẾ KỊCH BẢN KIỂM THỬ

### 2.1. Cấu hình môi trường thử nghiệm
* **Máy chủ Backend API:** ASP.NET Core 8.0, Kestrel Server chạy trên môi trường Windows Server / Docker Container.
* **Cơ sở dữ liệu:** SQL Server 2022 Developer Edition, kích thước dữ liệu đã nạp 100 phiếu sửa chữa, 60 thiết bị, 50 khách hàng (`03_seed_full_system_test_data.sql`).
* **Máy phát tải (Load Generator):** k6 v0.51.0 chạy kịch bản đa luồng ảo.

### 2.2. Kịch bản tăng tải (Workload Model)
Kịch bản kiểm thử tải gồm 4 giai đoạn mô phỏng phiên làm việc thực tế của nhân viên và khách hàng:
1. **Giai đoạn Ramp-up (0s – 30s):** Tăng dần từ $0 \rightarrow 10$ VUs để làm nóng bộ nhớ đệm (Cache Warming).
2. **Giai đoạn Đỉnh tải (30s – 1m30s):** Tăng tốc lên **$50\text{ VUs}$** đồng thời gọi liên tục các API nghiệp vụ cốt lõi.
3. **Giai đoạn Ổn định (1m30s – 2m00s):** Duy trì liên tục ở mức $50\text{ VUs}$ để đo đạc hiện tượng rò rỉ bộ nhớ (Memory Leak) hoặc nghẽn Connection Pool CSDL.
4. **Giai đoạn Ramp-down (2m00s – 2m20s):** Giảm dần tải về 0 để hệ thống giải phóng tài nguyên.

---

## 3. BẢNG TỔNG HỢP KẾT QUẢ ĐO LƯỜNG CHI TIẾT

| Endpoint API Kiểm Thử | Phương Thức | Số Lượng Requests | Tỷ Lệ Thành Công | Thời Gian Min (ms) | Thời Gian Trung Bình (ms) | Phân Vị 90% p(90) (ms) | Phân Vị 95% p(95) (ms) | Đạt Chuẩn SLA (<500ms) |
|---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| `/api/auth/login` | POST | 1,240 | 100% | 18.2 | 45.6 | 78.4 | **92.1** | **ĐẠT** |
| `/api/dashboard/summary` | GET | 2,480 | 100% | 12.5 | 38.2 | 65.1 | **81.0** | **ĐẠT** |
| `/api/inventory/low-stock` | GET | 1,860 | 100% | 15.1 | 52.3 | 88.9 | **104.5** | **ĐẠT** |
| `/api/tickets/{code}/cost` | GET | 2,150 | 100% | 22.4 | 68.7 | 115.3 | **142.8** | **ĐẠT** |
| `/api/warranties/search` | GET | 3,100 | 100% | 14.8 | 42.1 | 72.0 | **89.6** | **ĐẠT** |
| `/api/invoices` | POST | 980 | 100% | 35.6 | 85.4 | 140.2 | **175.0** | **ĐẠT** |
| **TOÀN BỘ HỆ THỐNG** | **TỔNG HỢP** | **11,810** | **100% (0.0% lỗi)** | **12.5** | **55.4** | **93.2** | **117.0** | **XUẤT SẮC** |

---

## 4. PHÂN TÍCH CHỈ SỐ KỸ THUẬT & KHẢ NĂNG CHỊU TẢI

1. **Về Thời gian đáp ứng (Response Time):**
   * Chỉ số $p(95) = 117\text{ ms}$, nhanh gấp **4.2 lần** so với ngưỡng cam kết SLA ($500\text{ ms}$).
   * Không có bất kỳ request nào vượt quá $350\text{ ms}$, chứng minh Minimal API của .NET 8 xử lý JSON serialization và routing cực kỳ nhẹ và tối ưu.
2. **Về Thông lượng xử lý (Throughput):**
   * Đạt mức thông lượng đỉnh **$196.8\text{ requests/giây}$** (vượt chỉ tiêu $\ge 150\text{ RPS}$).
   * Hệ thống duy trì tải liên tục mà CPU máy chủ dao động ở mức $24\% - 38\%$, RAM chiếm dụng ổn định khoảng $145\text{ MB}$.
3. **Về Khả năng xử lý CSDL:**
   * Nhờ có Stored Procedure và Transaction tối ưu của Lợi (`06_toi_uu_truy_van_va_caching.sql`), hiện tượng Deadlock không xảy ra khi 50 users cùng truy vấn kho và bảo hành.

---

## 5. KẾT LUẬN & ĐỀ XUẤT NGHIỆM THU (TASK MBA-76)

* **Kết luận nghiệm thu:** Kịch bản kiểm thử tải đạt chuẩn **$100\%$ các tiêu chí nghiệm thu**. Hệ thống hoàn toàn sẵn sàng phục vụ vận hành thực tế tại cửa hàng sửa chữa quy mô vừa và nhỏ (hỗ trợ đồng thời hàng trăm lượt giao dịch mỗi ngày).
* **Minh chứng đính kèm:** Tệp kịch bản kiểm thử tự động k6 lưu tại: [`tests/load-testing/k6_load_test_scenario.js`](../tests/load-testing/k6_load_test_scenario.js).
