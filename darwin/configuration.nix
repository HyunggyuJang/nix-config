{ config ? inputs.nix-darwin.config, pkgs ? inputs.nixpkgs, lib, inputs, specialArgs, ... }:
let
  machineType = specialArgs.machineType or "unknown";
  owner = if machineType == "M3-Pro" then "a13884" else "hyunggyujang";
  hgj_home = "/Users/${owner}";
  hgj_sync = hgj_home;
  hgj_darwin_home = "${hgj_sync}/nixpkgs/darwin";
  hgj_localbin = ".local/bin";
  localconfig = import ./silicon.nix;
  brewpath = "/opt/homebrew";

  nur = config.nur;

  kittyDracula = with pkgs;
    stdenv.mkDerivation {
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

  # https://github.com/NixOS/nixpkgs/issues/11893
  altacv = with pkgs;
    stdenv.mkDerivation rec {
      name = "altacv";
      src = fetchFromGitHub {
        owner = "liantze";
        repo = "AltaCV";
        rev = "74bc05d";
        sha256 = "sha256-3xbEqyg2UC8ngMos8+BzLzrUpzhA8w3QM3Cn2d0HzY4=";
      };
      pname = name;
      tlType = "run";
      installPhase = ''
        mkdir -p $out/tex/latex
        cp altacv.cls $out/tex/latex/
      '';
    };
in
with lib; rec {
  # See https://github.com/LnL7/nix-darwin/issues/701
  documentation.enable = false;

  # Home manager
  imports = [ "${inputs.home-manager}/nix-darwin" ];

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = false;
  home-manager.users =
    let
      userconfig = { config, ... }: {
        home.stateVersion = "24.11";
        home.file = {
          ".direnvrc".text = ''
            export_alias() {
              local name=$1
              shift
              local alias_dir=$PWD/.direnv/aliases
              local target="$alias_dir/$name"
              local oldpath="$PATH"
              mkdir -p "$alias_dir"
              if ! [[ ":$PATH:" == *":$alias_dir:"* ]]; then
                PATH_add "$alias_dir"
              fi

              echo "#!/usr/bin/env bash" > "$target"
              echo "PATH=$oldpath" >> "$target"
              echo "$@" >> "$target"
              chmod +x "$target"
            }
          '';
          ".cargo/bin/rust-analyzer".source = config.lib.file.mkOutOfStoreSymlink
            "${hgj_home}/.rustup/toolchains/stable-aarch64-apple-darwin/bin/rust-analyzer";
          ".gnupg/gpg-agent.conf".text = ''
            enable-ssh-support
            default-cache-ttl 86400
            max-cache-ttl 86400
            pinentry-program /run/current-system/sw/bin/pinentry-mac
          '';
          ".tridactylrc".text = ''
            # set editorcmd emacsclient --eval "(setq mac-use-title-bar t)"; emacsclient -c -F "((name . \"Emacs Everywhere :: firefox\") (width . 80) (height . 12) (internal-border-width . 0))" +%l:%c
            # bind <M-p> js location.href='org-protocol://capture?template=p&url='+encodeURIComponent(location.href)+'&title='+encodeURIComponent(document.title)+'&body='+encodeURIComponent(window.getSelection())
            # bind <M-i> js location.href='org-protocol://capture?template=L&url='+encodeURIComponent(location.href)+'&title='+encodeURIComponent(document.title)+'&body='+encodeURIComponent(window.getSelection())
            bind --mode=browser <C-g> escapehatch
            bind <C-g> composite mode normal ; hidecmdline
            bind --mode=ex <C-g> ex.hide_and_clear
            bind --mode=insert <C-g> composite unfocus | mode normal
            bind --mode=input <C-g> composite unfocus | mode normal
            bind --mode=hint <C-g> hint.reset
            bind --mode=visual <C-g> composite js document.getSelection().empty(); mode normal; hidecmdline
            bind --mode=ex <A-n> ex.next_history
            bind --mode=ex <A-p> ex.prev_history
            # bind --mode=insert <C-p> !s skhd -k up
            # bind --mode=insert <C-n> !s skhd -k down
            bind --mode=ex <C-p> ex.prev_completion
            bind --mode=ex <C-n> ex.next_completion
            # bind --mode=ex <C-k> text.kill_line # same as default setting
            # unbind --mode=ex <C-j> # used for kakutei key in Aquaskk
            bind --mode=ex <Tab> ex.insert_space_or_completion # ex.complete is buggy
            # unbind --mode=ex <Space>
            bind --mode=insert <A-d> text.kill_word
            bind --mode=insert <C-u> text.backward_kill_line
            bind --mode=insert <A-f> text.forward_word
            bind --mode=insert <A-b> text.backward_word
            # For international language mode navigation -- specifically for Korean
            bind --mode=insert <A-k> text.kill_line
            bind --mode=insert <A-u> text.backward_kill_line
            bind --mode=insert <A-a> text.beginning_of_line
            bind --mode=insert <A-e> text.end_of_line
            set theme dark
          '';
          ".qutebrowser/config.py".text = ''
            config.load_autoconfig(True)
            # c.window.hide_decoration = True

            # c.colors.webpage.darkmode.enabled = True

            # c.qt.args = [ "disable-gpu" ]

            c.qt.environ = {"NODE_PATH": "/run/current-system/sw/lib/node_modules"}

            c.url.default_page = 'https://google.com'
            c.url.start_pages = c.url.default_page
            c.url.searchengines = {"DEFAULT": "https://google.com/search?q={}"}
            with config.pattern('teams.microsoft.com') as p:
                 p.content.unknown_url_scheme_policy = 'allow-all'
            c.content.unknown_url_scheme_policy

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
                "<Meta-i>": "open javascript:location.href='org-protocol://capture?template=L&url='+encodeURIComponent(location.href)+'&title='+encodeURIComponent(document.title)+'&body='+encodeURIComponent(window.getSelection())"
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

            # config.bind(';;', 'hint inputs --first')  # easier to reach than ;t -> can be inserted using gi

            # Open in firefox
            config.bind(';g', 'hint links spawn open -na Firefox --args {hint-url}')

            c.aliases['readability-js'] = "spawn -u readability-js"
            c.aliases['readability'] = "spawn -u readability"
            c.aliases['firefox'] = "spawn open -na Firefox --args {url}"
            c.aliases['removed'] = "open javascript:document.location=document.URL.replace('reddit.com','removeddit.com');"
            c.aliases['save-to-zotero'] = "jseval --quiet var d=document,s=d.createElement('script');s.src='https://www.zotero.org/bookmarklet/loader.js';(d.body?d.body:d.documentElement).appendChild(s);void(0);"
            c.aliases['mouse-pointer'] = "open javascript:void%20function(){document.head.innerHTML+=%22%3Cstyle%3E%20*%20%20{%20cursor:%20url(data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAGCklEQVRYhe2XTWwd1RXHj2fmzpdnxm/G7z1btjG2lTpOU2rhNkGWElQSZCJkCQUhZJQVlCYyUutERan4kGqvyCYSrEAWWA4fKlRJXFfdRapA2WSBIAtokYUIyESgIJQ6tnHs9+b+uphrwqJ23EAXVXulq7/mfpx77rnnnP8Zkf+3/9LWQNGt7/QGKfp/piHSMC5ivSuiEPERCRGJEIkNhoj474qo8RsK/WCHW4i45qAyIrddF/kRIjtXRe5AZKf5vs3MR2a99X3PbkDEQaQRkSoivYgMInI/tv0Itv0Ytv0rg48gcr+Z7zXrGxFx5FasYd5YIZIg0onIXdj2Q7lSR3HdE3jeZO77r+P7f8h9/3U8bxLXPZErdRTbfgiRu8y+xMj595QwN08Q6UHkHizrCEqdxPNOEwTnCcOLRNFHxPEcUfQRYXiRIDiP551GqZNY1hFE7jH7E2OJLR9uG/N1IbIPpcbwvJd1ELxDFM0Rx1/S1HSVNL1Gmi6SptdoarpKHH9JFM0RBO/geS+j1Bgi+4ycRkTsrZreQ6QVkUEs64ncdacIggtE0Tyl0gJZtkK5vEqlskalUqNSWaNcXiXLViiVFoiieYLgQu66U1jWE4gMLhXyvJs+hbl9gsgObHsEpV4gCM4Tx5+Tpos0N6/S2lqjvb1OZ2edrq6czs467e11WltrNDevkqaLxPHnBMF5lHoB2x5BZIeRu6kVGkz4tCByN45zHM+bJY4/plRaoFxepa2tTnd3Tn9/zt69mn37NHv3avr7c7q7c9ra6pTLq7pUWiCOP8bzZnGc3yFyt5HrbmgFY/7AOM6DKPW8DsMLJMkVmptXaG2t0dOTMzioGRnRjI1pjh8vcGREMzio6enJjSVWSJIrhOGFXKnnEXnQyA03U8AymW0ntv0Yvv8aUfQ3SqUFKpU1OjrqDAzkHDqkmZiAF1+EV14pcGICDh3SDAzkdHTUqVTWjD/8Hd9/Ddv+JSI/QSQe3yhB/VHEvipSQmQApX6N550ljj8hTZeoVmt0d+fs36958knN5KTmrbc0p08XODlZjO/fr+nuzqlWa6TpMnH8CZ43g1K/QeRnFPL/tR8gYv9DJEVkF0odIwj+TJJ8RpYtU63W2LYtZ3hYMz6uOXVKc+aMZmamwFOnivHhYc22bYUCWbZMknxGEPwFx/ktIrsRyTbMCSYCUkR+jlJjOgj+RBxf+laBnp6cAwc0Tz+tmZoqbn/2bIFTU8X4gQOFH6wrEMef6iCYRamjiOwyF9zQAhYiyarIT7GsI/j+m8TxHGm6SKWyRmdnncFBzeHDmpMnYXpa88Ybmunp4vvw4cIROzsLHyjCcQ7ff9Nkxn5EmjYkKaNAIyK92PZI7nkvEYbv6yT5mnL5Om1tdbZvzxka0oyOFo544kThgKOjmqEhzfbt66F4nST5mjB8H897yZBVr5G/oQLrWbAdkSFcdwLfP0cUzZOmS99GQl9fzp49mgce0Dz8cIF79mj6+m5EQJouEUXz+P45XHcCkSFEOm6aDQ0JpYjciW0/jutO6TB8jyS5QpZ9Q7W6Rnt7kQF7e3N27Ciwqyunvb1OtbpGln1jcsB7uetO1W37cUTuNHI3JyXzDIGh0ntxnKe0550hij4kSb4iy5Ypl1epVmu0tNRoba3T0lKjWq0ZPlgmSb4iij7E887gOE8hcq+RF2ypSDFWaEKkD5GDuetO4HkzhOFF4viyYcIlsmyF5uYVsmyFNF0yjHiZMLyI580Y0x80cpq2TMnc4IQyInfUbfsgjvNM7rqvEgRv09j4gY7jS8TxZZLkC+L4MnF8icbGDwiCt3HdV3GcZ+q2fZCiZCtvygGbPIVnNv8YkfuwrFFc9zlcd5ogmMX3zxEEfzU4i+tO47rPYVmjiNy3WuwrI+KN30p9+B0lSqao2IXIMLb9KEodw3GezR3n9zjOsyh1DNt+FJFhRHatiHSZtO5t6d03UWK9NgzNbW43pLLbUOwvDO4247dfK9aF3EoteBNrKOPJ8UKR0yuIVBcLzBCJ54t59b1ufRNF1v+IHHPQenf4oX9I/ifaPwEDuMzfkWqgjAAAAABJRU5ErkJggg==),%20auto%20!important;%20}%20%3C/style%3E%22}();"

            #Activate dracula theme
            import dracula.draw

            dracula.draw.blood(c, {
                'spacing': {
                    'vertical': 6,
                    'horizontal': 8
                }
            })
          '';
          "Library/Application Support/AquaSKK/keymap.conf".text = ''
            ###
            ### keymap.conf
            ###

            # ======================================================================
            # event section
            # ======================================================================

            SKK_JMODE		ctrl::j
            SKK_ENTER		group::hex::0x03,0x0a,0x0d||ctrl::m
            SKK_CANCEL		ctrl::g||hex::0x1b
            SKK_BACKSPACE		hex::0x08||ctrl::h
            SKK_DELETE		hex::0x7f||ctrl::d
            SKK_TAB			hex::0x09||ctrl::i
            SKK_PASTE		ctrl::y
            SKK_LEFT		hex::0x1c||ctrl::b||keycode::7b
            SKK_RIGHT		hex::0x1d||ctrl::f||keycode::7c
            SKK_UP			hex::0x1e||ctrl::a||keycode::7e
            SKK_DOWN		hex::0x1f||ctrl::e||keycode::7d
            SKK_PING		ctrl::l
            SKK_UNDO                ctrl::/

            # ======================================================================
            # attribute section(for SKK_CHAR)
            # ======================================================================

            ToggleKana		q
            ToggleJisx0201Kana	ctrl::q
            SwitchToAscii		l
            SwitchToJisx0208Latin	L

            EnterAbbrev		/
            EnterJapanese		Q
            NextCompletion		.
            PrevCompletion		,
            NextCandidate		hex::0x20||ctrl::n
            PrevCandidate		x||ctrl::p
            RemoveTrigger		X

            UpperCases		group::A-K,M-P,R-Z
            Direct			group::keycode::0x41,0x43,0x45,0x4b,0x4e,0x51-0x59,0x5b,0x5c,0x5f
            InputChars              group::hex::0x20-0x7e

            CompConversion		alt::hex::0x20||shift::hex::0x20

            # ======================================================================
            # handle option
            # ======================================================================

            AlwaysHandled           group::keycode::0x66,0x68
            PseudoHandled           ctrl::l

            # ======================================================================
            # Sticky key
            # ======================================================================

            StickyKey               ;
          '';
          "Library/Application Support/AquaSKK/azik.conf".text = ''
            NotToggleKana		q
            NotToggleJisx0201Kana	ctrl::q
            NotEnterJapanese		Q

            ToggleKana		keycode::21
            ToggleJisx0201Kana	ctrl::keycode::21
            EnterJapanese  shift::keycode::21
            UpperCases		Q||shift::keycode::29
            InputChars		shift::keycode::29||keycode::21
          '';
          "Library/Application Support/AquaSKK/sub-rule.desc".text = ''
            ###
            ### sub-rule.desc -- 補助ルールの説明
            ###

            azik_us.rule azik.conf Use「AZIK」extension
          '';
          "Library/Application Support/AquaSKK/azik_us.rule" = import ./azik_us.nix;
          "Library/Application Support/AquaSKK/BlacklistApps.plist".text = ''
            <?xml version="1.0" encoding="UTF-8"?>
            <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
            <plist version="1.0">
            <array>
              <dict>
                <key>bundleIdentifier</key>
                <string>com.microsoft.powerpoint</string>
                <key>insertEmptyString</key>
                <false/>
                <key>insertMarkedText</key>
                <false/>
                <key>syncInputSource</key>
                <false/>
              </dict>
              <dict>
                <key>bundleIdentifier</key>
                <string>com.jetbrains</string>
                <key>insertEmptyString</key>
                <false/>
                <key>insertMarkedText</key>
                <false/>
                <key>syncInputSource</key>
                <false/>
              </dict>
              <dict>
                <key>bundleIdentifier</key>
                <string>com.google.android.studio</string>
                <key>insertEmptyString</key>
                <false/>
                <key>insertMarkedText</key>
                <false/>
                <key>syncInputSource</key>
                <false/>
              </dict>
              <dict>
                <key>bundleIdentifier</key>
                <string>jp.naver.line.mac</string>
                <key>insertEmptyString</key>
                <false/>
                <key>insertMarkedText</key>
                <false/>
              </dict>
            </array>
            </plist>
          '';
          "Library/Application Support/AquaSKK/DictionarySet.plist".text = ''
            <?xml version="1.0" encoding="UTF-8"?>
            <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
            <plist version="1.0">
            <array>
              <dict>
                <key>active</key>
                <true/>
                <key>location</key>
                <string>~/.doom/etc/skk/skk-jisyo.utf8</string>
                <key>type</key>
                <integer>5</integer>
              </dict>
              <dict>
                <key>active</key>
                <false/>
                <key>location</key>
                <string>SKK-JISYO.L</string>
                <key>type</key>
                <integer>1</integer>
              </dict>
              <dict>
                <key>active</key>
                <false/>
                <key>location</key>
                <string>SKK-JISYO.jinmei</string>
                <key>type</key>
                <integer>1</integer>
              </dict>
              <dict>
                <key>active</key>
                <false/>
                <key>location</key>
                <string>SKK-JISYO.fullname</string>
                <key>type</key>
                <integer>1</integer>
              </dict>
              <dict>
                <key>active</key>
                <false/>
                <key>location</key>
                <string>SKK-JISYO.geo</string>
                <key>type</key>
                <integer>1</integer>
              </dict>
              <dict>
                <key>active</key>
                <false/>
                <key>location</key>
                <string>SKK-JISYO.propernoun</string>
                <key>type</key>
                <integer>1</integer>
              </dict>
              <dict>
                <key>active</key>
                <false/>
                <key>location</key>
                <string>SKK-JISYO.station</string>
                <key>type</key>
                <integer>1</integer>
              </dict>
              <dict>
                <key>active</key>
                <false/>
                <key>location</key>
                <string>SKK-JISYO.law</string>
                <key>type</key>
                <integer>1</integer>
              </dict>
              <dict>
                <key>active</key>
                <false/>
                <key>location</key>
                <string>SKK-JISYO.okinawa</string>
                <key>type</key>
                <integer>1</integer>
              </dict>
              <dict>
                <key>active</key>
                <false/>
                <key>location</key>
                <string>SKK-JISYO.china_taiwan</string>
                <key>type</key>
                <integer>1</integer>
              </dict>
              <dict>
                <key>active</key>
                <false/>
                <key>location</key>
                <string>SKK-JISYO.assoc</string>
                <key>type</key>
                <integer>1</integer>
              </dict>
              <dict>
                <key>active</key>
                <false/>
                <key>location</key>
                <string>SKK-JISYO.edict</string>
                <key>type</key>
                <integer>1</integer>
              </dict>
              <dict>
                <key>active</key>
                <false/>
                <key>location</key>
                <string>zipcode/SKK-JISYO.zipcode</string>
                <key>type</key>
                <integer>1</integer>
              </dict>
              <dict>
                <key>active</key>
                <false/>
                <key>location</key>
                <string>zipcode/SKK-JISYO.office.zipcode</string>
                <key>type</key>
                <integer>1</integer>
              </dict>
              <dict>
                <key>active</key>
                <false/>
                <key>location</key>
                <string>SKK-JISYO.JIS2</string>
                <key>type</key>
                <integer>1</integer>
              </dict>
              <dict>
                <key>active</key>
                <false/>
                <key>location</key>
                <string>SKK-JISYO.JIS3_4</string>
                <key>type</key>
                <integer>1</integer>
              </dict>
              <dict>
                <key>active</key>
                <false/>
                <key>location</key>
                <string>SKK-JISYO.JIS2004</string>
                <key>type</key>
                <integer>1</integer>
              </dict>
              <dict>
                <key>active</key>
                <false/>
                <key>location</key>
                <string>SKK-JISYO.itaiji</string>
                <key>type</key>
                <integer>1</integer>
              </dict>
              <dict>
                <key>active</key>
                <false/>
                <key>location</key>
                <string>SKK-JISYO.itaiji.JIS3_4</string>
                <key>type</key>
                <integer>1</integer>
              </dict>
              <dict>
                <key>active</key>
                <false/>
                <key>location</key>
                <string>SKK-JISYO.mazegaki</string>
                <key>type</key>
                <integer>1</integer>
              </dict>
              <dict>
                <key>active</key>
                <true/>
                <key>location</key>
                <string>localhost:1178</string>
                <key>type</key>
                <integer>2</integer>
              </dict>
              <dict>
                <key>active</key>
                <true/>
                <key>location</key>
                <string>${hgj_home}/.doom/etc/skk/aquaskk-jisyo.utf8</string>
                <key>type</key>
                <integer>5</integer>
              </dict>
            </array>
            </plist>
          '';
          ".mailcap".text = ''
            # HTML
            text/html; open %s; description=HTML Text; test=test -n "$DISPLAY";  nametemplate=%s.html
          '';
          ".mbsyncrc".text = ''
            IMAPAccount nagoya
            Host mail.math.nagoya-u.ac.jp
            User hyunggyu.jang.e6@math.nagoya-u.ac.jp #not XXX@me.com etc.
            AuthMechs LOGIN
            PassCmd "pass Migrate/math.nagoya-u.ac.jp"
            Port 993
            CertificateFile ~/.mail/nagoya.crt
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
            tls_trust_file /etc/ssl/certs/ca-certificates.crt
            logfile        ~/.msmtp.log

            # Nagoya-U mail
            account        hyunggyu.jang.e6@math.nagoya-u.ac.jp
            host           smtp.math.nagoya-u.ac.jp
            port           443
            protocol       smtp
            # https://help.zoho.com/portal/en/community/topic/msmtp
            from	         hyunggyu.jang.e6@math.nagoya-u.ac.jp
            user           hyunggyu.jang.e6@math.nagoya-u.ac.jp
            passwordeval   "pass Migrate/math.nagoya-u.ac.jp"
            tls_starttls   off

            # Set a default account
            account default : hyunggyu.jang.e6@math.nagoya-u.ac.jp
          '';
          ".notmuch-config".text = ''
            [database]
            path=${hgj_home}/.mail
            [user]
            name=Hyunggyu Jang
            primary_email=murasakipurplez5@gmail.com
            other_email=hyunggyu.jang.e6@math.nagoya-u.ac.jp
            [new]
            tags=new
            ignore=/.*[.](json|lock|bak)$/;.mbsyncstate;.uidvalidity;.DS_Store
            [search]
            exclude_tags=deleted;spam;
            [maildir]
            synchronize_flags=true
          '';
          "${hgj_localbin}/open_kitty" = {
            executable = true;
            text = ''
              #!/usr/bin/env bash

              # https://github.com/noperator/dotfiles/blob/master/.config/kitty/launch-instance.sh

              # Launch a kitty window from another kitty window, while:
              # 1. Copying the first window's working directory, and
              # 2. Keeping the second window on the first window's focused display.

              PATH="/Applications/kitty.app/Contents/MacOS${
            "\${PATH:+:\${PATH}}"
          }"

              FOCUSED_WINDOW=$(yabai -m query --windows --window)

              # If launching _from_ a focused kitty window, open the new kitty window with
              # the same working directory. The socket is required to use control messages to
              # grab the working directory of the focused kitty window; more details in
              # kitty's documentation:
              # - https://sw.kovidgoyal.net/kitty/invocation.html?highlight=socket#cmdoption-kitty-listen-on
              FOCUSED_WINDOW_APP=$(echo "$FOCUSED_WINDOW" | jq '.app' -r)
              if [[ "$FOCUSED_WINDOW_APP" == 'kitty' ]]; then
                  DIR=$(
                      kitty @ --to unix:/tmp/mykitty ls |
                      jq '.[] | select(.is_focused==true) | .tabs[] | select(.is_focused==true) | .windows[] | .cwd' -r
                  )
              else
                  DIR="$HOME"
              fi

              # Adapted a few changes from @yanzhang0219's script to leverage yabai signals to
              # move the new kitty window to the focused display, rather than the display the
              # first kitty window was launched from.
              # - https://github.com/koekeishiya/yabai/issues/413#issuecomment-604072616
              # - https://github.com/koekeishiya/yabai/wiki/Commands#automation-with-rules-and-signals
              FOCUSED_WINDOW_DISPLAY=$(echo "$FOCUSED_WINDOW" | jq .display)
              FOCUSED_WINDOW_ID=$(echo "$FOCUSED_WINDOW" | jq .id)

              yabai -m signal --add \
                  action="yabai -m signal --remove temp_move_kitty;
                          YABAI_WINDOW_DISPLAY=\$(yabai -m query --windows --window $YABAI_WINDOW_ID | jq .display);
                          if ! [[ \$YABAI_WINDOW_DISPLAY == $FOCUSED_WINDOW_DISPLAY ]]; then
                              yabai -m window \$YABAI_WINDOW_ID --warp $FOCUSED_WINDOW_ID;
                              yabai -m window --focus \$YABAI_WINDOW_ID;
                          fi" \
                  app=kitty \
                  event=window_created \
                  label=temp_move_kitty

              # Launch new kitty window; the temporary signal above will move it to the
              # focused display.
              kitty --listen-on unix:/tmp/mykitty --single-instance --directory "$DIR"
            '';
          };
          "storage".source = config.lib.file.mkOutOfStoreSymlink
            "${hgj_home}/OneDrive - j.mbox.nagoya-u.ac.jp/";
        } // (if machineType != "M3-Pro" then {
          ".gitconfig".text = ''
            [user]
              name = Hyunggyu Jang
              email = murasakipurplez5@gmail.com
          '';
        } else {});
        # https://github.com/nix-community/home-manager/blob/db00b39a9abec04245486a01b236b8d9734c9ad0/tests/modules/targets-darwin/default.nix
        # Has to be set explicitly as it disabled by default, preferring nix-darwin
        targets.darwin.keybindings = {
          # Control shortcuts
          "^l" = "centerSelectionInVisibleArea:";
          "^/" = "undo:";
          "^_" = "undo:";
          "^ " = "setMark:";
          "^w" = "deleteToMark:";
          "^u" = "deleteToBeginningOfLine:";
          "^g" = "_cancelKey:";
          # Meta shortcuts
          "~y" = "yankPop:";
          "~f" = "moveWordForward:";
          "~b" = "moveWordBackward:";
          "~p" = "selectPreviousKeyView:";
          "~n" = "selectNextKeyView:";
          # Excaping XML expressions should be done automatically!
          "~&lt;" = "moveToBeginningOfDocument:";
          "~&gt;" = "moveToEndOfDocument:";
          "~v" = "pageUp:";
          "~/" = "complete:";
          "~c" = [ "capitalizeWord:" "moveForward:" "moveForward:" ];
          "~u" = [ "uppercaseWord:" "moveForward:" "moveForward:" ];
          "~l" = [ "lowercaseWord:" "moveForward:" "moveForward:" ];
          "~d" = "deleteWordForward:";
          "^~h" = "deleteWordBackward:";
          "~t" = "transposeWords:";
          "~\\@" = [ "setMark:" "moveWordForward:" "swapWithMark:" ];
          "~h" = [ "setMark:" "moveToEndOfParagraph:" "swapWithMark:" ];
          # C-x shortcuts
          "^x" = {
            "u" = "undo:";
            "k" = "performClose:";
            "^f" = "openDocument:";
            "^x" = "swapWithMark:";
            "^m" = "selectToMark:";
            "^s" = "saveDocument:";
            "^w" = "saveDocumentAs:";
          };
        };
        xdg = {
          enable = true;

          configHome = "${hgj_home}/.config";
          dataHome = "${hgj_home}/.local/share";
          cacheHome = "${hgj_home}/.cache";
          configFile = {
            "fontconfig/fonts.conf".text = ''
              <?xml version='1.0'?>
              <!-- Generated by Hyunggyu Jang. -->
              <!DOCTYPE fontconfig SYSTEM 'fonts.dtd'>
              <fontconfig>
                <dir>/Library/Fonts</dir>
                <dir>${hgj_home}/Library/Fonts</dir>
              </fontconfig>
            '';
            "pip/pip.conf".text = ''
              [global]
              break-system-packages = true
            '';
            "afew/config".text = ''
              [MailMover]
              folders = account.nagoya/Inbox account.nagoya/Trash
              rename = True

              account.nagoya/Inbox = 'tag:trash':'account.nagoya/Trash' 'NOT tag:inbox AND tag:lab':'account.nagoya/Lab' 'NOT tag:inbox AND tag:school':'account.nagoya/School' 'NOT tag:inbox AND NOT tag:trash':'account.nagoya/Archive'
              account.nagoya/Trash = 'NOT tag:trash':'account.nagoya/Inbox'

              [FolderNameFilter]
              folder_blacklist = account.nagoya account.gmail mail Archive
              folder_transforms = Drafts:draft Junk:spam
              folder_lowercases = true
              maildir_separator = /
            '';

            "kitty/dracula.conf".source = "${kittyDracula}/dracula.conf";
            "kitty/diff.conf".source = "${kittyDracula}/diff.conf";
            "kitty/kitty.conf".text = ''
              allow_remote_control yes

              hide_window_decorations yes

              font_family      Roboto Mono
              font_size        14.0

              macos_thicken_font 0.5

              macos_option_as_alt yes
              macos_hide_from_tasks no
              macos_quit_when_last_window_closed yes

              include dracula.conf
            '';
            "helix/config.toml".text = ''
              [editor.cursor-shape]
              insert = "bar"
              normal = "block"
              select = "underline"
            '';
            "zathura/zathurarc".text = "set selection-clipboard clipboard";
            "karabiner/karabiner.json".source = ./karabiner.json;
            "youtube-dl/config".text = ''
              # Save all vides under Youtube directory in cloud server
              -o ~/storage/Youtube/%(title)s.%(ext)s
            '';
          };
        };
        programs = {
          vscode = {
            enable = true;
            package = pkgs.vscode;
            extensions = (with pkgs.vscode-extensions; [
              bierner.markdown-mermaid
              bodil.file-browser
              editorconfig.editorconfig
              esbenp.prettier-vscode
              github.copilot
              github.copilot-chat
              jnoortheen.nix-ide
              kahole.magit
              mkhl.direnv
              streetsidesoftware.code-spell-checker
              vspacecode.vspacecode
              vspacecode.whichkey
            ]) ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
              {
                name = "open-in-editor-vscode";
                publisher = "generalov";
                version = "1.0.1";
                sha256 = "sha256-yrbZhp0NN4J1llyxz+FgOdc1lKg53SWlXfhsZpkP1hA=";
              }
              {
                name = "vim-with-killring";
                publisher = "hyunggyujang";
                version = "1.0.7";
                sha256 = "sha256-clTKqm/OFsgPLUcbfUvdHkA4JjLGWFNhqpYKZlzex1Q=";
              }
              {
                name = "fuzzy-search";
                publisher = "jacobdufault";
                version = "0.0.3";
                sha256 = "sha256-oN1SzXypjpKOTUzPbLCTC+H3I/40LMVdjbW3T5gib0M=";
              }
            ];
            userSettings = {
              "vim.easymotion" = true;
              "vim.sneak" = true;
              "vim.incsearch" = true;
              "vim.useSystemClipboard" = true;
              "vim.useCtrlKeys" = true;
              "vim.hlsearch" = true;
              "vim.visualstar" = true;
              "vim.commandLineModeKeyBindingsNonRecursive" = [
                {
                  "before" = [
                    "<C-a>"
                  ];
                  "after" = [
                    "<Home>"
                  ];
                }
                {
                  "before" = [
                    "<C-b>"
                  ];
                  "after" = [
                    "<Left>"
                  ];
                }
                {
                  "before" = [
                    "<C-f>"
                  ];
                  "after" = [
                    "<Right>"
                  ];
                }
                {
                  "before" = [
                    "<C-k>"
                  ];
                  "after" = [
                    "<End>"
                    "<C-u>"
                  ];
                }
              ];
              "vim.normalModeKeyBindingsNonRecursive" = [
                {
                  "before" = [
                    "Y"
                  ];
                  "after" = [
                    "y"
                    "$"
                  ];
                }
                {
                  "before" = [
                    "<space>"
                  ];
                  "commands" = [
                    "vspacecode.space"
                  ];
                }
                {
                  "before" = [
                    ","
                  ];
                  "commands" = [
                    "vspacecode.space"
                    {
                      "command" = "whichkey.triggerKey";
                      "args" = "m";
                    }
                  ];
                }
                {
                  "before" = [
                    "g"
                    "s"
                  ];
                  "after" = [
                    "<leader>"
                    "<leader>"
                  ];
                }
                {
                  "before" = [
                    "g"
                    "s"
                    "s"
                  ];
                  "after" = [
                    "<leader>"
                    "<leader>"
                    "2"
                    "s"
                  ];
                }
                {
                  "before" = [
                    "%"
                  ];
                  "commands" = [
                    "editor.action.jumpToBracket"
                  ];
                }
              ];
              "vim.visualModeKeyBindingsNonRecursive" = [
                {
                  "before" = [
                    "<space>"
                  ];
                  "commands" = [
                    "vspacecode.space"
                  ];
                }
                {
                  "before" = [
                    ","
                  ];
                  "commands" = [
                    "vspacecode.space"
                    {
                      "command" = "whichkey.triggerKey";
                      "args" = "m";
                    }
                  ];
                }
                {
                  "before" = [
                    "g"
                    "s"
                  ];
                  "after" = [
                    "<leader>"
                    "<leader>"
                  ];
                }
                {
                  "before" = [
                    "g"
                    "s"
                    "s"
                  ];
                  "after" = [
                    "<leader>"
                    "<leader>"
                    "2"
                    "s"
                  ];
                }
              ];
              "editor.renderWhitespace" = "none";
              "editor.lineNumbers" = "off";
              "magit.quick-switch-enabled" = true;
              "workbench.editorAssociations" = { };
              "alt-editor.binary" = "emacsclient";
              "alt-editor.args" = "-n +{line}:{column} {filename}";
              "vim.sneakReplacesF" = true;
              "[jsonc]" = {
                "editor.defaultFormatter" = "vscode.json-language-features";
              };
              "solidity.telemetry" = false;
              "[typescript]" = {
                "editor.defaultFormatter" = "esbenp.prettier-vscode";
              };
              "workbench.editor.enablePreview" = false;
              "githubPullRequests.remotes" = [
                "origin"
              ];
              "[python]" = {
                "editor.formatOnType" = true;
                "editor.defaultFormatter" = "charliermarsh.ruff";
              };
              "[rust]" = {
                "editor.defaultFormatter" = "rust-lang.rust-analyzer";
              };
              "haskell.manageHLS" = "GHCup";
              "[html]" = {
                "editor.defaultFormatter" = "vscode.html-language-features";
              };
              "notebook.output.scrolling" = true;
              "notebook.globalToolbar" = false;
              "haskell.upgradeGHCup" = false;
              "editor.unicodeHighlight.ambiguousCharacters" = false;
              "[solidity]" = {
                "editor.defaultFormatter" = "NomicFoundation.hardhat-solidity";
              };
              "telemetry.telemetryLevel" = "crash";
              "editor.inlineSuggest.suppressSuggestions" = true;
              "jest.autoRun" = "off";
              "window.commandCenter" = false;
              "[haskell]" = {
                "editor.defaultFormatter" = "haskell.haskell";
              };
              "settingsSync.ignoredExtensions" = [
                "vspacecode.vspacecode"
              ];
              "workbench.layoutControl.enabled" = false;
              # "apc.electron" = {
              #   "frame" = false;
              # };
              "window.titleBarStyle" = "native";
              "window.customTitleBarVisibility" = "never";
              "editor.minimap.renderCharacters" = false;
              "editor.minimap.enabled" = false;
              "editor.scrollbar.horizontal" = "hidden";
              "editor.scrollbar.vertical" = "hidden";
              "cSpell.diagnosticLevel" = "Hint";
              "editor.overviewRulerBorder" = false;
              "editor.glyphMargin" = false;
              "extensions.experimental.affinity" = {
                "HyunggyuJang.vim-with-killring" = 1;
              };
              "editor.lineDecorationsWidth" = 0;
              "editor.overviewRulerLanes" = 0;
              "editor.hideCursorInOverviewRuler" = true;
              "testing.gutterEnabled" = false;
              "editor.renderLineHighlight" = "none";
              "vspacecode.bindingOverrides" = [
                {
                  "keys" = [
                    "m"
                    "languageId:typescriptreact"
                  ];
                  "name" = "+Major";
                  "icon" = "code";
                  "type" = "bindings";
                  "bindings" = [
                    {
                      "key" = "g";
                      "name" = "+Goto";
                      "icon" = "go-to-file";
                      "type" = "bindings";
                      "bindings" = [
                        {
                          "key" = "d";
                          "name" = "Go to definition";
                          "icon" = "symbol-function";
                          "type" = "command";
                          "command" = "editor.action.revealDefinition";
                        }
                        {
                          "key" = "h";
                          "name" = "Show call hierarchy";
                          "icon" = "type-hierarchy";
                          "type" = "command";
                          "command" = "references-view.showCallHierarchy";
                        }
                        {
                          "key" = "i";
                          "name" = "Go to implementations";
                          "icon" = "symbol-module";
                          "type" = "command";
                          "command" = "editor.action.goToImplementation";
                        }
                        {
                          "key" = "r";
                          "name" = "Go to references";
                          "icon" = "symbol-reference";
                          "type" = "command";
                          "command" = "editor.action.goToReferences";
                        }
                        {
                          "key" = "s";
                          "name" = "Go to symbol in buffer";
                          "icon" = "file";
                          "type" = "command";
                          "command" = "workbench.action.gotoSymbol";
                        }
                        {
                          "key" = "t";
                          "name" = "Go to type definition";
                          "icon" = "symbol-struct";
                          "type" = "command";
                          "command" = "editor.action.goToTypeDefinition";
                        }
                        {
                          "key" = "I";
                          "name" = "Find implementations";
                          "icon" = "symbol-module";
                          "type" = "command";
                          "command" = "references-view.findImplementations";
                        }
                        {
                          "key" = "R";
                          "name" = "Find references";
                          "icon" = "symbol-reference";
                          "type" = "command";
                          "command" = "references-view.findReferences";
                        }
                        {
                          "key" = "S";
                          "name" = "Go to symbol in project";
                          "icon" = "project";
                          "type" = "command";
                          "command" = "workbench.action.showAllSymbols";
                        }
                        {
                          "key" = "t";
                          "name" = "Go to type definition";
                          "icon" = "symbol-struct";
                          "type" = "command";
                          "command" = "editor.action.goToTypeDefinition";
                        }
                      ];
                    }
                    {
                      "key" = "G";
                      "name" = "+Peek";
                      "icon" = "eye";
                      "type" = "bindings";
                      "bindings" = [
                        {
                          "key" = "d";
                          "name" = "Peek definition";
                          "icon" = "symbol-function";
                          "type" = "command";
                          "command" = "editor.action.peekDefinition";
                        }
                        {
                          "key" = "h";
                          "name" = "Peek call hierarchy";
                          "icon" = "type-hierarchy";
                          "type" = "command";
                          "command" = "editor.showCallHierarchy";
                        }
                        {
                          "key" = "i";
                          "name" = "Peek implementations";
                          "icon" = "symbol-module";
                          "type" = "command";
                          "command" = "editor.action.peekImplementation";
                        }
                        {
                          "key" = "r";
                          "name" = "Peek references";
                          "icon" = "symbol-reference";
                          "type" = "command";
                          "command" = "editor.action.referenceSearch.trigger";
                        }
                      ];
                    }
                  ];
                }
                {
                  "keys" = [
                    "m"
                    "languageId:haskell"
                  ];
                  "name" = "+Major";
                  "icon" = "code";
                  "type" = "bindings";
                  "bindings" = [
                    {
                      "key" = "g";
                      "name" = "+Goto";
                      "icon" = "go-to-file";
                      "type" = "bindings";
                      "bindings" = [
                        {
                          "key" = "d";
                          "name" = "Go to definition";
                          "icon" = "symbol-function";
                          "type" = "command";
                          "command" = "editor.action.revealDefinition";
                        }
                        {
                          "key" = "h";
                          "name" = "Show call hierarchy";
                          "icon" = "type-hierarchy";
                          "type" = "command";
                          "command" = "references-view.showCallHierarchy";
                        }
                        {
                          "key" = "i";
                          "name" = "Go to implementations";
                          "icon" = "symbol-module";
                          "type" = "command";
                          "command" = "editor.action.goToImplementation";
                        }
                        {
                          "key" = "r";
                          "name" = "Go to references";
                          "icon" = "symbol-reference";
                          "type" = "command";
                          "command" = "editor.action.goToReferences";
                        }
                        {
                          "key" = "s";
                          "name" = "Go to symbol in buffer";
                          "icon" = "file";
                          "type" = "command";
                          "command" = "workbench.action.gotoSymbol";
                        }
                        {
                          "key" = "t";
                          "name" = "Go to type definition";
                          "icon" = "symbol-struct";
                          "type" = "command";
                          "command" = "editor.action.goToTypeDefinition";
                        }
                        {
                          "key" = "I";
                          "name" = "Find implementations";
                          "icon" = "symbol-module";
                          "type" = "command";
                          "command" = "references-view.findImplementations";
                        }
                        {
                          "key" = "R";
                          "name" = "Find references";
                          "icon" = "symbol-reference";
                          "type" = "command";
                          "command" = "references-view.findReferences";
                        }
                        {
                          "key" = "S";
                          "name" = "Go to symbol in project";
                          "icon" = "project";
                          "type" = "command";
                          "command" = "workbench.action.showAllSymbols";
                        }
                        {
                          "key" = "t";
                          "name" = "Go to type definition";
                          "icon" = "symbol-struct";
                          "type" = "command";
                          "command" = "editor.action.goToTypeDefinition";
                        }
                      ];
                    }
                    {
                      "key" = "G";
                      "name" = "+Peek";
                      "icon" = "eye";
                      "type" = "bindings";
                      "bindings" = [
                        {
                          "key" = "d";
                          "name" = "Peek definition";
                          "icon" = "symbol-function";
                          "type" = "command";
                          "command" = "editor.action.peekDefinition";
                        }
                        {
                          "key" = "h";
                          "name" = "Peek call hierarchy";
                          "icon" = "type-hierarchy";
                          "type" = "command";
                          "command" = "editor.showCallHierarchy";
                        }
                        {
                          "key" = "i";
                          "name" = "Peek implementations";
                          "icon" = "symbol-module";
                          "type" = "command";
                          "command" = "editor.action.peekImplementation";
                        }
                        {
                          "key" = "r";
                          "name" = "Peek references";
                          "icon" = "symbol-reference";
                          "type" = "command";
                          "command" = "editor.action.referenceSearch.trigger";
                        }
                      ];
                    }
                  ];
                }
                {
                  "keys" = [
                    "m"
                    "languageId:python"
                    "g"
                    "t"
                  ];
                  "name" = "Go to type definition";
                  "icon" = "symbol-struct";
                  "type" = "command";
                  "command" = "editor.action.goToTypeDefinition";
                }
                {
                  "keys" = [
                    "m"
                    "languageId:python"
                    "G"
                    "t"
                  ];
                  "name" = "Peek type definition";
                  "icon" = "symbol-struct";
                  "type" = "command";
                  "command" = "editor.action.peekTypeDefinition";
                }
                {
                  "keys" = [
                    "T"
                    "T"
                  ];
                  "name" = "Toggle tab visibility";
                  "icon" = "files";
                  "type" = "conditional";
                  "bindings" = [
                    {
                      "key" = "";
                      "name" = "Show tab bar";
                      "type" = "command";
                      "command" = "workbench.action.hideEditorTabs";
                    }
                    {
                      "key" = "when:config.workbench.editor.showTabs === 'none'";
                      "name" = "Show tab bar";
                      "type" = "command";
                      "command" = "workbench.action.showEditorTab";
                    }
                  ];
                }
                {
                  "keys" = [
                    "T"
                    "t"
                  ];
                  "name" = "Toggle tool/activity bar visibility";
                  "icon" = "tools";
                  "type" = "conditional";
                  "bindings" = [
                    {
                      "key" = "";
                      "name" = "Hide activity bar";
                      "type" = "command";
                      "command" = "workbench.action.activityBarLocation.hide";
                    }
                    {
                      "key" = "when:config.workbench.activityBar.location === 'hidden'";
                      "name" = "Show activity bar";
                      "type" = "command";
                      "command" = "workbench.action.focusActivityBar";
                    }
                  ];
                }
                {
                  "keys" = [
                    "T"
                    "S"
                  ];
                  "name" = "Toggle status bar visibility";
                  "icon" = "layout-statusbar";
                  "type" = "command";
                  "command" = "workbench.action.toggleStatusbarVisibility";
                }
              ];
              "window.density.editorTabHeight" = "compact";
              "workbench.editor.tabCloseButton" = "off";
              "workbench.editor.tabSizing" = "shrink";
              "workbench.editor.tabSizingFixedMinWidth" = 38;
              "workbench.editor.showTabs" = "single";
              "haskell.trace.server" = "verbose";
              "editor.folding" = false;
              "github.copilot.advanced" = {
                "debug.overrideLogLevels" = {
                  "*" = "DEBUG";
                };
                "fix.useGPT4InInlineChat" = true;
                "conversationLoggingEnabled" = true;
                "workspace.useNewFlow" = true;
                "workspace.codeSearchEnabled" = true;
                "workspace.useAda" = true;
                "slashCommands" = {
                  "*" = true;
                };
                # "debug.overrideEngine" = "gpt-4-0125-preview";
              };
              "workbench.activityBar.location" = "hidden";
              "githubPullRequests.pullBranch" = "never";
              "workbench.editor.tabActionCloseVisibility" = false;
              "githubIssues.queries" = [
                {
                  "label" = "My Issues";
                  "query" = "default";
                }
                {
                  "label" = "Created Issues";
                  "query" = "author:$${user} state:open repo:$${owner}/$${repository} sort:created-desc";
                }
                {
                  "label" = "Recent Issues";
                  "query" = "state:open repo:$${owner}/$${repository} sort:updated-desc";
                }
              ];
              "workbench.startupEditor" = "none";
              "github.copilot.enable" = {
                "plaintext" = "true";
                "markdown" = "true";
                "scminput" = "true";
              };
              "window.autoDetectColorScheme" = true;
              "nix.enableLanguageServer" = true;
              "nix.serverPath" = "nixd";
              "editor.defaultFormatter" = "esbenp.prettier-vscode";
              "[nix]" = {
                "editor.defaultFormatter" = "jnoortheen.nix-ide";
              };
              "github.copilot.editor.enableAutoCompletions" = true;
              "redhat.telemetry.enabled" = false;
            };
            keybindings = [
              {
                key = "g g";
                command = "cursorTop";
                when = "editorTextFocus && editorLangId == 'magit' && vim.mode =~ /^(?!SearchInProgressMode|CommandlineInProgress).*$/";
              }
              {
                key = "g r";
                command = "magit.refresh";
                when = "editorTextFocus && editorLangId == 'magit' && vim.mode =~ /^(?!SearchInProgressMode|CommandlineInProgress).*$/";
              }
              {
                key = "tab";
                command = "-extension.vim_tab";
                when = "editorTextFocus && vim.active && !inDebugRepl && vim.mode != 'Insert'";
              }
              {
                key = "tab";
                command = "extension.vim_tab";
                when = "editorTextFocus && vim.active && !inDebugRepl && vim.mode != 'Insert' && editorLangId != 'magit'";
              }
              {
                key = "x";
                command = "magit.discard-at-point";
                when = "editorTextFocus && editorLangId == 'magit' && vim.mode =~ /^(?!SearchInProgressMode|CommandlineInProgress).*$/";
              }
              {
                key = "k";
                command = "-magit.discard-at-point";
              }
              {
                key = "-";
                command = "magit.reverse-at-point";
                when = "editorTextFocus && editorLangId == 'magit' && vim.mode =~ /^(?!SearchInProgressMode|CommandlineInProgress).*$/";
              }
              {
                key = "v";
                command = "-magit.reverse-at-point";
              }
              {
                key = "shift+-";
                command = "magit.reverting";
                when = "editorTextFocus && editorLangId == 'magit' && vim.mode =~ /^(?!SearchInProgressMode|CommandlineInProgress).*$/";
              }
              {
                key = "shift+v";
                command = "-magit.reverting";
              }
              {
                key = "shift+o";
                command = "magit.resetting";
                when = "editorTextFocus && editorLangId == 'magit' && vim.mode =~ /^(?!SearchInProgressMode|CommandlineInProgress).*$/";
              }
              {
                key = "shift+x";
                command = "-magit.resetting";
              }
              {
                key = "x";
                command = "-magit.reset-mixed";
              }
              {
                key = "ctrl+u x";
                command = "-magit.reset-hard";
              }
              {
                key = "ctrl+t";
                command = "-extension.vim_ctrl+t";
                when = "editorTextFocus && vim.active && vim.use<C-t> && !inDebugRepl";
              }
              {
                key = "alt+l";
                command = "editor.action.transformToLowercase";
              }
              {
                key = "alt+u";
                command = "editor.action.transformToUppercase";
              }
              {
                key = "alt+c";
                command = "editor.action.transformToTitlecase";
              }
              {
                key = "cmd+k tab";
                command = "editor.action.insertSnippet";
              }
              {
                key = "alt+w";
                command = "workbench.action.switchWindow";
              }
              {
                key = "ctrl+w";
                command = "-workbench.action.switchWindow";
              }
              {
                key = "alt+space";
                command = "vspacecode.space";
                when = "!whichkeyActive";
              }
              {
                key = "alt+f";
                command = "cursorWordRight";
                when = "editorTextFocus && vim.active && vim.mode == 'Insert' || textInputFocus";
              }
              {
                key = "ctrl+alt+f";
                command = "cursorWordPartRight";
                when = "editorTextFocus && vim.active && vim.mode == 'Insert' || textInputFocus";
              }
              {
                key = "alt+f";
                command = "extension.vim_ctrl+right";
                when = "editorTextFocus && vim.active && !inDebugRepl && vim.mode =~ /^(CommandlineInProgress|SearchInProgressMode)$/";
              }
              {
                key = "alt+b";
                command = "cursorWordLeft";
                when = "editorTextFocus && vim.active && vim.mode == 'Insert' || textInputFocus";
              }
              {
                key = "ctrl+alt+b";
                command = "cursorWordPartLeft";
                when = "editorTextFocus && vim.active && vim.mode == 'Insert' || textInputFocus";
              }
              {
                key = "alt+b";
                command = "extension.vim_ctrl+left";
                when = "editorTextFocus && vim.active && !inDebugRepl && vim.mode =~ /^(CommandlineInProgress|SearchInProgressMode)$/";
              }
              {
                key = "ctrl+k";
                command = "extension.vim_ctrl+k";
                when = "editorTextFocus && vim.active && vim.use<C-k> && vim.mode != 'Insert' && !inDebugRepl";
              }
              {
                key = "ctrl+k";
                command = "-extension.vim_ctrl+k";
                when = "editorTextFocus && vim.active && vim.use<C-k> && !inDebugRepl";
              }
              {
                key = "ctrl+d";
                command = "extension.vim_ctrl+d";
                when = "editorTextFocus && vim.active && vim.use<C-d> && vim.mode != 'Insert' && !inDebugRepl";
              }
              {
                key = "ctrl+d";
                command = "-extension.vim_ctrl+d";
                when = "editorTextFocus && vim.active && vim.use<C-d> && !inDebugRepl";
              }
              {
                key = "ctrl+a";
                command = "extension.vim_ctrl+a";
                when = "editorTextFocus && vim.active && vim.use<C-a> && vim.mode != 'Insert' && !inDebugRepl";
              }
              {
                key = "ctrl+a";
                command = "-extension.vim_ctrl+a";
                when = "editorTextFocus && vim.active && vim.use<C-a> && !inDebugRepl";
              }
              {
                key = "ctrl+e";
                command = "extension.vim_ctrl+e";
                when = "editorTextFocus && vim.active && vim.use<C-e> && vim.mode != 'Insert' && !inDebugRepl";
              }
              {
                key = "ctrl+e";
                command = "-extension.vim_ctrl+e";
                when = "editorTextFocus && vim.active && vim.use<C-e> && !inDebugRepl";
              }
              {
                key = "alt+d";
                command = "deleteWordRight";
                when = "editorTextFocus && vim.active && vim.mode == 'Insert' || textInputFocus";
              }
              {
                key = "ctrl+alt+d";
                command = "deleteWordPartRight";
                when = "editorTextFocus && vim.active && vim.mode == 'Insert' || textInputFocus";
              }
              {
                key = "alt+d";
                command = "vim.remap";
                when = "editorTextFocus && vim.active && !inDebugRepl && vim.mode =~ /^(CommandlineInProgress|SearchInProgressMode)$/";
                args = {
                  after = [ "<C-Right>" "<C-w>" ];
                };
              }
              {
                key = "alt+b";
                command = "workbench.action.terminal.sendSequence";
                when = "terminalFocus && !terminalTextSelected";
                args = {
                  text = "[1;5D";
                };
              }
              {
                key = "alt+f";
                command = "workbench.action.terminal.sendSequence";
                when = "terminalFocus && !terminalTextSelected";
                args = {
                  text = "[1;5C";
                };
              }
              {
                key = "alt+d";
                command = "workbench.action.terminal.sendSequence";
                when = "terminalFocus && !terminalTextSelected";
                args = {
                  text = "d";
                };
              }
              {
                key = "alt+r";
                command = "workbench.action.terminal.sendSequence";
                when = "terminalFocus && !terminalTextSelected";
                args = {
                  text = "r";
                };
              }
              {
                key = "alt+t";
                command = "workbench.action.terminal.sendSequence";
                when = "terminalFocus && !terminalTextSelected";
                args = {
                  text = "t";
                };
              }
              {
                key = "alt+c";
                command = "workbench.action.terminal.sendSequence";
                when = "terminalFocus && !terminalTextSelected";
                args = {
                  text = "c";
                };
              }
              {
                key = "space";
                command = "vspacecode.space";
                when = "activeEditorGroupEmpty && focusedView == '' && !whichkeyActive && !inputFocus";
              }
              {
                key = "space";
                command = "vspacecode.space";
                when = "sideBarFocus && !inputFocus && !whichkeyActive";
              }
              {
                key = "y";
                command = "-magit.show-refs";
              }
              {
                key = "y";
                command = "vspacecode.showMagitRefMenu";
                when = "editorTextFocus && editorLangId == 'magit' && vim.mode == 'Normal'";
              }
              {
                key = "ctrl+h";
                command = "file-browser.stepOut";
                when = "inFileBrowser";
              }
              {
                key = "ctrl+l";
                command = "file-browser.stepIn";
                when = "inFileBrowser";
              }
              {
                key = "ctrl+l";
                command = "acceptSelectedSuggestion";
                when = "suggestWidgetMultipleSuggestions && suggestWidgetVisible && textInputFocus";
              }
              {
                key = "ctrl+d";
                command = "deleteRight";
                when = "textInputFocus && (vim.mode == 'Insert' || !vim.active)";
              }
              {
                key = "ctrl+d";
                command = "-deleteRight";
                when = "textInputFocus";
              }
              {
                key = "ctrl+h";
                command = "-deleteLeft";
                when = "textInputFocus";
              }
              {
                key = "shift+t";
                command = "whichkey.triggerKey";
                when = "whichkeyVisible && config.workbench.editor.showTabs === 'none'";
                args = {
                  key = "T";
                };
              }
              {
                key = "shift+t";
                command = "whichkey.triggerKey";
                when = "whichkeyVisible && config.workbench.activityBar.location === 'hidden'";
                args = {
                  key = "T";
                };
              }
              {
                key = "shift+l";
                command = "breadcrumbs.focusNext";
                when = "breadcrumbsActive && breadcrumbsVisible";
              }
              {
                key = "alt+right";
                command = "-breadcrumbs.focusNext";
                when = "breadcrumbsActive && breadcrumbsVisible";
              }
              {
                key = "shift+h";
                command = "breadcrumbs.focusPrevious";
                when = "breadcrumbsActive && breadcrumbsVisible";
              }
              {
                key = "left";
                command = "-breadcrumbs.focusPrevious";
                when = "breadcrumbsActive && breadcrumbsVisible";
              }
              {
                key = "ctrl+g";
                command = "-workbench.action.gotoLine";
              }
            ];
          };
          zsh = {
            enable = true;
            autosuggestion.enable = true;
            enableCompletion =
              false; # See https://github.com/NixOS/nix/issues/5445
            defaultKeymap = "emacs";
            sessionVariables = { RPROMPT = ""; };
            shellAliases = {
              dbuild =
                "cd ${hgj_darwin_home} && HOSTNAME=${localconfig.hostname} TERM=xterm-256color make && cd -";
              dswitch =
                "cd ${hgj_darwin_home} && HOSTNAME=${localconfig.hostname} TERM=xterm-256color caffeinate -i make switch && cd -";
              drb =
                "cd ${hgj_darwin_home} && HOSTNAME=${localconfig.hostname} TERM=xterm-256color make rollback && cd -";
            };

            oh-my-zsh.enable = true;

            plugins = [
              {
                name = "autopair";
                file = "autopair.zsh";
                src = pkgs.fetchFromGitHub {
                  owner = "hlissner";
                  repo = "zsh-autopair";
                  rev = "9d003fc02dbaa6db06e6b12e8c271398478e0b5d";
                  sha256 = "sha256-hwZDbVo50kObLQxCa/wOZImjlH4ZaUI5W5eWs/2RnWg=";
                };
              }
              {
                name = "fast-syntax-highlighting";
                file = "fast-syntax-highlighting.plugin.zsh";
                src = pkgs.fetchFromGitHub {
                  owner = "zdharma-continuum";
                  repo = "fast-syntax-highlighting";
                  rev = "585c089968caa1c904cbe926ff04a1be9e3d8f42";
                  sha256 = "sha256-x+4C2u03RueNo6/ZXsueqmYoPIpDHnKAZXP5IiKsidE=";
                };
              }
              {
                name = "z";
                file = "zsh-z.plugin.zsh";
                src = pkgs.fetchFromGitHub {
                  owner = "agkozak";
                  repo = "zsh-z";
                  rev = "b30bc6050e77abe30ce36761d18ed696e5410f16";
                  sha256 = "sha256-TSX6KooWYGf1NDlD4A3o6CmSsyy1JL7bPeKsuCOuUhY=";
                };
              }
              rec {
                name = "system-wide-clipboard";
                file = "system-wide-clipboard.zsh";
                src = pkgs.stdenv.mkDerivation rec {
                  name = "system-wide-clipboard";
                  src = pkgs.fetchurl {
                    name = "system-wide-clipboard.zsh";
                    url =
                      "https://gist.githubusercontent.com/HyunggyuJang/850b22128515b257ff3da73b589d7d3b/raw/3660504d2874a46a048b291a8ceabe8af9778294/system-wide-clipboard.zsh";
                    sha256 =
                      "sha256-fmLcHhD2Cb45OEmIQi8mp9Q1uid1Osy9/kFxelHp70Y=";
                  };

                  phases = "installPhase";

                  installPhase = ''
                    mkdir -p $out
                    cp ${src} $out/${file}
                  '';
                };
              }
            ];
            initExtraBeforeCompInit = ''
              if [[ $INSIDE_EMACS != vterm && $TERM_PROGRAM != vscode ]]; then
                  echo >&2 "Homebrew completion path..."
                  if [ -f ${brewpath}/bin/brew ]; then
                      PATH=${brewpath}/bin:$PATH fpath+=$(brew --prefix)/share/zsh/site-functions
                  else
                      echo -e "\e[1;31merror: Homebrew is not installed, skipping...\e[0m" >&2
                  fi
              fi
            '';
            initExtra = ''
              PROMPT=' %{$fg_bold[blue]%}$(get_pwd)%{$reset_color%} ''${prompt_suffix}'
              local prompt_suffix="%(?:%{$fg_bold[green]%}❯ :%{$fg_bold[red]%}❯%{$reset_color%} "

              function get_pwd(){
                  git_root=$PWD
                  while [[ $git_root != / && ! -e $git_root/.git ]]; do
                      git_root=$git_root:h
                  done
                  if [[ $git_root = / ]]; then
                      unset git_root
                      prompt_short_dir=%~
                  else
                      parent=''${git_root%\/*}
                      prompt_short_dir=''${PWD#$parent/}
                  fi
                  echo $prompt_short_dir
                                          }

              vterm_printf(){
                  if [ -n "$TMUX" ]; then
                      # Tell tmux to pass the escape sequences through
                      # (Source: http://permalink.gmane.org/gmane.comp.terminal-emulators.tmux.user/1324)
                      printf "\ePtmux;\e\e]%s\007\e\\" "$1"
                  elif [ "''${TERM%%-*}" = "screen" ]; then
                      # GNU screen (screen, screen-256color, screen-256color-bce)
                      printf "\eP\e]%s\007\e\\" "$1"
                  else
                      printf "\e]%s\e\\" "$1"
                  fi
                                                                                      }

              if ! whence nvm; then
                  export NVM_DIR="$HOME/.nvm"
                  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && . "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
                  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && . "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion
              fi
            '';
          };
          direnv = {
            enable = true;
            enableZshIntegration = true; # see note on other shells below
            nix-direnv.enable = true;
          };
          emacs = {
            enable = true;
            package = pkgs.emacs;
            extraPackages = (epkgs: [ epkgs.vterm ]);
          };
        };

        programs.fzf.enable = true;
        programs.fzf.enableZshIntegration = true;
        programs.browserpass.enable = true;
        programs.browserpass.browsers = [ "firefox" ];
        programs.firefox.enable = true;
        programs.firefox.package = pkgs.firefox-darwin;
        programs.firefox.profiles = {
          home = {
            id = 0;
            settings = {
              "app.update.auto" = false;
              "browser.startup.homepage" = "https://start.duckduckgo.com";
              "browser.search.region" = "KR";
              "browser.search.countryCode" = "KR";
              "browser.search.isUS" = true;
              "browser.ctrlTab.recentlyUsedOrder" = false;
              "browser.newtabpage.enabled" = false;
              "browser.bookmarks.showMobileBookmarks" = true;
              "browser.uidensity" = 1;
              "browser.urlbar.placeholderName" = "DuckDuckGo";
              "browser.urlbar.update1" = true;
              "distribution.searchplugins.defaultLocale" = "en-KR";
              "general.useragent.locale" = "en-KR";
              "identity.fxaccounts.account.device.name" = localconfig.hostname;
              "privacy.trackingprotection.enabled" = true;
              "privacy.trackingprotection.socialtracking.enabled" = true;
              "privacy.trackingprotection.socialtracking.annotate.enabled" = true;
              "reader.color_scheme" = "sepia";
              "services.sync.declinedEngines" = "addons,passwords,prefs";
              "services.sync.engine.addons" = false;
              "services.sync.engineStatusChanged.addons" = true;
              "services.sync.engine.passwords" = false;
              "services.sync.engine.prefs" = false;
              "services.sync.engineStatusChanged.prefs" = true;
              "signon.rememberSignons" = false;
              "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
            };
            userChrome = builtins.readFile ./userChrome.css;
            extensions = with nur.repos.rycee.firefox-addons; [
              ublock-origin
              browserpass
              tridactyl
              darkreader
              # For work with kazuki
              metamask
              # Need to add zotero-connector
              # -> there is no official extension registered in the mozilla's store.
              # Let's use edge's for now.

              # Recommended by Lechuck
              # multi-account-containers
            ];
          };
        };
      };
    in
      { ${owner} = userconfig; };
  system.stateVersion = 5;
  system.defaults = {
    dock = {
      orientation = "left";
      autohide = true;
      launchanim = false;
      show-process-indicators = true;
      show-recents = false;
      static-only = true;
      mru-spaces = false;
      minimize-to-application = true;
    };

    spaces.spans-displays = false;

    finder = {
      AppleShowAllExtensions = true;
      FXEnableExtensionChangeWarning = false;
      CreateDesktop = false;
      FXPreferredViewStyle = "Nlsv"; # list view
      ShowPathbar = true;
    };

    loginwindow.GuestEnabled = false;

    CustomUserPreferences = {
      # Finder's default location upon open
      "com.apple.finder" = {
        NewWindowTargetPath =
          let homePath = config.users.users.${owner}.home;
          in "file://${homePath}/";
        ShowHardDrivesOnDesktop = false;
        ShowMountedServersOnDesktop = true;
        ShowRemovableMediaOnDesktop = true;
        _FXSortFoldersFirst = true;
        # When performing a search, search the current folder by default
        FXDefaultSearchScope = "SCcf";
      };
      "com.apple.desktopservices" = {
        # Avoid creating .DS_Store files on network or USB volumes
        DSDontWriteNetworkStores = true;
        DSDontWriteUSBStores = true;
      };
      "com.apple.AdLib" = {
        allowApplePersonalizedAdvertising = false;
      };
      # Prevent Photos from opening automatically when devices are plugged in
      "com.apple.ImageCapture".disableHotPlug = true;
      "com.apple.SoftwareUpdate" = {
        AutomaticCheckEnabled = true;
        # Check for software updates daily, not just once per week
        ScheduleFrequency = 1;
        # Do not download newly available updates in background
        AutomaticDownload = 0;
        # Install System data files & security updates
        CriticalUpdateInstall = 1;
      };
      "com.apple.TimeMachine".DoNotOfferNewDisksForBackup = true;
    };

    NSGlobalDomain = {
      ApplePressAndHoldEnabled = false;
      AppleKeyboardUIMode = 3;
      AppleShowScrollBars = "WhenScrolling";
      AppleInterfaceStyleSwitchesAutomatically = true;
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;
      NSScrollAnimationEnabled = false;
      NSUseAnimatedFocusRing = false;
      NSTextShowsControlCharacters = true;
      NSNavPanelExpandedStateForSaveMode = true;
      NSNavPanelExpandedStateForSaveMode2 = true;
      NSTableViewDefaultSizeMode = 1;
      _HIHideMenuBar = true;
      "com.apple.mouse.tapBehavior" = 1;
      "com.apple.trackpad.forceClick" = true;
      "com.apple.swipescrolldirection" = true;
      "com.apple.trackpad.trackpadCornerClickBehavior" = null;
      "com.apple.keyboard.fnState" = true;
    };
  };
  users = {
    users.${owner} = {
      name = owner;
      home = hgj_home;
      shell = pkgs.zsh;
    };
  };
  fonts = {
    packages = [ pkgs.ibm-plex ];
  };
  environment = {
    darwinConfig = "${hgj_darwin_home}/configuration.nix";
    variables = {
      EDITOR = "emacsclient --alternate-editor='open -a Emacs'";
      VISUAL = "$EDITOR";
      LANG = "en_US.UTF-8";
      DOOMDIR = "${hgj_home}/notes/org/manager";
      EMACSDIR = "${hgj_home}/.emacs.d";
      DOOMLOCALDIR = "${hgj_home}/.doom";
      SHELL = "${pkgs.zsh}/bin/zsh";
      # LIBGS = "/opt/homebrew/lib/libgs.dylib"; # For tikz's latex preview.
      PAPERSPACE_INSTALL = "${hgj_home}/.paperspace";
    };
    systemPath = [
      "$HOME/${hgj_localbin}"
      # Easy access to Doom
      # SystemPath added before to the variables, it can be inspected at /etc/static/zshenv,
      # which source *-set-environment file.
      "${environment.variables.EMACSDIR}/bin"
      "${brewpath}/bin"
      # rust
      "$HOME/.cargo/bin"
      # ruby
      "$HOME/.rbenv/shims"
      # Haskell
      "$HOME/.ghcup/bin"
      "$HOME/.cabal/bin"
      # go
      "$HOME/go/bin"
      # Paperspace
      "${environment.variables.PAPERSPACE_INSTALL}/bin"
    ];
    systemPackages = with pkgs; [
      nixpkgs-fmt
      yaskkserv2
      skhd
      shellcheck
      solc-select
      tree-sitter
      llvm
      # WASM
      rustup
      pandoc
      openssl
      # Mail
      # lieer # Curretly installed manually by cloning the repo as instructed: https://afew.readthedocs.io/en/latest/installation.html
      # afew # Currently installed using pip3 install afew
      # Latex
      (texlive.combine {
        # https://gist.github.com/veprbl/3dc563802c97a95bcdc4eac6650ede7d
        inherit (texlive)
          scheme-medium zxjatype ctex biblatex tikz-cd xpatch cleveref svg
          trimspaces catchfile transparent capt-of enumitem fvextra upquote
          tcolorbox environ pdfcol nanumtype1 kotex-plain kotex-utf kotex-utils xetexko
          # jupyter export
          adjustbox standalone algorithm2e ifoddpage relsize wrapfig
          beamertheme-metropolis pdfx xmpincl accsupp fontawesome5 tikzfill
          tikzmark dashrule ifmtarg multirow changepage paracol titling;
        altacv = { pkgs = [ altacv ]; };
      })
      biber
      # OutsideIn(X)
      # ↓ Installed from ghcup
      # cabal-install
      # ghc
      ffmpeg-headless
      # sourcegraph
      nodePackages_latest.pnpm
      imagemagick
      # scop
      poetry

      # nix lsp
      nixd

      # System inspector & cleaner
      dua

      tree-sitter
      msmtp
      (aspellWithDicts (dicts: with dicts; [ en ]))
      jq
      pngpaste
      zstd
      isync
      ripgrep
      git
      gnupg
      pass
      gmp
      coreutils
      fd
      poppler
      pinentry_mac
      findutils
      cmake
      automake
      ctags
      sdcv
      notmuch
      libusb
    ];
    pathsToLink = [ "/lib" ];
    shells = [ pkgs.zsh ];
  };

  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config.allowUnfree = true;

  nixpkgs.overlays =
    let
      path = ../overlays;
    in with builtins;
      let
        localOverlays = map (n: import (path + ("/" + n))) (filter
          (n:
            match ".*\\.nix" n != null
            || pathExists (path + ("/" + n + "/default.nix")))
          (attrNames (readDir path)));
      in [ inputs.nixpkgs-firefox-darwin.overlay ] ++ localOverlays;

  programs = {
    zsh = {
      enable = true;
      enableCompletion = false;
      enableBashCompletion = false;
    };
  };
  services = {
    nix-daemon.enable = true;
    yabai = {
      enable = true;
      config = {
        active_window_opacity = 1.0;
        auto_balance = "on";
        bottom_padding = 0;
        focus_follows_mouse = "off";
        layout = "bsp";
        left_padding = 0;
        mouse_action1 = "move";
        mouse_action2 = "resize";
        mouse_follows_focus = "off";
        mouse_modifier = "fn";
        normal_window_opacity = 0.9;
        right_padding = 0;
        split_ratio = 0.5;
        top_padding = 0;
        window_border = "off";
        window_gap = 0;
        window_opacity = "on";
        window_opacity_duration = 0.0;
        window_placement = "second_child";
        window_shadow = "off";
        window_topmost = "on";
      };
      extraConfig = ''
        yabai -m rule --add app="^System Preferences$" manage=off
        yabai -m rule --add app="Inkscape" title!=" - Inkscape$" manage=off
        yabai -m rule --add app=AquaSKK manage=off
        yabai -m rule --add app=Emacs title="Emacs Everywhere ::" manage=off
        yabai -m rule --add app=Anki space=3
        yabai -m rule --add app="^Microsoft Teams$" space=4
        yabai -m rule --add app="^zoom$" space=4
      '';
    };
    skhd = {
      enable = true;
      skhdConfig = ''
        ################################################################################
        #
        # window manipulation
        #

        # ^ = 0x16
        ctrl + cmd - 6 : yabai -m window --focus recent
        ctrl + cmd - h : yabai -m window --focus west || yabai -m display --focus west
        ctrl + cmd - j : yabai -m window --focus south || yabai -m display --focus south
        ctrl + cmd - k : yabai -m window --focus north || yabai -m display --focus north
        ctrl + cmd - l : yabai -m window --focus east || yabai -m display --focus east
        ctrl + cmd + shift - 6 : WIN_ID=$(yabai -m query --windows --window | jq '.id') && yabai -m window --display recent && yabai -m window --focus $WIN_ID
        ctrl + cmd + shift - h : WIN_ID=$(yabai -m query --windows --window | jq '.id') && yabai -m window --display west && yabai -m window --focus $WIN_ID
        ctrl + cmd + shift - j : WIN_ID=$(yabai -m query --windows --window | jq '.id') && yabai -m window --display south && yabai -m window --focus $WIN_ID
        ctrl + cmd + shift - k : WIN_ID=$(yabai -m query --windows --window | jq '.id') && yabai -m window --display north && yabai -m window --focus $WIN_ID
        ctrl + cmd + shift - l : WIN_ID=$(yabai -m query --windows --window | jq '.id') && yabai -m window --display east && yabai -m window --focus $WIN_ID


        ctrl + cmd - r : yabai -m space --rotate 90
        ctrl + cmd + shift - r : yabai -m space --rotate 270

        :: modal @
        :: mywindow @
        :: swap @
        :: warp @
        :: myinsert @

        cmd - space ; modal
        modal < ctrl - g ; default

        modal < j : skhd -k "ctrl - g" ; hs -c "hs.hints.windowHints(hs.window.allWindows(), nil, true)"

        modal < w ; mywindow
        mywindow < ctrl - g ; default

        mywindow < h : yabai -m window west --resize right:-20:0 2> /dev/null || yabai -m window --resize right:-20:0
        mywindow < j : yabai -m window north --resize bottom:0:20 2> /dev/null || yabai -m window --resize bottom:0:20
        mywindow < k : yabai -m window south --resize top:0:-20 2> /dev/null || yabai -m window --resize top:0:-20
        mywindow < l : yabai -m window east --resize left:20:0 2> /dev/null || yabai -m window --resize left:20:0

        mywindow < s ; swap
        swap < ctrl - g ; default

        swap < h : skhd -k "ctrl - g" ; yabai -m window --swap west || WIN_ID=$(yabai -m query --windows --window | jq '.id') && yabai -m display --focus west && yabai -m window --swap $WIN_ID && yabai -m window --focus $WIN_ID
        swap < j : skhd -k "ctrl - g" ; yabai -m window --swap south || WIN_ID=$(yabai -m query --windows --window | jq '.id') && yabai -m display --focus south && yabai -m window --swap $WIN_ID && yabai -m window --focus $WIN_ID
        swap < k : skhd -k "ctrl - g" ; yabai -m window --swap north || WIN_ID=$(yabai -m query --windows --window | jq '.id') && yabai -m display --focus north && yabai -m window --swap $WIN_ID && yabai -m window --focus $WIN_ID
        swap < l : skhd -k "ctrl - g" ; yabai -m window --swap east || WIN_ID=$(yabai -m query --windows --window | jq '.id') && yabai -m display --focus east && yabai -m window --swap $WIN_ID && yabai -m window --focus $WIN_ID

        swap < 0x16 : skhd -k "ctrl - g" ; yabai -m window --swap recent

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

        mywindow < i ; myinsert
        myinsert < ctrl - g ; default

        myinsert < h : yabai -m window --insert west
        myinsert < j : yabai -m window --insert south
        myinsert < k : yabai -m window --insert north
        myinsert < l : yabai -m window --insert east

        ctrl + cmd - return : yabai -m window --toggle zoom-fullscreen

        ################################################################################
        #
        # space manipulation
        #

        # Move currently focused window to the specified space
        ctrl + cmd - 1 : yabai -m window --space 1; skhd -k "cmd - 1"
        ctrl + cmd - 2 : yabai -m window --space 2; skhd -k "cmd - 2"
        ctrl + cmd - 3 : yabai -m window --space 3; skhd -k "cmd - 3"
        ctrl + cmd - 4 : yabai -m window --space 4; skhd -k "cmd - 4"
        ctrl + cmd - 5 : yabai -m window --space 5; skhd -k "cmd - 5"
        ctrl + cmd - 6 : yabai -m window --space 6; skhd -k "cmd - 6"

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
        modal < a ; open
        open < ctrl - g ; default

        # emacs
        open < e : skhd -k "ctrl - g"; open -a Emacs
        open < shift - e : skhd -k "ctrl - g"; DEBUG=1 open -a Emacs

        # kitty or terminal
        open < k : skhd -k "ctrl - g"; open_kitty
        open < shift - k : skhd -k "ctrl - g"; open -a kitty

        # Internet Browser
        open < f : skhd -k "ctrl - g"; open -a Firefox

        open < s : skhd -k "ctrl - g"; open -a Slack

        open < r : skhd -k "ctrl - g"; open -a Zotero

        open < a : skhd -k "ctrl - g"; open -a Anki

        open < z : skhd -k "ctrl - g"; open -a zoom.us

        open < t : skhd -k "ctrl - g"; open -a "Microsoft Teams"

        open < c : skhd -k "ctrl - g"; open -a "Visual Studio Code"

        open < i : skhd -k "ctrl - g"; doom everywhere
      '';
    };
  };
  nix = {
    settings = {
      trusted-users = [ "root" owner ];
      experimental-features = "nix-command flakes";
    };
    package = pkgs.nix;
    nixPath = [{
      darwin = inputs.nix-darwin;
      nixpkgs = inputs.nixpkgs;
      localconfig = "${hgj_darwin_home}/${localconfig.hostname}.nix";
    }];
  };

  homebrew = {
    enable = true;
    onActivation.upgrade = false;
    onActivation.autoUpdate = false;
    onActivation.cleanup = "zap";
    global.brewfile = true;
    brewPrefix = "/opt/homebrew/bin";
    brews = [
      "nvm"
    ];
    casks = [
      "appcleaner"
      "kitty"
      "karabiner-elements"
      # "zoom"
      "zotero"
      # elegant-emacs
      "font-roboto-mono"
      "font-roboto-slab"
      # math font
      "font-dejavu"
      # beamer with xelatex
      "font-fira-sans"
      "font-fira-mono"
      # altacv with xelatex
      "font-lato"
      # Docker
      "docker"
      "obsidian"
      # Storage using Univ Account, but also needed to store images and screen shots from emacs
      "onedrive"
    ] ++ optionals (machineType == "MacBook-Air") [
      "slack"
      # For Bing AI + Google meet
      "microsoft-edge"
      "inkscape"
      # "aquaskk"
      "discord"
      "hammerspoon"
      # zulip
      "vagrant"
      # Data analysis class
      "microsoft-excel"
      # School
      "microsoft-word"
      # audit
      "telegram"
    ] ++ optionals (machineType == "MacBook-Pro") [
      "microsoft-teams"
    ] ++ optionals (machineType == "M3-Pro") [
      "cloudflare-warp"
      "sdm"
    ];
  };
}
