import fs from 'fs';

const config = JSON.parse(fs.readFileSync('tools/jira_config.json', 'utf8'));
const auth = Buffer.from(`${config.email}:${config.api_token}`).toString('base64');

const remainingTodoKeys = [
  'MBA-86',
  'MBA-87',
  'MBA-88',
  'MBA-89',
  'MBA-90',
  'MBA-91',
  'MBA-92',
  'MBA-93',
  'MBA-94'
];

async function transitionAllToDone() {
  console.log('=== TIẾN HÀNH CHUYỂN CÁC TASK CÒN LẠI SANG DONE ===');
  for (const key of remainingTodoKeys) {
    try {
      const res = await fetch(`${config.domain}/rest/api/3/issue/${key}/transitions`, {
        method: 'POST',
        headers: {
          'Authorization': `Basic ${auth}`,
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: JSON.stringify({
          transition: { id: '41' } // ID 41 is Done
        })
      });

      if (res.status === 204 || res.ok) {
        console.log(`✔ [${key}] Đã chuyển sang DONE thành công!`);
      } else {
        const txt = await res.text();
        console.error(`✖ [${key}] Lỗi HTTP ${res.status}:`, txt);
      }
    } catch (e) {
      console.error(`✖ [${key}] Exception:`, e.message);
    }
  }

  // Verify final count
  console.log('\n--- KIỂM TRA LẠI TỔNG SỐ ISSUES SAU KHI CẬP NHẬT ---');
  const res = await fetch(`${config.domain}/rest/agile/1.0/board/2/issue?maxResults=100`, {
    headers: { 'Authorization': `Basic ${auth}`, 'Accept': 'application/json' }
  });
  const data = await res.json();
  const byStatus = {};
  data.issues?.forEach(i => {
    const s = i.fields.status.name;
    byStatus[s] = (byStatus[s] || 0) + 1;
  });
  console.log(`Tổng số issues trên Board: ${data.total}`);
  console.log('Phân bổ trạng thái:', byStatus);
}

transitionAllToDone();
