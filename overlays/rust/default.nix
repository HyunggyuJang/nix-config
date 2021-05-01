final: prev:
with prev;
{
  yaskkserv2 = rustPlatform.buildRustPackage rec {
    pname = "yaskkserv2";
    version = "0.1.1";
    src = fetchFromGitHub {
      owner = "wachikun";
      repo = pname;
      rev = "818fa43b09a1967a38c246626b570b3da33da555";
      sha256 = "0pnh8ss15c644qc1mhz4zil4r4qnmr3nxw7mdm6dnwqa44byig19";
    };
    target = "x86_64-apple-darwin";

    cargoSha256 = "00r00h3kgps9bknrqrjqz2f07n2c31cjn1ks2vqwf7dvm4k2f312";

    buildInputs = [ darwin.apple_sdk.frameworks.Security ];

    doCheck = false;

    meta = with lib; {
      description = "Yet another SKK server.";
      homepage = "https://github.com/${src.owner}/${pname}";
      license = licenses.mit;
      maintainers = with maintainers; [ hyunggyujang ];
      platforms = platforms.darwin;
    };
  };
  elan = prev.elan.overrideAttrs (oldAttrs: {
    buildInputs = oldAttrs.buildInputs ++ [ darwin.libiconv ];
  });
}
