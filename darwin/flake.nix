{
  description = "Hyunggyu's darwin system";

  inputs = {
    nixpkgs.url =
      "github:NixOS/nixpkgs/32fb99ba93fea2798be0e997ea331dd78167f814";
    nix-darwin.url =
      "github:LnL7/nix-darwin/ae406c04577ff9a64087018c79b4fdc02468c87c";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url =
      "github:HyunggyuJang/home-manager/248f678471f4bcc2061bba57bd82588996f06ec2";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    firefox-addons.url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
    firefox-addons.inputs.nixpkgs.follows = "nixpkgs";
    nixpkgs-firefox-darwin.url = "github:bandithedoge/nixpkgs-firefox-darwin/debb9b889951b74cee5cbdb45074dd9d289f25d6";
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
