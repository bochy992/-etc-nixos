# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{ config, lib, pkgs, ... }:

let
    nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only
    exec -a "$0" "$@"
  '';
in
{

  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    kernelPackages = pkgs.linuxPackages_zen;
  };

  programs.zsh = {
    enable = true;
    # autocd = true;
    autosuggestions.enable = true;
    enableCompletion = true;
    shellAliases = {
      # sl = "exa";
      # ls = "exa";
      # l = "exa -l";
      # la = "exa -la";
      # ip = "ip --color=auto";
      switch = "cd /etc/nixos; sudo nixos-rebuild switch";
      boot = "cd /etc/nixos/; sudo nixos-rebuild boot";
      # flake version of above two commands
      switchflake="cd /etc/nixos; sudo nixos-rebuild switch --flake .#anvil";
      bootflake="cd /etc/nixos/; sudo nixos-rebuild boot --flake .#anvil";
      ls = "eza -all";
      confnix = "sudo hx /etc/nixos/configuration.nix";
      flakenix = "sudo hx /etc/nixos/flake.nix";
      homenix = "sudo hx /etc/nixos/home.nix";
    };
  };


  

  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

security.polkit.enable = true;
  # Enable OpenGL
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

#   # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = ["nvidia" "intel"];

  hardware.nvidia = {

    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    powerManagement.enable = false;
    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of 
    # supported GPUs is at: 
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
    # Only available from driver 515.43.04+
    # Currently alpha-quality/buggy, so false is currently the recommended setting.
    open = false;

    # Enable the Nvidia settings menu,
	# accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.latest;
    forceFullCompositionPipeline = true;
  };

  	hardware.nvidia.prime = {
		offload = {
			enable = true;
			enableOffloadCmd = true;
		};
		# Make sure to use the correct Bus ID values for your system!
		intelBusId = "PCI:0:2:0";
		nvidiaBusId = "PCI:1:0:0";
	};

  boot.kernel.sysctl = { "vm.swappiness" = 1; };
  virtualisation.podman.enable = true;


  

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


  # allow unfree and insecure packages
  nixpkgs.config.permittedInsecurePackages = [ "electron-19.1.9" ];
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.nvidia.acceptLicense = true;


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
        default-sample-rate = 192000;
        alternate-sample-rate = 48000;
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

nixpkgs.config.allowAliases = false;
  


  # Emacs
services.emacs = {
enable = true;
defaultEditor = true;
package = pkgs.emacs29-pgtk;
};
  


# apps/packages to install system-wide
  environment.systemPackages = with pkgs; [
    dislocker
    emacsPackages.vterm
    #(pkgs.emacs.override {withGTK3 = false; nativeComp = true;})
    emacsPackages.adwaita-dark-theme
    avizo
    read-edid
    nvidia-offload
    wayland-utils
    clinfo
    gpu-viewer
    glxinfo
    vulkan-tools
    shellcheck
    neovim
    gImageReader
    pandoc
    nil
    nixpkgs-fmt
    gnomeExtensions.appindicator
    gnome.adwaita-icon-theme
    nvidia-system-monitor-qt
    unetbootin
    nvidia-vaapi-driver
    GnomeExtensions.pop-shell
    mission-center
  ];

  services.udev.packages = with pkgs; [ gnome.gnome-settings-daemon ];
  services.dbus.packages = with pkgs; [ gnome2.GConf ];



environment.gnome.excludePackages = (with pkgs; [
  gnome-photos
  gnome-tour
]) ++ (with pkgs.gnome; [
  cheese # webcam tool
  gnome-music
  gnome-terminal
  epiphany # web browser
  geary # email reader
  evince # document viewer
  gnome-characters
  totem # video player
  tali # poker game
  iagno # go game
  hitori # sudoku game
  atomix # puzzle game
]);

qt = {
  enable = true;
  platformTheme = "gnome";
  style = "adwaita-dark";
};

   virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ "user-with-access-to-virtualbox" ];
   virtualisation.virtualbox.host.enableExtensionPack = true;
     virtualisation.virtualbox.guest.enable = true;
  virtualisation.virtualbox.guest.x11 = true;


  system.stateVersion = "23.11"; # Did you read the comment?
}

