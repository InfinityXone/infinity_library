#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="/home/etherverse/infinity_library"
cd "$REPO_DIR"

echo "[SYNC] Starting git sync at \$(date)"

# Stage changes
git add -A || true

# Commit if there is anything to commit
if ! git diff --cached --quiet; then
  git commit -m "Auto-sync: \$(date '+%Y-%m-%d %H:%M:%S')" || true
fi

# Pull latest
git pull --rebase --autostash || true

# Push changes
git push origin main || true

echo "[SYNC] Completed at \$(date)"
