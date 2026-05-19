{
  description = "Hans's NixOS hosts";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ nixpkgs, agenix, ... }: {
    apps.x86_64-linux.agenix = {
      type = "app";
      program = "${agenix.packages.x86_64-linux.default}/bin/agenix";
    };

    packages.x86_64-linux.agenix = agenix.packages.x86_64-linux.default;

    nixosConfigurations = {
      anubis = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          agenix.nixosModules.default
          ./hosts/anubis
        ];
      };
    };
  };
}
