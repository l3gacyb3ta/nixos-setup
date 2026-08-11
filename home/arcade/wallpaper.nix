{ config, pkgs, ... }:

let
	downloadedWallpaper = pkgs.fetchurl {
		url = "https://upload.wikimedia.org/wikipedia/commons/7/72/Enterprise_free_flight.jpg";
		hash = "sha256-brkrfrzB2F9gdRDn5G8h1abQrCFAP1T55kk7XIUs2W0=";
	};
in
{
	dconf.settings = {
		"org/gnome/desktop/background" = {
			picture-uri = "file://${downloadedWallpaper}";
			picture-uri-dark = "file://${downloadedWallpaper}";
		};
	};
}
