# BÁO CÁO KẾT QUẢ KIỂM THỬ E2E XUẤT KHO & THANH TOÁN (TASK MBA-72)
**Học phần:** Quản lý Dự án Công nghệ Thông tin (QLDACNTT) — Nhóm 11  
**Mã đề tài:** LV33-001 | Hệ thống quản lý tổng thể cho cửa hàng sửa chữa  
**Thời gian thực thi máy sinh:** 2026-10-21T09:55:30.057Z  
**Kịch bản nguồn:** `tests/test_scenario_inventory_stock_out.http`  
**Người phụ trách:** Nguyễn Đại Kỳ (QA Tester Lead)  

---

## 1. TỔNG QUAN LUỒNG E2E

| STT | Bước nghiệp vụ | Endpoint & Method | Mã HTTP | Kết quả | Ý nghĩa kiểm thử |
|:---:|---|---|:---:|:---:|---|
| **01** | KTV đăng nhập | `POST /api/auth/login` | **200** | ✅ Pass | Lấy token phiên kỹ thuật viên |
| **02** | Rà soát linh kiện sắp hết | `GET /api/inventory/low-stock` | **200** | ✅ Pass | Cảnh báo tồn dưới mức tối thiểu |
| **03** | Xuất kho linh kiện theo phiếu | `POST /api/inventory/transactions` | **201** | ✅ Pass | Xuất 1 LK00001 cho phiếu PSC2026090001 |
| **04** | Kiểm thử chặn xuất vượt tồn | `POST /api/inventory/transactions` | **400** | ✅ Pass | Cố tình xuất 999 cái -> Hệ thống chặn đúng 400 |
| **05** | Lễ tân đăng nhập | `POST /api/auth/login` | **200** | ✅ Pass | Lấy token phiên lễ tân quầy |
| **06** | Tính toán tổng chi phí phiếu | `GET /api/tickets/PSC2026090001/cost` | **200** | ✅ Pass | Tự động cộng tiền công + tiền linh kiện xuất |
| **07** | Lập hóa đơn thanh toán | `POST /api/invoices` | **201** | ✅ Pass | Sinh hóa đơn HD2026100001, áp voucher giảm 50k |
| **08** | Khách thanh toán VietQR | `POST /api/invoices/HD2026100001/pay` | **200** | ✅ Pass | Ghi nhận tiền về 1.600.000đ |
| **09** | Kích hoạt bảo hành điện tử | `GET /api/warranties/search?serial=...` | **200** | ✅ Pass | Tự động kích hoạt thời hạn bảo hành theo serial |
| **10** | Trạng thái phiếu sang PAID | `GET /api/tickets/PSC2026090001` | **200** | ✅ Pass | Phiếu sửa chữa tự động chuyển trạng thái `PAID` |

---

## 2. CHI TIẾT CA CHẶN XUẤT KHO VƯỢT TỒN (TEST 04)
- **Request Body gửi lên:**
```json
{
  "partCode": "LK00005",
  "transactionType": "OUT",
  "quantity": 999,
  "ticketCode": "PSC2026090001",
  "note": "Co tinh xuat vuot qua so luong ton de test bat loi"
}
```
- **Response thực tế (HTTP 400 Bad Request):**
```json
""
```
*Kết luận:* Hệ thống kiểm soát tính toàn vẹn kho hàng chuẩn xác, không cho phép âm kho.
