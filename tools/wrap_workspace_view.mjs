import fs from 'fs';

let html = fs.readFileSync('src/web-admin/index.html', 'utf8');

const targetBeforeSidebar = `    <!-- APP SIDEBAR -->
    <aside class="sidebar" id="appSidebar">`;

const replacementBeforeSidebar = `    <div id="workspaceView" style="display: none;">
        <!-- APP SIDEBAR -->
        <aside class="sidebar" id="appSidebar">`;

const targetAfterMainWrapper = `        </main>
    </div>

    <!-- MODALS SECTION -->`;

const replacementAfterMainWrapper = `        </main>
    </div>
    </div>

    <!-- MODALS SECTION -->`;

if (html.includes(targetBeforeSidebar) && html.includes(targetAfterMainWrapper)) {
    html = html.replace(targetBeforeSidebar, replacementBeforeSidebar);
    html = html.replace(targetAfterMainWrapper, replacementAfterMainWrapper);
    fs.writeFileSync('src/web-admin/index.html', html, 'utf8');
    console.log('✔ Đã bọc chính xác workspaceView quanh sidebar và main-wrapper!');
} else {
    console.error('❌ Không khớp vị trí wrapper');
    console.log('Has targetBeforeSidebar:', html.includes(targetBeforeSidebar));
    console.log('Has targetAfterMainWrapper:', html.includes(targetAfterMainWrapper));
}
