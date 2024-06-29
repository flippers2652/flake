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
  networking.firewall = {
  enable = false;
  allowedTCPPorts = [ 80 443 ];
  };
  # Define the www-data user and add them to the www-data group
  users.users.www-data = {
    isSystemUser = true;
    group = "www-data";
    home = "/var/www";
    createHome = true;
    description = "Web Server User";
    shell = pkgs.bash;
  };
  services.phpfpm.pools.www-data = {
    user = "www-data";
    settings = {
      "listen.owner" = config.services.nginx.user;
      "pm" = "dynamic";
      "pm.max_children" = 32;
      "pm.max_requests" = 500;
      "pm.start_servers" = 2;
      "pm.min_spare_servers" = 2;
      "pm.max_spare_servers" = 5;
      "php_admin_value[error_log]" = "stderr";
      "php_admin_flag[log_errors]" = true;
      "catch_workers_output" = true;
    };
    phpEnv."PATH" = lib.makeBinPath [ pkgs.php.buildEnv {
          extensions = {
            enabled,
            all,
          }:
            enabled
            ++ (with all; [
              redis
              xdebug
            ]);
          extraConfig = ''
            xdebug.mode=debug
          '';
        } ];
  };
  services.nginx = {
    enable = true;
    user = "www-data";
    virtualHosts."172.16.0.26"={
      root = "/var/www/panel/public";
      extraConfig = ''
        
            # Replace the example <domain> with your domain name or IP address


            index index.html index.htm index.php;
            charset utf-8;

            location / {
                try_files $uri $uri/ /index.php?$query_string;
            }

            location = /favicon.ico { access_log off; log_not_found off; }
            location = /robots.txt  { access_log off; log_not_found off; }

            access_log off;
            error_log  /var/log/nginx/pterodactyl.app-error.log error;

            # allow larger file uploads and longer script runtimes
            client_max_body_size 100m;
            client_body_timeout 120s;

            sendfile off;

            location ~ \.php$ {
                fastcgi_split_path_info ^(.+\.php)(/.+)$;
                fastcgi_pass unix:/run/phpfpm/www-data.sock;
                fastcgi_index index.php;
                include ${pkgs.nginx}/conf/fastcgi_params;
                fastcgi_param PHP_VALUE "upload_max_filesize = 100M \n post_max_size=100M";
                fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
                fastcgi_param HTTP_PROXY "";
                fastcgi_intercept_errors off;
                fastcgi_buffer_size 16k;
                fastcgi_buffers 4 16k;
                fastcgi_connect_timeout 300;
                fastcgi_send_timeout 300;
                fastcgi_read_timeout 300;
            }

            location ~ /\.ht {
                deny all;
            }
        
      '';};

  };
  system.stateVersion = "24.05";
}

