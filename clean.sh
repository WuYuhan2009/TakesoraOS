#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

lb clean --purge || true
rm -rf chroot binary cache .build config/bootstrap config/chroot config/common config/source
rm -f ./*.iso ./*.hybrid.iso
rm -rf output
rm -f build.log

echo "[INFO] Cleaned build artifacts."
