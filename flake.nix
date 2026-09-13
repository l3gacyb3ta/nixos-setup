{
	description = "arcade's systems";

	inputs = {
		nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
		nixos-hardware.url = "github:NixOS/nixos-hardware";
		home-manager = {
			url = "github:nix-community/home-manager/release-26.05";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		disko = {
			url = "github:nix-community/disko";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		sops-nix = {
			url = "github:Mic92/sops-nix";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		# Private repo, so ssh rather than the github: fetcher, which would
		# need a token. nixos-anywhere ships the locked inputs to the target,
		# so the box does not fetch this during the initial install.
		mega-app = {
			url = "git+ssh://git@github.com/l3gacyb3ta/mega-app.git?ref=main";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		helium = {
			url = "github:AlvaroParker/helium-nix";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		#affinity-nix.url = "github:mrshmllow/affinity-nix";
	};

	outputs = { self, nixpkgs, nixos-hardware, home-manager, disko, sops-nix, mega-app, ... }@inputs: {
		# board.arcades.agency — Hetzner Cloud, runs the mega-app and nothing else.
		nixosConfigurations.board = nixpkgs.lib.nixosSystem {
			system = "x86_64-linux";
			specialArgs = { inherit inputs; };
			modules = [
				disko.nixosModules.disko
				sops-nix.nixosModules.sops
				mega-app.nixosModules.megaapp
				./hosts/board/default.nix
			];
		};

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
