final: prev:
with prev;
{
  yaskkserv2 = rustPlatform.buildRustPackage rec {
    pname = "yaskkserv2";
    version = "0.1.5";
    src = fetchFromGitHub {
      owner = "wachikun";
      repo = pname;
      rev = "c5e2e32807e9871205e1bfb58dfaaa40f5957021";
      sha256 = "sha256-i1Nsga1BJgG0gdeTvg0KvkpmKb1qp/PlXfgjJHSGAxQ=";
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
