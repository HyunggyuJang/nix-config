{ ...  }:

let localconfig = import <localconfig>;
    default = import (builtins.fetchTarball {
      # Get the revision by choosing a version from https://github.com/LnL7/nix-darwin
      url = "https://github.com/LnL7/nix-darwin/archive/87b9d090ad39b25b2400029c64825fc2a8868943.tar.gz";
      # Get the hash by running `nix-prefetch-url --unpack <url>` on the above url
      sha256 = "0c2naszb8xqi152m4b71vpi20cwacmxsx82ig8fgq61z9y05iiq2";
    }) rec {
      configuration = ./configuration.nix;
      nixpkgs = (builtins.fetchTarball {
        # Get the revision by choosing a version from https://github.com/LnL7/nix-darwin
        url = "https://github.com/NixOS/nixpkgs/archive/6360be075539647669cf0a09fbda9f8fdae627d8.tar.gz";
        # Get the hash by running `nix-prefetch-url --unpack <url>` on the above url
        sha256 = "0bnkf2376lz58a61dqnr6makpgdh0wsn8va0k1jk6bi509lzx641";
      });
      system = builtins.currentSystem;
      pkgs = import nixpkgs {};
    };
    darwin = default;
in
darwin.installer
