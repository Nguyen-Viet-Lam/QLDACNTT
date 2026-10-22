import fs from 'fs';

const config = JSON.parse(fs.readFileSync('tools/jira_config.json', 'utf8'));
const auth = Buffer.from(`${config.email}:${config.api_token}`).toString('base64');

async function check88Issues() {
  const url = `${config.domain}/rest/api/3/search/jql?jql=${encodeURIComponent('project = MBA')}&maxResults=100`;
  const res = await fetch(url, {
    headers: { 'Authorization': `Basic ${auth}`, 'Accept': 'application/json' }
  });
  const data = await res.json();
  const issueIds = data.issues.map(i => i.id);
  console.log(`Tìm thấy đúng ${issueIds.length} issues trong dự án MBA!`);

  // Now fetch details for each issue
  console.log('Đang lấy thông tin chi tiết từng issue...');
  const detailed = [];
  
  // Fetch in batches of 10
  for (let i = 0; i < issueIds.length; i += 10) {
    const chunk = issueIds.slice(i, i + 10);
    const promises = chunk.map(async (id) => {
      try {
        const r = await fetch(`${config.domain}/rest/api/3/issue/${id}?fields=summary,status,assignee,created,updated,issuetype,priority,customfield_10020`, {
          headers: { 'Authorization': `Basic ${auth}`, 'Accept': 'application/json' }
        });
        if (r.ok) {
          const d = await r.json();
          const sprintField = d.fields.customfield_10020;
          let sprintName = 'Backlog / Không có Sprint';
          let sprintState = 'None';
          if (Array.isArray(sprintField) && sprintField.length > 0) {
            const activeOrLast = sprintField[sprintField.length - 1];
            sprintName = activeOrLast.name || 'Sprint';
            sprintState = activeOrLast.state || 'active';
          }
          return {
            id,
            key: d.key,
            summary: d.fields.summary,
            status: d.fields.status.name,
            statusCategory: d.fields.status.statusCategory.name,
            assignee: d.fields.assignee?.displayName || 'Unassigned',
            sprint: sprintName,
            sprintState
          };
        }
      } catch (e) {
        return null;
      }
    });
    const results = await Promise.all(promises);
    detailed.push(...results.filter(Boolean));
    process.stdout.write(`Đã lấy ${detailed.length} / ${issueIds.length}...\r`);
  }

  console.log(`\nHoàn tất tải ${detailed.length} issues.`);

  // Sort by key number
  detailed.sort((a, b) => {
    const nA = parseInt(a.key.replace('MBA-', ''), 10);
    const nB = parseInt(b.key.replace('MBA-', ''), 10);
    return nA - nB;
  });

  // Group by status
  const byStatus = {};
  const bySprint = {};
  for (const item of detailed) {
    byStatus[item.status] = (byStatus[item.status] || 0) + 1;
    bySprint[item.sprint] = (bySprint[item.sprint] || 0) + 1;
  }

  console.log('\n--- PHÂN BỔ THEO TRẠNG THÁI ---');
  console.log(byStatus);

  console.log('\n--- PHÂN BỔ THEO SPRINT ---');
  console.log(bySprint);

  console.log('\n--- CÁC TASK CÓ TRẠNG THÁI DONE (' + (byStatus['Done'] || 0) + ' tasks) ---');
  detailed.filter(i => i.status.toLowerCase() === 'done').forEach(i => {
    console.log(`  ${i.key}: ${i.summary} [${i.sprint}]`);
  });

  console.log('\n--- CÁC TASK CÓ TRẠNG THÁI TO DO (' + (byStatus['To Do'] || 0) + ' tasks) ---');
  detailed.filter(i => i.status.toLowerCase() === 'to do').forEach(i => {
    console.log(`  ${i.key}: ${i.summary} [${i.sprint}]`);
  });

  fs.writeFileSync('tools/jira_88_issues_detailed.json', JSON.stringify(detailed, null, 2), 'utf8');
}

check88Issues();
