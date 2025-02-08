self: pkgs:

let
  # patchFor takes an attribute set with an optional 'prefix' (defaulting to the empty string)
  patchFor = { prefix ? "" }:
    ''
      FILE="${prefix}Contents/Resources/app/out/main.js"
      echo "Patching file: $FILE"
      if [ -f "$FILE" ]; then
        sed -i "s/webPreferences/frame:!1,webPreferences/" "$FILE"
      else
        echo "ERROR: $$FILE not found!"
        echo "=== DEBUG: Directory structure after attempted patch ==="
        find .
        exit 1
      fi
    '';
in {
  vscode = pkgs.vscode.overrideAttrs (oldAttrs: {
    # No need to pass an empty string—just call with an empty attribute set.
    postPatch = oldAttrs.postPatch or "" + patchFor {};
  });
  code-cursor = pkgs.code-cursor.overrideAttrs (oldAttrs: {
    # Only pass a prefix when needed.
    postInstall = oldAttrs.postInstall or "" + patchFor { prefix = "Cursor.app/"; };
  });
}
