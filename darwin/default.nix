{ ...  }:

let localconfig = import <localconfig>;
    default = import <darwin> rec {
      configuration = ./configuration.nix;
      nixpkgs = <nixpkgs>;
      system = builtins.currentSystem;
      pkgs = import nixpkgs {};
    };
    darwin = default;
in
darwin.installer
