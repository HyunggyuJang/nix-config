{ pkgs, ... }:
{
  programs = {
          emacs = {
            enable = true;
            package = pkgs.emacs;
            extraPackages = (epkgs: [ epkgs.vterm ]);
          };
  };
}
