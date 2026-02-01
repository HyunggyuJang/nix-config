let
  host = "A13884ui-MacBookPro";
  users = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPb+1f40ul2LmtRfs6wuT3F5gGDymSWIl3yPfOZOI/ea"
  ];
  systems = [ ];
  recipients = users ++ systems;

  sshSecret = name: {
    "ssh/${host}/${name}.age".publicKeys = recipients;
  };

  sshSecrets = names:
    builtins.foldl' (acc: name: acc // (sshSecret name)) { } names;

  sshFiles = [
    "id_ed25519"
    "id_ed25519.pub"
    "id_rsa"
    "id_rsa.pub"
    "gitlab_42dotpol"
    "gitlab_42dotpol.pub"
    "ios"
    "ios.pub"
    "poc-ec2.pem"
  ];
in
sshSecrets sshFiles
