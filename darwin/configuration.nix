{ config ? (import <darwin> {}).config
, pkgs ? import <nixpkgs> { system = builtins.currentSystem; }
, lib ? pkgs.lib
, ... }:

let hgj_home = builtins.getEnv "HOME";
    hgj_sync = hgj_home;
    hgj_darwin_home = "${hgj_sync}/nixpkgs/darwin";
    hgj_localbin = ".local/bin";
    localconfig = import <localconfig>;
    brewpath = if localconfig.hostname == "classic" then "/usr/local"
               else "/opt/homebrew";
    mach-nix = import <mach-nix> {
        inherit pkgs;
        python = "python38";
    };

    nur = import <nur> {
        inherit pkgs;
    };

    myPython = mach-nix.mkPython {
        requirements = ''
        readability-lxml
        octave-kernel
        mathlibtools
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

    shevek = with pkgs; stdenv.mkDerivation {
        name = "shevek";
        src = fetchFromSourcehut {
            owner = "~technomancy";
            repo = "shevek";
            rev = "06b9a6b499b3b876937ead8e58028ed925a60611";
            sha256 = "sha256-1PxaPR0FUo9FH5gyZvOA8+u8+MYkdM5VyErwPetr9Y4=";
        };
        phases = ["unpackPhase" "installPhase"];
        installPhase = ''
        mkdir -p $out
        cp shevek.fnl $out/
      '';
    };

in with lib;
    rec {
        # Home manager
        imports = [ <home-manager/nix-darwin> ];

        home-manager.useGlobalPkgs = true;
        home-manager.users = let userconfig = { config, ...}: rec {
            home.file = {
                #             ".mail/.notmuch/hooks/pre-new" = {
                #                 text = ''
                # #!/bin/bash
                # filter="tag:deleted tag:trash AND folder:/account.nagoya/"
                # echo "$(notmuch count "$filter") trashed messages"
                # notmuch search --output=files --format=text0 "$filter" | ${if localconfig.hostname == "silicon" then "g" else ""}xargs -0 --no-run-if-empty rm
                #             '';
                #                 executable = true;
                #             };
                ".emacs-profiles.el".text = ''
                (("default" . ((user-emacs-directory . "~/test/doom-testbed/doom-emacs")
                               (env . (("EMACSDIR" . "~/test/doom-testbed/doom-emacs")
                                       ("DOOMDIR" . ;"${hgj_sync}/.doom.d"
                                        "~/test/doom-testbed/.doom.d"
                                       )
                                       ("DOOMLOCALDIR" . "~/test/doom-testbed/.doom"))))))
            '';
                "${hgj_localbin}/doomTest" = {
                    executable = true;
                    text = ''
                cd $HOME/test/doom-testbed/doom-emacs/bin
                # DOOMDIR=${hgj_sync}/.doom.d
                EMACSDIR=../
                DOOMDIR=../../.doom.d
                DOOMLOCALDIR=../../.doom
                ./doom $@
              '';
                };
                "${hgj_localbin}/emacs-eru" = {
                    executable = true;
                    text = ''
              #!/usr/bin/env bash
              set -e
              ACTION=$1
              emacs_d=$HOME/.config/emacs
              if [[ -d "$XDG_CONFIG_HOME" ]]; then
                emacs_d="$XDG_CONFIG_HOME/emacs"
              fi
              function print_usage() {
                echo "Usage:
                emacs-eru ACTION
              Actions:
                install               Install dependencies, compile and lint configurations
                upgrade               Upgrade dependencies
                test                  Test configurations
              "
              }
              if [ -z "$ACTION" ]; then
                echo "No ACTION is provided"
                print_usage
                exit 1
              fi
              case "$ACTION" in
                install)
                  cd "$emacs_d" && {
                    make bootstrap compile lint
                  }
                  ;;
                upgrade)
                  cd "$emacs_d" && {
                    make upgrade compile lint
                  }
                  ;;
                test)
                  cd "$emacs_d" && {
                    make test
                  }
                  ;;
                *)
                  echo "Unrecognized ACTION $ACTION"
                  print_usage
                  ;;
              esac
            '';
                };
                "${hgj_localbin}/eldev" = {
                    source = pkgs.fetchurl {
                        name = "eldev";
                        url = "https://raw.github.com/doublep/eldev/master/bin/eldev";
                        sha256 = "0y3ri82cxxx4c29hb39jp655vrj88vcvwqxz5mad8rcqlh68aiy4";
                    };
                    executable = true;
                };
                ".gnupg/gpg-agent.conf".text = ''
            enable-ssh-support
            default-cache-ttl 86400
            max-cache-ttl 86400
            pinentry-program ${brewpath}/bin/pinentry-mac
            '';
                "${hgj_localbin}/uninstall-nix-osx" = {
                    executable = true;
                    text = ''
#!usr/bin/env bash

# !!WARNING!!
# This will DELETE all efforts you have put into configuring nix
# Have a look through everything that gets deleted / copied over

# nix-env -e '.*'

rm -rf "$HOME"/.nix-*
# rm -rf $HOME/.config/nixpkgs
rm -rf "$HOME"/.cache/nix
rm -rf "$HOME"/.nixpkgs

if [ -L "$HOME"/Applications ]; then
  rm "$HOME"/Applications
fi

sudo rm -rf /etc/nix /nix

# Nix wasnt installed using `--daemon`
# [ ! -f /Library/LaunchDaemons/org.nixos.nix-daemon.plist ] && exit 0

if [ -f /Library/LaunchDaemons/org.nixos.nix-daemon.plist ]; then
    sudo launchctl unload /Library/LaunchDaemons/org.nixos.nix-daemon.plist
    sudo rm /Library/LaunchDaemons/org.nixos.nix-daemon.plist
fi

if [ -f /etc/profile.backup-before-nix ]; then
    sudo mv /etc/profile.backup-before-nix /etc/profile
fi

if [ -f /etc/bashrc.backup-before-nix ]; then
    sudo mv /etc/bashrc.backup-before-nix /etc/bashrc
fi

if [ -f /etc/zshrc.backup-before-nix ]; then
    sudo mv /etc/zshrc.backup-before-nix /etc/zshrc
fi

USERS=$(sudo dscl . list /Users | grep nixbld)

for USER in $USERS; do
    sudo /usr/bin/dscl . -delete "/Users/$USER"
    sudo /usr/bin/dscl . -delete /Groups/staff GroupMembership "$USER";
done

_GROUPS=$(sudo dscl . list /Groups | grep nixbld)

for GROUP in $_GROUPS; do
    sudo /usr/bin/dscl . -delete "/Groups/$GROUP"
done

sudo rm -rf /var/root/.nix-*
sudo rm -rf /var/root/.cache/nix

# useful for finding hanging links
# $ find . -type l -maxdepth 5 ! -exec test -e {} \; -print 2>/dev/null | xargs -I {} sh -c 'file -b {} | grep nix && echo {}'
            '';
                };
                ".tridactylrc".text = ''
          set editorcmd emacsclient --eval "(setq mac-use-title-bar t)"; emacsclient -c -F "((name . \"Emacs Everywhere :: firefox\") (width . 80) (height . 12) (internal-border-width . 0))" +%l:%c
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
          bind --mode=insert <C-p> !s hs -c 'hs.eventtap.keyStroke({}, "up")'
          bind --mode=insert <C-n> !s hs -c 'hs.eventtap.keyStroke({}, "down")'
          bind --mode=ex <C-p> ex.prev_completion
          bind --mode=ex <C-n> ex.next_completion
          # bind --mode=ex <C-k> text.kill_line # same as default setting
          unbind --mode=ex <C-j> # used for kakutei key in Aquaskk
          bind --mode=ex <Tab> ex.insert_space_or_completion # ex.complete is buggy
          unbind --mode=ex <Space>
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
                "Library/texmf/tex/latex/lstlean.tex".source = pkgs.fetchurl {
                    name = "Lean-syntax-tex-highlight";
                    url = "https://raw.githubusercontent.com/leanprover-community/lean/master/extras/latex/lstlean.tex";
                    sha256 = "0ig0r4zg9prfydzc4wbywjfj1yv4578zrd80bx34vbkfbgqvpq5m";
                };
                "Library/texmf/tex/latex/uplatex.cfg".text = ''
                \RequirePackage{plautopatch}
                \RequirePackage{exppl2e}
            '';
                "Library/texmf/tex/latex/lstlangcoq.sty".source = pkgs.fetchurl {
                    name = "Coq-syntax-tex-highlight";
                    url = "https://raw.githubusercontent.com/PrincetonUniversity/VST/master/doc/lstlangcoq.sty";
                    sha256 = "12dg7yqfsh2hz74nmb0y0qvdr75dn06mj0inyz9assh55ixpljd4";
                };
                "Library/Application Support/Zotero/Profiles/z6bvhh6i.default/chrome/userChrome.css".source = pkgs.fetchurl {
                    name = "Zotero-Dark-theme";
                    url = "https://raw.githubusercontent.com/quin-q/Zotero-Dark-Theme/mac-patch/userChrome.css";
                    sha256 = "03hb64j6baj5kx24cf9y7vx4sdsv34553djsf4l3krz7aj7cwi7f";
                };
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
### sub-rule.desc -- 鋆�怒�怒隤祆�
###

azik_us.rule azik.conf Use�ZIK�xtension
                '';
                "Library/Application Support/AquaSKK/azik_us.rule".text = ''
###
### azik_us.rule -- AZIK 迕澀爛
###

',勻,永,

b.,少,皮,
bd,屯氏,矛件,
bh,少丹,皮它,
bj,少氏,皮件,
bk,太氏,申件,
bl,廿氏,示件,
bn,壬氏,田件,
bp,廿丹,示它,
bq,壬中,田奶,
br,壬日,田仿,
bt,太午,申玄,
bw,屯中,矛奶,
bx,屯中,矛奶,
bz,壬氏,田件,

byd,太之氏,申尼件,
byh,太文丹,申亙它,
byj,太文氏,申亙件,
byl,太斤氏,申亦件,
byn,太扎氏,申乓件,
byp,太斤丹,申亦它,
byq,太扎中,申乓奶,
byw,太之中,申尼奶,
byz,太扎氏,申乓件,

ca,切扎,民乓,
cc,切扎,民乓,
cd,切之氏,民尼件,
ce,切之,民尼,
cf,切之,民尼,
ch,切文丹,民亙它,
ci,切,民,
cj,切文氏,民亙件,
ck,切氏,民件,
cl,切斤氏,民亦件,
cn,切扎氏,民乓件,
co,切斤,民亦,
cp,切斤丹,民亦它,
cq,切扎中,民乓奶,
cu,切文,民亙,
cv,切扎中,民乓奶,
cw,切之中,民尼奶,
cx,切之中,民尼奶,
cz,切扎氏,民乓件,

dd,匹氏,犯件,
df,匹,犯,
dg,分互,母布,
dh,勿丹,汀它,
dj,勿氏,汀件,
dk,刈氏,氐件,
dl,升氏,玉件,
dm,匹手,犯乒,
dn,分氏,母件,
dp,升丹,玉它,
dq,分中,母奶,
dr,匹丐月,犯失伙,
ds,匹允,犯旦,
dt,分切,母民,
dv,匹氏,犯件,
dw,匹中,犯奶,
dy,匹不,犯奴,
dz,分氏,母件,
dch,匹文,犯亙□,
dci,匹不,犯奴,
dck,匹不氏,犯奴件,
dcp,升丰,玉孕□,
dcu,匹文,犯亙,

fd,孔之氏,白尼件,
fh,孔丹,白它,
fj,孔氏,白件,
fk,孔不氏,白奴件,
fl,孔予氏,白巧件,
fm,孔戈,白丞,
fn,孔丑氏,白央件,
fp,孔予,白巧□,
fq,孔丑中,白央奶,
fr,孔月,白伙,
fs,孔丑中,白央奶,
fw,孔之中,白尼奶,
fz,孔丑氏,白央件,

gd,仆氏,必件,
gh,什丹,弘它,
gj,什氏,弘件,
gk,亢氏,幼件,
gl,仍氏,打件,
gn,互氏,布件,
gp,仍丹,打它,
gq,互中,布奶,
gr,互日,布仿,
gt,仍午,打玄,
gw,仆中,必奶,
gz,互氏,布件,

gyd,亢之氏,幼尼件,
gyh,亢文丹,幼亙它,
gyj,亢文氏,幼亙件,
gyl,亢斤氏,幼亦件,
gyn,亢扎氏,幼乓件,
gyp,亢斤丹,幼亦它,
gyq,亢扎中,幼乓奶,
gyw,亢之中,幼尼奶,
gyz,亢扎氏,幼乓件,

hd,尺氏,目件,
hf,孔,白,
hh,孔丹,白它,
hj,孔氏,白件,
hk,夫氏,甲件,
hl,幻氏,石件,
hn,反氏,甩件,
hp,幻丹,石它,
hq,反中,甩奶,
ht,夫午,甲玄,
hw,尺中,目奶,
hz,反氏,甩件,
hga,夫扎,甲乓,
hgd,夫之氏,甲尼件,
hge,夫之,甲尼,
hgh,夫文丹,甲亙它,
hgj,夫文氏,甲亙件,
hgl,夫斤氏,甲亦件,
hgn,夫扎氏,甲乓件,
hgo,夫斤,甲亦,
hgp,夫斤丹,甲亦它,
hgq,夫扎中,甲乓奶,
hgu,夫文,甲亙,
hgw,夫之中,甲尼奶,
hgz,夫扎氏,甲乓件,
hyd,夫之氏,甲尼件,
hyh,夫文丹,甲亙它,
hyl,夫斤氏,甲亦件,
hyp,夫斤丹,甲亦它,
hyq,夫扎中,甲乓奶,
hyw,夫之中,甲尼奶,
hyz,夫扎氏,甲乓件,

jd,元之氏,斥尼件,
jf,元文,斥亙,
jh,元文丹,斥亙它,
jj,元文氏,斥亙件,
jk,元氏,斥件,
jl,元斤氏,斥亦件,
jn,元扎氏,斥乓件,
jp,元斤丹,斥亦它,
jq,元扎中,斥乓奶,
jv,元文丹,斥亙它,
jw,元之中,斥尼奶,
jz,元扎氏,斥乓件,

kA,仰,仰,
kE,仳,仳,
kd,仃氏,弗件,
kf,五,平,
kh,仁丹,弁它,
kj,仁氏,弁件,
kk,五氏,平件,
kl,仇氏,戊件,
km,五,平,
kn,井氏,市件,
kp,仇丹,戊它,
kq,井中,市奶,
kr,井日,市仿,
kt,仇午,戊玄,
kv,五氏,平件,
kw,仃中,弗奶,
kz,井氏,市件,
kga,五扎,平乓,
kgd,五之氏,平尼件,
kge,五之,平尼,
kgh,五文丹,平亙它,
kgl,五斤氏,平亦件,
kgn,五扎氏,平乓件,
kgo,五斤,平亦,
kgp,五斤丹,平亦它,
kgq,五扎中,平乓奶,
kgu,五文,平亙,
kgw,五之中,平尼奶,
kgz,五扎氏,平乓件,
kyd,五之氏,平尼件,
kyh,五文丹,平亙它,
kyj,五文氏,平亙件,
kyl,五斤氏,平亦件,
kyn,五扎氏,平乓件,
kyp,五斤丹,平亦它,
kyq,五扎中,平乓奶,
kyw,五之中,平尼奶,
kyz,五扎氏,平乓件,

m.,戈,丞,
md,戶氏,丟件,
mf,戈,丞,
mh,戈丹,丞它,
mj,戈氏,丞件,
mk,心氏,立件,
ml,手氏,乒件,
mn,手及,乒用,
mp,手丹,乒它,
mq,引中,穴奶,
mr,引月,穴伙,
ms,引允,穴旦,
mt,引凶,穴正,
mv,戈氏,丞件,
mw,戶中,丟奶,
mz,引氏,穴件,
mga,心扎,立乓,
mgd,心之氏,立尼件,
mge,心之,立尼,
mgh,心文丹,立亙它,
mgj,心文氏,立亙件,
mgl,心斤氏,立亦件,
mgn,心扎氏,立乓件,
mgo,心斤,立亦,
mgp,心斤丹,立亦它,
mgq,心扎中,立乓奶,
mgu,心文,立亙,
mgw,心之中,立尼奶,
mgz,心扎氏,立乓件,
myd,心之氏,立尼件,
myh,心文丹,立亙它,
myj,心文氏,立亙件,
myl,心斤氏,立亦件,
myn,心扎氏,立乓件,
myp,心斤丹,立亦它,
myq,心扎中,立乓奶,
myw,心之中,立尼奶,
myz,心扎氏,立乓件,

n.,厄,甘,
nb,友壬,生田,
nd,友氏,生件,
nf,厄,甘,
nh,厄丹,甘它,
nj,厄氏,甘件,
nk,卞氏,瓦件,
nl,及氏,用件,
np,及丹,用它,
nq,卅中,瓜奶,
nr,卅月,瓜伙,
nt,卞切,瓦民,
nv,厄氏,甘件,
nw,友中,生奶,
nz,卅氏,瓜件,
nga,卞扎,瓦乓,
ngd,卞之氏,瓦尼件,
nge,卞之,瓦尼,
ngh,卞文丹,瓦亙它,
ngj,卞文氏,瓦亙件,
ngl,卞斤氏,瓦亦件,
ngn,卞扎氏,瓦乓件,
ngo,卞斤,瓦亦,
ngp,卞斤丹,瓦亦它,
ngq,卞扎中,瓦乓奶,
ngu,卞文,瓦亙,
ngw,卞之中,瓦尼奶,
ngz,卞扎氏,瓦乓件,
nyd,卞之氏,瓦尼件,
nyh,卞文丹,瓦亙它,
nyj,卞文氏,瓦亙件,
nyl,卞斤氏,瓦亦件,
nyn,卞扎氏,瓦乓件,
nyp,卞斤丹,瓦亦它,
nyq,卞扎中,瓦乓奶,
nyw,卞之中,瓦尼奶,
nyz,卞扎氏,瓦乓件,

pd,巴氏,矢件,
pf,弔氏,禾件,
ph,尤丹,皿它,
pj,尤氏,皿件,
pk,夭氏,疋件,
pl,弔氏,禾件,
pn,天氏,由件,
pp,弔丹,禾它,
pq,天中,由奶,
pv,弔丹,禾它,
pw,巴中,矢奶,
pz,天氏,由件,
pga,夭扎,疋乓,
pgd,夭之氏,疋尼件,
pge,夭之,疋尼,
pgh,夭文丹,疋亙它,
pgj,夭文氏,疋亙件,
pgl,夭斤氏,疋亦件,
pgn,夭扎氏,疋乓件,
pgo,夭斤,疋亦,
pgp,夭斤丹,疋亦它,
pgq,夭扎中,疋乓奶,
pgu,夭文,疋亙,
pgw,夭之中,疋尼奶,
pgz,夭扎氏,疋乓件,
pyd,夭之氏,疋尼件,
pyh,夭文丹,疋亙它,
pyj,夭文氏,疋亙件,
pyl,夭斤氏,疋亦件,
pyn,夭扎氏,疋乓件,
pyp,夭斤丹,疋亦它,
pyq,夭扎中,疋乓奶,
pyw,夭之中,疋尼奶,
pyz,夭扎氏,疋乓件,

q,氏,件,

rd,木氏,伊件,
rh,月丹,伙它,
rj,月氏,伙件,
rk,曰氏,伉件,
rl,欠氏,伕件,
rn,日氏,仿件,
rp,欠丹,伕它,
rq,日中,仿奶,
rr,日木,仿伊,
rw,木中,伊奶,
rz,日氏,仿件,

ryd,曰之氏,伉尼件,
ryh,曰文丹,伉亙它,
ryj,曰文氏,伉亙件,
ryk,曰斤仁,伉亦弁,
ryl,曰斤氏,伉亦件,
ryn,曰扎氏,伉乓件,
ryp,曰斤丹,伉亦它,
ryq,曰扎中,伉乓奶,
ryw,曰之中,伉尼奶,
ryz,曰扎氏,伉乓件,

sd,六氏,本件,
sf,今中,扔奶,
sh,允丹,旦它,
sj,允氏,旦件,
sk,仄氏,扑件,
sl,公氏,末件,
sm,仄手,扑乒,
sn,今氏,扔件,
sp,公丹,末它,
sq,今中,扔奶,
sr,允月,旦伙,
ss,六中,本奶,
st,仄凶,扑正,
sv,今中,扔奶,
sw,六中,本奶,
sz,今氏,扔件,

syd,仄之氏,扑尼件,
syh,仄文丹,扑亙它,
syj,仄文氏,扑亙件,
syl,仄斤氏,扑亦件,
syp,仄斤丹,扑亦它,
syq,仄扎中,扑乓奶,
syw,仄之中,扑尼奶,
syz,仄扎氏,扑乓件,

tU,勻,永,
tb,凶太,正申,
td,化氏,氾件,
th,勾丹,汁它,
tj,勾氏,汁件,
tk,切氏,民件,
tl,午氏,玄件,
tm,凶戶,正丟,
tn,凶氏,正件,
tp,午丹,玄它,
tq,凶中,正奶,
tr,凶日,正仿,
tt,凶切,正民,
tw,化中,氾奶,
tz,凶氏,正件,
tgh,化文,氾亙□,
tgi,化不,氾奴,
tgk,化不氏,氾奴件,
tgp,午丰,玄孕□,
tgu,化文,氾亙,
tsU,勻,永,
tsa,勾丑,汁央,
tse,勾之,汁尼,
tsi,勾不,汁奴,
tso,勾予,汁巧,
tyd,切之氏,民尼件,
tyh,切文丹,民亙它,
tyj,切文氏,民亙件,
tyl,切斤氏,民亦件,
tyn,切扎氏,民乓件,
typ,切斤丹,民亦它,
tyq,切扎中,民乓奶,
tyw,切之中,民尼奶,
tyz,切扎氏,民乓件,

vd,丹,任尼件,
vk,丹,任奴件,
vl,丹,任巧件,
vn,丹,任央件,
vp,丹,任巧□,
vq,丹,任央奶,
vw,丹,任尼奶,
vz,丹,任央件,
vya,丹,任乓,
vye,丹,任尼,
vyo,丹,任亦,
vyu,丹,任亙,

wA,止,伍,
wd,丹之氏,它尼件,
wf,歹,伐,
wk,丹不氏,它奴件,
wl,丹予氏,它巧件,
wn,歹氏,伐件,
wp,丹予,它巧□,
wq,歹中,伐奶,
wr,歹木,伐伊,
wt,歹凶,伐正,
wz,歹氏,伐件,
wha,丹丑,它央,
whe,丹之,它尼,
whi,丹不,它奴,
who,丹予,它巧,
whu,丹,它,
wso,丹予,它巧,

x;,”,”,;
z;,“,“,:

xa,仄扎,扑乓,
xc,仄扎,扑乓,
xd,仄之氏,扑尼件,
xe,仄之,扑尼,
xf,仄之中,扑尼奶,
xh,仄文丹,扑亙它,
xi,仄,扑,
xj,仄文氏,扑亙件,
xk,仄氏,扑件,
xl,仄斤氏,扑亦件,
xn,仄扎氏,扑乓件,
xo,仄斤,扑亦,
xp,仄斤丹,扑亦它,
xq,仄扎中,扑乓奶,
xt,仄文勾,扑亙汁,
xu,仄文,扑亙,
xv,仄扎中,扑乓奶,
xw,仄之中,扑尼奶,
xz,仄扎氏,扑乓件,
xxa,丑,央,
xxe,之,尼,
xxi,不,奴,
xxo,予,巧,
xxu,丰,孕,

yh,斗丹,交它,
yi,毋,休,
yj,斗氏,交件,
yl,方氏,亥件,
yn,支氏,乩件,
yp,方丹,亥它,
yq,支中,乩奶,
yr,方月,亥伙,
yv,斗丹,交它,
yz,支氏,乩件,

z.,內,朮,
zc,介,扒,
zd,兮氏,未件,
zf,兮,未,
zh,內丹,朮它,
zj,內氏,朮件,
zk,元氏,斥件,
zl,冗氏,札件,
zn,介氏,扒件,
zp,冗丹,札它,
zq,介中,扒奶,
zr,介月,扒伙,
zv,介中,扒奶,
zw,兮中,未奶,
zx,兮中,未奶,
zz,介氏,扒件,
zyd,元之氏,斥尼件,
zyh,元文丹,斥亙它,
zyj,元文氏,斥亙件,
zyl,元斤氏,斥亦件,
zyn,元扎氏,斥乓件,
zyp,元斤丹,斥亦它,
zyq,元扎中,斥乓奶,
zyw,元之中,斥尼奶,
zyz,元扎氏,斥乓件,
x[,＞,＞,＞

# kana-rule.conf  卞 [ 卞覆允月庍晶筋禮互爛聒今木化中月及匹﹜ToggleKana 互懇仄仁綜仄卅中﹝
# 公仇匹﹜ [ 及庍晶筋禮毛丐中引中卞仄化﹜庍晶今木卅中方丹卞允月
[[,＞,＞,＞
                '';
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
		<string>/Users/hyunggyujang/.doom/etc/skk/aquaskk-jisyo.utf8</string>
		<key>type</key>
		<integer>5</integer>
	</dict>
</array>
</plist>
                '';
                ## For deploying for the first time
                # "Library/Preferences/jp.sourceforge.inputmethod.aquaskk.plist".text = ''
# <?xml version="1.0" encoding="UTF-8"?>
# <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
# <plist version="1.0">
# <dict>
# 	<key>beep_on_registration</key>
# 	<false/>
# 	<key>candidate_window_font_name</key>
# 	<string>Trebuchet MS</string>
# 	<key>candidate_window_font_size</key>
# 	<integer>18</integer>
# 	<key>candidate_window_labels</key>
# 	<string>ASDFJKL</string>
# 	<key>delete_okuri_when_quit</key>
# 	<true/>
# 	<key>direct_clients</key>
# 	<array>
# 		<string>net.kovidgoyal.kitty</string>
# 		<string>org.gnu.Emacs</string>
# 	</array>
# 	<key>display_shortest_match_of_kana_conversions</key>
# 	<false/>
# 	<key>dynamic_completion_range</key>
# 	<integer>1</integer>
# 	<key>enable_annotation</key>
# 	<false/>
# 	<key>enable_dynamic_completion</key>
# 	<false/>
# 	<key>enable_extended_completion</key>
# 	<true/>
# 	<key>enable_private_mode</key>
# 	<false/>
# 	<key>enable_skkdap</key>
# 	<false/>
# 	<key>enable_skkserv</key>
# 	<false/>
# 	<key>fix_intermediate_conversion</key>
# 	<true/>
# 	<key>handle_recursive_entry_as_okuri</key>
# 	<false/>
# 	<key>inline_backspace_implies_commit</key>
# 	<false/>
# 	<key>keyboard_layout</key>
# 	<string>org.sil.ukelele.keyboardlayout..abccopy</string>
# 	<key>max_count_of_inline_candidates</key>
# 	<integer>4</integer>
# 	<key>minimum_completion_length</key>
# 	<integer>0</integer>
# 	<key>openlab_host</key>
# 	<string>openlab.ring.gr.jp</string>
# 	<key>openlab_path</key>
# 	<string>/skk/skk/dic</string>
# 	<key>put_candidate_window_upward</key>
# 	<false/>
# 	<key>show_input_mode_icon</key>
# 	<true/>
# 	<key>skkdap_folder</key>
# 	<string>~/Library/Application Support/AquaSKK</string>
# 	<key>skkdap_port</key>
# 	<integer>2178</integer>
# 	<key>skkserv_localonly</key>
# 	<true/>
# 	<key>skkserv_port</key>
# 	<integer>1178</integer>
# 	<key>sub_keymaps</key>
# 	<array>
# 		<string>/Users/hyunggyujang/Library/Application Support/AquaSKK/azik.conf</string>
# 	</array>
# 	<key>sub_rules</key>
# 	<array>
# 		<string>/Users/hyunggyujang/Library/Application Support/AquaSKK/azik_us.rule</string>
# 	</array>
# 	<key>suppress_newline_on_commit</key>
# 	<true/>
# 	<key>use_individual_input_mode</key>
# 	<false/>
# 	<key>use_numeric_conversion</key>
# 	<true/>
# 	<key>user_dictionary_path</key>
# 	<string>/Users/hyunggyujang/.doom/etc/skk/aquaskk-jisyo.utf8</string>
# </dict>
# </plist>
#                 '';
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
                        sha256 = "14hbaz9x9680l3cbv7v9pndnhvpff62j9wiadgg9gwvkxn179zd1";
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
                ".gitconfig".text = ''
          [user]
            name = Hyunggyu Jang
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
          AuthMechs LOGIN
          PassCmd "pass mail.j.mbox.nagoya-u.ac.jp"
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

          IMAPAccount gmail
          Host imap.gmail.com
          SSLType IMAPS
          AuthMechs LOGIN
          User murasakipurplez5@gmail.com
          PassCmd "pass email/gmail.com"
          Port 993
          Timeout 0
          SSLType IMAPS
          SSLVersions TLSv1.2

          IMAPStore gmail-remote
          Account gmail

          MaildirStore gmail-local
          Path ~/.mail/gmail/
          Inbox ~/.mail/gmail/INBOX
          Subfolders Verbatim

          Channel gmail-folders
          Far :gmail-remote:
          Near :gmail-local:
          Create Both
          Expunge Both
          Patterns * !"[Gmail]/All Mail" !"[Gmail]/Important" !"[Gmail]/Starred" !"[Gmail]/Bin"
          SyncState *

          Group gmail
          Channel gmail-folders
        '';
                ".msmtprc".text = ''
          # Set default values for all following accounts.
          defaults
          auth           on
          tls            on
          tls_trust_file /etc/ssl/certs/ca-certificates.crt
          logfile        ~/.msmtp.log

          # Nagoya-U mail
          account        jang.hyunggyu@j.mbox.nagoya-u.ac.jp
          host           mail.j.mbox.nagoya-u.ac.jp
          port           587
          protocol       smtp
          from	         jang.hyunggyu@j.mbox.nagoya-u.ac.jp
          user           jang.hyunggyu@j.mbox.nagoya-u.ac.jp
          passwordeval   "pass mail.j.mbox.nagoya-u.ac.jp"
          tls_starttls   on

          # Gmail
          account        murasakipurplez5@gmail.com
          host           smtp.gmail.com
          port           587
          protocol       smtp
          from	         murasakipurplez5@gmail.com
          user           murasakipurplez5@gmail.com
          passwordeval   "pass email/gmail.com"
          tls_starttls   on

          # Set a default account
          account default : murasakipurplez5@gmail.com
        '';
                ".notmuch-config".text = ''
          [database]
          path=${hgj_home}/.mail
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
                "${hgj_localbin}/open_kitty" = {
                    executable = true;
                    text = ''
#!/usr/bin/env bash

# https://github.com/noperator/dotfiles/blob/master/.config/kitty/launch-instance.sh

# Launch a kitty window from another kitty window, while:
# 1. Copying the first window's working directory, and
# 2. Keeping the second window on the first window's focused display.

PATH="${if localconfig.hostname == "classic" then "$HOME/Applications/Nix Apps" else "/Applications"}/kitty.app/Contents/MacOS${"\${PATH:+:\${PATH}}"}"

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
                ".hammerspoon".source = fetchGit {
                    url = "https://github.com/HyunggyuJang/spacehammer.git";
                    rev = "c0e384326785fd02be7535777f9132cca65e2630";
                    submodules = true;
                };
                "notes".source = config.lib.file.mkOutOfStoreSymlink "${hgj_home}/Library/Mobile Documents/iCloud~com~appsonthemove~beorg/Documents/";
                "storage".source = config.lib.file.mkOutOfStoreSymlink "${hgj_home}/OneDrive - j.mbox.nagoya-u.ac.jp/";
            };
            # https://github.com/nix-community/home-manager/blob/db00b39a9abec04245486a01b236b8d9734c9ad0/tests/modules/targets-darwin/default.nix
            # Has to be set explicitly as it disabled by default, preferring nix-darwin
            targets.darwin.keybindings = {
                # Control shortcuts
                "^l"        = "centerSelectionInVisibleArea:";
                "^/"        = "undo:";
                "^_"        = "undo:";
                "^ "        = "setMark:";
                "^w"        = "deleteToMark:";
                "^u"        = "deleteToBeginningOfLine:";
                "^g"        = "_cancelKey:";
                # Meta shortcuts
                "~y"        = "yankPop:";
                "~f"        = "moveWordForward:";
                "~b"        = "moveWordBackward:";
                "~p"        = "selectPreviousKeyView:";
                "~n"        = "selectNextKeyView:";
                # Excaping XML expressions should be done automatically!
                "~&lt;"     = "moveToBeginningOfDocument:";
                "~&gt;"     = "moveToEndOfDocument:";
                "~v"        = "pageUp:";
                "~/"        = "complete:";
                "~c"        = [ "capitalizeWord:"
                                "moveForward:"
                                "moveForward:"];
                "~u"        = [ "uppercaseWord:"
                                "moveForward:"
                                "moveForward:"];
                "~l"        = [ "lowercaseWord:"
                                "moveForward:"
                                "moveForward:"];
                "~d"        = "deleteWordForward:";
                "^~h"       = "deleteWordBackward:";
                "~t"        = "transposeWords:";
                "~\\@"       = [ "setMark:"
                                 "moveWordForward:"
                                 "swapWithMark:"];
                "~h"        = [ "setMark:"
                                "moveToEndOfParagraph:"
                                "swapWithMark:"];
                # C-x shortcuts
                "^x" = {
                    "u"     = "undo:";
                    "k"     = "performClose:";
                    "^f"    = "openDocument:";
                    "^x"    = "swapWithMark:";
                    "^m"    = "selectToMark:";
                    "^s"    = "saveDocument:";
                    "^w"    = "saveDocumentAs:";
                };
            };
            xdg = {
                enable = true;

                configHome = "${hgj_home}/.config";
                dataHome = "${hgj_home}/.local/share";
                cacheHome = "${hgj_home}/.cache";
                configFile = {
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
          macos_hide_from_tasks yes
          macos_quit_when_last_window_closed yes

          include dracula.conf
        '';
                    "zathura/zathurarc".text = "set selection-clipboard clipboard";
                } // (if localconfig.hostname == "classic" then {
                    "fontconfig/fonts.conf".text = ''
        <?xml version='1.0'?>
        <!-- Generated by Hyunggyu Jang. -->
        <!DOCTYPE fontconfig SYSTEM 'fonts.dtd'>
        <fontconfig>
          <dir>/Library/Fonts</dir>
          <dir>${hgj_home}/Library/Fonts</dir>
        </fontconfig>
      '';

                    "karabiner/karabiner.json".text = ''
{
    "global": {
        "check_for_updates_on_startup": false,
        "show_in_menu_bar": true,
        "show_profile_name_in_menu_bar": false
    },
    "profiles": [
        {
            "complex_modifications": {
                "parameters": {
                    "basic.simultaneous_threshold_milliseconds": 50,
                    "basic.to_delayed_action_delay_milliseconds": 500,
                    "basic.to_if_alone_timeout_milliseconds": 1000,
                    "basic.to_if_held_down_threshold_milliseconds": 500,
                    "mouse_motion_to_scroll.speed": 100
                },
                "rules": [
                    {
                        "description": "�喋��喋��准���扼�准�怎蔭������",
                        "manipulators": [
                            {
                                "from": {
                                    "key_code": "left_command",
                                    "modifiers": {
                                        "optional": [
                                            "any"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "left_option"
                                    }
                                ],
                                "type": "basic"
                            }
                        ]
                    },
                    {
                        "description": "�望�颯��芥�潦�隞�准�函��踹����行���具��怒���潦��縑����",
                        "manipulators": [
                            {
                                "conditions": [
                                    {
                                        "bundle_identifiers": [
                                            "^org\\.gnu\\.Emacs$"
                                        ],
                                        "type": "frontmost_application_unless"
                                    }
                                ],
                                "from": {
                                    "key_code": "japanese_eisuu",
                                    "modifiers": {
                                        "optional": [
                                            "any"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "left_command"
                                    }
                                ],
                                "to_if_alone": [
                                    {
                                        "key_code": "japanese_eisuu"
                                    }
                                ],
                                "type": "basic"
                            },
                            {
                                "conditions": [
                                    {
                                        "bundle_identifiers": [
                                            "^org\\.gnu\\.Emacs$"
                                        ],
                                        "type": "frontmost_application_if"
                                    }
                                ],
                                "from": {
                                    "key_code": "japanese_eisuu",
                                    "modifiers": {
                                        "optional": [
                                            "any"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "left_command"
                                    }
                                ],
                                "to_if_alone": [
                                    {
                                        "key_code": "f17"
                                    }
                                ],
                                "type": "basic"
                            },
                            {
                                "conditions": [
                                    {
                                        "bundle_identifiers": [
                                            "^org\\.gnu\\.Emacs$"
                                        ],
                                        "type": "frontmost_application_unless"
                                    }
                                ],
                                "from": {
                                    "key_code": "japanese_kana",
                                    "modifiers": {
                                        "optional": [
                                            "any"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "right_command"
                                    }
                                ],
                                "to_if_alone": [
                                    {
                                        "key_code": "japanese_kana"
                                    }
                                ],
                                "type": "basic"
                            },
                            {
                                "conditions": [
                                    {
                                        "bundle_identifiers": [
                                            "^org\\.gnu\\.Emacs$"
                                        ],
                                        "type": "frontmost_application_if"
                                    }
                                ],
                                "from": {
                                    "key_code": "japanese_kana",
                                    "modifiers": {
                                        "optional": [
                                            "any"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "right_command"
                                    }
                                ],
                                "to_if_alone": [
                                    {
                                        "key_code": "f18"
                                    }
                                ],
                                "type": "basic"
                            },
                            {
                                "conditions": [
                                    {
                                        "input_sources": [
                                            {
                                                "language": "ko"
                                            }
                                        ],
                                        "type": "input_source_if"
                                    },
                                    {
                                        "bundle_identifiers": [
                                            "^org\\.gnu\\.Emacs$"
                                        ],
                                        "type": "frontmost_application_unless"
                                    }
                                ],
                                "from": {
                                    "key_code": "right_command",
                                    "modifiers": {
                                        "optional": [
                                            "any"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "right_option"
                                    }
                                ],
                                "type": "basic"
                            },
                            {
                                "conditions": [
                                    {
                                        "input_sources": [
                                            {
                                                "language": "ko"
                                            }
                                        ],
                                        "type": "input_source_unless"
                                    },
                                    {
                                        "bundle_identifiers": [
                                            "^org\\.gnu\\.Emacs$"
                                        ],
                                        "type": "frontmost_application_unless"
                                    }
                                ],
                                "from": {
                                    "key_code": "right_command",
                                    "modifiers": {
                                        "optional": [
                                            "any"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "right_option"
                                    }
                                ],
                                "to_if_alone": [
                                    {
                                        "hold_down_milliseconds": 50,
                                        "key_code": "japanese_eisuu"
                                    },
                                    {
                                        "select_input_source": {
                                            "language": "ko"
                                        }
                                    }
                                ],
                                "type": "basic"
                            },
                            {
                                "conditions": [
                                    {
                                        "bundle_identifiers": [
                                            "^org\\.gnu\\.Emacs$"
                                        ],
                                        "type": "frontmost_application_if"
                                    }
                                ],
                                "from": {
                                    "key_code": "right_command",
                                    "modifiers": {
                                        "optional": [
                                            "any"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "right_option"
                                    }
                                ],
                                "to_if_alone": [
                                    {
                                        "key_code": "f19"
                                    }
                                ],
                                "type": "basic"
                            }
                        ]
                    },
                    {
                        "description": "Change escape to control if pressed with other keys, to escape if pressed alone.",
                        "manipulators": [
                            {
                                "from": {
                                    "key_code": "escape",
                                    "modifiers": {
                                        "optional": [
                                            "any"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "left_control"
                                    }
                                ],
                                "to_if_alone": [
                                    {
                                        "key_code": "escape"
                                    }
                                ],
                                "type": "basic"
                            }
                        ]
                    },
                    {
                        "description": "Change return key to control if pressed with other keys, to return if pressed alone.",
                        "manipulators": [
                            {
                                "from": {
                                    "key_code": "return_or_enter",
                                    "modifiers": {
                                        "optional": [
                                            "any"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "right_control"
                                    }
                                ],
                                "to_if_alone": [
                                    {
                                        "key_code": "return_or_enter"
                                    }
                                ],
                                "type": "basic"
                            }
                        ]
                    },
                    {
                        "description": "Bash style Emacs key bindings (rev 2)",
                        "manipulators": [
                            {
                                "conditions": [
                                    {
                                        "bundle_identifiers": [
                                            "^org\\.gnu\\.Emacs$",
                                            "^com\\.apple\\.Terminal$",
                                            "^com\\.googlecode\\.iterm2$",
                                            "^com\\.microsoft\\.VSCode$",
                                            "^com\\.qvacua\\.VimR$"
                                        ],
                                        "file_paths": [
                                            "kitty",
                                            "qutebrowser"
                                        ],
                                        "type": "frontmost_application_unless"
                                    }
                                ],
                                "from": {
                                    "key_code": "w",
                                    "modifiers": {
                                        "mandatory": [
                                            "control"
                                        ],
                                        "optional": [
                                            "caps_lock"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "delete_or_backspace",
                                        "modifiers": [
                                            "left_option"
                                        ]
                                    }
                                ],
                                "type": "basic"
                            },
                            {
                                "conditions": [
                                    {
                                        "bundle_identifiers": [
                                            "^org\\.gnu\\.Emacs$",
                                            "^com\\.apple\\.Terminal$",
                                            "^com\\.googlecode\\.iterm2$",
                                            "^com\\.microsoft\\.VSCode$",
                                            "^com\\.qvacua\\.VimR$"
                                        ],
                                        "file_paths": [
                                            "kitty",
                                            "qutebrowser"
                                        ],
                                        "type": "frontmost_application_unless"
                                    }
                                ],
                                "from": {
                                    "key_code": "u",
                                    "modifiers": {
                                        "mandatory": [
                                            "control"
                                        ],
                                        "optional": [
                                            "caps_lock"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "left_arrow",
                                        "modifiers": [
                                            "left_command",
                                            "left_shift"
                                        ]
                                    },
                                    {
                                        "key_code": "delete_or_backspace",
                                        "repeat": false
                                    }
                                ],
                                "type": "basic"
                            }
                        ]
                    },
                    {
                        "description": "Emacs key bindings [control+keys] (rev 10)",
                        "manipulators": [
                            {
                                "conditions": [
                                    {
                                        "bundle_identifiers": [
                                            "^org\\.gnu\\.Emacs$",
                                            "^com\\.apple\\.Terminal$",
                                            "^com\\.googlecode\\.iterm2$",
                                            "^com\\.microsoft\\.VSCode$",
                                            "^com\\.qvacua\\.VimR$"
                                        ],
                                        "file_paths": [
                                            "kitty",
                                            "qutebrowser"
                                        ],
                                        "type": "frontmost_application_unless"
                                    }
                                ],
                                "from": {
                                    "key_code": "d",
                                    "modifiers": {
                                        "mandatory": [
                                            "control"
                                        ],
                                        "optional": [
                                            "caps_lock",
                                            "option"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "delete_forward"
                                    }
                                ],
                                "type": "basic"
                            },
                            {
                                "conditions": [
                                    {
                                        "bundle_identifiers": [
                                            "^org\\.gnu\\.Emacs$",
                                            "^com\\.apple\\.Terminal$",
                                            "^com\\.googlecode\\.iterm2$",
                                            "^com\\.microsoft\\.VSCode$",
                                            "^com\\.qvacua\\.VimR$"
                                        ],
                                        "file_paths": [
                                            "kitty",
                                            "qutebrowser"
                                        ],
                                        "type": "frontmost_application_unless"
                                    }
                                ],
                                "from": {
                                    "key_code": "h",
                                    "modifiers": {
                                        "mandatory": [
                                            "control"
                                        ],
                                        "optional": [
                                            "caps_lock",
                                            "option"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "delete_or_backspace"
                                    }
                                ],
                                "type": "basic"
                            },
                            {
                                "conditions": [
                                    {
                                        "bundle_identifiers": [
                                            "^org\\.gnu\\.Emacs$",
                                            "^com\\.apple\\.Terminal$",
                                            "^com\\.googlecode\\.iterm2$",
                                            "^com\\.microsoft\\.VSCode$",
                                            "^com\\.qvacua\\.VimR$"
                                        ],
                                        "file_paths": [
                                            "kitty",
                                            "qutebrowser"
                                        ],
                                        "type": "frontmost_application_unless"
                                    }
                                ],
                                "from": {
                                    "key_code": "i",
                                    "modifiers": {
                                        "mandatory": [
                                            "control"
                                        ],
                                        "optional": [
                                            "caps_lock",
                                            "shift"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "tab"
                                    }
                                ],
                                "type": "basic"
                            },
                            {
                                "conditions": [
                                    {
                                        "keyboard_types": [
                                            "ansi",
                                            "iso"
                                        ],
                                        "type": "keyboard_type_if"
                                    }
                                ],
                                "from": {
                                    "key_code": "open_bracket",
                                    "modifiers": {
                                        "mandatory": [
                                            "control"
                                        ],
                                        "optional": [
                                            "caps_lock"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "escape"
                                    }
                                ],
                                "type": "basic"
                            },
                            {
                                "conditions": [
                                    {
                                        "keyboard_types": [
                                            "jis"
                                        ],
                                        "type": "keyboard_type_if"
                                    }
                                ],
                                "from": {
                                    "key_code": "close_bracket",
                                    "modifiers": {
                                        "mandatory": [
                                            "control"
                                        ],
                                        "optional": [
                                            "caps_lock"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "escape"
                                    }
                                ],
                                "type": "basic"
                            },
                            {
                                "from": {
                                    "key_code": "m",
                                    "modifiers": {
                                        "mandatory": [
                                            "control"
                                        ],
                                        "optional": [
                                            "caps_lock",
                                            "shift",
                                            "option"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "return_or_enter"
                                    }
                                ],
                                "type": "basic"
                            },
                            {
                                "conditions": [
                                    {
                                        "bundle_identifiers": [
                                            "^org\\.gnu\\.Emacs$",
                                            "^com\\.apple\\.Terminal$",
                                            "^com\\.googlecode\\.iterm2$",
                                            "^com\\.microsoft\\.VSCode$",
                                            "^com\\.qvacua\\.VimR$"
                                        ],
                                        "file_paths": [
                                            "kitty",
                                            "qutebrowser"
                                        ],
                                        "type": "frontmost_application_unless"
                                    }
                                ],
                                "from": {
                                    "key_code": "b",
                                    "modifiers": {
                                        "mandatory": [
                                            "control"
                                        ],
                                        "optional": [
                                            "caps_lock",
                                            "shift",
                                            "option"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "left_arrow"
                                    }
                                ],
                                "type": "basic"
                            },
                            {
                                "conditions": [
                                    {
                                        "bundle_identifiers": [
                                            "^org\\.gnu\\.Emacs$",
                                            "^com\\.apple\\.Terminal$",
                                            "^com\\.googlecode\\.iterm2$",
                                            "^com\\.microsoft\\.VSCode$",
                                            "^com\\.qvacua\\.VimR$"
                                        ],
                                        "file_paths": [
                                            "kitty",
                                            "qutebrowser"
                                        ],
                                        "type": "frontmost_application_unless"
                                    }
                                ],
                                "from": {
                                    "key_code": "f",
                                    "modifiers": {
                                        "mandatory": [
                                            "control"
                                        ],
                                        "optional": [
                                            "caps_lock",
                                            "shift",
                                            "option"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "right_arrow"
                                    }
                                ],
                                "type": "basic"
                            },
                            {
                                "conditions": [
                                    {
                                        "bundle_identifiers": [
                                            "^org\\.gnu\\.Emacs$",
                                            "^com\\.apple\\.Terminal$",
                                            "^com\\.googlecode\\.iterm2$",
                                            "^com\\.microsoft\\.VSCode$",
                                            "^com\\.qvacua\\.VimR$"
                                        ],
                                        "file_paths": [
                                            "kitty",
                                            "qutebrowser"
                                        ],
                                        "type": "frontmost_application_unless"
                                    }
                                ],
                                "from": {
                                    "key_code": "n",
                                    "modifiers": {
                                        "mandatory": [
                                            "control"
                                        ],
                                        "optional": [
                                            "caps_lock",
                                            "shift",
                                            "option"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "down_arrow"
                                    }
                                ],
                                "type": "basic"
                            },
                            {
                                "conditions": [
                                    {
                                        "bundle_identifiers": [
                                            "^org\\.gnu\\.Emacs$",
                                            "^com\\.apple\\.Terminal$",
                                            "^com\\.googlecode\\.iterm2$",
                                            "^com\\.microsoft\\.VSCode$",
                                            "^com\\.qvacua\\.VimR$"
                                        ],
                                        "file_paths": [
                                            "kitty",
                                            "qutebrowser"
                                        ],
                                        "type": "frontmost_application_unless"
                                    }
                                ],
                                "from": {
                                    "key_code": "p",
                                    "modifiers": {
                                        "mandatory": [
                                            "control"
                                        ],
                                        "optional": [
                                            "caps_lock",
                                            "shift",
                                            "option"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "up_arrow"
                                    }
                                ],
                                "type": "basic"
                            },
                            {
                                "conditions": [
                                    {
                                        "bundle_identifiers": [
                                            "^org\\.gnu\\.Emacs$",
                                            "^com\\.apple\\.Terminal$",
                                            "^com\\.googlecode\\.iterm2$",
                                            "^com\\.microsoft\\.VSCode$",
                                            "^com\\.qvacua\\.VimR$"
                                        ],
                                        "file_paths": [
                                            "kitty",
                                            "qutebrowser"
                                        ],
                                        "type": "frontmost_application_unless"
                                    }
                                ],
                                "from": {
                                    "key_code": "v",
                                    "modifiers": {
                                        "mandatory": [
                                            "control"
                                        ],
                                        "optional": [
                                            "caps_lock",
                                            "shift"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "page_down"
                                    }
                                ],
                                "type": "basic"
                            },
                            {
                                "conditions": [
                                    {
                                        "bundle_identifiers": [
                                            "^com\\.microsoft\\.Excel$",
                                            "^com\\.microsoft\\.Powerpoint$",
                                            "^com\\.microsoft\\.Word$"
                                        ],
                                        "type": "frontmost_application_if"
                                    }
                                ],
                                "from": {
                                    "key_code": "a",
                                    "modifiers": {
                                        "mandatory": [
                                            "control"
                                        ],
                                        "optional": [
                                            "caps_lock",
                                            "shift"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "home"
                                    }
                                ],
                                "type": "basic"
                            },
                            {
                                "conditions": [
                                    {
                                        "bundle_identifiers": [
                                            "^com\\.microsoft\\.Excel$",
                                            "^com\\.microsoft\\.Powerpoint$",
                                            "^com\\.microsoft\\.Word$"
                                        ],
                                        "type": "frontmost_application_if"
                                    }
                                ],
                                "from": {
                                    "key_code": "e",
                                    "modifiers": {
                                        "mandatory": [
                                            "control"
                                        ],
                                        "optional": [
                                            "caps_lock",
                                            "shift"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "end"
                                    }
                                ],
                                "type": "basic"
                            },
                            {
                                "conditions": [
                                    {
                                        "bundle_identifiers": [
                                            "^org\\.eclipse\\.platform\\.ide$"
                                        ],
                                        "type": "frontmost_application_if"
                                    }
                                ],
                                "from": {
                                    "key_code": "a",
                                    "modifiers": {
                                        "mandatory": [
                                            "control"
                                        ],
                                        "optional": [
                                            "caps_lock",
                                            "shift"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "left_arrow",
                                        "modifiers": [
                                            "left_command"
                                        ]
                                    }
                                ],
                                "type": "basic"
                            },
                            {
                                "conditions": [
                                    {
                                        "bundle_identifiers": [
                                            "^org\\.eclipse\\.platform\\.ide$"
                                        ],
                                        "type": "frontmost_application_if"
                                    }
                                ],
                                "from": {
                                    "key_code": "e",
                                    "modifiers": {
                                        "mandatory": [
                                            "control"
                                        ],
                                        "optional": [
                                            "caps_lock",
                                            "shift"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "right_arrow",
                                        "modifiers": [
                                            "left_command"
                                        ]
                                    }
                                ],
                                "type": "basic"
                            }
                        ]
                    },
                    {
                        "description": "Emacs key bindings [option+keys] (rev 5)",
                        "manipulators": [
                            {
                                "conditions": [
                                    {
                                        "bundle_identifiers": [
                                            "^org\\.gnu\\.Emacs$",
                                            "^com\\.apple\\.Terminal$",
                                            "^com\\.googlecode\\.iterm2$",
                                            "^com\\.microsoft\\.VSCode$",
                                            "^com\\.qvacua\\.VimR$"
                                        ],
                                        "file_paths": [
                                            "kitty",
                                            "qutebrowser"
                                        ],
                                        "type": "frontmost_application_unless"
                                    }
                                ],
                                "from": {
                                    "key_code": "v",
                                    "modifiers": {
                                        "mandatory": [
                                            "option"
                                        ],
                                        "optional": [
                                            "caps_lock",
                                            "shift"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "page_up"
                                    }
                                ],
                                "type": "basic"
                            },
                            {
                                "conditions": [
                                    {
                                        "bundle_identifiers": [
                                            "^org\\.gnu\\.Emacs$",
                                            "^com\\.apple\\.Terminal$",
                                            "^com\\.googlecode\\.iterm2$",
                                            "^com\\.microsoft\\.VSCode$",
                                            "^com\\.qvacua\\.VimR$"
                                        ],
                                        "file_paths": [
                                            "kitty",
                                            "qutebrowser"
                                        ],
                                        "type": "frontmost_application_unless"
                                    }
                                ],
                                "from": {
                                    "key_code": "b",
                                    "modifiers": {
                                        "mandatory": [
                                            "option"
                                        ],
                                        "optional": [
                                            "caps_lock",
                                            "shift"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "left_arrow",
                                        "modifiers": [
                                            "left_option"
                                        ]
                                    }
                                ],
                                "type": "basic"
                            },
                            {
                                "conditions": [
                                    {
                                        "bundle_identifiers": [
                                            "^org\\.gnu\\.Emacs$",
                                            "^com\\.apple\\.Terminal$",
                                            "^com\\.googlecode\\.iterm2$",
                                            "^com\\.microsoft\\.VSCode$",
                                            "^com\\.qvacua\\.VimR$"
                                        ],
                                        "file_paths": [
                                            "kitty",
                                            "qutebrowser"
                                        ],
                                        "type": "frontmost_application_unless"
                                    }
                                ],
                                "from": {
                                    "key_code": "f",
                                    "modifiers": {
                                        "mandatory": [
                                            "option"
                                        ],
                                        "optional": [
                                            "caps_lock",
                                            "shift"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "right_arrow",
                                        "modifiers": [
                                            "left_option"
                                        ]
                                    }
                                ],
                                "type": "basic"
                            },
                            {
                                "conditions": [
                                    {
                                        "bundle_identifiers": [
                                            "^org\\.gnu\\.Emacs$",
                                            "^com\\.apple\\.Terminal$",
                                            "^com\\.googlecode\\.iterm2$",
                                            "^com\\.microsoft\\.VSCode$",
                                            "^com\\.qvacua\\.VimR$"
                                        ],
                                        "file_paths": [
                                            "kitty",
                                            "qutebrowser"
                                        ],
                                        "type": "frontmost_application_unless"
                                    }
                                ],
                                "from": {
                                    "key_code": "d",
                                    "modifiers": {
                                        "mandatory": [
                                            "option"
                                        ],
                                        "optional": [
                                            "caps_lock"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "delete_forward",
                                        "modifiers": [
                                            "left_option"
                                        ]
                                    }
                                ],
                                "type": "basic"
                            }
                        ]
                    },
                    {
                        "description": "Emacs key bindings [C-x key strokes] (rev 2)",
                        "manipulators": [
                            {
                                "conditions": [
                                    {
                                        "name": "C-x",
                                        "type": "variable_if",
                                        "value": 1
                                    }
                                ],
                                "from": {
                                    "key_code": "c",
                                    "modifiers": {
                                        "mandatory": [
                                            "control"
                                        ],
                                        "optional": [
                                            "caps_lock"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "q",
                                        "modifiers": [
                                            "left_command"
                                        ]
                                    }
                                ],
                                "type": "basic"
                            },
                            {
                                "conditions": [
                                    {
                                        "name": "C-x",
                                        "type": "variable_if",
                                        "value": 1
                                    }
                                ],
                                "from": {
                                    "key_code": "f",
                                    "modifiers": {
                                        "mandatory": [
                                            "control"
                                        ],
                                        "optional": [
                                            "caps_lock"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "o",
                                        "modifiers": [
                                            "left_command"
                                        ]
                                    }
                                ],
                                "type": "basic"
                            },
                            {
                                "conditions": [
                                    {
                                        "name": "C-x",
                                        "type": "variable_if",
                                        "value": 1
                                    }
                                ],
                                "from": {
                                    "key_code": "s",
                                    "modifiers": {
                                        "mandatory": [
                                            "control"
                                        ],
                                        "optional": [
                                            "caps_lock"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "s",
                                        "modifiers": [
                                            "left_command"
                                        ]
                                    }
                                ],
                                "type": "basic"
                            },
                            {
                                "conditions": [
                                    {
                                        "name": "C-x",
                                        "type": "variable_if",
                                        "value": 1
                                    }
                                ],
                                "from": {
                                    "any": "key_code",
                                    "modifiers": {
                                        "optional": [
                                            "any"
                                        ]
                                    }
                                },
                                "type": "basic"
                            },
                            {
                                "conditions": [
                                    {
                                        "bundle_identifiers": [
                                            "^org\\.gnu\\.Emacs$",
                                            "^com\\.apple\\.Terminal$",
                                            "^com\\.googlecode\\.iterm2$",
                                            "^com\\.microsoft\\.VSCode$",
                                            "^com\\.qvacua\\.VimR$"
                                        ],
                                        "file_paths": [
                                            "kitty",
                                            "qutebrowser"
                                        ],
                                        "type": "frontmost_application_unless"
                                    }
                                ],
                                "from": {
                                    "key_code": "x",
                                    "modifiers": {
                                        "mandatory": [
                                            "control"
                                        ],
                                        "optional": [
                                            "caps_lock"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "set_variable": {
                                            "name": "C-x",
                                            "value": 1
                                        }
                                    }
                                ],
                                "to_delayed_action": {
                                    "to_if_canceled": [
                                        {
                                            "set_variable": {
                                                "name": "C-x",
                                                "value": 0
                                            }
                                        }
                                    ],
                                    "to_if_invoked": [
                                        {
                                            "set_variable": {
                                                "name": "C-x",
                                                "value": 0
                                            }
                                        }
                                    ]
                                },
                                "type": "basic"
                            }
                        ]
                    }
                ]
            },
            "devices": [
                {
                    "disable_built_in_keyboard_if_exists": false,
                    "fn_function_keys": [],
                    "identifiers": {
                        "is_keyboard": true,
                        "is_pointing_device": false,
                        "product_id": 657,
                        "vendor_id": 1452
                    },
                    "ignore": false,
                    "manipulate_caps_lock_led": true,
                    "simple_modifications": []
                }
            ],
            "fn_function_keys": [
                {
                    "from": {
                        "key_code": "f1"
                    },
                    "to": {
                        "consumer_key_code": "display_brightness_decrement"
                    }
                },
                {
                    "from": {
                        "key_code": "f2"
                    },
                    "to": {
                        "consumer_key_code": "display_brightness_increment"
                    }
                },
                {
                    "from": {
                        "key_code": "f3"
                    },
                    "to": {
                        "key_code": "mission_control"
                    }
                },
                {
                    "from": {
                        "key_code": "f4"
                    },
                    "to": {
                        "key_code": "launchpad"
                    }
                },
                {
                    "from": {
                        "key_code": "f5"
                    },
                    "to": {
                        "key_code": "illumination_decrement"
                    }
                },
                {
                    "from": {
                        "key_code": "f6"
                    },
                    "to": {
                        "key_code": "illumination_increment"
                    }
                },
                {
                    "from": {
                        "key_code": "f7"
                    },
                    "to": {
                        "consumer_key_code": "rewind"
                    }
                },
                {
                    "from": {
                        "key_code": "f8"
                    },
                    "to": {
                        "consumer_key_code": "play_or_pause"
                    }
                },
                {
                    "from": {
                        "key_code": "f9"
                    },
                    "to": {
                        "consumer_key_code": "fast_forward"
                    }
                },
                {
                    "from": {
                        "key_code": "f10"
                    },
                    "to": {
                        "consumer_key_code": "mute"
                    }
                },
                {
                    "from": {
                        "key_code": "f11"
                    },
                    "to": {
                        "consumer_key_code": "volume_decrement"
                    }
                },
                {
                    "from": {
                        "key_code": "f12"
                    },
                    "to": {
                        "consumer_key_code": "volume_increment"
                    }
                }
            ],
            "name": "Default profile",
            "parameters": {
                "delay_milliseconds_before_open_device": 1000
            },
            "selected": true,
            "simple_modifications": [
                {
                    "from": {
                        "key_code": "caps_lock"
                    },
                    "to": {
                        "key_code": "fn"
                    }
                },
                {
                    "from": {
                        "key_code": "escape"
                    },
                    "to": {
                        "key_code": "caps_lock"
                    }
                },
                {
                    "from": {
                        "key_code": "left_control"
                    },
                    "to": {
                        "key_code": "escape"
                    }
                }
            ],
            "virtual_hid_keyboard": {
                "country_code": 0,
                "mouse_key_xy_scale": 100
            }
        }
    ]
}
'';
                } else {
                    "yabai/yabairc".text = ''
yabai -m config active_window_opacity 1.000000
yabai -m config auto_balance on
yabai -m config bottom_padding 0
yabai -m config focus_follows_mouse off
yabai -m config layout bsp
yabai -m config left_padding 0
yabai -m config mouse_action1 move
yabai -m config mouse_action2 resize
yabai -m config mouse_follows_focus off
yabai -m config mouse_modifier fn
yabai -m config normal_window_opacity 0.900000
yabai -m config right_padding 0
yabai -m config split_ratio 0.500000
yabai -m config top_padding 0
yabai -m config window_border off
yabai -m config window_gap 0
yabai -m config window_opacity on
yabai -m config window_opacity_duration 0.000000
yabai -m config window_placement second_child
yabai -m config window_shadow off
yabai -m config window_topmost on
yabai -m rule --add app="^System Preferences$" manage=off
yabai -m rule --add app="Inkscape" title="LaTeX (pdflatex)" manage=off
yabai -m rule --add app=AquaSKK manage=off
yabai -m rule --add app=Emacs title="Emacs Everywhere ::*" manage=off
yabai -m rule --add app="^Emacs$" space=1
yabai -m rule --add app="^Firefox$" space=2
yabai -m rule --add app=Anki space=3
yabai -m rule --add app="^Microsoft Teams$" space=4
yabai -m rule --add app="^zoom$" space=4
'';
                    "karabiner/karabiner.json".text = ''
{
    "global": {
        "check_for_updates_on_startup": false,
        "show_in_menu_bar": true,
        "show_profile_name_in_menu_bar": false
    },
    "profiles": [
        {
            "complex_modifications": {
                "parameters": {
                    "basic.simultaneous_threshold_milliseconds": 50,
                    "basic.to_delayed_action_delay_milliseconds": 500,
                    "basic.to_if_alone_timeout_milliseconds": 1000,
                    "basic.to_if_held_down_threshold_milliseconds": 500,
                    "mouse_motion_to_scroll.speed": 100
                },
                "rules": [
                    {
                        "description": "Change escape to control if pressed with other keys, to escape if pressed alone.",
                        "manipulators": [
                            {
                                "from": {
                                    "key_code": "escape",
                                    "modifiers": {
                                        "optional": [
                                            "any"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "left_control"
                                    }
                                ],
                                "to_if_alone": [
                                    {
                                        "key_code": "escape"
                                    }
                                ],
                                "type": "basic"
                            }
                        ]
                    },
                    {
                        "description": "Change return key to control if pressed with other keys, to return if pressed alone.",
                        "manipulators": [
                            {
                                "from": {
                                    "key_code": "return_or_enter",
                                    "modifiers": {
                                        "optional": [
                                            "any"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "right_control"
                                    }
                                ],
                                "to_if_alone": [
                                    {
                                        "key_code": "return_or_enter"
                                    }
                                ],
                                "type": "basic"
                            }
                        ]
                    },
                    {
                        "description": "Change to English layout if Left �� key pressed alone, else send �� key.",
                        "manipulators": [
                            {
                                "from": {
                                    "key_code": "left_command",
                                    "modifiers": {
                                        "optional": [
                                            "any"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "left_command"
                                    }
                                ],
                                "to_if_alone": [
                                    {
                                        "key_code": "f17"
                                    }
                                ],
                                "type": "basic"
                            },
                            {
                                "from": {
                                    "key_code": "right_command",
                                    "modifiers": {
                                        "optional": [
                                            "any"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "right_command"
                                    }
                                ],
                                "to_if_alone": [
                                    {
                                        "key_code": "f18"
                                    }
                                ],
                                "type": "basic"
                            },
                            {
                                "from": {
                                    "key_code": "right_option",
                                    "modifiers": {
                                        "optional": [
                                            "any"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "right_option"
                                    }
                                ],
                                "to_if_alone": [
                                    {
                                        "key_code": "f19"
                                    }
                                ],
                                "type": "basic"
                            }
                        ]
                    },
                    {
                        "description": "Map F6 (Do Not Disturb) to Cmd+Opt+Eject for Sleep Mac",
                        "manipulators": [
                            {
                                "from": {
                                    "key_code": "f6"
                                },
                                "to_after_key_up": [
                                    {
                                    "repeat": false,
                                    "consumer_key_code": "eject",
                                    "modifiers": [
                                        "left_gui",
                                        "left_alt"
                                    ]
                                    }
                                ],
                                "type": "basic"
                            }
                        ]
                    }
                ]
            },
            "name": "Default profile",
            "parameters": {
                "delay_milliseconds_before_open_device": 1000
            },
            "selected": true,
            "simple_modifications": [
                {
                    "from": {
                        "key_code": "caps_lock"
                    },
                    "to": [
                        {
                            "key_code": "escape"
                        }
                    ]
                },
                {
                    "from": {
                        "key_code": "escape"
                    },
                    "to": [
                        {
                            "key_code": "caps_lock"
                        }
                    ]
                }
            ],
            "virtual_hid_keyboard": {
                "country_code": 0,
                "indicate_sticky_modifier_keys_state": true,
                "mouse_key_xy_scale": 100
            }
        }
    ]
}
'';
                });
            };
            programs.zsh = {
                enable = true;
                enableAutosuggestions = true;
                enableCompletion = false; # See https://github.com/NixOS/nix/issues/5445
                defaultKeymap = "emacs";
                sessionVariables = { RPROMPT = ""; };
                shellAliases =  {
                    dbuild = "cd ${hgj_darwin_home} && HOSTNAME=${localconfig.hostname} TERM=xterm-256color make && cd -";
                    dswitch = "cd ${hgj_darwin_home} && HOSTNAME=${localconfig.hostname} TERM=xterm-256color make switch && cd -";
                    drb = "cd ${hgj_darwin_home} && HOSTNAME=${localconfig.hostname} TERM=xterm-256color make rollback && cd -";
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
                            name    = "system-wide-clipboard";
                            src = pkgs.fetchurl {
                                name = "system-wide-clipboard.zsh";
                                url = "https://gist.githubusercontent.com/varenc/e4a22145c484771f254fa20982e2cd7f/raw/c2f17f411b38c7deda31ee35ff5ae980dff6ef10/system-wide-clipboard.zsh";
                                sha256 = "09disbcgpgdckmzds8lsbyvn0m8187np5r1qs9cdza3412wcm9sl";
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
        echo >&2 "Homebrew completion path..."
        if [ -f ${brewpath}/bin/brew ]; then
          PATH=${brewpath}/bin:$PATH fpath+=$(brew --prefix)/share/zsh/site-functions
        else
          echo -e "\e[1;31merror: Homebrew is not installed, skipping...\e[0m" >&2
        fi
    '';
                initExtra = ''
        PROMPT=' %{$fg_bold[blue]%}$(get_pwd)%{$reset_color%} ''${prompt_suffix}'
        local prompt_suffix="%(?:%{$fg_bold[green]%}�� :%{$fg_bold[red]%}��%{$reset_color%} "
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
        '';
            };

            programs.fzf.enable = true;
            programs.fzf.enableZshIntegration = true;
            programs.browserpass.enable = true;
            programs.browserpass.browsers = [ "firefox" ];
            programs.firefox.enable = true;
            programs.firefox.package = pkgs.runCommand "firefox-0.0.0" {} "mkdir $out";
            programs.firefox.extensions =
                with nur.repos.rycee.firefox-addons; [
                    ublock-origin
                    browserpass
                    tridactyl
                    darkreader
                    # Need to add zotero-connector
                ];
            programs.firefox.profiles =
                {
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
                        userChrome = (
                            builtins.readFile (
                                pkgs.substituteAll {
                                    name = "homeUserChrome";
                                    src = pkgs.fetchurl {
                                        name = "userChrome.css";
                                        url = "https://raw.githubusercontent.com/cmacrae/config/master/conf.d/userChrome.css";
                                        sha256 = "1ia2azcrrbc70m8hcn7mph1allh2fly9k2kqmi4qy6mx5lf12kn8";
                                    };
                                    tabLineColour = "#5e81ac";
                                }
                            )
                        );
                    };
                };
        };
                             in
                               if localconfig.hostname == "classic" then {
                                   hynggyujang = userconfig // {
                                       home.sessionVariables = {
                                           FONTCONFIG_FILE    = "${xdg.configHome}/fontconfig/fonts.conf";
                                           FONTCONFIG_PATH    = "${xdg.configHome}/fontconfig";
                                       };
                                   };
                               } else {
                                   hyunggyujang = userconfig;
                               };
        system = {
            defaults.NSGlobalDomain = {
                ApplePressAndHoldEnabled = false;
                AppleKeyboardUIMode = 3;
                AppleShowScrollBars = "WhenScrolling";
                AppleInterfaceStyleSwitchesAutomatically = true;
                NSAutomaticCapitalizationEnabled = false;
                NSAutomaticDashSubstitutionEnabled = false;
                NSAutomaticPeriodSubstitutionEnabled = false;
                NSAutomaticQuoteSubstitutionEnabled = false;
                NSAutomaticSpellingCorrectionEnabled = false;
                NSUseAnimatedFocusRing = false;
                _HIHideMenuBar = true;
            };

            defaults.dock.orientation = "left";

            defaults.loginwindow.GuestEnabled = false;

        };
        users = {
            users.hyunggyujang = {
                name = "Hyunggyu Jang";
                home = "${hgj_home}";
                shell = pkgs.zsh;
            };
        } //
        (if localconfig.hostname == "silicon" then {
            # For single user hack
            nix.configureBuildUsers = mkForce false;
            knownGroups = mkForce [];
        } else {});

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
                SPACEHAMMER_REPL = "${hgj_home}/.luarocks/bin/fennel ${shevek}/shevek.fnl localhost:7888";
            } //
            ( if localconfig.hostname == "classic" then {
                NODE_PATH =  "/run/current-system/sw/lib/node_modules";
            } else {
                LIBGS = "/opt/homebrew/lib/libgs.dylib"; # For tikz's latex preview.
            });
            systemPath = [
                "$HOME/${hgj_localbin}"
                # Easy access to Doom
                # SystemPath added before to the variables, it can be inspected at /etc/static/zshenv,
                # which source *-set-environment file.
                "${environment.variables.EMACSDIR}/bin"
                "${brewpath}/bin"
            ];
            profiles = mkForce ([ "$HOME/.nix-profile" "/run/current-system/sw" ]);
        } // (if localconfig.hostname == "classic" then {
            systemPackages = with pkgs; [
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
                (lua5_3.withPackages (ps: with ps; [fennel]))
                gnupg
                pass
                # fish
                yaskkserv2 #�� Cannot build
                cargo
                skhd
            ];
            shells = [
                pkgs.bashInteractive
                pkgs.zsh
            ];
            pathsToLink = [
                "/lib/node_modules"
                "/share/emacs"
                "/share/lua"
                "/lib/lua"
            ];
            loginShell = "${pkgs.zsh}/bin/zsh -l";
        } else {
            systemPackages = with pkgs; [
                nixfmt
                clojure
                leiningen
                yaskkserv2
                darwin-zsh-completions
                # skhd
                shellcheck # Not yet available
                # octave # nix-build-qrupdate aren't ready -- See https://github.com/NixOS/nixpkgs/issues/140041
            ];
            shells = [
                pkgs.zsh
            ];
        });

        nixpkgs.overlays =
            let path = ../overlays;
            in with builtins;
                [
                    (self: super: {
                        darwin-zsh-completions = super.runCommandNoCC "darwin-zsh-completions-0.0.0"
                            { preferLocalBuild = true; }
                            ''
          mkdir -p $out/share/zsh/site-functions
          cat <<-'EOF' > $out/share/zsh/site-functions/_darwin-rebuild
          #compdef darwin-rebuild
          #autoload
          _nix-common-options
          local -a _1st_arguments
          _1st_arguments=(
            'switch:Build, activate, and update the current generation'\
            'build:Build without activating or updating the current generation'\
            'check:Build and run the activation sanity checks'\
            'changelog:Show most recent entries in the changelog'\
                         )
          _arguments \
            '--list-generations[Print a list of all generations in the active profile]'\
            '--rollback[Roll back to the previous configuration]'\
            {--switch-generation,-G}'[Activate specified generation]'\
            '(--profile-name -p)'{--profile-name,-p}'[Profile to use to track current and previous system configurations]:Profile:_nix_profiles'\
            '1:: :->subcmds' && return 0
          case $state in
            subcmds)
              _describe -t commands 'darwin-rebuild subcommands' _1st_arguments
            ;;
          esac
          EOF
        '';})
                ] ++ map (n: import (path + ("/" + n)))
                    (filter (n: match ".*\\.nix" n != null ||
                                pathExists (path + ("/" + n + "/default.nix")))
                        (attrNames (readDir path)));

        programs = {
            zsh = {
                enable = true;
                enableCompletion = false;
                enableBashCompletion = false;
            };
        };

        # Manual setting for workaround of org-id: 7127dc6e-5a84-476c-8d31-59737a4f85f9
        launchd.daemons = if localconfig.hostname == "classic" then {
            yabai-sa = {
                script = ''
          ${pkgs.yabai}/bin/yabai --check-sa || ${pkgs.yabai}/bin/yabai --install-sa
        '';

                serviceConfig.RunAtLoad = true;
                serviceConfig.KeepAlive.SuccessfulExit = false;
            };
        } else {};
        services =
            (if localconfig.hostname == "classic" then {
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
          yabai -m rule --add app="^Karabiner-Elements$" manage=off
          yabai -m rule --add app=Emacs title="Emacs Everywhere ::*" manage=off sticky=on
          yabai -m rule --add app=Emacs space=1
          yabai -m rule --add app=qutebrowser space=2
          yabai -m rule --add app=Anki space=3
          yabai -m rule --add app="Microsoft Teams" space=4
          yabai -m rule --add app=zoom space=4
          yabai -m rule --add app="Google Chrome" space=5
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
          ## Doom
          open < d : echo "doom" > $HOME/.emacs-profile; open -a "$HOME/Applications/Nix Apps/Emacs.app"&; skhd -k "ctrl - g"
          ## d12Frosted
          open < f : echo "d12frosted" > $HOME/.emacs-profile; open -a "$HOME/Applications/Nix Apps/Emacs.app"&; skhd -k "ctrl - g"
          open < e : open -a "$HOME/Applications/Nix Apps/Emacs.app"&; skhd -k "ctrl - g"
          open < shift - e : DEBUG=1 open -a "$HOME/Applications/Nix Apps/Emacs.app"&; skhd -k "ctrl - g"

          # kitty or terminal
          open < t : open_kitty &; skhd -k "ctrl - g"

          # Internet Browser
          open < b : open -a "/Applications/qutebrowser.app" &; skhd -k "ctrl - g"
          ctrl + cmd - e : doom everywhere
          ctrl + shift + cmd - e : skhd -k "cmd - a"; doom everywhere
        '';
                };
            } else (if localconfig.hostname == "silicon" then {
                nix-daemon.enable = false;
                skhd = {
                    enable = false;
                    skhdConfig = ''
################################################################################
#
# window manipulation
#

# ^ = 0x18
ctrl + cmd - 6 : yabai -m window --focus recent
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
myinsert < j : skhd -k "ctrl - g"; yabai -m window --insert south
myinsert < k : skhd -k "ctrl - g"; yabai -m window --insert north
myinsert < l : skhd -k "ctrl - g"; yabai -m window --insert east

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
ctrl + cmd - o ; open
open < ctrl - g ; default

# emacs
open < e : skhd -k "ctrl - g"; open -a Emacs
open < shift - e : skhd -k "ctrl - g"; DEBUG=1 open -a Emacs

# kitty or terminal
open < t : skhd -k "ctrl - g"; open_kitty
open < shift - t : skhd -k "ctrl - g"; open -a kitty

# Internet Browser
open < b : skhd -k "ctrl - g"; open -a "/Applications/firefox.app"
ctrl + cmd - e : doom everywhere
ctrl + shift + cmd - e : skhd -k "cmd - a"; doom everywhere

'';
                };
            } else {
                nix-daemon.enable = true;
            }));
        nix = {
            trustedUsers = [ "@admin" "hyunggyujang"];
            package = pkgs.nix;
        } // (if localconfig.hostname == "silicon" then {
            # See Fix �� �� Unnecessary NIX_PATH entry for single user installation in nix_darwin.org
            nixPath = mkForce [
                { darwin-config = "${config.environment.darwinConfig}"; }
                { localconfig = "${hgj_darwin_home}/${localconfig.hostname}.nix"; }
                "$HOME/.nix-defexpr/channels"
            ];
        } else {
            nixPath = [
                { localconfig = "${hgj_darwin_home}/${localconfig.hostname}.nix"; }
            ];
        });

        homebrew =  {
            enable = true;
            autoUpdate = true;
            cleanup = "zap";
            global.brewfile = true;
        } //
        (if localconfig.hostname == "classic" then {
            taps = [
                "homebrew/cask"
                "homebrew/core"
                "homebrew/services"
            ];
            casks = [
                "altserver"
                "karabiner-elements"
                "zotero"
                "microsoft-teams"
                "zoom"
                "anki"
                "ukelele"
                "aquaskk"
            ];
            brews = [
                "pngpaste"
            ];
        } else {
            brewPrefix = "/opt/homebrew/bin";
            taps = [
                "homebrew/bundle"
                "homebrew/cask"
                "homebrew/core"
                "homebrew/services"
                "homebrew/cask-fonts"
                "railwaycat/emacsmacport"
                "borkdude/brew"
            ];
            brews = [
                "pngpaste"
                "jq"
                "msmtp"
                "aspell"
                "graphviz"
                "zstd"
                "nodejs"
                "isync"
                "libvterm"
                "ripgrep"
                "git"
                "gnupg"
                "pass"
                "lua"
                "luarocks"
                "gmp"
                "coreutils"
                "gnuplot"
                "imagemagick"
                "octave"
                "fd"
                "pkg-config"
                "poppler"
                "automake"
                "cmake"
                "python"
                "findutils"
                "z3"
                "coq"
                "pandoc"
                "pinentry-mac"
                # Fonts
                "svn"
                # emacs-mac dependencies
                "jansson"
                "libxml2"
                # suggested by Doom emacs
                "pipenv"
                "jupyterlab"
                # For projectile
                "ctags"
                # Lexic
                "sdcv"
                # Prover
                "lean"
                # Clojure
                "clj-kondo"
                # Spacehammer
                "fnlfmt"
            ];
            casks = [
                "appcleaner"
                "slack"
                "basictex"
                "kitty"
                "altserver"
                "anki"
                "aquaskk"
                "hammerspoon"
                "karabiner-elements"
                "microsoft-powerpoint"
                "onedrive"
                "microsoft-teams"
                "zoom"
                "ukelele"
                "zotero"
                "inkscape"
                # elegant-emacs
                "font-roboto-mono"
                "font-roboto-slab"
                # math font
                "font-dejavu"
                # beamer with xelatex
                "font-fira-sans"
                "font-fira-mono"
		# IBM fonts
                "font-ibm-plex"
            ];
            extraConfig = ''
        brew "emacs-mac", args: ["with-no-title-bars", "with-starter"]
        brew "notmuch", args: ["HEAD"]
        cask "firefox", args: { language: "en-KR" }
      '';
        });
    }
