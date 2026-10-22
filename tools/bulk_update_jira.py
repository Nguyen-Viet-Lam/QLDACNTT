import os
import sys
import json
from jira_tool import load_config, transition_issue, get_issue

TASKS_TO_DONE = [
    ("MBA-34", "Đã hoàn thành viết 4 Views truy vấn báo cáo thống kê SQL Server và tích hợp API"),
    ("MBA-35", "Đã hoàn thành kiểm tra toàn vẹn dữ liệu xuất nhập kho, chặn âm kho"),
    ("MBA-40", "Đã hoàn thành API lập phiếu sửa chữa và điều phối trạng thái thiết bị"),
    ("MBA-41", "Đã hoàn thành API chẩn đoán, báo giá linh kiện và phân công kỹ thuật viên"),
    ("MBA-46", "Đã hoàn thành giao diện Web Admin ZEISS TechCare, Floating Navbar bo góc và SSO nút đỏ"),
    ("MBA-47", "Đã hoàn thành kiểm thử giao diện & 10 kịch bản xuất kho linh kiện không âm"),
    ("MBA-50", "Đã hoàn thành tài liệu Kế hoạch Quản lý Rủi ro QLRR chuẩn Slide 21, 28, 30"),
    ("MBA-53", "Đã hoàn thành tài liệu Kế hoạch Quản lý Mua sắm QLMS chuẩn 5 câu hỏi Slide 7")
]

def main():
    config = load_config()
    if not config.get("api_token") or not config.get("email"):
        print("[LƯU Ý] Chưa có Jira API Token để tự động cập nhật qua API.")
        print("Vui lòng chạy lệnh sau để lưu token:")
        print("  cap_nhat_jira.bat config lamnguyenadc1@gmail.com <API_TOKEN_CUA_BAN>")
        print("\nHoặc mở trực tiếp Jira Board trên trình duyệt:")
        print("  https://lamnguyenadc1.atlassian.net/jira/software/projects/MBA/boards/2")
        print("và kéo các task sau sang cột DONE:")
        for key, desc in TASKS_TO_DONE:
            print(f"  - [{key}]: {desc}")
        sys.exit(0)

    print(f"=== ĐANG CHUYỂN CÁC TASK JIRA SANG DONE CHO {config['email']} ===")
    for key, comment in TASKS_TO_DONE:
        print(f"\n-> Đang xử lý {key}...")
        transition_issue(key, "Done", comment, config)
    print("\n[HOÀN TẤT] Đã cập nhật toàn bộ các task Jira sang DONE!")

if __name__ == "__main__":
    main()

