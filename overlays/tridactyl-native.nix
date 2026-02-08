final: prev: {
  tridactyl-native = prev.tridactyl-native.overrideAttrs (_old: {
    version = "0.5.0";
    src = prev.fetchFromGitHub {
      owner = "tridactyl";
      repo = "native_messenger";
      rev = "0.5.0";
      hash = "sha256-lOBiWLQp28jIxrmYDYnNfxfFXmSgneKU4ZrHpoHZ9ik=";
    };
  });
}
