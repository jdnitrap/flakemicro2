{
  description = "Qubes-inspired NixOS MicroVMs with microvm.nix";

  nixConfig = {
    extra-substituters = [ "https://microvm.cachix.org" ];
    extra-trusted-public-keys = [ "microvm.cachix.org-1:oXnBc6hRE3eX5rSYdRyMYXnfzcCxC7yKPTbZXALsqys=" ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    microvm = {
      url = "github:microvm-nix/microvm.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, microvm }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      # Explicit templates
      templates = {
        minimal = { lib, pkgs, ... }: {
          imports = [ microvm.nixosModules.microvm ];
          users.users.root.password = "";
          system.stateVersion = "26.05";
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
          imports = [ templates.minimal ];
          microvm.mem = 2048;
          microvm.vcpu = 2;
          environment.systemPackages = with pkgs; [ firefox git vim htop ];
        };
      };
    in {
      nixosConfigurations = {
        host = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            microvm.nixosModules.host
            # hardware-configuration.nix comes from your machine when you deploy:
            # ./hardware-configuration.nix
            {
              networking.hostName = "nixqubes";
              users.mutableUsers = true;
              users.users.admin = {
                isNormalUser = true;
                extraGroups = [ "wheel" "networkmanager" ];
                initialPassword = "changeme";
              };
              security.sudo.wheelNeedsPassword = false;

              services.xserver.enable = true;
              services.xserver.desktopManager.xfce.enable = true;
              services.xserver.displayManager.lightdm.enable = true;

              environment.systemPackages = with pkgs; [
                salt
                firefox
                git
                gh
                vim
                python3
                python3Packages.tkinter
              ];

              # Day-to-day VMs
              # Networking note: switch type = "user" to type = "tap" + host bridge
              # once sys-net owns the real NIC (see docs/networking.md).
              microvm.vms = {
                sys-net = {
                  autostart = false;
                  config = {
                    imports = [ templates.minimal ];
                    networking.hostName = "sys-net";
                    microvm.interfaces = [{
                      type = "user"; # change to tap after host bridge setup
                      id = "net";
                      mac = "02:00:00:00:00:10";
                    }];
                  };
                };
                personal = {
                  autostart = false;
                  config = {
                    imports = [ templates.workstation ];
                    networking.hostName = "personal";
                    microvm.interfaces = [{
                      type = "user";
                      id = "personal";
                      mac = "02:00:00:00:00:11";
                    }];
                    environment.systemPackages = with pkgs; [ firefox libreoffice ];
                  };
                };
                work = {
                  autostart = false;
                  config = {
                    imports = [ templates.workstation ];
                    networking.hostName = "work";
                    microvm.interfaces = [{
                      type = "user";
                      id = "work";
                      mac = "02:00:00:00:00:12";
                    }];
                    environment.systemPackages = with pkgs; [ git vscode ];
                  };
                };
              };

              system.stateVersion = "26.05";
            }
          ];
        };

        personal = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            templates.workstation
            { networking.hostName = "personal"; }
          ];
        };
      };

      packages.${system} = {
        default = self.nixosConfigurations.personal.config.microvm.declaredRunner;
        personal = self.nixosConfigurations.personal.config.microvm.declaredRunner;
      };
    };
}
