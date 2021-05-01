{ ...  }:

let localconfig = import <localconfig>;
    systems = {
      intel = "x86_64-darwin";
      appleSilicon = "aarch64-darwin";
    };
    darwin = import <darwin> ({
      configuration = ./configuration.nix;
    } // (if localconfig.hostname == "classic" then rec {
      nixpkgs = <nixpkgs>;
      system = builtins.currentSystem;
      pkgs = import nixpkgs { inherit system; };
    } else rec {
      nixpkgs = <nixpkgs>;
      pkgs = import nixpkgs { localSystem = systems.appleSilicon;};
    })); in
{
  nix-darwin = darwin.system;
}
