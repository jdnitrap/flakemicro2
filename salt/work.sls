# work microVM
work-start:
  cmd.run:
    - name: systemctl start microvm@work
    - unless: systemctl is-active --quiet microvm@work

work-status:
  cmd.run:
    - name: systemctl is-active microvm@work || true
