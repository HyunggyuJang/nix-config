{ inputs, ... }:
{
  nixpkgs.overlays =
    let path = ../../overlays;
    in with builtins;
    [
      (final: prev: {
        # Simple derivation that just extracts the binary from the tarball
        glab = prev.stdenv.mkDerivation rec {
          pname = "glab";
          version = "1.80.4";

          src = prev.fetchurl {
            url = "https://gitlab.com/gitlab-org/cli/-/releases/v${version}/downloads/${pname}_${version}_darwin_arm64.tar.gz";
            sha256 = "sha256-pebDuHBc4bSysKYKJaPay6o/dkhPaDwHp8Ksttaepb8=";
          };

          dontUnpack = false;
          sourceRoot = ".";

          installPhase = ''
            mkdir -p $out/bin
            cp bin/glab $out/bin/
            chmod +x $out/bin/glab
          '';

          meta = with prev.lib; {
            description = "GitLab CLI tool";
            homepage = "https://gitlab.com/gitlab-org/cli";
            license = licenses.mit;
            platforms = platforms.darwin;
          };
        };
      })
      inputs.nixpkgs-firefox-darwin.overlay
    ] ++ map (n: import (path + ("/" + n))) (filter
      (n:
        match ".*\\.nix" n != null
        || pathExists (path + ("/" + n + "/default.nix")))
      (attrNames (readDir path)));
}
