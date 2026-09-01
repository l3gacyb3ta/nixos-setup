{
	description = "arcade's systems";

	inputs = {
		nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
		nixos-hardware.url = "github:NixOS/nixos-hardware";
		home-manager = {
			url = "github:nix-community/home-manager/release-26.05";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		helium = {
			url = "github:AlvaroParker/helium-nix";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		#affinity-nix.url = "github:mrshmllow/affinity-nix";
	};

	outputs = { self, nixpkgs, nixos-hardware, home-manager, ... }@inputs: {
		nixosConfigurations.framework = nixpkgs.lib.nixosSystem {
			specialArgs = { inherit inputs; };
			modules = [
				nixos-hardware.nixosModules.framework-desktop-amd-ai-max-300-series
				./hosts/framework/default.nix
				./hosts/framework/hardware-configuration.nix
				home-manager.nixosModules.home-manager
				{
					home-manager.useGlobalPkgs = true;
					home-manager.useUserPackages = true;
					home-manager.extraSpecialArgs = { inherit inputs; };
					home-manager.users.arcade = import ./home/arcade;
				}

			 ({ pkgs, ... }: {
          #nixpkgs.overlays = [ affinity-nix.overlays.default ];
          #environment.systemPackages = [ pkgs.affinity-v3 ];
        })
			];
		};

		packages.x86_64-linux = {
			gram = (import nixpkgs { system = "x86_64-linux"; overlays = [ (import ./overlays) ]; }).callPackage ./pkgs/gram.nix { };
		};
	};
}
