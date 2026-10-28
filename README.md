# flakemicro2

Day-to-day Qubes-inspired NixOS MicroVM system using microvm.nix.

## What you get
- XFCE host named `nixqubes` with admin user (`admin` / `changeme`, mutable users)
- Explicit templates: `minimal`, `workstation`
- Purpose VMs: `sys-net`, `personal`, `work`
- GUI manager for start/stop/status, temporary sessions, and labeled VM creation
- Salt state skeletons
- Deploy and networking guides

## Structure
- `flake.nix` — thin entry point
- `modules/host.nix` — host configuration
- `modules/templates.nix` — microVM templates
- `scripts/gui-launcher.py` — day-to-day manager
- `salt/` — orchestration states
- `docs/deploy.md`, `docs/networking.md`

## Deploy (no clone)

```bash
sudo nixos-rebuild switch --flake github:jdnitrap/flakemicro2#host
```

The flake imports `/etc/nixos/hardware-configuration.nix` from the machine.

After switch, log in as `admin` / `changeme` and run the manager.

## Daily use
- GUI: start/stop purpose VMs, launch temporary sessions, create labeled VMs.
- Labeled VM stubs land in `~/.flakemicro2/` — paste into the flake and rebuild.
- Networking isolation steps: `docs/networking.md`.

Handbook: https://microvm-nix.github.io/microvm.nix/
