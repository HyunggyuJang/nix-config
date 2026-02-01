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
in
{
  age.identityPaths = lib.mkDefault [ "${hgj_home}/.ssh/id_ed25519" ];
  age.secrets = lib.mkIf (sshSecretFiles != [ ]) secretAttrs;
}
