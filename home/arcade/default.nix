{ pkgs, inputs, ... }:
{
	home.stateVersion = "26.05";

	imports = [
		./wallpaper.nix
	];

	programs = {
		direnv = {
			enable = true;
			nix-direnv.enable = true;
		};
	
		git = {
			enable = true;
			settings.user = {
				name = "Arcade";
				email = "l3gacy.b3ta@gmail.com";
			};
			settings.init.defaultBranch = "main";
		};

		nh = {
			enable = true;
			clean.enable = true;
			clean.extraArgs = "--keep-since 7d --keep 5";
			flake = "/home/arcade/nixos";
		};

		fish.enable = true;
	};

	home.packages = with pkgs; [
		# dev
		pkgs.gram
		claude-code
		btop-rocm

		# local inference / agents
		hermes-agent

		# thingy
		zotero
		deluge

		# communication
		inputs.helium.packages.${pkgs.system}.default
		slack
		python313Packages.nomadnet
	];
}
