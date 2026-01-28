{ inputs, pkgs, owner, ... }:
{
  nix = {
    settings = {
      trusted-users = [ "root" owner ];
      experimental-features = "nix-command flakes";
    };
    package = pkgs.nix;
    nixPath = [{
      darwin = inputs.nix-darwin;
      nixpkgs = inputs.nixpkgs;
    }];
  };
}
