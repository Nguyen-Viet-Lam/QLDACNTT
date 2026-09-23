using System.Collections.Concurrent;
using QLDACNTT.Api.Models;

namespace QLDACNTT.Api.Data;

public sealed class AppData
{
    public required List<UserAccount> Users { get; init; }

    public required ConcurrentDictionary<string, UserSession> Sessions { get; init; }

    public required List<CustomerDto> Customers { get; init; }

    public required List<DeviceDto> Devices { get; init; }

    public required List<ServiceTypeDto> ServiceTypes { get; init; }

    public required List<SparePartDto> SpareParts { get; init; }

    public required List<RepairTicketDto> Tickets { get; init; }

    public static AppData CreateDemo()
    {
        return new AppData
        {
            Users =
            [
                new(1, "admin", "123456", "Nguyen Viet Lam", "ADMIN", true),
                new(2, "staff", "123456", "Nhan vien tiep nhan", "STAFF", true),
                new(3, "tech", "123456", "Ky thuat vien", "TECHNICIAN", true),
                new(4, "customer", "123456", "Khach hang demo", "CUSTOMER", true)
            ],
            Sessions = new ConcurrentDictionary<string, UserSession>(),
            Customers =
            [
                new("KH000001", "Nguyen Van An", "0901000001", "an.demo@example.com", "Quan 1, TP.HCM"),
                new("KH000002", "Tran Thi Binh", "0901000002", "binh.demo@example.com", "Quan 3, TP.HCM")
            ],
            Devices =
            [
                new("TB000001", "KH000001", "Laptop", "Dell", "Inspiron 15", "DL-2026-001"),
                new("TB000002", "KH000002", "Dien thoai", "Apple", "iPhone 12", "IP12-2026-002")
            ],
            ServiceTypes =
            [
                new("DV001", "Thay man hinh dien thoai", 150000, 90),
                new("DV002", "Thay pin dien thoai", 100000, 180),
                new("DV003", "Ve sinh laptop, tra keo tan nhiet", 120000, 30),
                new("DV004", "Cai dat lai he dieu hanh", 80000, 15)
            ],
            SpareParts =
            [
                new("LK00001", "Man hinh iPhone 11", 12, 3, 1200000),
                new("LK00002", "Pin iPhone 11", 20, 5, 450000),
                new("LK00003", "SSD 512GB NVMe", 10, 3, 1150000),
                new("LK00004", "Keo tan nhiet MX-4", 22, 6, 100000)
            ],
            Tickets =
            [
                new("PSC2026090001", "KH000001", "TB000001", "DV003", "RECEIVED", "staff", null, "May nong, tu tat", null, 120000),
                new("PSC2026090002", "KH000002", "TB000002", "DV002", "DIAGNOSING", "staff", "tech", "Pin chai nhanh", "Can thay pin moi", 100000)
            ]
        };
    }
}
