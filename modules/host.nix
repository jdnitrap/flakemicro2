{ pkgs, templates, ... }:
{
  # Boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking
  networking.hostName = "nixqubes";
  networking.networkmanager.enable = true;

  # Locale / time
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  # Nix experimental features
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
    "ca-derivations"
    "recursive-nix"
    "impure-derivations"
  ];
  nixpkgs.config.allowUnfree = true;

  # Users
  users.mutableUsers = true;
  users.users.admin = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "kvm" ];
    initialPassword = "changeme";
  };
  security.sudo.wheelNeedsPassword = false;

  # Desktop
  services.xserver.enable = true;
  services.xserver.desktopManager.xfce.enable = true;
  services.xserver.displayManager.lightdm.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  # SSH
  services.openssh.enable = true;

  environment.systemPackages = with pkgs; [
    # Core management
    salt
    git
    gh
    vim

    # GUI manager
    python3
    tk

    # MicroVM / hypervisor support
    qemu
    iproute2
    bridge-utils

    # General support
    firefox
    openssh
    htop
    wget
    curl
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
        nixpkgs.config.allowUnfree = true;
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
        nixpkgs.config.allowUnfree = true;
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
        nixpkgs.config.allowUnfree = true;
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
