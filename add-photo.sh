#!/bin/bash
# Usage: ./add-photo.sh /path/to/photo.jpg "Optional caption" "YYYY-MM-DD"
set -euo pipefail
SITE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PHOTO_PATH="${1:-}"
CAPTION="${2:-}"
CUSTOM_DATE="${3:-$(date +%Y-%m-%d)}"
[[ -z "$PHOTO_PATH" ]] && echo "Usage: $0 <photo> [caption] [date]" && exit 1
[[ ! -f "$PHOTO_PATH" ]] && echo "❌ File not found: $PHOTO_PATH" && exit 1
POST_DIR="$SITE_DIR/content/$CUSTOM_DATE"
mkdir -p "$POST_DIR"
EXT="${PHOTO_PATH##*.}"
cp "$PHOTO_PATH" "$POST_DIR/photo.${EXT}"
DISPLAY_DATE="$(date -d "$CUSTOM_DATE" '+%B %d, %Y' 2>/dev/null || date -jf '%Y-%m-%d' "$CUSTOM_DATE" '+%B %d, %Y')"
cat > "$POST_DIR/index.md" << FRONTMATTER
---
title: "${DISPLAY_DATE}"
date: ${CUSTOM_DATE}T18:46:00+07:00
draft: false
${CAPTION:+description: \"${CAPTION}\"}
---
${CAPTION:+${CAPTION}}
FRONTMATTER
/tmp/hugo --source "$SITE_DIR" --minify --quiet
cd "$SITE_DIR"
git add .
git commit -m "📷 ${CUSTOM_DATE}${CAPTION:+ — ${CAPTION}}"
git push origin main
echo "🚀 Deployed!"
