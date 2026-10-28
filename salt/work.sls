# Purpose VM: work
work-present:
  cmd.run:
    - name: echo "work VM declared"
    - unless: systemctl is-active microvm@work
