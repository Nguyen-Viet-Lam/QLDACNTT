# HƯỚNG DẪN ĐẨY CODE LÊN GITHUB DÀNH CHO TRẦN NGỌC LỢI

> **Thành viên:** Trần Ngọc Lợi  
> **Vai trò:** BA / Database Lead (Nhóm 11 - Lớp 23DTHC6)  
> **Nhiệm vụ chính:** CSDL SQL Server 13 bảng 3NF, Dữ liệu mẫu tiếng Việt, Script truy vấn báo cáo thống kê  
> **Mã công việc Jira phụ trách:** `MBA-32`, `MBA-33`, `MBA-34`, `MBA-35`  
> **Thư mục quản lý:** `database/`

---

## BƯỚC 0: CHẤP NHẬN LỜI MỜI GITHUB (BẮT BUỘC)
Trước khi đẩy code, Lợi mở Email đăng ký tài khoản GitHub của mình lên:
- Tìm email từ GitHub có tiêu đề mời vào repository `Nguyen-Viet-Lam/QLDACNTT`.
- Bấm **Accept invitation** (Chấp nhận lời mời) để có quyền đẩy code lên repo.

---

## HƯỚNG DẪN COPY - PASTE VÀO TERMINAL ANTIGRAVITY

Lợi mở dự án trong phần mềm **Antigravity**, mở cửa sổ **Terminal** (PowerShell), rồi copy lần lượt các lệnh dưới đây:

### 1. Cấu hình thông tin tài khoản GitHub của Lợi
```powershell
git config user.name "Tran Ngoc Loi"
git config user.email "dien_gmail_github_cua_loi_vao_day@gmail.com"
```
*(Lưu ý: Thay `dien_gmail_github_cua_loi_vao_day@gmail.com` bằng Gmail GitHub của Lợi)*

### 2. Cập nhật code mới nhất và tạo nhánh tính năng riêng
```powershell
git checkout develop
git pull origin develop
git checkout -b feature/MBA-34-tran-ngoc-loi
```

### 3. Ghi nhận xác nhận hoàn thành task vào database
```powershell
Add-Content -Path "database\queries\bao_cao_thong_ke.sql" -Value "`n-- Xac nhan hoan thanh task MBA-34 boi Tran Ngoc Loi (BA/DB)"
```

### 4. Thêm thư mục database và commit chuẩn mã Jira
```powershell
git add database/
git commit -m "MBA-34: Bo sung script truy van bao cao doanh thu va ton kho - Tran Ngoc Loi"
```

### 5. Đẩy nhánh riêng lên GitHub
```powershell
git push -u origin feature/MBA-34-tran-ngoc-loi
```

---

## KẾT QUẢ ĐẠT ĐƯỢC:
- Trên GitHub sẽ xuất hiện nhánh riêng: `feature/MBA-34-tran-ngoc-loi`.
- Commit hiển thị chính xác tên tác giả **Tran Ngoc Loi** với avatar GitHub của Lợi.
- Thông tin commit khớp 100% với mã task `MBA-34` trên Jira và Báo cáo Word/Excel.
