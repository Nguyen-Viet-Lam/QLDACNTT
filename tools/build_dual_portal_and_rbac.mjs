import fs from 'fs';

console.log('--- KHỞI ĐỘNG XÂY DỰNG CỔNG DỊCH VỤ KHÁCH HÀNG & PHÂN QUYỀN RẠCH RÒI ---');

let html = fs.readFileSync('src/web-admin/index.html', 'utf8');

// 1. BỔ SUNG CÁC CSS TƯƠI SÁNG (BRIGHT THEME) CHO PUBLIC PORTAL VÀ PHÂN QUYỀN
const extraBrightStyles = `
        /* === PUBLIC PORTAL BRIGHT STYLES (ẢNH MẪU 1: HUTECH IT EXAM STYLE - SÁNG MÀU) === */
        #publicPortalView {
            background: #f8fafc;
            min-height: 100vh;
            color: #1e293b;
            font-family: 'Inter', sans-serif;
        }

        .portal-nav {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(12px);
            border-bottom: 1px solid rgba(226, 232, 240, 0.9);
            position: sticky;
            top: 0;
            z-index: 1000;
            padding: 14px 0;
            box-shadow: 0 4px 20px -2px rgba(0, 0, 0, 0.03);
        }

        .portal-logo-icon {
            width: 44px;
            height: 44px;
            background: linear-gradient(135deg, #2563eb 0%, #1d4ed8 100%);
            color: white;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.25rem;
            box-shadow: 0 8px 16px -4px rgba(37, 99, 235, 0.35);
        }

        .portal-hero {
            padding: 70px 0 60px;
            background: radial-gradient(circle at 85% 15%, rgba(37, 99, 235, 0.08) 0%, rgba(248, 250, 252, 1) 65%);
            border-bottom: 1px solid #e2e8f0;
        }

        .portal-badge {
            display: inline-flex;
            align-items: center;
            padding: 6px 16px;
            border-radius: 9999px;
            background: #eff6ff;
            color: #1d4ed8;
            font-size: 0.82rem;
            font-weight: 700;
            letter-spacing: 0.6px;
            border: 1px solid rgba(191, 219, 254, 0.9);
            box-shadow: 0 2px 6px rgba(37, 99, 235, 0.06);
        }

        .portal-hero-title {
            font-size: 3.1rem;
            font-weight: 800;
            line-height: 1.15;
            color: #0f172a;
            letter-spacing: -0.03em;
        }

        .portal-hero-title .gradient-text {
            background: linear-gradient(135deg, #2563eb 0%, #0284c7 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        .portal-hero-lead {
            font-size: 1.12rem;
            color: #475569;
            line-height: 1.65;
            max-width: 580px;
        }

        /* Mockup Card Interactive */
        .portal-workspace-card {
            background: #ffffff;
            border-radius: 20px;
            border: 1px solid #e2e8f0;
            box-shadow: 0 25px 50px -12px rgba(15, 23, 42, 0.08), 0 0 0 1px rgba(226, 232, 240, 0.6);
            overflow: hidden;
            transition: all 0.3s ease;
        }

        .portal-workspace-header {
            background: #f8fafc;
            padding: 12px 20px;
            border-bottom: 1px solid #e2e8f0;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .window-dot {
            width: 10px;
            height: 10px;
            border-radius: 50%;
            display: inline-block;
        }
        .dot-red { background: #ef4444; }
        .dot-yellow { background: #f59e0b; }
        .dot-green { background: #10b981; }

        .service-pricing-card {
            background: #ffffff;
            border-radius: 16px;
            border: 1px solid #e2e8f0;
            padding: 24px;
            transition: transform 0.2s ease, box-shadow 0.2s ease;
            box-shadow: 0 4px 12px rgba(15, 23, 42, 0.02);
            height: 100%;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
        }

        .service-pricing-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 16px 30px -8px rgba(37, 99, 235, 0.12);
            border-color: #bfdbfe;
        }

        .service-price-tag {
            font-size: 1.55rem;
            font-weight: 800;
            color: #2563eb;
        }

        .workflow-step-box {
            background: #ffffff;
            border-radius: 16px;
            border: 1px solid #e2e8f0;
            padding: 24px 20px;
            position: relative;
            box-shadow: 0 4px 12px rgba(15, 23, 42, 0.03);
            transition: all 0.2s ease;
        }
        .workflow-step-box:hover {
            border-color: #93c5fd;
            transform: translateY(-2px);
        }

        .workflow-step-num {
            width: 38px;
            height: 38px;
            border-radius: 10px;
            background: #eff6ff;
            color: #2563eb;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 800;
            font-size: 1rem;
            margin-bottom: 14px;
            border: 1px solid #bfdbfe;
        }

        /* Topbar Simulator & Role Nav */
        .rbac-sim-btn {
            font-size: 0.76rem;
            font-weight: 600;
            padding: 4px 10px;
            border-radius: 8px;
            transition: all 0.2s ease;
        }

        .sidebar-role-indicator {
            padding: 10px 14px;
            margin: 0 12px 14px;
            border-radius: 12px;
            font-size: 0.74rem;
            font-weight: 700;
            letter-spacing: 0.5px;
            text-transform: uppercase;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .role-indicator-CUSTOMER {
            background: #eff6ff;
            color: #1d4ed8;
            border: 1px solid #bfdbfe;
        }
        .role-indicator-TECHNICIAN {
            background: #fffbeb;
            color: #b45309;
            border: 1px solid #fde68a;
        }
        .role-indicator-STAFF {
            background: #f0fdf4;
            color: #15803d;
            border: 1px solid #bbf7d0;
        }
        .role-indicator-ADMIN {
            background: #f5f3ff;
            color: #6d28d9;
            border: 1px solid #ddd6fe;
        }
`;

// Chèn extra styles trước </style>
if (!html.includes('portal-nav')) {
    html = html.replace('</style>', extraBrightStyles + '\n    </style>');
    console.log('✔ Đã chèn CSS Public Portal & RBAC Simulator');
}

// 2. TẠO GIAO DIỆN PUBLIC PORTAL (ẢNH MẪU 1: HUTECH IT EXAM STYLE - PHIÊN BẢN SÁNG MÀU)
const publicPortalHtml = `
    <!-- ========================================================================= -->
    <!-- VIEW 1: PUBLIC PORTAL (CỔNG DỊCH VỤ & TRA CỨU KHÁCH HÀNG - SÁNG MÀU)       -->
    <!-- ========================================================================= -->
    <div id="publicPortalView" style="display: block;">
        <!-- TOP NAVBAR -->
        <nav class="portal-nav">
            <div class="container-xxl d-flex align-items-center justify-content-between">
                <!-- LOGO & BRAND -->
                <a href="#hero" class="d-flex align-items-center gap-3 text-decoration-none" onclick="window.scrollTo({top:0, behavior:'smooth'})">
                    <div class="portal-logo-icon">
                        <i class="fa-solid fa-screwdriver-wrench"></i>
                    </div>
                    <div>
                        <div class="fw-bold text-dark fs-5 lh-1 tracking-tight">REPAIRPRO 33</div>
                        <span class="text-muted fw-semibold" style="font-size: 0.72rem; letter-spacing: 0.5px;">KHOA CNTT HUTECH — NHÓM 11 (LV33-001)</span>
                    </div>
                </a>

                <!-- NAV LINKS -->
                <div class="d-none d-lg-flex align-items-center gap-4">
                    <a href="#hero" class="text-dark text-decoration-none fw-semibold small hover-primary">Trang Chủ</a>
                    <a href="#trackingSection" class="text-secondary text-decoration-none fw-semibold small hover-primary"><i class="fa-solid fa-magnifying-glass me-1 text-primary"></i>Tra Cứu Tiến Độ</a>
                    <a href="#pricingSection" class="text-secondary text-decoration-none fw-semibold small hover-primary"><i class="fa-solid fa-tags me-1 text-success"></i>Bảng Giá Dịch Vụ</a>
                    <a href="#bookingSection" class="text-secondary text-decoration-none fw-semibold small hover-primary"><i class="fa-regular fa-calendar-check me-1 text-warning"></i>Đặt Lịch Tiếp Nhận</a>
                    <a href="#workflowSection" class="text-secondary text-decoration-none fw-semibold small hover-primary"><i class="fa-solid fa-list-check me-1 text-info"></i>Quy Trình 5 Bước</a>
                </div>

                <!-- RIGHT ACTION BUTTONS -->
                <div class="d-flex align-items-center gap-2">
                    <button type="button" class="btn btn-outline-secondary btn-sm px-3 fw-semibold rounded-pill" onclick="showAuthOverlay('register')">
                        <i class="fa-solid fa-user-plus me-1"></i>Đăng Ký
                    </button>
                    <button type="button" class="btn btn-primary btn-sm px-3 fw-semibold rounded-pill shadow-sm" onclick="showAuthOverlay('login')" id="btnPortalLogin">
                        <i class="fa-solid fa-arrow-right-to-bracket me-1"></i>Đăng Nhập
                    </button>
                    <button type="button" class="btn btn-dark btn-sm px-3 fw-semibold rounded-pill shadow-sm" id="btnPortalGoWorkspace" style="display: none;" onclick="toggleViewMode('workspace')">
                        <i class="fa-solid fa-laptop-code me-1"></i>Vào Không Gian Làm Việc
                    </button>
                </div>
            </div>
        </nav>

        <!-- HERO SECTION (HUTECH IT EXAM STYLE - BRIGHT THEME) -->
        <section class="portal-hero" id="hero">
            <div class="container-xxl">
                <div class="row align-items-center g-5">
                    <!-- LEFT COLUMN: TITLE & CTA -->
                    <div class="col-lg-6">
                        <div class="portal-badge mb-3">
                            <i class="fa-solid fa-graduation-cap me-2 text-primary"></i>HỆ SINH THÁI SỬA CHỮA — KHOA CNTT HUTECH
                        </div>
                        <h1 class="portal-hero-title mb-3">
                            HỆ THỐNG QUẢN LÝ <span class="gradient-text">CỬA HÀNG SỬA CHỮA</span>
                        </h1>
                        <p class="portal-hero-lead mb-4">
                            Chào mừng bạn đến với nền tảng tiếp nhận thiết bị, theo dõi tiến độ sửa chữa trực tuyến theo thời gian thực, quản lý kho linh kiện minh bạch và tra cứu sổ bảo hành điện tử chính hãng.
                        </p>

                        <div class="d-flex flex-wrap align-items-center gap-3 mb-4">
                            <a href="#trackingSection" class="btn btn-primary px-4 py-2 fw-semibold rounded-pill shadow-sm">
                                <i class="fa-solid fa-magnifying-glass me-2"></i>Bắt Đầu Tra Cứu Ngay
                            </a>
                            <a href="#bookingSection" class="btn btn-outline-primary px-4 py-2 fw-semibold rounded-pill">
                                <i class="fa-regular fa-calendar-plus me-2"></i>Đặt Lịch Tiếp Nhận Máy
                            </a>
                            <button type="button" class="btn btn-light border px-3 py-2 fw-semibold rounded-pill text-secondary" onclick="showAuthOverlay('login')">
                                <i class="fa-solid fa-shield-halved me-1 text-primary"></i>Cổng Quản Trị
                            </button>
                        </div>

                        <!-- STAT CHIPS -->
                        <div class="d-flex align-items-center gap-4 pt-3 border-top">
                            <div>
                                <div class="fw-bold text-dark fs-5">100%</div>
                                <div class="text-muted" style="font-size: 0.78rem;">Linh kiện chính hãng</div>
                            </div>
                            <div class="vr bg-secondary opacity-25"></div>
                            <div>
                                <div class="fw-bold text-dark fs-5">6 - 12 Tháng</div>
                                <div class="text-muted" style="font-size: 0.78rem;">Sổ bảo hành điện tử</div>
                            </div>
                            <div class="vr bg-secondary opacity-25"></div>
                            <div>
                                <div class="fw-bold text-dark fs-5">VietQR</div>
                                <div class="text-muted" style="font-size: 0.78rem;">Quyết toán tự động</div>
                            </div>
                        </div>
                    </div>

                    <!-- RIGHT COLUMN: INTERACTIVE WORKSPACE CARD MOCKUP (NHƯ ẢNH MẪU 1) -->
                    <div class="col-lg-6">
                        <div class="portal-workspace-card">
                            <div class="portal-workspace-header">
                                <div class="d-flex align-items-center gap-2">
                                    <span class="window-dot dot-red"></span>
                                    <span class="window-dot dot-yellow"></span>
                                    <span class="window-dot dot-green"></span>
                                    <span class="text-muted small fw-bold ms-2 tracking-wide font-monospace" style="font-size: 0.78rem;">REPAIRPRO WORKSPACE</span>
                                </div>
                                <span class="badge bg-success bg-opacity-10 text-success border border-success border-opacity-25 px-2 py-1 small font-monospace">
                                    <i class="fa-solid fa-circle text-success me-1" style="font-size: 0.45rem;"></i>ĐANG HOẠT ĐỘNG
                                </span>
                            </div>

                            <div class="p-4">
                                <div class="mb-3">
                                    <label class="form-label small fw-bold text-dark">Tra cứu nhanh trạng thái thiết bị của bạn:</label>
                                    <div class="input-group">
                                        <span class="input-group-text bg-white border-end-0 text-muted"><i class="fa-solid fa-magnifying-glass"></i></span>
                                        <input type="text" id="heroFastSearchInput" class="form-control border-start-0" placeholder="Nhập mã phiếu (VD: PSC2026090001) hoặc SĐT..." value="PSC2026090001">
                                        <button class="btn btn-primary px-3 fw-semibold" type="button" onclick="executePublicTracking(document.getElementById('heroFastSearchInput').value)">
                                            Tra cứu ngay
                                        </button>
                                    </div>
                                    <div class="form-text text-muted small mt-1">
                                        Gợi ý mẫu: <a href="javascript:void(0)" onclick="executePublicTracking('PSC2026090001')" class="text-decoration-none text-primary fw-semibold">PSC2026090001</a> hoặc <a href="javascript:void(0)" onclick="executePublicTracking('PSC2026090002')" class="text-decoration-none text-primary fw-semibold">PSC2026090002</a>
                                    </div>
                                </div>

                                <!-- PREVIEW CONTAINER TRONG HERO -->
                                <div id="heroFastSearchResult">
                                    <div class="p-3 bg-light rounded-3 border">
                                        <div class="d-flex align-items-center justify-content-between mb-2">
                                            <span class="badge bg-primary bg-opacity-10 text-primary fw-bold font-monospace">PSC2026090001</span>
                                            <span class="badge bg-warning bg-opacity-25 text-warning border border-warning border-opacity-25">Đang chẩn đoán</span>
                                        </div>
                                        <div class="fw-bold text-dark">Dell Inspiron 15 (DL-2026-001)</div>
                                        <div class="text-muted small mb-2">Chủ sở hữu: Nguyễn Văn An (090100****)</div>
                                        <div class="p-2 bg-white rounded border small text-secondary">
                                            <i class="fa-solid fa-wrench text-primary me-1"></i>Lỗi: Quạt tản nhiệt bám bụi, CPU nóng 92° C. Keo tản nhiệt MX-4.
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <!-- SECTION 1: TRA CỨU TIẾN ĐỘ & BẢO HÀNH ĐIỆN TỬ -->
        <section class="py-5 bg-white border-bottom" id="trackingSection">
            <div class="container-xxl">
                <div class="text-center max-w-2xl mx-auto mb-4">
                    <span class="badge bg-primary bg-opacity-10 text-primary px-3 py-1 rounded-pill fw-bold small text-uppercase">Tra cứu trực tuyến</span>
                    <h2 class="fw-bold text-dark mt-2">Theo Dõi Tiến Độ Phiếu Sửa Chữa & Sổ Bảo Hành</h2>
                    <p class="text-muted small">Cập nhật minh bạch từng bước từ lúc tiếp nhận, kỹ thuật viên khám máy cho tới khi bàn giao và kích hoạt bảo hành.</p>
                </div>

                <div class="row justify-content-center">
                    <div class="col-lg-8">
                        <div class="card border rounded-4 shadow-sm p-3 mb-4">
                            <div class="input-group input-group-lg">
                                <span class="input-group-text bg-white border-end-0 text-muted"><i class="fa-solid fa-qrcode fs-5"></i></span>
                                <input type="text" id="publicSearchInput" class="form-control border-start-0 fs-6" placeholder="Nhập mã phiếu sửa chữa (PSC...) hoặc số điện thoại khách hàng...">
                                <button class="btn btn-primary px-4 fw-bold" onclick="executePublicTracking(document.getElementById('publicSearchInput').value)">
                                    <i class="fa-solid fa-magnifying-glass me-2"></i>Tra Cứu
                                </button>
                            </div>
                        </div>

                        <!-- KẾT QUẢ TRA CỨU CHI TIẾT -->
                        <div id="publicTrackingContainer"></div>
                    </div>
                </div>
            </div>
        </section>

        <!-- SECTION 2: BẢNG GIÁ DỊCH VỤ NIÊM YẾT CÔNG KHAI -->
        <section class="py-5 bg-light border-bottom" id="pricingSection">
            <div class="container-xxl">
                <div class="text-center max-w-2xl mx-auto mb-5">
                    <span class="badge bg-success bg-opacity-10 text-success px-3 py-1 rounded-pill fw-bold small text-uppercase">Bảng giá minh bạch</span>
                    <h2 class="fw-bold text-dark mt-2">Bảng Giá Dịch Vụ Sửa Chữa Niêm Yết</h2>
                    <p class="text-muted small">Mức giá công khai, không phụ phí phát sinh, cam kết linh kiện chuẩn chất lượng và có phiếu bảo hành theo từng linh kiện.</p>
                </div>

                <div class="row g-4" id="publicServicesGrid">
                    <!-- Dữ liệu dịch vụ sẽ được render tự động từ API /api/public/services -->
                </div>
            </div>
        </section>

        <!-- SECTION 3: ĐẶT LỊCH TIẾP NHẬN MÁY TRỰC TUYẾN -->
        <section class="py-5 bg-white border-bottom" id="bookingSection">
            <div class="container-xxl">
                <div class="row justify-content-center">
                    <div class="col-lg-8">
                        <div class="text-center mb-4">
                            <span class="badge bg-warning bg-opacity-10 text-warning px-3 py-1 rounded-pill fw-bold small text-uppercase">Ưu tiên phục vụ</span>
                            <h2 class="fw-bold text-dark mt-2">Đặt Lịch Tiếp Nhận Sửa Chữa Trực Tuyến</h2>
                            <p class="text-muted small">Quý khách đăng ký thông tin trước để cửa hàng chuẩn bị kỹ thuật viên và linh kiện sẵn sàng khi mang máy đến.</p>
                        </div>

                        <div class="card border rounded-4 shadow-sm p-4 p-md-5">
                            <form onsubmit="handlePublicBookingSubmit(event)">
                                <div class="row g-3 mb-3">
                                    <div class="col-md-6">
                                        <label class="form-label small fw-semibold text-secondary">Họ và tên quý khách *</label>
                                        <input type="text" id="bookFullName" class="form-control" placeholder="Nguyễn Văn A" required>
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label small fw-semibold text-secondary">Số điện thoại liên hệ *</label>
                                        <input type="tel" id="bookPhone" class="form-control" placeholder="0912345678" required>
                                    </div>
                                </div>

                                <div class="row g-3 mb-3">
                                    <div class="col-md-6">
                                        <label class="form-label small fw-semibold text-secondary">Loại thiết bị</label>
                                        <select id="bookDeviceType" class="form-select">
                                            <option value="Điện thoại">Điện thoại di động</option>
                                            <option value="Laptop" selected>Máy tính xách tay (Laptop)</option>
                                            <option value="Máy tính bảng">Máy tính bảng (Tablet)</option>
                                            <option value="Thiết bị khác">Thiết bị điện tử khác</option>
                                        </select>
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label small fw-semibold text-secondary">Hãng sản xuất & Model thiết bị</label>
                                        <input type="text" id="bookModel" class="form-control" placeholder="Ví dụ: Dell XPS 15, iPhone 14 Pro, Asus ROG...">
                                    </div>
                                </div>

                                <div class="row g-3 mb-3">
                                    <div class="col-md-6">
                                        <label class="form-label small fw-semibold text-secondary">Thời gian dự kiến mang máy tới</label>
                                        <input type="text" id="bookPreferredTime" class="form-control" placeholder="Ví dụ: Chiều nay lúc 15:30 hoặc Sáng mai">
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label small fw-semibold text-secondary">Số Serial / IMEI (nếu có)</label>
                                        <input type="text" id="bookSerial" class="form-control" placeholder="Để tra cứu bảo hành nhanh">
                                    </div>
                                </div>

                                <div class="mb-4">
                                    <label class="form-label small fw-semibold text-secondary">Mô tả hiện tượng lỗi / Yêu cầu sửa chữa *</label>
                                    <textarea id="bookFault" class="form-control" rows="3" placeholder="Ví dụ: Máy bật không lên nguồn, chai pin sụt nhanh, vỡ kính cảm ứng, cần tra keo tản nhiệt..." required></textarea>
                                </div>

                                <button type="submit" class="btn btn-primary w-100 py-3 fw-bold rounded-pill shadow-sm" id="btnBookSubmit">
                                    <i class="fa-solid fa-paper-plane me-2"></i>Gửi Yêu Cầu Hẹn Giờ Tiếp Nhận
                                </button>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <!-- SECTION 4: QUY TRÌNH 5 BƯỚC MINH BẠCH -->
        <section class="py-5 bg-light" id="workflowSection">
            <div class="container-xxl">
                <div class="text-center max-w-2xl mx-auto mb-5">
                    <span class="badge bg-info bg-opacity-10 text-info px-3 py-1 rounded-pill fw-bold small text-uppercase">Chuẩn hóa vận hành</span>
                    <h2 class="fw-bold text-dark mt-2">Quy Trình Sửa Chữa 5 Bước Khoa Học</h2>
                    <p class="text-muted small">Mọi công đoạn đều có biên nhận kỹ thuật số, lịch sử trạng thái minh bạch không sợ thất lạc linh kiện.</p>
                </div>

                <div class="row g-3">
                    <div class="col-lg col-md-4 col-sm-6">
                        <div class="workflow-step-box">
                            <div class="workflow-step-num">1</div>
                            <h6 class="fw-bold text-dark mb-1">Tiếp Nhận Máy</h6>
                            <p class="text-muted small mb-0">Lập biên nhận điện tử, ghi nhận tình trạng máy, cấp mã phiếu duy nhất.</p>
                        </div>
                    </div>
                    <div class="col-lg col-md-4 col-sm-6">
                        <div class="workflow-step-box">
                            <div class="workflow-step-num">2</div>
                            <h6 class="fw-bold text-dark mb-1">Chẩn Đoán & Báo Giá</h6>
                            <p class="text-muted small mb-0">Kỹ thuật viên khám máy, báo giá nhân công & linh kiện minh bạch.</p>
                        </div>
                    </div>
                    <div class="col-lg col-md-4 col-sm-6">
                        <div class="workflow-step-box">
                            <div class="workflow-step-num">3</div>
                            <h6 class="fw-bold text-dark mb-1">Tiến Hành Sửa Chữa</h6>
                            <p class="text-muted small mb-0">Xuất linh kiện kho chính hãng, thay thế dưới quy trình kỹ thuật chuẩn.</p>
                        </div>
                    </div>
                    <div class="col-lg col-md-4 col-sm-6">
                        <div class="workflow-step-box">
                            <div class="workflow-step-num">4</div>
                            <h6 class="fw-bold text-dark mb-1">Kiểm Định QC</h6>
                            <p class="text-muted small mb-0">Kiểm tra toàn bộ chức năng, vệ sinh máy và xác nhận hoàn tất.</p>
                        </div>
                    </div>
                    <div class="col-lg col-md-4 col-sm-6">
                        <div class="workflow-step-box">
                            <div class="workflow-step-num">5</div>
                            <h6 class="fw-bold text-dark mb-1">Thanh Toán & Bảo Hành</h6>
                            <p class="text-muted small mb-0">Thanh toán VietQR động đúng số tiền, kích hoạt Sổ bảo hành điện tử.</p>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <!-- FOOTER -->
        <footer class="py-4 bg-white border-top">
            <div class="container-xxl d-flex flex-column flex-md-row align-items-center justify-content-between gap-3 text-muted small">
                <div>
                    <strong>REPAIRPRO 33</strong> — Đồ án Quản lý Dự án CNTT (Mã đề tài: LV33-001)
                    <div style="font-size: 0.76rem;">Nhóm 11 — Lớp 23DTHC6 — Khoa Công nghệ Thông tin, Đại học HUTECH</div>
                </div>
                <div class="text-md-end">
                    <span>Sinh viên thực hiện: Nguyễn Viết Lãm (Leader), Trần Ngọc Lợi, Nguyễn Đại Kỳ</span>
                </div>
            </div>
        </footer>
    </div>
    <!-- END VIEW 1: PUBLIC PORTAL -->
`;

// Chèn publicPortalHtml ngay sau <body ...>
if (!html.includes('id="publicPortalView"')) {
    html = html.replace('<body>', '<body>\n' + publicPortalHtml);
    console.log('✔ Đã chèn Public Portal View');
}

// 3. BỌC WORKSPACE VIEW BÊN TRONG <div id="workspaceView" style="display: none;">
if (!html.includes('id="workspaceView"')) {
    html = html.replace('<div class="admin-wrapper" id="adminAppWrapper">', '<div id="workspaceView" style="display: none;">\n    <div class="admin-wrapper" id="adminAppWrapper">');
    // Tìm thẻ đóng của admin-wrapper
    html = html.replace('</main>\n    </div>\n</div>', '</main>\n    </div>\n</div>\n</div>');
    console.log('✔ Đã bọc Workspace View trong #workspaceView');
}

// 4. BỔ SUNG NÚT VỀ TRANG CHỦ VÀ BỘ MÔ PHỎNG VAI TRÒ (RBAC SIMULATOR BAR) VÀO TOPBAR
const enhancedTopNavbar = `
            <div class="d-flex align-items-center gap-3">
                <button type="button" class="btn btn-outline-primary btn-sm rounded-pill fw-semibold" onclick="toggleViewMode('portal')" title="Quay ra Cổng thông tin & tra cứu khách hàng">
                    <i class="fa-solid fa-arrow-left me-1"></i>Xem Cổng Dịch Vụ
                </button>
                <h5 class="fw-bold mb-0 text-dark" id="pageTitle">Không Gian Làm Việc</h5>
                <span class="db-badge-online d-none d-md-inline-flex">
                    <span class="pulse-dot"></span>
                    <span id="dbStatusBadge">SQL Server: ONLINE</span>
                </span>
            </div>

            <!-- BỘ MÔ PHỎNG VAI TRÒ NHANH (RBAC SIMULATOR) CHO NGƯỜI CHẤM ĐỒ ÁN -->
            <div class="d-flex align-items-center gap-2">
                <div class="d-none d-xl-flex align-items-center p-1 bg-light rounded-pill border">
                    <span class="text-muted fw-bold px-2" style="font-size: 0.68rem; letter-spacing: 0.5px;">GÓC NHÌN:</span>
                    <button type="button" class="btn btn-sm py-1 px-2 rounded-pill rbac-sim-btn fw-bold text-purple" onclick="simulateRole('ADMIN')" title="Xem với quyền Quản trị viên">
                        <i class="fa-solid fa-crown me-1"></i>Admin
                    </button>
                    <button type="button" class="btn btn-sm py-1 px-2 rounded-pill rbac-sim-btn fw-bold text-success" onclick="simulateRole('STAFF')" title="Xem với quyền Lễ tân Tiếp nhận">
                        <i class="fa-solid fa-headset me-1"></i>Staff
                    </button>
                    <button type="button" class="btn btn-sm py-1 px-2 rounded-pill rbac-sim-btn fw-bold text-warning" onclick="simulateRole('TECHNICIAN')" title="Xem với quyền Kỹ thuật viên">
                        <i class="fa-solid fa-wrench me-1"></i>Tech
                    </button>
                    <button type="button" class="btn btn-sm py-1 px-2 rounded-pill rbac-sim-btn fw-bold text-primary" onclick="simulateRole('CUSTOMER')" title="Xem với quyền Khách hàng">
                        <i class="fa-solid fa-user me-1"></i>Khách
                    </button>
                </div>
`;

if (html.includes('<h5 class="fw-bold mb-0 text-dark" id="pageTitle">')) {
    html = html.replace(/<header class="top-navbar">\s*<div class="d-flex align-items-center gap-3">[\s\S]*?<div class="d-flex align-items-center gap-3">/, `<header class="top-navbar">\n` + enhancedTopNavbar + `\n            <div class="d-flex align-items-center gap-3">`);
    console.log('✔ Đã cập nhật Topbar với RBAC Simulator Bar và nút Về Cổng Dịch Vụ!');
}

// 5. THÊM CÁC HÀM JAVASCRIPT ĐIỀU PHỐI PUBLIC PORTAL, RBAC SIDEBAR VÀ SIMULATION
const portalAndRbacJs = `
        // =========================================================================
        // ĐIỀU PHỐI CHUYỂN ĐỔI GIAO DIỆN (PUBLIC PORTAL <-> WORKSPACE)
        // =========================================================================
        function toggleViewMode(mode) {
            const portalView = document.getElementById('publicPortalView');
            const wsView = document.getElementById('workspaceView');
            const btnGoWs = document.getElementById('btnPortalGoWorkspace');
            const btnLogin = document.getElementById('btnPortalLogin');

            if (mode === 'portal') {
                if (portalView) portalView.style.display = 'block';
                if (wsView) wsView.style.display = 'none';
                window.scrollTo({ top: 0, behavior: 'smooth' });
                loadPublicServices();

                // Cập nhật trạng thái nút đăng nhập trên portal
                if (state.token && state.user) {
                    if (btnGoWs) {
                        btnGoWs.style.display = 'inline-block';
                        btnGoWs.innerHTML = '<i class="fa-solid fa-laptop-code me-1"></i>Vào Workspace (' + state.user.role + ')';
                    }
                    if (btnLogin) btnLogin.style.display = 'none';
                } else {
                    if (btnGoWs) btnGoWs.style.display = 'none';
                    if (btnLogin) btnLogin.style.display = 'inline-block';
                }
            } else {
                if (!state.token || !state.user) {
                    showAuthOverlay('login');
                    return;
                }
                if (portalView) portalView.style.display = 'none';
                if (wsView) wsView.style.display = 'block';
                applyUserRoleUI();
            }
        }

        // =========================================================================
        // TRA CỨU TIẾN ĐỘ CÔNG KHAI DÀNH CHO KHÁCH HÀNG (LIVE PUBLIC TRACKING)
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
                container.innerHTML = '<div class="text-center py-4 text-muted"><span class="spinner-border spinner-border-sm me-2"></span>Đang truy vấn cơ sở dữ liệu...</div>';
            }

            try {
                const res = await fetch(API_BASE + '/api/public/track?query=' + encodeURIComponent(q));
                if (!res.ok) throw new Error('Không thể tra cứu thông tin phiếu');
                const list = await res.json();

                if (!list || list.length === 0) {
                    const noResultHtml = '<div class="alert alert-warning border text-center p-4 rounded-3 shadow-sm">' +
                        '<i class="fa-solid fa-triangle-exclamation fs-3 text-warning mb-2 d-block"></i>' +
                        '<strong>Không tìm thấy phiếu sửa chữa nào!</strong>' +
                        '<p class="mb-0 small text-muted">Vui lòng kiểm tra lại mã phiếu (ví dụ: PSC2026090001, TICK0003) hoặc số điện thoại của bạn.</p>' +
                        '</div>';
                    if (container) container.innerHTML = noResultHtml;
                    if (heroResult) heroResult.innerHTML = noResultHtml;
                    return;
                }

                // Render kết quả tìm thấy
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
                                    <i class="fa-solid fa-shield-halved me-1"></i>Bảo hành chính hãng
                                </span>
                            </div>
                        </div>
                    \`;
                });

                if (container) container.innerHTML = htmlResults;
                if (heroResult) {
                    heroResult.innerHTML = htmlResults;
                }
            } catch (err) {
                console.error(err);
                if (container) container.innerHTML = '<div class="alert alert-danger">Lỗi khi kết nối hệ thống tra cứu: ' + err.message + '</div>';
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
                                    <p class="text-muted small mb-3">\${s.description || 'Dịch vụ sửa chữa tiêu chuẩn kỹ thuật cao, lấy liền trong ngày.'}</p>
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
            if (faultInput) {
                faultInput.value = 'Yêu cầu dịch vụ: ' + serviceName;
            }
            const bookingSection = document.getElementById('bookingSection');
            if (bookingSection) {
                bookingSection.scrollIntoView({ behavior: 'smooth' });
            }
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

                // Tự động điền vào khung tra cứu và hiển thị
                executePublicTracking(data.ticketCode);
                const trackingSection = document.getElementById('trackingSection');
                if (trackingSection) {
                    trackingSection.scrollIntoView({ behavior: 'smooth' });
                }

                // Reset form
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
        // PHÂN QUYỀN RẠCH RÒI SIDEBAR MENU CHO TỪNG VAI TRÒ (RBAC RENDERER)
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
                    <div class="sidebar-section-title">Dịch Vụ Cá Nhân</div>
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
                    <div class="sidebar-section-title">Hỗ Trợ & Cổng Dịch Vụ</div>
                    <a href="#" class="nav-link" onclick="toggleViewMode('portal')">
                        <i class="fa-solid fa-house-chimney text-secondary"></i>
                        <span>Về Trang Chủ Dịch Vụ</span>
                    </a>
                \`;
            } else if (role === 'TECHNICIAN') {
                html = \`
                    <div class="sidebar-role-indicator role-indicator-TECHNICIAN">
                        <i class="fa-solid fa-wrench"></i> BÀN THAO TÁC KỸ THUẬT
                    </div>
                    <div class="sidebar-section-title">Kỹ Thuật Sửa Chữa</div>
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
                        <span>Về Trang Chủ Dịch Vụ</span>
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
                        <span>Điều phối phiếu sửa chữa</span>
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
                        <span>Cấp sổ bảo hành điện tử</span>
                    </a>
                    <div class="sidebar-section-title">Vật Tư & Cổng Dịch Vụ</div>
                    <a href="#" class="nav-link" onclick="switchTab('inventory')">
                        <i class="fa-solid fa-boxes-stacked text-warning"></i>
                        <span>Kho linh kiện</span>
                    </a>
                    <a href="#" class="nav-link" onclick="toggleViewMode('portal')">
                        <i class="fa-solid fa-house-chimney text-secondary"></i>
                        <span>Về Trang Chủ Dịch Vụ</span>
                    </a>
                \`;
            } else {
                // ADMIN - ĐẦY ĐỦ CÁC PHÂN HỆ QUẢN TRỊ CAO CẤP PHÂN NHÓM RÕ RÀNG
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
        // MÔ PHỎNG VAI TRÒ NHANH (RBAC SIMULATOR) CHO NGƯỜI CHẤM ĐỒ ÁN
        // =========================================================================
        function simulateRole(targetRole) {
            if (!state.user) {
                state.user = { username: 'demo', fullName: 'Người Thử Nghiệm', role: targetRole };
            }
            state.user.role = targetRole;

            const roleNames = {
                'ADMIN': 'Quản Trị Viên Toàn Quyền',
                'STAFF': 'Nhân Viên Tiếp Nhận & Thu Ngân',
                'TECHNICIAN': 'Kỹ Thuật Viên Sửa Chữa',
                'CUSTOMER': 'Khách Hàng Tra Cứu'
            };

            showToast('Đã chuyển đổi góc nhìn sang vai trò: ' + (roleNames[targetRole] || targetRole), 'info');

            // Cập nhật giao diện
            applyUserRoleUI();

            // Chuyển tab phù hợp
            if (targetRole === 'CUSTOMER') {
                switchTab('tickets');
            } else if (targetRole === 'TECHNICIAN') {
                switchTab('tickets');
            } else if (targetRole === 'STAFF') {
                switchTab('tickets');
            } else {
                switchTab('dashboard');
            }
        }
`;

// Chèn các hàm JS vào script tag
if (!html.includes('toggleViewMode')) {
    html = html.replace('function applyUserRoleUI() {', portalAndRbacJs + '\n        function applyUserRoleUI() {');
    console.log('✔ Đã chèn các hàm Portal & RBAC Simulation');
}

// Cập nhật lại applyUserRoleUI để gọi renderSidebarForRole(role)
const oldApplyRoleBlock = `function applyUserRoleUI() {
            if (!state.user) return;
            const role = state.user.role;
            const name = state.user.fullName || state.user.username;

            document.getElementById('navUserName').textContent = name;
            document.getElementById('sideUserName').textContent = name;
            document.getElementById('navUserRole').textContent = role;
            document.getElementById('sideUserRole').textContent = role;
            document.getElementById('navUserRole').className = \`badge badge-role-\${role}\`;
            document.getElementById('sideUserRole').className = \`badge badge-role-\${role}\`;
            document.getElementById('navAvatar').textContent = name.charAt(0).toUpperCase();`;

const newApplyRoleBlock = `function applyUserRoleUI() {
            if (!state.user) return;
            const role = state.user.role || 'STAFF';
            const name = state.user.fullName || state.user.username || 'Người dùng';

            const elNavName = document.getElementById('navUserName');
            if (elNavName) elNavName.textContent = name;
            const elSideName = document.getElementById('sideUserName');
            if (elSideName) elSideName.textContent = name;

            const elNavRole = document.getElementById('navUserRole');
            if (elNavRole) {
                elNavRole.textContent = role;
                elNavRole.className = \`badge badge-role-\${role}\`;
            }
            const elSideRole = document.getElementById('sideUserRole');
            if (elSideRole) {
                elSideRole.textContent = role;
                elSideRole.className = \`badge badge-role-\${role}\`;
            }

            const elAvatar = document.getElementById('navAvatar');
            if (elAvatar) elAvatar.textContent = name.charAt(0).toUpperCase();

            // RENDER LẠI SIDEBAR PHÂN QUYỀN RẠCH RÒI CHO TỪNG VAI TRÒ
            renderSidebarForRole(role);`;

if (html.includes(oldApplyRoleBlock)) {
    html = html.replace(oldApplyRoleBlock, newApplyRoleBlock);
    console.log('✔ Đã nâng cấp applyUserRoleUI tự động render sidebar theo vai trò!');
}

// Cập nhật DOMContentLoaded khởi tạo hệ thống
const oldDomLoaded = `window.addEventListener('DOMContentLoaded', async () => {
            if (state.token && state.user) {
                try {
                    const me = await api('/api/auth/me');
                    state.user.fullName = me.fullName || state.user.fullName;
                    state.user.role = me.role || state.user.role;
                    applyUserRoleUI();
                    await initializeSystem();
                } catch (err) {
                    showAuthOverlay();
                }
            } else {
                showAuthOverlay();
            }
        });`;

const newDomLoaded = `window.addEventListener('DOMContentLoaded', async () => {
            // Khởi tạo bảng giá trên Public Portal
            loadPublicServices();

            if (state.token && state.user) {
                try {
                    const me = await api('/api/auth/me');
                    state.user.fullName = me.fullName || state.user.fullName;
                    state.user.role = me.role || state.user.role;
                    state.user.customerId = me.customerId !== undefined ? me.customerId : state.user.customerId;
                    toggleViewMode('workspace');
                    await initializeSystem();
                } catch (err) {
                    toggleViewMode('portal');
                }
            } else {
                // Khách chưa đăng nhập: Mặc định hiển thị Public Portal cực đẹp
                toggleViewMode('portal');
            }
        });`;

if (html.includes(oldDomLoaded)) {
    html = html.replace(oldDomLoaded, newDomLoaded);
    console.log('✔ Đã cập nhật DOMContentLoaded hiển thị Public Portal mặc định!');
}

// Cập nhật handleLogin và handleRegister để chuyển vào Workspace
if (html.includes('hideAuthOverlay();\n                applyUserRoleUI();')) {
    html = html.replace('hideAuthOverlay();\n                applyUserRoleUI();', 'hideAuthOverlay();\n                toggleViewMode(\'workspace\');');
    console.log('✔ Đã cập nhật handleLogin/Register gọi toggleViewMode(workspace)');
}

fs.writeFileSync('src/web-admin/index.html', html, 'utf8');
console.log('--- HOÀN TẤT CẬP NHẬT src/web-admin/index.html --- Kích thước:', html.length, 'bytes');

