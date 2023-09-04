# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  # boot.loader.grub.efiSupport = true;
  # boot.loader.grub.efiInstallAsRemovable = true;
  # boot.loader.efi.efiSysMountPoint = "/boot/efi";
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only

  networking.hostName = "nixos"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "America/Sao_Paulo";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
   console = {
     font = "Lat2-Terminus16";
     # keyMap = "us";
     useXkbConfig = true; # use xkbOptions in tty.
   };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  nixpkgs.config.allowUnfree = true;
  

  # Configure keymap in X11
  # services.xserver.layout = "br";
  # services.xserver.xkbOptions = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # sound.enable = true;
  # hardware.pulseaudio.enable = true;
  security.rtkit.enable = true; 
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver = {
        enable = true;
        libinput.enable = true;
        layout = "br";
        windowManager.awesome = {
              enable = true;
              luaModules = with pkgs.luaPackages; [
                      luarocks
                      # luadbi-mysql
              ];
        };
        displayManager.startx.enable = true;
        videoDrivers = [ "intel" ];
        
  };
  programs.java = {
     enable = true;
     package = pkgs.jdk11;
  };

   # NOT NEEDED!! THEY FINALLY FIXED IT!!!

   #hardware.opengl.package = (pkgs.mesa.override {
   #    galliumDrivers = [ "i915" "swrast" "r600" ];
   #    vulkanDrivers = [ "intel" "swrast" ];
   #    eglPlatforms = [ "x11" ];
   #    enableGalliumNine = true;
   # }).drivers;

   hardware.opengl = {
     enable = true;
     extraPackages = with pkgs; [
       vaapiIntel
       vaapiVdpau
       libvdpau-va-gl
     ];
   };

   #Attempt of building linux-tkg-bmq, take so long to build.

   # boot.kernelPackages = let
   # linux_tkg_bmq_pkg = { fetchurl, buildLinux, ... } @ args:
  
   #  buildLinux (args // rec {
   #    version = "6.4.10-tkg-bmq";
   #    modDirVersion = "6.4.10-tkg-bmq";
  
   #    src = fetchurl {
   #      url = "https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.4.10.tar.xz";
   #      sha256 = "980b3fb2a97788fd885cbd85ba4520980f76c7ae1d62bfc2e7477ee04df5f239";
   #    };
   #    kernelPatches = [
   #      { name = "prjc.patch"; patch = ./patches/prjc.patch; }
   #      { name = "glitched-base.patch"; patch = ./patches/glitched-base.patch; }
   #      { name = "glitched-bmq.patch"; patch = ./patches/glitched-bmq.patch; }
   #      { name = "clear-patches.patch"; patch = ./patches/clear-patches.patch; }
   #      { name = "misc-additions.patch"; patch = ./patches/misc-additions.patch; }
   #    ];
  
   #    extraConfig = ''
   #      SCHED_ALT y
   #      SCHED_BMQ y
   #      HZ_500 y
   #      MLX5_CORE n
   #      DRM_RADEON n
   #      DRM_AMDGPU n
   #      DRM_NOUVEAU n
   #      DRM_i915 m
   #      ZENIFY y
   #      LOCALVERSION -tkg-bmq
   #    '';
  
   #    ignoreConfigErrors = true;
  
   #    extraMeta.branch = "6.4";
   #  } // (args.argsOverride or {}));
   #    linux_tkg_bmq = pkgs.callPackage linux_tkg_bmq_pkg{};
   #  in 
   #    pkgs.recurseIntoAttrs (pkgs.linuxPackagesFor linux_tkg_bmq);
  
   boot.kernelPackages = pkgs.linuxPackages_xanmod_latest;

  fonts.packages = with pkgs; [
        (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
        noto-fonts-emoji
        font-awesome
        dejavu_fonts
        source-code-pro

  ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
   users.users.duvas = {
     isNormalUser = true;
     extraGroups = [ "wheel" "audio" "video" ]; # Enable ‘sudo’ for the user.
     packages = with pkgs; [
       neofetch
       htop
       glxinfo
     ];
   };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
   environment.systemPackages = with pkgs; [
     vim 
     wget
     unzip
     git
     feh
     dmenu
     pavucontrol
     google-chrome
     rxvt-unicode
     streamlink-twitch-gui-bin
     mpv
     krabby
     ani-cli
     alsa-utils




     
     # Spotify with SpotX
     (pkgs.spotify.overrideAttrs (oldAttrs: rec {
       buildInputs = oldAttrs.buildInputs or [] ++ [ pkgs.unzip pkgs.perl pkgs.zip pkgs.util-linux];
       spotx = pkgs.fetchurl {
         url = "https://raw.githubusercontent.com/SpotX-CLI/SpotX-Linux/main/install.sh";
         sha256 = "4265771659ff121cc0a939f5661733d4d0e9ae10a55281459844c0eb8e3e9540";
       };
       
       postInstall = ''
         # SpotX install script
         bash $spotx -P $out/share/spotify
       '';
     }))
   ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}

