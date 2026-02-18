#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$ROOT_DIR/build.log"
ISO_NAME="takesoraos-amd64.iso"
OUT_DIR="$ROOT_DIR/output"

exec > >(tee "$LOG_FILE") 2>&1

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "[ERROR] Missing command: $1"
    exit 1
  }
}

install_deps() {
  echo "[INFO] Installing build dependencies..."
  sudo apt-get update
  sudo apt-get install -y --no-install-recommends \
    live-build debootstrap squashfs-tools xorriso grub-pc-bin grub-efi-amd64-bin \
    mtools dosfstools gdisk rsync curl jq
}

collect_ai_secrets() {
  local ai_env="$ROOT_DIR/config/includes.chroot/etc/takesora-ai/ai.env"
  local api_key model_name

  if [[ -n "${TAKESORA_AI_API_KEY:-}" ]]; then
    api_key="$TAKESORA_AI_API_KEY"
  else
    read -r -s -p "Enter SiliconFlow API key (leave empty to disable AI service by default): " api_key
    echo
  fi

  if [[ -n "${TAKESORA_AI_MODEL:-}" ]]; then
    model_name="$TAKESORA_AI_MODEL"
  else
    read -r -p "Enter AI model name [deepseek-ai/DeepSeek-V3]: " model_name
    model_name="${model_name:-deepseek-ai/DeepSeek-V3}"
  fi

  install -m 0700 -d "$(dirname "$ai_env")"
  cat > "$ai_env" <<EOT
SILICONFLOW_API_KEY=${api_key}
SILICONFLOW_MODEL=${model_name}
AI_ENABLED_BY_DEFAULT=0
EOT
  chmod 0600 "$ai_env"
}

configure_live_build() {
  echo "[INFO] Configuring live-build..."
  lb clean --purge || true
  lb config \
    --mode debian \
    --distribution bookworm \
    --architectures amd64 \
    --linux-flavours amd64 \
    --binary-images iso-hybrid \
    --archive-areas "main contrib non-free non-free-firmware" \
    --bootappend-live "boot=live components quiet splash locales=zh_CN.UTF-8,en_US.UTF-8 username=user hostname=takesoraos" \
    --debian-installer live \
    --debian-installer-gui true \
    --firmware-binary true \
    --firmware-chroot true \
    --iso-application "TakesoraOS" \
    --iso-publisher "TakesoraOS Project" \
    --iso-volume "TakesoraOS Live" \
    --memtest memtest86+
}

build_iso() {
  echo "[INFO] Building ISO. This can take a while..."
  lb build

  mkdir -p "$OUT_DIR"
  local built_iso
  built_iso="$(find "$ROOT_DIR" -maxdepth 1 -type f -name '*.iso' | head -n1)"
  if [[ -z "$built_iso" ]]; then
    echo "[ERROR] Build completed but no ISO was found."
    exit 1
  fi

  cp -f "$built_iso" "$OUT_DIR/$ISO_NAME"
  (cd "$OUT_DIR" && sha256sum "$ISO_NAME" > sha256.txt)
  echo "[INFO] Output: $OUT_DIR/$ISO_NAME"
  echo "[INFO] SHA256: $OUT_DIR/sha256.txt"
}

main() {
  require_cmd sudo
  require_cmd apt-get
  require_cmd lb

  install_deps
  collect_ai_secrets
  configure_live_build
  build_iso
}

main "$@"
