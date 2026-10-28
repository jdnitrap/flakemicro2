# flakemicro2

Qubes-inspired architectural model on NixOS using [microvm.nix](https://github.com/microvm-nix/microvm.nix).

## Architecture

- **Host (Dom0-like)**: XFCE desktop, admin user (password `changeme`), mutable users, Salt, microvm host module.
- **Templates**: Shared NixOS base (`templateBase`) that purpose VMs inherit from.
- **Purpose microVMs**:
  - `sys-net` — dedicated network domain
  - `personal` — personal use
  - `work` — work use
- **Temporary / disposable**: GUI can launch one-off VMs (overlay discarded on shutdown).
- **Labeled persistent VMs**: GUI creates a stub in `~/.flakemicro2/` that you import into the flake.
- **Management**:
  - Flake + systemd units / `microvm` CLI
  - Salt states under `salt/`
  - GUI manager: `scripts/gui-launcher.py` (tkinter) + desktop entry

## Quick start

```bash
git clone https://github.com/jdnitrap/flakemicro2.git
cd flakemicro2

# Test a purpose VM
nix run .#personal

# Evaluate host
nixos-rebuild build --flake .#host

# Launch GUI manager
python3 scripts/gui-launcher.py
```

Host admin: `admin` / `changeme`. Root inside VMs: empty password.

## Files

- `flake.nix` — host + VMs + template base
- `salt/` — top.sls + per-VM states
- `scripts/gui-launcher.py` — GUI (start/stop, temporary, create labeled)
- `scripts/launch-vm.sh` — CLI helper
- `share/applications/flakemicro2-manager.desktop`

## Next steps (when you deploy)

- Add your `hardware-configuration.nix` to the host.
- Wire real TAP/bridge networking so only sys-net sees the NIC.
- Import GUI-generated stubs into `microvm.vms` and rebuild.
- Expand Salt states to drive create/dispose fully.

Handbook: https://microvm-nix.github.io/microvm.nix/
