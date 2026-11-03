# Bell Labs login: tuigreet on greetd, cream VT palette, Go Mono console font.
# Theme lifted from @bunniemoder.
{ pkgs, lib, ... }:

let
	font = pkgs.callPackage ../pkgs/go-mono-psf.nix { pixelSize = 32; };

	# tuigreet centres each issue line on its own, so every line is padded
	# to the same width to keep the block left-aligned like a real banner
	pad = s: s + lib.strings.replicate (38 - lib.stringLength s) " ";
	banner = lib.concatMapStrings (l: pad l + "\n") [
		"AT&T BELL LABORATORIES"
		"COMPUTING SYSTEMS DIVISION"
		""
		"INSTALLATION:  07-8290"
		"EQUIPMENT:     PERSONAL UNIX TERMINAL"
		""
		"UNAUTHORIZED INFERENCE IS BILLABLE."
	];

	theme = lib.concatStringsSep ";" [
		"container=black"   # palette 0, the cream
		"border=blue"
		"title=blue"
		"text=blue"
		"greet=blue"
		"prompt=blue"
		"input=blue"
		"time=blue"
		"action=blue"
		"button=darkgray"   # palette 8, real black, for the ESC/F2 chips
	];
in
{
	# VT palette. tuigreet only speaks ANSI names, so the look lives here.
	console = {
		earlySetup = true;
		font = "${font}/share/consolefonts/GoMono-32.psf.gz";
		colors = [
			"fffee8" # 0  black   -> cream background
			"aa0000" # 1  red
			"007a00" # 2  green
			"8a6d00" # 3  yellow
			"0000aa" # 4  blue
			"8800aa" # 5  magenta
			"007a8a" # 6  cyan
			"0000aa" # 7  white   -> default fg, navy
			"000000" # 8  darkgray -> key chips
			"cc3333" # 9
			"33aa33" # 10
			"aa8800" # 11
			"3333cc" # 12
			"aa33cc" # 13
			"3399aa" # 14
			"0000aa" # 15
		];
	};

	environment.etc."issue".text = lib.mkForce banner;

	services.greetd = {
		enable = true;
		useTextGreeter = true;
		settings.default_session = {
			user = "greeter";
			command = lib.concatStringsSep " " [
				"${lib.getExe pkgs.tuigreet}"
				"--time --time-format '%a, %d %b %Y - %H:%M'"
				"--issue"
				"--remember --asterisks"
				"--cmd niri-session"
				"--theme '${theme}'"
			];
		};
	};
}
