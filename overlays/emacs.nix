self: pkgs:

{
  emacsMacport = pkgs.emacsMacport.overrideAttrs (oldAttrs: {
    notitleBarPatch = self.fetchurl {
      url = "https://raw.githubusercontent.com/railwaycat/homebrew-emacsmacport/667f0efc08506facfc6963ac1fd1d5b9b777e094/patches/emacs-26.2-rc1-mac-7.5-no-title-bar.patch";
      sha256 = "8319fd9568037c170f5990f608fb5bd82cd27346d1d605a83ac47d5a82da6066";
    };
    installTargets = [ "tags" "install" ];
    postPatch = oldAttrs.postPatch + ''
         patch -p1 < $notitleBarPatch
         '';
    postInstall = oldAttrs.postInstall + ''
         for srcdir in src lisp lwlib ; do
           dstdir=$out/share/emacs/${oldAttrs.version}/$srcdir
           mkdir -p $dstdir
           find $srcdir -name "*.[chm]" -exec cp {} $dstdir \;
           cp $srcdir/TAGS $dstdir
           echo '((nil . ((tags-file-name . "TAGS"))))' > $dstdir/.dir-locals.el
         done
         '';
    passthru = {
      pkgs = with pkgs; dontRecurseIntoAttrs (emacsPackagesFor emacsMacport);
    };
  });
  emacs = self.emacsMacport;
}
