# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{ config, lib, pkgs, ... }:

# let
#     nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
#     export __NV_PRIME_RENDER_OFFLOAD=1
#     export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
#     export __GLX_VENDOR_LIBRARY_NAME=nvidia
#     export __VK_LAYER_NV_optimus=NVIDIA_only
#     exec -a "$0" "$@"
#   '';
# in
{

  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    kernelPackages = pkgs.linuxPackages_zen;
  };

security.polkit.enable = true;
  hardware.opengl.enable = true; # when using QEMU KVM


  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "DroidSansMono" ]; })
    dejavu_fonts # mind the underscore! most of the packages are named with a hypen, not this one however
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
  ];

  # nixpkgs.config.allowAliases = false;
  programs.dconf.enable = true;
  # Nvidia Stuff
  services.thermald.enable = lib.mkDefault true;

  # Define a user account.
  users.users.ilyas = {
    isNormalUser = true;
    description = "ilyas";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  # enable the nix command and flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # # Wayland stuff
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  environment.sessionVariables.WLR_NO_HARDWARE_CURSORS = "1";

  # allow unfree and insecure packages
  nixpkgs.config.permittedInsecurePackages = [ "electron-19.1.9" ];
  nixpkgs.config.allowUnfree = true;
  # nixpkgs.config.nvidia.acceptLicense = true;

  # Default Shell
  users.defaultUserShell = pkgs.powershell;

  # Computer name
  networking.hostName = "anvil";

  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Chicago";

  # Select internationalisation properties.
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

  # Enable CUPS to print documents.
  services.printing.enable = true;


  # Enable sound with pulseaudio.
  sound.enable = true;
  environment.etc."asound.conf".text = lib.mkForce ''
# Use PulseAudio plugin hw
pcm.!default {
   type plug
   slave.pcm hw
}'';
  hardware = {
    bluetooth.enable = true;
    pulseaudio = {
      enable = true;
      daemon.config = {
        default-sample-format = "float32le";
        default-sample-rate = 48000;
        alternate-sample-rate = 44100;
        default-sample-channels = 2;
        default-channel-map = "front-left,front-right";
        default-fragments = 2;
        default-fragment-size-msec = 125;
        resample-method = "soxr-vhq";
        avoid-resampling = "yes";
        remixing-produce-lfe = "no";
        remixing-consume-lfe = "no";
        high-priority = "yes";
        nice-level = -11;
        realtime-scheduling = "yes";
        realtime-priority = 9;
        rlimit-rtprio = 9;
        daemonize = "no";
      };
    };
  };

  
# apps/packages to install system-wide
  environment.systemPackages = with pkgs; [
    dislocker
    emacsPackages.vterm
    #(pkgs.emacs.override {withGTK3 = false; nativeComp = true;})
    emacsPackages.adwaita-dark-theme
  ];


  # Emacs
services.emacs = {
enable = true;
defaultEditor = true;
package = pkgs.emacs29-pgtk;
};
  




  system.stateVersion = "23.11"; # Did you read the comment?
}

