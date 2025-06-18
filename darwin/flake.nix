{
  description = "Hyunggyu's darwin system";

  inputs = {
    nixpkgs.url =
      "github:NixOS/nixpkgs/f45e75fc63fc8a7ffc3da382b2f6b681c5b71875";
    nix-darwin.url =
      "github:LnL7/nix-darwin/2f140d6ac8840c6089163fb43ba95220c230f22b";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url =
      "github:nix-community/home-manager/c5f345153397f62170c18ded1ae1f0875201d49a";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    firefox-addons.url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
    firefox-addons.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ nix-darwin, nixpkgs, ... }: {
    formatter.aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.nixfmt;
    darwinConfigurations.Hyunggyus-MacBook-Air = nix-darwin.lib.darwinSystem {
      modules = [ ./configuration.nix ];
      specialArgs =
        {
          inherit inputs;
          machineType = "MacBook-Air";
        };
    };
    darwinConfigurations.Hyunggyus-MacBook-Pro = nix-darwin.lib.darwinSystem {
      modules = [ ./configuration.nix ];
      specialArgs = {
        inherit inputs;
        machineType = "MacBook-Pro";
      };
    };
    darwinConfigurations.A13884ui-MacBookPro = nix-darwin.lib.darwinSystem {
      modules = [ ./configuration.nix ];
      specialArgs = {
        inherit inputs;
        machineType = "M3-Pro";
      };
    };
    devShells.aarch64-darwin.default =
      nixpkgs.legacyPackages.aarch64-darwin.mkShell { };
  };
}
