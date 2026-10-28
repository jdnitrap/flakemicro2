# Host orchestration for microVMs
# Apply with: sudo salt-call --local state.apply host

reload-systemd:
  cmd.run:
    - name: systemctl daemon-reload

ensure-sys-net:
  cmd.run:
    - name: systemctl start microvm@sys-net
    - unless: systemctl is-active --quiet microvm@sys-net
    - require:
      - cmd: reload-systemd

ensure-personal:
  cmd.run:
    - name: systemctl start microvm@personal
    - unless: systemctl is-active --quiet microvm@personal
    - require:
      - cmd: reload-systemd

ensure-work:
  cmd.run:
    - name: systemctl start microvm@work
    - unless: systemctl is-active --quiet microvm@work
    - require:
      - cmd: reload-systemd
