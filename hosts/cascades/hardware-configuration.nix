# PLACEHOLDER so the flake evaluates before install. On the mac, after
# partitioning and mounting, replace this file with the output of
#   nixos-generate-config --root /mnt --show-hardware-config
{ lib, ... }:
{
	boot.initrd.availableKernelModules = [ "usb_storage" "sdhci_pci" ];

	fileSystems."/" = {
		device = "/dev/disk/by-label/nixos";
		fsType = "ext4";
	};

	fileSystems."/boot" = {
		device = "/dev/disk/by-label/EFI";
		fsType = "vfat";
		options = [ "fmask=0022" "dmask=0022" ];
	};

	nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
}
