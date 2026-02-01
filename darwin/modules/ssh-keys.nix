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
  gitSecretFile = "${gitSecretsDir}/gitconfig-work.age";
in
{
  age.identityPaths = lib.mkDefault [ "${hgj_home}/.ssh/agenix_ed25519" ];
  age.secrets = lib.mkMerge [
    (lib.mkIf (sshSecretFiles != [ ]) secretAttrs)
    (lib.mkIf (builtins.pathExists gitSecretFile) {
      gitconfig-work = {
        file = gitSecretFile;
        path = "${hgj_home}/.gitconfig-work";
        owner = owner;
        mode = "0600";
        symlink = false;
      };
    })
  ];
}
