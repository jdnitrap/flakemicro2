# Day-to-day deploy

Host name is set to `nixqubes`.

1. Clone the repo on the NixOS host.
2. Place your machine's `hardware-configuration.nix` in the repo root (it will be imported when you uncomment the line in flake.nix).
3. Uncomment `./hardware-configuration.nix` in the host modules in `flake.nix`.
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

## Daily use
- Start/stop purpose VMs from the GUI.
- Launch a temporary VM (disposable session).
- Create a labeled VM → stub lands in `~/.flakemicro2/` → copy the generated config into the flake and rebuild to make it permanent.
