// 把 repo 的 settings.json 合併進 ~/.claude/settings.json。
// 物件遞迴合併、陣列取聯集、純值以 repo 為準；~/.claude 裡 repo 沒有的 key 保留不動
// （例如 app 自己寫進去的 enabledPlugins 或 model）。
const fs = require('fs');
const path = require('path');
const os = require('os');

const repoFile = path.join(__dirname, '..', 'settings.json');
const userFile = path.join(os.homedir(), '.claude', 'settings.json');

const isObj = (v) => v && typeof v === 'object' && !Array.isArray(v);

function merge(base, over) {
  if (Array.isArray(base) && Array.isArray(over)) {
    return [...base, ...over.filter((x) => !base.some((b) => JSON.stringify(b) === JSON.stringify(x)))];
  }
  if (isObj(base) && isObj(over)) {
    const out = { ...base };
    for (const k of Object.keys(over)) out[k] = k in base ? merge(base[k], over[k]) : over[k];
    return out;
  }
  return over;
}

const repo = JSON.parse(fs.readFileSync(repoFile, 'utf8'));
let user = {};
if (fs.existsSync(userFile)) {
  const raw = fs.readFileSync(userFile, 'utf8');
  user = JSON.parse(raw);
  const stamp = new Date().toISOString().replace(/[-:T]/g, '').slice(0, 14);
  fs.mkdirSync(path.join(os.homedir(), '.claude', 'backups'), { recursive: true });
  fs.writeFileSync(path.join(os.homedir(), '.claude', 'backups', `settings.json.${stamp}`), raw);
}
const merged = merge(user, repo);
fs.mkdirSync(path.dirname(userFile), { recursive: true });
fs.writeFileSync(userFile, JSON.stringify(merged, null, 2) + '\n');
console.log(`settings.json 已合併到 ${userFile}`);
// 印出要裝的外掛，給安裝腳本用
for (const [id, on] of Object.entries(repo.enabledPlugins || {})) if (on) console.log(`plugin:${id}`);
