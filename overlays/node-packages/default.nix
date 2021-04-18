self: pkgs:

let myNodePackages = import ./packages {};
in
{
  nodePackages = pkgs.nodePackages // myNodePackages // {
    jsdom = myNodePackages.jsdom.override {
      preRebuild = ''
       sed 's/"link:/"file:/g' --in-place package.json
     '';
    };
  };
}
