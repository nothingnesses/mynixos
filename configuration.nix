# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  inputs,
  lib,
  pkgs,
  pkgs-unstable,
  local,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Bootloader.
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    supportedFilesystems = [ "ntfs" ];
  };

  hardware = {
    bluetooth = {
      enable = true;
    };
    fw-fanctrl = {
      enable = true;
      config = {
        defaultStrategy = "b";
        strategies = {
          "a" = {
            fanSpeedUpdateFrequency = 5;
            movingAverageInterval = 20;
            speedCurve = [
              { temp = 30; speed = 10; }
              { temp = 40; speed = 20; }
              { temp = 45; speed = 70; }
              { temp = 50; speed = 80; }
              { temp = 55; speed = 90; }
              { temp = 60; speed = 100; }
            ];
          };
          "b" = {
            fanSpeedUpdateFrequency = 5;
            movingAverageInterval = 20;
            speedCurve = [
              { temp = 65; speed = 20; }
              { temp = 75; speed = 70; }
              { temp = 85; speed = 100; }
            ];
          };
        };
      };
    };
  };

  powerManagement.enable = true;

  # systemd.services.rustdesk = {
  #   description = "RustDesk client service";
  #   wantedBy = [ "multi-user.target" ];
  #   wants = [ "network-online.target" ];
  #   after = [ "network-online.target" "display-manager.service" ];

  #   path = [
  #     pkgs.sudo
  #     pkgs.coreutils
  #     pkgs.findutils
  #     pkgs.gnugrep
  #     pkgs.gnused
  #     pkgs.systemd
  #   ];

  #   serviceConfig = {
  #     Type = "simple";
  #     ExecStart = "${pkgs-unstable.rustdesk-flutter}/bin/rustdesk --service";
  #     Restart = "on-failure";
  #     RestartSec = "5s";
  #   };
  # };

  # networking.networkmanager.wifi.backend = "iwd";
  # networking.wireless.iwd.enable = true;

  networking = {
    firewall = {
      enable = false;
      allowPing = true;
    };
    hostName = "framework-16";
    nftables = {
      enable = true;
    };

    # Configure network proxy if necessary
    # proxy.default = "http://user:password@proxy:port/";
    # proxy.noProxy = "127.0.0.1,localhost,internal.domain";

    networkmanager = {
      enable = true;
    };
    interfaces.wlp1s0.ipv4.routes = [
      {
        # Host route for the server
        address      = local.lanServerIp;
        prefixLength = 32;
        # no "via" because it’s same subnet
        options      = {
          scope = "link";  # ensure link scope
        };
      }
    ];
  };

  # Set your time zone.
  time.timeZone = "Europe/London";

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_GB.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_GB.UTF-8";
      LC_IDENTIFICATION = "en_GB.UTF-8";
      LC_MEASUREMENT = "en_GB.UTF-8";
      LC_MONETARY = "en_GB.UTF-8";
      LC_NAME = "en_GB.UTF-8";
      LC_NUMERIC = "en_GB.UTF-8";
      LC_PAPER = "en_GB.UTF-8";
      LC_TELEPHONE = "en_GB.UTF-8";
      LC_TIME = "en_GB.UTF-8";
    };
  };

  services = {

    displayManager = {
      sddm = {
        enable = true;
        wayland.enable = true;
      };
    };

    desktopManager.plasma6.enable = true;

    # Enable the X11 windowing system.
    # You can disable this if you're only using the Wayland session.
    xserver = {
      enable = true;
      # Configure keymap in X11
      xkb = {
        layout = "gb";
        variant = "";
      };
    };

    # Enable CUPS to print documents.
    printing.enable = true;

    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
      # If you want to use JACK applications, uncomment this
      #jack.enable = true;

      # use the example session manager (no others are packaged yet so this is enabled by default,
      # no need to redefine it in your config for now)
      #media-session.enable = true;
    };

    rustdesk-server = {
      enable = true;
      openFirewall = true;
      signal = {
        enable = true;
        relayHosts = [ local.rustdeskRelay ];
        # extraArgs = [
        # ];
      };
      relay = {
        enable = true;
      };
    };

    ddns-updater = {
      enable = true;
      environment = {
        SERVER_ENABLED="no";
        CONFIG_FILEPATH = "/etc/ddns-updater/config.json";
        PERIOD = "5m";
      };
    };

    avahi = {
      enable = true;
      publish = {
        enable = true;
        userServices = true;
      };
    };

    samba = {
      enable = true;
      securityType = "user";
      openFirewall = true;
      settings = {
        global = {
          "workgroup" = "WORKGROUP";
          "server string" = "smbnix";
          "netbios name" = "smbnix";
          "security" = "user";
          #"use sendfile" = "yes";
          #"max protocol" = "smb2";
          # note: localhost is the ipv6 localhost ::1
          "hosts allow" = "${local.lanSubnet} 127.0.0.1 localhost";
          "hosts deny" = "0.0.0.0/0";
          "guest account" = "nobody";
          "map to guest" = "bad user";
          "allow insecure wide links" = "yes";
        };
        # "public" = {
        #   "path" = "/mnt/Shares/Public";
        #   "browseable" = "yes";
        #   "read only" = "no";
        #   "guest ok" = "yes";
        #   "create mask" = "0644";
        #   "directory mask" = "0755";
        #   "force user" = "username";
        #   "force group" = "groupname";
        # };
        "private" = {
          "path" = "/home/jessea/shared";
          "browseable" = "yes";
          "read only" = "no";
          "guest ok" = "no";
          "valid users" = "jessea";
          "follow symlinks" = "yes";
          "wide links" = "yes";
          "create mask" = "0644";
          "directory mask" = "0755";
          "force user" = "jessea";
          "force group" = "users";
        };
      };
    };

    samba-wsdd = {
      enable = true;
      openFirewall = true;
    };

    openssh = {
      enable = true;
      openFirewall = true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PubkeyAuthentication = true;
        PermitRootLogin = "no";
        X11Forwarding = false;
        AllowUsers = [ "jessea" ];
        PerSourcePenalties = "crash:3600s authfail:3600s max:86400s";
      };

      # Optional: only accept keys declared in NixOS config, not ~/.ssh/authorized_keys.
      authorizedKeysInHomedir = false;
    };
  };

  # Configure console keymap
  console.keyMap = "uk";

  # Enable sound with pipewire.
  security.rtkit.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  users = {
    extraGroups = {
      vboxusers = {
        members = [
          "jessea"
        ];
      };
    };

    # Define a user account. Don't forget to set a password with ‘passwd’.
    users = {
      jessea = {
        openssh.authorizedKeys.keys = local.sshAuthorizedKeys;
        isNormalUser = true;
        description = local.fullName;
        extraGroups = [
          "networkmanager"
          "wheel"
          "libvirtd"
          "podman"
        ];
        packages = [ ];
        shell = pkgs.nushell;
        subUidRanges = [{ startUid = 100000; count = 65536; }];
        subGidRanges = [{ startGid = 100000; count = 65536; }];
      };
      root = {
        shell = pkgs.bashInteractive;
      };
    };
    groups.libvirtd.members = [ "jessea" ];
  };

  programs = {
    virt-manager.enable = true;

    obs-studio = {
      enable = true;

      plugins = with pkgs.obs-studio-plugins; [
        wlrobs
        obs-composite-blur
        obs-backgroundremoval
        obs-pipewire-audio-capture
        obs-vaapi #optional AMD hardware acceleration
        obs-gstreamer
        obs-vkcapture
        obs-localvocal-vulkan
      ];

      enableVirtualCamera = true;
    };

    steam = {
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
      localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
    };

    # appimage-run command + run ./Foo.AppImage directly (binfmt).
    appimage = {
      enable = true;
      binfmt = true;
    };

    # Stub dynamic linker so generic Linux ELF binaries run.
    # Also the prerequisite for nix-alien.
    nix-ld = {
      enable = true;
      # Common libs many prebuilt binaries expect at runtime.
      # Add more here as nix-alien/ldd reports them missing.
      libraries = with pkgs; [
        stdenv.cc.cc
        zlib
        openssl
        glib
        gtk3
        webkitgtk_4_1   # Tauri apps like Pluely need this
        libsoup_3
      ];
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Register the obs-localvocal plugin under pkgs.obs-studio-plugins.*
  nixpkgs.overlays = [ inputs.obs-localvocal.overlays.default ];

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "steam"
    "steam-original"
    "steam-unwrapped"
    "steam-run"
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = [
    # ragenix/agenix CLI for creating and editing age-encrypted secrets
    inputs.ragenix.packages.${pkgs.system}.default
    pkgs.cryptsetup
    pkgs.ddrescue
    pkgs.fuc
    pkgs.kdePackages.knotifications
    pkgs.kdePackages.karousel
    pkgs.lsof
    pkgs.nixfmt-rfc-style
    pkgs.fw-ectool
    pkgs.gparted

    # podman
    pkgs.dive # look into docker image layers
    pkgs.podman-tui # status of containers in the terminal
    # podman-compose is a drop-in replacement for docker-compose
    # pkgs.docker-compose # start group of containers for dev
    pkgs.podman-compose # start group of containers for dev

    pkgs.kdePackages.flatpak-kcm

    pkgs.wayvr
    pkgs.android-tools
  ];

  environment.shells = [
    pkgs.nushell
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

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

  system = {
    autoUpgrade = {
      enable = true;
      flake = "/etc/nixos/flake.nix";
      flags = [
        "--print-build-logs"
        "--commit-lock-file"
      ];
      dates = "02:00";
      randomizedDelaySec = "45min";
      allowReboot = false;
    };
  };

  fonts = {
    packages = [
      pkgs.jetbrains-mono
      pkgs.nerd-fonts.jetbrains-mono
      pkgs.libertinus
    ];
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nix = {
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 30d";
    };
    settings = {
      auto-optimise-store = true;
    };
  };

  virtualisation = {
    containers = {
      enable = true;
    };
    libvirtd = {
      enable = true;
      allowedBridges = [ "virbr0" ];
      qemu = {
        swtpm = {
          enable = true;
        };
        vhostUserPackages = [ pkgs.virtiofsd ];
      };
    };
    podman = {
      enable = true;
      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;
      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
    };
    spiceUSBRedirection.enable = true;
  };
}
