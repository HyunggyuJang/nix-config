{ lib, pkgs, hgj_home, ... }:
let
  emacsDir = "${hgj_home}/.emacs.d";
  doomRepo = "git@github.com:HyunggyuJang/doom-emacs.git";
in
{
  programs = {
    emacs = {
      enable = true;
      package = pkgs.emacs;
      extraPackages = (epkgs: [ epkgs.vterm ]);
    };
  };

  home.activation.bootstrapDoomEmacs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -e "${emacsDir}" ]; then
      $DRY_RUN_CMD ${pkgs.git}/bin/git clone "${doomRepo}" "${emacsDir}"
    elif [ ! -d "${emacsDir}/.git" ]; then
      echo "warning: ${emacsDir} exists but is not a git repository; skipping bootstrap" >&2
    fi
  '';
}
