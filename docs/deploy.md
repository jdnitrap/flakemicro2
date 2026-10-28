# Day-to-day deploy

1. Clone the repo on the NixOS host.
2. Copy your `hardware-configuration.nix` into the repo root.
3. Uncomment the import in `flake.nix` under the host modules.
4. (Optional) Follow `docs/networking.md` for real isolation.
5. Build and switch:
   ```bash
   sudo nixos-rebuild switch --flake .#host
   ```
6. Log in as `admin` / `changeme` (change the password).
7. Launch the manager:
   ```bash
   python3 scripts/gui-launcher.py
   ```
   or install the desktop entry.

## Daily use
- Start/stop purpose VMs from the GUI.
- Launch a temporary VM (disposable session).
- Create a labeled VM → stub lands in `~/.flakemicro2/` → copy the generated config into the flake and rebuild to make it permanent.
- Salt: `sudo salt-call state.apply` (after configuring salt master if desired).
