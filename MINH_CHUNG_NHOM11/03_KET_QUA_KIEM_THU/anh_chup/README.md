# DANH SÁCH ẢNH KIỂM THỬ CẦN CHỤP

- `TC_AUTH_401.png`: đăng nhập sai hoặc token thiếu.
- `TC_RBAC_403.png`: STAFF/TECHNICIAN gọi API chỉ dành cho ADMIN.
- `TC_IDOR_BEFORE.png`: hành vi trước khi vá, nếu nhóm còn môi trường/commit để tái hiện an toàn.
- `TC_IDOR_AFTER_403.png`: Request 25 trả về 403 sau khi vá.
- `TC_INVENTORY_OVERSTOCK_400.png`: xuất kho vượt số lượng tồn.
- `TC_VALIDATION_400.png`: dữ liệu đầu vào không hợp lệ.
- `UNIT_TEST_23_PASS.png`: màn hình `dotnet test` hiển thị 23/23 Passed.
- `CI_GITHUB_GREEN.png`: workflow CI/CD thành công.

Ảnh phải thấy được thời gian chạy, request hoặc lệnh, status code và phần response liên quan; che token, cookie và mật khẩu.
