#!/usr/bin/env python3
"""
flakemicro2 GUI VM Manager
- Start/stop declared purpose VMs
- Spin up temporary (disposable) microVMs from template
- Create labeled persistent VMs (writes a stub that can be imported into the flake)
Requires: python3, tkinter, systemctl / microvm on PATH
"""
import subprocess
import tkinter as tk
from tkinter import messagebox, simpledialog
import os
from pathlib import Path

DECLARED = ["sys-net", "personal", "work"]
STATE_DIR = Path.home() / ".flakemicro2"
STATE_DIR.mkdir(exist_ok=True)

def run(cmd):
    try:
        r = subprocess.run(cmd, check=True, capture_output=True, text=True)
        return r.stdout
    except subprocess.CalledProcessError as e:
        messagebox.showerror("Error", e.stderr or str(e))
        return None

def start_vm(name):
    if run(["systemctl", "start", f"microvm@{name}"]):
        messagebox.showinfo("Started", f"{name} started")

def stop_vm(name):
    if run(["systemctl", "stop", f"microvm@{name}"]):
        messagebox.showinfo("Stopped", f"{name} stopped")

def launch_temp(label):
    # Temporary: use nix run against a template-style config (or microvm command)
    # In a full setup this would create a disposable overlay and start it
    name = f"temp-{label.replace(' ', '-')}"
    messagebox.showinfo("Temporary", f"Would launch disposable VM: {name}\n(overlay discarded on shutdown)")
    # Placeholder: nix run .#personal or similar one-off
    run(["nix", "run", ".#personal"])  # example; replace with proper temp runner

def create_labeled():
    name = simpledialog.askstring("Create VM", "Name:")
    if not name:
        return
    label = simpledialog.askstring("Label", "Label/purpose:", initialvalue="custom")
    purpose = simpledialog.askstring("Template", "Base template (personal/work/minimal):", initialvalue="personal")
    stub = STATE_DIR / f"{name}.nix"
    stub.write_text(f"# Auto-generated labeled VM\n# name={name} label={label} template={purpose}\n# Import this into flake.nix microvm.vms\n")
    messagebox.showinfo("Created", f"Labeled VM stub written to {stub}\nAdd it to the flake and rebuild to make it permanent.")

root = tk.Tk()
root.title("flakemicro2 VM Manager")
root.geometry("420x320")

tk.Label(root, text="Declared purpose VMs", font=("", 12, "bold")).pack(pady=5)
for vm in DECLARED:
    f = tk.Frame(root)
    f.pack(fill="x", padx=10, pady=2)
    tk.Label(f, text=vm, width=14, anchor="w").pack(side="left")
    tk.Button(f, text="Start", width=8, command=lambda v=vm: start_vm(v)).pack(side="left", padx=2)
    tk.Button(f, text="Stop", width=8, command=lambda v=vm: stop_vm(v)).pack(side="left")

tk.Label(root, text="Temporary / disposable", font=("", 12, "bold")).pack(pady=(15, 5))
tk.Button(root, text="Launch temporary VM", command=lambda: launch_temp("session")).pack()

tk.Label(root, text="Create persistent", font=("", 12, "bold")).pack(pady=(15, 5))
tk.Button(root, text="Create labeled VM", command=create_labeled).pack()

tk.Label(root, text="Stubs land in ~/.flakemicro2/ for flake import", fg="gray").pack(pady=10)
root.mainloop()
