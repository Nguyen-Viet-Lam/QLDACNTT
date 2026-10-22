import fs from 'fs';
import path from 'path';
import JSZip from 'jszip';

function escapeXml(str) {
  if (!str) return '';
  return String(str)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&apos;');
}

function pXml(text, opts = {}) {
  const pStyle = opts.pStyle ? `<w:pStyle w:val="${opts.pStyle}"/>` : '';
  const pageBreak = opts.pageBreak ? '<w:pageBreakBefore/>' : '';
  const jc = opts.jc ? `<w:jc w:val="${opts.jc}"/>` : '<w:jc w:val="both"/>';
  const before = opts.before ?? 70;
  const after = opts.after ?? 70;
  const sz = opts.sz ?? 26; // 13pt
  const bold = opts.bold ? '<w:b/><w:bCs/>' : '<w:b w:val="0"/><w:bCs w:val="0"/>';
  const italic = opts.italic ? '<w:i/><w:iCs/>' : '<w:i w:val="0"/><w:iCs w:val="0"/>';
  const color = opts.color ? `<w:color w:val="${opts.color}"/>` : '<w:color w:val="auto"/>';

  return `<w:p><w:pPr>${pStyle}${pageBreak}<w:spacing w:before="${before}" w:after="${after}" w:line="312" w:lineRule="auto"/>${jc}<w:rPr><w:rFonts w:hint="default" w:ascii="Times New Roman" w:hAnsi="Times New Roman" w:cs="Times New Roman"/>${color}<w:sz w:val="${sz}"/><w:szCs w:val="${sz}"/></w:rPr></w:pPr><w:r><w:rPr><w:rFonts w:hint="default" w:ascii="Times New Roman" w:hAnsi="Times New Roman" w:eastAsia="Times New Roman" w:cs="Times New Roman"/>${bold}${italic}${color}<w:sz w:val="${sz}"/><w:szCs w:val="${sz}"/></w:rPr><w:t xml:space="preserve">${escapeXml(text)}</w:t></w:r></w:p>`;
}

function tableXml(headers, rows, colWidths = []) {
  let xml = `<w:tbl><w:tblPr><w:tblW w:w="0" w:type="auto"/><w:jc w:val="center"/><w:tblBorders><w:top w:val="single" w:sz="6" w:space="0" w:color="1F4E79"/><w:bottom w:val="single" w:sz="6" w:space="0" w:color="1F4E79"/><w:insideH w:val="single" w:sz="4" w:space="0" w:color="D9D9D9"/><w:insideV w:val="single" w:sz="4" w:space="0" w:color="D9D9D9"/></w:tblBorders><w:tblCellMar><w:top w:w="120" w:type="dxa"/><w:bottom w:w="120" w:type="dxa"/><w:left w:w="140" w:type="dxa"/><w:right w:w="140" w:type="dxa"/></w:tblCellMar></w:tblPr>`;

  if (colWidths.length > 0) {
    xml += '<w:tblGrid>';
    colWidths.forEach(w => { xml += `<w:gridCol w:w="${w}"/>`; });
    xml += '</w:tblGrid>';
  }

  // Header
  xml += '<w:tr><w:trPr><w:tblHeader/><w:cantSplit/></w:trPr>';
  headers.forEach((h, idx) => {
    const wAttr = colWidths[idx] ? `<w:tcW w:w="${colWidths[idx]}" w:type="dxa"/>` : '<w:tcW w:w="0" w:type="auto"/>';
    xml += `<w:tc><w:tcPr>${wAttr}<w:shd w:val="clear" w:color="auto" w:fill="1F4E79"/><w:vAlign w:val="center"/></w:tcPr><w:p><w:pPr><w:spacing w:before="60" w:after="60"/><w:jc w:val="center"/><w:rPr><w:rFonts w:ascii="Times New Roman" w:hAnsi="Times New Roman" w:cs="Times New Roman"/><w:b/><w:bCs/><w:color w:val="FFFFFF"/><w:sz w:val="21"/><w:szCs w:val="21"/></w:rPr></w:pPr><w:r><w:rPr><w:rFonts w:ascii="Times New Roman" w:hAnsi="Times New Roman" w:eastAsia="Times New Roman" w:cs="Times New Roman"/><w:b/><w:bCs/><w:color w:val="FFFFFF"/><w:sz w:val="21"/><w:szCs w:val="21"/></w:rPr><w:t xml:space="preserve">${escapeXml(h)}</w:t></w:r></w:p></w:tc>`;
  });
  xml += '</w:tr>';

  // Rows
  rows.forEach((row, rIdx) => {
    const isAlt = rIdx % 2 === 1;
    const fill = isAlt ? 'F2F5F9' : 'FFFFFF';
    xml += '<w:tr><w:trPr><w:cantSplit/></w:trPr>';
    row.forEach((cell, cIdx) => {
      const wAttr = colWidths[cIdx] ? `<w:tcW w:w="${colWidths[cIdx]}" w:type="dxa"/>` : '<w:tcW w:w="0" w:type="auto"/>';
      const isCenter = cIdx === 0 || (row.length <= 6 && (cIdx === 1 || cIdx === 4));
      const jc = isCenter ? 'center' : 'left';
      xml += `<w:tc><w:tcPr>${wAttr}<w:shd w:val="clear" w:color="auto" w:fill="${fill}"/><w:vAlign w:val="center"/></w:tcPr><w:p><w:pPr><w:spacing w:before="50" w:after="50" w:line="260" w:lineRule="auto"/><w:jc w:val="${jc}"/><w:rPr><w:rFonts w:ascii="Times New Roman" w:hAnsi="Times New Roman" w:cs="Times New Roman"/><w:color w:val="000000"/><w:sz w:val="20"/><w:szCs w:val="20"/></w:rPr></w:pPr><w:r><w:rPr><w:rFonts w:ascii="Times New Roman" w:hAnsi="Times New Roman" w:eastAsia="Times New Roman" w:cs="Times New Roman"/><w:color w:val="000000"/><w:sz w:val="20"/><w:szCs w:val="20"/></w:rPr><w:t xml:space="preserve">${escapeXml(String(cell))}</w:t></w:r></w:p></w:tc>`;
    });
    xml += '</w:tr>';
  });

  xml += '</w:tbl>';
  return xml;
}

async function generateCompleteHoSoDocx() {
  const templatePath = 'link github jira.docx';
  console.log(`Đang đọc mẫu docx: ${templatePath}...`);
  const buf = fs.readFileSync(templatePath);
  const zip = await JSZip.loadAsync(buf);

  let bXml = '';

  // Title Header
  bXml += pXml('HỒ SƠ BẢO VỆ DỰ ÁN & MINH CHỨNG CÔNG CỤ QUẢN TRỊ', { bold: true, sz: 32, jc: 'center', color: '1F4E79', before: 200, after: 80 });
  bXml += pXml('ĐỀ TÀI: HỆ THỐNG QUẢN LÝ TỔNG THỂ CHO CỬA HÀNG SỬA CHỮA — LV33-001', { bold: true, sz: 26, jc: 'center', color: '2F5597', before: 50, after: 120 });
  bXml += pXml('Học phần: Quản lý Dự án Công nghệ Thông tin (QLDACNTT) — Lớp 23DTHC6 — Nhóm 11', { italic: true, sz: 24, jc: 'center', color: '595959', before: 50, after: 200 });

  // I. Thành viên nhóm
  bXml += pXml('I. THÔNG TIN NHÓM THỰC HIỆN & PHÂN CÔNG VAI TRÒ', { bold: true, sz: 26, color: '1F4E79', before: 160, after: 80 });
  const memH = ['STT', 'Họ và tên', 'Mã số sinh viên', 'Vai trò dự án', 'Email liên hệ', 'Tỷ lệ đóng góp'];
  const memR = [
    ['1', 'Nguyễn Viết Lãm', '2380601183', 'Nhóm trưởng / PM / Backend Lead / DevOps', 'lamnguyenadc1@gmail.com', '100%'],
    ['2', 'Trần Ngọc Lợi', '2380601292', 'Business Analyst / Database & SQL Lead', 'loitran.2380601292@gmail.com', '100%'],
    ['3', 'Nguyễn Đại Kỳ', '2380601178', 'UI/UX Designer / QA Tester Lead', 'kynguyen.2380601178@gmail.com', '100%']
  ];
  bXml += tableXml(memH, memR, [600, 2200, 1600, 2600, 2600, 1200]);

  // II. Đường dẫn trực tuyến
  bXml += pXml('II. CÁC ĐƯỜNG DẪN MINH CHỨNG TRỰC TUYẾN CHÍNH THỨC', { bold: true, sz: 26, color: '1F4E79', before: 200, after: 80 });
  const linkH = ['Hệ thống công cụ', 'Địa chỉ truy cập (URL)', 'Tài khoản / Quyền', 'Mục đích & Nội dung minh chứng'];
  const linkR = [
    ['GitHub Repository', 'https://github.com/Nguyen-Viet-Lam/QLDACNTT', 'Public Repo', 'Toàn bộ mã nguồn C# Backend Minimal API, CSDL SQL Server 13 bảng 3NF, Web Admin SPA, 23 Unit Tests, CI/CD Actions.'],
    ['Jira Software Cloud', 'https://lamnguyenadc1.atlassian.net/jira/software/projects/MBA/boards/2', 'lamnguyenadc1@gmail.com (Scrum Master)', 'Project Key: MBA, Quản lý toàn diện 88 tasks (100% DONE), 8 Sprints thực thi liên tục.'],
    ['Live Backend API', 'http://127.0.0.1:5055/health (và /api/db/status)', 'Localhost (C# .NET 8)', 'Endpoint kiểm tra kết nối CSDL SQL Server SQLEXPRESS RepairShopDB (trạng thái: CONNECTED, 13 users, 5 tickets, 16 parts).'],
    ['Live Web Admin SPA', 'http://127.0.0.1:5055/admin (hoặc /portal)', 'admin / Abc@12345 (BCrypt)', 'Giao diện ZEISS TechCare, phân quyền RBAC 4 vai trò, điều phối phiếu sửa, tạo VietQR, kho linh kiện, báo cáo đồ án.']
  ];
  bXml += tableXml(linkH, linkR, [1800, 3600, 2200, 3200]);

  // III. Jira Tasks Progress
  bXml += pXml('III. BẢNG TỔNG HỢP TIẾN ĐỘ 88 TASKS TRÊN JIRA CLOUD (PROJECT: MBA — 100% DONE)', { bold: true, sz: 26, color: '1F4E79', before: 200, after: 80 });
  bXml += pXml('Dự án được quản lý theo phương pháp luận Agile/Scrum trên Jira Cloud với tổng cộng 88 công việc chi tiết chia theo 8 giai đoạn. Toàn bộ 88/88 tasks đều đã hoàn thành xuất sắc (DONE):');
  const jH = ['Mã Task', 'Phân loại / Sprint', 'Tên công việc / Hạng mục WBS', 'Người phụ trách', 'Trạng thái', 'Minh chứng kỹ thuật'];
  const jR = [
    ['MBA-07', 'Giai đoạn 1', 'Xác định đề tài và mục tiêu hệ thống sửa chữa', 'Nguyễn Viết Lãm', 'DONE', 'Project Charter v1.0'],
    ['MBA-08', 'Giai đoạn 1', 'Lập tôn chỉ dự án (Project Charter)', 'Nguyễn Viết Lãm', 'DONE', 'Báo cáo Word Chương 1'],
    ['MBA-09', 'Giai đoạn 1', 'Lập tuyên bố phạm vi (Scope Statement - SOW)', 'Trần Ngọc Lợi', 'DONE', 'Word Chương 2 & SRS'],
    ['MBA-10', 'Giai đoạn 1', 'Lập cấu trúc phân rã công việc (WBS 8 tuần)', 'Nguyễn Viết Lãm', 'DONE', 'Excel Sheet 1 & WBS Dictionary'],
    ['MBA-11', 'Giai đoạn 1', 'Ma trận phân công trách nhiệm RACI', 'Nguyễn Đại Kỳ', 'DONE', 'Excel RACI & Word Bảng 2.1'],
    ['MBA-18', 'Giai đoạn 2', 'Xây dựng tài liệu đặc tả SRS 8 nhóm chức năng', 'Trần Ngọc Lợi', 'DONE', 'Tài liệu SRS v1.2'],
    ['MBA-19', 'Giai đoạn 2', 'Chi tiết hóa 16 User Stories kèm tiêu chí AC', 'Trần Ngọc Lợi', 'DONE', 'User Stories Table'],
    ['MBA-29', 'Giai đoạn 3', 'Thiết kế kiến trúc tổng thể hệ thống 3 lớp', 'Nguyễn Viết Lãm', 'DONE', 'Architecture Diagram'],
    ['MBA-30', 'Giai đoạn 3', 'Thiết kế mô hình ERD quan hệ thực thể 13 bảng', 'Trần Ngọc Lợi', 'DONE', 'ERD 3NF & SQL Schema'],
    ['MBA-31', 'Giai đoạn 3', 'Script SQL Server tạo database và 13 bảng', 'Trần Ngọc Lợi', 'DONE', 'Database RepairShopDB'],
    ['MBA-34', 'Giai đoạn 4', 'Viết 10 câu queries & 4 Views báo cáo thống kê SQL', 'Trần Ngọc Lợi', 'DONE', '4 Database Views trên SQL Server'],
    ['MBA-35', 'Giai đoạn 4', 'Khởi tạo project ASP.NET Core 8 Minimal API', 'Nguyễn Viết Lãm', 'DONE', 'src/backend/QLDACNTT.Api.csproj'],
    ['MBA-36', 'Giai đoạn 4', 'Xây dựng xác thực token-based session auth', 'Nguyễn Viết Lãm', 'DONE', 'AuthEndpoints.cs & SessionStore'],
    ['MBA-37', 'Giai đoạn 4', 'Hiện thực phân quyền người dùng RBAC 4 vai trò', 'Nguyễn Viết Lãm', 'DONE', 'AuthHelper.cs & 23 Unit Tests Pass'],
    ['MBA-41', 'Giai đoạn 5', 'API tiếp nhận và tạo phiếu sửa chữa', 'Nguyễn Viết Lãm', 'DONE', 'TicketEndpoints.cs & 35 HTTP Tests'],
    ['MBA-42', 'Giai đoạn 5', 'API phân công kỹ thuật viên và chẩn đoán', 'Nguyễn Viết Lãm', 'DONE', 'TicketEndpoints.cs'],
    ['MBA-44', 'Giai đoạn 5', 'Viết file test API QLDACNTT.Api.http & Auth', 'Nguyễn Đại Kỳ', 'DONE', '35/35 HTTP Requests Pass (100%)'],
    ['MBA-46', 'Giai đoạn 5', 'Thiết kế giao diện Web Admin ZEISS SPA & HUTECH SSO', 'Nguyễn Đại Kỳ', 'DONE', 'src/web-admin/index.html (Floating Nav, Sidebar)'],
    ['MBA-55', 'Giai đoạn 5', 'Kết nối Backend Minimal API với SQL Server thật', 'Nguyễn Viết Lãm', 'DONE', 'Connection status CONNECTED'],
    ['MBA-61', 'Giai đoạn 6', 'API quản lý danh mục và tồn kho linh kiện', 'Nguyễn Viết Lãm', 'DONE', 'InventoryEndpoints.cs (16 phụ tùng)'],
    ['MBA-62', 'Giai đoạn 6', 'Nghiệp vụ xuất linh kiện thay thế theo phiếu', 'Nguyễn Viết Lãm', 'DONE', '10/10 kịch bản test xuất kho pass'],
    ['MBA-66', 'Giai đoạn 6', 'API tính chi phí và lập hóa đơn thanh toán', 'Nguyễn Viết Lãm', 'DONE', 'BillingAndWarrantyEndpoints.cs'],
    ['MBA-67', 'Giai đoạn 6', 'Xử lý thanh toán VietQR và tiền mặt', 'Nguyễn Viết Lãm', 'DONE', 'VietQR Generator & Scan QR'],
    ['MBA-68', 'Giai đoạn 6', 'Tự động kích hoạt sổ bảo hành điện tử theo máy', 'Trần Ngọc Lợi', 'DONE', 'Electronic Warranty Module'],
    ['MBA-73', 'Giai đoạn 7', 'Xây dựng báo cáo doanh thu theo thợ và dịch vụ', 'Nguyễn Viết Lãm', 'DONE', 'ReportEndpoints.cs (HTTP 200 OK)'],
    ['MBA-74', 'Giai đoạn 7', 'Báo cáo thống kê linh kiện bán chạy và tồn lâu', 'Trần Ngọc Lợi', 'DONE', 'ReportEndpoints.cs (HTTP 200 OK)'],
    ['MBA-83', 'Giai đoạn 7', 'Đóng gói ứng dụng và cấu hình CI/CD GitHub Actions', 'Nguyễn Viết Lãm', 'DONE', 'ci-cd.yml & Dockerfile'],
    ['MBA-85', 'Giai đoạn 8', 'Sao lưu dự phòng CSDL (Backup) trước khi Golive', 'Trần Ngọc Lợi', 'DONE', 'SQL Backup script hàng đêm'],
    ['MBA-86', 'Giai đoạn 8', 'Tổ chức training bàn giao cho cửa hàng TechCare', 'Cả nhóm', 'DONE', 'Tài liệu HDSD 3 vai trò'],
    ['MBA-87', 'Giai đoạn 8', 'Viết kịch bản Demo nghiệm thu đồ án chi tiết', 'Nguyễn Đại Kỳ', 'DONE', 'Kịch bản thuyết trình bảo vệ'],
    ['MBA-94', 'Giai đoạn 8', 'Lập checklist bàn giao mã nguồn và tài liệu cho trường', 'Nguyễn Viết Lãm', 'DONE', 'Gói nộp bài MINH_CHUNG_NHOM11']
  ];
  bXml += tableXml(jH, jR, [1100, 1400, 3100, 1700, 1100, 2400]);

  // IV. QUẢN LÝ RỦI RO DỰ ÁN (QLRR - CHUẨN SLIDE 21, SLIDE 28, SLIDE 30)
  bXml += pXml('IV. KẾ HOẠCH & MA TRẬN QUẢN LÝ RỦI RO DỰ ÁN (QLRR - BÀI GIẢNG SLIDE 21, 28, 30)', { bold: true, sz: 26, color: '1F4E79', before: 240, after: 100 });
  bXml += pXml('Căn cứ theo giáo trình Quản lý Dự án CNTT của Giảng viên, Nhóm 11 triển khai toàn diện công tác quản trị rủi ro thông qua 3 bảng biểu và sơ đồ chuẩn tắc:');

  // 4.1 Slide 21
  bXml += pXml('4.1. Phân tích tính chất rủi ro định tính theo dõi qua từng tháng (Slide 21)', { bold: true, sz: 24, color: '2F5597', before: 140, after: 60 });
  bXml += pXml('Bảng theo dõi biến động thứ hạng ưu tiên rủi ro qua 3 tháng thực hiện đồ án (Tháng 1: Khảo sát & Phân tích; Tháng 2: Thiết kế & Xây dựng Core; Tháng 3: Hoàn thiện & Tích hợp):');
  const s21H = ['STT', 'Mục Rủi ro (Nhận diện sự kiện)', 'Tháng 1', 'Tháng 2', 'Tháng 3', 'Tiến hành Giải quyết Rủi ro (Biện pháp xử lý)'];
  const s21R = [
    ['1', 'Lập Kế hoạch Không phù hợp với khối lượng thực tế', '1', '2', '3', 'Xem lại kế hoạch WBS 56 gói, rà soát ma trận RACI và điều phối lại tải công việc giữa 3 thành viên.'],
    ['2', 'Xác định phạm vi kém (Scope Creep / Thiếu sót SRS)', '2', '3', '3', 'Họp với Khách hàng & Nhà tài trợ (Giảng viên) làm rõ hơn về phạm vi nghiệp vụ và chốt SRS v1.2.'],
    ['3', 'Thiếu sự Lãnh đạo / Chỉ đạo & phối hợp nhóm kém', '3', '1', '2', 'Bổ nhiệm NV QL Dự án mới thay thế (Củng cố vai trò PM của Lãm, thiết lập Daily Scrum 15 phút, theo dõi Jira Board).'],
    ['4', 'Ước tính Chi phí chưa chính xác (Vượt ngân sách)', '4', '4', '3', 'Xem lại Ước tính chi phí; rà soát bảng SOR, cắt giảm phần mềm bản quyền trả phí, chuyển sang công cụ mã nguồn mở.'],
    ['5', 'Ước tính Thời gian kém (Trễ deadline task trọng yếu)', '5', '5', '3', 'Xem lại các Ước tính Lịch biểu, áp dụng kỹ thuật Fast-tracking (chạy song song Frontend và Backend API) để bù đắp lịch.'],
    ['6', 'Lỗ hổng bảo mật IDOR L05 (Xem chéo phiếu sửa chữa)', '8', '1', '1', 'Ưu tiên mức P0 khẩn cấp; vá logic kiểm tra Session Token trong TicketEndpoints.cs (Commit 4eb360c), test 403 Forbidden.'],
    ['7', 'Lỗi xuất kho linh kiện vượt tồn thực tế (Âm tồn kho)', '7', '2', '2', 'Bổ sung validation kiểm tra tồn kho trước khi xuất phiếu sửa, chặn lỗi HTTP 400 Bad Request kèm thông báo chi tiết.'],
    ['8', 'Sự cố kết nối hoặc timeout CSDL SQL Server', '6', '5', '4', 'Tối ưu Connection Pooling, thiết lập timeout 5s, xây dựng cơ chế in-memory fallback trong backend để web không bị sập.']
  ];
  bXml += tableXml(s21H, s21R, [600, 2800, 1000, 1000, 1000, 4400]);

  // 4.2 Slide 28
  bXml += pXml('4.2. Bảng theo dõi rủi ro chuẩn (Risk Register - Slide 28)', { bold: true, sz: 24, color: '2F5597', before: 160, after: 60 });
  bXml += pXml('Bảng 1: Định danh rủi ro theo cấu trúc WBS và người chịu trách nhiệm (Slide 28 - Mẫu 1):');
  const s28H1 = ['Mã rủi ro', 'Số hiệu trong WBS', 'Sự kiện rủi ro', 'Người chịu trách nhiệm', 'Phạm vi ảnh hưởng (W/B/S)'];
  const s28R1 = [
    ['RR-01', 'WBS 1.1.2', 'Thay đổi yêu cầu chức năng sau khi đã chốt SRS', 'Trần Ngọc Lợi (BA)', 'W (Work / Phạm vi)'],
    ['RR-02', 'WBS 3.1.2', 'Thiết kế CSDL thiếu trường khóa ngoại gây sai sót dữ liệu', 'Trần Ngọc Lợi (DB Lead)', 'W (Work / Dữ liệu)'],
    ['RR-03', 'WBS 4.1.3', 'Lỗ hổng an ninh phân quyền IDOR L05 trên API phiếu sửa', 'Nguyễn Viết Lãm (Backend)', 'W, S (Chất lượng & Tiến độ)'],
    ['RR-04', 'WBS 5.2.1', 'Chậm tiến độ xây dựng giao diện Web Admin do vướng CSS/JS', 'Nguyễn Đại Kỳ (Frontend)', 'S (Schedule / Tiến độ)'],
    ['RR-05', 'WBS 6.1.2', 'Lỗi xuất kho âm linh kiện khi nhiều kỹ thuật viên thao tác', 'Nguyễn Viết Lãm (PM)', 'W (Work / Tính đúng đắn)'],
    ['RR-06', 'WBS 7.1.1', 'Vượt ngân sách mua sắm thiết bị ngoại vi và phí Cloud VPS', 'Nguyễn Viết Lãm (PM)', 'B (Budget / Ngân sách)']
  ];
  bXml += tableXml(s28H1, s28R1, [1400, 1800, 3800, 2400, 1800]);

  bXml += pXml('Bảng 2: Đánh giá định lượng rủi ro: Xác suất, Ảnh hưởng và Xếp hạng (Slide 28 - Mẫu "Hay là:"):', { before: 100, after: 60 });
  const s28H2 = ['Mã RR', 'Ngày ảnh hưởng dự kiến', 'Xác suất xuất hiện (P)', 'Ảnh hưởng của rủi ro (I)', 'Mức độ nghiêm trọng (P x I)', 'Xếp hạng'];
  const s28R2 = [
    ['RR-01', '25/09/2026', '3 (Trung bình - 40%)', '3 (Đáng kể)', '9 (Vừa)', 'Hạng 3 (P2)'],
    ['RR-02', '30/09/2026', '2 (Thấp - 25%)', '4 (Nghiêm trọng)', '8 (Vừa)', 'Hạng 4 (P2)'],
    ['RR-03', '05/10/2026', '4 (Cao - 70%)', '5 (Thảm họa)', '20 (Khẩn cấp)', 'Hạng 1 (P0 - Critical)'],
    ['RR-04', '08/10/2026', '3 (Trung bình - 50%)', '4 (Nghiêm trọng)', '12 (Cao)', 'Hạng 2 (P1 - High)'],
    ['RR-05', '12/10/2026', '3 (Trung bình - 45%)', '3 (Đáng kể)', '9 (Vừa)', 'Hạng 5 (P2)'],
    ['RR-06', '15/10/2026', '2 (Thấp - 20%)', '3 (Đáng kể)', '6 (Thấp)', 'Hạng 6 (P3)']
  ];
  bXml += tableXml(s28H2, s28R2, [1200, 2000, 2000, 2200, 2200, 1600]);

  // 4.3 Slide 30
  bXml += pXml('4.3. Kế hoạch chiến lược đối phó rủi ro chính quy (Sơ đồ cây Slide 30)', { bold: true, sz: 24, color: '2F5597', before: 160, after: 60 });
  bXml += pXml('Nhóm 11 triển khai 4 nhóm chiến lược đối phó rủi ro chuẩn hóa theo đúng cấu trúc phân nhánh tại Slide 30 của Giảng viên:');
  const s30H = ['Chiến lược chính', 'Nhánh hành động cấp 2', 'Kế hoạch hành động cụ thể trong đồ án LV33-001', 'Giải pháp cứu chữa & Dự phòng'];
  const s30R = [
    ['Tránh né (Avoidance)', 'Chọn hướng đi khác', 'Không tự xây cổng thanh toán phức tạp mà tích hợp giải pháp VietQR tĩnh chuẩn EMVCo; không dùng CSDL NoSQL phức tạp mà chọn SQL Server 13 bảng 3NF ổn định.', 'Loại bỏ yếu tố gây rủi ro; rà soát loại bỏ tính năng ngoài phạm vi.'],
    ['Tránh né (Avoidance)', 'Thay đổi mục tiêu', 'Thu hẹp tính năng chat realtime sang hệ thống thông báo trạng thái phiếu sửa; tập trung làm xuất sắc 8 luồng nghiệp vụ lõi.', 'Họp với Giảng viên thống nhất điều chỉnh mục tiêu Sprint.'],
    ['Chuyển giao (Transference)', 'Chia sẻ rủi ro', 'Ký hợp đồng dịch vụ bảo trì phần cứng và cam kết SLA đổi trả trong 24h với nhà cung cấp thiết bị ngoại vi.', 'Giảm thiểu sự ràng buộc trực tiếp của nhóm vào thiết bị vật lý.'],
    ['Chuyển giao (Transference)', 'Báo cáo lãnh đạo', 'Kịp thời báo cáo Giảng viên hướng dẫn về các vướng mắc công nghệ để xin ý kiến chỉ đạo phương án kỹ thuật.', 'Báo cáo tiến độ hàng tuần kèm chỉ số EVM minh bạch.'],
    ['Chuyển giao (Transference)', 'Mua bảo hiểm', 'Sử dụng gói bảo hiểm thiết bị phần cứng tại quầy và thuê Cloud VPS có cam kết sao lưu dữ liệu hàng ngày (Auto-snapshot).', 'Chuyển gánh nặng rủi ro mất mát dữ liệu sang nhà cung cấp dịch vụ.'],
    ['Giảm nhẹ (Mitigation)', 'Giảm thiểu sự ảnh hưởng', 'Thiết lập cơ chế phân quyền RBAC 4 vai trò, kiểm tra Session Token chống IDOR, cấu hình bộ đệm in-memory fallback.', 'Các kế hoạch cứu chữa: Nhân lực dự phòng (Lãm hỗ trợ Kỳ code), Thời gian dự phòng (Buffer 4 ngày).'],
    ['Giảm nhẹ (Mitigation)', 'Giảm thiểu khả năng gây ra', 'Áp dụng Code Review chéo, viết 23 xUnit Unit Tests và 35 kịch bản API Integration Tests tự động trước khi merge.', 'Dùng công cụ mới (Jira Automation, GitHub CI/CD); Thay người nếu phát sinh sự cố bất khả kháng.'],
    ['Chấp nhận (Acceptance)', 'Chờ và xem', 'Đối với rủi ro biến động giá linh kiện thay thế nhỏ, chấp nhận biên độ dao động ±5% và theo dõi báo giá nhà cung cấp.', 'Giám sát định kỳ không can thiệp sớm tránh lãng phí nguồn lực.'],
    ['Chấp nhận (Acceptance)', 'Thu thập / mua thông tin', 'Khảo sát thực tế biểu phí dịch vụ và quy trình bảo hành từ 3 cửa hàng sửa chữa điện thoại - máy tính uy tín tại TP.HCM.', 'Bổ sung căn cứ thực tiễn hoàn thiện tài liệu SRS.'],
    ['Chấp nhận (Acceptance)', 'Kế hoạch khắc phục tác hại', 'Trích lập quỹ dự phòng rủi ro ngân sách 1.200.000 VNĐ; chuẩn bị sẵn script rollback database nếu migration gặp sự cố.', 'Huấn luyện phòng tránh: Đào tạo thành viên về tiêu chuẩn OWASP API Security.']
  ];
  bXml += tableXml(s30H, s30R, [1800, 2000, 4200, 3200]);

  // V. QUẢN LÝ MUA SẮM DỰ ÁN (QLMS - CHUẨN SLIDE 7)
  bXml += pXml('V. KẾ HOẠCH QUẢN LÝ MUA SẮM DỰ ÁN (QLMS - BÀI GIẢNG SLIDE 7)', { bold: true, sz: 26, color: '1F4E79', before: 240, after: 100 });
  bXml += pXml('Theo bài giảng Quản lý Dự án Công nghệ Thông tin (Slide 7: Lập kế hoạch mua sắm), kế hoạch mua sắm được xây dựng chặt chẽ nhằm trả lời trọn vẹn 5 câu hỏi cốt lõi:');

  const s7H = ['Câu hỏi cốt lõi (Slide 7)', 'Nội dung hoạch định chi tiết trong đồ án LV33-001', 'Căn cứ quyết định & Phân công'];
  const s7R = [
    ['1. Có mua hay không? (Make-or-Buy)', 'Nhóm xác định nguyên tắc: TỰ LÀM (Make) 100% phần mềm ứng dụng (Backend C# Minimal API, CSDL SQL Server 13 bảng, Web Admin SPA) nhằm làm chủ mã nguồn và tiết kiệm chi phí; MUA SẮM (Buy) thiết bị phần cứng tại quầy; THUÊ NGOÀI (Lease) hạ tầng Cloud VPS và tên miền.', 'Cả nhóm thống nhất trong Project Charter. Tiết kiệm ~65% chi phí so với mua giải pháp phần mềm đóng gói.'],
    ['2. Mua bằng cách nào? (Procurement Method)', 'Áp dụng 3 hình thức hợp đồng chính quy: (1) Mua đứt giá cố định (Firm Fixed Price - FFP) đối với thiết bị phần cứng; (2) Thuê bao định kỳ (Subscription) đối với Cloud VPS và Domain; (3) Mua lẻ linh kiện mẫu có hóa đơn VAT và bảo hành chính hãng.', 'Trần Ngọc Lợi (BA/Thương thảo hợp đồng). Lựa chọn nhà cung cấp qua chào giá cạnh tranh.'],
    ['3. Mua cái gì? (What to Buy)', 'Danh mục gồm 3 nhóm hàng hóa/dịch vụ: (1) Thiết bị quầy: Máy in nhiệt hóa đơn 80mm Xprinter, Máy quét mã vạch 2D QR Code Honeywell; (2) Hạ tầng: Cloud VPS Ubuntu 2 CPU/4GB RAM, Tên miền .vn; (3) Linh kiện mẫu kiểm thử kho: Pin iPhone, Màn hình OLED, RAM DDR4, SSD NVMe Kingston.', 'Nguyễn Đại Kỳ (Đề xuất thông số kỹ thuật) và Trần Ngọc Lợi (Lập danh mục mua sắm).'],
    ['4. Mua bao nhiêu? (Quantity & Budget)', 'Tổng kinh phí mua sắm dự kiến: 11.450.000 VNĐ (chiếm 21.2% tổng ngân sách BAC 54.000.000 VNĐ của dự án). Phân bổ: Thiết bị phần cứng 4.500.000 đ; Hạ tầng Cloud & Domain 1.950.000 đ; Lô linh kiện kiểm thử kho 3.800.000 đ; Dự phòng phí 1.200.000 đ.', 'Nguyễn Viết Lãm (PM) phê duyệt dự toán chi phí.'],
    ['5. Khi nào mua? (Procurement Schedule)', 'Tiến độ mua sắm theo 4 mốc Sprint: (1) Tuần 1 - Sprint 2: Mua gói Cloud VPS và Domain; (2) Tuần 3 - Sprint 3: Mua máy quét barcode và máy in nhiệt; (3) Tuần 5 - Sprint 5: Mua lô linh kiện mẫu phục vụ test luồng xuất kho và VietQR; (4) Tuần 7 - Sprint 7: Nghiệm thu và thanh lý hợp đồng.', 'Đồng bộ 100% với tiến độ đường găng CPM và biểu đồ Gantt.']
  ];
  bXml += tableXml(s7H, s7R, [2200, 5800, 3200]);

  // VI. Minh chứng kiểm thử tự động
  bXml += pXml('VI. MINH CHỨNG KIỂM THỬ TỰ ĐỘNG & AN TOÀN BẢO MẬT', { bold: true, sz: 26, color: '1F4E79', before: 200, after: 80 });
  const tH = ['Bộ công cụ kiểm thử', 'Số lượng kịch bản', 'Kết quả thực thi', 'Ý nghĩa kỹ thuật'];
  const tR = [
    ['Unit Test (xUnit .NET 8)', '23 Tests', '23/23 Passed (100%)', 'Bao phủ toàn bộ logic phân quyền Auth RBAC, tính giá dịch vụ, kiểm tra trạng thái phiếu'],
    ['API Integration Tests (.http)', '35 Requests', '35/35 Passed (100%)', 'Bao phủ 4 vai trò Admin, Staff, Technician, Customer; kiểm tra mã HTTP 200, 400, 401, 403'],
    ['E2E Inventory & Billing Tests', '10 Kịch bản', '10/10 Passed (100%)', 'Kiểm tra chặt chẽ quy trình xuất linh kiện thay thế, chặn lỗi âm tồn kho, tính tổng tiền hóa đơn'],
    ['Bảo mật An toàn thông tin (OWASP)', 'Lỗ hổng IDOR L05', 'Đã vá triệt để', 'Khách hàng chỉ được xem phiếu của chính mình, chặn truy cập trái phép bằng Session Token']
  ];
  bXml += tableXml(tH, tR, [2600, 1800, 2200, 4200]);

  // VII. Kết luận & Cam kết
  bXml += pXml('VII. KẾT LUẬN & CAM KẾT CỦA NHÓM SINH VIÊN', { bold: true, sz: 26, color: '1F4E79', before: 200, after: 80 });
  bXml += pXml('Nhóm 11 cam kết toàn bộ dữ liệu trên GitHub Repository, Jira Cloud và CSDL SQL Server là sản phẩm thực tế của nhóm, phản ánh trung thực quá trình học tập và làm việc qua 8 Sprints. Hệ thống phần mềm Backend và CSDL SQL Server đang chạy ổn định và sẵn sàng cho buổi báo cáo bảo vệ trước Hội đồng chấm thi.');

  // XML wrapper
  const newDocumentXml = `<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
            xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
            xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math"
            xmlns:w14="http://schemas.microsoft.com/office/word/2010/wordml">
  <w:body>
    ${bXml}
    <w:sectPr>
      <w:pgSz w:w="11906" w:h="16838"/>
      <w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/>
      <w:cols w:space="720"/>
      <w:docGrid w:linePitch="360"/>
    </w:sectPr>
  </w:body>
</w:document>`;

  zip.file('word/document.xml', newDocumentXml);
  const outBuf = await zip.generateAsync({ type: 'nodebuffer', compression: 'DEFLATE' });

  // Ghi đè vào cả 4 đường dẫn lưu trữ
  const targetPaths = [
    'HoSo_CongCu_Jira_GitHub_Nhom11.docx',
    'link github jira.docx',
    'MINH_CHUNG_NHOM11/01_BAO_CAO_VA_KE_HOACH/HoSo_CongCu_Jira_GitHub_Nhom11.docx',
    'github jira excel giua ky/link github jira.docx'
  ];

  for (const p of targetPaths) {
    if (fs.existsSync(path.dirname(p))) {
      fs.writeFileSync(p, outBuf);
      console.log(`✔ Đã cập nhật thành công: ${p} (${outBuf.length} bytes)`);
    }
  }
}

generateCompleteHoSoDocx().catch(err => {
  console.error('[LỖI TẠO FILE HO SO]', err);
  process.exit(1);
});
