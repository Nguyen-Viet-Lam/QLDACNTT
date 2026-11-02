// Bản mô phỏng kịch bản k6_load_test_scenario.js bằng Node (máy chưa cài k6). Cùng kịch bản, cùng stages, cùng ngưỡng.
import fs from "fs";
const BASE = process.env.API_BASE_URL || "http://localhost:5055";
const stages = [[30, 10], [60, 50], [30, 50], [20, 0]];
const total = stages.reduce((a, s) => a + s[0], 0);
const sleep = (s) => new Promise((r) => setTimeout(r, s * 1000));
const lat = []; let reqs = 0, failed = 0, checks = 0, checksFailed = 0, iters = 0;
const per = { login: [], dashboard: [], cost: [], warranty: [] };
async function req(kind, method, path, headers, body, ok) {
  const t0 = performance.now(); let r, j = null;
  try { r = await fetch(BASE + path, { method, headers, body }); const t = await r.text(); try { j = JSON.parse(t); } catch {} } catch { r = { status: 0 }; }
  const ms = performance.now() - t0; lat.push(ms); per[kind].push(ms); reqs++;
  const good = r.status === 200 && ok(j); checks++; if (!good) { checksFailed++; failed++; }
  return j;
}
async function iteration() {
  iters++;
  const l = await req("login", "POST", "/api/auth/login", { "Content-Type": "application/json" }, JSON.stringify({ username: "admin", password: "123456" }), (j) => j && j.token);
  const h = { "X-Session-Token": l?.token || "" };
  await sleep(1);
  await req("dashboard", "GET", "/api/dashboard/summary", h, undefined, (j) => j && j.totalTickets !== undefined);
  await sleep(1);
  await req("cost", "GET", "/api/tickets/PSC202610001/cost", h, undefined, (j) => j && j.grandTotal !== undefined);
  await sleep(1);
  await req("warranty", "GET", "/api/warranties/search?serial=DLXPS-9520-VN01", h, undefined, (j) => j && Array.isArray(j.data));
  await sleep(2);
}
const t0 = Date.now(); let active = 0, maxVU = 0;
const target = (t) => { let acc = 0, prev = 0; for (const [d, g] of stages) { if (t < acc + d) return Math.round(prev + (g - prev) * (t - acc) / d); acc += d; prev = g; } return 0; };
const vu = async (stopAt) => { active++; while ((Date.now() - t0) / 1000 < total && active <= target((Date.now() - t0) / 1000) + 0) await iteration(); active--; };
const running = new Set();
while ((Date.now() - t0) / 1000 < total) {
  const want = target((Date.now() - t0) / 1000);
  while (running.size < want) { const p = (async () => { while ((Date.now() - t0) / 1000 < total && running.size <= target((Date.now() - t0) / 1000)) await iteration(); })().finally(() => running.delete(p)); running.add(p); }
  maxVU = Math.max(maxVU, running.size); await sleep(0.5);
}
await Promise.all(running);
const pct = (a, p) => { const s = [...a].sort((x, y) => x - y); return s[Math.min(s.length - 1, Math.floor(s.length * p))] || 0; };
const st = (a) => ({ avg: +(a.reduce((x, y) => x + y, 0) / a.length).toFixed(1), p95: +pct(a, 0.95).toFixed(1), max: +Math.max(...a).toFixed(1), count: a.length });
const dur = (Date.now() - t0) / 1000;
const res = { runAt: new Date().toISOString(), tool: "Node.js (mô phỏng k6, k6 chưa cài trên máy)", durationSec: +dur.toFixed(0), maxVUs: maxVU, iterations: iters, requests: reqs, rps: +(reqs / dur).toFixed(2), failedRequests: failed, errorRatePct: +(100 * failed / reqs).toFixed(2), overall: st(lat), perEndpoint: Object.fromEntries(Object.entries(per).map(([k, v]) => [k, st(v)])), thresholds: { "p95<500ms": pct(lat, 0.95) < 500, "error<1%": failed / reqs < 0.01 } };
fs.writeFileSync("tests/results/load_results.json", JSON.stringify(res, null, 1)); console.log(JSON.stringify(res, null, 1));
