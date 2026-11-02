// Chạy lại các kịch bản .http bằng Node (không cần VS Code REST Client). Ghi kết quả JSON vào tests/results/.
import fs from "fs";
const BASE = process.env.API_BASE_URL || "http://localhost:5055";
const tokens = {};
async function call(method, path, headers, body) {
  const t0 = performance.now();
  try {
    const r = await fetch(BASE + path, { method, headers, body });
    const text = await r.text();
    return { status: r.status, ms: Math.round(performance.now() - t0), text };
  } catch (e) { return { status: 0, ms: 0, text: String(e) }; }
}
async function login(u) {
  const r = await call("POST", "/api/auth/login", { "Content-Type": "application/json" }, JSON.stringify({ username: u, password: "123456" }));
  try { return JSON.parse(r.text).token; } catch { return ""; }
}
for (const [k, u] of [["admin", "admin"], ["staff", "staff01"], ["tech", "tech01"], ["customer", "khach01"]]) tokens[k] = await login(u);
// Token cố định trong file pentest -> thay bằng token đăng nhập thật cùng vai trò
const alias = { "token-customer-demo-session": "customer", "token-khach01-session": "customer", "token-staff01-session": "staff", "token-tech01-session": "tech" };

function parse(file, prefix) {
  const raw = fs.readFileSync(file, "utf8").replace(/\r/g, "");
  const parts = raw.split(/\n(?=### \[(?:Request|PenTest) )/).slice(1);
  return parts.map((p) => {
    const lines = p.split("\n");
    const title = lines[0].replace(/^### /, "");
    const exp = (p.match(/Mong đợi:\s*(\d{3})/) || [])[1];
    const i = lines.findIndex((l) => /^(GET|POST|PUT|PATCH|DELETE) /.test(l));
    const [method, url] = lines[i].split(" ");
    const headers = {}; let j = i + 1;
    for (; j < lines.length && lines[j].trim() !== "" && !lines[j].startsWith("###"); j++) {
      const m = lines[j].match(/^([\w-]+):\s*(.*)$/); if (m) headers[m[1]] = m[2];
    }
    let body = []; for (; j < lines.length && !lines[j].startsWith("###"); j++) body.push(lines[j]);
    body = body.join("\n").trim() || undefined;
    return { id: title.match(/\[(.*?)\]/)[1], title: title.replace(/\[.*?\]\s*/, ""), method, url: url.replace("{{baseUrl}}", ""), headers, body, exp: exp ? +exp : null };
  });
}
const out = [];
async function runSet(file, suite) {
  for (const t of parse(file)) {
    const h = { ...t.headers };
    if (h["X-Session-Token"]) {
      const m = h["X-Session-Token"].match(/^\{\{(\w+)Token\}\}$/);
      if (m) h["X-Session-Token"] = tokens[m[1] === "tech" ? "tech" : m[1]];
      else if (alias[h["X-Session-Token"]]) h["X-Session-Token"] = tokens[alias[h["X-Session-Token"]]];
    }
    const r = await call(t.method, t.url, h, t.body);
    let exp = t.exp, note = "";
    if (exp === null) { exp = 201; note = "kịch bản XSS: kỳ vọng API lưu dạng văn bản thuần (2xx), không thực thi"; }
    const pass = t.exp === null ? r.status >= 200 && r.status < 300 : r.status === exp;
    out.push({ suite, id: t.id, title: t.title, method: t.method, url: t.url, expected: t.exp ?? "2xx", actual: r.status, ms: r.ms, pass, note, resp: r.text.slice(0, 160) });
    console.log(`${pass ? "PASS" : "FAIL"} ${suite} ${t.id} ${t.method} ${t.url} exp=${t.exp ?? "2xx"} got=${r.status} ${r.ms}ms`);
  }
}
await runSet("tests/QLDACNTT_Api_Tests.http", "API");
await runSet("tests/security/penetration_security_test.http", "PENTEST");
fs.writeFileSync("tests/results/http_results.json", JSON.stringify({ runAt: new Date().toISOString(), results: out }, null, 1));
const f = out.filter((x) => !x.pass).length; console.log(`TOTAL ${out.length}, FAIL ${f}`);
