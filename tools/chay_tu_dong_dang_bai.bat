@echo off
chcp 65001 >nul
title Hệ thống Tự Động Hóa Đăng Bài Facebook & Zalo - Cowork Claude
echo ================================================================
echo    HỆ THỐNG TỰ ĐỘNG HÓA ĐĂNG BÀI FACEBOOK & ZALO - COWORK
echo    Tác giả: Nguyễn Viết Lãm (lamnguyenadc@gmail.com)
echo    Jira: lamnguyenadc1@gmail.com
echo ================================================================
echo.
echo 1. Xem danh sách & trạng thái bài đăng (--status)
echo 2. Chạy thử nghiệm giả lập bài tiếp theo (--dry-run)
echo 3. Đăng bài tiếp theo và tự động cập nhật Excel (--next)
echo 4. Đăng tất cả bài chưa đăng (--all)
echo.
set /p choice="Nhập lựa chọn của bạn (1-4, Enter để thoát): "

if "%choice%"=="1" (
    node tools/auto_publish_social.mjs --status
) else if "%choice%"=="2" (
    node tools/auto_publish_social.mjs --dry-run
) else if "%choice%"=="3" (
    node tools/auto_publish_social.mjs --next
) else if "%choice%"=="4" (
    node tools/auto_publish_social.mjs --all
) else (
    echo Thoát chương trình.
)
echo.
pause

