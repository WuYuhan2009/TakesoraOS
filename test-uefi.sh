#!/usr/bin/env bash
set -euo pipefail

ISO_PATH="${1:-output/takesoraos-amd64.iso}"
OVMF_CODE="${OVMF_CODE:-/usr/share/OVMF/OVMF_CODE.fd}"
OVMF_VARS_LOCAL="${OVMF_VARS_LOCAL:-./OVMF_VARS.fd}"

if [[ ! -f "$ISO_PATH" ]]; then
  echo "ISO not found: $ISO_PATH"
  exit 1
fi

if [[ ! -f "$OVMF_CODE" ]]; then
  echo "OVMF firmware not found: $OVMF_CODE"
  exit 1
fi

if [[ ! -f "$OVMF_VARS_LOCAL" ]]; then
  cp /usr/share/OVMF/OVMF_VARS.fd "$OVMF_VARS_LOCAL"
fi

qemu-system-x86_64 \
  -m 4096 \
  -smp 4 \
  -enable-kvm \
  -cdrom "$ISO_PATH" \
  -drive if=pflash,format=raw,readonly=on,file="$OVMF_CODE" \
  -drive if=pflash,format=raw,file="$OVMF_VARS_LOCAL" \
  -vga virtio \
  -net nic -net user \
  -cpu host
