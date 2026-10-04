# HƯỚNG DẪN ĐẨY CODE LÊN GITHUB DÀNH CHO NGUYỄN ĐẠI KỲ

> **Thành viên:** Nguyễn Đại Kỳ  
> **Vai trò:** UI/UX Designer / QA Tester (Nhóm 11 - Lớp 23DTHC6)  
> **Nhiệm vụ chính:** Thiết kế giao diện Mockup Figma Web Admin, Kịch bản kiểm thử API HTTP Client 25 request  
> **Mã công việc Jira phụ trách:** `MBA-44`, `MBA-46`, `MBA-47`  
> **Thư mục quản lý:** `tests/`

---

## BƯỚC 0: CHẤP NHẬN LỜI MỜI GITHUB (BẮT BUỘC)
Trước khi đẩy code, Kỳ mở Email đăng ký tài khoản GitHub của mình lên:
- Tìm email từ GitHub có tiêu đề mời vào repository `Nguyen-Viet-Lam/QLDACNTT`.
- Bấm **Accept invitation** (Chấp nhận lời mời) để có quyền đẩy code lên repo.

---

## HƯỚNG DẪN COPY - PASTE VÀO TERMINAL ANTIGRAVITY

Kỳ mở dự án trong phần mềm **Antigravity**, mở cửa sổ **Terminal** (PowerShell), rồi copy lần lượt các lệnh dưới đây:

### 1. Cấu hình thông tin tài khoản GitHub của Kỳ
```powershell
git config user.name "Nguyen Dai Ky"
git config user.email "dien_gmail_github_cua_ky_vao_day@gmail.com"
```
*(Lưu ý: Thay `dien_gmail_github_cua_ky_vao_day@gmail.com` bằng Gmail GitHub của Kỳ)*

### 2. Cập nhật code mới nhất và tạo nhánh tính năng riêng
```powershell
git checkout develop
git pull origin develop
git checkout -b feature/MBA-44-nguyen-dai-ky
```

### 3. Ghi nhận xác nhận hoàn thành task vào file kiểm thử API
```powershell
Add-Content -Path "tests\QLDACNTT_Api_Tests.http" -Value "`n### Xac nhan hoan thanh task MBA-44 boi Nguyen Dai Ky (QA/UI)"
```

### 4. Thêm thư mục tests và commit chuẩn mã Jira
```powershell
git add tests/
git commit -m "MBA-44: Cap nhat kich ban kiem thu 25 request API HTTP Client - Nguyen Dai Ky"
```

### 5. Đẩy nhánh riêng lên GitHub
```powershell
git push -u origin feature/MBA-44-nguyen-dai-ky
```

---

## KẾT QUẢ ĐẠT ĐƯỢC:
- Trên GitHub sẽ xuất hiện nhánh riêng: `feature/MBA-44-nguyen-dai-ky`.
- Commit hiển thị chính xác tên tác giả **Nguyen Dai Ky** với avatar GitHub của Kỳ.
- Thông tin commit khớp 100% với mã task `MBA-44` trên Jira và Báo cáo Word/Excel.
