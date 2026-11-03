# Stuff every desktop box shares. Host files only carry what's actually
# specific to that machine.
{ pkgs, ... }:
{
	nix.settings = {
		experimental-features = [ "nix-command" "flakes" ];

		substituters = [
			"https://cache.nixos.org"
			"https://arcadesagency.cachix.org"
		];

		trusted-public-keys = [
			"cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
			"arcadesagency.cachix.org-1:sjLxki4X0B5zor3c+phsFsHY3LA8B4Rp+hNxIPRgUpg="
		];

		trusted-users = [ "arcade" ];
	};

	networking.networkmanager.enable = true;
	hardware.graphics.enable = true;

	time.timeZone = "America/New_York";

	i18n.defaultLocale = "en_US.UTF-8";
	i18n.extraLocaleSettings = {
		LC_ADDRESS = "en_US.UTF-8";
		LC_IDENTIFICATION = "en_US.UTF-8";
		LC_MEASUREMENT = "en_US.UTF-8";
		LC_MONETARY = "en_US.UTF-8";
		LC_NAME = "en_US.UTF-8";
		LC_NUMERIC = "en_US.UTF-8";
		LC_PAPER = "en_US.UTF-8";
		LC_TELEPHONE = "en_US.UTF-8";
		LC_TIME = "en_US.UTF-8";
	};

	services.tailscale.enable = true;

	services.syncthing = {
		enable = true;
		openDefaultPorts = true;
	};

	services.pulseaudio.enable = false;
	security.rtkit.enable = true;
	services.pipewire = {
		enable = true;
		alsa.enable = true;
		alsa.support32Bit = pkgs.stdenv.hostPlatform.isx86_64;
		pulse.enable = true;
	};

	users.users."arcade" = {
		isNormalUser = true;
		description = "Arcade Wise";
		extraGroups = [ "networkmanager" "wheel" "render" "video" "dialout" ];
		shell = pkgs.fish;
	};

	programs.fish.enable = true;

	nixpkgs.overlays = [ (import ../overlays) ];
	nixpkgs.config.allowUnfree = true;

	environment.systemPackages = with pkgs; [
		micro
		git
		wget
		file
		binutils
	];
}
