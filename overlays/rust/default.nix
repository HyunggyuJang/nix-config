final: prev:
with prev;
{
  yaskkserv2 = rustPlatform.buildRustPackage rec {
    pname = "yaskkserv2";
    version = "0.1.1";
    src = fetchFromGitHub {
      owner = "wachikun";
      repo = pname;
      rev = "982845af2dd8eca6675dc3c9eded24570a205142";
      sha256 = "13nadqm977rc6z7zka7ymdrh717r62w3s6k15dll4way6djvp3y6";
    };
    # target = "x86_64-apple-darwin";

    cargoSha256 = "sha256-IgwnJqm7HcfxFnoGK1kYTNgDnPhYZpztXEnfNwcEIAM=";

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
