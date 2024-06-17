# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  networking.hostName="Adelie";
  imports =
    [ # Include the results of the hardware scan.
      ./adelie-hardware-configuration.nix
      ./common.nix
    ];
  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
  };
  system.stateVersion = "24.05";
}

