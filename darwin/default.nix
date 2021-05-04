{ ...  }:

let localconfig = import <localconfig>;
    systems = {
      intel = "x86_64-darwin";
      appleSilicon = "aarch64-darwin";
    };
    default = import <darwin> rec {
      configuration = ./configuration.nix;
      nixpkgs = <nixpkgs>;
      system = builtins.currentSystem;
      pkgs = import nixpkgs { inherit system; };
    };
    darwin =  if localconfig.hostname == "classic"
              then default
              else default;
in
darwin.installer
