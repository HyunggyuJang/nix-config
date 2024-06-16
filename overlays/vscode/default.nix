self: pkgs:

{
  vscode = pkgs.vscode.overrideAttrs (oldAttrs: {
    vscodeWithExtensions = pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      {
        name = "apc-extension";
        publisher = "drcika";
        version = "0.3.9";
        sha256 = "sha256-VMUICGvAFWrG/uL3aGKNUIt1ARovc84TxkjgSkXuoME=";
      }
    ];

    postPatch = oldAttrs.postPatch or "" + ''
      cp "${./patch-vscode.sh}" $TMPDIR/patch-vscode.sh
      chmod +x $TMPDIR/patch-vscode.sh

      cp -r "$vscodeWithExtensions/share/vscode/extensions/drcika.apc-extension/." "$TMPDIR/extension/"

      $TMPDIR/patch-vscode.sh "$TMPDIR/extension" "Contents/Resources/app/out"
    '';
  });
}
