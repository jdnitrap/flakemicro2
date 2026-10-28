# Host (Dom0-like) state
# Orchestrates microVM lifecycle via systemctl / microvm CLI

ensure-microvm-services:
  cmd.run:
    - name: systemctl daemon-reload
    - unless: systemctl is-active microvm@personal
