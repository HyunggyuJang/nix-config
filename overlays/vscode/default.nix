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
  # Replaces the code-cursor package, which will be installed via brew; nixpkgs version is not updated due to https://github.com/NixOS/nixpkgs/issues/386176
  # code-cursor = applyPatch pkgs.code-cursor { prefix = "Cursor.app/"; };
  code-cursor = pkgs.stdenv.mkDerivation {
    pname = "cursor";
    version = "0.0.0";
    src = null;
    dontUnpack = true;
    phases = [ "installPhase" ];

    # The installPhase must produce the output in $out.
    installPhase = ''
      mkdir -p $out/bin
      touch $out/bin/cursor
      chmod +x $out/bin/cursor
    '';
    meta.mainProgram = "cursor";
  };
  zed-editor = pkgs.stdenv.mkDerivation {
    pname = "zed-editor";
    version = "0.0.0";
    src = null;
    dontUnpack = true;
    phases = [ "installPhase" ];

    # The installPhase must produce the output in $out.
    installPhase = ''
      mkdir -p $out
    '';
  };
}
