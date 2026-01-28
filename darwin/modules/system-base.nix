{ pkgs, owner, hgj_home, ... }:
{
  system.primaryUser = owner;
  system.stateVersion = 5;

  users = {
    users.${owner} = {
      name = owner;
      home = hgj_home;
      shell = pkgs.zsh;
    };
  };

  fonts = {
    packages = [ pkgs.ibm-plex ];
  };

  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config.allowUnfree = true;

  ids.gids.nixbld = 30000;
}
