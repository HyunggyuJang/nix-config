self: pkgs:

{
  vscode = pkgs.vscode.overrideAttrs (oldAttrs: {
    postPatch = oldAttrs.postPatch or "" + ''
      FILE="Contents/Resources/app/out/vs/code/electron-main/main.js"
      sed -i "s/webPreferences/frame:!1,webPreferences/" "$FILE"
    '';
  });
}
