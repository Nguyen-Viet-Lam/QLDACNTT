using Microsoft.EntityFrameworkCore;
using QLDACNTT.Api.Models;

namespace QLDACNTT.Api.Data;

public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options)
    {
    }

    public DbSet<Role> Roles => Set<Role>();
    public DbSet<User> Users => Set<User>();
    public DbSet<Customer> Customers => Set<Customer>();
    public DbSet<Device> Devices => Set<Device>();
    public DbSet<ServiceType> ServiceTypes => Set<ServiceType>();
    public DbSet<RepairTicket> RepairTickets => Set<RepairTicket>();
    public DbSet<TicketStatusHistory> TicketStatusHistories => Set<TicketStatusHistory>();
    public DbSet<SparePartCategory> SparePartCategories => Set<SparePartCategory>();
    public DbSet<SparePart> SpareParts => Set<SparePart>();
    public DbSet<StockTransaction> StockTransactions => Set<StockTransaction>();
    public DbSet<Invoice> Invoices => Set<Invoice>();
    public DbSet<Payment> Payments => Set<Payment>();
    public DbSet<Warranty> Warranties => Set<Warranty>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Role>(e =>
        {
            e.ToTable("Roles");
            e.HasKey(x => x.RoleId);
            e.HasIndex(x => x.RoleCode).IsUnique();
        });

        modelBuilder.Entity<User>(e =>
        {
            e.ToTable("Users");
            e.HasKey(x => x.UserId);
            e.HasIndex(x => x.Username).IsUnique();
            e.HasOne(x => x.Role).WithMany(r => r.Users).HasForeignKey(x => x.RoleId);
            e.HasOne(x => x.Customer).WithMany().HasForeignKey(x => x.CustomerId);
        });

        modelBuilder.Entity<Customer>(e =>
        {
            e.ToTable("Customers");
            e.HasKey(x => x.CustomerId);
            e.HasIndex(x => x.CustomerCode).IsUnique();
        });

        modelBuilder.Entity<Device>(e =>
        {
            e.ToTable("Devices");
            e.HasKey(x => x.DeviceId);
            e.HasIndex(x => x.DeviceCode).IsUnique();
            e.HasOne(x => x.Customer).WithMany(c => c.Devices).HasForeignKey(x => x.CustomerId);
        });

        modelBuilder.Entity<ServiceType>(e =>
        {
            e.ToTable("ServiceTypes");
            e.HasKey(x => x.ServiceTypeId);
            e.HasIndex(x => x.ServiceCode).IsUnique();
            e.Property(x => x.LaborCost).HasColumnType("decimal(18,2)");
        });

        modelBuilder.Entity<RepairTicket>(e =>
        {
            e.ToTable("RepairTickets");
            e.HasKey(x => x.TicketId);
            e.HasIndex(x => x.TicketCode).IsUnique();
            e.Property(x => x.QuotedLaborCost).HasColumnType("decimal(18,2)");
            e.Property(x => x.QuotedPartsCost).HasColumnType("decimal(18,2)");
            e.HasOne(x => x.Customer).WithMany().HasForeignKey(x => x.CustomerId).OnDelete(DeleteBehavior.NoAction);
            e.HasOne(x => x.Device).WithMany().HasForeignKey(x => x.DeviceId).OnDelete(DeleteBehavior.NoAction);
            e.HasOne(x => x.ServiceType).WithMany().HasForeignKey(x => x.ServiceTypeId).OnDelete(DeleteBehavior.NoAction);
            e.HasOne(x => x.ReceivedByUser).WithMany().HasForeignKey(x => x.ReceivedByUserId).OnDelete(DeleteBehavior.NoAction);
            e.HasOne(x => x.TechnicianUser).WithMany().HasForeignKey(x => x.TechnicianUserId).OnDelete(DeleteBehavior.NoAction);
        });

        modelBuilder.Entity<TicketStatusHistory>(e =>
        {
            e.ToTable("TicketStatusHistory");
            e.HasKey(x => x.HistoryId);
            e.HasOne(x => x.Ticket).WithMany().HasForeignKey(x => x.TicketId).OnDelete(DeleteBehavior.NoAction);
            e.HasOne(x => x.ChangedByUser).WithMany().HasForeignKey(x => x.ChangedByUserId).OnDelete(DeleteBehavior.NoAction);
        });

        modelBuilder.Entity<SparePartCategory>(e =>
        {
            e.ToTable("SparePartCategories");
            e.HasKey(x => x.CategoryId);
        });

        modelBuilder.Entity<SparePart>(e =>
        {
            e.ToTable("SpareParts");
            e.HasKey(x => x.PartId);
            e.HasIndex(x => x.PartCode).IsUnique();
            e.Property(x => x.PurchasePrice).HasColumnType("decimal(18,2)");
            e.Property(x => x.SellingPrice).HasColumnType("decimal(18,2)");
            e.HasOne(x => x.Category).WithMany(c => c.SpareParts).HasForeignKey(x => x.CategoryId);
        });

        modelBuilder.Entity<StockTransaction>(e =>
        {
            e.ToTable("StockTransactions");
            e.HasKey(x => x.TransactionId);
            e.Property(x => x.UnitPrice).HasColumnType("decimal(18,2)");
            e.HasOne(x => x.Part).WithMany().HasForeignKey(x => x.PartId).OnDelete(DeleteBehavior.NoAction);
            e.HasOne(x => x.Ticket).WithMany().HasForeignKey(x => x.TicketId).OnDelete(DeleteBehavior.NoAction);
            e.HasOne(x => x.PerformedByUser).WithMany().HasForeignKey(x => x.PerformedByUserId).OnDelete(DeleteBehavior.NoAction);
        });

        modelBuilder.Entity<Invoice>(e =>
        {
            e.ToTable("Invoices");
            e.HasKey(x => x.InvoiceId);
            e.HasIndex(x => x.InvoiceCode).IsUnique();
            e.HasIndex(x => x.TicketId).IsUnique();
            e.Property(x => x.LaborCost).HasColumnType("decimal(18,2)");
            e.Property(x => x.PartsCost).HasColumnType("decimal(18,2)");
            e.Property(x => x.DiscountAmount).HasColumnType("decimal(18,2)");
            e.Property(x => x.TotalAmount)
                .HasColumnType("decimal(18,2)")
                .HasComputedColumnSql("([LaborCost]+[PartsCost]-[DiscountAmount])", stored: true);
            e.HasOne(x => x.Ticket).WithMany().HasForeignKey(x => x.TicketId).OnDelete(DeleteBehavior.NoAction);
            e.HasOne(x => x.Customer).WithMany().HasForeignKey(x => x.CustomerId).OnDelete(DeleteBehavior.NoAction);
        });

        modelBuilder.Entity<Payment>(e =>
        {
            e.ToTable("Payments");
            e.HasKey(x => x.PaymentId);
            e.Property(x => x.Amount).HasColumnType("decimal(18,2)");
            e.HasOne(x => x.Invoice).WithMany().HasForeignKey(x => x.InvoiceId).OnDelete(DeleteBehavior.NoAction);
            e.HasOne(x => x.ReceivedByUser).WithMany().HasForeignKey(x => x.ReceivedByUserId).OnDelete(DeleteBehavior.NoAction);
        });

        modelBuilder.Entity<Warranty>(e =>
        {
            e.ToTable("Warranties");
            e.HasKey(x => x.WarrantyId);
            e.HasIndex(x => x.WarrantyCode).IsUnique();
            e.HasOne(x => x.Ticket).WithMany().HasForeignKey(x => x.TicketId).OnDelete(DeleteBehavior.NoAction);
            e.HasOne(x => x.Customer).WithMany().HasForeignKey(x => x.CustomerId).OnDelete(DeleteBehavior.NoAction);
            e.HasOne(x => x.Device).WithMany().HasForeignKey(x => x.DeviceId).OnDelete(DeleteBehavior.NoAction);
        });
    }
}
