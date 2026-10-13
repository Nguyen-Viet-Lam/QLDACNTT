import os
import sys
import json
import base64
import urllib.request
import urllib.error

# UTF-8 encoding for Windows console
if sys.platform.startswith('win'):
    try:
        sys.stdout.reconfigure(encoding='utf-8')
        sys.stderr.reconfigure(encoding='utf-8')
    except Exception:
        pass

# Config default
DEFAULT_DOMAIN = "https://lamnguyenadc1.atlassian.net"
CONFIG_FILE = os.path.join(os.path.dirname(__file__), "jira_config.json")

def load_config():
    config = {
        "domain": DEFAULT_DOMAIN,
        "email": os.environ.get("JIRA_EMAIL", ""),
        "api_token": os.environ.get("JIRA_API_TOKEN", "")
    }
    if os.path.exists(CONFIG_FILE):
        try:
            with open(CONFIG_FILE, "r", encoding="utf-8") as f:
                saved = json.load(f)
                config.update(saved)
        except Exception:
            pass
    return config

def save_config(email, api_token, domain=DEFAULT_DOMAIN):
    config = {
        "domain": domain.rstrip("/"),
        "email": email.strip(),
        "api_token": api_token.strip()
    }
    os.makedirs(os.path.dirname(CONFIG_FILE), exist_ok=True)
    with open(CONFIG_FILE, "w", encoding="utf-8") as f:
        json.dump(config, f, indent=2, ensure_ascii=False)
    print(f"[OK] Da luu cau hinh Jira thanh cong vao {CONFIG_FILE}")

def get_auth_header(email, api_token):
    auth_str = f"{email}:{api_token}"
    b64_auth = base64.b64encode(auth_str.encode("utf-8")).decode("utf-8")
    return {
        "Authorization": f"Basic {b64_auth}",
        "Content-Type": "application/json",
        "Accept": "application/json"
    }

def get_issue(issue_key, config=None):
    if not config:
        config = load_config()
    url = f"{config['domain']}/rest/api/3/issue/{issue_key}"
    headers = get_auth_header(config['email'], config['api_token'])
    req = urllib.request.Request(url, headers=headers)
    try:
        with urllib.request.urlopen(req) as resp:
            data = json.loads(resp.read().decode("utf-8"))
            status = data["fields"]["status"]["name"]
            summary = data["fields"]["summary"]
            assignee = data["fields"].get("assignee")
            assignee_name = assignee["displayName"] if assignee else "Unassigned"
            print(f"[{issue_key}] {summary} | Status: {status} | Assignee: {assignee_name}")
            return data
    except urllib.error.HTTPError as e:
        print(f"[ERROR] HTTP {e.code}: {e.read().decode('utf-8')}")
        return None

def get_transitions(issue_key, config=None):
    if not config:
        config = load_config()
    url = f"{config['domain']}/rest/api/3/issue/{issue_key}/transitions"
    headers = get_auth_header(config['email'], config['api_token'])
    req = urllib.request.Request(url, headers=headers)
    try:
        with urllib.request.urlopen(req) as resp:
            data = json.loads(resp.read().decode("utf-8"))
            return data.get("transitions", [])
    except urllib.error.HTTPError as e:
        print(f"[ERROR] HTTP {e.code}: {e.read().decode('utf-8')}")
        return []

def transition_issue(issue_key, target_status_name, comment_text=None, config=None):
    if not config:
        config = load_config()
    transitions = get_transitions(issue_key, config)
    target_id = None
    target_status_name_lower = target_status_name.lower().strip()
    
    available = []
    for t in transitions:
        t_name = t["name"]
        available.append(f"{t_name} (id={t['id']})")
        if target_status_name_lower in t_name.lower() or t_name.lower() in target_status_name_lower:
            target_id = t["id"]
            break
            
    if not target_id:
        print(f"[WARN] Khong tim thay transition '{target_status_name}' cho {issue_key}.")
        print(f"       Cac trang thai kha dung: {', '.join(available)}")
        return False
        
    url = f"{config['domain']}/rest/api/3/issue/{issue_key}/transitions"
    headers = get_auth_header(config['email'], config['api_token'])
    payload = {
        "transition": {
            "id": target_id
        }
    }
    
    req = urllib.request.Request(url, data=json.dumps(payload).encode("utf-8"), headers=headers, method="POST")
    try:
        with urllib.request.urlopen(req) as resp:
            print(f"[THANH CONG] {issue_key} da chuyen sang '{target_status_name}' (Transition ID: {target_id})")
            
        if comment_text:
            add_comment(issue_key, comment_text, config)
        return True
    except urllib.error.HTTPError as e:
        print(f"[ERROR] HTTP {e.code}: {e.read().decode('utf-8')}")
        return False

def add_comment(issue_key, comment_text, config=None):
    if not config:
        config = load_config()
    url = f"{config['domain']}/rest/api/3/issue/{issue_key}/comment"
    headers = get_auth_header(config['email'], config['api_token'])
    payload = {
        "body": {
            "type": "doc",
            "version": 1,
            "content": [
                {
                    "type": "paragraph",
                    "content": [
                        {
                            "type": "text",
                            "text": comment_text
                        }
                    ]
                }
            ]
        }
    }
    req = urllib.request.Request(url, data=json.dumps(payload).encode("utf-8"), headers=headers, method="POST")
    try:
        with urllib.request.urlopen(req) as resp:
            print(f"[COMMENT] Da them ghi chu vao {issue_key}: '{comment_text}'")
            return True
    except urllib.error.HTTPError as e:
        print(f"[ERROR] Failed to add comment: HTTP {e.code}")
        return False

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Huong dan su dung:")
        print("  1. Luu cau hinh:  python jira_tool.py config <email> <api_token> [domain]")
        print("  2. Xem task:      python jira_tool.py get <issue_key>")
        print("  3. Chuyen DONE:   python jira_tool.py done <issue_key> [comment]")
        print("  4. Chuyen INPROG: python jira_tool.py in_progress <issue_key> [comment]")
        sys.exit(0)
        
    cmd = sys.argv[1].lower()
    if cmd == "config":
        if len(sys.argv) < 4:
            print("Usage: python jira_tool.py config <email> <api_token> [domain]")
            sys.exit(1)
        domain = sys.argv[4] if len(sys.argv) > 4 else DEFAULT_DOMAIN
        save_config(sys.argv[2], sys.argv[3], domain)
    elif cmd == "get":
        if len(sys.argv) < 3:
            print("Usage: python jira_tool.py get <issue_key>")
            sys.exit(1)
        get_issue(sys.argv[2])
    elif cmd == "done":
        if len(sys.argv) < 3:
            print("Usage: python jira_tool.py done <issue_key> [comment]")
            sys.exit(1)
        comment = sys.argv[3] if len(sys.argv) > 3 else None
        transition_issue(sys.argv[2], "Done", comment)
    elif cmd in ["in_progress", "inprogress", "doing"]:
        if len(sys.argv) < 3:
            print("Usage: python jira_tool.py in_progress <issue_key> [comment]")
            sys.exit(1)
        comment = sys.argv[3] if len(sys.argv) > 3 else None
        transition_issue(sys.argv[2], "In Progress", comment)
