# Framework Desktop (Ryzen AI Max). Shared desktop bits live in
# ../../modules/common.nix.
{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/common.nix
  ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelParams = [
      "ttm.pages_limit=12582912"
      "amdgpu.gttsize=49152"
    ];
    kernelPackages = pkgs.linuxPackages_latest;
  };

  networking.hostName = "framework";

  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  services.printing.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-wlr
      xdg-desktop-portal-gtk
    ];
  };

  environment.systemPackages = with pkgs; [
    gnomeExtensions.dash-to-dock
    gnomeExtensions.blur-my-shell
    gnomeExtensions.caffeine

    vulkan-tools
    (llama-cpp.override { vulkanSupport = true; })
  ];

  # services = {
  #   ollama = {
  #     enable = true;
  #     package = pkgs.ollama-rocm;
  #     rocmOverrideGfx = "11.5.1";
  #     environmentVariables = {
  #       OLLAMA_FLASH_ATTENTION = "1";
  #       OLLAMA_KEEP_ALIVE = "-1";
  #     };
  #   };
  #   open-webui = {
  #     enable = true;
  #     port = 8091;
  #   };
  # };

  system.stateVersion = "26.05"; # Did you read the comment?
}
