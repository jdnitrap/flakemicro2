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

      # Shared base for template-style VMs
      templateBase = { lib, pkgs, ... }: {
        imports = [ microvm.nixosModules.microvm ];
        users.users.root.password = "";
        system.stateVersion = "26.05";
        microvm = {
          hypervisor = "qemu";
          mem = 1024;
          vcpu = 2;
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
            size = 2048;
          }];
          socket = "control.socket";
        };
        environment.systemPackages = with pkgs; [ vim htop ];
      };
    in {
      nixosConfigurations = {
        # Dom0-like host
        host = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            microvm.nixosModules.host
            {
              networking.hostName = "flakemicro-host";
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
                vim
              ];

              # Declare the microVMs the host can run
              microvm.vms = {
                sys-net = {
                  autostart = false;
                  config = {
                    imports = [ templateBase ];
                    networking.hostName = "sys-net";
                    microvm.interfaces = [{
                      type = "user";
                      id = "net";
                      mac = "02:00:00:00:00:10";
                    }];
                  };
                };
                personal = {
                  autostart = false;
                  config = {
                    imports = [ templateBase ];
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
                    imports = [ templateBase ];
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

        # Standalone runners for testing
        sys-net = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            templateBase
            { networking.hostName = "sys-net"; }
          ];
        };
        personal = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            templateBase
            {
              networking.hostName = "personal";
              environment.systemPackages = with pkgs; [ firefox ];
            }
          ];
        };
      };

      packages.${system} = {
        default = self.nixosConfigurations.personal.config.microvm.declaredRunner;
        personal = self.nixosConfigurations.personal.config.microvm.declaredRunner;
        sys-net = self.nixosConfigurations.sys-net.config.microvm.declaredRunner;
      };
    };
}
