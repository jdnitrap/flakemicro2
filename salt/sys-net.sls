# sys-net microVM
sys-net-start:
  cmd.run:
    - name: systemctl start microvm@sys-net
    - unless: systemctl is-active --quiet microvm@sys-net

sys-net-status:
  cmd.run:
    - name: systemctl is-active microvm@sys-net || true
