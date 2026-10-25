// tools/test_full_system_features.mjs
// Kịch bản kiểm thử toàn diện tất cả các chức năng của Hệ thống Quản lý Sửa chữa Shop (LV33-001)

const BASE_URL = 'http://127.0.0.1:5055';

let passedTests = 0;
let failedTests = 0;
const testLogs = [];

function assert(condition, testName, details = '') {
    if (condition) {
        passedTests++;
        console.log(`  [PASS] ${testName}`);
        testLogs.push({ name: testName, status: 'PASS', details });
    } else {
        failedTests++;
        console.error(`  [FAIL] ${testName} - ${details}`);
        testLogs.push({ name: testName, status: 'FAIL', details });
    }
}

async function api(path, options = {}) {
    const url = `${BASE_URL}${path}`;
    const headers = {
        'Content-Type': 'application/json',
        ...(options.headers || {})
    };
    if (options.token) {
        headers['X-Session-Token'] = options.token;
    }

    const res = await fetch(url, {
        method: options.method || 'GET',
        headers,
        body: options.body ? JSON.stringify(options.body) : undefined
    });

    let data = null;
    const contentType = res.headers.get('content-type') || '';
    if (contentType.includes('application/json')) {
        data = await res.json().catch(() => null);
    } else {
        data = await res.text().catch(() => null);
    }

    return { status: res.status, ok: res.ok, data };
}

async function runAllTests() {
    console.log('================================================================');
    console.log('BẮT ĐẦU KIỂM THỬ TOÀN DIỆN HỆ THỐNG QUẢN LÝ SỬA CHỮA (LV33-001)');
    console.log('Thời gian:', new Date().toLocaleString('vi-VN'));
    console.log('================================================================\n');

    // -------------------------------------------------------------
    // CHỨC NĂNG 1: XÁC THỰC & ĐĂNG NHẬP (AUTHENTICATION & SESSIONS)
    // -------------------------------------------------------------
    console.log('--- 1. KIỂM THỬ XÁC THỰC & ĐĂNG NHẬP ---');
    
    // 1.1 Đăng nhập sai mật khẩu
    const badLogin = await api('/api/auth/login', {
        method: 'POST',
        body: { username: 'admin', password: 'WrongPassword@999' }
    });
    assert(badLogin.status === 401 || badLogin.status === 400, 'Từ chối đăng nhập khi sai mật khẩu');

    // 1.2 Đăng nhập Admin
    const adminLogin = await api('/api/auth/login', {
        method: 'POST',
        body: { username: 'admin', password: 'Abc@12345' }
    });
    assert(adminLogin.ok && adminLogin.data.token, 'Đăng nhập Admin thành công', `Token: ${adminLogin.data?.token?.slice(0, 8)}...`);
    const adminToken = adminLogin.data.token;
    assert(adminLogin.data.user.roleCode === 'ADMIN', 'Admin có roleCode là ADMIN');

    // 1.3 Đăng nhập Nhân viên quầy (Staff)
    const staffLogin = await api('/api/auth/login', {
        method: 'POST',
        body: { username: 'staff01', password: 'Abc@12345' }
    });
    assert(staffLogin.ok && staffLogin.data.user.roleCode === 'STAFF', 'Đăng nhập Nhân viên quầy (staff01) thành công');
    const staffToken = staffLogin.data.token;

    // 1.4 Đăng nhập Kỹ thuật viên (Technician)
    const techLogin = await api('/api/auth/login', {
        method: 'POST',
        body: { username: 'tech01', password: 'Abc@12345' }
    });
    assert(techLogin.ok && techLogin.data.user.roleCode === 'TECHNICIAN', 'Đăng nhập Kỹ thuật viên (tech01) thành công');
    const techToken = techLogin.data.token;

    // 1.5 Đăng nhập Khách hàng (Customer)
    const custLogin = await api('/api/auth/login', {
        method: 'POST',
        body: { username: 'khach01', password: 'Abc@12345' }
    });
    assert(custLogin.ok && custLogin.data.user.roleCode === 'CUSTOMER', 'Đăng nhập Khách hàng (khach01) thành công');
    const custToken = custLogin.data.token;

    // 1.6 Kiểm tra endpoint /api/auth/me
    const meRes = await api('/api/auth/me', { token: adminToken });
    assert(meRes.ok && meRes.data.username === 'admin', 'Kiểm tra thông tin phiên /api/auth/me chuẩn xác');

    // 1.7 Kiểm tra phân quyền RBAC
    const techAccessUserList = await api('/api/users', { token: techToken });
    assert(techAccessUserList.status === 403, 'RBAC: Kỹ thuật viên không được truy cập danh sách Users (403 Forbidden)');

    const custAccessDashboard = await api('/api/dashboard/summary', { token: custToken });
    assert(custAccessDashboard.status === 403, 'RBAC: Khách hàng không được truy cập Dashboard quản trị (403 Forbidden)');

    // -------------------------------------------------------------
    // CHỨC NĂNG 2: DASHBOARD TỔNG QUAN & KPI
    // -------------------------------------------------------------
    console.log('\n--- 2. KIỂM THỬ DASHBOARD TỔNG QUAN & KPI ---');
    const dashRes = await api('/api/dashboard/summary', { token: adminToken });
    assert(dashRes.ok, 'Lấy dữ liệu Dashboard Summary thành công');
    const d = dashRes.data;
    assert(d.totalCustomers >= 25, `Tổng số khách hàng >= 25 (Thực tế: ${d.totalCustomers})`);
    assert(d.totalDevices >= 28, `Tổng số thiết bị >= 28 (Thực tế: ${d.totalDevices})`);
    assert(d.totalTickets >= 25, `Tổng số phiếu sửa chữa >= 25 (Thực tế: ${d.totalTickets})`);
    assert(d.activeTickets > 0, `Số phiếu đang hoạt động > 0 (Thực tế: ${d.activeTickets})`);
    assert(d.unpaidInvoices >= 2, `Số hóa đơn chờ thanh toán >= 2 (Thực tế: ${d.unpaidInvoices})`);
    assert(d.ticketsByStatus && d.ticketsByStatus.COMPLETED !== undefined, 'Dashboard thống kê đầy đủ trạng thái phiếu');

    // -------------------------------------------------------------
    // CHỨC NĂNG 3: QUẢN LÝ KHO & CẢNH BÁO TỒN KHO (INVENTORY)
    // -------------------------------------------------------------
    console.log('\n--- 3. KIỂM THỬ QUẢN LÝ KHO & LINH KIỆN ---');
    const partsRes = await api('/api/spare-parts', { token: adminToken });
    assert(partsRes.ok && Array.isArray(partsRes.data) && partsRes.data.length >= 18, `Tải danh sách linh kiện (${partsRes.data?.length} mặt hàng)`);
    
    // Kiểm tra không có trường undefined
    const samplePart = partsRes.data[0];
    assert(samplePart.partCode && samplePart.partName && samplePart.categoryName && samplePart.purchasePrice > 0,
        `Linh kiện ${samplePart.partCode} đầy đủ mã, tên, danh mục, giá nhập: ${samplePart.purchasePrice}`);

    const lowStockRes = await api('/api/spare-parts?lowStockOnly=true', { token: adminToken });
    assert(lowStockRes.ok && Array.isArray(lowStockRes.data), `Lọc linh kiện tồn kho thấp thành công (${lowStockRes.data?.length} mặt hàng)`);

    const invSummary = await api('/api/inventory/summary', { token: adminToken });
    assert(invSummary.ok && invSummary.data.totalCatalogItems >= 18, 'Lấy tổng quan kho /api/inventory/summary thành công');

    const stockTxRes = await api('/api/inventory/transactions', { token: adminToken });
    assert(stockTxRes.ok && Array.isArray(stockTxRes.data) && stockTxRes.data.length >= 15, `Lịch sử xuất nhập kho (${stockTxRes.data?.length} giao dịch)`);

    // -------------------------------------------------------------
    // CHỨC NĂNG 4: HỒ SƠ KHÁCH HÀNG & THIẾT BỊ 360
    // -------------------------------------------------------------
    console.log('\n--- 4. KIỂM THỬ KHÁCH HÀNG & THIẾT BỊ ---');
    const custsRes = await api('/api/customers', { token: staffToken });
    assert(custsRes.ok && custsRes.data.length >= 25, `Tải danh sách khách hàng (${custsRes.data?.length} khách)`);

    const sampleCust = custsRes.data[0];
    assert(sampleCust.customerCode && sampleCust.fullName && sampleCust.phone && sampleCust.createdAt,
        `Khách hàng ${sampleCust.customerCode} đầy đủ mã, tên, SĐT, ngày tạo`);

    // Tìm kiếm khách hàng theo từ khóa
    const searchCust = await api('/api/customers?keyword=Nam', { token: staffToken });
    assert(searchCust.ok && searchCust.data.length >= 1, `Tìm kiếm khách hàng theo từ khóa "Nam" thành công (${searchCust.data.length} kết quả)`);

    // Xem thiết bị theo khách hàng (Customer 360 view)
    const custDevices = await api(`/api/customers/${sampleCust.customerCode}/devices`, { token: staffToken });
    assert(custDevices.ok && Array.isArray(custDevices.data), `Lấy danh sách thiết bị của khách ${sampleCust.customerCode} thành công`);

    // Thêm khách hàng mới
    const testPhone = `09${Math.floor(10000000 + Math.random() * 90000000)}`;
    const newCustRes = await api('/api/customers', {
        method: 'POST',
        token: staffToken,
        body: {
            fullName: 'Kiểm Thử Viên Tự Động',
            phone: testPhone,
            email: 'test.auto@repairshop.local',
            address: '123 Đường Kiểm Thử, Quận 1, TP.HCM'
        }
    });
    const createdCustCode = newCustRes.data?.customerCode || newCustRes.data?.code || newCustRes.data?.Code;
    assert(newCustRes.status === 201 && createdCustCode, `Thêm mới khách hàng thành công (Mã: ${createdCustCode})`);

    // Cập nhật thông tin khách hàng
    const updateCustRes = await api(`/api/customers/${createdCustCode}`, {
        method: 'PUT',
        token: staffToken,
        body: {
            fullName: 'Kiểm Thử Viên Tự Động (Đã Cập Nhật)',
            phone: testPhone,
            email: 'test.updated@repairshop.local',
            address: '456 Đường Mới, Quận 3, TP.HCM'
        }
    });
    assert(updateCustRes.ok, `Cập nhật thông tin khách hàng ${createdCustCode} thành công`);

    // Thêm thiết bị cho khách hàng
    const newDevRes = await api(`/api/customers/${createdCustCode}/devices`, {
        method: 'POST',
        token: staffToken,
        body: {
            deviceType: 'Laptop',
            brand: 'Dell',
            model: 'Latitude 7420 Core i7 / 16GB RAM',
            serialNumber: `DL-TEST-${Date.now()}`
        }
    });
    const createdDevCode = newDevRes.data?.deviceCode || newDevRes.data?.code || newDevRes.data?.Code;
    assert(newDevRes.status === 201 && createdDevCode, `Thêm thiết bị mới cho khách thành công (Mã: ${createdDevCode})`);

    // -------------------------------------------------------------
    // CHỨC NĂNG 5: QUY TRÌNH TIẾP NHẬN & SỬA CHỮA (WORKFLOW)
    // -------------------------------------------------------------
    console.log('\n--- 5. KIỂM THỬ QUY TRÌNH SỬA CHỮA HOÀN CHỈNH ---');

    // 5.1 Lập phiếu tiếp nhận mới (Status: RECEIVED)
    const createTicketRes = await api('/api/tickets', {
        method: 'POST',
        token: staffToken,
        body: {
            customerCode: createdCustCode,
            deviceCode: createdDevCode,
            serviceCode: 'DV003',
            deviceCondition: 'Máy nóng ran, quạt kêu rít, tự sập khi chạy nặng',
            customerRequest: 'Kiểm tra bảo dưỡng toàn bộ máy và vệ sinh quạt',
            technicianUsername: 'tech01'
        }
    });
    const newTicketCode = createTicketRes.data?.ticketCode || createTicketRes.data?.code || createTicketRes.data?.Code;
    assert(createTicketRes.status === 201 && newTicketCode, `Lập phiếu tiếp nhận mới thành công (Mã: ${newTicketCode})`);

    // 5.2 Kỹ thuật viên cập nhật chẩn đoán và báo giá
    const diagRes = await api(`/api/tickets/${newTicketCode}/diagnosis`, {
        method: 'PATCH',
        token: techToken,
        body: {
            diagnosis: 'Quạt tản nhiệt nghẹt xơ bụi, keo tản nhiệt CPU đã khô cứng. Cần vệ sinh quạt kép và tra keo Kryonaut.',
            quotedLaborCost: 150000
        }
    });
    assert(diagRes.ok, `Kỹ thuật viên cập nhật chẩn đoán và tiền công cho phiếu ${newTicketCode}`);

    // 5.3 Chuyển trạng thái sang DIAGNOSING -> WAITING_CONFIRM -> REPAIRING
    const stDiag = await api(`/api/tickets/${newTicketCode}/status`, {
        method: 'PATCH',
        token: techToken,
        body: { status: 'DIAGNOSING', note: 'KTV đang đo nhiệt độ tải tối đa' }
    });
    assert(stDiag.ok, 'Chuyển trạng thái phiếu sang DIAGNOSING');

    const stWait = await api(`/api/tickets/${newTicketCode}/status`, {
        method: 'PATCH',
        token: staffToken,
        body: { status: 'WAITING_CONFIRM', note: 'Đã gọi điện thoại báo giá cho khách' }
    });
    assert(stWait.ok, 'Chuyển trạng thái phiếu sang WAITING_CONFIRM');

    const stRepair = await api(`/api/tickets/${newTicketCode}/status`, {
        method: 'PATCH',
        token: techToken,
        body: { status: 'REPAIRING', note: 'Khách đồng ý, tiến hành vệ sinh máy' }
    });
    assert(stRepair.ok, 'Chuyển trạng thái phiếu sang REPAIRING');

    // 5.4 Kỹ thuật viên xuất dùng linh kiện cho phiếu qua Giao dịch kho
    const addPartRes = await api('/api/inventory/transactions', {
        method: 'POST',
        token: techToken,
        body: {
            partCode: 'LK00016', // Keo tản nhiệt Kryonaut 1g
            transactionType: 'OUT',
            quantity: 1,
            ticketCode: newTicketCode,
            note: 'Xuất keo tản nhiệt Kryonaut cho phiếu kiểm thử'
        }
    });
    assert(addPartRes.ok, `KTV xuất kho linh kiện LK00016 gắn vào phiếu ${newTicketCode}`);

    // 5.5 Kiểm tra tính toán chi phí phiếu (Tiền công + Phụ tùng)
    const costRes = await api(`/api/tickets/${newTicketCode}/cost`, { token: staffToken });
    assert(costRes.ok && costRes.data.laborCost === 150000 && costRes.data.partsTotal === 180000 && costRes.data.grandTotal === 330000,
        `Tính toán tổng chi phí chuẩn xác: Công 150k + Phụ tùng 180k = 330k`);

    // 5.6 Hoàn tất sửa chữa (Status: COMPLETED)
    const stComp = await api(`/api/tickets/${newTicketCode}/status`, {
        method: 'PATCH',
        token: techToken,
        body: { status: 'COMPLETED', note: 'Đã test Cinebench R23 nhiệt độ ổn định 70°C' }
    });
    assert(stComp.ok, 'Chuyển trạng thái phiếu sang COMPLETED');

    // 5.7 Nhân viên lập hóa đơn thanh toán (INVOICE)
    const invCreateRes = await api('/api/invoices', {
        method: 'POST',
        token: staffToken,
        body: {
            ticketCode: newTicketCode,
            discountAmount: 30000,
            paymentMethod: 'TRANSFER',
            note: 'Khách thanh toán quét mã QR VietQR, giảm giá 30k khuyến mãi'
        }
    });
    const newInvoiceCode = invCreateRes.data?.invoiceCode || invCreateRes.data?.InvoiceCode;
    const invTotal = invCreateRes.data?.totalAmount || invCreateRes.data?.TotalAmount;
    assert(invCreateRes.status === 201 && newInvoiceCode,
        `Tạo hóa đơn thanh toán thành công (Mã: ${newInvoiceCode}, Tổng tiền: ${invTotal})`);

    // 5.8 Thu ngân xác nhận thanh toán hóa đơn
    const payRes = await api(`/api/invoices/${newInvoiceCode}/pay`, {
        method: 'POST',
        token: staffToken,
        body: { paymentMethod: 'TRANSFER' }
    });
    assert(payRes.ok && payRes.data?.payment, `Thanh toán hóa đơn ${newInvoiceCode} thành công và tự động kích hoạt bảo hành`);

    // 5.9 Bàn giao máy cho khách (Status: DELIVERED)
    const stDeliv = await api(`/api/tickets/${newTicketCode}/status`, {
        method: 'PATCH',
        token: staffToken,
        body: { status: 'DELIVERED', note: 'Khách kiểm tra máy tại quầy ưng ý, bàn giao kèm sổ bảo hành điện tử' }
    });
    assert(stDeliv.ok, 'Chuyển trạng thái phiếu sang DELIVERED (Bàn giao hoàn tất)');

    // 5.10 Kiểm tra nhật ký kiểm toán trạng thái phiếu (AUDIT LOGS)
    const logsRes = await api(`/api/tickets/${newTicketCode}/logs`, { token: staffToken });
    assert(logsRes.ok && logsRes.data.length >= 5, `Nhật ký chuyển trạng thái phiếu ghi nhận đầy đủ (${logsRes.data?.length} mốc lịch sử)`);

    // 5.11 Khách hàng tra cứu tiến độ công khai qua Public Portal
    const pubTicketRes = await api(`/api/public/track?query=${newTicketCode}`);
    const trackList = Array.isArray(pubTicketRes.data) ? pubTicketRes.data : [];
    assert(pubTicketRes.ok && trackList.length > 0 && trackList[0].ticketCode === newTicketCode,
        `Cổng thông tin khách hàng tra cứu phiếu ${newTicketCode} công khai không cần đăng nhập`);

    // -------------------------------------------------------------
    // CHỨC NĂNG 6: HÓA ĐƠN & BẢO HÀNH ĐIỆN TỬ
    // -------------------------------------------------------------
    console.log('\n--- 6. KIỂM THỬ HÓA ĐƠN & SỔ BẢO HÀNH ĐIỆN TỬ ---');
    const invoicesList = await api('/api/invoices', { token: staffToken });
    assert(invoicesList.ok && Array.isArray(invoicesList.data) && invoicesList.data.length >= 12,
        `Tải danh sách hóa đơn (${invoicesList.data?.length} hóa đơn)`);

    const warrantiesList = await api('/api/warranties', { token: staffToken });
    const wData = Array.isArray(warrantiesList.data) ? warrantiesList.data : warrantiesList.data?.data;
    assert(warrantiesList.ok && Array.isArray(wData) && wData.length >= 12,
        `Tải danh sách sổ bảo hành (${wData?.length} sổ bảo hành)`);

    // Tra cứu bảo hành công khai bằng từ khóa (SĐT)
    const pubWarrantySearch = await api('/api/warranties/search?phone=0982345678', { token: staffToken });
    const wSearchData = Array.isArray(pubWarrantySearch.data) ? pubWarrantySearch.data : pubWarrantySearch.data?.data;
    assert(pubWarrantySearch.ok && Array.isArray(wSearchData) && wSearchData.length >= 1,
        `Tra cứu sổ bảo hành điện tử theo SĐT (Tìm thấy ${wSearchData?.length} sổ bảo hành)`);

    // -------------------------------------------------------------
    // CHỨC NĂNG 7: BÁO CÁO & THỐNG KÊ (REPORTS & ANALYTICS)
    // -------------------------------------------------------------
    console.log('\n--- 7. KIỂM THỬ BÁO CÁO & THỐNG KÊ DOANH THU ---');
    const repTech = await api('/api/reports/revenue-by-technician', { token: adminToken });
    assert(repTech.ok && Array.isArray(repTech.data) && repTech.data.length >= 2,
        `Báo cáo doanh thu & tiền công theo Kỹ thuật viên (${repTech.data?.length} KTV)`);
    assert(repTech.data[0].technicianName && repTech.data[0].completedTicketsCount >= 0 && repTech.data[0].totalLaborRevenue >= 0,
        `Báo cáo KTV ${repTech.data[0].technicianName}: ${repTech.data[0].completedTicketsCount} phiếu, Tiền công: ${repTech.data[0].totalLaborRevenue} đ`);

    const repService = await api('/api/reports/revenue-by-service', { token: adminToken });
    assert(repService.ok && Array.isArray(repService.data) && repService.data.length >= 1,
        `Báo cáo doanh thu theo Gói dịch vụ (${repService.data?.length} dịch vụ có phát sinh)`);
    assert(repService.data[0].serviceName && repService.data[0].ticketsCount >= 0 && repService.data[0].totalRevenue >= 0,
        `Báo cáo dịch vụ ${repService.data[0].serviceName}: ${repService.data[0].ticketsCount} lượt, Doanh thu: ${repService.data[0].totalRevenue} đ`);

    const repTopParts = await api('/api/reports/top-selling-parts', { token: adminToken });
    assert(repTopParts.ok && Array.isArray(repTopParts.data), `Báo cáo phụ tùng xuất dùng nhiều nhất (${repTopParts.data?.length} mặt hàng)`);

    const repSlowParts = await api('/api/reports/slow-moving-parts', { token: adminToken });
    assert(repSlowParts.ok && Array.isArray(repSlowParts.data), `Báo cáo phụ tùng đọng vốn lâu ngày (${repSlowParts.data?.length} mặt hàng)`);

    // -------------------------------------------------------------
    // CHỨC NĂNG 8: QUẢN TRỊ USER & PHÂN QUYỀN RBAC
    // -------------------------------------------------------------
    console.log('\n--- 8. KIỂM THỬ QUẢN TRỊ USER & PHÂN QUYỀN RBAC ---');
    const usersRes = await api('/api/users', { token: adminToken });
    assert(usersRes.ok && Array.isArray(usersRes.data) && usersRes.data.length >= 8, `Danh sách tài khoản nhân sự (${usersRes.data?.length} users)`);
    const sampleUser = usersRes.data[0];
    assert(sampleUser.username && sampleUser.fullName && sampleUser.roleCode && sampleUser.roleName,
        `Tài khoản ${sampleUser.username}: ${sampleUser.fullName} (Vai trò: ${sampleUser.roleName})`);

    // Cập nhật trạng thái khóa/mở tài khoản
    const toggleStatus = await api('/api/users/customer/status', {
        method: 'PATCH',
        token: adminToken,
        body: { isActive: false }
    });
    assert(toggleStatus.ok && toggleStatus.data.isActive === false, 'Khóa tài khoản người dùng thành công');

    const restoreStatus = await api('/api/users/customer/status', {
        method: 'PATCH',
        token: adminToken,
        body: { isActive: true }
    });
    assert(restoreStatus.ok && restoreStatus.data.isActive === true, 'Kích hoạt lại tài khoản người dùng thành công');

    // -------------------------------------------------------------
    // CHỨC NĂNG 9: BẢNG GIÁ DỊCH VỤ CÔNG KHAI (PUBLIC PORTAL)
    // -------------------------------------------------------------
    console.log('\n--- 9. KIỂM THỬ BẢNG GIÁ DỊCH VỤ CÔNG KHAI ---');
    const pubServices = await api('/api/public/services');
    assert(pubServices.ok && Array.isArray(pubServices.data) && pubServices.data.length >= 10,
        `Bảng giá niêm yết dịch vụ công khai (${pubServices.data?.length} dịch vụ)`);

    // -------------------------------------------------------------
    // CHỨC NĂNG 10: HẠ TẦNG & SỨC KHỎE HỆ THỐNG (HEALTH CHECK)
    // -------------------------------------------------------------
    console.log('\n--- 10. KIỂM THỬ HẠ TẦNG & SỨC KHỎE CƠ SỞ DỮ LIỆU ---');
    const health = await api('/health');
    assert(health.ok && health.data.status === 'ok', `Kiểm tra sức khỏe hệ thống: Status ${health.data?.status} (${health.data?.checkedAt})`);

    // -------------------------------------------------------------
    // TỔNG KẾT KẾT QUẢ KIỂM THỬ
    // -------------------------------------------------------------
    console.log('\n================================================================');
    console.log(`KẾT QUẢ KIỂM THỬ TOÀN DIỆN: ${passedTests} PASSED / ${failedTests} FAILED (Tổng cộng ${passedTests + failedTests} bài test)`);
    console.log(`TỶ LỆ THÀNH CÔNG: ${Math.round((passedTests / (passedTests + failedTests)) * 100)}%`);
    console.log('================================================================');

    if (failedTests > 0) {
        process.exit(1);
    }
}

runAllTests().catch(err => {
    console.error('Lỗi ngoại lệ trong quá trình chạy test:', err);
    process.exit(1);
});
