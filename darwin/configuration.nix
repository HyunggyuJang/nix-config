{ config, pkgs, lib, ... }:

let hgj_home = builtins.getEnv "HOME";
    hgj_sync = "${hgj_home}/Desktop";

    mach-nix = import <mach-nix> {
      inherit pkgs;
      python = "python38";
    };

    myPython = mach-nix.mkPython {
      requirements = ''
        readability-lxml
        octave-kernel
    '';
    };

    kittyDracula = with pkgs; stdenv.mkDerivation {
      name = "kitty-dracula-theme";
      src = fetchFromGitHub {
        owner = "dracula";
        repo = "kitty";
        rev = "6d6239a";
        sha256 = "1fyclzglw4jz0vrglwg6v644bhr7w7mb1d95lagy7iz14gybli0i";
      };
      installPhase = ''
        mkdir -p $out
        cp dracula.conf diff.conf $out/
      '';
    };

in with lib;
  {
    # Home manager
    imports = [ <home-manager/nix-darwin> ];

    home-manager.useGlobalPkgs = true;
    home-manager.users.hynggyujang =
      let
        doom-emacs = pkgs.callPackage (builtins.fetchTarball {
          url = https://github.com/vlaci/nix-doom-emacs/archive/master.tar.gz;
        }) {
          inherit pkgs;
          doomPrivateDir = environment.variables.DOOMDIR;
        };
      in rec {
        # home.packages = [ doom-emacs ];
        home.file = {
          # ".emacs.d/init.el".text = ''
          #     (load "default.el")
          # '';
          ".qutebrowser/config.py".text = ''
          config.load_autoconfig(True)
          # c.window.hide_decoration = True

          # c.colors.webpage.darkmode.enabled = True

          # c.qt.args = [ "disable-gpu" ]

          c.qt.environ = {"NODE_PATH": "/run/current-system/sw/lib/node_modules"}

          c.url.default_page = 'https://google.com'
          c.url.start_pages = c.url.default_page
          c.url.searchengines = {"DEFAULT": "https://google.com/search?q={}"}

          c.editor.command = ['emacsclient', '{}']

          c.statusbar.show = "never"
          c.tabs.show = "switching"

          c.bindings.commands['normal'] = {
              "<cmd-n>": "open -w",
              "<cmd-t>": "open -t",
              "<cmd-r>": "reload -f",
              "<cmd-shift-r>": "session-load -f _autosave",
              "<cmd-w>": "tab-close",
              "<cmd-shift-w>": "close",
              "x": "tab-close",
              "<shift-x>": "close",
              # Org roam capture
              "<Meta-Shift-L>": "open javascript:location.href='org-protocol://roam-ref?template=r&ref='+encodeURIComponent(location.href)+'&title='+encodeURIComponent(document.title)+'&body='+encodeURIComponent(window.getSelection())",
              # Plain old org capture
              "<Meta-p>": "open javascript:location.href='org-protocol://capture?template=p&url='+encodeURIComponent(location.href)+'&title='+encodeURIComponent(document.title)+'&body='+encodeURIComponent(window.getSelection())",
              # Plain old org capture at current point
              "<Meta-L>": "open javascript:location.href='org-protocol://capture?template=L&url='+encodeURIComponent(location.href)+'&title='+encodeURIComponent(document.title)+'&body='+encodeURIComponent(window.getSelection())"
              }

          # Doom emacs like key binding
          c.bindings.commands['insert'] = {
              # editing
              '<ctrl-f>': 'fake-key <Right>',
              '<ctrl-b>': 'fake-key <Left>',
              '<ctrl-a>': 'fake-key <cmd-left>',
              '<ctrl-e>': 'fake-key <cmd-right>',
              '<ctrl-n>': 'fake-key <Down>',
              '<ctrl-p>': 'fake-key <Up>',
              '<alt-f>': 'fake-key <Alt-Right>',
              '<alt-b>': 'fake-key <Alt-Left>',
              '<ctrl-d>': 'fake-key <Delete>',
              '<alt-d>': 'fake-key <Alt-Delete>',
              '<ctrl-u>': 'fake-key <cmd-shift-left> ;; fake-key <backspace>',
              '<ctrl-k>': 'fake-key <cmd-shift-right> ;; fake-key <backspace>',
              '<ctrl-w>': 'fake-key <alt-backspace>',
              '<ctrl-y>': 'insert-text',
              '<ctrl-shift-e>': 'edit-text'
          }

          c.bindings.commands['caret'] = {
              # Org roam capture
              "<Meta-Shift-L>": "open javascript:location.href='org-protocol://roam-ref?template=r&ref='+encodeURIComponent(location.href)+'&title='+encodeURIComponent(document.title)+'&body='+encodeURIComponent(window.getSelection())",
              # Plain old org capture
              "<Meta-p>": "open javascript:location.href='org-protocol://capture?template=p&url='+encodeURIComponent(location.href)+'&title='+encodeURIComponent(document.title)+'&body='+encodeURIComponent(window.getSelection())",
              # Plain old org capture at current point
              "<Meta-i>": "open javascript:location.href='org-protocol://capture?template=L&url='+encodeURIComponent(location.href)+'&title='+encodeURIComponent(document.title)+'&body='+encodeURIComponent(window.getSelection())"
          }

          c.bindings.commands['command'] = {
              '<ctrl-j>': 'completion-item-focus next',
              '<ctrl-k>': 'completion-item-focus prev',
              '<ctrl-d>': 'rl-delete-char'
          }

          c.bindings.commands['prompt'] = {
              '<ctrl-j>': 'prompt-item-focus next',
              '<ctrl-k>': 'prompt-item-focus prev'
          }

          # Universal Emacsien C-g alias for Escape
          config.bind('<Ctrl-g>', 'clear-keychain ;; search ;; fullscreen --leave')
          # Dark mode toggling
          config.bind('<cmd-d>', 'config-cycle colors.webpage.darkmode.enabled ;; restart ;; session-load -f _autosave')
          for mode in ['caret', 'command', 'hint', 'insert', 'passthrough', 'prompt', 'register']:
              config.bind('<Ctrl-g>', 'mode-leave', mode=mode)
              config.bind('<cmd-d>', 'config-cycle colors.webpage.darkmode.enabled ;; restart ;; session-load -f _autosave', mode=mode)


          config.unbind("<ctrl-q>")
          config.unbind("<ctrl-n>")
          config.unbind("<ctrl-t>")
          config.unbind("<ctrl-w>")
          config.unbind("<ctrl-shift-w>")
          # I use `x` instead `d`.
          config.unbind("d")

          config.bind(';;', 'hint inputs --first')  # easier to reach than ;t

          # Open in chrome
          config.bind(';g', 'hint links spawn open -na "Google Chrome" --args --app={hint-url}')

          c.aliases['readability-js'] = "spawn -u readability-js"
          c.aliases['readability'] = "spawn -u readability"
          c.aliases['chrome'] = "spawn open -na 'Google Chrome' --args --app={url}"
          c.aliases['removed'] = "open javascript:document.location=document.URL.replace('reddit.com','removeddit.com');"

          #Activate dracula theme
          import dracula.draw

          dracula.draw.blood(c, {
              'spacing': {
                  'vertical': 6,
                  'horizontal': 8
              }
          })
        '';
          ".qutebrowser/dracula".source = pkgs.fetchFromGitHub {
            owner = "dracula";
            repo = "qutebrowser";
            rev = "ba5bd6589c4bb8ab35aaaaf7111906732f9764ef";
            sha256 = "1mhckmyqc7ripzmz0d8466fq0njqhxkigzm3nz0yl05k0xlsbzka";
          };
          ".qutebrowser/userscripts/readability-js" = {
            source = pkgs.fetchurl {
              name = "readability-js";
              url = "https://raw.githubusercontent.com/qutebrowser/qutebrowser/master/misc/userscripts/readability-js";
              sha256 = "1plp2gnvk2qy6kkdhl05fd01n15nxfy2hllyd2lskp9z0g8gdldn";
            };
            executable = true;
          };
          ".qutebrowser/userscripts/readability" = {
            source = pkgs.fetchurl {
              name = "readability";
              url = "https://raw.githubusercontent.com/qutebrowser/qutebrowser/master/misc/userscripts/readability";
              sha256 = "029538gkymh756qd14j6947r6qdyzww6chnkd240vc8v0pif58lk";
            };
            executable = true;
          };
          ".bash_profile".text = ". /Users/hynggyujang/.nix-profile/etc/profile.d/nix.sh";
          ".gitconfig".text = ''
          [user]
            name = Hynggyu Jang
            email = murasakipurplez5@gmail.com
        '';
          ".mailcap".text = ''
          # HTML
          text/html; open %s; description=HTML Text; test=test -n "$DISPLAY";  nametemplate=%s.html
        '';
          ".mailrc".text = ''
          set sendmail="/usr/local/bin/msmtp"
        '';
          ".mbsyncrc".text = ''
          IMAPAccount nagoya
          Host mail.j.mbox.nagoya-u.ac.jp
          User jang.hyunggyu@j.mbox.nagoya-u.ac.jp #not XXX@me.com etc.
          UseKeychain Yes
          Port 993
          SSLType IMAPS
          SSLVersions TLSv1.2

          IMAPStore nagoya-remote
          Account nagoya

          MaildirStore nagoya-local
          Path ~/.mail/account.nagoya/
          Inbox ~/.mail/account.nagoya/Inbox
          SubFolders Verbatim

          Channel nagoya-folders
          Far :nagoya-remote:
          Near :nagoya-local:
          Patterns *
          Create Both
          Expunge Both
          SyncState *
          CopyArrivalDate Yes

          Group nagoya
          Channel nagoya-folders
        '';
          ".msmtprc".text = ''
          # Set default values for all following accounts.
          defaults
          auth           on
          tls            on
          # https://github.com/okovko/msmtp_gmail_setup/blob/master/msmtp_setup.sh
          tls_fingerprint 77:05:8C:8E:FC:3C:F0:5C:17:F1:21:75:02:27:33:30:D4:85:00:C2:09:63:4E:0A:56:AA:C1:54:45:FD:F6:37
          logfile        ~/.msmtp.log

          # Nagoya-U mail
          account        jang.hyunggyu@j.mbox.nagoya-u.ac.jp
          host           mail.j.mbox.nagoya-u.ac.jp
          port           587
          protocol       smtp
          from	       jang.hyunggyu@j.mbox.nagoya-u.ac.jp
          user           jang.hyunggyu@j.mbox.nagoya-u.ac.jp
          tls_starttls   on

          # Set a default account
          account default : jang.hyunggyu@j.mbox.nagoya-u.ac.jp
        '';
          ".notmuch-config".text = ''
          [database]
          path=/Users/hynggyujang/.mail
          [user]
          name=Hyunggyu Jang
          primary_email=murasakipurplez5@gmail.com
          other_email=jang.hyunggyu@j.mbox.nagoya-u.ac.jp
          [new]
          tags=new
          ignore=/.*[.](json|lock|bak)$/;.mbsyncstate;.uidvalidity;.DS_Store
          [search]
          exclude_tags=deleted;spam;
          [maildir]
          synchronize_flags=true
        '';
          ".SpaceVim.d".source = "${hgj_sync}/dotfiles/.SpaceVim.d";
        };
        home.sessionVariables = {
          FONTCONFIG_FILE    = "${xdg.configHome}/fontconfig/fonts.conf";
          FONTCONFIG_PATH    = "${xdg.configHome}/fontconfig";
        };
        programs = {
          # qutebrowser.enable = true;
          home-manager.enable = true;
          zsh = rec {
            enable = true;
            dotDir = ".config/zsh";
            enableCompletion = false;
            enableAutosuggestions = true;

            history = {
              size = 50000;
              save = 500000;
              path = "$HOME/${dotDir}/history";
              ignoreDups = true;
              share = true;
            };
          };
        };
        xdg = {
          enable = true;

          configHome = "${hgj_home}/.config";
          dataHome = "${hgj_home}/.local/share";
          cacheHome = "${hgj_home}/.cache";

          configFile."nvim".source = "${hgj_home}/.SpaceVim";

          configFile."afew/config".text = ''
          [MailMover]
          folders = account.nagoya/Inbox
          rename = True

          account.nagoya/Inbox = 'NOT tag:inbox AND tag:lab':'account.nagoya/Lab' 'NOT tag:inbox AND tag:school':'account.nagoya/School' 'NOT tag:inbox AND NOT tag:trash':'account.nagoya/Archive'

          [FolderNameFilter]
          folder_blacklist = account.nagoya account.gmail mail Archive
          folder_transforms = Drafts:draft Junk:spam
          folder_lowercases = true
          maildir_separator = /
        '';

          configFile."karabiner/karabiner.json".source = "${hgj_sync}/dotfiles/karabiner.json";
          configFile."kitty/dracula.conf".source = "${kittyDracula}/dracula.conf";
          configFile."kitty/diff.conf".source = "${kittyDracula}/diff.conf";
          configFile."kitty/kitty.conf".text = ''
          allow_remote_control yes

          hide_window_decorations yes

          font_family      Sarasa Mono K
          font_size        14.0

          macos_thicken_font 0.5

          macos_option_as_alt yes
          macos_hide_from_tasks yes
          macos_quit_when_last_window_closed yes

          include dracula.conf
        '';
          configFile."zathura/zathurarc".text = "set selection-clipboard clipboard";
          configFile."nixpkgs".source = "${hgj_sync}/dotfiles/nixpkgs";
          configFile."fontconfig/fonts.conf".text = ''
        <?xml version='1.0'?>
        <!-- Generated by Hyunggyu Jang. -->
        <!DOCTYPE fontconfig SYSTEM 'fonts.dtd'>
        <fontconfig>
          <dir>/Library/Fonts</dir>
          <dir>${hgj_home}/Library/Fonts</dir>
        </fontconfig>
      '';
        };
      };
    system.defaults.NSGlobalDomain = {
      ApplePressAndHoldEnabled = false;
      AppleKeyboardUIMode = 3;
      AppleShowScrollBars = "WhenScrolling";
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;
      NSUseAnimatedFocusRing = false;
      _HIHideMenuBar = true;
    };

    system.defaults.dock.orientation = "left";

    system.defaults.loginwindow.GuestEnabled = false;

    # For single user hack
    users.nix.configureBuildUsers = mkForce false;
    users.knownGroups = mkForce [];

    environment.darwinConfig = "${hgj_sync}/dotfiles/nixpkgs/darwin/configuration.nix";

    environment.systemPackages = with pkgs; [
      git
      ((emacsPackagesNgGen emacs).emacsWithPackages (epkgs: with epkgs; [
        vterm
      ]))
      afew
      notmuch
      msmtp
      # From doom
      (aspellWithDicts (dicts: with dicts; [ en en-computers en-science ]))
      jq
      fd
      djvulibre
      graphviz
      zstd
      coreutils-prefixed
      nodejs
      isync
      nixfmt
      skhd
      shellcheck
      ripgrep
      # desktop-file-utils
      # inkscape
      gmailieer
      findutils
      fontconfig
      kitty
      fzf
      bashInteractive
      nodePackages.node2nix
      # qutebrowser
      # for qutebrowser userscript packages
      nodePackages.qutejs
      nodePackages.jsdom
      nodePackages."@mozilla/readability"
      # readability packages
      mach-nix.mach-nix
      myPython
      proselint
      texlive.combined.scheme-medium
      imagemagick
      # For octave
      ((octave.override {inherit (pkgs) gnuplot;}).withPackages (opkgs: with opkgs; [ control geometry ]))
      gnuplot
      epstool
      lean
      pandoc
      # for pdf-tools
      gcc gnumake automake autoconf pkgconfig libpng zlib poppler
      (lua.withPackages (ps: with ps; [fennel]))
    ];
    environment.shells = [
      pkgs.bashInteractive
      pkgs.zsh
    ];
    environment.variables = {
      EDITOR = "emacsclient --alternate-editor='open -a Emacs'";
      VISUAL = "$EDITOR";
      LANG = "en_US.UTF-8";
      SHELL = "${pkgs.zsh}/bin/zsh";
      NODE_PATH = "/run/current-system/sw/lib/node_modules";
      DOOMDIR = "${hgj_sync}/dotfiles/.doom.d";
    };

    environment.systemPath = [
      "$HOME/Desktop/bin"
      # Easy access to Doom
      "$HOME/.emacs.d/bin"
    ];

    environment.pathsToLink = [
      "/lib/node_modules"
      "/share/emacs"
      "/share/lua"
      "/lib/lua"
    ];

    environment.loginShell = "${pkgs.zsh}/bin/zsh -l";

    environment.profiles = mkForce [ "/run/current-system/sw" "$HOME/.nix-profile" ];

    nixpkgs.overlays =
      let path = ../overlays;
      in with builtins;
        map (n: import (path + ("/" + n)))
          (filter (n: match ".*\\.nix" n != null ||
                      pathExists (path + ("/" + n + "/default.nix")))
            (attrNames (readDir path)));

    programs.zsh = {
      enable = true;
      enableFzfCompletion = true;
      enableCompletion = true;
      enableFzfHistory = true;
      enableSyntaxHighlighting = true;
      # For brew completions
      interactiveShellInit = ''
        echo >&2 "Homebrew completion path..."
        if [ -f /usr/local/bin/brew ]; then
          PATH=/usr/local/bin:$PATH fpath+=$(brew --prefix)/share/zsh/site-functions
        else
          echo -e "\e[1;31merror: Homebrew is not installed, skipping...\e[0m" >&2
        fi
      '';
    };
    services = {
      activate-system.enable = true;
      nix-daemon.enable =false;
    };

    nix = {
      trustedUsers = [ "hynggyujang" "@admin" ];
      # See Fix ⚠️ — Unnecessary NIX_PATH entry for single user installation in nix_darwin.org
      nixPath = mkForce [
        { darwin-config = "${config.environment.darwinConfig}"; }
        "$HOME/.nix-defexpr/channels"
      ];
      package = pkgs.nix;
    };

    users.users.hynggyujang = {
      name = "Hyunggyu Jang";
      home = "${hgj_home}";
      shell = pkgs.zsh;
    };
    fonts = {
      enableFontDir = true;
      fonts = [
        pkgs.sarasa-gothic
        pkgs.etBook
        pkgs.emacs-all-the-icons-fonts
      ];
    };
    homebrew = {
      enable = true;
      autoUpdate = true;
      cleanup = "zap";
      global.brewfile = true;
      taps = [
        "homebrew/cask"
        "homebrew/core"
        "homebrew/services"
        "laishulu/macism"
        "laishulu/cask-fonts"
      ];
      casks = [
        "altserver"
        "calibre"
        "font-sarasa-nerd"
        "google-chrome"
        "karabiner-elements"
        "microsoft-office"
        "vimr"
        "zotero"
        "microsoft-teams"
        "zoom"
        "anki"
        "ukelele"
        "qutebrowser"
        "hammerspoon"
      ];
      brews = [
        "pngpaste"
        "macism"
      ];
    };
  }
