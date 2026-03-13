{ lib, inputs, hostName, owner, hgj_home, ... }:
let
  secretsDir = inputs.secrets;
  sshSecretsDir = "${secretsDir}/ssh/${hostName}";
  sshSecretFiles =
    if builtins.pathExists sshSecretsDir then
      lib.filter (name: lib.hasSuffix ".age" name) (builtins.attrNames (builtins.readDir sshSecretsDir))
    else
      [ ];
  secretAttrs = builtins.listToAttrs (
    map (file:
      let
        name = lib.removeSuffix ".age" file;
        targetPath = "${hgj_home}/.ssh/${name}";
        mode = if lib.hasSuffix ".pub" name then "0644" else "0600";
      in
      {
        name = "ssh-${name}";
        value = {
          file = "${sshSecretsDir}/${file}";
          path = targetPath;
          owner = owner;
          mode = mode;
          symlink = false;
        };
      })
      sshSecretFiles
  );
  gitSecretsDir = "${secretsDir}/git/${hostName}";
  gitconfigWorkFile = "${gitSecretsDir}/gitconfig-work.age";
  gitconfigFile = "${gitSecretsDir}/gitconfig.age";
in
{
  age.identityPaths = lib.mkDefault [ "${hgj_home}/.ssh/agenix_ed25519" ];
  age.secrets = lib.mkMerge [
    (lib.mkIf (sshSecretFiles != [ ]) secretAttrs)
    (lib.mkIf (builtins.pathExists gitconfigWorkFile) {
      gitconfig-work = {
        file = gitconfigWorkFile;
        path = "${hgj_home}/.gitconfig-work";
        owner = owner;
        mode = "0600";
        symlink = false;
      };
    })
    (lib.mkIf (builtins.pathExists gitconfigFile) {
      gitconfig = {
        file = gitconfigFile;
        path = "${hgj_home}/.gitconfig";
        owner = owner;
        mode = "0600";
        symlink = false;
      };
    })
  ];
}
