import fs from 'fs';

let html = fs.readFileSync('src/web-admin/index.html', 'utf8');

// 1. Cập nhật initializeSystem theo vai trò (không ép non-admin gọi loadDashboard)
const oldInit = `async function initializeSystem() {
            await checkDbHealth();
            await loadDashboard();
        }`;

const newInit = `async function initializeSystem() {
            try {
                await checkDbHealth();
            } catch (e) {
                console.warn('Check DB health warning:', e);
            }

            const role = (state.user && state.user.role) ? state.user.role : 'ADMIN';
            console.log('Khởi tạo hệ thống cho vai trò:', role);

            try {
                if (role === 'ADMIN') {
                    await loadDashboard();
                    await loadTickets();
                    await loadInventory();
                } else if (role === 'STAFF') {
                    await loadTickets();
                    await loadCustomers();
                    await loadInventory();
                } else if (role === 'TECHNICIAN') {
                    await loadTickets();
                    await loadInventory();
                } else if (role === 'CUSTOMER') {
                    await loadTickets();
                }
            } catch (err) {
                console.warn('Lỗi tải dữ liệu ca làm việc:', err);
            }
        }`;

if (html.includes(oldInit)) {
    html = html.replace(oldInit, newInit);
    console.log('✔ Đã nâng cấp initializeSystem theo từng vai trò!');
} else {
    console.log('⚠ Không khớp oldInit');
}

// 2. Cập nhật applyUserRoleUI để chuyển tab phù hợp
const targetApplyRole = `// RENDER LẠI SIDEBAR PHÂN QUYỀN RẠCH RÒI CHO TỪNG VAI TRÒ
            renderSidebarForRole(role);`;

const updatedApplyRole = `// RENDER LẠI SIDEBAR PHÂN QUYỀN RẠCH RÒI CHO TỪNG VAI TRÒ
            renderSidebarForRole(role);

            // Chuyển tab mặc định phù hợp vai trò
            if (role === 'ADMIN') {
                switchTab('dashboard');
            } else {
                switchTab('tickets');
            }`;

if (html.includes(targetApplyRole) && !html.includes("if (role === 'ADMIN') {\n                switchTab('dashboard');")) {
    html = html.replace(targetApplyRole, updatedApplyRole);
    console.log('✔ Đã cập nhật applyUserRoleUI tự động switchTab!');
}

// 3. Cập nhật DOMContentLoaded an toàn
const targetDom = `if (state.token && state.user) {
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
            }`;

const updatedDom = `if (state.token && state.user) {
                try {
                    const me = await api('/api/auth/me');
                    state.user.fullName = me.fullName || state.user.fullName;
                    state.user.role = me.role || state.user.role;
                    state.user.customerId = me.customerId !== undefined ? me.customerId : state.user.customerId;
                    toggleViewMode('workspace');
                    await initializeSystem();
                } catch (err) {
                    console.warn('Session check failed, staying on portal:', err);
                    handleLogout(false);
                }
            } else {
                // Khách tham quan: Mặc định hiển thị Cổng dịch vụ khách hàng ZEISS
                toggleViewMode('portal');
            }`;

if (html.includes(targetDom)) {
    html = html.replace(targetDom, updatedDom);
    console.log('✔ Đã cập nhật DOMContentLoaded an toàn');
}

fs.writeFileSync('src/web-admin/index.html', html, 'utf8');
console.log('Hoàn tất lưu file index.html!');

