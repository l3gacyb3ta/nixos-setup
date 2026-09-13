# Hetzner Cloud CX-class: one 38GB virtio disk, UEFI boot.
#
# Single disk, so /dev/sda is stable enough; by-id would pin this config to
# one particular VM's serial number and break if the machine is ever rebuilt.
{
	disko.devices.disk.main = {
		device = "/dev/sda";
		type = "disk";
		content = {
			type = "gpt";
			partitions = {
				# Hetzner's images boot UEFI, but a BIOS boot partition costs a
				# megabyte and keeps a rescue boot possible.
				boot = {
					size = "1M";
					type = "EF02";
				};
				ESP = {
					size = "512M";
					type = "EF00";
					content = {
						type = "filesystem";
						format = "vfat";
						mountpoint = "/boot";
						mountOptions = [ "umask=0077" ];
					};
				};
				root = {
					size = "100%";
					content = {
						type = "filesystem";
						format = "ext4";
						mountpoint = "/";
					};
				};
			};
		};
	};
}
