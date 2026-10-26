import fs from 'fs';
import path from 'path';

// Resilient loader for @oai/artifact-tool
let artifactTool;
try {
  artifactTool = await import('@oai/artifact-tool');
} catch {
  try {
    artifactTool = await import('file:///C:/Users/ASUS/Downloads/QLDACNTT/tmp/qlda_final/node_modules/@oai/artifact-tool/dist/artifact_tool.mjs');
  } catch {
    artifactTool = await import('file:///C:/Users/ASUS/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/@oai/artifact-tool/dist/artifact_tool.mjs');
  }
}
const { SpreadsheetFile } = artifactTool;

// Load configuration
const configPath = path.resolve('tools/social_config.json');
let config = {
  author: { name: 'Nguyễn Viết Lãm', email: 'lamnguyenadc@gmail.com', jira_email: 'lamnguyenadc1@gmail.com' },
  facebook: { enabled: false, page_id: '', access_token: '' },
  zalo: { enabled: false, webhook_url: '', oa_access_token: '' },
  excel: {
    filePath: 'C:/Users/ASUS/Downloads/QLDACNTT/Lich_Dang_Bai_Hoc_Tu_Dong.xlsx',
    claudeSyncPath: 'C:/Users/ASUS/Claude/Lich_Dang_Bai_Hoc_Tu_Dong.xlsx',
    sheetName: 'Lich dang'
  }
};

if (fs.existsSync(configPath)) {
  try {
    config = JSON.parse(fs.readFileSync(configPath, 'utf8'));
  } catch (err) {
    console.warn(`[CẢNH BÁO] Không thể đọc file cấu hình: ${err.message}. Sử dụng cấu hình mặc định.`);
  }
}

// Không lưu access token trong repo hoặc bộ minh chứng.
// Nếu vẫn dùng Facebook Graph API, truyền token qua biến môi trường.
config.facebook.access_token = process.env.FACEBOOK_PAGE_ACCESS_TOKEN || '';

function getFormattedTimestamp() {
  const d = new Date();
  const pad = (n) => String(n).padStart(2, '0');
  const day = pad(d.getDate());
  const month = pad(d.getMonth() + 1);
  const year = d.getFullYear();
  const hours = pad(d.getHours());
  const mins = pad(d.getMinutes());
  const secs = pad(d.getSeconds());
  return `${day}/${month}/${year} ${hours}:${mins}:${secs}`;
}

async function postToFacebook(post) {
  if (config.facebook && config.facebook.enabled && config.facebook.page_id && config.facebook.access_token && !config.facebook.access_token.includes('YOUR_')) {
    try {
      console.log(`[FB LIVE] Đang gửi bài viết lên Facebook Fanpage ID: ${config.facebook.page_id}...`);
      const url = `https://graph.facebook.com/v19.0/${config.facebook.page_id}/feed`;
      const res = await fetch(url, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          message: post.content,
          access_token: config.facebook.access_token
        })
      });
      const data = await res.json();
      if (res.ok && data.id) {
        console.log(`[FB THÀNH CÔNG] Post ID: ${data.id}`);
        return { success: true, id: data.id };
      } else {
        console.error(`[FB LỖI] ${JSON.stringify(data)}`);
        return { success: false, error: data };
      }
    } catch (err) {
      console.error(`[FB NGOẠI LỆ] ${err.message}`);
      return { success: false, error: err.message };
    }
  } else {
    console.log(`[FB GIẢ LẬP / KIỂM THỬ] Chưa bật Live API (hoặc chưa nhập Token). Giả lập gửi thành công lên Fanpage riêng tư.`);
    console.log(`--- [NỘI DUNG FACEBOOK PREVIEW] ---`);
    console.log(post.content.slice(0, 160) + '...\n----------------------------------');
    return { success: false, simulated: true, error: 'Facebook Live API chưa được cấu hình.' };
  }
}

async function postToZalo(post) {
  if (config.zalo && config.zalo.enabled && config.zalo.webhook_url && !config.zalo.webhook_url.includes('YOUR_')) {
    try {
      console.log(`[ZALO LIVE] Đang gửi webhook vào nhóm Zalo riêng tư...`);
      const res = await fetch(config.zalo.webhook_url, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          text: `📢 [COWORK AUTO-POST] ${post.title}\n\n${post.summary}\n\nTài liệu: ${post.link}\nTác giả: ${config.author.name} (${config.author.email})`
        })
      });
      console.log(`[ZALO THÀNH CÔNG] HTTP Status: ${res.status}`);
      return { success: true };
    } catch (err) {
      console.error(`[ZALO NGOẠI LỆ] ${err.message}`);
      return { success: false, error: err.message };
    }
  } else {
    console.log(`[ZALO GIẢ LẬP / KIỂM THỬ] Đã giả lập gửi tin nhắn webhook vào nhóm Zalo riêng tư.`);
    return { success: true, simulated: true };
  }
}

async function runAutoPublish() {
  const args = process.argv.slice(2);
  const isDryRun = args.includes('--dry-run');
  const isStatusOnly = args.includes('--status');
  const isPublishAll = args.includes('--all');
  const isMarkScheduled = args.includes('--mark-scheduled');
  const idIndex = args.indexOf('--id');
  const targetId = idIndex !== -1 && args[idIndex + 1] ? parseInt(args[idIndex + 1], 10) : null;
  const scheduledAtIndex = args.indexOf('--scheduled-at');
  const scheduledAt = scheduledAtIndex !== -1 && args[scheduledAtIndex + 1]
    ? args[scheduledAtIndex + 1]
    : null;

  console.log(`================================================================`);
  console.log(`   HỆ THỐNG TỰ ĐỘNG HÓA ĐĂNG BÀI FACEBOOK & ZALO RIÊNG TƯ       `);
  console.log(`   Tác giả: ${config.author.name} | Email: ${config.author.email}`);
  console.log(`   Tài khoản Jira tích hợp: ${config.author.jira_email}          `);
  console.log(`================================================================\n`);

  const excelPath = config.excel.filePath;
  if (!fs.existsSync(excelPath)) {
    console.error(`[LỖI] Không tìm thấy file Excel tại: ${excelPath}`);
    process.exit(1);
  }

  const buf = fs.readFileSync(excelPath);
  const wb = await SpreadsheetFile.importXlsx(buf);
  const sheet = wb.worksheets.getItem(config.excel.sheetName || 'Lich dang');

  if (!sheet) {
    console.error(`[LỖI] Không tìm thấy sheet '${config.excel.sheetName}' trong workbook.`);
    process.exit(1);
  }

  // Parse rows (A5 to P14)
  const rows = [];
  for (let r = 5; r <= 14; r++) {
    const stt = sheet.getRange(`A${r}`).values[0][0];
    const date = sheet.getRange(`B${r}`).values[0][0];
    const time = sheet.getRange(`C${r}`).values[0][0];
    const chapter = sheet.getRange(`D${r}`).values[0][0];
    const lesson = sheet.getRange(`E${r}`).values[0][0];
    const title = sheet.getRange(`F${r}`).values[0][0];
    const duration = sheet.getRange(`G${r}`).values[0][0];
    const summary = sheet.getRange(`H${r}`).values[0][0];
    const hashtag = sheet.getRange(`I${r}`).values[0][0];
    const content = sheet.getRange(`J${r}`).values[0][0];
    const link = sheet.getRange(`K${r}`).values[0][0];
    const status = sheet.getRange(`L${r}`).values[0][0];
    const channel = sheet.getRange(`M${r}`).values[0][0];
    const author = sheet.getRange(`N${r}`).values[0][0];
    const video = sheet.getRange(`O${r}`).values[0][0];
    const postedAt = sheet.getRange(`P${r}`).values[0][0];

    rows.push({
      rowNum: r,
      stt, date, time, chapter, lesson, title, duration, summary,
      hashtag, content, link, status, channel, author, video, postedAt
    });
  }

  if (isMarkScheduled) {
    if (!targetId || !scheduledAt) {
      console.error(`[LỖI] --mark-scheduled yêu cầu cả --id và --scheduled-at.`);
      process.exit(1);
    }

    const scheduledPost = rows.find(r => r.stt === targetId);
    if (!scheduledPost) {
      console.error(`[LỖI] Không tìm thấy bài có STT = ${targetId}.`);
      process.exit(1);
    }

    sheet.getRange(`L${scheduledPost.rowNum}`).values = [['Đã lên lịch']];
    sheet.getRange(`P${scheduledPost.rowNum}`).values = [[`${scheduledAt} (lên lịch)`]];
    sheet.getRange(`L${scheduledPost.rowNum}`).format = {
      fill: '#DDEBF7',
      font: { name: 'Arial', size: 9.5, bold: true, color: '#1F4E78' },
      horizontalAlignment: 'center',
      verticalAlignment: 'center'
    };
    sheet.getRange(`P${scheduledPost.rowNum}`).format = {
      font: { name: 'Arial', size: 9, italic: true, color: '#1F1F1F' },
      horizontalAlignment: 'center',
      verticalAlignment: 'center'
    };

    const blob = await SpreadsheetFile.exportXlsx(wb);
    await blob.save(excelPath);
    console.log(`✔ Bài STT ${targetId} đã được ghi nhận 'Đã lên lịch' lúc ${scheduledAt}.`);
    return;
  }

  if (isStatusOnly) {
    console.log(`DANH SÁCH BÀI ĐĂNG HIỆN TẠI TRONG EXCEL:`);
    console.log(`-----------------------------------------------------------------------------------------`);
    console.log(`STT | Bài học                          | Trạng thái | Đã đăng lúc`);
    console.log(`-----------------------------------------------------------------------------------------`);
    for (const item of rows) {
      const name = item.title.padEnd(32, ' ').slice(0, 32);
      const st = (item.status || 'Chưa đăng').padEnd(10, ' ');
      const at = item.postedAt || '(chưa có)';
      console.log(`${String(item.stt).padStart(3)} | ${name} | ${st} | ${at}`);
    }
    console.log(`-----------------------------------------------------------------------------------------\n`);
    return;
  }

  // Determine which items to publish
  let toPublish = [];
  if (targetId) {
    toPublish = rows.filter(r => r.stt === targetId);
    if (toPublish.length === 0) {
      console.log(`[CẢNH BÁO] Không tìm thấy bài học có STT = ${targetId}.`);
      return;
    }
  } else if (isPublishAll) {
    toPublish = rows.filter(r => !['Đã đăng', 'Đã lên lịch'].includes(r.status));
  } else {
    // Publish next pending
    const nextItem = rows.find(r => !['Đã đăng', 'Đã lên lịch'].includes(r.status));
    if (nextItem) {
      toPublish = [nextItem];
    } else {
      console.log(`[THÔNG BÁO] Toàn bộ 10 bài học đều đã ở trạng thái 'Đã đăng'. Không có bài mới cần đẩy!`);
      return;
    }
  }

  console.log(`Chuẩn bị xử lý đăng ${toPublish.length} bài viết...\n`);

  for (const post of toPublish) {
    console.log(`▶ ĐANG XỬ LÝ: [STT ${post.stt}] ${post.title}`);
    console.log(`   Chương: ${post.chapter}`);
    console.log(`   Kênh: ${post.channel}`);
    console.log(`   Tác giả: ${post.author || config.author.name}`);

    // Step 1: Send to Facebook
    const facebookResult = await postToFacebook(post);

    // Step 2: Send to Zalo
    await postToZalo(post);

    const nowTimestamp = getFormattedTimestamp();

    if (!isDryRun) {
      if (!facebookResult.success) {
        console.error(`   ✘ Facebook chưa đăng thành công; giữ nguyên trạng thái Excel để có thể thử lại.`);
        continue;
      }

      // Step 3: Update Excel status & timestamp
      sheet.getRange(`L${post.rowNum}`).values = [['Đã đăng']];
      sheet.getRange(`P${post.rowNum}`).values = [[nowTimestamp]];
      
      // Update cell styling to Green
      sheet.getRange(`L${post.rowNum}`).format = {
        fill: '#E2EFDA',
        font: { name: 'Arial', size: 9.5, bold: true, color: '#375623' },
        horizontalAlignment: 'center',
        verticalAlignment: 'center'
      };
      sheet.getRange(`P${post.rowNum}`).format = {
        font: { name: 'Arial', size: 9, italic: true, color: '#1F1F1F' },
        horizontalAlignment: 'center',
        verticalAlignment: 'center'
      };

      console.log(`   ✔ Đã cập nhật trạng thái ô L${post.rowNum} -> 'Đã đăng'`);
      console.log(`   ✔ Đã cập nhật thời gian ô P${post.rowNum} -> '${nowTimestamp}'`);
    } else {
      console.log(`   [DRY-RUN] Không ghi vào Excel do đang chạy cờ kiểm thử --dry-run.`);
    }
    console.log(``);
  }

  if (!isDryRun && toPublish.length > 0) {
    console.log(`Đang lưu và xuất bản lại file Excel: ${excelPath}...`);
    try {
      const blob = await SpreadsheetFile.exportXlsx(wb);
      await blob.save(excelPath);
      console.log(`✔ Lưu thành công: ${excelPath}`);
    } catch (saveErr) {
      if (saveErr.code === 'EBUSY') {
        const altPath = excelPath.replace('.xlsx', '_MoiNhat.xlsx');
        console.warn(`[CẢNH BÁO] File ${excelPath} đang được mở trong phần mềm Excel.`);
        console.warn(`Đang lưu tạm kết quả ra file mới: ${altPath}`);
        const blob = await SpreadsheetFile.exportXlsx(wb);
        await blob.save(altPath);
        console.log(`✔ Lưu thành công vào file thay thế: ${altPath}`);
      } else {
        throw saveErr;
      }
    }

    // Synchronize to Claude directory
    if (config.excel.claudeSyncPath) {
      try {
        const claudeDir = path.dirname(config.excel.claudeSyncPath);
        if (!fs.existsSync(claudeDir)) {
          fs.mkdirSync(claudeDir, { recursive: true });
        }
        if (fs.existsSync(excelPath)) {
          fs.copyFileSync(excelPath, config.excel.claudeSyncPath);
          console.log(`✔ Đồng bộ thành công sang thư mục Claude: ${config.excel.claudeSyncPath}`);
        }
      } catch (err) {
        console.warn(`[CẢNH BÁO] Không thể đồng bộ sang thư mục Claude: ${err.message}`);
      }
    }
  }

  console.log(`\n================================================================`);
  console.log(`   HOÀN TẤT TIẾN TRÌNH TỰ ĐỘNG HÓA THÀNH CÔNG!                  `);
  console.log(`================================================================\n`);
}

runAutoPublish().catch(err => {
  console.error('[LỖI CHƯƠNG TRÌNH]', err);
  process.exit(1);
});

