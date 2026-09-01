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

		fish = {
			enable = true;

			interactiveShellInit = ''
			# Autoactivate devenv
			${pkgs.devenv}/bin/devenv hook fish | source
			'';
		};
	};

  services.darkman = {
    enable = true;

    settings = {
      lat = 44.47;
      lng = -73.21;
    };

    lightModeScripts.gnome-light = ''
      ${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
    '';

    darkModeScripts.gnome-dark = ''
      ${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
    '';
  };

	home.packages = with pkgs; [
		# dev
		pkgs.gram
		claude-code
		btop-rocm
		devenv

		# local inference / agents
		hermes-agent

		# thingy
		zotero
		deluge

		# fonts
		go-font
		comic-relief
		garamond-libre
		eb-garamond

		# communication
		inputs.helium.packages.${pkgs.system}.default
		slack
		python313Packages.nomadnet
	];
}
