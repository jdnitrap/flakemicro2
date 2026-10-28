# personal microVM
personal-start:
  cmd.run:
    - name: systemctl start microvm@personal
    - unless: systemctl is-active --quiet microvm@personal

personal-status:
  cmd.run:
    - name: systemctl is-active microvm@personal || true
