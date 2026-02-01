{
  config,
  lib,
  pkgs,
  inputs,
  owner,
  hostName,
  machineType,
  hgj_home,
  hgj_projects,
  hgj_darwin_home,
  hgj_localbin,
  brewpath,
  ...
}:
{
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = false;
  home-manager.extraSpecialArgs = {
    inherit
      hostName
      owner
      machineType
      hgj_home
      hgj_projects
      hgj_darwin_home
      hgj_localbin
      brewpath
      inputs
      ;
  };
  home-manager.users.${owner} = {
    home.stateVersion = "24.11";
    imports = [
      ./files.nix
      ./targets.nix
      ./xdg.nix
      ./programs/vscode.nix
      ./programs/zsh.nix
      ./programs/direnv.nix
      ./programs/emacs.nix
      ./programs/firefox.nix
      ./programs/fzf.nix
      ./programs/browserpass.nix
      ./programs/tmux.nix
    ];
  };
}
