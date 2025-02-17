# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  nix.settings = {
    auto-optimise-store = true;
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./modules/yubikey.nix
  ];

  nixpkgs.config = {
    allowUnfree = true;
    packageOverrides = pkgs: {
      xsaneGimp = pkgs.xsane.override { gimpSupport = true; };
      unstable = import <nixos-unstable> {
        config = config.nixpkgs.config;
      };
    };
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # boot.kernelPackages = pkgs.linuxPackages_5_15;
  boot.extraModulePackages = with config.boot.kernelPackages; [
    rr-zen_workaround
  ];
  boot.kernelModules = [
    "zen_workaround"
  ];
  boot.supportedFilesystems = [
    "ntfs"
    "jfs"
  ];
  boot.initrd.kernelModules = [ "amdgpu" ];

  hardware.tuxedo-drivers.enable = true;
  boot.kernelParams = [
    "xhci_hcd.quirks=1073741824"
  ];

  # RR the perf!
  boot.kernel.sysctl = {
    "kernel.perf_event_paranoid" = 1;
  };

  services.logind.extraConfig = ''
    HandleLidSwitch=ignore
  '';

  networking.hostName = "kurosaki"; # Define your hostname.
  networking.wireless.enable = false;
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Warsaw";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.eno1.useDHCP = true;
  networking.interfaces.wlp1s0.useDHCP = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  # };

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    videoDrivers = [ "amdgpu" ];
    deviceSection = ''
      Option "TearFree" "true"
    '';
  };

  # Enable the GNOME Desktop Environment.
  # services.xserver.displayManager.gdm.enable = true;
  # services.xserver.desktopManager.gnome.enable = true;

  # Enable i3wm with xfce
  services.xserver.windowManager.i3.enable = true;
  services.xserver.desktopManager = {
    xterm.enable = false;
    xfce = {
      enable = true;
      noDesktop = true;
      enableXfwm = false;
    };
  };

  # Configure keymap in X11
  services.xserver.xkb.layout = "us,us";
  services.xserver.xkb.variant = "colemak,";
  services.xserver.xkb.options = "grp:win_space_toggle,caps:escape";
  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.avahi = {
    enable = true;
    nssmdns4 = true;
  };

  # Enable sound
  # nixpkgs.config.pulseaudio = true;
  # hardware.pulseaudio = {
  #   enable = true;
  #   # extraModules = [ pkgs.pulseaudio-modules-bt ];
  #   package = pkgs.pulseaudioFull;
  # };
  hardware.bluetooth = {
    enable = true;
    settings = {
      Policy = {
        AutoEnable = true;
      };
      General = {
        Enable = "Source,Sink,Media,Socket";
      };
    };
  };
  services.blueman.enable = true;

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    pulse.enable = true;
  };

  # AMD Graphics
  hardware.graphics.extraPackages = [
    pkgs.amdvlk
  ];

  # Enable scanners
  hardware.sane = {
    enable = true;
    extraBackends = [ pkgs.sane-airscan ];
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput = {
  services.libinput = {
    enable = true;
    touchpad = {
      naturalScrolling = true;
    };
  };

  programs.fish.enable = true;

  users.defaultUserShell = pkgs.fish;
  users.mutableUsers = false;
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.kubkon = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "scanner"
      "lp"
      "libvirtd"
    ];
    hashedPassword = "deadbeef";
    openssh.authorizedKeys.keys = [ "deadbeef" ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  # nixpkgs.config.allowUnfree = true;
  # nixpkgs.config.packageOverrides = pkgs: {
  # xsaneGimp = pkgs.xsane.override { gimpSupport = true; };
  # };
  environment.localBinInPath = true;
  environment.systemPackages = with pkgs; [
    postman
    man-pages
    man-pages-posix
    vim
    wget
    thunderbird
    firefox
    ripgrep
    fzf
    libreoffice
    gimp
    signal-desktop
    fish
    starship
    kitty
    i3lock
    lxappearance
    autorandr
    htop
    obs-studio
    unstable.discord
    file
    chromium
    vlc
    skypeforlinux
    wineWowPackages.stable
    slack
    flameshot
    xss-lock
    signal-desktop
    fd
    lua
    libimobiledevice
    ifuse
    vscode
    xsaneGimp
    wireshark
    virt-manager
    qemu_full
    python3
    irssi
  ];
  environment.variables.EDITOR = "vim";

  virtualisation = {
    spiceUSBRedirection.enable = true;
    libvirtd.enable = true;
    docker.rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };

  programs.dconf.enable = true;

  environment.stub-ld.enable = false;

  fonts.packages = with pkgs; [
    nerdfonts
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  #programs.gnupg.agent = {
  #  enable = true;
  #  enableSSHSupport = true;
  #};

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  # Enable iPhone tethering
  services.usbmuxd.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?

  documentation.dev.enable = true;
}
