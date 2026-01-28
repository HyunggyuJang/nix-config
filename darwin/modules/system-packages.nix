{ pkgs, ... }:
let
  # https://github.com/NixOS/nixpkgs/issues/11893
  altacv = with pkgs;
    stdenv.mkDerivation rec {
      name = "altacv";
      src = fetchFromGitHub {
        owner = "liantze";
        repo = "AltaCV";
        rev = "91373530c55843533a4de12a29d28896f9b14c0d";
        sha256 = "sha256-fRnElZqCN4hbjdyjjhxNTvKLwSzJf6WnaQDEFl5pGW4=";
      };
      pname = name;
      tlType = "run";
      installPhase = ''
        mkdir -p $out/tex/latex
        cp altacv.cls $out/tex/latex/
      '';
    };
in
{
  environment.systemPackages = with pkgs; [
    nixpkgs-fmt
    tree
    yaskkserv2
    skhd
    shellcheck
    solc-select
    tree-sitter
    llvm
    # WASM
    rustup
    pandoc
    openssl
    # Mail
    # lieer # Curretly installed manually by cloning the repo as instructed: https://afew.readthedocs.io/en/latest/installation.html
    # afew # Currently installed using pip3 install afew
    # Latex
    (texlive.combine {
      # https://gist.github.com/veprbl/3dc563802c97a95bcdc4eac6650ede7d
      inherit (texlive)
        scheme-medium zxjatype ctex biblatex tikz-cd xpatch cleveref svg
        trimspaces catchfile transparent capt-of enumitem fvextra upquote
        tcolorbox environ pdfcol nanumtype1 kotex-plain kotex-utf kotex-utils xetexko
        # jupyter export
        adjustbox standalone algorithm2e ifoddpage relsize wrapfig
        beamertheme-metropolis pdfx xmpincl accsupp fontawesome5 tikzfill
        tikzmark dashrule ifmtarg multirow changepage paracol titling titlesec;
      altacv = { pkgs = [ altacv ]; };
    })
    biber
    # OutsideIn(X)
    # ↓ Installed from ghcup
    # cabal-install
    # ghc
    ffmpeg-headless
    # sourcegraph
    nodePackages_latest.pnpm
    imagemagick
    ghostscript
    # scop
    # poetry

    # nix lsp
    nixd

    # System inspector & cleaner
    dua

    tree-sitter
    msmtp
    (aspellWithDicts (dicts: with dicts; [ en ]))
    jq
    pngpaste
    zstd
    isync
    ripgrep
    git
    gnupg
    pass
    gmp
    coreutils
    fd
    poppler
    pinentry_mac
    findutils
    # cmake
    automake
    ctags
    sdcv
    notmuch
    mermaid-cli
    nodejs
    awscli2
    gh
    go
    yq-go
    typescript-language-server
    vscode-json-languageserver
    kubectl
    bun
    kubernetes-helm
    istioctl
    # glab is provided via custom overlay to get v1.65.0
    glab
    postgresql
    mongosh
    tmux
    python3
    uv
    buf
    poppler-utils
  ];
  environment.pathsToLink = [ "/lib" "/share" ];
  environment.shells = [ pkgs.zsh ];
}
