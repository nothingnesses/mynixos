{
  config,
  inputs,
  pkgs,
  pkgs-unstable,
  system,
  ...
}:

{
  home = {
    # Home Manager needs a bit of information about you and the
    # paths it should manage.
    homeDirectory = "/home/jessea";

    packages = [
      pkgs.dbeaver-bin
      pkgs.kalker
      # pkgs.lapce
      pkgs.livecaptions
      pkgs.nil
      pkgs.pik
      pkgs.vlc
      inputs.zen-browser.packages."${system}".default
      pkgs-unstable.azahar
      pkgs.pcsx2
      # pkgs-unstable.rpcs3
      pkgs.rpcs3
      pkgs-unstable.xemu
      pkgs-unstable.lutris
      pkgs.hoppscotch
      pkgs-unstable.eddie
      pkgs-unstable.yt-dlp
      pkgs.chromium
      pkgs.brightnessctl
      pkgs.libreoffice-qt
      pkgs.p7zip
      pkgs.unrar
      pkgs.discord
      # pkgs-unstable.heroic
      pkgs.jq
      pkgs-unstable.claude-code
      pkgs-unstable.rustdesk-flutter
      pkgs.tealdeer
      pkgs.diffsitter
      pkgs.gh
      pkgs.musescore
      pkgs.muse-sounds-manager
      pkgs.bubblewrap
      pkgs-unstable.codex
      pkgs.wivrn
      pkgs.teams-for-linux
      inputs.nix-alien.packages."${system}".nix-alien
      pkgs.ast-grep
   ];

    sessionPath = [
      "$HOME/.cargo/bin"
      "$HOME/.local/share/bin"
    ];

    sessionVariables = {
      EDITOR = "hx";
    };

    # shell = {
    #   enableNushellIntegration = true;
    # };

    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    stateVersion = "24.11";

    username = "jessea";
 };

  programs = {
    alacritty = {
      enable = true;
      # settings = {
      #   font = {
      #     normal = {
      #       family = "JetBrainsMono Nerd Font";
      #       style = "Regular";
      #     };
      #   };
      # };
    };

    bash = {
      enable = true;
    };

    bat = {
      enable = true;
    };

    broot = {
      enable = true;
      enableNushellIntegration = true;
    };

    direnv = {
      enable = true;
      enableNushellIntegration = true;
      enableBashIntegration = true;
      nix-direnv = {
        enable = true;
      };
    };

    git = {
      enable = true;
      userName = "nothingnesses";
      userEmail = "18732253+nothingnesses@users.noreply.github.com";
    };

    helix = {
      # defaultEditor = true;
      enable = true;
    };

    # Let Home Manager install and manage itself.
    home-manager.enable = true;

    # lapce = {
    #   enable = true;
    # };

    nushell = {
      enable = true;
      environmentVariables = config.home.sessionVariables;
      shellAliases = config.home.shellAliases;
      extraConfig = ''
        use std ["path add"]
        path add "~/.local/share/bin"
        path add "~/.cargo/bin"
        def --wrapped cpr [...args] {
          rsync -aAXUHS -hh --partial --info=stats1,progress2 --modify-window=1 ...$args
        }
        def --wrapped mvr [...args] {
          rsync -aAXUHS -hh --partial --info=stats1,progress2 --modify-window=1 --remove-source-files ...$args
        }
        def --wrapped git-core [...args] {
          git ...$args
        }
        def --wrapped git-status [...args] {
          git -c color.ui=always status ...$args | less -R
        }
        def --wrapped sudoedit-codium [...args] {
          EDITOR="codium --wait" sudoedit ...$args
        }
      '';
    };

    starship = {
      enable = true;
      enableNushellIntegration = true;
    };

    vscode = {
      enable = true;
      package = pkgs.vscodium.fhsWithPackages (p: [ p.rustup p.zlib p.openssl.dev p.pkg-config ]);
    };

    yazi = {
      enable = true;
      enableNushellIntegration = true;
    };

    zellij = {
      enable = true;
      # enableNushellIntegration = true;
    };

    zoxide = {
      enable = true;
      enableNushellIntegration = true;
    };
  };

  services = {
    kdeconnect = {
      enable = true;
    };
 };

  home.file.".vscode-oss".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/.vscode-oss";
  xdg = {
    configFile = {
      "alacritty".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/.config/alacritty";
      "autostart/rustdesk.desktop".source =
        "${pkgs-unstable.rustdesk-flutter}/share/applications/rustdesk.desktop";
      # "lapce-stable".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/.config/lapce-stable";
      # "niri".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/.config/niri";
      "helix".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/.config/helix";
      "starship.toml".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/.config/starship.toml";
      "VSCodium".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/.config/VSCodium";
      "yazi".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/.config/yazi";
    };
  };

  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = [ "qemu:///system" ];
      uris = [ "qemu:///system" ];
    };
  };
}
