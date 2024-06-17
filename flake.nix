{
  description = "Flake";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
};

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations.BlackFish = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ./blackfish-configuration.nix
      ];
    };
  };
}
