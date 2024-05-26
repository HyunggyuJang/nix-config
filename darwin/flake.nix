{
  description = "Hyunggyu's darwin system";

  inputs = {
    nixpkgs.url =
      "github:NixOS/nixpkgs/3305b2b25e4ae4baee872346eae133cf6f611783";
    nix-darwin.url =
      "github:LnL7/nix-darwin/0bea8222f6e83247dd13b055d83e64bce02ee532";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url =
      "github:nix-community/home-manager/850cb322046ef1a268449cf1ceda5fd24d930b05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nur.url =
      "github:nix-community/NUR/8ef4be789b09122a98de08ef3496c65511b3b35d";
    nixpkgs-firefox-darwin.url = "github:bandithedoge/nixpkgs-firefox-darwin/37d616abf90e7a1ee0fa33bf6d9dce6bfe164e4c";
  };

  outputs = inputs@{ nix-darwin, nixpkgs, nur, ... }: {
    formatter.aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.nixfmt;
    darwinConfigurations.Hyunggyus-MacBook-Air = nix-darwin.lib.darwinSystem {
      modules = [ ./configuration.nix nur.nixosModules.nur ];
      specialArgs = { inherit inputs; };
    };
    devShells.aarch64-darwin.default =
      nixpkgs.legacyPackages.aarch64-darwin.mkShell { };
  };
}
