using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using QLDACNTT.Api.Data;
using QLDACNTT.Api.Infrastructure;

namespace QLDACNTT.Api.Endpoints;

/// <summary>
/// API báo cáo thống kê, đọc trực tiếp từ các VIEW đã có trong database
/// (database/queries/05_bao_cao_doanh_thu_theo_tho_va_dich_vu.sql,
///  database/queries/08_bao_cao_linh_kien_ban_chay_va_ton_lau.sql).
/// </summary>
public static class ReportEndpoints
{
    public static void MapReportEndpoints(this WebApplication app)
    {
        app.MapGet("/api/reports/revenue-by-technician", async (HttpRequest request, AppDbContext db, SessionStore store) =>
        {
            var auth = AuthHelper.RequireRole(request, store, "ADMIN", "STAFF");
            if (auth is not null) return auth;

            var rows = await QueryAsync(db, "SELECT * FROM dbo.v_BaoCaoDoanhThuTheoTho ORDER BY TongDoanhThuThucThu DESC");
            var result = rows.Select(r => new
            {
                technicianId = r.GetValueOrDefault("MaTho"),
                technicianName = r.GetValueOrDefault("TenKyThuatVien")?.ToString() ?? r.GetValueOrDefault("TenDangNhap")?.ToString() ?? "Kỹ thuật viên",
                technicianUsername = r.GetValueOrDefault("TenDangNhap")?.ToString() ?? "",
                phone = r.GetValueOrDefault("SoDienThoai")?.ToString() ?? "",
                totalTicketsAssigned = Convert.ToInt32(r.GetValueOrDefault("TongSoPhieuGiao") ?? 0),
                completedTicketsCount = Convert.ToInt32(r.GetValueOrDefault("SoPhieuHoanTat") ?? 0),
                cancelledTicketsCount = Convert.ToInt32(r.GetValueOrDefault("SoPhieuHuy") ?? 0),
                paidInvoicesCount = Convert.ToInt32(r.GetValueOrDefault("SoHoaDonDaThuTien") ?? 0),
                totalLaborRevenue = Convert.ToDecimal(r.GetValueOrDefault("DoanhThuTienCong") ?? 0),
                totalPartsRevenue = Convert.ToDecimal(r.GetValueOrDefault("DoanhThuLinhKien") ?? 0),
                totalDiscount = Convert.ToDecimal(r.GetValueOrDefault("TongTienGiamGia") ?? 0),
                totalRevenue = Convert.ToDecimal(r.GetValueOrDefault("TongDoanhThuThucThu") ?? 0),
                avgRevenuePerTicket = Convert.ToDecimal(r.GetValueOrDefault("DoanhThuTrungBinhMoiPhieu") ?? 0),
                completionRate = Convert.ToDecimal(r.GetValueOrDefault("TyLeHoanThanhPhanTram") ?? 0),
                avgProcessingHours = Convert.ToDecimal(r.GetValueOrDefault("ThoiGianXuLyTrungBinhGio") ?? 0),
                reWarrantyCount = Convert.ToInt32(r.GetValueOrDefault("SoPhieuBaoHanhLai") ?? 0),
                // Vietnamese keys preserved
                MaTho = r.GetValueOrDefault("MaTho"),
                TenKyThuatVien = r.GetValueOrDefault("TenKyThuatVien"),
                TenDangNhap = r.GetValueOrDefault("TenDangNhap"),
                SoPhieuHoanTat = r.GetValueOrDefault("SoPhieuHoanTat"),
                DoanhThuTienCong = r.GetValueOrDefault("DoanhThuTienCong"),
                TongDoanhThuThucThu = r.GetValueOrDefault("TongDoanhThuThucThu")
            });
            return Results.Ok(result);
        });

        app.MapGet("/api/reports/revenue-by-service", async (HttpRequest request, AppDbContext db, SessionStore store) =>
        {
            var auth = AuthHelper.RequireRole(request, store, "ADMIN", "STAFF");
            if (auth is not null) return auth;

            var rows = await QueryAsync(db, "SELECT * FROM dbo.v_BaoCaoDoanhThuTheoDichVu ORDER BY TongDoanhThuDichVu DESC");
            var result = rows.Select(r => new
            {
                serviceId = r.GetValueOrDefault("MaDichVu"),
                serviceCode = r.GetValueOrDefault("MaCodeDichVu")?.ToString() ?? "",
                serviceName = r.GetValueOrDefault("TenLoaiDichVu")?.ToString() ?? "Dịch vụ",
                laborCost = Convert.ToDecimal(r.GetValueOrDefault("DonGiaCongNiemYet") ?? 0),
                warrantyDays = Convert.ToInt32(r.GetValueOrDefault("HanBaoHanhMacDinh") ?? 0),
                ticketsCount = Convert.ToInt32(r.GetValueOrDefault("TongSoPhieuYeuCau") ?? r.GetValueOrDefault("SoPhieuHoanThanh") ?? 0),
                completedCount = Convert.ToInt32(r.GetValueOrDefault("SoPhieuHoanThanh") ?? 0),
                totalLaborRevenue = Convert.ToDecimal(r.GetValueOrDefault("DoanhThuTienCong") ?? 0),
                totalPartsRevenue = Convert.ToDecimal(r.GetValueOrDefault("DoanhThuLinhKien") ?? 0),
                totalRevenue = Convert.ToDecimal(r.GetValueOrDefault("TongDoanhThuDichVu") ?? 0),
                contributionPercent = Convert.ToDecimal(r.GetValueOrDefault("TyTrongDongGopPhanTram") ?? 0),
                // Vietnamese keys preserved
                MaCodeDichVu = r.GetValueOrDefault("MaCodeDichVu"),
                TenLoaiDichVu = r.GetValueOrDefault("TenLoaiDichVu"),
                TongSoPhieuYeuCau = r.GetValueOrDefault("TongSoPhieuYeuCau"),
                TongDoanhThuDichVu = r.GetValueOrDefault("TongDoanhThuDichVu")
            });
            return Results.Ok(result);
        });

        app.MapGet("/api/reports/top-selling-parts", async (HttpRequest request, int? top, AppDbContext db, SessionStore store) =>
        {
            var auth = AuthHelper.RequireRole(request, store, "ADMIN", "STAFF");
            if (auth is not null) return auth;

            var topN = top is > 0 ? top.Value : 10;
            var rows = await QueryAsync(db,
                $"SELECT TOP ({topN}) * FROM dbo.v_LinhKienBanChay WHERE TongSoLuongBan > 0 ORDER BY TongSoLuongBan DESC");
            var result = rows.Select(r => new
            {
                partId = r.GetValueOrDefault("PartId"),
                partCode = r.GetValueOrDefault("MaLinhKien")?.ToString() ?? "",
                partName = r.GetValueOrDefault("TenLinhKien")?.ToString() ?? "",
                categoryName = r.GetValueOrDefault("NhomLinhKien")?.ToString() ?? "",
                currentStock = Convert.ToInt32(r.GetValueOrDefault("TonHienTai") ?? 0),
                minStock = Convert.ToInt32(r.GetValueOrDefault("TonToiThieu") ?? 0),
                totalSoldQuantity = Convert.ToInt32(r.GetValueOrDefault("TongSoLuongBan") ?? 0),
                totalSalesAmount = Convert.ToDecimal(r.GetValueOrDefault("DoanhThuThucTe") ?? 0),
                grossProfit = Convert.ToDecimal(r.GetValueOrDefault("LoiNhuanGop") ?? 0),
                revenueSharePercent = Convert.ToDecimal(r.GetValueOrDefault("TyTrongDoanhThuPhanTram") ?? 0),
                unit = "Cái",
                // Vietnamese keys preserved
                MaLinhKien = r.GetValueOrDefault("MaLinhKien"),
                TenLinhKien = r.GetValueOrDefault("TenLinhKien"),
                TongSoLuongBan = r.GetValueOrDefault("TongSoLuongBan"),
                DoanhThuThucTe = r.GetValueOrDefault("DoanhThuThucTe")
            });
            return Results.Ok(result);
        });

        app.MapGet("/api/reports/slow-moving-parts", async (HttpRequest request, int? minDays, AppDbContext db, SessionStore store) =>
        {
            var auth = AuthHelper.RequireRole(request, store, "ADMIN", "STAFF");
            if (auth is not null) return auth;

            var threshold = minDays is > 0 ? minDays.Value : 30;
            var rows = await QueryAsync(db,
                $"SELECT * FROM dbo.v_LinhKienTonLau WHERE SoNgayKhongCoGiaoDich >= {threshold} ORDER BY SoNgayKhongCoGiaoDich DESC");
            var result = rows.Select(r => new
            {
                partCode = r.GetValueOrDefault("MaLinhKien")?.ToString() ?? "",
                partName = r.GetValueOrDefault("TenLinhKien")?.ToString() ?? "",
                categoryName = r.GetValueOrDefault("NhomLinhKien")?.ToString() ?? "",
                currentStock = Convert.ToInt32(r.GetValueOrDefault("TonKhoHienTai") ?? 0),
                minStock = Convert.ToInt32(r.GetValueOrDefault("TonToiThieu") ?? 0),
                sellingPrice = Convert.ToDecimal(r.GetValueOrDefault("GiaBan") ?? 0),
                purchasePrice = Convert.ToDecimal(r.GetValueOrDefault("GiaNhap") ?? 0),
                lockedCapital = Convert.ToDecimal(r.GetValueOrDefault("GiaTriTonKho") ?? 0),
                inactiveDays = Convert.ToInt32(r.GetValueOrDefault("SoNgayKhongCoGiaoDich") ?? 0),
                unit = "Cái",
                level = r.GetValueOrDefault("MucDo")?.ToString() ?? "",
                recommendation = r.GetValueOrDefault("DeXuat")?.ToString() ?? "",
                // Vietnamese keys preserved
                MaLinhKien = r.GetValueOrDefault("MaLinhKien"),
                TenLinhKien = r.GetValueOrDefault("TenLinhKien"),
                TonKhoHienTai = r.GetValueOrDefault("TonKhoHienTai"),
                GiaTriTonKho = r.GetValueOrDefault("GiaTriTonKho")
            });
            return Results.Ok(result);
        });
    }

    private static async Task<List<Dictionary<string, object?>>> QueryAsync(AppDbContext db, string sql)
    {
        var results = new List<Dictionary<string, object?>>();
        var connection = db.Database.GetDbConnection();
        var shouldClose = connection.State != System.Data.ConnectionState.Open;
        if (shouldClose)
        {
            await connection.OpenAsync();
        }

        try
        {
            using var command = connection.CreateCommand();
            command.CommandText = sql;
            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                var row = new Dictionary<string, object?>();
                for (var i = 0; i < reader.FieldCount; i++)
                {
                    var value = reader.GetValue(i);
                    row[reader.GetName(i)] = value is DBNull ? null : value;
                }
                results.Add(row);
            }
        }
        finally
        {
            if (shouldClose)
            {
                await connection.CloseAsync();
            }
        }

        return results;
    }
}
