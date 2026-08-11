{
	description = "arcade's systems";

	inputs = {
		nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
	};

	outputs = { self, nixpkgs, ... }@inputs: {
		nixosConfigurations.framework = nixpkgs.lib.nixosSystem {
			specialArgs = { inherit inputs; };
			modules = [
				./hosts/framework/default.nix
				./hosts/framework/hardware-configuration.nix
			];
		};
	};
}
