import fs from 'fs';

let html = fs.readFileSync('src/web-admin/index.html', 'utf8');

// 1. Cập nhật showAuthOverlay nhận mode
const oldShowAuth = `function showAuthOverlay() {
            document.getElementById('authOverlay').style.display = 'flex';
        }`;

const newShowAuth = `function showAuthOverlay(mode) {
            const overlay = document.getElementById('authOverlay');
            if (overlay) overlay.style.display = 'flex';
            if (mode) switchAuthView(mode);
        }`;

if (html.includes(oldShowAuth)) {
    html = html.replace(oldShowAuth, newShowAuth);
    console.log('✔ Đã cập nhật showAuthOverlay(mode)');
}

// 2. Cập nhật handleLogout chuyển về portal
const oldLogout = `if (notify) showToast('Đã đăng xuất khỏi hệ thống an toàn.', 'info');
            showAuthOverlay();`;

const newLogout = `if (notify) showToast('Đã đăng xuất khỏi hệ thống an toàn.', 'info');
            toggleViewMode('portal');`;

if (html.includes(oldLogout)) {
    html = html.replace(oldLogout, newLogout);
    console.log('✔ Đã cập nhật handleLogout chuyển về portal');
}

// 3. Thêm nút đóng và click ngoài overlay để đóng Auth Modal
const oldOverlayTag = `<div id="authOverlay" style="display: none;">`;
const newOverlayTag = `<div id="authOverlay" style="display: none;" onclick="if(event.target===this) hideAuthOverlay();">`;

if (html.includes(oldOverlayTag)) {
    html = html.replace(oldOverlayTag, newOverlayTag);
    console.log('✔ Đã thêm click background đóng modal');
}

// Thêm nút close trong auth-form-pane
const oldFormPane = `<div class="auth-form-pane">
                <!-- SEGMENTED CONTROLLER -->`;

const newFormPane = `<div class="auth-form-pane position-relative">
                <button type="button" class="btn-close position-absolute top-0 end-0 m-3" onclick="hideAuthOverlay()" aria-label="Đóng"></button>
                <!-- SEGMENTED CONTROLLER -->`;

if (html.includes(oldFormPane)) {
    html = html.replace(oldFormPane, newFormPane);
    console.log('✔ Đã thêm nút X đóng auth modal');
}

fs.writeFileSync('src/web-admin/index.html', html, 'utf8');
console.log('Hoàn tất polish portal flow!');

