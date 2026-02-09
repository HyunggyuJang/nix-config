{
  description = "Hyunggyu's darwin system";

  inputs = {
    nixpkgs.url =
      "github:NixOS/nixpkgs/6d70567773843ee381a1adbb212d452a43b078dc";
    nix-darwin.url =
      "github:nix-darwin/nix-darwin/0fc4e7ac670a0ed874abacf73c4b072a6a58064b";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url =
      "github:nix-community/home-manager/475921375def3eb930e1f8883f619ff8609accb6";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
    doomemacs = {
      url = "github:HyunggyuJang/doom-emacs/nano-doom";
      flake = false;
    };
    doom-config = {
      url = "git+ssh://git@github.com/HyunggyuJang/manager.git";
      flake = false;
    };
    nix-doom-emacs-unstraightened.url = "github:marienz/nix-doom-emacs-unstraightened";
    nix-doom-emacs-unstraightened.inputs.nixpkgs.follows = "nixpkgs";
    nix-doom-emacs-unstraightened.inputs.doomemacs.follows = "doomemacs";
    secrets = {
      url = "path:../secrets";
      flake = false;
    };
    firefox-addons.url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
    firefox-addons.inputs.nixpkgs.follows = "nixpkgs";
    nixpkgs-firefox-darwin.url = "github:bandithedoge/nixpkgs-firefox-darwin/3d34ee3b73b456efde0d7950ce96575aea190692";
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
