import fs from 'fs';
import path from 'path';

console.log('--- ĐANG NÂNG CẤP GIAO DIỆN AUTH: HIỆN ĐẠI, TƯƠI SÁNG, RẠCH RÒI ĐĂNG KÝ / ĐĂNG NHẬP ---');

const currentHtml = fs.readFileSync('src/web-admin/index.html', 'utf-8');

// Replace the CSS of #authOverlay and auth-card
const authCssTarget = `        /* AUTH OVERLAY */
        #authOverlay {
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: linear-gradient(135deg, #0f172a 0%, #1e293b 100%);
            z-index: 2000;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }

        .auth-card {
            background: #ffffff;
            width: 100%;
            max-width: 480px;
            border-radius: var(--radius-lg);
            padding: 36px;
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.4);
        }`;

const modernAuthCss = `        /* MODERN BRIGHT SAAS AUTH CONTAINER */
        #authOverlay {
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: radial-gradient(circle at 10% 20%, rgba(37, 99, 235, 0.05) 0%, rgba(241, 245, 249, 0.95) 90%), #f8fafc;
            z-index: 2000;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 24px;
            overflow-y: auto;
        }

        .auth-container {
            width: 100%;
            max-width: 1020px;
            background: #ffffff;
            border-radius: 20px;
            box-shadow: 0 20px 40px -15px rgba(15, 23, 42, 0.1), 0 0 0 1px rgba(226, 232, 240, 0.9);
            display: flex;
            overflow: hidden;
            min-height: 620px;
        }

        /* LEFT HERO PANE */
        .auth-hero-pane {
            width: 440px;
            background: linear-gradient(145deg, #1e293b 0%, #0f172a 100%);
            padding: 40px;
            color: #ffffff;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            position: relative;
        }

        .auth-hero-pane::before {
            content: '';
            position: absolute;
            top: -60px;
            right: -60px;
            width: 200px;
            height: 200px;
            background: radial-gradient(circle, rgba(37, 99, 235, 0.25) 0%, rgba(37, 99, 235, 0) 70%);
            border-radius: 50%;
            pointer-events: none;
        }

        .auth-hero-logo {
            width: 48px;
            height: 48px;
            background: linear-gradient(135deg, #2563eb, #3b82f6);
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #ffffff;
            font-size: 1.35rem;
            box-shadow: 0 8px 16px rgba(37, 99, 235, 0.35);
        }

        .auth-hero-badge {
            background: rgba(255, 255, 255, 0.08);
            border: 1px solid rgba(255, 255, 255, 0.14);
            padding: 6px 14px;
            border-radius: 9999px;
            font-size: 0.72rem;
            color: #93c5fd;
            font-weight: 600;
            display: inline-flex;
            align-items: center;
            letter-spacing: 0.5px;
        }

        .auth-feature-item {
            display: flex;
            gap: 14px;
            align-items: flex-start;
            margin-bottom: 22px;
        }

        .auth-feature-icon {
            width: 36px;
            height: 36px;
            border-radius: 10px;
            background: rgba(255, 255, 255, 0.08);
            border: 1px solid rgba(255, 255, 255, 0.1);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1rem;
            flex-shrink: 0;
        }

        /* RIGHT FORM PANE */
        .auth-form-pane {
            flex: 1;
            padding: 44px 48px;
            display: flex;
            flex-direction: column;
            justify-content: center;
            background: #ffffff;
        }

        /* SEGMENTED SWITCHER */
        .auth-segmented-nav {
            background: #f1f5f9;
            padding: 5px;
            border-radius: 12px;
            display: flex;
            gap: 6px;
            margin-bottom: 28px;
        }

        .segmented-btn {
            flex: 1;
            border: none;
            background: transparent;
            padding: 9px 16px;
            font-size: 0.88rem;
            font-weight: 600;
            color: #64748b;
            border-radius: 8px;
            transition: all 0.2s ease;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .segmented-btn:hover {
            color: #0f172a;
        }

        .segmented-btn.active {
            background: #ffffff;
            color: #2563eb;
            box-shadow: 0 2px 6px rgba(0, 0, 0, 0.06);
        }

        /* DEMO CARDS GRID */
        .demo-roles-box {
            background: #f8fafc;
            border: 1px solid #e2e8f0;
            border-radius: 14px;
            padding: 16px;
            margin-top: 20px;
        }

        .demo-card {
            background: #ffffff;
            border: 1px solid #e2e8f0;
            border-radius: 10px;
            padding: 10px 12px;
            display: flex;
            align-items: center;
            gap: 12px;
            cursor: pointer;
            transition: all 0.15s ease;
        }

        .demo-card:hover {
            border-color: #2563eb;
            transform: translateY(-1px);
            box-shadow: 0 4px 8px rgba(37, 99, 235, 0.08);
            background-color: #eff6ff;
        }

        .demo-icon {
            width: 32px;
            height: 32px;
            border-radius: 8px;
            background: #f1f5f9;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 0.95rem;
            flex-shrink: 0;
        }

        @media (max-width: 900px) {
            .auth-container {
                flex-direction: column;
                max-width: 520px;
            }
            .auth-hero-pane {
                width: 100%;
                padding: 30px;
            }
            .auth-form-pane {
                padding: 30px 24px;
            }
        }`;

// Replace the HTML of #authOverlay
const authHtmlPattern = /<!-- AUTH OVERLAY \(LOGIN \/ REGISTER\) -->[\s\S]*?<!-- APP SIDEBAR -->/;

const modernAuthHtml = `<!-- AUTH OVERLAY (LOGIN / REGISTER) -->
    <div id="authOverlay" style="display: none;">
        <div class="auth-container">
            <!-- LEFT HERO PANE -->
            <div class="auth-hero-pane">
                <div>
                    <div class="d-flex align-items-center gap-3 mb-3">
                        <div class="auth-hero-logo">
                            <i class="fa-solid fa-screwdriver-wrench"></i>
                        </div>
                        <div>
                            <h4 class="fw-bold mb-0 text-white tracking-wide">REPAIRPRO 33</h4>
                            <span class="text-white-50" style="font-size: 0.78rem;">Hệ thống Quản lý Cửa hàng Sửa chữa</span>
                        </div>
                    </div>

                    <div class="auth-hero-badge mb-4">
                        <i class="fa-solid fa-graduation-cap me-2"></i>ĐỒ ÁN QLDACNTT — NHÓM 11 — 23DTHC6
                    </div>

                    <div class="auth-feature-list mt-4">
                        <div class="auth-feature-item">
                            <div class="auth-feature-icon text-info">
                                <i class="fa-solid fa-table-columns"></i>
                            </div>
                            <div>
                                <div class="fw-bold text-white small">Luân chuyển sửa chữa Kanban</div>
                                <div class="text-white-50" style="font-size: 0.76rem;">Tiếp nhận, Chẩn đoán, Sửa chữa, Hoàn thành và Bàn giao 5 bước trực quan.</div>
                            </div>
                        </div>

                        <div class="auth-feature-item">
                            <div class="auth-feature-icon text-warning">
                                <i class="fa-solid fa-boxes-stacked"></i>
                            </div>
                            <div>
                                <div class="fw-bold text-white small">Kho linh kiện & Cảnh báo an toàn</div>
                                <div class="text-white-50" style="font-size: 0.76rem;">Kiểm soát xuất/nhập, cảnh báo chạm mức tồn tối thiểu (MinStockLevel).</div>
                            </div>
                        </div>

                        <div class="auth-feature-item">
                            <div class="auth-feature-icon text-success">
                                <i class="fa-solid fa-qrcode"></i>
                            </div>
                            <div>
                                <div class="fw-bold text-white small">Quyết toán VietQR & Sổ bảo hành</div>
                                <div class="text-white-50" style="font-size: 0.76rem;">Mã VietQR động đúng số tiền, tự động cấp Sổ bảo hành điện tử theo serial.</div>
                            </div>
                        </div>

                        <div class="auth-feature-item">
                            <div class="auth-feature-icon text-primary">
                                <i class="fa-solid fa-shield-halved"></i>
                            </div>
                            <div>
                                <div class="fw-bold text-white small">Phân quyền RBAC & An toàn IDOR</div>
                                <div class="text-white-50" style="font-size: 0.76rem;">Phân tách 4 nhóm vai trò (Admin, Staff, Tech, Khách hàng) chuẩn an toàn.</div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="pt-3 border-top border-white border-opacity-10 d-flex justify-content-between align-items-center">
                    <span class="text-white-50 small"><i class="fa-solid fa-database text-success me-1"></i>SQL Server: RepairShopDB</span>
                    <span class="badge bg-success bg-opacity-25 text-success border border-success border-opacity-25 font-monospace">ONLINE</span>
                </div>
            </div>

            <!-- RIGHT FORM PANE (RẠCH RÒI ĐĂNG NHẬP / ĐĂNG KÝ) -->
            <div class="auth-form-pane">
                <!-- SEGMENTED CONTROLLER -->
                <div class="auth-segmented-nav">
                    <button type="button" class="segmented-btn active" id="tabBtnLogin" onclick="switchAuthView('login')">
                        <i class="fa-solid fa-arrow-right-to-bracket me-2"></i>Đăng Nhập
                    </button>
                    <button type="button" class="segmented-btn" id="tabBtnRegister" onclick="switchAuthView('register')">
                        <i class="fa-solid fa-user-plus me-2"></i>Đăng Ký Khách Hàng
                    </button>
                </div>

                <!-- 1. GIAO DIỆN ĐĂNG NHẬP (LOGIN VIEW) -->
                <div id="authViewLogin">
                    <div class="mb-3">
                        <h5 class="fw-bold text-dark mb-1">Đăng Nhập Cổng Quản Trị & Vận Hành</h5>
                        <p class="text-muted small">Truy cập ca làm việc để quản lý tiếp nhận máy, điều phối kỹ thuật và thanh toán.</p>
                    </div>

                    <form onsubmit="event.preventDefault(); handleLogin();">
                        <div class="mb-3">
                            <label class="form-label small fw-semibold text-secondary">Tên tài khoản / Username</label>
                            <div class="input-group">
                                <span class="input-group-text bg-white border-end-0 text-muted"><i class="fa-regular fa-user"></i></span>
                                <input type="text" id="loginUsername" class="form-control border-start-0 ps-0" placeholder="admin / staff01 / tech01 / khach01" value="admin" required>
                            </div>
                        </div>

                        <div class="mb-3">
                            <div class="d-flex justify-content-between align-items-center mb-1">
                                <label class="form-label small fw-semibold text-secondary mb-0">Mật khẩu</label>
                                <a href="javascript:void(0)" class="text-primary text-decoration-none small" onclick="showToast('Vui lòng liên hệ Quản trị viên (Admin) để cấp lại mật khẩu.', 'info')">Quên mật khẩu?</a>
                            </div>
                            <div class="input-group">
                                <span class="input-group-text bg-white border-end-0 text-muted"><i class="fa-solid fa-lock"></i></span>
                                <input type="password" id="loginPassword" class="form-control border-start-0 border-end-0 ps-0" placeholder="••••••••" value="Abc@12345" required>
                                <button type="button" class="btn btn-outline-light text-muted border border-start-0" onclick="togglePassVisibility('loginPassword', this)">
                                    <i class="fa-regular fa-eye"></i>
                                </button>
                            </div>
                        </div>

                        <button type="submit" class="btn btn-primary w-100 py-2 fw-semibold shadow-sm mb-3" id="btnLoginSubmit">
                            <i class="fa-solid fa-arrow-right-to-bracket me-2"></i>Đăng Nhập Hệ Thống
                        </button>
                    </form>

                    <!-- TRUY CẬP NHANH TÀI KHOẢN MẪU (DEMO ROLES) -->
                    <div class="demo-roles-box">
                        <div class="d-flex align-items-center justify-content-between mb-2">
                            <span class="text-uppercase fw-bold text-muted" style="font-size: 0.68rem; letter-spacing: 0.6px;">
                                <i class="fa-solid fa-bolt text-warning me-1"></i>Truy cập nhanh tài khoản mẫu:
                            </span>
                            <span class="text-muted" style="font-size: 0.68rem;">(Click để đăng nhập tức thì)</span>
                        </div>
                        <div class="row g-2">
                            <div class="col-6">
                                <div class="demo-card" onclick="quickFillAndLogin('admin')">
                                    <div class="demo-icon"><i class="fa-solid fa-crown text-purple"></i></div>
                                    <div class="overflow-hidden">
                                        <div class="fw-bold small text-dark text-truncate">Quản trị viên (Admin)</div>
                                        <div class="text-muted" style="font-size: 0.7rem;">admin / Abc@12345</div>
                                    </div>
                                </div>
                            </div>
                            <div class="col-6">
                                <div class="demo-card" onclick="quickFillAndLogin('staff01')">
                                    <div class="demo-icon"><i class="fa-solid fa-headset text-info"></i></div>
                                    <div class="overflow-hidden">
                                        <div class="fw-bold small text-dark text-truncate">Tiếp nhận & Thu ngân</div>
                                        <div class="text-muted" style="font-size: 0.7rem;">staff01 / Abc@12345</div>
                                    </div>
                                </div>
                            </div>
                            <div class="col-6">
                                <div class="demo-card" onclick="quickFillAndLogin('tech01')">
                                    <div class="demo-icon"><i class="fa-solid fa-wrench text-warning"></i></div>
                                    <div class="overflow-hidden">
                                        <div class="fw-bold small text-dark text-truncate">Kỹ thuật viên (Tech)</div>
                                        <div class="text-muted" style="font-size: 0.7rem;">tech01 / Abc@12345</div>
                                    </div>
                                </div>
                            </div>
                            <div class="col-6">
                                <div class="demo-card" onclick="quickFillAndLogin('khach01')">
                                    <div class="demo-icon"><i class="fa-solid fa-user text-primary"></i></div>
                                    <div class="overflow-hidden">
                                        <div class="fw-bold small text-dark text-truncate">Khách hàng Demo</div>
                                        <div class="text-muted" style="font-size: 0.7rem;">khach01 / Abc@12345</div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="text-center mt-3">
                        <span class="text-muted small">Chưa có tài khoản khách hàng? </span>
                        <a href="javascript:void(0)" class="text-primary fw-semibold small text-decoration-none" onclick="switchAuthView('register')">Đăng ký mới tại đây</a>
                    </div>
                </div>

                <!-- 2. GIAO DIỆN ĐĂNG KÝ (REGISTER VIEW) -->
                <div id="authViewRegister" style="display: none;">
                    <div class="mb-3">
                        <h5 class="fw-bold text-dark mb-1">Đăng Ký Tài Khoản Khách Hàng</h5>
                        <p class="text-muted small">Khởi tạo hồ sơ khách hàng để theo dõi tiến độ sửa máy, hóa đơn và tra cứu sổ bảo hành.</p>
                    </div>

                    <form onsubmit="event.preventDefault(); handleRegister();">
                        <div class="row g-2 mb-2">
                            <div class="col-6">
                                <label class="form-label small fw-semibold text-secondary">Họ và tên *</label>
                                <input type="text" id="regFullName" class="form-control form-control-sm" placeholder="Nguyễn Văn A" required>
                            </div>
                            <div class="col-6">
                                <label class="form-label small fw-semibold text-secondary">Số điện thoại *</label>
                                <input type="tel" id="regPhone" class="form-control form-control-sm" placeholder="0987654321" required>
                            </div>
                        </div>

                        <div class="row g-2 mb-2">
                            <div class="col-6">
                                <label class="form-label small fw-semibold text-secondary">Email liên hệ</label>
                                <input type="email" id="regEmail" class="form-control form-control-sm" placeholder="khachhang@gmail.com">
                            </div>
                            <div class="col-6">
                                <label class="form-label small fw-semibold text-secondary">Địa chỉ</label>
                                <input type="text" id="regAddress" class="form-control form-control-sm" placeholder="TP. Hồ Chí Minh">
                            </div>
                        </div>

                        <div class="row g-2 mb-3">
                            <div class="col-6">
                                <label class="form-label small fw-semibold text-secondary">Tên tài khoản (Username) *</label>
                                <input type="text" id="regUsername" class="form-control form-control-sm" placeholder="khachhangmoi" required>
                            </div>
                            <div class="col-6">
                                <label class="form-label small fw-semibold text-secondary">Mật khẩu *</label>
                                <input type="password" id="regPassword" class="form-control form-control-sm" placeholder="••••••••" required>
                            </div>
                        </div>

                        <div class="p-2 bg-light rounded small text-muted mb-3 border" style="font-size: 0.74rem;">
                            <i class="fa-solid fa-circle-info text-primary me-1"></i>Hệ thống tự động cấp mã khách hàng duy nhất (CustomerCode) và liên kết với tài khoản đăng nhập của bạn.
                        </div>

                        <button type="submit" class="btn btn-success w-100 py-2 fw-semibold shadow-sm mb-3" id="btnRegisterSubmit">
                            <i class="fa-solid fa-user-check me-2"></i>Hoàn Tất Đăng Ký Tài Khoản
                        </button>

                        <div class="text-center">
                            <span class="text-muted small">Đã có tài khoản? </span>
                            <a href="javascript:void(0)" class="text-primary fw-semibold small text-decoration-none" onclick="switchAuthView('login')">
                                Quay lại Đăng nhập
                            </a>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <!-- APP SIDEBAR -->`;

let updatedHtml = currentHtml;

// Replace CSS
if (updatedHtml.includes(authCssTarget)) {
    updatedHtml = updatedHtml.replace(authCssTarget, modernAuthCss);
    console.log('✔ Đã cập nhật CSS Auth Container tươi sáng, hiện đại!');
} else {
    // If target not exact match, replace #authOverlay block
    updatedHtml = updatedHtml.replace(/\/\* AUTH OVERLAY \*\/[\s\S]*?\.auth-card\s*\{[\s\S]*?\}/, modernAuthCss);
    console.log('✔ Đã cập nhật CSS Auth Container qua regex!');
}

// Replace HTML
if (authHtmlPattern.test(updatedHtml)) {
    updatedHtml = updatedHtml.replace(authHtmlPattern, modernAuthHtml);
    console.log('✔ Đã thay thế HTML Auth Overlay rạch ròi 2 chế độ Đăng nhập & Đăng ký!');
} else {
    console.error('Không tìm thấy vùng HTML auth overlay!');
}

// Add JS helper functions for switchAuthView and quickFillAndLogin and togglePassVisibility
const jsTarget = `        function switchAuthTab(tab) {
            if (tab === 'login') {
                document.getElementById('tabBtnLogin').classList.add('active');
                document.getElementById('tabBtnRegister').classList.remove('active');
                document.getElementById('authLoginForm').style.display = 'block';
                document.getElementById('authRegisterForm').style.display = 'none';
            } else {
                document.getElementById('tabBtnLogin').classList.remove('active');
                document.getElementById('tabBtnRegister').classList.add('active');
                document.getElementById('authLoginForm').style.display = 'none';
                document.getElementById('authRegisterForm').style.display = 'block';
            }
        }`;

const newJsFunctions = `        // RẠCH RÒI 2 CHẾ ĐỘ ĐĂNG NHẬP / ĐĂNG KÝ
        function switchAuthView(mode) {
            const btnLogin = document.getElementById('tabBtnLogin');
            const btnReg = document.getElementById('tabBtnRegister');
            const viewLogin = document.getElementById('authViewLogin');
            const viewReg = document.getElementById('authViewRegister');

            if (mode === 'login') {
                btnLogin.classList.add('active');
                btnReg.classList.remove('active');
                viewLogin.style.display = 'block';
                viewReg.style.display = 'none';
            } else {
                btnLogin.classList.remove('active');
                btnReg.classList.add('active');
                viewLogin.style.display = 'none';
                viewReg.style.display = 'block';
            }
        }

        // Backward compatibility
        function switchAuthTab(tab) {
            switchAuthView(tab);
        }

        // One-click Demo Login
        function quickFillAndLogin(user) {
            document.getElementById('loginUsername').value = user;
            document.getElementById('loginPassword').value = 'Abc@12345';
            handleLogin();
        }

        // Toggle Password Visibility
        function togglePassVisibility(inputId, btn) {
            const input = document.getElementById(inputId);
            if (!input) return;
            const icon = btn.querySelector('i');
            if (input.type === 'password') {
                input.type = 'text';
                icon.className = 'fa-regular fa-eye-slash';
            } else {
                input.type = 'password';
                icon.className = 'fa-regular fa-eye';
            }
        }`;

if (updatedHtml.includes(jsTarget)) {
    updatedHtml = updatedHtml.replace(jsTarget, newJsFunctions);
    console.log('✔ Đã cập nhật các hàm JavaScript điều phối Auth!');
} else {
    // Replace switchAuthTab function
    updatedHtml = updatedHtml.replace(/function switchAuthTab\(tab\) \{[\s\S]*?\}\s*\}/, newJsFunctions);
    console.log('✔ Đã thay thế hàm switchAuthTab qua regex!');
}

fs.writeFileSync('src/web-admin/index.html', updatedHtml, 'utf-8');
console.log('✔ Đã lưu tệp src/web-admin/index.html với kích thước:', fs.statSync('src/web-admin/index.html').size, 'bytes');
