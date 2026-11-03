# Bell Labs desktop: niri + waybar + alacritty + fastfetch, cream and navy.
# Only imported on the mbp.
{ pkgs, lib, ... }:

let
	c = {
		cream = "#fffee8";
		ink   = "#1a1a1a";
		navy  = "#0000aa";
		green = "#007a00";
		ring  = "#9a9ad0";
		bar   = "#eefaff";
		hi    = "#bfefff";
	};

	banner = ''
		AT&T BELL LABORATORIES
		COMPUTING SYSTEMS DIVISION

		INSTALLATION:  07-8290
		EQUIPMENT:     PERSONAL UNIX TERMINAL
		SERVICE:       AT&T DATAGRID
		OPERATING SYS: UNIX COMPATIBILITY ENVIRONMENT
		MAINTENANCE:   CUSTOMER RESPONSIBILITY

		ALL SYSTEMS NOMINAL.

		NOTICE:
		THIS TERMINAL IS CONNECTED TO THE
		BELL SYSTEM COMPUTING NETWORK.

		UNAUTHORIZED INFERENCE IS BILLABLE.
	'';
in
{
	home.packages = with pkgs; [ go-font ];

	programs.alacritty = {
		enable = true;
		settings = {
			window.padding = { x = 6; y = 4; };
			font = {
				normal.family = "Go Mono";
				size = 11;
			};
			colors = {
				primary = { background = c.cream; foreground = c.ink; };
				cursor = { text = c.cream; cursor = c.ink; };
				selection = { text = c.ink; background = c.hi; };
				normal = {
					black = c.ink; red = "#aa0000"; green = c.green; yellow = "#8a6d00";
					blue = c.navy; magenta = "#8800aa"; cyan = "#007a8a"; white = "#555555";
				};
				bright = {
					black = "#555555"; red = "#cc3333"; green = "#228b22"; yellow = "#aa8800";
					blue = "#3333cc"; magenta = "#aa33cc"; cyan = "#3399aa"; white = "#777777";
				};
			};
		};
	};

	programs.fish = {
		functions.fish_greeting = ''
			printf '%s' ${lib.escapeShellArg banner}
		'';
		functions.fish_prompt = ''
			set_color --bold green
			printf '[%s@%s:%s]$ ' $USER (prompt_hostname) (prompt_pwd --full-length-dirs 2)
			set_color normal
		'';
	};

	programs.fastfetch = {
		enable = true;
		settings = {
			# drop your own art in ~/.config/fastfetch/logo.txt, falls back to the distro logo
			logo = {
				type = "file";
				source = "~/.config/fastfetch/logo.txt";
				color."1" = "blue";
				padding.right = 3;
			};
			display = {
				separator = "  ";
				color.keys = "bold_blue";
			};
			modules = [
				{ type = "command"; key = "SERVICE"; text = "echo AT\\&T DATAGRID"; }
				{ type = "command"; key = "INSTALLATION"; text = "echo 07-8290"; }
				{ type = "host"; key = "EQUIPMENT"; }
				{ type = "os"; key = "OPERATING SYS"; }
				{ type = "kernel"; key = "KERNEL"; }
				{ type = "uptime"; key = "IN SERVICE"; }
				{ type = "shell"; key = "COMMAND INTERP"; }
				{ type = "terminal"; key = "TERMINAL"; }
				{ type = "memory"; key = "CORE STORE"; }
				{ type = "disk"; key = "MASS STORE"; folders = "/"; }
				"break"
				{ type = "command"; key = "MAINTENANCE"; text = "echo CUSTOMER RESPONSIBILITY"; }
				{ type = "command"; key = "STATUS"; text = "echo ALL SYSTEMS NOMINAL"; }
			];
		};
	};

	programs.waybar = {
		enable = true;
		systemd.enable = true;
		settings.main = {
			layer = "top";
			position = "top";
			height = 22;
			modules-left = [ "niri/workspaces" "niri/window" ];
			modules-right = [ "pulseaudio" "network" "battery" "clock" ];
			"niri/workspaces".format = "{index}";
			"niri/window".format = "{title}";
			pulseaudio = { format = "vol {volume}%"; format-muted = "vol mute"; };
			network = {
				format-wifi = "net {essid}";
				format-ethernet = "net wired";
				format-disconnected = "net down";
			};
			battery = {
				format = "bat {capacity}%";
				format-charging = "bat {capacity}%+";
				format-plugged = "bat {capacity}%+";
			};
			clock.format = "{:%a %d %b %H:%M}";
		};
		style = ''
			* {
				font-family: "Go Mono";
				font-size: 12px;
				border: none;
				border-radius: 0;
				min-height: 0;
			}
			window#waybar { background: ${c.bar}; color: ${c.ink}; }
			#workspaces button { padding: 0 6px; color: ${c.ink}; background: transparent; }
			#workspaces button.active { background: ${c.hi}; }
			#window { padding: 0 10px; }
			#pulseaudio, #network, #battery, #clock { padding: 0 8px; }
		'';
	};

	xdg.configFile."niri/config.kdl".text = ''
		input {
			keyboard {
				xkb { layout "us"; }
			}
			touchpad {
				tap
				natural-scroll
			}
		}

		output "eDP-1" {
			scale 2
		}

		layout {
			gaps 8
			background-color "${c.cream}"
			center-focused-column "never"
			default-column-width { proportion 0.6; }

			focus-ring { off; }
			border {
				width 2
				active-color "${c.ring}"
				inactive-color "#c8c8e0"
			}
		}

		prefer-no-csd
		screenshot-path "~/Pictures/Screenshots/%Y-%m-%d %H-%M-%S.png"

		spawn-at-startup "xwayland-satellite"
		environment { DISPLAY ":0"; }

		window-rule {
			geometry-corner-radius 0
			clip-to-geometry true
		}

		binds {
			Mod+Return { spawn "alacritty"; }
			Mod+D { spawn "fuzzel"; }
			Mod+Q { close-window; }
			Mod+Shift+E { quit; }

			Mod+H { focus-column-left; }
			Mod+L { focus-column-right; }
			Mod+J { focus-window-down; }
			Mod+K { focus-window-up; }
			Mod+Shift+H { move-column-left; }
			Mod+Shift+L { move-column-right; }
			Mod+Shift+J { move-window-down; }
			Mod+Shift+K { move-window-up; }

			Mod+1 { focus-workspace 1; }
			Mod+2 { focus-workspace 2; }
			Mod+3 { focus-workspace 3; }
			Mod+4 { focus-workspace 4; }
			Mod+Shift+1 { move-column-to-workspace 1; }
			Mod+Shift+2 { move-column-to-workspace 2; }
			Mod+Shift+3 { move-column-to-workspace 3; }
			Mod+Shift+4 { move-column-to-workspace 4; }

			Mod+R { switch-preset-column-width; }
			Mod+F { maximize-column; }
			Mod+Shift+F { fullscreen-window; }
			Mod+Comma { consume-window-into-column; }
			Mod+Period { expel-window-from-column; }

			Print { screenshot; }
			Shift+Print { screenshot-screen; }

			XF86AudioRaiseVolume allow-when-locked=true { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%+"; }
			XF86AudioLowerVolume allow-when-locked=true { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%-"; }
			XF86AudioMute allow-when-locked=true { spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"; }
			XF86MonBrightnessUp { spawn "brightnessctl" "set" "5%+"; }
			XF86MonBrightnessDown { spawn "brightnessctl" "set" "5%-"; }
		}
	'';
}
