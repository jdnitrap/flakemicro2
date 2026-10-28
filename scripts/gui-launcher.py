#!/usr/bin/env python3
"""
flakemicro2 Qubes-style VM Manager
- List of VMs with label, state, template
- Start / Stop / Status
- Launch disposable
- Create labeled persistent VM (writes stub)
"""
import subprocess
import tkinter as tk
from tkinter import messagebox, simpledialog, ttk
from pathlib import Path

FLAKE = "github:jdnitrap/flakemicro2"
STATE_DIR = Path.home() / ".flakemicro2"
STATE_DIR.mkdir(exist_ok=True)

# name, label, color, template
VMS = [
    ("sys-net", "net", "#00aa00", "minimal"),
    ("personal", "personal", "#ff8800", "workstation"),
    ("work", "work", "#0088ff", "workstation"),
]

def run(cmd):
    try:
        r = subprocess.run(cmd, check=True, capture_output=True, text=True)
        return r.stdout.strip()
    except subprocess.CalledProcessError as e:
        messagebox.showerror("Error", (e.stderr or str(e))[:400])
        return None

def vm_state(name):
    out = run(["systemctl", "is-active", f"microvm@{name}"])
    return out if out else "unknown"

def refresh_list():
    for item in tree.get_children():
        tree.delete(item)
    for name, label, color, tmpl in VMS:
        state = vm_state(name)
        tree.insert("", "end", iid=name, values=(name, label, state, tmpl), tags=(label,))
        tree.tag_configure(label, background=color)

def selected_name():
    sel = tree.selection()
    return sel[0] if sel else None

def start_selected():
    name = selected_name()
    if not name:
        return
    if run(["systemctl", "start", f"microvm@{name}"]):
        refresh_list()

def stop_selected():
    name = selected_name()
    if not name:
        return
    if run(["systemctl", "stop", f"microvm@{name}"]):
        refresh_list()

def launch_disposable():
    label = simpledialog.askstring("Disposable", "Session label:", initialvalue="disp")
    if not label:
        return
    messagebox.showinfo("Disposable", f"Launching disposable '{label}'\nClose the window to discard.")
    run(["nix", "run", f"{FLAKE}#personal"])

def create_vm():
    name = simpledialog.askstring("Create VM", "Name:")
    if not name or not name.isalnum():
        messagebox.showerror("Invalid", "Alphanumeric name required")
        return
    label = simpledialog.askstring("Label", "Label:", initialvalue="custom") or "custom"
    tmpl = simpledialog.askstring("Template", "minimal or workstation:", initialvalue="workstation") or "workstation"
    stub = STATE_DIR / f"{name}.nix"
    stub.write_text(f"""# {name}  label={label}  template={tmpl}
{name} = {{
  autostart = false;
  config = {{
    imports = [ templates.{tmpl} ];
    networking.hostName = "{name}";
    microvm.interfaces = [{{ type = "user"; id = "{name}"; mac = "02:00:00:00:00:99"; }}];
  }};
}};
""")
    messagebox.showinfo("Created", f"Stub written to {stub}\nAdd it to modules/host.nix and rebuild.")

root = tk.Tk()
root.title("nixqubes VM Manager")
root.geometry("640x420")

tk.Label(root, text="nixqubes", font=("", 14, "bold")).pack(pady=4)

cols = ("Name", "Label", "State", "Template")
tree = ttk.Treeview(root, columns=cols, show="headings", height=10)
for c in cols:
    tree.heading(c, text=c)
    tree.column(c, width=140)
tree.pack(fill="both", expand=True, padx=8, pady=4)

btn = tk.Frame(root)
btn.pack(pady=6)
tk.Button(btn, text="Start", width=10, command=start_selected).pack(side="left", padx=3)
tk.Button(btn, text="Stop", width=10, command=stop_selected).pack(side="left", padx=3)
tk.Button(btn, text="Refresh", width=10, command=refresh_list).pack(side="left", padx=3)
tk.Button(btn, text="Disposable", width=10, command=launch_disposable).pack(side="left", padx=3)
tk.Button(btn, text="Create VM", width=10, command=create_vm).pack(side="left", padx=3)

tk.Label(root, text="Select a VM then Start/Stop  |  Disposable uses remote flake  |  Create writes stub to ~/.flakemicro2/", fg="gray").pack(pady=4)

refresh_list()
root.mainloop()
