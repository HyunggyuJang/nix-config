{
  description = "Hyunggyu's darwin system";

  inputs = {
    nixpkgs.url =
      "github:NixOS/nixpkgs/d04953086551086b44b6f3c6b7eeb26294f207da";
    nix-darwin.url =
      "github:LnL7/nix-darwin/f7142b8024d6b70c66fd646e1d099d3aa5bfec49";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url =
      "github:nix-community/home-manager/afc892db74d65042031a093adb6010c4c3378422";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nur.url =
      "github:nix-community/NUR/5605ce776b3d21c0ee477fcd028a817bd3524e6f";
    nixpkgs-firefox-darwin.url = "github:bandithedoge/nixpkgs-firefox-darwin/ec1dd891c812cc220b6b1a3805db6b577de4f2eb";
  };

  outputs = inputs@{ nix-darwin, nixpkgs, nur, ... }: {
    formatter.aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.nixfmt;
    darwinConfigurations.Hyunggyus-MacBook-Air = nix-darwin.lib.darwinSystem {
      modules = [ ./configuration.nix nur.nixosModules.nur ];
      specialArgs =
        {
          inherit inputs;
          machineType = "MacBook-Air";
        };
    };
    darwinConfigurations.Hyunggyus-MacBook-Pro = nix-darwin.lib.darwinSystem {
      modules = [ ./configuration.nix nur.nixosModules.nur ];
      specialArgs = {
        inherit inputs;
        machineType = "MacBook-Pro";
      };
    };
    darwinConfigurations.A13884ui-MacBookPro = nix-darwin.lib.darwinSystem {
      modules = [ ./configuration.nix nur.nixosModules.nur ];
      specialArgs = {
        inherit inputs;
        machineType = "M3-Pro";
      };
    };
    devShells.aarch64-darwin.default =
      nixpkgs.legacyPackages.aarch64-darwin.mkShell { };
  };
}
