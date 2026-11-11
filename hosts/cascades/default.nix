# 14"/16" MacBook Pro, M1 Pro, via nixos-apple-silicon (Asahi).
{ pkgs, ... }:

{
	imports = [
		./hardware-configuration.nix
		../../modules/common.nix
		../../modules/bell-labs-greeter.nix
	];

	hardware.asahi.enable = true;
	# peripheral firmware (wifi, bt, webcam) is read from /boot/vendorfw,
	# which is outside the flake, so rebuilds need --impure. it's non-
	# redistributable so don't copy it into this public repo.

	boot.loader.systemd-boot.enable = true;
	boot.loader.timeout = 0;
	boot.m1n1CustomLogo = ./bell.png;

	nixpkgs.overlays = [
		(final: prev: {
			uboot-asahi = prev.uboot-asahi.overrideAttrs (o: {
				extraConfig = o.extraConfig + ''
	CONFIG_BOOTDELAY=0
'';
			});
		})
	];
	
	# the asahi module forces efi.canTouchEfiVariables off, m1n1/u-boot own boot

	networking.hostName = "cascades";
	networking.networkmanager.wifi.backend = "iwd";

	programs.niri.enable = true;

	environment.systemPackages = with pkgs; [
		alacritty
		fuzzel
		brightnessctl
		xwayland-satellite
	];

	fonts.packages = [ pkgs.go-font ];

	services.physlock = {
		enable = true;
		allowAnyUser = true;
		lockOn.suspend = true;
		muteKernelMessages = true;
		lockMessage = "\n  TERMINAL SUSPENDED. AUTHENTICATE.";
	};

	system.stateVersion = "26.05";
}
