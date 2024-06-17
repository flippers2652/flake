# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, inputs , ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  networking.hostName="BlackFish";
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
  console = {
    font = "Lat2-Terminus16";
    keyMap = "uk";
  };

  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.displayManager.defaultSession = "plasma";
  services.displayManager.sddm.wayland.enable = true;
  services.xserver.videoDrivers = [ "amdgpu" ];

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
  users.users.Admin = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      firefox
    ];
    password="testing";
    uid = 1234;
  };
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
  ];
  virtualisation.docker.enable = true;

  services.openssh.enable = true;

  system.stateVersion = "24.05"; # Don't Change!

}

