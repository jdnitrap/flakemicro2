{
  description = "NixOS MicroVMs with microvm.nix";

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
    in {
      packages.${system} = {
        default = self.packages.${system}.my-microvm;
        my-microvm = self.nixosConfigurations.my-microvm.config.microvm.declaredRunner;
      };

      nixosConfigurations = {
        my-microvm = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            microvm.nixosModules.microvm
            {
              networking.hostName = "my-microvm";
              users.users.root.password = "";

              microvm = {
                hypervisor = "qemu";
                mem = 1024;
                vcpu = 2;

                # User networking (no host setup needed)
                interfaces = [{
                  type = "user";
                  id = "qemu";
                  mac = "02:00:00:00:00:01";
                }];

                # Share host /nix/store (faster, no store image built)
                shares = [{
                  proto = "9p";
                  tag = "ro-store";
                  source = "/nix/store";
                  mountPoint = "/nix/.ro-store";
                }];

                # Writable overlay for the store (optional)
                writableStoreOverlay = "/nix/.rw-store";
                volumes = [{
                  image = "nix-store-overlay.img";
                  mountPoint = "/nix/.rw-store";
                  size = 2048;
                }];

                socket = "control.socket";
              };

              # Example packages
              environment.systemPackages = with nixpkgs.legacyPackages.${system}; [
                vim
                htop
                git
              ];

              system.stateVersion = "26.05";
            }
          ];
        };
      };
    };
}
