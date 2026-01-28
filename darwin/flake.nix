{
  description = "Hyunggyu's darwin system";

  inputs = {
    nixpkgs.url =
      "github:NixOS/nixpkgs/be5afa0fcb31f0a96bf9ecba05a516c66fcd8114";
    nix-darwin.url =
      "github:nix-darwin/nix-darwin/8b720b9662d4dd19048664b7e4216ce530591adc";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url =
      "github:nix-community/home-manager/c47b2cc64a629f8e075de52e4742de688f930dc6";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    firefox-addons.url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
    firefox-addons.inputs.nixpkgs.follows = "nixpkgs";
    nixpkgs-firefox-darwin.url = "github:bandithedoge/nixpkgs-firefox-darwin/4b4582d5fa6b2f7bd9753fd6f00a179923f9df81";
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
