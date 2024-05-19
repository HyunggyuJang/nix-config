final: prev: {
  firefox-darwin = prev.firefox-bin.overrideAttrs (previousAttrs: {
    postInstall = ''
      folder="''${out}/Applications/Firefox.app/Contents/Resources/distribution"
      mkdir -p "''${folder}"

      touch "''${folder}/policies.json"

      echo '{
      "policies": {
        "DisableAppUpdate": true,
        "AppAutoUpdate": false,
        "ExtensionUpdate": false,
        "EncryptedMediaExtensions": {
          "Enabled": false
        }
      }
      }' > "''${folder}/policies.json"
    '';
  });
}
