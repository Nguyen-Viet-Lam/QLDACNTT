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
            return Results.Ok(rows);
        });

        app.MapGet("/api/reports/revenue-by-service", async (HttpRequest request, AppDbContext db, SessionStore store) =>
        {
            var auth = AuthHelper.RequireRole(request, store, "ADMIN", "STAFF");
            if (auth is not null) return auth;

            var rows = await QueryAsync(db, "SELECT * FROM dbo.v_BaoCaoDoanhThuTheoDichVu ORDER BY TongDoanhThuDichVu DESC");
            return Results.Ok(rows);
        });

        app.MapGet("/api/reports/top-selling-parts", async (HttpRequest request, int? top, AppDbContext db, SessionStore store) =>
        {
            var auth = AuthHelper.RequireRole(request, store, "ADMIN", "STAFF");
            if (auth is not null) return auth;

            var topN = top is > 0 ? top.Value : 10;
            var rows = await QueryAsync(db,
                $"SELECT TOP ({topN}) * FROM dbo.v_LinhKienBanChay WHERE TongSoLuongBan > 0 ORDER BY TongSoLuongBan DESC");
            return Results.Ok(rows);
        });

        app.MapGet("/api/reports/slow-moving-parts", async (HttpRequest request, int? minDays, AppDbContext db, SessionStore store) =>
        {
            var auth = AuthHelper.RequireRole(request, store, "ADMIN", "STAFF");
            if (auth is not null) return auth;

            var threshold = minDays is > 0 ? minDays.Value : 30;
            var rows = await QueryAsync(db,
                $"SELECT * FROM dbo.v_LinhKienTonLau WHERE SoNgayKhongCoGiaoDich >= {threshold} ORDER BY SoNgayKhongCoGiaoDich DESC");
            return Results.Ok(rows);
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
