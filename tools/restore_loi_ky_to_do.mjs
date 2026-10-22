import fs from 'fs';

const config = JSON.parse(fs.readFileSync('tools/jira_config.json', 'utf8'));
const auth = Buffer.from(`${config.email}:${config.api_token}`).toString('base64');

// Tasks of Tran Ngoc Loi and Nguyen Dai Ky to restore back to 'To Do'
const tasksToRestore = [
  { key: 'MBA-85', assignee: 'Trần Ngọc Lợi', summary: 'Sao lưu dự phòng CSDL (Backup) trước khi Golive' },
  { key: 'MBA-87', assignee: 'Đại Kỳ Nguyễn', summary: 'Viết kịch bản Demo nghiệm thu đồ án chi tiết' },
  { key: 'MBA-88', assignee: 'Trần Ngọc Lợi', summary: 'Khảo sát và đánh giá người dùng sau triển khai' },
  { key: 'MBA-93', assignee: 'Trần Ngọc Lợi', summary: 'Soạn biên bản nghiệm thu và thanh lý hợp đồng dịch vụ' },
  { key: 'MBA-94', assignee: 'Đại Kỳ Nguyễn', summary: 'Lập checklist bàn giao mã nguồn và tài liệu cho trường' }
];

async function restoreTasks() {
  console.log('=== KHÔI PHỤC CÁC TASK CỦA LỢI VÀ KỲ VỀ LẠI "TO DO" ===');
  for (const t of tasksToRestore) {
    try {
      const res = await fetch(`${config.domain}/rest/api/3/issue/${t.key}/transitions`, {
        method: 'POST',
        headers: {
          'Authorization': `Basic ${auth}`,
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: JSON.stringify({
          transition: { id: '11' } // ID 11 is To Do
        })
      });

      if (res.status === 204 || res.ok) {
        console.log(`✔ [${t.key}] (${t.assignee}) Đã trả về "TO DO" thành công!`);
      } else {
        const txt = await res.text();
        console.error(`✖ [${t.key}] Lỗi HTTP ${res.status}:`, txt);
      }
    } catch (e) {
      console.error(`✖ [${t.key}] Exception:`, e.message);
    }
  }

  // Verify Board state
  console.log('\n--- KIỂM TRA TRẠNG THÁI BOARD JIRA HIỆN TẠI ---');
  const res = await fetch(`${config.domain}/rest/agile/1.0/board/2/issue?maxResults=100`, {
    headers: { 'Authorization': `Basic ${auth}`, 'Accept': 'application/json' }
  });
  const data = await res.json();
  const byStatus = {};
  data.issues?.forEach(i => {
    const s = i.fields.status.name;
    byStatus[s] = (byStatus[s] || 0) + 1;
  });
  console.log(`Tổng issues: ${data.total}`);
  console.log('Phân bổ trạng thái:', byStatus);

  // List To Do
  const todoIssues = data.issues?.filter(i => i.fields.status.name === 'To Do');
  console.log(`\nDanh sách các task đang ở To Do (${todoIssues.length} tasks):`);
  todoIssues.forEach(i => {
    console.log(`  - [${i.key}] ${i.fields.summary} (Assignee: ${i.fields.assignee?.displayName})`);
  });

  // List Lam's tasks in last 10
  const lamTasks = data.issues?.filter(i => ['MBA-86', 'MBA-89', 'MBA-90', 'MBA-91', 'MBA-92'].includes(i.key));
  console.log(`\nDanh sách các task của Lãm đã chuyển DONE (${lamTasks.length} tasks):`);
  lamTasks.forEach(i => {
    console.log(`  - [${i.key}] ${i.fields.summary} -> Status: ${i.fields.status.name}`);
  });
}

restoreTasks();
