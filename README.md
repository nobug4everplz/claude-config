# claude-config

Windows 和 MacBook 共用的 Claude Code 個人設定。

| 檔案 | 怎麼接到 `~/.claude` | 什麼時候生效 |
| :- | :- | :- |
| `CLAUDE.md` | `~/.claude/CLAUDE.md` 只有一行 `@` 匯入 | pull 完，下一個 session |
| `skills/` | Windows junction / Mac symlink | pull 完，下一個 session |
| `settings.json` | 合併進 `~/.claude/settings.json`（Windows 沒有管理員權限不能 symlink） | 重跑安裝腳本後 |

合併規則（`scripts/merge-settings.js`）：物件遞迴合併、陣列取聯集、純值以 repo 為準。`~/.claude/settings.json` 裡 repo 沒有的 key 會保留，合併前會備份到 `~/.claude/backups/`。從 repo 刪掉的規則不會自動從 `~/.claude` 刪掉，要手動刪。

## settings.json 內容

- `language`：回答語言固定為繁體中文。
- `remoteControlAtStartup`：每個新 session 自動連 Remote Control，iPhone 隨時看得到。
- `permissions.deny`：擋 Claude 讀 `~/.ssh`、`~/.aws`、`~/.gnupg`、`gh` 的 token、專案裡的 `.env`、`.env.*`（包括 `.env.example`）和 `secrets/`。這只擋檔案工具和直接點名檔案的指令，擋不住所有繞法。
- `permissions.ask`：`git push` 一律先問。
- `extraKnownMarketplaces`：第三方外掛的來源 repo。
- `enabledPlugins`：

| 外掛 | 來源 | 用途 |
| :- | :- | :- |
| `context7` | 官方 | 查函式庫的最新文件 |
| `claude-md-management` | 官方 | 檢查、更新 CLAUDE.md |
| `security-guidance` | 官方 | 改程式時提醒安全問題 |
| `superpowers` | 官方 | 腦力激盪、計畫、TDD、除錯等工作流程 |
| `claude-mem` | thedotmack/claude-mem | 跨 session 的記憶 |
| `understand-anything` | Egonex-AI/Understand-Anything | 把 codebase 畫成知識圖譜 |
| `last30days` | mvanhorn/last30days-skill | 查某個主題近 30 天的討論 |
| `humanizer` | blader/humanizer | 改掉文字裡的 AI 腔 |
| `ppt-master` | hugohe3/ppt-master | 產生、改造 PPTX |

從這裡拿掉的外掛不會自動從 `~/.claude/settings.json` 刪掉（見上方合併規則），兩台都要手動刪。

## skills

| skill | 說明 |
| :- | :- |
| `untrusted-ai-pipeline` | 自己寫的：讓 AI 讀不可信內容、或把 Claude 放進 CI 時的檢查清單 |
| `agent-reach` | `agent-reach` setup 產生，上游 Panniantong/Agent-Reach；要更新就重跑 setup，不要手改 |

## 安裝

需要 Git 和 Node.js。外掛用 PATH 上的 `claude`，沒有的話用桌面 app 內建的那份。

Windows（PowerShell）：

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

Mac：

```bash
zsh ./install.sh
```

`security-guidance` 需要 Python 3.10 以上（Windows 要用 python.org 版，不能只有 Microsoft Store 的捷徑），第一次啟動 session 時會在 `~/.claude/security/` 建一個 venv。
