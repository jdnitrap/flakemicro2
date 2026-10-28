# Hardening / Minimize the TCB

Recommendations for shrinking the trusted computing base on the NixOS + microvm.nix host.

## 1. Shrink the host
- Prefer no full desktop (or the absolute minimum window manager).
- Remove browsers, office suites, and anything not required to run or manage microVMs.
- Disable unnecessary services (Bluetooth, printing, extra networking, etc.).
- Keep only: hypervisor support, networking for the VMs, SSH or a tiny management UI, and the microvm tools.

## 2. Harden the kernel
- Use a hardened or minimal kernel config (disable unused drivers and subsystems).
- Enable AppArmor or SELinux and write tight profiles for host processes.
- Disable module loading after boot if possible (`kernel.modules_disabled=1`).
- Keep the kernel and microcode updated.

## 3. Reduce attack surface
- Avoid 9p/virtiofs shares of sensitive host paths into VMs.
- Only the sys-net VM should see the real NIC; the host itself should have minimal or no external networking.
- Prefer a read-only root on the host where practical.
- Drop capabilities and use seccomp/landlock where possible.

## 4. Minimize userspace
- Keep the host package set small and static.
- Avoid interpreters and large runtimes on the host unless required for the GUI/manager.
- Prefer the microvm host module’s built-in tools over extra daemons.

## 5. Operational habits
- Treat the host as Dom0: log in rarely, don’t browse or run untrusted code there.
- Update via declarative rebuilds, not ad-hoc installs.
- Use disposable VMs for anything untrusted.

## Practical limit
Even after all of the above, the **Linux kernel + KVM** remain in the TCB. The host can be made much smaller and harder to attack, but it will not be as small as Xen Dom0 without changing the hypervisor.
