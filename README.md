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
- `enabledPlugins`：官方 marketplace 的 `context7`、`claude-md-management`、`security-guidance`、`superpowers`。

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
