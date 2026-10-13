@echo off
chcp 65001 >nul
title CAP NHAT TRANG THAI JIRA AUTOMATION - NHOM 11
color 0b

if "%1"=="" (
    echo =========================================================================
    echo         TOOL CAP NHAT JIRA BOARD QUA API - NHOM 11 (LV33-001)
    echo =========================================================================
    echo.
    echo Cach su dung:
    echo   1. Luu tai khoan:
    echo      cap_nhat_jira.bat config email@gmail.com api_token_o_day
    echo.
    echo   2. Chuyen task sang DONE:
    echo      cap_nhat_jira.bat done MBA-46 "Hoan thien UI Web Admin"
    echo.
    echo   3. Chuyen task sang IN PROGRESS:
    echo      cap_nhat_jira.bat in_progress MBA-40 "Dang viet API lap phieu"
    echo.
    echo   4. Xem thong tin task:
    echo      cap_nhat_jira.bat get MBA-46
    echo =========================================================================
    goto END
)

& "C:\Users\ASUS\.local\bin\uv.exe" run python "%~dp0jira_tool.py" %*

:END
