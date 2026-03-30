final: prev:

let
  generatedNodePackages = import ./packages {
    pkgs = prev;
    system = prev.stdenv.hostPlatform.system;
    nodejs = prev.nodejs;
  };
  jsdom = generatedNodePackages.jsdom.override {
    preRebuild = ''
      sed 's/"link:/"file:/g' --in-place package.json
    '';
  };
in
{
  inherit jsdom;
  myNodePackages = generatedNodePackages // {
    inherit jsdom;
  };
}
