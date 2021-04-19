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
      in {
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
              "<Meta-L>": "open javascript:location.href='org-protocol://capture?template=L&url='+encodeURIComponent(location.href)+'&title='+encodeURIComponent(document.title)+'&body='+encodeURIComponent(window.getSelection())"
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
      EDITOR = "emacsclient --alternate-editor=emacs";
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

    # Manual setting for workaround of org-id: 7127dc6e-5a84-476c-8d31-59737a4f85f9
    launchd.daemons.yabai-sa = {
      script = ''
          ${pkgs.yabai}/bin/yabai --check-sa || ${pkgs.yabai}/bin/yabai --install-sa
        '';

      serviceConfig.RunAtLoad = true;
      serviceConfig.KeepAlive.SuccessfulExit = false;
    };
    services = {
      yabai = {
        enable = true;
        package = pkgs.yabai;
        config = {
          mouse_follows_focus        = "off";
          focus_follows_mouse        = "off";
          window_placement           = "second_child";
          window_topmost             = "on";
          window_opacity             = "on";
          window_opacity_duration    = 0.0;
          active_window_opacity      = 1.0;
          normal_window_opacity      = 0.90;
          window_shadow              = "off";
          window_border              = "off";
          split_ratio                = 0.50;
          auto_balance               = "on";
          mouse_modifier             = "fn";
          mouse_action1              = "move";
          mouse_action2              = "resize";

          # general space settings;
          layout                     = "bsp";
          top_padding                = 0;
          bottom_padding             = 0;
          left_padding               = 0;
          right_padding              = 0;
          window_gap                 = 0;
        };
        extraConfig = ''
          yabai -m rule --add app="^System Preferences$" manage=off
          yabai -m rule --add app=Emacs title="Emacs Everywhere ::*" manage=off sticky=on
          yabai -m rule --add app=Emacs space=1
          yabai -m rule --add app=qutebrowser space=2
          yabai -m rule --add app=Anki space=3
          yabai -m rule --add app="Microsoft Teams" space=4
          yabai -m rule --add app=zoom space=4
        '';
      };
      skhd = {
        enable = true;
        skhdConfig = ''
          ################################################################################
          #
          # window manipulation
          #

          # ^ = 0x18
          ctrl + cmd - 0x18 : yabai -m window --focus recent
          ctrl + cmd - h : yabai -m window --focus west
          ctrl + cmd - j : yabai -m window --focus south
          ctrl + cmd - k : yabai -m window --focus north
          ctrl + cmd - l : yabai -m window --focus east

          ctrl + cmd - r : yabai -m space --rotate 90
          ctrl + cmd + shift - r : yabai -m space --rotate 270

          :: mywindow @
          :: swap @
          :: warp @
          :: myinsert @

          ctrl + cmd - w ; mywindow
          mywindow < ctrl - g ; default

          mywindow < h : yabai -m window west --resize right:-20:0 2> /dev/null || yabai -m window --resize right:-20:0
          mywindow < j : yabai -m window north --resize bottom:0:20 2> /dev/null || yabai -m window --resize bottom:0:20
          mywindow < k : yabai -m window south --resize top:0:-20 2> /dev/null || yabai -m window --resize top:0:-20
          mywindow < l : yabai -m window east --resize left:20:0 2> /dev/null || yabai -m window --resize left:20:0
          mywindow < 1 : skhd -k "ctrl - g" ; yabai -m query --spaces \
            | jq -re ".[] | select(.visible == 1).index" \
            | xargs -I{} yabai -m query --windows --space {} \
            | jq -sre "add | sort_by(.display, .frame.x, .frame.y, .id) | nth(0).id" \
            | xargs -I{} yabai -m window --focus {}
          mywindow < 2 : skhd -k "ctrl - g" ; yabai -m query --spaces \
            | jq -re ".[] | select(.visible == 1).index" \
            | xargs -I{} yabai -m query --windows --space {} \
            | jq -sre "add | sort_by(.display, .frame.x, .frame.y, .id) | nth(1).id" \
            | xargs -I{} yabai -m window --focus {}
          mywindow < 3 : skhd -k "ctrl - g" ; yabai -m query --spaces \
            | jq -re ".[] | select(.visible == 1).index" \
            | xargs -I{} yabai -m query --windows --space {} \
            | jq -sre "add | sort_by(.display, .frame.x, .frame.y, .id) | nth(2).id" \
            | xargs -I{} yabai -m window --focus {}
          mywindow < 4 : skhd -k "ctrl - g" ; yabai -m query --spaces \
            | jq -re ".[] | select(.visible == 1).index" \
            | xargs -I{} yabai -m query --windows --space {} \
            | jq -sre "add | sort_by(.display, .frame.x, .frame.y, .id) | nth(3).id" \
            | xargs -I{} yabai -m window --focus {}
          mywindow < 5 : skhd -k "ctrl - g" ; yabai -m query --spaces \
            | jq -re ".[] | select(.visible == 1).index" \
            | xargs -I{} yabai -m query --windows --space {} \
            | jq -sre "add | sort_by(.display, .frame.x, .frame.y, .id) | nth(4).id" \
            | xargs -I{} yabai -m window --focus {}
          mywindow < 6 : skhd -k "ctrl - g" ; yabai -m query --spaces \
            | jq -re ".[] | select(.visible == 1).index" \
            | xargs -I{} yabai -m query --windows --space {} \
            | jq -sre "add | sort_by(.display, .frame.x, .frame.y, .id) | nth(5).id" \
            | xargs -I{} yabai -m window --focus {}
          mywindow < 7 : skhd -k "ctrl - g" ; yabai -m query --spaces \
            | jq -re ".[] | select(.visible == 1).index" \
            | xargs -I{} yabai -m query --windows --space {} \
            | jq -sre "add | sort_by(.display, .frame.x, .frame.y, .id) | nth(6).id" \
            | xargs -I{} yabai -m window --focus {}
          mywindow < 8 : skhd -k "ctrl - g" ; yabai -m query --spaces \
            | jq -re ".[] | select(.visible == 1).index" \
            | xargs -I{} yabai -m query --windows --space {} \
            | jq -sre "add | sort_by(.display, .frame.x, .frame.y, .id) | nth(7).id" \
            | xargs -I{} yabai -m window --focus {}
          mywindow < 9 : skhd -k "ctrl - g" ; yabai -m query --spaces \
            | jq -re ".[] | select(.visible == 1).index" \
            | xargs -I{} yabai -m query --windows --space {} \
            | jq -sre "add | sort_by(.display, .frame.x, .frame.y, .id) | nth(8).id" \
            | xargs -I{} yabai -m window --focus {}

          mywindow < ctrl + cmd - w ; swap
          swap < ctrl - g ; default

          swap < n : skhd -k "ctrl - g" ; yabai -m query --spaces \
            | jq -re ".[] | select(.visible == 1).index" \
            | xargs -I{} yabai -m query --windows --space {} \
            | jq -sre "add | sort_by(.display, .frame.x, .frame.y, .id) | reverse | nth(index(map(select(.focused == 1))) - 1).id" \
            | xargs -I{} yabai -m window --swap {}

          swap < p: yabai -m query --spaces \
            | jq -re ".[] | select(.visible == 1).index" \
            | xargs -I{} yabai -m query --windows --space {} \
            | jq -sre "add | sort_by(.display, .frame.x, .frame.y, .id) | nth(index(map(select(.focused == 1))) - 1).id" \
            | xargs -I{} yabai -m window --swap {}

          swap < h : skhd -k "ctrl - g" ; yabai -m window --swap west
          swap < j : skhd -k "ctrl - g" ; yabai -m window --swap south
          swap < k : skhd -k "ctrl - g" ; yabai -m window --swap north
          swap < l : skhd -k "ctrl - g" ; yabai -m window --swap east

          swap < 0x18 : skhd -k "ctrl - g" ; yabai -m window --swap recent

          swap < 1 : skhd -k "ctrl - g" ; yabai -m query --spaces \
            | jq -re ".[] | select(.visible == 1).index" \
            | xargs -I{} yabai -m query --windows --space {} \
            | jq -sre "add | sort_by(.display, .frame.x, .frame.y, .id) | nth(0).id" \
            | xargs -I{} yabai -m window --swap {}
          swap < 2 : skhd -k "ctrl - g" ; yabai -m query --spaces \
            | jq -re ".[] | select(.visible == 1).index" \
            | xargs -I{} yabai -m query --windows --space {} \
            | jq -sre "add | sort_by(.display, .frame.x, .frame.y, .id) | nth(1).id" \
            | xargs -I{} yabai -m window --swap {}
          swap < 3 : skhd -k "ctrl - g" ; yabai -m query --spaces \
            | jq -re ".[] | select(.visible == 1).index" \
            | xargs -I{} yabai -m query --windows --space {} \
            | jq -sre "add | sort_by(.display, .frame.x, .frame.y, .id) | nth(2).id" \
            | xargs -I{} yabai -m window --swap {}
          swap < 4 : skhd -k "ctrl - g" ; yabai -m query --spaces \
            | jq -re ".[] | select(.visible == 1).index" \
            | xargs -I{} yabai -m query --windows --space {} \
            | jq -sre "add | sort_by(.display, .frame.x, .frame.y, .id) | nth(3).id" \
            | xargs -I{} yabai -m window --swap {}
          swap < 5 : skhd -k "ctrl - g" ; yabai -m query --spaces \
            | jq -re ".[] | select(.visible == 1).index" \
            | xargs -I{} yabai -m query --windows --space {} \
            | jq -sre "add | sort_by(.display, .frame.x, .frame.y, .id) | nth(4).id" \
            | xargs -I{} yabai -m window --swap {}
          swap < 6 : skhd -k "ctrl - g" ; yabai -m query --spaces \
            | jq -re ".[] | select(.visible == 1).index" \
            | xargs -I{} yabai -m query --windows --space {} \
            | jq -sre "add | sort_by(.display, .frame.x, .frame.y, .id) | nth(5).id" \
            | xargs -I{} yabai -m window --swap {}
          swap < 7 : skhd -k "ctrl - g" ; yabai -m query --spaces \
            | jq -re ".[] | select(.visible == 1).index" \
            | xargs -I{} yabai -m query --windows --space {} \
            | jq -sre "add | sort_by(.display, .frame.x, .frame.y, .id) | nth(6).id" \
            | xargs -I{} yabai -m window --swap {}
          swap < 8 : skhd -k "ctrl - g" ; yabai -m query --spaces \
            | jq -re ".[] | select(.visible == 1).index" \
            | xargs -I{} yabai -m query --windows --space {} \
            | jq -sre "add | sort_by(.display, .frame.x, .frame.y, .id) | nth(7).id" \
            | xargs -I{} yabai -m window --swap {}
          swap < 9 : skhd -k "ctrl - g" ; yabai -m query --spaces \
            | jq -re ".[] | select(.visible == 1).index" \
            | xargs -I{} yabai -m query --windows --space {} \
            | jq -sre "add | sort_by(.display, .frame.x, .frame.y, .id) | nth(8).id" \
            | xargs -I{} yabai -m window --swap {}


          mywindow < w ; warp
          warp < ctrl - g ; default
          warp < h : skhd -k "ctrl - g" ; \
            yabai -m window --warp west
          warp < j : skhd -k "ctrl - g" ; \
            yabai -m window --warp south
          warp < k : skhd -k "ctrl - g" ; \
            yabai -m window --warp north
          warp < l : skhd -k "ctrl - g" ; \
            yabai -m window --warp east
          warp < 1 : skhd -k "ctrl - g" ; yabai -m query --spaces \
            | jq -re ".[] | select(.visible == 1).index" \
            | xargs -I{} yabai -m query --windows --space {} \
            | jq -sre "add | sort_by(.display, .frame.x, .frame.y, .id) | nth(0).id" \
            | xargs -I{} yabai -m window --warp {}
          warp < 2 : skhd -k "ctrl - g" ; yabai -m query --spaces \
            | jq -re ".[] | select(.visible == 1).index" \
            | xargs -I{} yabai -m query --windows --space {} \
            | jq -sre "add | sort_by(.display, .frame.x, .frame.y, .id) | nth(1).id" \
            | xargs -I{} yabai -m window --warp {}
          warp < 3 : skhd -k "ctrl - g" ; yabai -m query --spaces \
            | jq -re ".[] | select(.visible == 1).index" \
            | xargs -I{} yabai -m query --windows --space {} \
            | jq -sre "add | sort_by(.display, .frame.x, .frame.y, .id) | nth(2).id" \
            | xargs -I{} yabai -m window --warp {}
          warp < 4 : skhd -k "ctrl - g" ; yabai -m query --spaces \
            | jq -re ".[] | select(.visible == 1).index" \
            | xargs -I{} yabai -m query --windows --space {} \
            | jq -sre "add | sort_by(.display, .frame.x, .frame.y, .id) | nth(3).id" \
            | xargs -I{} yabai -m window --warp {}
          warp < 5 : skhd -k "ctrl - g" ; yabai -m query --spaces \
            | jq -re ".[] | select(.visible == 1).index" \
            | xargs -I{} yabai -m query --windows --space {} \
            | jq -sre "add | sort_by(.display, .frame.x, .frame.y, .id) | nth(4).id" \
            | xargs -I{} yabai -m window --warp {}
          warp < 6 : skhd -k "ctrl - g" ; yabai -m query --spaces \
            | jq -re ".[] | select(.visible == 1).index" \
            | xargs -I{} yabai -m query --windows --space {} \
            | jq -sre "add | sort_by(.display, .frame.x, .frame.y, .id) | nth(5).id" \
            | xargs -I{} yabai -m window --warp {}
          warp < 7 : skhd -k "ctrl - g" ; yabai -m query --spaces \
            | jq -re ".[] | select(.visible == 1).index" \
            | xargs -I{} yabai -m query --windows --space {} \
            | jq -sre "add | sort_by(.display, .frame.x, .frame.y, .id) | nth(6).id" \
            | xargs -I{} yabai -m window --warp {}
          warp < 8 : skhd -k "ctrl - g" ; yabai -m query --spaces \
            | jq -re ".[] | select(.visible == 1).index" \
            | xargs -I{} yabai -m query --windows --space {} \
            | jq -sre "add | sort_by(.display, .frame.x, .frame.y, .id) | nth(7).id" \
            | xargs -I{} yabai -m window --warp {}
          warp < 9 : skhd -k "ctrl - g" ; yabai -m query --spaces \
            | jq -re ".[] | select(.visible == 1).index" \
            | xargs -I{} yabai -m query --windows --space {} \
            | jq -sre "add | sort_by(.display, .frame.x, .frame.y, .id) | nth(8).id" \
            | xargs -I{} yabai -m window --warp {}

          mywindow < i ; myinsert
          myinsert < ctrl - g ; default

          myinsert < h : skhd -k "ctrl - g"; yabai -m window --insert west
          myinsert < j : skhd -k "ctrl - g"; yabai -m window --insert north
          myinsert < k : skhd -k "ctrl - g"; yabai -m window --insert south
          myinsert < l : skhd -k "ctrl - g"; yabai -m window --insert east

          ctrl + cmd - return : yabai -m window --toggle zoom-fullscreen

          ################################################################################
          #
          # space manipulation
          #

          cmd - 1 : yabai -m space --focus 1
          cmd - 2 : yabai -m space --focus 2
          cmd - 3 : yabai -m space --focus 3
          cmd - 4 : yabai -m space --focus 4
          cmd - 5 : yabai -m space --focus 5
          cmd - 6 : yabai -m space --focus 6

          # Move currently focused window to the specified space
          ctrl + cmd - 1 : yabai -m window --space 1; yabai -m space --focus 1
          ctrl + cmd - 2 : yabai -m window --space 2; yabai -m space --focus 2
          ctrl + cmd - 3 : yabai -m window --space 3; yabai -m space --focus 3
          ctrl + cmd - 4 : yabai -m window --space 4; yabai -m space --focus 4
          ctrl + cmd - 5 : yabai -m window --space 5; yabai -m space --focus 5
          ctrl + cmd - 6 : yabai -m window --space 6; yabai -m space --focus 6

          ################################################################################
          #
          # Applications
          #

          ctrl + cmd - c [
            "emacs" : skhd -k "ctrl - x" ; skhd -k "ctrl - c"
            "finder" : skhd -k "cmd - w"
            # "Google Chrome" : skhd -k "cmd - w" # I'll use chrome in app mode while using yabai!
            "kitty" : skhd -k "cmd - w"
            *       : skhd -k "cmd - q"
          ]

          ################################################################################
          #
          # Mode for opening applications
          #

          :: open @
          ctrl + cmd - o ; open
          open < ctrl - g ; default

          # emacs
          open < e : open -a "$HOME/Applications/Nix Apps/Emacs.app"; skhd -k "ctrl - g"
          open < shift - e : DEBUG=1 open -a "$HOME/Applications/Nix Apps/Emacs.app"; skhd -k "ctrl - g"

          # kitty or terminal
          open < t : "$HOME/Desktop/bin/open_kitty"; skhd -k "ctrl - g"

          # Internet Browser
          open < b : open -a "/Applications/qutebrowser.app"; skhd -k "ctrl - g"
          ctrl + cmd - e : skhd -k "cmd - a" ; doom everywhere
          ctrl + shift + cmd - e : doom everywhere
        '';
      };
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
