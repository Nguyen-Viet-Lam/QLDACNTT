using Microsoft.EntityFrameworkCore;
using QLDACNTT.Api.Models;

namespace QLDACNTT.Api.Data;

/// <summary>
/// Nạp dữ liệu thực tế cho cửa hàng sửa chữa điện thoại, máy tính ZEISS TECHCARE (LV33-001)
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
        SeedServicesAndParts(db);
        SeedTicketsAndWarranty(db);
        db.SaveChanges();
    }

    private static void SeedRoles(AppDbContext db)
    {
        if (db.Roles.Any())
        {
            var rAdmin = db.Roles.FirstOrDefault(x => x.RoleCode == "ADMIN");
            if (rAdmin != null) { rAdmin.RoleName = "Quản trị viên"; rAdmin.Description = "Chủ cửa hàng / Quản lý hệ thống, toàn quyền quản trị"; }
            var rStaff = db.Roles.FirstOrDefault(x => x.RoleCode == "STAFF");
            if (rStaff != null) { rStaff.RoleName = "Nhân viên quầy"; rStaff.Description = "Tiếp nhận thiết bị, lập phiếu tiếp nhận, thu ngân hóa đơn"; }
            var rTech = db.Roles.FirstOrDefault(x => x.RoleCode == "TECHNICIAN");
            if (rTech != null) { rTech.RoleName = "Kỹ thuật viên"; rTech.Description = "Chẩn đoán, sửa chữa phần cứng/phần mềm, xuất kho linh kiện"; }
            var rCust = db.Roles.FirstOrDefault(x => x.RoleCode == "CUSTOMER");
            if (rCust != null) { rCust.RoleName = "Khách hàng"; rCust.Description = "Tra cứu tiến độ sửa chữa máy và sổ bảo hành điện tử"; }
            return;
        }

        db.Roles.AddRange(
            new Role { RoleCode = "ADMIN", RoleName = "Quản trị viên", Description = "Chủ cửa hàng / Quản lý hệ thống, toàn quyền quản trị" },
            new Role { RoleCode = "STAFF", RoleName = "Nhân viên quầy", Description = "Tiếp nhận thiết bị, lập phiếu tiếp nhận, thu ngân hóa đơn" },
            new Role { RoleCode = "TECHNICIAN", RoleName = "Kỹ thuật viên", Description = "Chẩn đoán, sửa chữa phần cứng/phần mềm, xuất kho linh kiện" },
            new Role { RoleCode = "CUSTOMER", RoleName = "Khách hàng", Description = "Tra cứu tiến độ sửa chữa máy và sổ bảo hành điện tử" });
        db.SaveChanges();
    }

    private static void SeedUsers(AppDbContext db)
    {
        var adminRoleId = db.Roles.First(x => x.RoleCode == "ADMIN").RoleId;
        var staffRoleId = db.Roles.First(x => x.RoleCode == "STAFF").RoleId;
        var techRoleId = db.Roles.First(x => x.RoleCode == "TECHNICIAN").RoleId;
        var customerRoleId = db.Roles.First(x => x.RoleCode == "CUSTOMER").RoleId;

        EnsureUser(db, "admin", adminRoleId, "Nguyễn Viết Lãm (Admin / Quản lý)", "admin@repairshop.local", "0900000001");
        EnsureUser(db, "staff01", staffRoleId, "Trần Ngọc Lợi (Trưởng nhóm lễ tân & CSKH)", "staff01@repairshop.local", "0900000002");
        EnsureUser(db, "tech01", techRoleId, "Phạm Văn Kỹ Thuật (Chuyên viên Laptop & PC)", "tech01@repairshop.local", "0900000003");
        EnsureUser(db, "tech02", techRoleId, "Nguyễn Đại Kỳ (Chuyên viên Mobile & Apple)", "tech02@repairshop.local", "0900000004");

        EnsureUser(db, "khach01", customerRoleId, "Nguyễn Thành Nam (Khách hàng VIP)", "nam.nguyen@gmail.com", "0982345678");
        EnsureUser(db, "khach02", customerRoleId, "Lê Hoàng Phúc (Khách hàng)", "phuc.le@outlook.com", "0903124567");
        EnsureUser(db, "khach03", customerRoleId, "Đặng Minh Tâm (Khách hàng)", "tam.dang@fpt.edu.vn", "0918765432");
        EnsureUser(db, "customer", customerRoleId, "Khách hàng Demo (Trải nghiệm Portal)", "customer@example.com", "0901000003");

        foreach (var user in db.Users)
        {
            if (string.IsNullOrEmpty(user.PasswordHash) || !user.PasswordHash.StartsWith("$2"))
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
                new Customer { CustomerCode = "KH000001", FullName = "Nguyễn Thành Nam", Phone = "0982345678", Email = "nam.nguyen@gmail.com", Address = "142 Võ Văn Tần, Phường 6, Quận 3, TP.HCM", Note = "Khách hàng VIP doanh nghiệp" },
                new Customer { CustomerCode = "KH000002", FullName = "Lê Hoàng Phúc", Phone = "0903124567", Email = "phuc.le@outlook.com", Address = "475A Điện Biên Phủ, Phường 25, Bình Thạnh, TP.HCM", Note = "Giảng viên ĐH HUTECH" },
                new Customer { CustomerCode = "KH000003", FullName = "Đặng Minh Tâm", Phone = "0918765432", Email = "tam.dang@fpt.edu.vn", Address = "280 An Dương Vương, Phường 4, Quận 5, TP.HCM", Note = "Lập trình viên Senior" },
                new Customer { CustomerCode = "KH000004", FullName = "Võ Hoài Thương", Phone = "0976543210", Email = "thuong.vo@gmail.com", Address = "120 Hai Bà Trưng, Phường Đa Kao, Quận 1, TP.HCM", Note = "Thiết kế đồ họa Studio" },
                new Customer { CustomerCode = "KH000005", FullName = "Phan Thanh Tùng", Phone = "0938889900", Email = "tung.phan@techcorp.vn", Address = "68 Nguyễn Huệ, Phường Bến Nghé, Quận 1, TP.HCM", Note = "Khách sửa máy tính PC gaming" });
            db.SaveChanges();
        }

        var kh1 = db.Customers.FirstOrDefault(x => x.CustomerCode == "KH000001");
        var kh2 = db.Customers.FirstOrDefault(x => x.CustomerCode == "KH000002");
        var kh3 = db.Customers.FirstOrDefault(x => x.CustomerCode == "KH000003");

        var uKh1 = db.Users.FirstOrDefault(x => x.Username == "khach01");
        if (uKh1 != null && kh1 != null) uKh1.CustomerId = kh1.CustomerId;

        var uKh2 = db.Users.FirstOrDefault(x => x.Username == "khach02");
        if (uKh2 != null && kh2 != null) uKh2.CustomerId = kh2.CustomerId;

        var uKh3 = db.Users.FirstOrDefault(x => x.Username == "khach03");
        if (uKh3 != null && kh3 != null) uKh3.CustomerId = kh3.CustomerId;

        var uCust = db.Users.FirstOrDefault(x => x.Username == "customer");
        if (uCust != null && kh1 != null) uCust.CustomerId = kh1.CustomerId;

        if (!db.Devices.Any() && kh1 != null && kh2 != null && kh3 != null)
        {
            db.Devices.AddRange(
                new Device { DeviceCode = "TB000001", CustomerId = kh1.CustomerId, DeviceType = "Laptop", Brand = "Dell", Model = "XPS 15 9520 (Core i7-12700H / 32GB / 1TB SSD)", SerialNumber = "DLXPS-9520-VN01", Note = "Máy đồ họa cao cấp" },
                new Device { DeviceCode = "TB000002", CustomerId = kh2.CustomerId, DeviceType = "Điện thoại", Brand = "Apple", Model = "iPhone 14 Pro Max 256GB Deep Purple", SerialNumber = "F2LX90A4MD6R", Note = "Máy chính hãng VNA" },
                new Device { DeviceCode = "TB000003", CustomerId = kh3.CustomerId, DeviceType = "Laptop", Brand = "Apple", Model = "MacBook Pro 14 M2 Pro 2023 Space Gray", SerialNumber = "C02G90ABMD6T", Note = "Máy lập trình di động" });
            db.SaveChanges();
        }
    }

    private static void SeedServicesAndParts(AppDbContext db)
    {
        if (!db.ServiceTypes.Any())
        {
            db.ServiceTypes.AddRange(
                new ServiceType { ServiceCode = "DV001", ServiceName = "Thay màn hình điện thoại OLED / Super Retina", LaborCost = 150000, WarrantyDays = 90, Description = "Tháo ráp, ép ron chống nước, chuyển IC giữ True Tone" },
                new ServiceType { ServiceCode = "DV002", ServiceName = "Thay pin chính hãng điện thoại / máy tính bảng", LaborCost = 100000, WarrantyDays = 180, Description = "Thay pin dung lượng cao, dán keo seal chuyên dụng" },
                new ServiceType { ServiceCode = "DV003", ServiceName = "Vệ sinh tra keo tản nhiệt gốm máy tính & laptop", LaborCost = 150000, WarrantyDays = 30, Description = "Vệ sinh quạt kép, tra keo gốm Thermal Grizzly Kryonaut" },
                new ServiceType { ServiceCode = "DV004", ServiceName = "Cài đặt hệ điều hành Windows 11 / macOS & phần mềm", LaborCost = 100000, WarrantyDays = 30, Description = "Cài đặt OS chuẩn UEFI/GPT, driver đầy đủ và Office" },
                new ServiceType { ServiceCode = "DV005", ServiceName = "Sửa chữa phần cứng mainboard, IC nguồn, reball chip", LaborCost = 450000, WarrantyDays = 90, Description = "Đo đạc boardview, dò chạm chập bằng camera nhiệt FLIR" });
            db.SaveChanges();
        }

        if (!db.SparePartCategories.Any())
        {
            db.SparePartCategories.AddRange(
                new SparePartCategory { CategoryName = "Màn hình Smartphone & Laptop", Description = "Màn hình Super Retina XDR, Dynamic AMOLED 2X, LCD IPS 144Hz" },
                new SparePartCategory { CategoryName = "Pin & Bộ sạc công suất cao", Description = "Pin Pisen chính hãng, Pin zin máy, Pin Dell/Apple cao cấp" },
                new SparePartCategory { CategoryName = "Ổ cứng SSD NVMe & RAM", Description = "SSD Samsung 980 PRO, Kingston NV2, RAM Crucial DDR5, Kingston DDR4" },
                new SparePartCategory { CategoryName = "Keo tản nhiệt & Vật tư bảo dưỡng", Description = "Keo gốm Thermal Grizzly, dung dịch tẩy keo Arctic Clean, ron chống nước" });
            db.SaveChanges();
        }
    }

    private static void SeedTicketsAndWarranty(AppDbContext db)
    {
        if (db.RepairTickets.Any())
        {
            return;
        }

        var staff = db.Users.FirstOrDefault(x => x.Username == "staff01");
        var tech = db.Users.FirstOrDefault(x => x.Username == "tech01");
        var kh1 = db.Customers.FirstOrDefault(x => x.CustomerCode == "KH000001");
        var tb1 = db.Devices.FirstOrDefault(x => x.DeviceCode == "TB000001");
        var dv3 = db.ServiceTypes.FirstOrDefault(x => x.ServiceCode == "DV003");

        if (staff == null || tech == null || kh1 == null || tb1 == null || dv3 == null) return;

        var ticket1 = new RepairTicket
        {
            TicketCode = "PSC202610001",
            CustomerId = kh1.CustomerId,
            DeviceId = tb1.DeviceId,
            ServiceTypeId = dv3.ServiceTypeId,
            ReceivedByUserId = staff.UserId,
            TechnicianUserId = tech.UserId,
            Status = "COMPLETED",
            DeviceCondition = "Máy chạy khoảng 15 phút quạt kêu to rú rít, nhiệt độ đo CPU 98°C, tự sập nguồn khi render video Premiere.",
            CustomerRequest = "Khách yêu cầu vệ sinh toàn bộ máy và thay loại keo tản nhiệt tốt nhất.",
            Diagnosis = "Keo tản nhiệt gốc đã bị khô cứng chai cứng, cụm lá nhôm tản nhiệt nghẹt xơ bụi. Đã vệ sinh quạt kép, tẩy keo cũ và tra keo Thermal Grizzly Kryonaut. Stress test Cinebench R23 nhiệt độ ổn định ở 72°C.",
            QuotedLaborCost = 150000,
            QuotedPartsCost = 180000
        };

        db.RepairTickets.Add(ticket1);
        db.SaveChanges();
    }
}
