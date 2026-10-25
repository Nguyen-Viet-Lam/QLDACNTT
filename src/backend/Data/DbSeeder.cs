using QLDACNTT.Api.Models;

namespace QLDACNTT.Api.Data;

/// <summary>
/// Đảm bảo có đủ dữ liệu demo để chạy ngay sau khi migrate (role, user admin/staff/tech/customer
/// với mật khẩu hash thật, khách hàng/thiết bị/phiếu mẫu để demo tính năng).
/// Mật khẩu mặc định cho mọi tài khoản demo: Abc@12345
/// </summary>
public static class DbSeeder
{
    private const string DefaultDemoPassword = "Abc@12345";

    public static void Seed(AppDbContext db)
    {
        SeedRoles(db);
        SeedUsers(db);
        SeedCustomersAndDevices(db);
        SeedTicketsAndWarranty(db);
        db.SaveChanges();
    }

    private static void SeedRoles(AppDbContext db)
    {
        if (db.Roles.Any())
        {
            return;
        }

        db.Roles.AddRange(
            new Role { RoleCode = "ADMIN", RoleName = "Quản trị viên", Description = "Chủ cửa hàng / quản lý, toàn quyền hệ thống" },
            new Role { RoleCode = "STAFF", RoleName = "Nhân viên", Description = "Tiếp nhận thiết bị, lập phiếu, thu tiền" },
            new Role { RoleCode = "TECHNICIAN", RoleName = "Kỹ thuật viên", Description = "Chẩn đoán, sửa chữa, xuất linh kiện" },
            new Role { RoleCode = "CUSTOMER", RoleName = "Khách hàng", Description = "Tra cứu tiến độ và bảo hành" });
        db.SaveChanges();
    }

    private static void SeedUsers(AppDbContext db)
    {
        var adminRoleId = db.Roles.First(x => x.RoleCode == "ADMIN").RoleId;
        var staffRoleId = db.Roles.First(x => x.RoleCode == "STAFF").RoleId;
        var techRoleId = db.Roles.First(x => x.RoleCode == "TECHNICIAN").RoleId;
        var customerRoleId = db.Roles.First(x => x.RoleCode == "CUSTOMER").RoleId;

        EnsureUser(db, "admin", adminRoleId, "Nguyễn Viết Lãm (Admin/PM)", "admin@repairshop.local", "0900000001");
        EnsureUser(db, "staff01", staffRoleId, "Lê Thị Tiếp Nhận", "staff01@repairshop.local", "0900000002");
        EnsureUser(db, "tech01", techRoleId, "Phạm Văn Kỹ Thuật", "tech01@repairshop.local", "0900000003");
        EnsureUser(db, "tech02", techRoleId, "Võ Minh Kỹ Thuật", "tech02@repairshop.local", "0900000004");
        EnsureUser(db, "khach01", customerRoleId, "Nguyễn Văn An (Khách hàng)", "khach01@example.com", "0901000001");
        EnsureUser(db, "khach02", customerRoleId, "Trần Thị Bình (Khách hàng)", "khach02@example.com", "0901000002");

        EnsureUser(db, "loi.staff", staffRoleId, "Trần Ngọc Lợi (Lễ tân / BA)", "loi@repairshop.local", "0900000005");
        EnsureUser(db, "ky.tech", techRoleId, "Nguyễn Đại Kỳ (Kỹ thuật / QA)", "ky@repairshop.local", "0900000006");
        EnsureUser(db, "customer", customerRoleId, "Khách hàng Demo", "customer@example.com", "0901000003");

        // Hoàn thiện bảo mật: chuẩn hóa hash BCrypt cho toàn bộ tài khoản
        foreach (var user in db.Users)
        {
            if (user.PasswordHash == "SEED_REPLACE_ME" || !user.PasswordHash.StartsWith("$2"))
            {
                user.PasswordHash = BCrypt.Net.BCrypt.HashPassword(DefaultDemoPassword);
            }
        }

        db.SaveChanges();
    }

    private static void EnsureUser(AppDbContext db, string username, int roleId, string fullName, string email, string phone)
    {
        var existing = db.Users.FirstOrDefault(x => x.Username == username);
        if (existing is not null)
        {
            existing.FullName = fullName;
            existing.RoleId = roleId;
            if (string.IsNullOrWhiteSpace(existing.Email)) existing.Email = email;
            if (string.IsNullOrWhiteSpace(existing.Phone)) existing.Phone = phone;
            return;
        }

        db.Users.Add(new User
        {
            Username = username,
            PasswordHash = BCrypt.Net.BCrypt.HashPassword(DefaultDemoPassword),
            FullName = fullName,
            RoleId = roleId,
            Email = email,
            Phone = phone,
            IsActive = true
        });
    }

    private static void SeedCustomersAndDevices(AppDbContext db)
    {
        if (!db.Customers.Any())
        {
            db.Customers.AddRange(
                new Customer { CustomerCode = "KH000001", FullName = "Nguyễn Văn An", Phone = "0901000001", Email = "khach01@example.com", Address = "Quận 1, TP.HCM" },
                new Customer { CustomerCode = "KH000002", FullName = "Trần Thị Bình", Phone = "0901000002", Email = "khach02@example.com", Address = "Quận 3, TP.HCM" });
            db.SaveChanges();
        }

        // Lien ket tai khoan khach hang voi ban ghi Customer (de tra IDOR dung CustomerId thuc,
        // khong hard-code "KH000001" nhu ban dang-nhap cu).
        var khach01 = db.Users.First(x => x.Username == "khach01");
        var khach02 = db.Users.First(x => x.Username == "khach02");
        var kh1 = db.Customers.First(x => x.CustomerCode == "KH000001");
        var kh2 = db.Customers.First(x => x.CustomerCode == "KH000002");
        khach01.CustomerId ??= kh1.CustomerId;
        khach02.CustomerId ??= kh2.CustomerId;

        if (!db.Devices.Any())
        {
            db.Devices.AddRange(
                new Device { DeviceCode = "TB000001", CustomerId = kh1.CustomerId, DeviceType = "Laptop", Brand = "Dell", Model = "Inspiron 15", SerialNumber = "DL-2026-001" },
                new Device { DeviceCode = "TB000002", CustomerId = kh2.CustomerId, DeviceType = "Điện thoại", Brand = "Apple", Model = "iPhone 12", SerialNumber = "IP12-2026-002" });
            db.SaveChanges();
        }
    }

    private static void SeedTicketsAndWarranty(AppDbContext db)
    {
        if (db.RepairTickets.Any())
        {
            return;
        }

        var staff = db.Users.First(x => x.Username == "staff01");
        var tech = db.Users.First(x => x.Username == "tech01");
        var kh1 = db.Customers.First(x => x.CustomerCode == "KH000001");
        var kh2 = db.Customers.First(x => x.CustomerCode == "KH000002");
        var tb1 = db.Devices.First(x => x.DeviceCode == "TB000001");
        var tb2 = db.Devices.First(x => x.DeviceCode == "TB000002");
        var dv2 = db.ServiceTypes.FirstOrDefault(x => x.ServiceCode == "DV002");
        var dv3 = db.ServiceTypes.FirstOrDefault(x => x.ServiceCode == "DV003");

        var ticket1 = new RepairTicket
        {
            TicketCode = "PSC202610001",
            CustomerId = kh1.CustomerId,
            DeviceId = tb1.DeviceId,
            ServiceTypeId = dv3?.ServiceTypeId,
            ReceivedByUserId = staff.UserId,
            Status = "RECEIVED",
            DeviceCondition = "May nong, tu tat",
            QuotedLaborCost = dv3?.LaborCost ?? 120000
        };

        var ticket2 = new RepairTicket
        {
            TicketCode = "PSC202610002",
            CustomerId = kh2.CustomerId,
            DeviceId = tb2.DeviceId,
            ServiceTypeId = dv2?.ServiceTypeId,
            ReceivedByUserId = staff.UserId,
            TechnicianUserId = tech.UserId,
            Status = "DIAGNOSING",
            DeviceCondition = "Pin chai nhanh",
            Diagnosis = "Can thay pin moi",
            QuotedLaborCost = dv2?.LaborCost ?? 100000
        };

        db.RepairTickets.AddRange(ticket1, ticket2);
        db.SaveChanges();

        db.TicketStatusHistories.AddRange(
            new TicketStatusHistory { TicketId = ticket1.TicketId, FromStatus = null, ToStatus = "RECEIVED", ChangedByUserId = staff.UserId, Note = "Tiep nhan may tu khach hang" },
            new TicketStatusHistory { TicketId = ticket2.TicketId, FromStatus = "RECEIVED", ToStatus = "DIAGNOSING", ChangedByUserId = staff.UserId, Note = "Phan cong KTV tech01 chan doan" });

        db.SaveChanges();
    }
}
