# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, inputs , ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  boot.loader.grub = {
    enable = true;
    zfsSupport = true;
    efiSupport = true;
    mirroredBoots = [
      { devices = [ "nodev"]; path = "/boot"; }
    ];
    memtest86.enable = true;
  };
  boot.initrd.kernelModules = [ "amdgpu" ];
  hardware.opengl.driSupport = true;
  hardware.opengl.driSupport32Bit = true;
  boot.loader.efi.canTouchEfiVariables = true;
  zramSwap.enable = true;
  networking.networkmanager.enable = true;
  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_GB.UTF-8";
  services.xserver.xkb.layout = "gb";

  console = {
    font = "Lat2-Terminus16";
    keyMap = "uk";
  };
  services.flatpak.enable = true;
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.displayManager.defaultSession = "plasma";
  services.displayManager.sddm.wayland.enable = true;
  services.xserver.videoDrivers = [ "amdgpu" ];
  services.zfs.autoScrub.enable = true;
  programs.nix-ld = { enable = true; libraries = pkgs.steam-run.fhsenv.args.multiPkgs pkgs; };
  security.rtkit.enable = true;
  sound.enable = true;
  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    pulse.enable = true;
  };
  nixpkgs.config.allowUnfree = true;

  users.mutableUsers=false;
  users.users.flippers2652 = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "networkmanager"]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      firefox
      discord
      signal-desktop
      kdePackages.yakuake
      prismlauncher
      mangohud
      htop
      wineWowPackages.stable
      jdk
      obs-studio
      easyeffects
      heroic
      vim
      goverlay
      idris2
      vscode
    ];
    hashedPassword="$y$j9T$JW7m827Kqutlmdw610V1w/$WqCP4GMLquPhdFsf2Bbgy//iHmIyFiK5fUaQCsqpvqD";
    uid = 2652;
  };

  programs.gamemode.enable = true;
  programs.corectrl.enable = true;
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };
  hardware.opengl.enable = true;
  hardware.enableAllFirmware = true;

  environment.systemPackages = with pkgs; [
    vim
    git
  ];
  virtualisation.docker.enable = true;
  services.openssh = {
    enable = true;
    # require public key authentication for better security
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
    #settings.PermitRootLogin = "yes";
  };

}

