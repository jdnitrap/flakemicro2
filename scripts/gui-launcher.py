#!/usr/bin/env python3
"""
flakemicro2 day-to-day GUI VM Manager
Works without a local clone (uses remote flake for temporary VMs).
"""
import subprocess
import tkinter as tk
from tkinter import messagebox, simpledialog
from pathlib import Path

DECLARED = ["sys-net", "personal", "work"]
FLAKE = "github:jdnitrap/flakemicro2"
STATE_DIR = Path.home() / ".flakemicro2"
STATE_DIR.mkdir(exist_ok=True)

def run(cmd):
    try:
        r = subprocess.run(cmd, check=True, capture_output=True, text=True)
        return r.stdout
    except subprocess.CalledProcessError as e:
        messagebox.showerror("Error", (e.stderr or str(e))[:500])
        return None

def start_vm(name):
    if run(["systemctl", "start", f"microvm@{name}"]):
        messagebox.showinfo("OK", f"{name} started")

def stop_vm(name):
    if run(["systemctl", "stop", f"microvm@{name}"]):
        messagebox.showinfo("OK", f"{name} stopped")

def status_vm(name):
    out = run(["systemctl", "is-active", f"microvm@{name}"])
    messagebox.showinfo(name, out.strip() if out else "unknown")

def launch_temp():
    label = simpledialog.askstring("Temporary VM", "Session label:", initialvalue="session")
    if not label:
        return
    messagebox.showinfo("Temporary", f"Launching disposable session '{label}'\nClose the VM window to discard.")
    # Use the remote flake so no local clone is required
    run(["nix", "run", f"{FLAKE}#personal"])

def create_labeled():
    name = simpledialog.askstring("Create persistent VM", "Name:")
    if not name or not name.isalnum():
        messagebox.showerror("Invalid", "Name must be alphanumeric")
        return
    label = simpledialog.askstring("Label", "Label/purpose:", initialvalue="custom") or "custom"
    template = simpledialog.askstring("Template", "minimal or workstation:", initialvalue="workstation") or "workstation"
    stub = STATE_DIR / f"{name}.nix"
    stub.write_text(f'''# Generated labeled VM: {name}
# label: {label}
# template: {template}
# Paste into microvm.vms in modules/host.nix then rebuild
{name} = {{
  autostart = false;
  config = {{
    imports = [ templates.{template} ];
    networking.hostName = "{name}";
    microvm.interfaces = [{{ type = "user"; id = "{name}"; mac = "02:00:00:00:00:99"; }}];
  }};
}};
''')
    messagebox.showinfo("Created", f"Stub written to:\n{stub}\n\nCopy the block into modules/host.nix and rebuild to activate.")

root = tk.Tk()
root.title("flakemicro2 VM Manager")
root.geometry("480x380")

tk.Label(root, text="Purpose VMs", font=("", 11, "bold")).pack(pady=4)
for vm in DECLARED:
    f = tk.Frame(root)
    f.pack(fill="x", padx=8, pady=1)
    tk.Label(f, text=vm, width=12, anchor="w").pack(side="left")
    tk.Button(f, text="Start", width=7, command=lambda v=vm: start_vm(v)).pack(side="left", padx=1)
    tk.Button(f, text="Stop", width=7, command=lambda v=vm: stop_vm(v)).pack(side="left", padx=1)
    tk.Button(f, text="Status", width=7, command=lambda v=vm: status_vm(v)).pack(side="left")

tk.Label(root, text="Temporary / disposable", font=("", 11, "bold")).pack(pady=(12, 4))
tk.Button(root, text="Launch temporary session", command=launch_temp).pack()

tk.Label(root, text="Create persistent labeled VM", font=("", 11, "bold")).pack(pady=(12, 4))
tk.Button(root, text="Create labeled VM", command=create_labeled).pack()

tk.Label(root, text="Stubs → ~/.flakemicro2/   |   Temporary uses remote flake", fg="gray").pack(pady=8)
root.mainloop()
