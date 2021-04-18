self: super: {

installApplication =
  { name, appname ? name, version, src, description, homepage,
    postInstall ? "", sourceRoot ? ".", ... }:
  with super; stdenv.mkDerivation {
    name = "${name}-${version}";
    version = "${version}";
    src = src;
    buildInputs = [ undmg unzip ];
    sourceRoot = sourceRoot;
    phases = [ "unpackPhase" "installPhase" ];
    installPhase = ''
      mkdir -p "$out/Applications/${appname}.app"
      cp -pR * "$out/Applications/${appname}.app"
    '' + postInstall;
    meta = with super.lib; {
      description = description;
      homepage = homepage;
      maintainers = with maintainers; [ hyunggyujang ];
      platforms = platforms.darwin;
    };
  };

Qutebrowser = self.installApplication rec {
  name = "Qutebrowser";
  version = "2.1.1";
  sourceRoot = "Qutebrowser.app";
  src = super.fetchurl {
    url = "https://github.com/qutebrowser/qutebrowser/releases/download/v${version}/qutebrowser-${version}.dmg";
    sha256 = "19cfgaq6mrbkih5g37s1q9c3w925x8zvv389ia6dcabhdjh2xksl";
  };
  description = "Qutebrowser is a keyboard-focused browser with a minimal GUI.";
  homepage = https://www.qutebrowser.org;
};

Ukelele = self.installApplication rec {
  name = "Ukelele";
  version = "3.5.2";
  sourceRoot = "Ukelele.app";
  src = super.fetchurl {
    name = "Ukelele-${version}.dmg";
    url = "https://software.sil.org/downloads/r/ukelele/Ukelele_${version}.dmg";
    sha256 = "0hpn9prqj5ppzrml2a94yacf5a9bp2xblvm3w6jwmw78rsrpm10y";
  };
  description = "Ukelele is a Unicode Keyboard Layout Editor for Mac OS X";
  homepage = http://scripts.sil.org/ukelele;
};

Anki = self.installApplication rec {
  name = "Anki";
  version = "2.1.42";
  sourceRoot = "Anki.app";
  src = super.fetchurl {
    name = "Anki-${version}.dmg";
    url = "https://github.com/ankitects/anki/releases/download/${version}/anki-${version}-mac.dmg";
    sha256 = "094c283myi6zcpwxh0l0gqk62ws8m19d215xg9zslmasms5b832g";
  };
  description = "Anki is a program which makes remembering things easy";
  homepage = https://apps.ankiweb.net;
};

}
