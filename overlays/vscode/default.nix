self: pkgs:

{
  vscode = pkgs.vscode.overrideAttrs (oldAttrs: {
    postPatch = oldAttrs.postPatch or "" + ''
      FILE="Contents/Resources/app/out/main.js"
      sed -i "s/webPreferences/frame:!1,webPreferences/" "$FILE"
    '';
  });
}
