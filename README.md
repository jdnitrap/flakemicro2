# flakemicro2

NixOS MicroVMs using [microvm.nix](https://github.com/microvm-nix/microvm.nix).

## Quick start

```bash
# Clone and enter
git clone https://github.com/jdnitrap/flakemicro2.git
cd flakemicro2

# Run the example MicroVM (QEMU + user networking)
nix run .#my-microvm
```

Login as `root` with an empty password.

## Notes

- Default hypervisor is QEMU with user-mode networking (no host network config required).
- Shares the host `/nix/store` via 9p and provides a writable overlay.
- Edit `flake.nix` to add more VMs, change RAM/CPU, hypervisor, shares, volumes, etc.
- Handbook: https://microvm-nix.github.io/microvm.nix/

## Requirements

- Nix with flakes enabled
- `/dev/kvm` available (KVM)
