{ pkgs, ... }:
{
	home.stateVersion = "26.05";

	programs = {
		git = {
			enable = true;
			settings.user = {
				name = "Arcade";
				email = "l3gacy.b3ta@gmail.com";
			};
		};

		nh = {
			enable = true;
			clean.enable = true;
			clean.extraArgs = "--keep-since 7d --keep 5";
			flake = "/home/arcade/nixos";
		};
	};

	home.packages = with pkgs; [ ];
}
