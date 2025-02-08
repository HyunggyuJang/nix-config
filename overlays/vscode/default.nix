self: pkgs:

let
  # patchScript accepts an attribute set with an optional `prefix`
  # (defaulting to the empty string) and always patches the file
  # "Contents/Resources/app/out/main.js" (prefixed if needed).
  patchScript = { prefix ? "" }:
    ''
      FILE="${prefix}Contents/Resources/app/out/main.js"
      echo "Patching file: $FILE"
      if [ -f "$FILE" ]; then
        sed -i "s/webPreferences/frame:!1,webPreferences/" "$FILE"
      else
        echo "ERROR: $FILE not found!"
        echo "=== DEBUG: Directory structure after attempted patch ==="
        find .
        exit 1
      fi
    '';

  # applyPatch applies the patchScript to a package by overriding its postPatch phase.
  applyPatch = pkg: { prefix ? "" }:
    pkg.overrideAttrs (oldAttrs: {
      postPatch = oldAttrs.postPatch or "" + patchScript { prefix = prefix; };
    });
in {
  vscode      = applyPatch pkgs.vscode      {};           # No prefix
  code-cursor = applyPatch pkgs.code-cursor { prefix = "Cursor.app/"; };
}
