#!/bin/zsh
# Mac：把這個 repo 接到 ~/.claude。可重複執行。
set -e
repo="${0:A:h}"
claude="$HOME/.claude"
mkdir -p "$claude"

# CLAUDE.md：只放一行 @import，指向 repo 裡的檔案
target="$repo/CLAUDE.md"
if [[ "$target" == "$HOME"/* ]]; then
  line="@~${target#$HOME}"
else
  line="@$target"
fi
stub="$claude/CLAUDE.md"
if [[ -f "$stub" && "$(cat "$stub")" != "$line" ]]; then
  backup="$stub.bak-$(date +%Y%m%d%H%M%S)"
  cp "$stub" "$backup"
  echo "已備份原本的 CLAUDE.md 到 $backup"
fi
print -r -- "$line" > "$stub"
echo "CLAUDE.md -> $line"

# skills：symlink 到 repo/skills
skills="$claude/skills"
if [[ ! -e "$skills" ]]; then
  ln -s "$repo/skills" "$skills"
  echo "skills -> $repo/skills"
elif [[ -L "$skills" ]]; then
  echo "skills 已經接好了"
else
  echo "~/.claude/skills 已存在而且不是連結，沒動它。請先把裡面的 skill 搬進 repo/skills 再刪掉它，然後重跑。"
fi

# settings.json：跟 Windows 一樣用合併的方式，兩台行為一致
if ! command -v node >/dev/null; then
  echo "找不到 node，跳過 settings.json 和外掛。裝好 Node.js（brew install node）後重跑。"
  exit 0
fi
plugins=()
while IFS= read -r l; do
  if [[ "$l" == plugin:* ]]; then plugins+=("${l#plugin:}"); else echo "$l"; fi
done < <(node "$repo/scripts/merge-settings.js")

# 外掛：用 PATH 上的 claude，沒有就用桌面 app 內建的那一份
cli="$(command -v claude || true)"
if [[ -z "$cli" ]]; then
  cli="$(ls -d "$HOME/Library/Application Support/Claude/claude-code/"*/*/claude 2>/dev/null | sort -V | tail -1)"
fi
if [[ -z "$cli" ]]; then
  echo "找不到 claude CLI，跳過外掛安裝。"
  exit 0
fi
if ! "$cli" plugin marketplace list | grep -q claude-plugins-official; then
  "$cli" plugin marketplace add anthropics/claude-plugins-official
fi
installed="$("$cli" plugin list)"
for p in "${plugins[@]}"; do
  if [[ "$installed" == *"$p"* ]]; then
    echo "外掛已安裝：$p"
  else
    "$cli" plugin install "$p" --scope user
  fi
done
