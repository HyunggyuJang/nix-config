final: prev:
with prev;
{
  yaskkserv2 = rustPlatform.buildRustPackage rec {
    pname = "yaskkserv2";
    version = "0.1.5";
    src = fetchFromGitHub {
      owner = "wachikun";
      repo = pname;
      rev = "48ede49d4a848de5e1787b270d61f03ed0176dd3";
      sha256 = "sha256-zXwyiI+oJv5ZUrl9OVWZ8VUFEaAf+kajRCkXRVihyFc=";
    };
    # target = "x86_64-apple-darwin";

    cargoSha256 = "sha256-r5PWeRvUyzuV26Eq4FWW67WCXBqQmpT8gBJujCys4k4=";

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
