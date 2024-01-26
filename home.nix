{config,pkgs, ... }:
{
  home.username = "ilyas";
  home.homeDirectory = "/home/ilyas";
    

  # link the configuration file in current directory to the specified location in home directory
  # home.file.".config/i3/wallpaper.jpg".source = ./wallpaper.jpg;

  # link all files in `./scripts` to `~/.config/i3/scripts`
  # home.file.".config/i3/scripts" = {
  #   source = ./scripts;
  #   recursive = true;   # link recursively
  #   executable = true;  # make all files executable
  # };

  # encode the file content in nix configuration file directly
  # home.file.".xxx".text = ''
  #     xxx
  # '';

   # Gnome HiDpi/Fractional Scaling
  dconf.settings = {
    "org/gnome/mutter" = {
      experimental-features = [ "scale-monitor-framebuffer" ];
    };
  };

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    # here is some command line tools I use frequently
    # feel free to add your own or remove some of them
    alacritty
    ripgrep
    fd
    coreutils
    clang
    pciutils

    neofetch
    gh
    curl

    # Gnome stuff
    gnome-extension-manager
      # archives
    zip
    xz
    unzip
    p7zip

    # utils
    ripgrep # recursively searches directories for a regex pattern
    jq # A lightweight and flexible command-line JSON processor
    yq-go # yaml processer https://github.com/mikefarah/yq
    eza # A modern replacement for ‘ls’
    fzf # A command-line fuzzy finder

    # networking tools
    mtr # A network diagnostic tool
    iperf3
    dnsutils # `dig` + `nslookup`
    ldns # replacement of `dig`, it provide the command `drill`
    aria2 # A lightweight multi-protocol & multi-source command-line download utility
    socat # replacement of openbsd-netcat
    nmap # A utility for network discovery and security auditing
    ipcalc # it is a calculator for the IPv4/v6 addresses

    # nix related
    #
    # it provides the command `nom` works just like `nix`
    # with more details log output
    nix-output-monitor

    # productivity
    hugo # static site generator
    glow # markdown previewer in terminal
    btop # replacement of htop/nmon
    iotop # io monitoring
    iftop # network monitoring

    # system call monitoring
    strace # system call monitoring
    ltrace # library call monitoring
    lsof # list open files

    # system tools
    sysstat
    lm_sensors # for `sensors` command
    ethtool
  
    usbutils # lsusb

    # browsers
    firefox
    librewolf

    # documents
    evince
    zotero
    libreoffice
    logseq

    # social
    discord
    thunderbird
    # programming tools
    vscodium
    oh-my-posh
    helix
    racket
    python3
    distrobox
    python311Packages.pip
    wget
    lazygit
    zoxide
    #shells
    powershell
    #terminals
    tmux
    # images/video
    pinta
    gimp-with-plugins
    inkscape
    mpv
    jellyfin-media-player
    yt-dlp
    qbittorrent
    # file managers
    nnn
    #misc
    hfsprogs
    lshw
    xsct
    maiko
    tldr
    spotify
    nvtop-nvidia
    shortwave
    fluent-reader
    audacity
    simh
    cowsay
    file
    which
    tree
    gnused
    gnutar
    gawk
    zstd
    gnupg
    dippi
  ];

  # basic configuration of git, please change to your own
  programs.git = {
    enable = true;
    userName = "bochy992";
    userEmail = "garare992@proton.me";
  };

  programs.emacs = {
    enable = true;
    package = pkgs.emacs29-pgtk;
  };


  # alacritty - a cross-platform, GPU-accelerated terminal emulator
  programs.alacritty = {
    enable = true;
    # custom settings
    settings = {
      scrolling.multiplier = 5;
      selection.save_to_clipboard = true;
    };
  };

  programs.bash = {
    enable = true;
    enableCompletion = true;
    # TODO add your cusotm bashrc here
    # bashrcExtra = ''
    # '';

    # set some aliases, feel free to add more or remove some
    shellAliases = {
      switch = "cd /etc/nixos; sudo nixos-rebuild switch";
      boot = "cd /etc/nixos/; sudo nixos-rebuild boot";
      # flake version of above two commands
      switchflake="cd /etc/nixos; sudo nixos-rebuild switch --flake .#anvil";
      bootflake="cd /etc/nixos/; sudo nixos-rebuild boot --flake .#anvil";
      ls = "eza -all";
      bashrc = "sudo hx ~/.bashrc";
      zshrc = "sudo hx ~/.zshrc";
      confnix = "sudo hx /etc/nixos/configuration.nix";
      flakenix = "sudo hx /etc/nixos/flake.nix";
      homenix = "sudo hx /etc/nixos/home.nix";
    };
  };

  # This value determines the home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "23.11";

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;
}
