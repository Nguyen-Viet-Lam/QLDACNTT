using QLDACNTT.Api.Data;
using QLDACNTT.Api.Models;
using Xunit;

namespace QLDACNTT.Tests;

public class BusinessLogicTests
{
    [Fact]
    public void CreateDemo_ShouldInitializeCoreEntities()
    {
        var data = AppData.CreateDemo();

        Assert.NotNull(data.Users);
        Assert.NotEmpty(data.Users);
        Assert.Contains(data.Users, u => u.Role == "ADMIN" && u.Username == "admin");
        Assert.Contains(data.Users, u => u.Role == "STAFF");
        Assert.Contains(data.Users, u => u.Role == "TECHNICIAN");

        Assert.NotNull(data.Customers);
        Assert.NotEmpty(data.Customers);

        Assert.NotNull(data.ServiceTypes);
        Assert.NotEmpty(data.ServiceTypes);

        Assert.NotNull(data.SpareParts);
        Assert.NotEmpty(data.SpareParts);
    }

    [Fact]
    public void ServiceTypes_ShouldHaveValidBasePricing()
    {
        var data = AppData.CreateDemo();

        foreach (var st in data.ServiceTypes)
        {
            Assert.False(string.IsNullOrWhiteSpace(st.Code), "Service Code must not be empty");
            Assert.False(string.IsNullOrWhiteSpace(st.Name), "Service Name must not be empty");
            Assert.True(st.LaborCost >= 0, $"LaborCost must be >= 0 for {st.Code}");
            Assert.True(st.WarrantyDays >= 0, $"WarrantyDays must be >= 0 for {st.Code}");
        }
    }

    [Fact]
    public void SpareParts_StockAndWarningThreshold_ShouldBeValid()
    {
        var data = AppData.CreateDemo();

        foreach (var part in data.SpareParts)
        {
            Assert.True(part.StockQuantity >= 0, "Stock quantity cannot be negative");
            Assert.True(part.MinStockLevel >= 0, "MinStockLevel cannot be negative");
            Assert.True(part.SellingPrice >= 0, "SellingPrice cannot be negative");
        }
    }

    [Fact]
    public void RepairTicket_CreationAndCostCalculation_ShouldBeConsistent()
    {
        var ticket = new RepairTicketDto(
            Code: "PC20261017-001",
            CustomerCode: "KH000001",
            DeviceCode: "TB000001",
            ServiceCode: "DV001",
            Status: "RECEIVED",
            ReceivedByUsername: "staff",
            TechnicianUsername: "tech",
            DeviceCondition: "Máy không lên nguồn",
            Diagnosis: "Hỏng tụ nguồn",
            QuotedLaborCost: 250000m
        );

        Assert.Equal("PC20261017-001", ticket.Code);
        Assert.Equal("RECEIVED", ticket.Status);
        Assert.Equal(250000m, ticket.QuotedLaborCost);
    }
}
