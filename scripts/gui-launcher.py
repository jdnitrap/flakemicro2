#!/usr/bin/env python3
"""
Basic GUI launcher sketch for flakemicro2 microVMs.
Requires python3 + tkinter (or can be adapted to GTK).
Desktop entries can call this.
"""
import subprocess
import tkinter as tk
from tkinter import messagebox

VMS = ["sys-net", "personal", "work"]

def start_vm(name):
    try:
        subprocess.run(["systemctl", "start", f"microvm@{name}"], check=True)
        messagebox.showinfo("Started", f"{name} started")
    except Exception as e:
        messagebox.showerror("Error", str(e))

def stop_vm(name):
    try:
        subprocess.run(["systemctl", "stop", f"microvm@{name}"], check=True)
        messagebox.showinfo("Stopped", f"{name} stopped")
    except Exception as e:
        messagebox.showerror("Error", str(e))

root = tk.Tk()
root.title("flakemicro2 VM Manager")

for vm in VMS:
    frame = tk.Frame(root)
    frame.pack(fill="x", padx=5, pady=2)
    tk.Label(frame, text=vm, width=12).pack(side="left")
    tk.Button(frame, text="Start", command=lambda v=vm: start_vm(v)).pack(side="left")
    tk.Button(frame, text="Stop", command=lambda v=vm: stop_vm(v)).pack(side="left")

tk.Label(root, text="Temporary VMs and create-from-template coming next").pack(pady=10)
root.mainloop()
