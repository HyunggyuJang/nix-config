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
            home.stateVersion = "22.11";
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
          bind --mode=insert <C-p> !s skhd -k up
          bind --mode=insert <C-n> !s skhd -k down
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
                "Library/Application Support/org.inkscape.Inkscape/config/inkscape/extensions/svg2tikz".source = with pkgs; stdenv.mkDerivation {
                  name = "svg2tikz";
                  src = fetchFromGitHub {
                    owner = "xyz2tex";
                    repo = "svg2tikz";
                    rev = "8e56b5752de4b330a436b70e57ba55603232737a";
                    sha256 = "sha256-IKLg9+ztG96b9A5dI3Ek9upiWoiUX9V09P5KWzlnVIo=";
                  };
                  phases = ["unpackPhase" "installPhase"];
                  installPhase = ''
                  cp -R svg2tikz/extensions $out
                  '';
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
### sub-rule.desc -- Ë£úÂä©„É´„Éº„É´„ÅÆË™¨Êòé
###

azik_us.rule azik.conf Use„ÄåAZIK„Äçextension
                '';
                "Library/Application Support/AquaSKK/azik_us.rule".text = ''
###
### azik_us.rule -- AZIK Õ—¿ﬂƒÍ
###

',§√,•√,éØ

b.,§÷,•÷,éÃéﬁ
bd,§Ÿ§Û,•Ÿ•Û,éÕéﬁé›
bh,§÷§¶,•÷•¶,éÃéﬁé≥
bj,§÷§Û,•÷•Û,éÃéﬁé›
bk,§”§Û,•”•Û,éÀéﬁé›
bl,§‹§Û,•‹•Û,éŒéﬁé›
bn,§–§Û,•–•Û,é éﬁé›
bp,§‹§¶,•‹•¶,éŒéﬁé≥
bq,§–§§,•–•§,é éﬁé≤
br,§–§È,•–•È,é éﬁé◊
bt,§”§»,•”•»,éÀéﬁéƒ
bw,§Ÿ§§,•Ÿ•§,éÕéﬁé≤
bx,§Ÿ§§,•Ÿ•§,éÕéﬁé≤
bz,§–§Û,•–•Û,é éﬁé›

byd,§”§ß§Û,•”•ß•Û,éÀéﬁé™é›
byh,§”§Â§¶,•”•Â•¶,éÀéﬁé≠é≥
byj,§”§Â§Û,•”•Â•Û,éÀéﬁé≠é›
byl,§”§Á§Û,•”•Á•Û,éÀéﬁéÆé›
byn,§”§„§Û,•”•„•Û,éÀéﬁé¨é›
byp,§”§Á§¶,•”•Á•¶,éÀéﬁéÆé≥
byq,§”§„§§,•”•„•§,éÀéﬁé¨é≤
byw,§”§ß§§,•”•ß•§,éÀéﬁé™é≤
byz,§”§„§Û,•”•„•Û,éÀéﬁé¨é›

ca,§¡§„,•¡•„,é¡é¨
cc,§¡§„,•¡•„,é¡é¨
cd,§¡§ß§Û,•¡•ß•Û,é¡é™é›
ce,§¡§ß,•¡•ß,é¡é™
cf,§¡§ß,•¡•ß,é¡é™
ch,§¡§Â§¶,•¡•Â•¶,é¡é≠é≥
ci,§¡,•¡,é¡
cj,§¡§Â§Û,•¡•Â•Û,é¡é≠é›
ck,§¡§Û,•¡•Û,é¡é›
cl,§¡§Á§Û,•¡•Á•Û,é¡éÆé›
cn,§¡§„§Û,•¡•„•Û,é¡é¨é›
co,§¡§Á,•¡•Á,é¡éÆ
cp,§¡§Á§¶,•¡•Á•¶,é¡éÆé≥
cq,§¡§„§§,•¡•„•§,é¡é¨é≤
cu,§¡§Â,•¡•Â,é¡é≠
cv,§¡§„§§,•¡•„•§,é¡é¨é≤
cw,§¡§ß§§,•¡•ß•§,é¡é™é≤
cx,§¡§ß§§,•¡•ß•§,é¡é™é≤
cz,§¡§„§Û,•¡•„•Û,é¡é¨é›

dd,§«§Û,•«•Û,é√éﬁé›
df,§«,•«,é√éﬁ
dg,§¿§¨,•¿•¨,é¿éﬁé∂éﬁ
dh,§≈§¶,•≈•¶,é¬éﬁé≥
dj,§≈§Û,•≈•Û,é¬éﬁé›
dk,§¬§Û,•¬•Û,é¡éﬁé›
dl,§…§Û,•…•Û,éƒéﬁé›
dm,§«§‚,•«•‚,é√éﬁé”
dn,§¿§Û,•¿•Û,é¿éﬁé›
dp,§…§¶,•…•¶,éƒéﬁé≥
dq,§¿§§,•¿•§,é¿éﬁé≤
dr,§«§¢§Î,•«•¢•Î,é√éﬁé±éŸ
ds,§«§π,•«•π,é√éﬁéΩ
dt,§¿§¡,•¿•¡,é¿éﬁé¡
dv,§«§Û,•«•Û,é√éﬁé›
dw,§«§§,•«•§,é√éﬁé≤
dy,§«§£,•«•£,é√éﬁé®
dz,§¿§Û,•¿•Û,é¿éﬁé›
dch,§«§Â,•«•Â°º,é√éﬁé≠é∞
dci,§«§£,•«•£,é√éﬁé®
dck,§«§£§Û,•«•£•Û,é√éﬁé®é›
dcp,§…§•,•…••°º,éƒéﬁé©é∞
dcu,§«§Â,•«•Â,é√éﬁé≠

fd,§’§ß§Û,•’•ß•Û,éÃé™é›
fh,§’§¶,•’•¶,éÃé≥
fj,§’§Û,•’•Û,éÃé›
fk,§’§£§Û,•’•£•Û,éÃé®é›
fl,§’§©§Û,•’•©•Û,éÃé´é›
fm,§’§‡,•’•‡,éÃé—
fn,§’§°§Û,•’•°•Û,éÃéßé›
fp,§’§©,•’•©°º,éÃé´é∞
fq,§’§°§§,•’•°•§,éÃéßé≤
fr,§’§Î,•’•Î,éÃéŸ
fs,§’§°§§,•’•°•§,éÃéßé≤
fw,§’§ß§§,•’•ß•§,éÃé™é≤
fz,§’§°§Û,•’•°•Û,éÃéßé›

gd,§≤§Û,•≤•Û,éπéﬁé›
gh,§∞§¶,•∞•¶,é∏éﬁé≥
gj,§∞§Û,•∞•Û,é∏éﬁé›
gk,§Æ§Û,•Æ•Û,é∑éﬁé›
gl,§¥§Û,•¥•Û,é∫éﬁé›
gn,§¨§Û,•¨•Û,é∂éﬁé›
gp,§¥§¶,•¥•¶,é∫éﬁé≥
gq,§¨§§,•¨•§,é∂éﬁé≤
gr,§¨§È,•¨•È,é∂éﬁé◊
gt,§¥§»,•¥•»,é∫éﬁéƒ
gw,§≤§§,•≤•§,éπéﬁé≤
gz,§¨§Û,•¨•Û,é∂éﬁé›

gyd,§Æ§ß§Û,•Æ•ß•Û,é∑éﬁé™é›
gyh,§Æ§Â§¶,•Æ•Â•¶,é∑éﬁé≠é≥
gyj,§Æ§Â§Û,•Æ•Â•Û,é∑éﬁé≠é›
gyl,§Æ§Á§Û,•Æ•Á•Û,é∑éﬁéÆé›
gyn,§Æ§„§Û,•Æ•„•Û,é∑éﬁé¨é›
gyp,§Æ§Á§¶,•Æ•Á•¶,é∑éﬁéÆé≥
gyq,§Æ§„§§,•Æ•„•§,é∑éﬁé¨é≤
gyw,§Æ§ß§§,•Æ•ß•§,é∑éﬁé™é≤
gyz,§Æ§„§Û,•Æ•„•Û,é∑éﬁé¨é›

hd,§ÿ§Û,•ÿ•Û,éÕé›
hf,§’,•’,éÃ
hh,§’§¶,•’•¶,éÃé≥
hj,§’§Û,•’•Û,éÃé›
hk,§“§Û,•“•Û,éÀé›
hl,§€§Û,•€•Û,éŒé›
hn,§œ§Û,•œ•Û,é é›
hp,§€§¶,•€•¶,éŒé≥
hq,§œ§§,•œ•§,é é≤
ht,§“§»,•“•»,éÀéƒ
hw,§ÿ§§,•ÿ•§,éÕé≤
hz,§œ§Û,•œ•Û,é é›
hga,§“§„,•“•„,éÀé¨
hgd,§“§ß§Û,•“•ß•Û,éÀé™é›
hge,§“§ß,•“•ß,éÀé™
hgh,§“§Â§¶,•“•Â•¶,éÀé≠é≥
hgj,§“§Â§Û,•“•Â•Û,éÀé≠é›
hgl,§“§Á§Û,•“•Á•Û,éÀéÆé›
hgn,§“§„§Û,•“•„•Û,éÀé¨é›
hgo,§“§Á,•“•Á,éÀéÆ
hgp,§“§Á§¶,•“•Á•¶,éÀéÆé≥
hgq,§“§„§§,•“•„•§,éÀé¨é≤
hgu,§“§Â,•“•Â,éÀé≠
hgw,§“§ß§§,•“•ß•§,éÀé™é≤
hgz,§“§„§Û,•“•„•Û,éÀé¨é›
hyd,§“§ß§Û,•“•ß•Û,éÀé™é›
hyh,§“§Â§¶,•“•Â•¶,éÀé≠é≥
hyl,§“§Á§Û,•“•Á•Û,éÀéÆé›
hyp,§“§Á§¶,•“•Á•¶,éÀéÆé≥
hyq,§“§„§§,•“•„•§,éÀé¨é≤
hyw,§“§ß§§,•“•ß•§,éÀé™é≤
hyz,§“§„§Û,•“•„•Û,éÀé¨é›

jd,§∏§ß§Û,•∏•ß•Û,éºéﬁé™é›
jf,§∏§Â,•∏•Â,éºéﬁé≠
jh,§∏§Â§¶,•∏•Â•¶,éºéﬁé≠é≥
jj,§∏§Â§Û,•∏•Â•Û,éºéﬁé≠é›
jk,§∏§Û,•∏•Û,éºéﬁé›
jl,§∏§Á§Û,•∏•Á•Û,éºéﬁéÆé›
jn,§∏§„§Û,•∏•„•Û,éºéﬁé¨é›
jp,§∏§Á§¶,•∏•Á•¶,éºéﬁéÆé≥
jq,§∏§„§§,•∏•„•§,éºéﬁé¨é≤
jv,§∏§Â§¶,•∏•Â•¶,éºéﬁé≠é≥
jw,§∏§ß§§,•∏•ß•§,éºéﬁé™é≤
jz,§∏§„§Û,•∏•„•Û,éºéﬁé¨é›

kA,•ı,•ı,é∂
kE,•ˆ,•ˆ,éπ
kd,§±§Û,•±•Û,éπé›
kf,§≠,•≠,é∑
kh,§Ø§¶,•Ø•¶,é∏é≥
kj,§Ø§Û,•Ø•Û,é∏é›
kk,§≠§Û,•≠•Û,é∑é›
kl,§≥§Û,•≥•Û,é∫é›
km,§≠,•≠,é∑
kn,§´§Û,•´•Û,é∂é›
kp,§≥§¶,•≥•¶,é∫é≥
kq,§´§§,•´•§,é∂é≤
kr,§´§È,•´•È,é∂é◊
kt,§≥§»,•≥•»,é∫éƒ
kv,§≠§Û,•≠•Û,é∑é›
kw,§±§§,•±•§,éπé≤
kz,§´§Û,•´•Û,é∂é›
kga,§≠§„,•≠•„,é∑é¨
kgd,§≠§ß§Û,•≠•ß•Û,é∑é™é›
kge,§≠§ß,•≠•ß,é∑é™
kgh,§≠§Â§¶,•≠•Â•¶,é∑é≠é≥
kgl,§≠§Á§Û,•≠•Á•Û,é∑éÆé›
kgn,§≠§„§Û,•≠•„•Û,é∑é¨é›
kgo,§≠§Á,•≠•Á,é∑éÆ
kgp,§≠§Á§¶,•≠•Á•¶,é∑éÆé≥
kgq,§≠§„§§,•≠•„•§,é∑é¨é≤
kgu,§≠§Â,•≠•Â,é∑é≠
kgw,§≠§ß§§,•≠•ß•§,é∑é™é≤
kgz,§≠§„§Û,•≠•„•Û,é∑é¨é›
kyd,§≠§ß§Û,•≠•ß•Û,é∑é™é›
kyh,§≠§Â§¶,•≠•Â•¶,é∑é≠é≥
kyj,§≠§Â§Û,•≠•Â•Û,é∑é≠é›
kyl,§≠§Á§Û,•≠•Á•Û,é∑éÆé›
kyn,§≠§„§Û,•≠•„•Û,é∑é¨é›
kyp,§≠§Á§¶,•≠•Á•¶,é∑éÆé≥
kyq,§≠§„§§,•≠•„•§,é∑é¨é≤
kyw,§≠§ß§§,•≠•ß•§,é∑é™é≤
kyz,§≠§„§Û,•≠•„•Û,é∑é¨é›

m.,§‡,•‡,é—
md,§·§Û,•·•Û,é“é›
mf,§‡,•‡,é—
mh,§‡§¶,•‡•¶,é—é≥
mj,§‡§Û,•‡•Û,é—é›
mk,§ﬂ§Û,•ﬂ•Û,é–é›
ml,§‚§Û,•‚•Û,é”é›
mn,§‚§Œ,•‚•Œ,é”é…
mp,§‚§¶,•‚•¶,é”é≥
mq,§ﬁ§§,•ﬁ•§,éœé≤
mr,§ﬁ§Î,•ﬁ•Î,éœéŸ
ms,§ﬁ§π,•ﬁ•π,éœéΩ
mt,§ﬁ§ø,•ﬁ•ø,éœé¿
mv,§‡§Û,•‡•Û,é—é›
mw,§·§§,•·•§,é“é≤
mz,§ﬁ§Û,•ﬁ•Û,éœé›
mga,§ﬂ§„,•ﬂ•„,é–é¨
mgd,§ﬂ§ß§Û,•ﬂ•ß•Û,é–é™é›
mge,§ﬂ§ß,•ﬂ•ß,é–é™
mgh,§ﬂ§Â§¶,•ﬂ•Â•¶,é–é≠é≥
mgj,§ﬂ§Â§Û,•ﬂ•Â•Û,é–é≠é›
mgl,§ﬂ§Á§Û,•ﬂ•Á•Û,é–éÆé›
mgn,§ﬂ§„§Û,•ﬂ•„•Û,é–é¨é›
mgo,§ﬂ§Á,•ﬂ•Á,é–éÆ
mgp,§ﬂ§Á§¶,•ﬂ•Á•¶,é–éÆé≥
mgq,§ﬂ§„§§,•ﬂ•„•§,é–é¨é≤
mgu,§ﬂ§Â,•ﬂ•Â,é–é≠
mgw,§ﬂ§ß§§,•ﬂ•ß•§,é–é™é≤
mgz,§ﬂ§„§Û,•ﬂ•„•Û,é–é¨é›
myd,§ﬂ§ß§Û,•ﬂ•ß•Û,é–é™é›
myh,§ﬂ§Â§¶,•ﬂ•Â•¶,é–é≠é≥
myj,§ﬂ§Â§Û,•ﬂ•Â•Û,é–é≠é›
myl,§ﬂ§Á§Û,•ﬂ•Á•Û,é–éÆé›
myn,§ﬂ§„§Û,•ﬂ•„•Û,é–é¨é›
myp,§ﬂ§Á§¶,•ﬂ•Á•¶,é–éÆé≥
myq,§ﬂ§„§§,•ﬂ•„•§,é–é¨é≤
myw,§ﬂ§ß§§,•ﬂ•ß•§,é–é™é≤
myz,§ﬂ§„§Û,•ﬂ•„•Û,é–é¨é›

n.,§Ã,•Ã,é«
nb,§Õ§–,•Õ•–,é»é éﬁ
nd,§Õ§Û,•Õ•Û,é»é›
nf,§Ã,•Ã,é«
nh,§Ã§¶,•Ã•¶,é«é≥
nj,§Ã§Û,•Ã•Û,é«é›
nk,§À§Û,•À•Û,é∆é›
nl,§Œ§Û,•Œ•Û,é…é›
np,§Œ§¶,•Œ•¶,é…é≥
nq,§ §§,• •§,é≈é≤
nr,§ §Î,• •Î,é≈éŸ
nt,§À§¡,•À•¡,é∆é¡
nv,§Ã§Û,•Ã•Û,é«é›
nw,§Õ§§,•Õ•§,é»é≤
nz,§ §Û,• •Û,é≈é›
nga,§À§„,•À•„,é∆é¨
ngd,§À§ß§Û,•À•ß•Û,é∆é™é›
nge,§À§ß,•À•ß,é∆é™
ngh,§À§Â§¶,•À•Â•¶,é∆é≠é≥
ngj,§À§Â§Û,•À•Â•Û,é∆é≠é›
ngl,§À§Á§Û,•À•Á•Û,é∆éÆé›
ngn,§À§„§Û,•À•„•Û,é∆é¨é›
ngo,§À§Á,•À•Á,é∆éÆ
ngp,§À§Á§¶,•À•Á•¶,é∆éÆé≥
ngq,§À§„§§,•À•„•§,é∆é¨é≤
ngu,§À§Â,•À•Â,é∆é≠
ngw,§À§ß§§,•À•ß•§,é∆é™é≤
ngz,§À§„§Û,•À•„•Û,é∆é¨é›
nyd,§À§ß§Û,•À•ß•Û,é∆é™é›
nyh,§À§Â§¶,•À•Â•¶,é∆é≠é≥
nyj,§À§Â§Û,•À•Â•Û,é∆é≠é›
nyl,§À§Á§Û,•À•Á•Û,é∆éÆé›
nyn,§À§„§Û,•À•„•Û,é∆é¨é›
nyp,§À§Á§¶,•À•Á•¶,é∆éÆé≥
nyq,§À§„§§,•À•„•§,é∆é¨é≤
nyw,§À§ß§§,•À•ß•§,é∆é™é≤
nyz,§À§„§Û,•À•„•Û,é∆é¨é›

pd,§⁄§Û,•⁄•Û,éÕéﬂé›
pf,§›§Û,•›•Û,éŒéﬂé›
ph,§◊§¶,•◊•¶,éÃéﬂé≥
pj,§◊§Û,•◊•Û,éÃéﬂé›
pk,§‘§Û,•‘•Û,éÀéﬂé›
pl,§›§Û,•›•Û,éŒéﬂé›
pn,§—§Û,•—•Û,é éﬂé›
pp,§›§¶,•›•¶,éŒéﬂé≥
pq,§—§§,•—•§,é éﬂé≤
pv,§›§¶,•›•¶,éŒéﬂé≥
pw,§⁄§§,•⁄•§,éÕéﬂé≤
pz,§—§Û,•—•Û,é éﬂé›
pga,§‘§„,•‘•„,éÀéﬂé¨
pgd,§‘§ß§Û,•‘•ß•Û,éÀéﬂé™é›
pge,§‘§ß,•‘•ß,éÀéﬂé™
pgh,§‘§Â§¶,•‘•Â•¶,éÀéﬂé≠é≥
pgj,§‘§Â§Û,•‘•Â•Û,éÀéﬂé≠é›
pgl,§‘§Á§Û,•‘•Á•Û,éÀéﬂéÆé›
pgn,§‘§„§Û,•‘•„•Û,éÀéﬂé¨é›
pgo,§‘§Á,•‘•Á,éÀéﬂéÆ
pgp,§‘§Á§¶,•‘•Á•¶,éÀéﬂéÆé≥
pgq,§‘§„§§,•‘•„•§,éÀéﬂé¨é≤
pgu,§‘§Â,•‘•Â,éÀéﬂé≠
pgw,§‘§ß§§,•‘•ß•§,éÀéﬂé™é≤
pgz,§‘§„§Û,•‘•„•Û,éÀéﬂé¨é›
pyd,§‘§ß§Û,•‘•ß•Û,éÀéﬂé™é›
pyh,§‘§Â§¶,•‘•Â•¶,éÀéﬂé≠é≥
pyj,§‘§Â§Û,•‘•Â•Û,éÀéﬂé≠é›
pyl,§‘§Á§Û,•‘•Á•Û,éÀéﬂéÆé›
pyn,§‘§„§Û,•‘•„•Û,éÀéﬂé¨é›
pyp,§‘§Á§¶,•‘•Á•¶,éÀéﬂéÆé≥
pyq,§‘§„§§,•‘•„•§,éÀéﬂé¨é≤
pyw,§‘§ß§§,•‘•ß•§,éÀéﬂé™é≤
pyz,§‘§„§Û,•‘•„•Û,éÀéﬂé¨é›

q,§Û,•Û,é›

rd,§Ï§Û,•Ï•Û,é⁄é›
rh,§Î§¶,•Î•¶,éŸé≥
rj,§Î§Û,•Î•Û,éŸé›
rk,§Í§Û,•Í•Û,éÿé›
rl,§Ì§Û,•Ì•Û,é€é›
rn,§È§Û,•È•Û,é◊é›
rp,§Ì§¶,•Ì•¶,é€é≥
rq,§È§§,•È•§,é◊é≤
rr,§È§Ï,•È•Ï,é◊é⁄
rw,§Ï§§,•Ï•§,é⁄é≤
rz,§È§Û,•È•Û,é◊é›

ryd,§Í§ß§Û,•Í•ß•Û,éÿé™é›
ryh,§Í§Â§¶,•Í•Â•¶,éÿé≠é≥
ryj,§Í§Â§Û,•Í•Â•Û,éÿé≠é›
ryk,§Í§Á§Ø,•Í•Á•Ø,éÿéÆé∏
ryl,§Í§Á§Û,•Í•Á•Û,éÿéÆé›
ryn,§Í§„§Û,•Í•„•Û,éÿé¨é›
ryp,§Í§Á§¶,•Í•Á•¶,éÿéÆé≥
ryq,§Í§„§§,•Í•„•§,éÿé¨é≤
ryw,§Í§ß§§,•Í•ß•§,éÿé™é≤
ryz,§Í§„§Û,•Í•„•Û,éÿé¨é›

sd,§ª§Û,•ª•Û,éæé›
sf,§µ§§,•µ•§,éªé≤
sh,§π§¶,•π•¶,éΩé≥
sj,§π§Û,•π•Û,éΩé›
sk,§∑§Û,•∑•Û,éºé›
sl,§Ω§Û,•Ω•Û,éøé›
sm,§∑§‚,•∑•‚,éºé”
sn,§µ§Û,•µ•Û,éªé›
sp,§Ω§¶,•Ω•¶,éøé≥
sq,§µ§§,•µ•§,éªé≤
sr,§π§Î,•π•Î,éΩéŸ
ss,§ª§§,•ª•§,éæé≤
st,§∑§ø,•∑•ø,éºé¿
sv,§µ§§,•µ•§,éªé≤
sw,§ª§§,•ª•§,éæé≤
sz,§µ§Û,•µ•Û,éªé›

syd,§∑§ß§Û,•∑•ß•Û,éºé™é›
syh,§∑§Â§¶,•∑•Â•¶,éºé≠é≥
syj,§∑§Â§Û,•∑•Â•Û,éºé≠é›
syl,§∑§Á§Û,•∑•Á•Û,éºéÆé›
syp,§∑§Á§¶,•∑•Á•¶,éºéÆé≥
syq,§∑§„§§,•∑•„•§,éºé¨é≤
syw,§∑§ß§§,•∑•ß•§,éºé™é≤
syz,§∑§„§Û,•∑•„•Û,éºé¨é›

tU,§√,•√,éØ
tb,§ø§”,•ø•”,é¿éÀéﬁ
td,§∆§Û,•∆•Û,é√é›
th,§ƒ§¶,•ƒ•¶,é¬é≥
tj,§ƒ§Û,•ƒ•Û,é¬é›
tk,§¡§Û,•¡•Û,é¡é›
tl,§»§Û,•»•Û,éƒé›
tm,§ø§·,•ø•·,é¿é“
tn,§ø§Û,•ø•Û,é¿é›
tp,§»§¶,•»•¶,éƒé≥
tq,§ø§§,•ø•§,é¿é≤
tr,§ø§È,•ø•È,é¿é◊
tt,§ø§¡,•ø•¡,é¿é¡
tw,§∆§§,•∆•§,é√é≤
tz,§ø§Û,•ø•Û,é¿é›
tgh,§∆§Â,•∆•Â°º,é√é≠é∞
tgi,§∆§£,•∆•£,é√é®
tgk,§∆§£§Û,•∆•£•Û,é√é®é›
tgp,§»§•,•»••°º,éƒé©é∞
tgu,§∆§Â,•∆•Â,é√é≠
tsU,§√,•√,éØ
tsa,§ƒ§°,•ƒ•°,é¬éß
tse,§ƒ§ß,•ƒ•ß,é¬é™
tsi,§ƒ§£,•ƒ•£,é¬é®
tso,§ƒ§©,•ƒ•©,é¬é´
tyd,§¡§ß§Û,•¡•ß•Û,é¡é™é›
tyh,§¡§Â§¶,•¡•Â•¶,é¡é≠é≥
tyj,§¡§Â§Û,•¡•Â•Û,é¡é≠é›
tyl,§¡§Á§Û,•¡•Á•Û,é¡éÆé›
tyn,§¡§„§Û,•¡•„•Û,é¡é¨é›
typ,§¡§Á§¶,•¡•Á•¶,é¡éÆé≥
tyq,§¡§„§§,•¡•„•§,é¡é¨é≤
tyw,§¡§ß§§,•¡•ß•§,é¡é™é≤
tyz,§¡§„§Û,•¡•„•Û,é¡é¨é›

vd,§¶,•Ù•ß•Û,é≥éﬁé™é›
vk,§¶,•Ù•£•Û,é≥éﬁé®é›
vl,§¶,•Ù•©•Û,é≥éﬁé´é›
vn,§¶,•Ù•°•Û,é≥éﬁéßé›
vp,§¶,•Ù•©°º,é≥éﬁé´é∞
vq,§¶,•Ù•°•§,é≥éﬁéßé≤
vw,§¶,•Ù•ß•§,é≥éﬁé™é≤
vz,§¶,•Ù•°•Û,é≥éﬁéßé›
vya,§¶,•Ù•„,é≥éﬁé¨
vye,§¶,•Ù•ß,é≥éﬁé™
vyo,§¶,•Ù•Á,é≥éﬁéÆ
vyu,§¶,•Ù•Â,é≥éﬁé≠

wA,§Ó,•Ó,é‹
wd,§¶§ß§Û,•¶•ß•Û,é≥é™é›
wf,§Ô,•Ô,é‹
wk,§¶§£§Û,•¶•£•Û,é≥é®é›
wl,§¶§©§Û,•¶•©•Û,é≥é´é›
wn,§Ô§Û,•Ô•Û,é‹é›
wp,§¶§©,•¶•©°º,é≥é´é∞
wq,§Ô§§,•Ô•§,é‹é≤
wr,§Ô§Ï,•Ô•Ï,é‹é⁄
wt,§Ô§ø,•Ô•ø,é‹é¿
wz,§Ô§Û,•Ô•Û,é‹é›
wha,§¶§°,•¶•°,é≥éß
whe,§¶§ß,•¶•ß,é≥é™
whi,§¶§£,•¶•£,é≥é®
who,§¶§©,•¶•©,é≥é´
whu,§¶,•¶,é≥
wso,§¶§©,•¶•©,é≥é´

x;,°®,°®,;
z;,°ß,°ß,:

xa,§∑§„,•∑•„,éºé¨
xc,§∑§„,•∑•„,éºé¨
xd,§∑§ß§Û,•∑•ß•Û,éºé™é›
xe,§∑§ß,•∑•ß,éºé™
xf,§∑§ß§§,•∑•ß•§,éºé™é≤
xh,§∑§Â§¶,•∑•Â•¶,éºé≠é≥
xi,§∑,•∑,éº
xj,§∑§Â§Û,•∑•Â•Û,éºé≠é›
xk,§∑§Û,•∑•Û,éºé›
xl,§∑§Á§Û,•∑•Á•Û,éºéÆé›
xn,§∑§„§Û,•∑•„•Û,éºé¨é›
xo,§∑§Á,•∑•Á,éºéÆ
xp,§∑§Á§¶,•∑•Á•¶,éºéÆé≥
xq,§∑§„§§,•∑•„•§,éºé¨é≤
xt,§∑§Â§ƒ,•∑•Â•ƒ,éºé≠é¬
xu,§∑§Â,•∑•Â,éºé≠
xv,§∑§„§§,•∑•„•§,éºé¨é≤
xw,§∑§ß§§,•∑•ß•§,éºé™é≤
xz,§∑§„§Û,•∑•„•Û,éºé¨é›
xxa,§°,•°,éß
xxe,§ß,•ß,é™
xxi,§£,•£,é®
xxo,§©,•©,é´
xxu,§•,••,é©

yh,§Ê§¶,•Ê•¶,é’é≥
yi,§,•,é≤
yj,§Ê§Û,•Ê•Û,é’é›
yl,§Ë§Û,•Ë•Û,é÷é›
yn,§‰§Û,•‰•Û,é‘é›
yp,§Ë§¶,•Ë•¶,é÷é≥
yq,§‰§§,•‰•§,é‘é≤
yr,§Ë§Î,•Ë•Î,é÷éŸ
yv,§Ê§¶,•Ê•¶,é’é≥
yz,§‰§Û,•‰•Û,é‘é›

z.,§∫,•∫,éΩéﬁ
zc,§∂,•∂,éªéﬁ
zd,§º§Û,•º•Û,éæéﬁé›
zf,§º,•º,éæéﬁ
zh,§∫§¶,•∫•¶,éΩéﬁé≥
zj,§∫§Û,•∫•Û,éΩéﬁé›
zk,§∏§Û,•∏•Û,éºéﬁé›
zl,§æ§Û,•æ•Û,éøéﬁé›
zn,§∂§Û,•∂•Û,éªéﬁé›
zp,§æ§¶,•æ•¶,éøéﬁé≥
zq,§∂§§,•∂•§,éªéﬁé≤
zr,§∂§Î,•∂•Î,éªéﬁéŸ
zv,§∂§§,•∂•§,éªéﬁé≤
zw,§º§§,•º•§,éæéﬁé≤
zx,§º§§,•º•§,éæéﬁé≤
zz,§∂§Û,•∂•Û,éªéﬁé›
zyd,§∏§ß§Û,•∏•ß•Û,éºéﬁé™é›
zyh,§∏§Â§¶,•∏•Â•¶,éºéﬁé≠é≥
zyj,§∏§Â§Û,•∏•Â•Û,éºéﬁé≠é›
zyl,§∏§Á§Û,•∏•Á•Û,éºéﬁéÆé›
zyn,§∏§„§Û,•∏•„•Û,éºéﬁé¨é›
zyp,§∏§Á§¶,•∏•Á•¶,éºéﬁéÆé≥
zyq,§∏§„§§,•∏•„•§,éºéﬁé¨é≤
zyw,§∏§ß§§,•∏•ß•§,éºéﬁé™é≤
zyz,§∏§„§Û,•∏•„•Û,éºéﬁé¨é›
x[,°÷,°÷,°÷

# kana-rule.conf  §À [ §À¬–§π§Î —¥πµ¨¬ß§¨ƒÍµ¡§µ§Ï§∆§§§Î§Œ§«°¢ToggleKana §¨¿µ§∑§Ø∆∞∫Ó§∑§ §§°£
# §Ω§≥§«°¢ [ §Œ —¥πµ¨¬ß§Ú§¢§§§ﬁ§§§À§∑§∆°¢ —¥π§µ§Ï§ §§§Ë§¶§À§π§Î
[[,°÷,°÷,°÷
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
          Host mail.math.nagoya-u.ac.jp
          User hyunggyu.jang.e6@math.nagoya-u.ac.jp #not XXX@me.com etc.
          AuthMechs LOGIN
          PassCmd "pass math.nagoya-u.ac.jp"
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
          account        hyunggyu.jang.e6@math.nagoya-u.ac.jp
          host           smtp.math.nagoya-u.ac.jp
          port           443
          protocol       smtp
          # https://help.zoho.com/portal/en/community/topic/msmtp
          from	         hyunggyu.jang.e6@math.nagoya-u.ac.jp
          user           hyunggyu.jang.e6@math.nagoya-u.ac.jp
          passwordeval   "pass math.nagoya-u.ac.jp"
          tls_starttls   off

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
                # ".hammerspoon".source = fetchGit {
                #     url = "https://github.com/HyunggyuJang/spacehammer.git";
                #     rev = "d2c9b655d937fc30b9d84a48ed171e89c2989c8f";
                #     submodules = true;
                # };
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
                        "description": "„Ç≥„Éû„É≥„Éâ„Ç≠„Éº„Çí„Ç™„Éó„Ç∑„Éß„É≥„Ç≠„Éº„Å´ÁΩÆ„ÅçÊèõ„Åà„Çã„ÄÇ",
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
                        "description": "Ëã±Êï∞„Éª„Åã„Å™„Ç≠„Éº„Çí‰ªñ„ÅÆ„Ç≠„Éº„Å®ÁµÑ„ÅøÂêà„Çè„Åõ„Å¶Êäº„Åó„Åü„Å®„Åç„Å´„ÄÅ„Ç≥„Éû„É≥„Éâ„Ç≠„Éº„ÇíÈÄÅ‰ø°„Åô„Çã„ÄÇ",
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
                        "description": "Change left control to control if pressed with other keys, to escape if pressed alone.",
                        "manipulators": [
                            {
                                "from": {
                                    "key_code": "left_control",
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
                        "description": "Change to English layout if Left ‚åò key pressed alone, else send ‚åò key.",
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
                                        "consumer_key_code": "eject",
                                        "modifiers": [
                                            "left_gui",
                                            "left_alt"
                                        ],
                                        "repeat": false
                                    }
                                ],
                                "type": "basic"
                            }
                        ]
                    }
                ]
            },
            "devices": [
                {
                    "disable_built_in_keyboard_if_exists": true,
                    "fn_function_keys": [],
                    "identifiers": {
                        "is_keyboard": true,
                        "is_pointing_device": false,
                        "product_id": 33,
                        "vendor_id": 1278
                    },
                    "ignore": false,
                    "manipulate_caps_lock_led": true,
                    "simple_modifications": [
                        {
                            "from": {
                                "key_code": "left_control"
                            },
                            "to": [
                                {
                                    "key_code": "escape"
                                }
                            ]
                        }
                    ]
                },
                {
                    "disable_built_in_keyboard_if_exists": true,
                    "fn_function_keys": [],
                    "identifiers": {
                        "is_keyboard": true,
                        "is_pointing_device": false,
                        "product_id": 569,
                        "vendor_id": 1452
                    },
                    "ignore": false,
                    "manipulate_caps_lock_led": true,
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
                    ]
                },
                {
                    "disable_built_in_keyboard_if_exists": false,
                    "fn_function_keys": [],
                    "identifiers": {
                        "is_keyboard": true,
                        "is_pointing_device": false,
                        "product_id": 641,
                        "vendor_id": 1452
                    },
                    "ignore": false,
                    "manipulate_caps_lock_led": true,
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
                    ]
                }
            ],
            "fn_function_keys": [
                {
                    "from": {
                        "key_code": "f1"
                    },
                    "to": [
                        {
                            "consumer_key_code": "display_brightness_decrement"
                        }
                    ]
                },
                {
                    "from": {
                        "key_code": "f2"
                    },
                    "to": [
                        {
                            "consumer_key_code": "display_brightness_increment"
                        }
                    ]
                },
                {
                    "from": {
                        "key_code": "f3"
                    },
                    "to": [
                        {
                            "apple_vendor_keyboard_key_code": "mission_control"
                        }
                    ]
                },
                {
                    "from": {
                        "key_code": "f4"
                    },
                    "to": [
                        {
                            "apple_vendor_keyboard_key_code": "spotlight"
                        }
                    ]
                },
                {
                    "from": {
                        "key_code": "f5"
                    },
                    "to": [
                        {
                            "consumer_key_code": "dictation"
                        }
                    ]
                },
                {
                    "from": {
                        "key_code": "f6"
                    },
                    "to": [
                        {
                            "key_code": "f6"
                        }
                    ]
                },
                {
                    "from": {
                        "key_code": "f7"
                    },
                    "to": [
                        {
                            "consumer_key_code": "rewind"
                        }
                    ]
                },
                {
                    "from": {
                        "key_code": "f8"
                    },
                    "to": [
                        {
                            "consumer_key_code": "play_or_pause"
                        }
                    ]
                },
                {
                    "from": {
                        "key_code": "f9"
                    },
                    "to": [
                        {
                            "consumer_key_code": "fast_forward"
                        }
                    ]
                },
                {
                    "from": {
                        "key_code": "f10"
                    },
                    "to": [
                        {
                            "consumer_key_code": "mute"
                        }
                    ]
                },
                {
                    "from": {
                        "key_code": "f11"
                    },
                    "to": [
                        {
                            "consumer_key_code": "volume_decrement"
                        }
                    ]
                },
                {
                    "from": {
                        "key_code": "f12"
                    },
                    "to": [
                        {
                            "consumer_key_code": "volume_increment"
                        }
                    ]
                }
            ],
            "name": "Default profile",
            "parameters": {
                "delay_milliseconds_before_open_device": 1000
            },
            "selected": true,
            "simple_modifications": [],
            "virtual_hid_keyboard": {
                "country_code": 0,
                "indicate_sticky_modifier_keys_state": true,
                "mouse_key_xy_scale": 100
            }
        }
    ]
}
'';
                    "youtube-dl/config".text = ''
# Save all vides under Youtube directory in cloud server
-o ~/storage/Youtube/%(title)s.%(ext)s
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
                    dswitch = "cd ${hgj_darwin_home} && HOSTNAME=${localconfig.hostname} TERM=xterm-256color caffeinate -i make switch && cd -";
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
                                url = "https://gist.githubusercontent.com/HyunggyuJang/850b22128515b257ff3da73b589d7d3b/raw/3660504d2874a46a048b291a8ceabe8af9778294/system-wide-clipboard.zsh";
                                sha256 = "sha256-fmLcHhD2Cb45OEmIQi8mp9Q1uid1Osy9/kFxelHp70Y=";
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
          PATH=$PATH:${brewpath}/bin fpath+=$(brew --prefix)/share/zsh/site-functions
        else
          echo -e "\e[1;31merror: Homebrew is not installed, skipping...\e[0m" >&2
        fi
    '';
                initExtra = ''
        PROMPT=' %{$fg_bold[blue]%}$(get_pwd)%{$reset_color%} ''${prompt_suffix}'
        local prompt_suffix="%(?:%{$fg_bold[green]%}‚ùØ :%{$fg_bold[red]%}‚ùØ%{$reset_color%} "
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

        export NVM_DIR="$HOME/.nvm"
        [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && . "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
        [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && . "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

        # opam
        [[ ! -r /Users/hyunggyujang/.opam/opam-init/init.zsh ]] || source /Users/hyunggyujang/.opam/opam-init/init.zsh  > /dev/null 2> /dev/null
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
                    # For work with kazuki
                    metamask
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
                # "$(${brewpath}/bin/python -m site --user-base)/bin"
                # rust
                "$HOME/.cargo/bin"
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
                yaskkserv2
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
                skhd
                shellcheck # Not yet available
                # octave # nix-build-qrupdate aren't ready -- See https://github.com/NixOS/nixpkgs/issues/140041
                solc-select
                # ligo-lsp
                tree-sitter
                stack
                llvm
                # Tezos
                rustup
            ];
            pathsToLink = [
              "/lib"
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
open < f : skhd -k "ctrl - g"; open -a "/Applications/firefox.app"

open < s : skhd -k "ctrl - g"; open -a Slack

open < r : skhd -k "ctrl - g"; open -a Zotero

open < a : skhd -k "ctrl - g"; open -a Anki

open < z : skhd -k "ctrl - g"; open -a zoom.us

open < t : skhd -k "ctrl - g"; open -a "Microsoft Teams"

open < c : skhd -k "ctrl - g"; open -a "Visual Studio Code"

open < i : skhd -k "ctrl - g"; doom everywhere
'';
                };
            } else {
                nix-daemon.enable = true;
            }));
        nix = {
            trustedUsers = [ "@admin" "hyunggyujang"];
            package = pkgs.nix;
        } // (if localconfig.hostname == "silicon" then {
            # See Fix ‚ö†Ô∏è ‚Äî Unnecessary NIX_PATH entry for single user installation in nix_darwin.org
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
                # For beta version
                "homebrew/cask-versions"
                "railwaycat/emacsmacport"
                "borkdude/brew"
                # yabai
                "koekeishiya/formulae"
                # system data cleaner
                "fwartner/tap"
            ];
            brews = [
                "pngpaste"
                "jq"
                "msmtp"
                "aspell"
                "graphviz"
                "zstd"
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
                "poppler"
                "automake"
                "cmake"
                "python"
                "findutils"
                "z3"
                "pandoc"
                "pinentry-mac"
                # Fonts
                "svn"
                # emacs-mac dependencies
                "jansson"
                "libxml2"
                # suggested by Doom emacs
                "pyenv"
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
                # ISUCON
                "go"
                "mysql"
                # Blog
                "hugo"
                # Javascript
                "nvm"
                # Arthswap slither
                "poetry"
                # emacs-mac
                "libgccjit"
                # Garrigue project
                # "ocaml"
                "opam"
                # "coq"
                "parallel"
                "youtube-dl"
                # By Sehun
                # "htop-osx"
                # GPU programming
                "glslang"
                # tezos
                "hidapi"
                # WASM
                "binaryen"
                # To cleanup system data
                "mac-cleanup"
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
                "discord"
                # Custom brew to install 2.2.18 version
                # "vagrant-m1"
                # "vagrant-vmware-utility"
                # "vmware-fusion-tech-preview"
                # Docker
                "docker"
                # IDE based on web development
                "visual-studio-code"
                # VPN
                "Tunnelblick"
                # Garrigue lab
                "element"
                "skype"
                # Data analysis class
                "microsoft-excel"
                # School
                "microsoft-word"
                # audit
                "telegram"
                # For google meet
                "google-chrome"
            ] ++ (if localconfig.hostname == "work" then [
                # IBM fonts
                "font-ibm-plex"
            ] else []);
            extraConfig = ''
        brew "emacs-mac", args: ["with-native-comp", "with-no-title-bars", "with-starter"]
        brew "notmuch", args: ["HEAD"]
        cask "firefox", args: { language: "en-KR" }
        brew "yabai", start_service: true
      '';
        });
    }
