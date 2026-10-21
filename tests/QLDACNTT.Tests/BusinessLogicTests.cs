using QLDACNTT.Api.Models;
using Xunit;

namespace QLDACNTT.Tests;

public class BusinessLogicTests
{
    [Fact]
    public void Role_ShouldInitializeWithDefaultValues()
    {
        var role = new Role
        {
            RoleId = 1,
            RoleCode = "ADMIN",
            RoleName = "Quản trị viên"
        };

        Assert.Equal("ADMIN", role.RoleCode);
        Assert.Equal("Quản trị viên", role.RoleName);
        Assert.True(role.IsActive);
        Assert.NotNull(role.Users);
    }

    [Fact]
    public void ServiceType_ShouldHaveValidPricing()
    {
        var st = new ServiceType
        {
            ServiceTypeId = 1,
            ServiceCode = "DV001",
            ServiceName = "Sửa nguồn laptop",
            LaborCost = 250000m,
            WarrantyDays = 30
        };

        Assert.False(string.IsNullOrWhiteSpace(st.ServiceCode));
        Assert.True(st.LaborCost >= 0);
        Assert.True(st.WarrantyDays >= 0);
    }

    [Fact]
    public void SparePart_StockAndWarningThreshold_ShouldBeValid()
    {
        var part = new SparePart
        {
            PartId = 1,
            PartCode = "LK00001",
            PartName = "Màn hình OLED 15.6 inch",
            StockQuantity = 10,
            MinStockLevel = 3,
            PurchasePrice = 800000m,
            SellingPrice = 1200000m
        };

        Assert.True(part.StockQuantity >= 0);
        Assert.True(part.MinStockLevel >= 0);
        Assert.True(part.SellingPrice >= part.PurchasePrice);
    }

    [Fact]
    public void RepairTicket_CreationAndCostCalculation_ShouldBeConsistent()
    {
        var ticket = new RepairTicket
        {
            TicketId = 1,
            TicketCode = "PSC20261017-001",
            CustomerId = 1,
            DeviceId = 1,
            ServiceTypeId = 1,
            Status = "RECEIVED",
            ReceivedByUserId = 1,
            DeviceCondition = "Máy không lên nguồn",
            Diagnosis = "Hỏng tụ nguồn",
            QuotedLaborCost = 250000m,
            QuotedPartsCost = 150000m
        };

        Assert.Equal("PSC20261017-001", ticket.TicketCode);
        Assert.Equal("RECEIVED", ticket.Status);
        Assert.Equal(250000m, ticket.QuotedLaborCost);
        Assert.Equal(150000m, ticket.QuotedPartsCost);
    }
}
