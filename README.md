# flakemicro2

## Scope

Replicate the **Qubes OS architectural model** on NixOS using [microvm.nix](https://github.com/microvm-nix/microvm.nix).

This means the same shape and workflow:

- Trusted host (Dom0-like) that mainly manages VMs
- Templates that other VMs inherit from
- Purpose-specific AppVMs (personal, work, etc.)
- Disposable / temporary VMs
- Dedicated network VM (sys-net) that owns networking
- GUI-driven management from the host
- Declarative control (Nix modules + Salt-style orchestration)

It is **not** a Xen-level security product. Isolation is KVM + microvm.nix on a normal NixOS host. The goal is the Qubes architecture and day-to-day experience, implemented the NixOS way.

## What you get
- XFCE host named `nixqubes` with admin user (`admin` / `changeme`, mutable users)
- Explicit templates: `minimal`, `workstation`
- Purpose VMs: `sys-net`, `personal`, `work`
- GUI manager for start/stop/status, temporary sessions, and labeled VM creation
- Salt states for orchestration
- Deploy and networking guides

## Structure
- `flake.nix` — thin entry point
- `modules/host.nix` — host configuration
- `modules/templates.nix` — microVM templates
- `hardware-configuration.nix` — from the basic repo (ZenBook)
- `scripts/gui-launcher.py` — day-to-day manager
- `salt/` — orchestration states
- `docs/deploy.md`, `docs/networking.md`

## Deploy

```bash
sudo nixos-rebuild switch --flake github:jdnitrap/flakemicro2#nixqubes --no-write-lock-file --refresh
```

After switch, log in as `admin` / `changeme` and run the manager.

## Daily use
- GUI: start/stop purpose VMs, launch temporary sessions, create labeled VMs.
- Labeled VM stubs land in `~/.flakemicro2/` — paste into the flake and rebuild.
- Networking isolation steps: `docs/networking.md`.

Handbook: https://microvm-nix.github.io/microvm.nix/
