#!/usr/bin/env bash
# comment-guard：攔截 AI 常見的「修改歷程型」註解
#
# 用法：
#   check_comments.sh               檢查已 staged 的新增行（pre-commit 用）
#   check_comments.sh --range A..B  檢查一段 commit 範圍的新增行（CI 用）
#   check_comments.sh --all         掃描整個 repo（第一次清理用）
#
# 自訂：在 repo 根目錄放 .commentguard，每行一個額外的正規表示式（# 開頭為註解）。
# 豁免：在該行加上「comment-guard: ignore」。

set -u

usage() { sed -n '2,11p' "$0" | sed 's/^# \{0,1\}//'; }

MODE="staged"
RANGE=""
while [ $# -gt 0 ]; do
  case "$1" in
    --all) MODE="all" ;;
    --range) MODE="range"; RANGE="${2:-}"; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "未知參數：$1" >&2; usage; exit 2 ;;
  esac
  shift
done

root=$(git rev-parse --show-toplevel 2>/dev/null) || { echo "不在 git repo 內" >&2; exit 2; }
cd "$root" || exit 2

# 預設樣式：只收「幾乎不可能是好註解」的字樣，避免誤判
PATTERNS='已修正|已修改|已更新|修正後|修改後|改成使用|依照?(你的|使用者的?)?要求|按照(你的)?要求|如你所要求|根據你的(要求|指示)|(^|[^A-Za-z])(NEW|UPDATED|FIXED|CHANGED|MODIFIED|ADDED)[[:space:]]*:|as requested|per (your|the user.?s) request|changed from .+ to |fixed per (review|feedback)'

if [ -f .commentguard ]; then
  while IFS= read -r p || [ -n "$p" ]; do
    case "$p" in ''|'#'*) continue ;; esac
    PATTERNS="$PATTERNS|$p"
  done < .commentguard
fi

# 依副檔名回傳註解起始符號的正規表示式；不支援的類型回傳空字串
marker_for() {
  case "$1" in
    *.do|*.ado|*.doh|*.mata|*.class)          echo '^[[:space:]]*\*|//|/\*' ;;
    *.py|*.r|*.R|*.Rmd|*.qmd|*.sh|*.bash|*.zsh|*.rb|*.pl|*.jl|*.yml|*.yaml|*.toml|*.ps1|*.mk|Makefile|Dockerfile) echo '#' ;;
    *.js|*.jsx|*.ts|*.tsx|*.mjs|*.cjs|*.java|*.c|*.h|*.cpp|*.hpp|*.cs|*.go|*.rs|*.swift|*.kt|*.scala|*.php|*.css|*.scss|*.less|*.dart) echo '//|/\*|^[[:space:]]*\*' ;;
    *.sql|*.lua|*.hs)                          echo '--' ;;
    *.tex|*.sty|*.bib|*.m)                     echo '%' ;;
    *.html|*.htm|*.xml|*.svg|*.vue|*.md)       echo '<!--' ;;
    *) echo '' ;;
  esac
}

found=0
report() { printf '%s:%s: %s\n' "$1" "$2" "$3"; found=1; }

# 從 diff 取出新增行，輸出「行號:內容」
added_lines() {
  awk '
    /^@@/ { match($0, /\+[0-9]+/); ln = substr($0, RSTART + 1, RLENGTH - 1) - 1; next }
    /^\+\+\+/ { next }
    /^\+/ { ln++; print ln ":" substr($0, 2); next }
  '
}

check_diff() {  # $@ = git diff 的額外參數
  git diff "$@" --name-only --diff-filter=ACMR | while IFS= read -r f; do
    m=$(marker_for "$f"); [ -z "$m" ] && continue
    re="($m).*($PATTERNS)"
    git diff "$@" -U0 -- "$f" | added_lines | while IFS= read -r l; do
      text=${l#*:}
      if printf '%s\n' "$text" | grep -Eiq -- "$re" &&
         ! printf '%s\n' "$text" | grep -q 'comment-guard: ignore'; then
        printf '%s:%s: %s\n' "$f" "${l%%:*}" "$text"
      fi
    done
  done
}

case "$MODE" in
  staged) out=$(check_diff --cached) ;;
  range)  [ -z "$RANGE" ] && { echo "--range 需要指定範圍" >&2; exit 2; }
          out=$(check_diff "$RANGE") ;;
  all)
    out=$(git ls-files | while IFS= read -r f; do
      [ -f "$f" ] || continue
      m=$(marker_for "$f"); [ -z "$m" ] && continue
      grep -nEi -- "($m).*($PATTERNS)" "$f" 2>/dev/null | grep -v 'comment-guard: ignore' | sed "s|^|$f:|"
    done) ;;
esac

if [ -n "$out" ]; then
  echo "comment-guard：偵測到修改歷程型註解"
  echo "$out"
  echo
  echo "修改說明請寫在 commit message。若確定要保留，在該行加上「comment-guard: ignore」。"
  exit 1
fi
exit 0
