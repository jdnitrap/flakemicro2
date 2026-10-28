{ microvm, pkgs, ... }:
let
  minimal = { lib, pkgs, ... }: {
    imports = [ microvm.nixosModules.microvm ];
    users.users.root.password = "";
    system.stateVersion = "26.05";
    nixpkgs.config.allowUnfree = true;
    microvm = {
      hypervisor = "qemu";
      mem = 512;
      vcpu = 1;
      shares = [{
        proto = "9p";
        tag = "ro-store";
        source = "/nix/store";
        mountPoint = "/nix/.ro-store";
      }];
      writableStoreOverlay = "/nix/.rw-store";
      volumes = [{
        image = "overlay.img";
        mountPoint = "/nix/.rw-store";
        size = 1024;
      }];
      socket = "control.socket";
    };
    environment.systemPackages = with pkgs; [ vim ];
  };

  workstation = { lib, pkgs, ... }: {
    imports = [ minimal ];
    # Avoid exact 2048 MB (QEMU hang issue)
    microvm.mem = lib.mkForce 1536;
    microvm.vcpu = lib.mkForce 2;
    environment.systemPackages = with pkgs; [ firefox git vim htop ];
  };
in
{
  templates = {
    inherit minimal workstation;
  };
}
