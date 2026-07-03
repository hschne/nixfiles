{
  description = "Hans's NixOS hosts";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, agenix, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    {
      apps.${system}.agenix = {
        type = "app";
        program = "${agenix.packages.${system}.default}/bin/agenix";
      };

      packages.${system} = {
        agenix = agenix.packages.${system}.default;
        picoclaw = pkgs.callPackage ./packages/picoclaw.nix { };

        # Bootable installer ISO. Build with:
        #   nix build .#installer-iso
        installer-iso = self.nixosConfigurations.installer.config.system.build.isoImage;
      };

      nixosConfigurations = {
        anubis = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            agenix.nixosModules.default
            ./hosts/anubis
          ];
        };

        rocinante = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            agenix.nixosModules.default
            ./hosts/rocinante
          ];
        };

        installer = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs self; };
          modules = [ ./hosts/installer ];
        };
      };
    };
}
