#!/usr/bin/env bash
set -euo pipefail

ISO_PATH="${1:-output/takesoraos-amd64.iso}"

if [[ ! -f "$ISO_PATH" ]]; then
  echo "ISO not found: $ISO_PATH"
  exit 1
fi

qemu-system-x86_64 \
  -m 4096 \
  -smp 4 \
  -enable-kvm \
  -boot d \
  -cdrom "$ISO_PATH" \
  -vga virtio \
  -net nic -net user \
  -cpu host
