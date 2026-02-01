{ config ? inputs.nix-darwin.config, pkgs ? inputs.nixpkgs, lib, inputs, host, ... }:
let
  machineType = host.machineType;
  owner = host.owner;
  hostName = host.name;
  hgj_home = "/Users/${owner}";
  hgj_sync = hgj_home;
  hgj_darwin_home = "${hgj_sync}/nixpkgs/darwin";
  hgj_projects = "${hgj_home}/notes/1-Projects";
  hgj_local = ".local";
  hgj_localbin = "${hgj_local}/bin";
  brewpath = "/opt/homebrew";

in
with lib; rec {
  # See https://github.com/LnL7/nix-darwin/issues/701
  documentation.enable = false;

  _module.args = {
    inherit host hostName owner machineType hgj_home hgj_sync hgj_darwin_home hgj_projects hgj_local hgj_localbin brewpath inputs;
  };

  # Home manager
  imports = [
    "${inputs.home-manager}/nix-darwin"
    inputs.agenix.darwinModules.default
    ./modules/homebrew.nix
    ./modules/overlays.nix
    ./modules/system-base.nix
    ./modules/system-defaults.nix
    ./modules/environment.nix
    ./modules/services.nix
    ./modules/system-programs.nix
    ./modules/nix-settings.nix
    ./modules/home-manager.nix
    ./modules/system-packages.nix
  ];
}
