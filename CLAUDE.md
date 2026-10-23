# 個人設定

## 語言
- 一律用繁體中文回答，包括說明、摘要和計畫。
- 程式碼、指令、檔名、錯誤訊息保持原文，不翻譯。

## 我的環境
- 兩台電腦：Windows 10（PowerShell 5.1；`bash` 指向 WSL，不是 Git Bash）和 MacBook（zsh）。
- 主要用 Claude 桌面 app 的 Code 分頁，偶爾用 iPhone 遙控或查詢。
- 給 Windows 的指令要能在 PowerShell 5.1 跑（沒有 `&&`、`||`、`??`）；給 Mac 的指令用 zsh。

## 個人設定 repo
- 個人設定放在 `~/Documents/claude-config`，兩台電腦各自 `git pull` 同步。
- 要改個人設定（這個檔案、skills、settings）時，改 repo 裡的檔案，不要直接改 `~/.claude`。
- `CLAUDE.md` 和 `skills/` 是連結，pull 完就生效；`settings.json` 是合併進 `~/.claude/settings.json` 的，改完或 pull 完要重跑安裝腳本（Windows `install.ps1`、Mac `install.sh`）。
- 新增外掛時，把它加進 repo `settings.json` 的 `enabledPlugins`，再重跑安裝腳本，兩台才會一致。
