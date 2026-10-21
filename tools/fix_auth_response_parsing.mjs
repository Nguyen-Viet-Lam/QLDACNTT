import fs from 'fs';

let html = fs.readFileSync('src/web-admin/index.html', 'utf8');

const targetLoginBlock = `                state.token = res.token;
                state.user = {
                    username: res.username,
                    fullName: res.fullName,
                    role: res.role,
                    customerId: res.customerId
                };

                localStorage.setItem('token', state.token);
                localStorage.setItem('user', JSON.stringify(state.user));

                showToast(\`Đăng nhập thành công! Chào mừng \${state.user.fullName} (\${state.user.role})\`, 'success');`;

const fixedLoginBlock = `                state.token = res.token;
                const uData = res.user || res;
                state.user = {
                    username: uData.username || res.username,
                    fullName: uData.fullName || res.fullName || uData.username || 'Người dùng',
                    role: uData.role || res.role || 'STAFF',
                    customerId: uData.customerId || res.customerId || null
                };

                localStorage.setItem('token', state.token);
                localStorage.setItem('user', JSON.stringify(state.user));

                showToast(\`Đăng nhập thành công! Chào mừng \${state.user.fullName} (\${state.user.role})\`, 'success');`;

const targetRegisterBlock = `                state.token = res.token;
                state.user = {
                    username: res.username,
                    fullName: res.fullName,
                    role: res.role,
                    customerId: res.customerId
                };

                localStorage.setItem('token', state.token);
                localStorage.setItem('user', JSON.stringify(state.user));

                showToast(\`Đăng ký tài khoản khách hàng thành công! Mã KH: \${res.customerCode}\`, 'success');`;

const fixedRegisterBlock = `                state.token = res.token;
                const uData = res.user || res;
                state.user = {
                    username: uData.username || res.username || username,
                    fullName: uData.fullName || res.fullName || fullName,
                    role: uData.role || res.role || 'CUSTOMER',
                    customerId: uData.customerId || res.customerId || null
                };

                localStorage.setItem('token', state.token);
                localStorage.setItem('user', JSON.stringify(state.user));

                showToast(\`Đăng ký tài khoản khách hàng thành công! Chào mừng \${state.user.fullName}\`, 'success');`;

if (html.includes(targetLoginBlock)) {
    html = html.replace(targetLoginBlock, fixedLoginBlock);
    console.log('✔ Đã sửa gán state.user trong handleLogin');
} else {
    console.log('⚠ Không khớp targetLoginBlock');
}

if (html.includes(targetRegisterBlock)) {
    html = html.replace(targetRegisterBlock, fixedRegisterBlock);
    console.log('✔ Đã sửa gán state.user trong handleRegister');
} else {
    console.log('⚠ Không khớp targetRegisterBlock');
}

fs.writeFileSync('src/web-admin/index.html', html, 'utf8');
console.log('Hoàn tất lưu index.html!');
