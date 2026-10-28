#!/usr/bin/env bash
# Simple launcher for microVMs (GUI desktop entries can call this)
set -euo pipefail

VM="${1:-}"
if [[ -z "$VM" ]]; then
  echo "Usage: $0 <vm-name>"
  echo "Available: sys-net personal work"
  exit 1
fi

echo "Starting microVM: $VM"
systemctl start "microvm@$VM" || microvm -u "$VM"
echo "Started. Check with: systemctl status microvm@$VM"
