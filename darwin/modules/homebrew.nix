{ lib, specialArgs, ... }:
let
  machineType = specialArgs.machineType;
in
{
  homebrew = {
    enable = true;
    onActivation.upgrade = false;
    onActivation.autoUpdate = false;
    onActivation.cleanup = "zap";
    global.brewfile = true;
    brewPrefix = "/opt/homebrew/bin";
    brews = [
      "nvm"
    ];
    casks = [
      "appcleaner"
      "kitty"
      "karabiner-elements"
      # "zoom"
      # "zotero"
      # elegant-emacs
      "font-roboto-mono"
      "font-roboto"
      # doom emacs's symbol font
      "font-juliamono"
      # math font
      # "font-dejavu"
      # beamer with xelatex
      # "font-fira-sans"
      # "font-fira-mono"
      # altacv with xelatex
      "font-lato"
      # Docker
      "docker-desktop"
      "obsidian"
      "neo4j-desktop"
      "android-studio"
      "figma"
      # "zed"
      # Demian
      "mongodb-compass"
      # onyx zsa moonlander
      "keymapp"
    ] ++ lib.optionals (machineType == "MacBook-Air") [
      "slack"
      # For Bing AI + Google meet
      "microsoft-edge"
      "inkscape"
      # "aquaskk"
      "discord"
      "hammerspoon"
      # zulip
      "vagrant"
      # Data analysis class
      "microsoft-excel"
      # School
      "microsoft-word"
      # audit
      "telegram"
    ] ++ lib.optionals (machineType == "MacBook-Pro") [
      "microsoft-teams"
    ] ++ lib.optionals (machineType == "M3-Pro") [
      "cloudflare-warp"
      "sdm"
      "cursor"
      "opencode-desktop"
    ];
    extraConfig = ''
      brew "aptos", args: ["force-bottle", "ignore-dependencies"]
      # brew "glab", args: ["force-bottle", "ignore-dependencies"]
      # brew "tilt", args: ["force-bottle", "ignore-dependencies"]
      brew "terraform-ls", args: ["force-bottle", "ignore-dependencies"]
      brew "aqua", args: ["force-bottle", "ignore-dependencies"]
      brew "git-filter-repo", args: ["force-bottle", "ignore-dependencies"]
      brew "ast-grep", args: ["force-bottle", "ignore-dependencies"]
    '';
  };
}
