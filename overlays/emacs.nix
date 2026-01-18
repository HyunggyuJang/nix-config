self: pkgs:

{
  emacs-macport = pkgs.emacs-macport.overrideAttrs (oldAttrs: {
    multiTtyPatch = self.fetchurl {
      url = "https://raw.githubusercontent.com/railwaycat/homebrew-emacsmacport/bfd525788e24f2556d1e241156917f1e642f2e29/patches/emacs-mac-29.2-rc-1-multi-tty.diff";
      sha256 = "sha256-Tt5pjI+PVQnjq/Tmqcc+HcOQmw9S9SrUwzBov67T0eQ=";
    };
    notitleBarPatch = self.fetchurl {
      url = "https://raw.githubusercontent.com/railwaycat/homebrew-emacsmacport/bfd525788e24f2556d1e241156917f1e642f2e29/patches/emacs-26.2-rc1-mac-7.5-no-title-bar.diff";
      sha256 = "8319fd9568037c170f5990f608fb5bd82cd27346d1d605a83ac47d5a82da6066";
    };
    postPatch = oldAttrs.postPatch + ''
         patch -p1 < $notitleBarPatch
         patch -p1 < $multiTtyPatch
         '';
  });
  emacs = self.emacs-macport;
}
