# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{ config, lib, pkgs, ... }: {
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    kernelPackages = pkgs.linuxPackages_zen;
    # extraModulePackages = [ 
    #   config.boot.kernelPackages.nvidia_x11];
    # kernelParams = [
    # "acpi_rev_override"
    # ];
  };
  # Enable the X11 windowing system.
  services.xserver.enable = true;
  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.udev.packages = with pkgs; [ gnome.gnome-settings-daemon ];
  nixpkgs.overlays = [
  (final: prev: {
    gnome = prev.gnome.overrideScope' (gnomeFinal: gnomePrev: {
      mutter = gnomePrev.mutter.overrideAttrs ( old: {
        src = pkgs.fetchgit {
          url = "https://gitlab.gnome.org/vanvugt/mutter.git";
          # GNOME 45: triple-buffering-v4-45
          rev = "0b896518b2028d9c4d6ea44806d093fd33793689";
          sha256 = "sha256-mzNy5GPlB2qkI2KEAErJQzO//uo8yO0kPQUwvGDwR4w=";
        };
      } );
    });
  })
];

  # nixpkgs.config.allowAliases = false;
  programs.dconf.enable = true;
  # Nvidia Stuff
  services.thermald.enable = lib.mkDefault true;
  # services.xserver.videoDrivers = ["nvidia"];
  # hardware.nvidia.prime.offload.enable = false;
  # hardware.nvidia.prime.sync.enable = true;
  # hardware.nvidia.powerManagement.enable = false;
  # hardware.nvidia.powerManagement.finegrained = false;
  # hardware.nvidia.prime.nvidiaBusId = "PCI:1:0:0";
  # hardware.nvidia.nvidiaSettings = true;
  # hardware.nvidia.modesetting.enable = true;
  # hardware.nvidia.prime.enableOffloadCmd = lib.mkIf config.hardware.nvidia.prime.offload.enable true;
  # hardware.nvidia.prime.enable = lib.mkOverride 990 true;
  # hardware.nvidia.prime.intelBusId = "PCI:0:2:0";



  # hardware.opengl = {
  #   enable = true;
  #   driSupport = true;
  #   driSupport32Bit = true;
  # };

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


  # sound.enable = true;
  #   enable = true;
  #   daemon.config = {
      # default-sample-format = "float32le";
      # default-sample-rate = 48000;
      # alternate-sample-rate = 44100;
      # default-sample-channels = 2;
      # default-channel-map = "front-left,front-right";
      # default-fragments = 2;
      # default-fragment-size-msec = 125;
      # resample-method = "soxr-vhq";
      # avoid-resampling = "yes";
      # remixing-produce-lfe = "no";
      # remixing-consume-lfe = "no";
      # high-priority = "yes";
      # nice-level = -11;
      # realtime-scheduling = "yes";
      # realtime-priority = 9;
      # rlimit-rtprio = 9;
      # daemonize = "no";
  #   };
  # };

# Disable PulseAudio
hardware.pulseaudio.enable = lib.mkForce false;
sound.enable = lib.mkForce false;
# Enable Pipewire
security.rtkit.enable = true;
services.pipewire = {
  enable = true;
  alsa.enable = true;
  alsa.support32Bit = true;
  pulse.enable = true;
  # If you want to use JACK applications, uncomment this
  #jack.enable = true;
};


  environment.systemPackages = with pkgs; [
    dislocker
    gnomeExtensions.appindicator
    nvidia-vaapi-driver
    nvidia-system-monitor-qt
  ];
  

  qt = {
  enable = true;
  platformTheme = "gnome";
  style = "adwaita-dark";
};



  system.stateVersion = "23.11"; # Did you read the comment?
}

