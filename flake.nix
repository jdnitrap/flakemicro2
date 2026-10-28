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

      templatesMod = import ./modules/templates.nix { inherit microvm pkgs; };
      templates = templatesMod.templates;
    in {
      nixosConfigurations = {
        nixqubes = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            microvm.nixosModules.host
            # Hardware config: add your own import here if needed
            # (e.g. a path you control, or leave unset and rely on existing system)
            (import ./modules/host.nix { inherit pkgs templates; })
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
