{ pkgs, hgj_darwin_home, hgj_home, hgj_local, hgj_localbin, brewpath, ... }:
{
  environment =
    let
      envVars = {
        # Keep macOS-style GUI fallback and rely on LaunchServices registration
        # to resolve Emacs.app to the Doom-wrapped app.
        EDITOR = "emacsclient --alternate-editor='open -a Emacs'";
        VISUAL = "$EDITOR";
        LANG = "en_US.UTF-8";
        DOOMLOCALDIR = "${hgj_home}/.doom";
        SHELL = "${pkgs.zsh}/bin/zsh";
        # LIBGS = "/opt/homebrew/lib/libgs.dylib"; # For tikz's latex preview.
        npm_config_prefix = "$HOME/${hgj_local}";
        PNPM_HOME = "$HOME/${hgj_localbin}";
        BUN_HOME = "$HOME/.cache/.bun";
        JAVA_HOME = "$HOME/.gradle/jdks/eclipse_adoptium-17-aarch64-os_x/jdk-17.0.17+10/Contents/Home";
        OPENCODE_EXPERIMENTAL = "true";
      };
    in
    {
      darwinConfig = "${hgj_darwin_home}/configuration.nix";
      variables = envVars;
      systemPath = [
        "$HOME/${hgj_localbin}"
        # Easy access to Doom
        # SystemPath added before to the variables, it can be inspected at /etc/static/zshenv,
        # which source *-set-environment file.
        "${hgj_home}/.emacs.d/bin"
        "${brewpath}/bin"
        # rust
        "$HOME/.cargo/bin"
        # ruby
        "$HOME/.rbenv/shims"
        # Haskell
        "$HOME/.ghcup/bin"
        "$HOME/.cabal/bin"
        # go
        "$HOME/go/bin"
        # javascript
        "${envVars.BUN_HOME}/bin"
        # Java
        "\"${envVars.JAVA_HOME}/bin\""
        # opencode
        "$HOME/.opencode/bin"
      ];
    };
}
