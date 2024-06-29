 
# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, inputs , ... }:

{
  networking.hostName="BlackFish";

  system.stateVersion = "24.05"; # Don't Change!
  imports =
    [ # Include the results of the hardware scan.
      ./blackfish-hardware-configuration.nix
      ./common.nix
    ];
  environment.systemPackages = with pkgs; [
    lact
  ];

  systemd.services.lact = {
    description = "AMDGPU Control Daemon";
    after = ["multi-user.target"];
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      ExecStart = "${pkgs.lact}/bin/lact daemon";
    };
    enable = true;
  };
}

