# flakemicro2

Qubes-inspired architectural model on NixOS using [microvm.nix](https://github.com/microvm-nix/microvm.nix).

## Architecture

- **Host (Dom0-like)**: XFCE desktop, admin user (password `changeme`), Salt, microvm host module.
- **Templates**: Shared NixOS base modules that purpose VMs inherit from.
- **Purpose microVMs**:
  - `sys-net` — dedicated network VM
  - `personal` — personal use (browser, office, etc.)
  - `work` — work use
- **Ephemeral / disposable**: Supported via writable overlays that can be discarded; temporary VMs can be created from the same templates.
- **Management**:
  - Declarative via the flake + `microvm` CLI / systemd units.
  - Salt states in `salt/` (top.sls, host.sls, personal.sls, sys-net.sls) for orchestration.
  - Basic GUI launcher sketch: `scripts/gui-launcher.py` (tkinter) + `scripts/launch-vm.sh`.

## Quick start

```bash
git clone https://github.com/jdnitrap/flakemicro2.git
cd flakemicro2

# Build and run a purpose VM directly
nix run .#personal

# Or evaluate the host configuration
nixos-rebuild build --flake .#host

# Try the GUI launcher sketch (needs python3 + tkinter)
python3 scripts/gui-launcher.py
```

Root login inside VMs is empty password. Host admin password is `changeme`.

## Next steps

- Add hardware-configuration.nix for your real host.
- Expand Salt states for create/label/dispose and temporary VMs.
- Turn the GUI sketch into a proper manager (persistent + temporary from templates, labels).
- Harden networking so only sys-net sees the real NIC.

Handbook: https://microvm-nix.github.io/microvm.nix/
