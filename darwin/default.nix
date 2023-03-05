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
        # Get the revision by choosing a version from https://github.com/NixOS/nixpkgs
        url = "https://github.com/NixOS/nixpkgs/archive/f5ffd5787786dde3a8bf648c7a1b5f78c4e01abb.tar.gz";
        # Get the hash by running `nix-prefetch-url --unpack <url>` on the above url
        sha256 = "04ralbbvxr5flla3qqr6c87wziphr0ddwmj4099y0kh174k9aa4n";
      });
      system = builtins.currentSystem;
      pkgs = import nixpkgs {};
    };
    darwin = default;
in
darwin.installer
