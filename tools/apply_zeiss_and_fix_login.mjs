import fs from 'fs';

console.log('--- ĐANG THỰC HIỆN CẢI TIẾN: ZEISS TECHCARE, BỎ DEMO BOX, FIX ĐĂNG NHẬP & PHÂN QUYỀN ---');

let html = fs.readFileSync('src/web-admin/index.html', 'utf8');

// 1. ĐỔI TÊN THÀNH ZEISS TECHCARE VÀ LẮP LOGO ZEISS ICONIC
const zeissSvgLogo = `<svg viewBox="0 0 100 100" width="40" height="40" style="border-radius: 8px; flex-shrink: 0; box-shadow: 0 4px 10px rgba(0, 47, 108, 0.35);">
    <rect width="100" height="100" rx="14" fill="#002f6c"/>
    <text x="50" y="60" font-family="'Inter', -apple-system, sans-serif" font-weight="900" font-style="italic" font-size="28" fill="#ffffff" text-anchor="middle" letter-spacing="-1">ZEISS</text>
</svg>`;

const zeissSvgSmall = `<svg viewBox="0 0 100 100" width="34" height="34" style="border-radius: 6px; flex-shrink: 0;">
    <rect width="100" height="100" rx="12" fill="#002f6c"/>
    <text x="50" y="60" font-family="'Inter', -apple-system, sans-serif" font-weight="900" font-style="italic" font-size="28" fill="#ffffff" text-anchor="middle" letter-spacing="-1">ZEISS</text>
</svg>`;

// Cập nhật title
html = html.replace(/<title>[\s\S]*?<\/title>/, '<title>ZEISS TECHCARE — Hệ Thống Quản Lý Dịch Vụ Sửa Chữa & Bảo Hành</title>');

// Thay thế các chỗ hiển thị REPAIRPRO 33 thành ZEISS TECHCARE
html = html.split('REPAIRPRO 33').join('ZEISS TECHCARE');
html = html.split('REPAIRPRO WORKSPACE').join('ZEISS WORKSPACE');

// Thay logo trong portal navbar
html = html.replace(/<div class="portal-logo-icon">\s*<i class="fa-solid fa-screwdriver-wrench"><\/i>\s*<\/div>/, zeissSvgLogo);

// Thay logo trong appSidebar brand
html = html.replace(/<div class="brand-icon">\s*<i class="fa-solid fa-screwdriver-wrench"><\/i>\s*<\/div>/, zeissSvgSmall);

// Thay logo trong auth hero
html = html.replace(/<div class="auth-hero-logo">\s*<i class="fa-solid fa-screwdriver-wrench"><\/i>\s*<\/div>/, zeissSvgLogo);

console.log('✔ Đã đổi thương hiệu sang ZEISS TECHCARE và gắn logo ZEISS chính hãng!');

// 2. BỎ KHỐI DEMO CARDS (TRUY CẬP NHANH TÀI KHOẢN MẪU) TRONG FORM ĐĂNG NHẬP THEO YÊU CẦU
const demoBoxRegex = /<!-- TRUY CẬP NHANH TÀI KHOẢN MẪU[\s\S]*?<\/div>\s*<\/div>\s*<\/div>/;
if (demoBoxRegex.test(html)) {
    html = html.replace(demoBoxRegex, '');
    console.log('✔ Đã xóa bỏ khối demo roles box khỏi Auth modal!');
} else {
    // Thử xóa bằng class demo-roles-box
    const idxDemo = html.indexOf('<div class="demo-roles-box">');
    if (idxDemo !== -1) {
        const endDemo = html.indexOf('</div>\n                    </div>\n\n                    <div class="text-center mt-3">', idxDemo);
        if (endDemo !== -1) {
            html = html.slice(0, idxDemo) + html.slice(endDemo + 26);
            console.log('✔ Đã xóa bỏ demo-roles-box qua slice!');
        }
    }
}

// 3. THÊM TÙY CHỌN ĐĂNG NHẬP NHANH GỌN GÀNG (SELECT VAI TRÒ) NGAY DƯỚI INPUT USERNAME/PASSWORD
// Để người dùng nhập bình thường hoặc chọn nhanh tài khoản quản lý / người dùng
const quickRoleSelect = `
                        <div class="mb-3 p-2 bg-light rounded-3 border">
                            <label class="form-label mb-1 text-muted" style="font-size: 0.72rem; font-weight: 600;">
                                <i class="fa-solid fa-user-gear text-primary me-1"></i>Chọn nhanh tài khoản phân quyền:
                            </label>
                            <select class="form-select form-select-sm" id="quickRolePicker" onchange="applyQuickRoleSelection(this.value)">
                                <option value="admin" selected>👑 Quản lý toàn quyền (Admin) — admin</option>
                                <option value="staff01">🎧 Nhân viên Tiếp nhận & Thu ngân — staff01</option>
                                <option value="tech01">🔧 Kỹ thuật viên sửa chữa — tech01</option>
                                <option value="khach01">👤 Người dùng / Khách hàng — khach01</option>
                            </select>
                        </div>
`;

if (!html.includes('id="quickRolePicker"')) {
    html = html.replace('<div class="mb-3">\n                            <label class="form-label small fw-semibold text-secondary">Tên tài khoản / Username</label>', quickRoleSelect + '\n                        <div class="mb-3">\n                            <label class="form-label small fw-semibold text-secondary">Tên tài khoản / Username</label>');
    console.log('✔ Đã thêm Quick Role Picker vào form đăng nhập');
}

// 4. KIỂM TRA VÀ INJECT CÁC HÀM JAVASCRIPT ĐIỀU PHỐI (TOGGLEVIEWMODE, EXECUTETRACKING, RENDERSIDEBAR, SIMULATEROLE)
// Đặt trực tiếp vào đầu block <script> để đảm bảo luôn tồn tại trong global scope
const essentialScriptFunctions = `
        // =========================================================================
        // HÀM CHUYỂN ĐỔI CHẾ ĐỘ HIỂN THỊ (PUBLIC PORTAL <-> WORKSPACE)
        // =========================================================================
        function toggleViewMode(mode) {
            console.log('toggleViewMode called with:', mode);
            const portalView = document.getElementById('publicPortalView');
            const wsView = document.getElementById('workspaceView');
            const btnGoWs = document.getElementById('btnPortalGoWorkspace');
            const btnLogin = document.getElementById('btnPortalLogin');

            if (mode === 'portal') {
                if (portalView) portalView.style.display = 'block';
                if (wsView) wsView.style.display = 'none';
                window.scrollTo({ top: 0, behavior: 'smooth' });
                loadPublicServices();

                if (state.token && state.user) {
                    if (btnGoWs) {
                        btnGoWs.style.display = 'inline-block';
                        btnGoWs.innerHTML = '<i class="fa-solid fa-laptop-code me-1"></i>Vào Không Gian Quản Lý (' + (state.user.role || 'USER') + ')';
                    }
                    if (btnLogin) btnLogin.style.display = 'none';
                } else {
                    if (btnGoWs) btnGoWs.style.display = 'none';
                    if (btnLogin) btnLogin.style.display = 'inline-block';
                }
            } else {
                // Vào chế độ Workspace
                if (!state.token || !state.user) {
                    showAuthOverlay('login');
                    return;
                }
                if (portalView) portalView.style.display = 'none';
                if (wsView) wsView.style.display = 'block';
                applyUserRoleUI();
            }
        }

        function applyQuickRoleSelection(val) {
            const uInput = document.getElementById('loginUsername');
            const pInput = document.getElementById('loginPassword');
            if (uInput && pInput) {
                uInput.value = val;
                pInput.value = 'Abc@12345';
            }
        }

        // =========================================================================
        // TRA CỨU TIẾN ĐỘ SỬA CHỮA CÔNG KHAI (KHÁCH THAM QUAN / KHÁCH HÀNG)
        // =========================================================================
        async function executePublicTracking(query) {
            const q = (query || '').trim();
            if (!q) {
                showToast('Vui lòng nhập mã phiếu hoặc số điện thoại để tra cứu!', 'warning');
                return;
            }

            const container = document.getElementById('publicTrackingContainer');
            const heroResult = document.getElementById('heroFastSearchResult');
            if (container) {
                container.innerHTML = '<div class="text-center py-4 text-muted"><span class="spinner-border spinner-border-sm me-2"></span>Đang truy vấn cơ sở dữ liệu ZEISS...</div>';
            }

            try {
                const res = await fetch(API_BASE + '/api/public/track?query=' + encodeURIComponent(q));
                if (!res.ok) throw new Error('Không thể tra cứu thông tin phiếu');
                const list = await res.json();

                if (!list || list.length === 0) {
                    const noResultHtml = '<div class="alert alert-warning border text-center p-4 rounded-3 shadow-sm">' +
                        '<i class="fa-solid fa-triangle-exclamation fs-3 text-warning mb-2 d-block"></i>' +
                        '<strong>Không tìm thấy phiếu sửa chữa nào!</strong>' +
                        '<p class="mb-0 small text-muted">Vui lòng kiểm tra lại mã phiếu (ví dụ: PSC2026090001, TICK0003) hoặc số điện thoại.</p>' +
                        '</div>';
                    if (container) container.innerHTML = noResultHtml;
                    if (heroResult) heroResult.innerHTML = noResultHtml;
                    return;
                }

                let htmlResults = '';
                list.forEach(t => {
                    const statusText = {
                        'RECEIVED': 'Tiếp nhận máy',
                        'DIAGNOSING': 'Đang chẩn đoán',
                        'WAITING_CONFIRM': 'Chờ khách xác nhận',
                        'REPAIRING': 'Đang tiến hành sửa',
                        'COMPLETED': 'Đã hoàn thành',
                        'DELIVERED': 'Đã bàn giao máy',
                        'CANCELLED': 'Đã hủy'
                    }[t.status] || t.status;

                    const statusBadge = {
                        'RECEIVED': 'bg-secondary',
                        'DIAGNOSING': 'bg-warning text-dark',
                        'WAITING_CONFIRM': 'bg-info text-white',
                        'REPAIRING': 'bg-primary',
                        'COMPLETED': 'bg-success',
                        'DELIVERED': 'bg-dark',
                        'CANCELLED': 'bg-danger'
                    }[t.status] || 'bg-primary';

                    htmlResults += \`
                        <div class="card border rounded-4 shadow-sm p-4 mb-3">
                            <div class="d-flex flex-wrap align-items-center justify-content-between border-bottom pb-3 mb-3 gap-2">
                                <div>
                                    <span class="badge \${statusBadge} px-3 py-2 rounded-pill font-monospace fw-bold mb-1">\${statusText}</span>
                                    <h5 class="fw-bold text-dark mb-0 font-monospace">\${t.ticketCode}</h5>
                                </div>
                                <div class="text-md-end">
                                    <div class="text-muted small">Khách hàng: <strong class="text-dark">\${t.customerName}</strong> (\${t.phone})</div>
                                    <div class="text-muted small">Thời gian tiếp nhận: \${formatDate(t.createdAt)}</div>
                                </div>
                            </div>

                            <div class="row g-3 mb-3">
                                <div class="col-md-6">
                                    <div class="p-3 bg-light rounded-3 border">
                                        <div class="text-muted small fw-semibold">Thiết bị sửa chữa:</div>
                                        <div class="fw-bold text-dark fs-6">\${t.deviceModel} (\${t.deviceType})</div>
                                        <div class="text-muted small">Số Serial / IMEI: \${t.serialNumber || 'Đang cập nhật'}</div>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="p-3 bg-light rounded-3 border">
                                        <div class="text-muted small fw-semibold">Kỹ thuật viên phụ trách:</div>
                                        <div class="fw-bold text-dark fs-6">\${t.technicianName}</div>
                                        <div class="text-muted small">Dự kiến hoàn thành: \${t.expectedFinishAt ? formatDate(t.expectedFinishAt) : 'Trong ngày'}</div>
                                    </div>
                                </div>
                            </div>

                            <div class="p-3 bg-white rounded-3 border mb-3">
                                <div class="fw-bold text-dark small mb-1"><i class="fa-solid fa-stethoscope text-primary me-2"></i>Hiện tượng & Chẩn đoán lỗi:</div>
                                <div class="text-secondary small">\${t.diagnosis || t.faultDescription || 'Đang được kỹ thuật viên kiểm tra đo đạc'}</div>
                            </div>

                            <div class="d-flex align-items-center justify-content-between pt-2 border-top">
                                <div>
                                    <span class="text-muted small">Tổng chi phí dự kiến:</span>
                                    <span class="fs-5 fw-bold text-primary ms-2">\${formatVND(t.totalAmount || 0)}</span>
                                </div>
                                <span class="badge bg-success bg-opacity-10 text-success border border-success border-opacity-25 px-3 py-2 rounded-pill font-monospace small">
                                    <i class="fa-solid fa-shield-halved me-1"></i>Bảo hành chính hãng ZEISS
                                </span>
                            </div>
                        </div>
                    \`;
                });

                if (container) container.innerHTML = htmlResults;
                if (heroResult) heroResult.innerHTML = htmlResults;
            } catch (err) {
                console.error(err);
                if (container) container.innerHTML = '<div class="alert alert-danger">Lỗi tra cứu: ' + err.message + '</div>';
            }
        }

        // =========================================================================
        // TẢI BẢNG GIÁ DỊCH VỤ CÔNG KHAI TỪ API
        // =========================================================================
        async function loadPublicServices() {
            const grid = document.getElementById('publicServicesGrid');
            if (!grid) return;

            try {
                const res = await fetch(API_BASE + '/api/public/services');
                let services = [];
                if (res.ok) {
                    services = await res.json();
                }

                if (!services || services.length === 0) {
                    services = [
                        { name: 'Ép kính & Thay màn hình OLED', laborCost: 250000, warrantyDays: 180, description: 'Màn hình cảm ứng zin, hiển thị chuẩn màu, tặng dán cường lực.' },
                        { name: 'Thay Pin Dung Lượng Cao / Chuẩn', laborCost: 100000, warrantyDays: 365, description: 'Pin dung lượng cao có mạch bảo vệ, an toàn chống phồng rộp.' },
                        { name: 'Vệ sinh máy, tra keo tản nhiệt MX-4', laborCost: 120000, warrantyDays: 90, description: 'Vệ sinh sạch quạt tản nhiệt, hạ nhiệt CPU / GPU 15 - 20°C.' },
                        { name: 'Sửa lỗi IC nguồn, sạc không vào pin', laborCost: 350000, warrantyDays: 90, description: 'Đo đạc kiểm tra vi mạch, khắc phục dứt điểm chạm chập nguồn.' },
                        { name: 'Nâng cấp SSD NVMe & RAM tốc độ cao', laborCost: 80000, warrantyDays: 730, description: 'Tăng tốc khởi động máy tính, bảo hành đổi mới 2 năm.' },
                        { name: 'Thay bàn phím Laptop & Touchpad', laborCost: 150000, warrantyDays: 180, description: 'Bàn phím chính hãng, gõ êm, độ nảy chuẩn.' }
                    ];
                }

                let htmlContent = '';
                services.forEach(s => {
                    htmlContent += \`
                        <div class="col-lg-4 col-md-6">
                            <div class="service-pricing-card">
                                <div>
                                    <div class="d-flex align-items-center justify-content-between mb-3">
                                        <span class="badge bg-primary bg-opacity-10 text-primary fw-bold font-monospace">\${s.code || 'DỊCH VỤ'}</span>
                                        <span class="badge bg-success bg-opacity-10 text-success border border-success border-opacity-25 small">
                                            <i class="fa-solid fa-shield-halved me-1"></i>Bảo hành \${s.warrantyDays || 90} ngày
                                        </span>
                                    </div>
                                    <h5 class="fw-bold text-dark mb-2">\${s.name}</h5>
                                    <p class="text-muted small mb-3">\${s.description || 'Dịch vụ sửa chữa tiêu chuẩn ZEISS kỹ thuật cao, lấy liền trong ngày.'}</p>
                                </div>
                                <div class="pt-3 border-top d-flex align-items-center justify-content-between">
                                    <div>
                                        <div class="text-muted" style="font-size: 0.72rem;">Chi phí nhân công:</div>
                                        <div class="service-price-tag">\${formatVND(s.laborCost || 0)}</div>
                                    </div>
                                    <button class="btn btn-outline-primary btn-sm rounded-pill px-3 fw-semibold" onclick="selectServiceForBooking('\${s.name}')">
                                        Đặt lịch ngay
                                    </button>
                                </div>
                            </div>
                        </div>
                    \`;
                });

                grid.innerHTML = htmlContent;
            } catch (err) {
                console.error(err);
            }
        }

        function selectServiceForBooking(serviceName) {
            const faultInput = document.getElementById('bookFault');
            if (faultInput) faultInput.value = 'Yêu cầu dịch vụ: ' + serviceName;
            const bookingSection = document.getElementById('bookingSection');
            if (bookingSection) bookingSection.scrollIntoView({ behavior: 'smooth' });
        }

        // =========================================================================
        // XỬ LÝ GỬI FORM ĐẶT LỊCH TIẾP NHẬN ONLINE
        // =========================================================================
        async function handlePublicBookingSubmit(event) {
            event.preventDefault();
            const btn = document.getElementById('btnBookSubmit');
            const fullName = document.getElementById('bookFullName').value.trim();
            const phone = document.getElementById('bookPhone').value.trim();
            const deviceType = document.getElementById('bookDeviceType').value;
            const model = document.getElementById('bookModel').value.trim();
            const preferredTime = document.getElementById('bookPreferredTime').value.trim();
            const serial = document.getElementById('bookSerial').value.trim();
            const fault = document.getElementById('bookFault').value.trim();

            if (!fullName || !phone || !fault) {
                showToast('Vui lòng điền họ tên, số điện thoại và mô tả lỗi!', 'warning');
                return;
            }

            btn.disabled = true;
            btn.innerHTML = '<span class="spinner-border spinner-border-sm me-2"></span>Đang tiếp nhận...';

            try {
                const res = await fetch(API_BASE + '/api/public/appointment', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({
                        fullName,
                        phone,
                        deviceType,
                        brand: 'Thiết bị khách',
                        model: model || 'Thiết bị',
                        serialNumber: serial,
                        faultDescription: fault,
                        preferredTime
                    })
                });

                if (!res.ok) throw new Error('Không thể gửi yêu cầu đặt lịch');
                const data = await res.json();

                showToast('Đặt lịch sửa chữa thành công! Mã phiếu của bạn là: ' + data.ticketCode, 'success');
                executePublicTracking(data.ticketCode);
                const trackingSection = document.getElementById('trackingSection');
                if (trackingSection) trackingSection.scrollIntoView({ behavior: 'smooth' });
                event.target.reset();
            } catch (err) {
                console.error(err);
                showToast('Lỗi gửi lịch hẹn: ' + err.message, 'danger');
            } finally {
                btn.disabled = false;
                btn.innerHTML = '<i class="fa-solid fa-paper-plane me-2"></i>Gửi Yêu Cầu Hẹn Giờ Tiếp Nhận';
            }
        }

        // =========================================================================
        // PHÂN QUYỀN RẠCH RÒI SIDEBAR MENU CHO TỪNG VAI TRÒ
        // =========================================================================
        function renderSidebarForRole(role) {
            const menu = document.getElementById('sidebarMenu');
            if (!menu) return;

            let html = '';

            if (role === 'CUSTOMER') {
                html = \`
                    <div class="sidebar-role-indicator role-indicator-CUSTOMER">
                        <i class="fa-solid fa-user-check"></i> CỔNG KHÁCH HÀNG
                    </div>
                    <div class="sidebar-section-title">Dịch Vụ Của Tôi</div>
                    <a href="#" class="nav-link active" onclick="switchTab('tickets')">
                        <i class="fa-solid fa-ticket text-info"></i>
                        <span>Phiếu sửa của tôi</span>
                        <span class="badge bg-primary rounded-pill ms-auto" id="badgeActiveTickets">0</span>
                    </a>
                    <a href="#" class="nav-link" onclick="switchTab('customers')">
                        <i class="fa-solid fa-mobile-screen-button text-success"></i>
                        <span>Thiết bị của tôi</span>
                    </a>
                    <a href="#" class="nav-link" onclick="switchTab('warranty')">
                        <i class="fa-solid fa-shield-halved text-purple"></i>
                        <span>Sổ bảo hành điện tử</span>
                    </a>
                    <a href="#" class="nav-link" onclick="switchTab('billing')">
                        <i class="fa-solid fa-file-invoice-dollar text-primary"></i>
                        <span>Lịch sử thanh toán & VietQR</span>
                    </a>
                    <div class="sidebar-section-title">Cổng Thông Tin</div>
                    <a href="#" class="nav-link" onclick="toggleViewMode('portal')">
                        <i class="fa-solid fa-house-chimney text-secondary"></i>
                        <span>Về Cổng Dịch Vụ</span>
                    </a>
                \`;
            } else if (role === 'TECHNICIAN') {
                html = \`
                    <div class="sidebar-role-indicator role-indicator-TECHNICIAN">
                        <i class="fa-solid fa-wrench"></i> BÀN THAO TÁC KỸ THUẬT
                    </div>
                    <div class="sidebar-section-title">Nhiệm Vụ Sửa Chữa</div>
                    <a href="#" class="nav-link active" onclick="switchTab('tickets')">
                        <i class="fa-solid fa-screwdriver-wrench text-warning"></i>
                        <span>Máy được phân công</span>
                        <span class="badge bg-warning text-dark rounded-pill ms-auto" id="badgeActiveTickets">0</span>
                    </a>
                    <div class="sidebar-section-title">Kho Phụ Tùng & Thay Thế</div>
                    <a href="#" class="nav-link" onclick="switchTab('inventory')">
                        <i class="fa-solid fa-boxes-stacked text-primary"></i>
                        <span>Tra cứu linh kiện kho</span>
                        <span class="badge bg-danger rounded-pill ms-auto" id="badgeLowStock" style="display: none;">0</span>
                    </a>
                    <a href="#" class="nav-link" onclick="switchTab('warranty')">
                        <i class="fa-solid fa-shield-halved text-purple"></i>
                        <span>Tra cứu bảo hành</span>
                    </a>
                    <div class="sidebar-section-title">Cổng Dịch Vụ</div>
                    <a href="#" class="nav-link" onclick="toggleViewMode('portal')">
                        <i class="fa-solid fa-house-chimney text-secondary"></i>
                        <span>Về Cổng Dịch Vụ</span>
                    </a>
                \`;
            } else if (role === 'STAFF') {
                html = \`
                    <div class="sidebar-role-indicator role-indicator-STAFF">
                        <i class="fa-solid fa-headset"></i> QUẦY TIẾP NHẬN & THU NGÂN
                    </div>
                    <div class="sidebar-section-title">Tiếp Nhận & Điều Phối</div>
                    <a href="#" class="nav-link active" onclick="switchTab('tickets')">
                        <i class="fa-solid fa-ticket text-info"></i>
                        <span>Điều phối phiếu sửa</span>
                        <span class="badge bg-primary rounded-pill ms-auto" id="badgeActiveTickets">0</span>
                    </a>
                    <div class="sidebar-section-title">Thu Ngân & Khách Hàng</div>
                    <a href="#" class="nav-link" onclick="switchTab('billing')">
                        <i class="fa-solid fa-file-invoice-dollar text-success"></i>
                        <span>Thu ngân & VietQR</span>
                    </a>
                    <a href="#" class="nav-link" onclick="switchTab('customers')">
                        <i class="fa-solid fa-users text-primary"></i>
                        <span>Khách hàng & Thiết bị</span>
                    </a>
                    <a href="#" class="nav-link" onclick="switchTab('warranty')">
                        <i class="fa-solid fa-shield-halved text-purple"></i>
                        <span>Cấp sổ bảo hành</span>
                    </a>
                    <div class="sidebar-section-title">Vật Tư & Cổng Dịch Vụ</div>
                    <a href="#" class="nav-link" onclick="switchTab('inventory')">
                        <i class="fa-solid fa-boxes-stacked text-warning"></i>
                        <span>Kho linh kiện</span>
                    </a>
                    <a href="#" class="nav-link" onclick="toggleViewMode('portal')">
                        <i class="fa-solid fa-house-chimney text-secondary"></i>
                        <span>Về Cổng Dịch Vụ</span>
                    </a>
                \`;
            } else {
                // ADMIN (QUẢN LÝ TOÀN QUYỀN)
                html = \`
                    <div class="sidebar-role-indicator role-indicator-ADMIN">
                        <i class="fa-solid fa-crown"></i> QUẢN TRỊ VIÊN TOÀN QUYỀN
                    </div>
                    <div class="sidebar-section-title">Vận Hành & Kinh Doanh</div>
                    <a href="#" class="nav-link active" onclick="switchTab('dashboard')">
                        <i class="fa-solid fa-chart-pie text-primary"></i>
                        <span>Tổng quan (Dashboard KPI)</span>
                    </a>
                    <a href="#" class="nav-link" onclick="switchTab('tickets')">
                        <i class="fa-solid fa-ticket text-info"></i>
                        <span>Phiếu sửa chữa</span>
                        <span class="badge bg-primary rounded-pill ms-auto" id="badgeActiveTickets">0</span>
                    </a>
                    <a href="#" class="nav-link" onclick="switchTab('billing')">
                        <i class="fa-solid fa-file-invoice-dollar text-success"></i>
                        <span>Hóa đơn & Doanh thu</span>
                    </a>

                    <div class="sidebar-section-title">Kho & Bảo Hành</div>
                    <a href="#" class="nav-link" onclick="switchTab('inventory')">
                        <i class="fa-solid fa-boxes-stacked text-warning"></i>
                        <span>Kho linh kiện & Cảnh báo</span>
                        <span class="badge bg-danger rounded-pill ms-auto" id="badgeLowStock" style="display: none;">0</span>
                    </a>
                    <a href="#" class="nav-link" onclick="switchTab('warranty')">
                        <i class="fa-solid fa-shield-halved text-purple"></i>
                        <span>Sổ bảo hành điện tử</span>
                    </a>

                    <div class="sidebar-section-title">Hệ Thống & Khách Hàng</div>
                    <a href="#" class="nav-link" onclick="switchTab('customers')">
                        <i class="fa-solid fa-users text-primary"></i>
                        <span>Khách hàng & Thiết bị</span>
                    </a>
                    <a href="#" class="nav-link" onclick="switchTab('users')">
                        <i class="fa-solid fa-user-shield text-danger"></i>
                        <span>Quản trị User & RBAC</span>
                    </a>
                    <a href="#" class="nav-link" onclick="switchTab('reports')">
                        <i class="fa-solid fa-chart-line text-success"></i>
                        <span>Báo cáo & Thống kê đồ án</span>
                    </a>
                    <a href="#" class="nav-link" onclick="switchTab('system')">
                        <i class="fa-solid fa-server text-secondary"></i>
                        <span>Hạ tầng CSDL SQL</span>
                    </a>
                \`;
            }

            menu.innerHTML = html;
        }

        // =========================================================================
        // MÔ PHỎNG VAI TRÒ NHANH (RBAC SIMULATOR)
        // =========================================================================
        function simulateRole(targetRole) {
            if (!state.user) {
                state.user = { username: 'admin', fullName: 'Quản trị viên', role: targetRole };
            }
            state.user.role = targetRole;

            const roleNames = {
                'ADMIN': 'Quản Trị Viên (Admin)',
                'STAFF': 'Tiếp Nhận & Thu Ngân (Staff)',
                'TECHNICIAN': 'Kỹ Thuật Viên (Tech)',
                'CUSTOMER': 'Khách Hàng (Customer)'
            };

            showToast('Đã chuyển sang góc nhìn: ' + (roleNames[targetRole] || targetRole), 'info');

            applyUserRoleUI();

            if (targetRole === 'CUSTOMER' || targetRole === 'TECHNICIAN' || targetRole === 'STAFF') {
                switchTab('tickets');
            } else {
                switchTab('dashboard');
            }
        }
`;

// Chèn các hàm JS cốt lõi vào ngay sau thẻ <script>
const scriptTagIdx = html.indexOf('<script>');
if (scriptTagIdx !== -1) {
    html = html.slice(0, scriptTagIdx + 8) + '\n' + essentialScriptFunctions + '\n' + html.slice(scriptTagIdx + 8);
    console.log('✔ Đã chèn essentialScriptFunctions vào đầu block <script>!');
}

fs.writeFileSync('src/web-admin/index.html', html, 'utf8');
console.log('--- HOÀN TẤT THÀNH CÔNG! Kích thước file index.html:', html.length, 'bytes ---');

