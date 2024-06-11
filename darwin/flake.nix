{
  description = "Hyunggyu's darwin system";

  inputs = {
    nixpkgs.url =
      "github:NixOS/nixpkgs/3bcedce9f4de37570242faf16e1e143583407eab";
    nix-darwin.url =
      "github:LnL7/nix-darwin/315aa649ba307704db0b16c92f097a08a65ec955";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url =
      "github:nix-community/home-manager/3d65009effd77cb0d6e7520b68b039836a7606cf";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nur.url =
      "github:nix-community/NUR/b2adfc00254cf5bca52f1951955e801534130d63";
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
    devShells.aarch64-darwin.default =
      nixpkgs.legacyPackages.aarch64-darwin.mkShell { };
  };
}
