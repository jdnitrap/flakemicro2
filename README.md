# flakemicro2

Day-to-day Qubes-inspired NixOS MicroVM system using microvm.nix.

## What you get
- XFCE host with admin user (`admin` / `changeme`, mutable users)
- Explicit templates: `minimal`, `workstation`
- Purpose VMs: `sys-net`, `personal`, `work`
- GUI manager for start/stop/status, temporary sessions, and labeled VM creation
- Salt state skeletons
- Deploy and networking guides

## Deploy
See `docs/deploy.md`.

```bash
git clone https://github.com/jdnitrap/flakemicro2.git
cd flakemicro2
# add hardware-configuration.nix, uncomment import, then:
sudo nixos-rebuild switch --flake .#host
python3 scripts/gui-launcher.py
```

## Daily use
- GUI: start/stop purpose VMs, launch temporary sessions, create labeled VMs.
- Labeled VM stubs land in `~/.flakemicro2/` — paste into the flake and rebuild.
- Networking isolation steps: `docs/networking.md`.

## Files
- `flake.nix` — host, templates, VMs
- `scripts/gui-launcher.py` — day-to-day manager
- `salt/` — orchestration states
- `docs/deploy.md`, `docs/networking.md`

Handbook: https://microvm-nix.github.io/microvm.nix/
