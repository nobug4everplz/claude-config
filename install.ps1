# Windows：把這個 repo 接到 ~/.claude。可重複執行。
$ErrorActionPreference = 'Stop'
$repo = $PSScriptRoot
$claude = Join-Path $env:USERPROFILE '.claude'
New-Item -ItemType Directory -Force $claude | Out-Null

# CLAUDE.md：只放一行 @import，指向 repo 裡的檔案
$target = Join-Path $repo 'CLAUDE.md'
if ($target.StartsWith($env:USERPROFILE, [StringComparison]::OrdinalIgnoreCase)) {
    $ref = '~' + $target.Substring($env:USERPROFILE.Length)
} else {
    $ref = $target
}
$line = '@' + $ref.Replace('\', '/')
$stub = Join-Path $claude 'CLAUDE.md'
if (Test-Path $stub) {
    $current = (Get-Content $stub -Raw).Trim()
    if ($current -ne $line) {
        $backup = "$stub.bak-$(Get-Date -Format yyyyMMddHHmmss)"
        Copy-Item $stub $backup
        Write-Host "已備份原本的 CLAUDE.md 到 $backup"
    }
}
[IO.File]::WriteAllText($stub, $line + "`n", (New-Object Text.UTF8Encoding $false))
Write-Host "CLAUDE.md -> $line"

# skills：用 junction 接到 repo/skills（不需要系統管理員或開發者模式）
$skills = Join-Path $claude 'skills'
$repoSkills = Join-Path $repo 'skills'
if (-not (Test-Path $skills)) {
    New-Item -ItemType Junction -Path $skills -Target $repoSkills | Out-Null
    Write-Host "skills -> $repoSkills"
} elseif ((Get-Item $skills).LinkType -eq 'Junction') {
    Write-Host "skills 已經接好了"
} else {
    Write-Host "~/.claude/skills 已存在而且不是連結，沒動它。請先把裡面的 skill 搬進 repo/skills 再刪掉它，然後重跑。"
}

# huashu-motion：skill 要用到上游 repo 裡的 cli/，所以 clone 整個 repo，再把 skill 資料夾用 junction 接進 repo/skills
$hm = Join-Path $env:USERPROFILE 'Documents\huashu-motion'
if (-not (Test-Path $hm)) {
    git clone https://github.com/alchaincyf/huashu-motion.git $hm
}
$hmLink = Join-Path $repoSkills 'huashu-motion'
if (-not (Test-Path $hmLink)) {
    New-Item -ItemType Junction -Path $hmLink -Target (Join-Path $hm 'skills\huashu-motion') | Out-Null
    Write-Host "skills/huashu-motion -> $hm"
} else {
    Write-Host "huashu-motion 已經接好了（更新：git -C $hm pull --ff-only）"
}

# settings.json：Windows 沒有系統管理員權限不能建 symlink，所以用合併的方式寫進去
if (-not (Get-Command node -EA SilentlyContinue)) {
    Write-Host "找不到 node，跳過 settings.json 和外掛。裝好 Node.js 後重跑。"
    return
}
$plugins = @()
node (Join-Path $repo 'scripts\merge-settings.js') | ForEach-Object {
    if ($_ -like 'plugin:*') { $plugins += $_.Substring(7) } else { Write-Host $_ }
}

# 外掛：用 PATH 上的 claude，沒有就用桌面 app 內建的那一份
$cli = (Get-Command claude -EA SilentlyContinue).Source
if (-not $cli) {
    $cli = Get-ChildItem "$env:APPDATA\Claude\claude-code\*\*\claude.exe" -EA SilentlyContinue |
        Sort-Object { [version]$_.Directory.Parent.Name } | Select-Object -Last 1 -ExpandProperty FullName
}
if (-not $cli) {
    Write-Host "找不到 claude CLI，跳過外掛安裝。"
    return
}
$markets = & $cli plugin marketplace list | Out-String
if ($markets -notmatch 'claude-plugins-official') {
    & $cli plugin marketplace add anthropics/claude-plugins-official
}
$installed = & $cli plugin list | Out-String
foreach ($p in $plugins) {
    if ($installed -match [regex]::Escape($p)) {
        Write-Host "外掛已安裝：$p"
    } else {
        & $cli plugin install $p --scope user
    }
}
