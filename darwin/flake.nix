{
  description = "Hyunggyu's darwin system";

  inputs = {
    nixpkgs.url =
      "github:NixOS/nixpkgs/85f7e662eda4fa3a995556527c87b2524b691933";
    nix-darwin.url =
      "github:LnL7/nix-darwin/2fbf4a8417c28cf45bae6e6e97248cbbd9b78632";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url =
      "github:nix-community/home-manager/2f607e07f3ac7e53541120536708e824acccfaa8";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nur.url =
      "github:nix-community/NUR/5e6755e038226196809096a0ad58e9eae7347f8f";
    nixpkgs-firefox-darwin.url = "github:bandithedoge/nixpkgs-firefox-darwin/545b84eea261aa797378f69de81282ee49174fa8";
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
