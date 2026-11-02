/* Don dep du lieu do bo test API/pentest tao ra (chay sau tests/run_http_tests.mjs).
   Xoa cac ban ghi moi (id lon hon moc co so) va hoan nguyen cac ban ghi bi bo test sua.
   Chay: sqlcmd -S . -E -C -I -d RepairShopDB -i tests/cleanup_test_data.sql */
SET XACT_ABORT ON;
BEGIN TRAN;
DELETE FROM TicketStatusHistory WHERE HistoryId > 82;
DELETE FROM TicketParts WHERE TicketPartId > 13;
DELETE FROM Warranties WHERE WarrantyId > 16;
DELETE FROM Payments WHERE PaymentId > 14;
DELETE FROM StockTransactions WHERE TransactionId > 21;
DELETE FROM Invoices WHERE InvoiceId > 18;
DELETE FROM RepairTickets WHERE TicketId > 68;
DELETE FROM Devices WHERE DeviceId > 51;
DELETE FROM Customers WHERE CustomerId > 48;
UPDATE Invoices SET PaymentStatus='UNPAID', PaidAt=NULL WHERE InvoiceCode='HD2026100011';
UPDATE RepairTickets SET UpdatedAt=NULL WHERE TicketCode='PSC202610015';
UPDATE RepairTickets SET Status='RECEIVED', TechnicianUserId=NULL, UpdatedAt=NULL WHERE TicketCode='PSC202610006';
UPDATE SpareParts SET StockQuantity=6, UpdatedAt=NULL WHERE PartCode='LK00001';
UPDATE SpareParts SET StockQuantity=29, UpdatedAt=NULL WHERE PartCode='LK00016'; -- bo test E2E (tools/test_full_system_features.mjs) xuat kho LK00016
UPDATE Users SET IsActive=1 WHERE IsActive=0;       -- bo test E2E khoa/kich hoat lai tai khoan
COMMIT;
PRINT 'Da don dep du lieu thu.';
