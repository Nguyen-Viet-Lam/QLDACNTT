import http from 'k6/http';
import { check, sleep, group } from 'k6';
import { Trend, Rate } from 'k6/metrics';

/* =====================================================================
   DỰ ÁN: Hệ thống Quản lý Cửa hàng Sửa chữa - LV33-001 (Nhóm 11)
   Mã task Jira: MBA-76
   Nhiệm vụ: Kịch bản kiểm thử tải (Load Test) và đo lường thời gian đáp ứng API
   Phụ trách: Nguyễn Đại Kỳ (UI/QA Tester Lead)
   
   Tiêu chuẩn kỹ thuật kiểm thử (SLA / Thresholds):
   - Thời gian đáp ứng 95% request (p95) < 500ms
   - Tỷ lệ lỗi (Error Rate) < 1% (0.01)
   - Quy mô tải: Tăng dần từ 10 đến 50 người dùng đồng thời (Virtual Users)
   ===================================================================== */

// Custom metrics
const loginDuration = new Trend('custom_login_duration');
const dashboardDuration = new Trend('custom_dashboard_duration');
const costCalcDuration = new Trend('custom_cost_calculation_duration');
const warrantySearchDuration = new Trend('custom_warranty_search_duration');
const failureRate = new Rate('custom_failure_rate');

export const options = {
    stages: [
        { duration: '30s', target: 10 },  // Ramp-up nhẹ 10 VUs
        { duration: '1m',  target: 50 },  // Đạt mức tải tiêu chuẩn 50 VUs đồng thời
        { duration: '30s', target: 50 },  // Duy trì tải đo độ ổn định
        { duration: '20s', target: 0 },   // Ramp-down xả tải
    ],
    thresholds: {
        http_req_duration: ['p(95)<500'], // 95% requests phải hoàn thành dưới 500ms
        http_req_failed: ['rate<0.01'],   // Tỷ lệ request lỗi không vượt quá 1%
        custom_failure_rate: ['rate<0.01'],
    },
};

const BASE_URL = __ENV.API_BASE_URL || 'http://localhost:5055';

export default function () {
    let sessionToken = '';

    // ==========================================
    // 1. Kiểm thử Tải API Đăng nhập (Auth Login)
    // ==========================================
    group('01_Auth_Login', function () {
        const payload = JSON.stringify({
            username: 'staff',
            password: '123456',
        });
        const params = {
            headers: { 'Content-Type': 'application/json' },
            tags: { name: 'POST /api/auth/login' },
        };

        const res = http.post(`${BASE_URL}/api/auth/login`, payload, params);
        loginDuration.add(res.timings.duration);

        const isSuccess = check(res, {
            'Login status is 200': (r) => r.status === 200,
            'Token returned': (r) => r.json('token') !== undefined,
        });

        failureRate.add(!isSuccess);
        if (isSuccess) {
            sessionToken = res.json('token');
        }
    });

    sleep(1);

    const authHeaders = {
        headers: {
            'X-Session-Token': sessionToken,
            'Accept': 'application/json',
        },
    };

    // ==========================================
    // 2. Kiểm thử Tải API Dashboard Summary
    // ==========================================
    group('02_Dashboard_Summary', function () {
        const res = http.get(`${BASE_URL}/api/dashboard/summary`, authHeaders);
        dashboardDuration.add(res.timings.duration);

        const isSuccess = check(res, {
            'Dashboard status is 200': (r) => r.status === 200,
            'Total tickets exists': (r) => r.json('totalTickets') !== undefined,
            'Response under 300ms': (r) => r.timings.duration < 300,
        });

        failureRate.add(!isSuccess);
    });

    sleep(1);

    // ==========================================
    // 3. Kiểm thử Tải API Tính chi phí phiếu (Cost Calculation)
    // ==========================================
    group('03_Ticket_Cost_Calculation', function () {
        const res = http.get(`${BASE_URL}/api/tickets/PSC2026090001/cost`, authHeaders);
        costCalcDuration.add(res.timings.duration);

        const isSuccess = check(res, {
            'Cost calculation status is 200': (r) => r.status === 200,
            'Grand total is calculated': (r) => r.json('grandTotal') !== undefined,
        });

        failureRate.add(!isSuccess);
    });

    sleep(1);

    // ==========================================
    // 4. Kiểm thử Tải Tra cứu bảo hành điện tử (Warranty Search)
    // ==========================================
    group('04_Warranty_Search', function () {
        const res = http.get(`${BASE_URL}/api/warranties/search?serial=IP11-64GB-VN`, authHeaders);
        warrantySearchDuration.add(res.timings.duration);

        const isSuccess = check(res, {
            'Warranty search status is 200': (r) => r.status === 200,
            'Data array returned': (r) => Array.isArray(r.json('data')),
        });

        failureRate.add(!isSuccess);
    });

    sleep(2);
}
