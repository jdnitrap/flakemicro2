#!/usr/bin/env python3
"""
nixqubes VM Manager — Qubes-style list
Always shows declared VMs even if systemctl units are not yet installed.
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
    ("sys-net", "net", "#2e7d32", "minimal"),
    ("personal", "personal", "#ef6c00", "workstation"),
    ("work", "work", "#1565c0", "workstation"),
]

def run_quiet(cmd):
    try:
        r = subprocess.run(cmd, check=False, capture_output=True, text=True, timeout=5)
        return r.stdout.strip()
    except Exception:
        return ""

def vm_state(name):
    out = run_quiet(["systemctl", "is-active", f"microvm@{name}"])
    if out in ("active", "inactive", "failed", "activating"):
        return out
    return "not-installed"

def refresh_list():
    tree.delete(*tree.get_children())
    for name, label, color, tmpl in VMS:
        state = vm_state(name)
        tree.insert("", "end", iid=name, values=(name, label, state, tmpl))
        # color the row via tag
        tree.tag_configure(name, background=color, foreground="white")
        tree.item(name, tags=(name,))

def selected_name():
    sel = tree.selection()
    return sel[0] if sel else None

def start_selected():
    name = selected_name()
    if not name:
        messagebox.showinfo("Select", "Select a VM first")
        return
    run_quiet(["systemctl", "start", f"microvm@{name}"])
    refresh_list()

def stop_selected():
    name = selected_name()
    if not name:
        return
    run_quiet(["systemctl", "stop", f"microvm@{name}"])
    refresh_list()

def launch_disposable():
    label = simpledialog.askstring("Disposable VM", "Session label:", initialvalue="disp")
    if not label:
        return
    messagebox.showinfo("Disposable", f"Starting disposable '{label}'\n(close the VM window to discard)")
    subprocess.Popen(["nix", "run", f"{FLAKE}#personal"])

def create_vm():
    name = simpledialog.askstring("Create VM", "Name:")
    if not name or not name.replace("-", "").isalnum():
        messagebox.showerror("Invalid", "Use letters, numbers, or hyphen")
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
    messagebox.showinfo("Created", f"Stub saved to:\n{stub}\n\nAdd the block to modules/host.nix and rebuild.")

root = tk.Tk()
root.title("nixqubes — VM Manager")
root.geometry("720x480")
root.configure(bg="#1e1e1e")

tk.Label(root, text="nixqubes", font=("Sans", 16, "bold"), bg="#1e1e1e", fg="white").pack(pady=6)

style = ttk.Style()
style.theme_use("clam")
style.configure("Treeview", background="#2d2d2d", fieldbackground="#2d2d2d", foreground="white", rowheight=28)
style.configure("Treeview.Heading", background="#3c3c3c", foreground="white")

cols = ("Name", "Label", "State", "Template")
tree = ttk.Treeview(root, columns=cols, show="headings", height=12)
for c, w in zip(cols, (160, 120, 140, 140)):
    tree.heading(c, text=c)
    tree.column(c, width=w, anchor="w")
tree.pack(fill="both", expand=True, padx=10, pady=6)

btn = tk.Frame(root, bg="#1e1e1e")
btn.pack(pady=8)
for text, cmd in [
    ("Start", start_selected),
    ("Stop", stop_selected),
    ("Refresh", refresh_list),
    ("Disposable", launch_disposable),
    ("Create VM", create_vm),
]:
    tk.Button(btn, text=text, width=12, command=cmd, bg="#424242", fg="white", relief="flat").pack(side="left", padx=4)

tk.Label(
    root,
    text="VMs are always listed. State shows 'not-installed' until the host has the microvm units.\nDisposable launches a temporary session. Create VM writes a stub for the flake.",
    bg="#1e1e1e", fg="#aaaaaa", justify="left"
).pack(pady=4)

refresh_list()
root.mainloop()
