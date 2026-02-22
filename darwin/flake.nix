{
  description = "Hyunggyu's darwin system";

  inputs = {
    nixpkgs.url =
      "github:NixOS/nixpkgs/c9bcf43e95457bb8a41b4c144de5cb394afe5261";
    nix-darwin.url =
      "github:nix-darwin/nix-darwin/6a7fdcd5839ec8b135821179eea3b58092171bcf";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url =
      "github:nix-community/home-manager/603626a8da9e1b622e55251a90ef486b8179334c";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
    agenix.inputs.home-manager.follows = "home-manager";
    agenix.inputs.darwin.follows = "nix-darwin";
    secrets = {
      url = "path:../secrets";
      flake = false;
    };
    firefox-addons.url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
    firefox-addons.inputs.nixpkgs.follows = "nixpkgs";
    nixpkgs-firefox-darwin.url = "github:bandithedoge/nixpkgs-firefox-darwin/eea90a2e07503710c6476772c8187aaa9da4e180";
    nixpkgs-firefox-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ nix-darwin, nixpkgs, ... }: {
    formatter.aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.nixfmt;
    darwinConfigurations.Hyunggyus-MacBook-Air =
      let
        hostModule = import ./hosts/Hyunggyus-MacBook-Air.nix;
        host = (hostModule { }).host;
      in
      nix-darwin.lib.darwinSystem {
        modules = [ ./configuration.nix ];
        specialArgs = {
          inherit inputs host;
        };
      };
    darwinConfigurations.Hyunggyus-MacBook-Pro =
      let
        hostModule = import ./hosts/Hyunggyus-MacBook-Pro.nix;
        host = (hostModule { }).host;
      in
      nix-darwin.lib.darwinSystem {
        modules = [ ./configuration.nix ];
        specialArgs = {
          inherit inputs host;
        };
      };
    darwinConfigurations.A13884ui-MacBookPro =
      let
        hostModule = import ./hosts/A13884ui-MacBookPro.nix;
        host = (hostModule { }).host;
      in
      nix-darwin.lib.darwinSystem {
        modules = [ ./configuration.nix ];
        specialArgs = {
          inherit inputs host;
        };
      };
    devShells.aarch64-darwin.default =
      nixpkgs.legacyPackages.aarch64-darwin.mkShell { };
  };
}
