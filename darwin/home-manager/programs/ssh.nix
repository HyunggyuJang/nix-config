{ ... }:
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    includes = [ "~/.ssh/config.private" ];
    matchBlocks = {
      "*" = {
        addKeysToAgent = "yes";
        identityFile = [ "~/.ssh/id_ed25519" ];
      };
    };
  };
}
