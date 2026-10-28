# Purpose VM: personal
# Can be expanded to call microvm CLI or systemctl

personal-present:
  cmd.run:
    - name: |
        if ! systemctl is-enabled microvm@personal 2>/dev/null; then
          echo "personal VM declared in flake"
        fi
    - unless: systemctl is-active microvm@personal
