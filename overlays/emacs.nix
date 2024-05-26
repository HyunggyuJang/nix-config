self: pkgs:

{
  emacsMacport = pkgs.emacsMacport.overrideAttrs (oldAttrs: {
    multiTtyPatch = self.fetchurl {
      url = "https://raw.githubusercontent.com/railwaycat/homebrew-emacsmacport/7abbd0c8887876cb54675afb5545b76fe83c2d31/patches/emacs-mac-29-multi-tty.diff";
      sha256 = "sha256-RBLONWiePK+Oix11G/NkG0c8067xGInT7NaCR0vyBLA=";
    };
    notitleBarPatch = self.fetchurl {
      url = "https://raw.githubusercontent.com/railwaycat/homebrew-emacsmacport/7abbd0c8887876cb54675afb5545b76fe83c2d31/patches/emacs-26.2-rc1-mac-7.5-no-title-bar.patch";
      sha256 = "8319fd9568037c170f5990f608fb5bd82cd27346d1d605a83ac47d5a82da6066";
    };
    postPatch = oldAttrs.postPatch + ''
         patch -p1 < $notitleBarPatch
         patch -p1 < $multiTtyPatch
         '';
  });
  emacs = self.emacsMacport;
}
