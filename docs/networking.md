# Network isolation (sys-net style)

Current configs use QEMU user networking for simplicity (no host setup).

## Goal
Only the `sys-net` microVM sees the physical NIC. Other VMs talk to sys-net via a host bridge.

## Steps on the host
1. Create a bridge (example `br0`):
   ```bash
   sudo ip link add br0 type bridge
   sudo ip link set br0 up
   ```
2. Move the physical interface into the bridge (or use NetworkManager).
3. In `flake.nix`, change sys-net's interface to:
   ```nix
   microvm.interfaces = [{
     type = "tap";
     id = "vm-sys-net";
     mac = "02:00:00:00:00:10";
   }];
   ```
   and attach the tap to `br0` (microvm host module can help with TAP creation).
4. Give personal/work VMs their own taps on the same bridge, or route them through sys-net.
5. Rebuild the host and start sys-net first.

See microvm.nix docs on interfaces for TAP/bridge details.
