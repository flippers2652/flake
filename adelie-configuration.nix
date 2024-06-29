# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, inputs,... }:

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
  services.redis.servers.redis.enable=true;
  services.redis.servers.redis.port=6379;
  services.cron = {
    enable = true;
    systemCronJobs = [
      "* * * * * php /var/www/panel/artisan schedule:run >> /dev/null 2>&1"
    ];
  };
  systemd.services.pterodactyl-queue-worker = {
    description = "Pterodactyl Queue Worker";
    after = [ "redis-redis.service" ];
    path=[ pkgs.git ];
    serviceConfig = {
      User = "www-data";
      Group = "www-data";
      #Restart = "always";
      WorkingDirectory="/var/www/panel";
      ExecStart = "${pkgs.nix}/bin/nix develop --command  php artisan queue:work --queue=high,standard,low --sleep=2 --tries=3";
      StartLimitIntervalSec = 180;
      StartLimitBurst = 30;
      RestartSec = 5;
    };

    wantedBy = [ "multi-user.target" ];
  };
    # Define the www-data group
  users.groups.www-data = { };
  networking.firewall.allowedTCPPorts = [ 80 443 ];
  # Define the www-data user and add them to the www-data group
  users.users.www-data = {
    isSystemUser = true;
    group = "www-data";
    home = "/var/www";
    createHome = true;
    description = "Web Server User";
    shell = pkgs.bash;
  };
  users.users."flippers2652".openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOGXIXHv3T/ZUDC29z1N5JeN/zW6NO8p4X3nRqq8cvp2 flippers2652" # content of authorized_keys file
    # note: ssh-copy-id will add user@your-machine after the public key
    # but we can remove the "@your-machine" part
  ];





  system.stateVersion = "24.05";
}

