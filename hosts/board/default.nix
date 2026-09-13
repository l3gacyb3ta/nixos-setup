# board.arcades.agency — the mega-app host.
#
# Hetzner Cloud, 2 vCPU / 3.7GB / 38GB. Runs exactly one thing.
{ config, pkgs, lib, ... }:

{
	imports = [ ./disko.nix ];

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

		# Two cores and 3.7GB: a runaway build must not be able to take the
		# board down with it.
		max-jobs = 2;
		cores = 2;
	};

	# The box is disposable; the database is not. Keep the store tidy so a
	# year of deploys cannot fill the disk out from under Postgres.
	nix.gc = {
		automatic = true;
		dates = "weekly";
		options = "--delete-older-than 14d";
	};
	nix.optimise.automatic = true;

	boot.loader.systemd-boot.enable = true;
	# Must be true. With it false, bootctl copies systemd-boot onto the ESP
	# but cannot write the NVRAM boot entry that points at it — the firmware
	# then finds nothing to boot and stops at "booting from hard disk".
	# Hetzner Cloud's firmware handles EFI variables fine.
	boot.loader.efi.canTouchEfiVariables = true;

	networking = {
		hostName = "board";
		useDHCP = lib.mkDefault true;
		# Hetzner hands out IPv4 over DHCP but expects IPv6 to be set
		# statically, with an on-link gateway at fe80::1.
		interfaces.eth0.ipv6.addresses = [
			{
				address = "2a01:4f8:1c18:69bc::1";
				prefixLength = 64;
			}
		];
		defaultGateway6 = {
			address = "fe80::1";
			interface = "eth0";
		};
		firewall = {
			# Caddy opens 80 and 443 itself.
			allowedTCPPorts = [ 22 ];
			# Tailscale's UDP port, for direct connections rather than relaying
			# everything through DERP.
			allowedUDPPorts = [ config.services.tailscale.port ];
			# The tailnet is trusted: it is how this box reaches Calibre and
			# Zotero at home, and nothing else is on it.
			trustedInterfaces = [ "tailscale0" ];
			# Tailscale's own recommendation — strict reverse-path filtering
			# drops replies that arrive over the tunnel.
			checkReversePath = "loose";
		};
	};

	# The board's own data all arrives over the public internet, but the
	# document corpus does not: Calibre-web and Zotero's WebDAV live on the
	# Framework, which is not publicly reachable and should stay that way.
	# Tailscale is how the VPS gets to them, with no ports opened at home and
	# no dynamic DNS.
	#
	# A sleeping laptop is simply an unreachable node — never a bug, always an
	# expected state — so every job that touches those sources has to be
	# retry-safe regardless.
	services.tailscale = {
		enable = true;
		useRoutingFeatures = "client";
		# Deliberately no authKeyFile: an expired key would leave a unit
		# failing on every boot for no benefit. Run `tailscale up` once after
		# the first install.
	};

	time.timeZone = "America/New_York";

	services.openssh = {
		enable = true;
		settings = {
			PasswordAuthentication = false;
			PermitRootLogin = "prohibit-password";
		};
	};

	users.users.root.openssh.authorizedKeys.keys = [
		"ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCwBcrBAHEiLLU2rzv6wR98JLk+Rd4vsIBbXVz97R0lPiIo59IKUB795hd6ton4CeU4OjiYt5lm8+2T6G6CQe8F5868yjdfbMEdVcdIMfHczVpvC0Dn/2mjgIOQrp/khBzMLj/VU/kHeG94Lx5UMEvFa5wOlfSi32JhGF1GJGJmLH75U+B5pmGp8S6I74z4Fm+xKf8iqe+wRGpfsHU0eqcLfwaQroBLhUUeYJrhPxF4G0ox1c8LsLs+UM6ZbckPk8NaUm32lxcKrteUhLbEWf7gbeBamhGfO3aDfWINoXJVDKbHJFWK6blQsqfMhmP+LD9I9T1AePALLwpJyBzaj4zndBMy8r9J3IdrUt2qaswTeKirBk9nm+xAH+C9B9UOY0ya6YsnaUr1O1aInPOQRlQQDYnrKXwMHVHgKxVCBb+Zxo4eu5cp8DePy5N6QMeyUyCzWcvo0wKdodcvZE3LJU62AJEAk035cMzWil+Ks/5Dkf7l14d7ULdKqjcjMJlVzsE="
	];

	environment.systemPackages = with pkgs; [
		git
		htop
		postgresql_18 # psql, for looking at the board's own data
	];

	services.megaapp = {
		enable = true;
		domain = "board.arcades.agency";
		environmentFile = config.sops.secrets."megaapp-env".path;
		place = "Burlington";
	};

	sops.secrets."megaapp-env" = {
		# Whole-file, opaque, handed to systemd as an EnvironmentFile.
		#
		# "dotenv" also works and gives nicer git diffs (one ENC block per
		# key rather than one blob) — but it needs `key = ""` alongside it,
		# because `key` defaults to the *secret's name* and would otherwise
		# look for a variable literally called "megaapp-env" inside the file.
		#
		# The filename has no extension on purpose: sops picks its format
		# from the extension, and ".env" silently made this dotenv, which is
		# what broke the first install.
		format = "binary";
		sopsFile = ../../secrets/megaapp-env;
		# Decrypted at boot using the host's own SSH key, so no key material
		# has to be copied anywhere after install.
		mode = "0400";
		owner = "root";
	};
	sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

	# How the Calibre library gets here.
	#
	# Syncthing shares the library from the Framework, so the board reads
	# `metadata.db` and the epubs straight off local disk — no OPDS, no basic
	# auth, no XML parsing, and it keeps working while the laptop is asleep.
	#
	# Reachable on the tailnet only: no ports are opened publicly, and both
	# discovery and relaying are off, so it never talks to Syncthing's public
	# infrastructure. Pair the Framework by device ID through the GUI over
	# Tailscale.
	services.syncthing = {
		enable = true;
		# Runs as the app's own user so the board can read what arrives
		# without a group-permission dance.
		user = "megaapp";
		group = "megaapp";
		dataDir = "/var/lib/megaapp/corpus";
		configDir = "/var/lib/megaapp/syncthing";
		# The firewall trusts tailscale0 entirely and opens nothing else, so
		# binding everywhere still means tailnet-only in practice.
		guiAddress = "0.0.0.0:8384";
		openDefaultPorts = false;
		overrideDevices = false;
		overrideFolders = false;
		settings = {
			options = {
				# Nothing about this library should reach Syncthing's public
				# discovery or relay servers; the tailnet is the whole network.
				globalAnnounceEnabled = false;
				relaysEnabled = false;
				localAnnounceEnabled = false;
				natEnabled = false;
				urAccepted = -1;
			};
		};
	};

	systemd.tmpfiles.rules = [
		"d /var/lib/megaapp/corpus 0750 megaapp megaapp -"
	];

	security.acme = {
		acceptTerms = true;
		defaults.email = "arcadewise@hackclub.com";
	};

	system.stateVersion = "26.05";
}
