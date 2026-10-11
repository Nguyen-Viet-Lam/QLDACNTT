#!/usr/bin/env python3
"""
Sync Jira issues to GitHub Issues.

Required environment variables:
  JIRA_BASE_URL       https://your-site.atlassian.net
  JIRA_EMAIL          Jira account email
  JIRA_API_TOKEN      Jira API token
  GITHUB_TOKEN        GitHub fine-grained/classic token with Issues write access
  GITHUB_REPOSITORY   owner/repo, for example Nguyen-Viet-Lam/QLDACNTT

Optional environment variables:
  JIRA_JQL            JQL query. Default: project = MBA ORDER BY updated DESC
  GITHUB_LABELS       Comma-separated extra labels. Default: jira
  SYNC_DRY_RUN        true/false. Default: true
  UPDATE_EXISTING     true/false. Default: true
  JIRA_MAX_RESULTS    Page size. Default: 50

You can also put the same KEY=value pairs in tools/.env. Environment variables
already set in PowerShell take priority over values from that file.
"""

from __future__ import annotations

import base64
import json
import os
import sys
from dataclasses import dataclass
from typing import Any
from urllib.error import HTTPError, URLError
from urllib.parse import quote
from urllib.request import Request, urlopen


JIRA_FIELDS = [
    "summary",
    "status",
    "assignee",
    "description",
    "issuetype",
    "priority",
    "created",
    "updated",
    "duedate",
    "labels",
    "components",
    "fixVersions",
    "parent",
]


if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8")
    sys.stderr.reconfigure(encoding="utf-8")


@dataclass(frozen=True)
class Config:
    jira_base_url: str
    jira_email: str
    jira_api_token: str
    jira_jql: str
    github_token: str
    github_repository: str
    github_labels: list[str]
    dry_run: bool
    update_existing: bool
    jira_max_results: int


def env_bool(name: str, default: bool) -> bool:
    value = os.getenv(name)
    if value is None:
        return default
    return value.strip().lower() in {"1", "true", "yes", "y", "on"}


def load_local_env() -> None:
    env_path = os.path.join(os.path.dirname(__file__), ".env")
    if not os.path.exists(env_path):
        return

    with open(env_path, "r", encoding="utf-8") as env_file:
        for raw_line in env_file:
            line = raw_line.strip()
            if not line or line.startswith("#") or "=" not in line:
                continue
            key, value = line.split("=", 1)
            key = key.strip()
            value = value.strip().strip('"').strip("'")
            if key and key not in os.environ:
                os.environ[key] = value


def load_config() -> Config:
    missing = [
        name
        for name in [
            "JIRA_BASE_URL",
            "JIRA_EMAIL",
            "JIRA_API_TOKEN",
            "GITHUB_TOKEN",
            "GITHUB_REPOSITORY",
        ]
        if not os.getenv(name)
    ]
    if missing:
        raise SystemExit("Missing required env vars: " + ", ".join(missing))

    labels = [
        label.strip()
        for label in os.getenv("GITHUB_LABELS", "jira").split(",")
        if label.strip()
    ]

    return Config(
        jira_base_url=os.environ["JIRA_BASE_URL"].rstrip("/"),
        jira_email=os.environ["JIRA_EMAIL"],
        jira_api_token=os.environ["JIRA_API_TOKEN"],
        jira_jql=os.getenv("JIRA_JQL", "project = MBA ORDER BY updated DESC"),
        github_token=os.environ["GITHUB_TOKEN"],
        github_repository=os.environ["GITHUB_REPOSITORY"],
        github_labels=labels,
        dry_run=env_bool("SYNC_DRY_RUN", True),
        update_existing=env_bool("UPDATE_EXISTING", True),
        jira_max_results=int(os.getenv("JIRA_MAX_RESULTS", "50")),
    )


def request_json(
    url: str,
    *,
    method: str = "GET",
    headers: dict[str, str] | None = None,
    body: dict[str, Any] | None = None,
) -> Any:
    data = None
    request_headers = headers.copy() if headers else {}
    if body is not None:
        data = json.dumps(body).encode("utf-8")
        request_headers["Content-Type"] = "application/json"

    request = Request(url, data=data, headers=request_headers, method=method)
    try:
        with urlopen(request, timeout=30) as response:
            raw = response.read().decode("utf-8")
            return json.loads(raw) if raw else {}
    except HTTPError as exc:
        detail = exc.read().decode("utf-8", errors="replace")
        raise RuntimeError(f"{method} {url} failed: {exc.code} {detail}") from exc
    except URLError as exc:
        raise RuntimeError(f"{method} {url} failed: {exc.reason}") from exc


def jira_headers(config: Config) -> dict[str, str]:
    auth = base64.b64encode(
        f"{config.jira_email}:{config.jira_api_token}".encode("utf-8")
    ).decode("ascii")
    return {"Accept": "application/json", "Authorization": f"Basic {auth}"}


def github_headers(config: Config) -> dict[str, str]:
    return {
        "Accept": "application/vnd.github+json",
        "Authorization": f"Bearer {config.github_token}",
        "User-Agent": "QLDACNTT-Jira-GitHub-Sync",
        "X-GitHub-Api-Version": "2022-11-28",
    }


def fetch_jira_issues(config: Config) -> list[dict[str, Any]]:
    issues: list[dict[str, Any]] = []
    next_page_token: str | None = None

    while True:
        body: dict[str, Any] = {
            "jql": config.jira_jql,
            "maxResults": config.jira_max_results,
            "fields": JIRA_FIELDS,
        }
        if next_page_token:
            body["nextPageToken"] = next_page_token

        response = request_json(
            f"{config.jira_base_url}/rest/api/3/search/jql",
            method="POST",
            headers=jira_headers(config),
            body=body,
        )
        page = response.get("issues", [])
        issues.extend(page)

        next_page_token = response.get("nextPageToken")
        if not next_page_token or not page:
            return issues


def adf_to_text(node: Any) -> str:
    if node is None:
        return ""
    if isinstance(node, str):
        return node
    if isinstance(node, list):
        return "".join(adf_to_text(child) for child in node)
    if not isinstance(node, dict):
        return ""

    text = node.get("text", "")
    content = adf_to_text(node.get("content", []))
    node_type = node.get("type")
    suffix = "\n" if node_type in {"paragraph", "heading", "listItem"} else ""
    if node_type in {"bulletList", "orderedList"}:
        suffix = "\n"
    return text + content + suffix


def compact_lines(value: str) -> str:
    lines = [line.rstrip() for line in value.splitlines()]
    compacted: list[str] = []
    previous_blank = False
    for line in lines:
        blank = not line.strip()
        if blank and previous_blank:
            continue
        compacted.append(line)
        previous_blank = blank
    return "\n".join(compacted).strip()


def field_name(value: Any) -> str:
    return value.get("name", "") if isinstance(value, dict) else ""


def build_github_issue(issue: dict[str, Any], config: Config) -> dict[str, Any]:
    fields = issue.get("fields", {})
    key = issue["key"]
    summary = fields.get("summary") or "(No summary)"
    status = field_name(fields.get("status"))
    assignee = fields.get("assignee") or {}
    issue_type = field_name(fields.get("issuetype"))
    priority = field_name(fields.get("priority"))
    description = compact_lines(adf_to_text(fields.get("description")))
    jira_url = f"{config.jira_base_url}/browse/{quote(key)}"

    metadata_rows = [
        ("Jira", f"[{key}]({jira_url})"),
        ("Type", issue_type),
        ("Status", status),
        ("Priority", priority),
        ("Assignee", assignee.get("displayName", "")),
        ("Created", fields.get("created", "")),
        ("Updated", fields.get("updated", "")),
        ("Due date", fields.get("duedate", "")),
    ]
    metadata = "\n".join(
        f"- **{label}:** {value}" for label, value in metadata_rows if value
    )

    body_parts = [
        "<!-- jira-sync -->",
        f"<!-- jira-key: {key} -->",
        metadata,
    ]
    if description:
        body_parts.extend(["", "## Jira description", description])

    status_obj = fields.get("status") or {}
    status_cat = (status_obj.get("statusCategory") or {}).get("key", "").lower()
    is_done = (status_cat == "done") or (status.lower() == "done")

    payload: dict[str, Any] = {
        "title": f"{key}: {summary}",
        "body": "\n".join(body_parts).strip() + "\n",
        "labels": config.github_labels,
        "state": "closed" if is_done else "open",
    }
    if is_done:
        payload["state_reason"] = "completed"

    return payload


def extract_jira_key(body: str | None) -> str | None:
    if not body:
        return None
    marker = "<!-- jira-key:"
    for line in body.splitlines():
        if marker in line:
            return line.split(marker, 1)[1].split("-->", 1)[0].strip()
    return None


def fetch_existing_github_issues(config: Config) -> dict[str, dict[str, Any]]:
    existing_by_key: dict[str, dict[str, Any]] = {}
    page = 1
    per_page = 100

    while True:
        url = (
            f"https://api.github.com/repos/{config.github_repository}/issues"
            f"?state=all&per_page={per_page}&page={page}"
        )
        response = request_json(url, headers=github_headers(config))
        items = response if isinstance(response, list) else []
        for item in items:
            if "pull_request" in item:
                continue
            jira_key = extract_jira_key(item.get("body"))
            if jira_key:
                existing_by_key[jira_key] = item

        if len(items) < per_page:
            return existing_by_key
        page += 1


def ensure_label(config: Config, label: str) -> None:
    owner_repo = config.github_repository
    encoded_label = quote(label, safe="")
    headers = github_headers(config)
    get_url = f"https://api.github.com/repos/{owner_repo}/labels/{encoded_label}"
    try:
        request_json(get_url, headers=headers)
        return
    except RuntimeError as exc:
        if "failed: 404" not in str(exc):
            raise

    request_json(
        f"https://api.github.com/repos/{owner_repo}/labels",
        method="POST",
        headers=headers,
        body={"name": label, "color": "1d76db", "description": "Synced from Jira"},
    )


def create_or_update_github_issue(
    config: Config, jira_issue: dict[str, Any], existing_by_key: dict[str, dict[str, Any]]
) -> tuple[str, str]:
    github_issue = build_github_issue(jira_issue, config)
    key = jira_issue["key"]
    existing = existing_by_key.get(key)

    if existing:
        if not config.update_existing:
            return key, f"skip existing #{existing['number']}"
        state_str = github_issue.get("state", "open")
        if config.dry_run:
            return key, f"would update #{existing['number']} [{state_str}]: {github_issue['title']}"
        request_json(
            existing["url"],
            method="PATCH",
            headers=github_headers(config),
            body=github_issue,
        )
        return key, f"updated #{existing['number']} [{state_str}]"

    state_str = github_issue.get("state", "open")
    if config.dry_run:
        return key, f"would create [{state_str}]: {github_issue['title']}"

    create_payload = {k: v for k, v in github_issue.items() if k not in ("state", "state_reason")}
    created = request_json(
        f"https://api.github.com/repos/{config.github_repository}/issues",
        method="POST",
        headers=github_headers(config),
        body=create_payload,
    )
    if state_str == "closed" and isinstance(created, dict) and "url" in created:
        request_json(
            created["url"],
            method="PATCH",
            headers=github_headers(config),
            body={"state": "closed", "state_reason": "completed"},
        )
    return key, f"created [{state_str}]"


def main() -> int:
    load_local_env()
    config = load_config()
    issues = fetch_jira_issues(config)
    print(f"Fetched {len(issues)} Jira issue(s) with JQL: {config.jira_jql}")
    print(f"Target GitHub repository: {config.github_repository}")
    print(f"Dry run: {config.dry_run}")

    if not config.dry_run:
        for label in config.github_labels:
            ensure_label(config, label)

    existing_by_key = fetch_existing_github_issues(config)
    print(f"Found {len(existing_by_key)} GitHub issue(s) with Jira markers.")

    for jira_issue in issues:
        key, result = create_or_update_github_issue(config, jira_issue, existing_by_key)
        print(f"{key}: {result}")

    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except RuntimeError as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        raise SystemExit(1)
