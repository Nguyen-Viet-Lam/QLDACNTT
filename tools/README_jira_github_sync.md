# Dong bo task Jira len GitHub Issues

Tool nay doc task Jira bang Jira Cloud REST API/JQL va tao/cap nhat GitHub Issues trong repo `Nguyen-Viet-Lam/QLDACNTT`.

## 1. Can chuan bi

- Jira API token: tao trong trang quan ly API token cua Atlassian.
- GitHub token: token can quyen `Issues: Read and write` tren repo `Nguyen-Viet-Lam/QLDACNTT`.
- Jira site URL cua board trong anh: `https://lamnguyenadc1.atlassian.net`.
- JQL loc task can dong bo, vi du:

```text
project = MBA AND assignee = currentUser() ORDER BY updated DESC
```

## 2. Cau hinh bien moi truong tren PowerShell

```powershell
$env:JIRA_BASE_URL="https://lamnguyenadc1.atlassian.net"
$env:JIRA_EMAIL="your-email@example.com"
$env:JIRA_API_TOKEN="your-jira-api-token"
$env:JIRA_JQL="project = MBA AND assignee = currentUser() ORDER BY updated DESC"

$env:GITHUB_REPOSITORY="Nguyen-Viet-Lam/QLDACNTT"
$env:GITHUB_TOKEN="github_pat_or_classic_token"
$env:GITHUB_LABELS="jira"
```

## 3. Chay thu, chua tao issue that

```powershell
$env:SYNC_DRY_RUN="true"
python .\tools\sync_jira_to_github.py
```

## 4. Dong bo that len GitHub Issues

```powershell
$env:SYNC_DRY_RUN="false"
python .\tools\sync_jira_to_github.py
```

Script se tim issue GitHub da co marker `jira-key: MBA-xx` trong body. Neu da co, script cap nhat issue do; neu chua co, script tao issue moi.

## Ghi chu

- Nen dung Jira REST API thay vi cao HTML Jira vi API on dinh hon, co phan quyen ro rang va khong bi phu thuoc giao dien web.
- Khong commit token vao repo. File `jira_github_sync.env.example` chi la mau, khong dien token that vao file nay.
