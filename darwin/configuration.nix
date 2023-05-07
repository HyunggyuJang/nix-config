let darwin = builtins.fetchTarball {
      # Get the revision by choosing a version from https://github.com/LnL7/nix-darwin
      url = "https://github.com/LnL7/nix-darwin/archive/87b9d090ad39b25b2400029c64825fc2a8868943.tar.gz";
      # Get the hash by running `nix-prefetch-url --unpack <url>` on the above url
      sha256 = "0c2naszb8xqi152m4b71vpi20cwacmxsx82ig8fgq61z9y05iiq2";
    };
    nixpkgsSrc = builtins.fetchTarball {
      # Get the revision by choosing a version from https://github.com/NixOS/nixpkgs
      url = "https://github.com/NixOS/nixpkgs/archive/f5ffd5787786dde3a8bf648c7a1b5f78c4e01abb.tar.gz";
      # Get the hash by running `nix-prefetch-url --unpack <url>` on the above url
      sha256 = "04ralbbvxr5flla3qqr6c87wziphr0ddwmj4099y0kh174k9aa4n";
    };
in
{ config ? (import darwin {}).config
, pkgs ? import nixpkgsSrc { system = builtins.currentSystem; }
, lib ? pkgs.lib
, ... }:

let hgj_home = builtins.getEnv "HOME";
    hgj_sync = hgj_home;
    hgj_darwin_home = "${hgj_sync}/nixpkgs/darwin";
    hgj_localbin = ".local/bin";
    localconfig = import <localconfig>;
    brewpath = "/opt/homebrew";

    nur = import (builtins.fetchTarball {
      # Get the revision by choosing a version from https://github.com/nix-community/NUR/commits/master
      url = "https://github.com/nix-community/NUR/archive/7dcad7f6b7ce15ba4fb6013deca282e7883ac3c3.tar.gz";
      # Get the hash by running `nix-prefetch-url --unpack <url>` on the above url
      sha256 = "13qzk8qji5cnhkh55cryahsj2981zdf4qw54z57hbf6sh49axpjx";
    }) {
      inherit pkgs;
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

    foundry = with pkgs; stdenv.mkDerivation {
      name = "foundry";
      src = fetchurl {
        url = "https://github.com/foundry-rs/foundry/releases/download/nightly-6c1eee9bdb1a49a302a0afe3597985346b7fb842/foundry_nightly_darwin_arm64.tar.gz";
        sha256 = "0ax90ammggqp9r96kdxgnnq6sl9yy7v508gfrlqym9ni12k7366h" ;
      };
      phases = ["installPhase"];
      installPhase = ''
        mkdir -p $out/bin
        tar -xf $src
        cp * $out/bin/
      '';
    };

in with lib;
  rec {
    # Home manager
    imports = [
      ''${(builtins.fetchTarball {
        # Get the revision by choosing a version from https://github.com/nix-community/home-manager
        url = "https://github.com/nix-community/home-manager/archive/b9e3a29864798d55ec1d6579ab97876bb1ee9664.tar.gz";
        # Get the hash by running `nix-prefetch-url --unpack <url>` on the above url
        sha256 = "04cvww0ic5kxvm09jhlsfcb1nby2rbw88jrv453zx0ipb4wndbks";
      })}/nix-darwin''
    ];

    home-manager.useGlobalPkgs = true;
    home-manager.users = let userconfig = { config, ...}: rec {
      home.stateVersion = "22.11";
      home.file = {
        ".cargo/bin/rust-analyzer".source = config.lib.file.mkOutOfStoreSymlink "${hgj_home}/.rustup/toolchains/stable-aarch64-apple-darwin/bin/rust-analyzer";
        ".gnupg/gpg-agent.conf".text = ''
            enable-ssh-support
            default-cache-ttl 86400
            max-cache-ttl 86400
            pinentry-program ${brewpath}/bin/pinentry-mac
            '';
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
        "Library/Application Support/AquaSKK/azik_us.rule".text = ''
###
### azik_us.rule -- AZIK ������
###

',��,��,��

b.,��,��,�̎�
bd,�٤�,�٥�,�͎ގ�
bh,�֤�,�֥�,�̎ގ�
bj,�֤�,�֥�,�̎ގ�
bk,�Ӥ�,�ӥ�,�ˎގ�
bl,�ܤ�,�ܥ�,�Ύގ�
bn,�Ф�,�Х�,�ʎގ�
bp,�ܤ�,�ܥ�,�Ύގ�
bq,�Ф�,�Х�,�ʎގ�
br,�Ф�,�Х�,�ʎގ�
bt,�Ӥ�,�ӥ�,�ˎގ�
bw,�٤�,�٥�,�͎ގ�
bx,�٤�,�٥�,�͎ގ�
bz,�Ф�,�Х�,�ʎގ�

byd,�Ӥ���,�ӥ���,�ˎގ���
byh,�Ӥ夦,�ӥ奦,�ˎގ���
byj,�Ӥ��,�ӥ��,�ˎގ���
byl,�Ӥ��,�ӥ��,�ˎގ���
byn,�Ӥ��,�ӥ��,�ˎގ���
byp,�Ӥ礦,�ӥ祦,�ˎގ���
byq,�Ӥ㤤,�ӥ㥤,�ˎގ���
byw,�Ӥ���,�ӥ���,�ˎގ���
byz,�Ӥ��,�ӥ��,�ˎގ���

ca,����,����,����
cc,����,����,����
cd,������,������,������
ce,����,����,����
cf,����,����,����
ch,���夦,���奦,������
ci,��,��,��
cj,�����,�����,������
ck,����,����,����
cl,�����,�����,������
cn,�����,�����,������
co,����,����,����
cp,���礦,���祦,������
cq,���㤤,���㥤,������
cu,����,����,����
cv,���㤤,���㥤,������
cw,������,������,������
cx,������,������,������
cz,�����,�����,������

dd,�Ǥ�,�ǥ�,�Îގ�
df,��,��,�Î�
dg,����,����,���ގ���
dh,�Ť�,�ť�,�ގ�
dj,�Ť�,�ť�,�ގ�
dk,�¤�,�¥�,���ގ�
dl,�ɤ�,�ɥ�,�Ďގ�
dm,�Ǥ�,�ǥ�,�Îގ�
dn,����,����,���ގ�
dp,�ɤ�,�ɥ�,�Ďގ�
dq,����,����,���ގ�
dr,�Ǥ���,�ǥ���,�Îގ���
ds,�Ǥ�,�ǥ�,�Îގ�
dt,����,����,���ގ�
dv,�Ǥ�,�ǥ�,�Îގ�
dw,�Ǥ�,�ǥ�,�Îގ�
dy,�Ǥ�,�ǥ�,�Îގ�
dz,����,����,���ގ�
dch,�Ǥ�,�ǥ塼,�Îގ���
dci,�Ǥ�,�ǥ�,�Îގ�
dck,�Ǥ���,�ǥ���,�Îގ���
dcp,�ɤ�,�ɥ���,�Ďގ���
dcu,�Ǥ�,�ǥ�,�Îގ�

fd,�դ���,�ե���,�̎���
fh,�դ�,�ե�,�̎�
fj,�դ�,�ե�,�̎�
fk,�դ���,�ե���,�̎���
fl,�դ���,�ե���,�̎���
fm,�դ�,�ե�,�̎�
fn,�դ���,�ե���,�̎���
fp,�դ�,�ե���,�̎���
fq,�դ���,�ե���,�̎���
fr,�դ�,�ե�,�̎�
fs,�դ���,�ե���,�̎���
fw,�դ���,�ե���,�̎���
fz,�դ���,�ե���,�̎���

gd,����,����,���ގ�
gh,����,����,���ގ�
gj,����,����,���ގ�
gk,����,����,���ގ�
gl,����,����,���ގ�
gn,����,����,���ގ�
gp,����,����,���ގ�
gq,����,����,���ގ�
gr,����,����,���ގ�
gt,����,����,���ގ�
gw,����,����,���ގ�
gz,����,����,���ގ�

gyd,������,������,���ގ���
gyh,���夦,���奦,���ގ���
gyj,�����,�����,���ގ���
gyl,�����,�����,���ގ���
gyn,�����,�����,���ގ���
gyp,���礦,���祦,���ގ���
gyq,���㤤,���㥤,���ގ���
gyw,������,������,���ގ���
gyz,�����,�����,���ގ���

hd,�ؤ�,�إ�,�͎�
hf,��,��,��
hh,�դ�,�ե�,�̎�
hj,�դ�,�ե�,�̎�
hk,�Ҥ�,�ҥ�,�ˎ�
hl,�ۤ�,�ۥ�,�Ύ�
hn,�Ϥ�,�ϥ�,�ʎ�
hp,�ۤ�,�ۥ�,�Ύ�
hq,�Ϥ�,�ϥ�,�ʎ�
ht,�Ҥ�,�ҥ�,�ˎ�
hw,�ؤ�,�إ�,�͎�
hz,�Ϥ�,�ϥ�,�ʎ�
hga,�Ҥ�,�ҥ�,�ˎ�
hgd,�Ҥ���,�ҥ���,�ˎ���
hge,�Ҥ�,�ҥ�,�ˎ�
hgh,�Ҥ夦,�ҥ奦,�ˎ���
hgj,�Ҥ��,�ҥ��,�ˎ���
hgl,�Ҥ��,�ҥ��,�ˎ���
hgn,�Ҥ��,�ҥ��,�ˎ���
hgo,�Ҥ�,�ҥ�,�ˎ�
hgp,�Ҥ礦,�ҥ祦,�ˎ���
hgq,�Ҥ㤤,�ҥ㥤,�ˎ���
hgu,�Ҥ�,�ҥ�,�ˎ�
hgw,�Ҥ���,�ҥ���,�ˎ���
hgz,�Ҥ��,�ҥ��,�ˎ���
hyd,�Ҥ���,�ҥ���,�ˎ���
hyh,�Ҥ夦,�ҥ奦,�ˎ���
hyl,�Ҥ��,�ҥ��,�ˎ���
hyp,�Ҥ礦,�ҥ祦,�ˎ���
hyq,�Ҥ㤤,�ҥ㥤,�ˎ���
hyw,�Ҥ���,�ҥ���,�ˎ���
hyz,�Ҥ��,�ҥ��,�ˎ���

jd,������,������,���ގ���
jf,����,����,���ގ�
jh,���夦,���奦,���ގ���
jj,�����,�����,���ގ���
jk,����,����,���ގ�
jl,�����,�����,���ގ���
jn,�����,�����,���ގ���
jp,���礦,���祦,���ގ���
jq,���㤤,���㥤,���ގ���
jv,���夦,���奦,���ގ���
jw,������,������,���ގ���
jz,�����,�����,���ގ���

kA,��,��,��
kE,��,��,��
kd,����,����,����
kf,��,��,��
kh,����,����,����
kj,����,����,����
kk,����,����,����
kl,����,����,����
km,��,��,��
kn,����,����,����
kp,����,����,����
kq,����,����,����
kr,����,����,����
kt,����,����,����
kv,����,����,����
kw,����,����,����
kz,����,����,����
kga,����,����,����
kgd,������,������,������
kge,����,����,����
kgh,���夦,���奦,������
kgl,�����,�����,������
kgn,�����,�����,������
kgo,����,����,����
kgp,���礦,���祦,������
kgq,���㤤,���㥤,������
kgu,����,����,����
kgw,������,������,������
kgz,�����,�����,������
kyd,������,������,������
kyh,���夦,���奦,������
kyj,�����,�����,������
kyl,�����,�����,������
kyn,�����,�����,������
kyp,���礦,���祦,������
kyq,���㤤,���㥤,������
kyw,������,������,������
kyz,�����,�����,������

m.,��,��,��
md,���,���,�Ҏ�
mf,��,��,��
mh,�द,�०,�ю�
mj,���,���,�ю�
mk,�ߤ�,�ߥ�,�Ў�
ml,���,���,�ӎ�
mn,���,���,�ӎ�
mp,�⤦,�⥦,�ӎ�
mq,�ޤ�,�ޥ�,�ώ�
mr,�ޤ�,�ޥ�,�ώ�
ms,�ޤ�,�ޥ�,�ώ�
mt,�ޤ�,�ޥ�,�ώ�
mv,���,���,�ю�
mw,�ᤤ,�ᥤ,�Ҏ�
mz,�ޤ�,�ޥ�,�ώ�
mga,�ߤ�,�ߥ�,�Ў�
mgd,�ߤ���,�ߥ���,�Ў���
mge,�ߤ�,�ߥ�,�Ў�
mgh,�ߤ夦,�ߥ奦,�Ў���
mgj,�ߤ��,�ߥ��,�Ў���
mgl,�ߤ��,�ߥ��,�Ў���
mgn,�ߤ��,�ߥ��,�Ў���
mgo,�ߤ�,�ߥ�,�Ў�
mgp,�ߤ礦,�ߥ祦,�Ў���
mgq,�ߤ㤤,�ߥ㥤,�Ў���
mgu,�ߤ�,�ߥ�,�Ў�
mgw,�ߤ���,�ߥ���,�Ў���
mgz,�ߤ��,�ߥ��,�Ў���
myd,�ߤ���,�ߥ���,�Ў���
myh,�ߤ夦,�ߥ奦,�Ў���
myj,�ߤ��,�ߥ��,�Ў���
myl,�ߤ��,�ߥ��,�Ў���
myn,�ߤ��,�ߥ��,�Ў���
myp,�ߤ礦,�ߥ祦,�Ў���
myq,�ߤ㤤,�ߥ㥤,�Ў���
myw,�ߤ���,�ߥ���,�Ў���
myz,�ߤ��,�ߥ��,�Ў���

n.,��,��,��
nb,�ͤ�,�ͥ�,�Ȏʎ�
nd,�ͤ�,�ͥ�,�Ȏ�
nf,��,��,��
nh,�̤�,�̥�,�ǎ�
nj,�̤�,�̥�,�ǎ�
nk,�ˤ�,�˥�,�Ǝ�
nl,�Τ�,�Υ�,�Ɏ�
np,�Τ�,�Υ�,�Ɏ�
nq,�ʤ�,�ʥ�,�Ŏ�
nr,�ʤ�,�ʥ�,�Ŏ�
nt,�ˤ�,�˥�,�Ǝ�
nv,�̤�,�̥�,�ǎ�
nw,�ͤ�,�ͥ�,�Ȏ�
nz,�ʤ�,�ʥ�,�Ŏ�
nga,�ˤ�,�˥�,�Ǝ�
ngd,�ˤ���,�˥���,�Ǝ���
nge,�ˤ�,�˥�,�Ǝ�
ngh,�ˤ夦,�˥奦,�Ǝ���
ngj,�ˤ��,�˥��,�Ǝ���
ngl,�ˤ��,�˥��,�Ǝ���
ngn,�ˤ��,�˥��,�Ǝ���
ngo,�ˤ�,�˥�,�Ǝ�
ngp,�ˤ礦,�˥祦,�Ǝ���
ngq,�ˤ㤤,�˥㥤,�Ǝ���
ngu,�ˤ�,�˥�,�Ǝ�
ngw,�ˤ���,�˥���,�Ǝ���
ngz,�ˤ��,�˥��,�Ǝ���
nyd,�ˤ���,�˥���,�Ǝ���
nyh,�ˤ夦,�˥奦,�Ǝ���
nyj,�ˤ��,�˥��,�Ǝ���
nyl,�ˤ��,�˥��,�Ǝ���
nyn,�ˤ��,�˥��,�Ǝ���
nyp,�ˤ礦,�˥祦,�Ǝ���
nyq,�ˤ㤤,�˥㥤,�Ǝ���
nyw,�ˤ���,�˥���,�Ǝ���
nyz,�ˤ��,�˥��,�Ǝ���

pd,�ڤ�,�ڥ�,�͎ߎ�
pf,�ݤ�,�ݥ�,�Ύߎ�
ph,�פ�,�ץ�,�̎ߎ�
pj,�פ�,�ץ�,�̎ߎ�
pk,�Ԥ�,�ԥ�,�ˎߎ�
pl,�ݤ�,�ݥ�,�Ύߎ�
pn,�Ѥ�,�ѥ�,�ʎߎ�
pp,�ݤ�,�ݥ�,�Ύߎ�
pq,�Ѥ�,�ѥ�,�ʎߎ�
pv,�ݤ�,�ݥ�,�Ύߎ�
pw,�ڤ�,�ڥ�,�͎ߎ�
pz,�Ѥ�,�ѥ�,�ʎߎ�
pga,�Ԥ�,�ԥ�,�ˎߎ�
pgd,�Ԥ���,�ԥ���,�ˎߎ���
pge,�Ԥ�,�ԥ�,�ˎߎ�
pgh,�Ԥ夦,�ԥ奦,�ˎߎ���
pgj,�Ԥ��,�ԥ��,�ˎߎ���
pgl,�Ԥ��,�ԥ��,�ˎߎ���
pgn,�Ԥ��,�ԥ��,�ˎߎ���
pgo,�Ԥ�,�ԥ�,�ˎߎ�
pgp,�Ԥ礦,�ԥ祦,�ˎߎ���
pgq,�Ԥ㤤,�ԥ㥤,�ˎߎ���
pgu,�Ԥ�,�ԥ�,�ˎߎ�
pgw,�Ԥ���,�ԥ���,�ˎߎ���
pgz,�Ԥ��,�ԥ��,�ˎߎ���
pyd,�Ԥ���,�ԥ���,�ˎߎ���
pyh,�Ԥ夦,�ԥ奦,�ˎߎ���
pyj,�Ԥ��,�ԥ��,�ˎߎ���
pyl,�Ԥ��,�ԥ��,�ˎߎ���
pyn,�Ԥ��,�ԥ��,�ˎߎ���
pyp,�Ԥ礦,�ԥ祦,�ˎߎ���
pyq,�Ԥ㤤,�ԥ㥤,�ˎߎ���
pyw,�Ԥ���,�ԥ���,�ˎߎ���
pyz,�Ԥ��,�ԥ��,�ˎߎ���

q,��,��,��

rd,���,���,�ڎ�
rh,�뤦,�륦,�َ�
rj,���,���,�َ�
rk,���,���,�؎�
rl,���,���,�ێ�
rn,���,���,�׎�
rp,��,��,�ێ�
rq,�餤,�饤,�׎�
rr,���,���,�׎�
rw,�줤,�쥤,�ڎ�
rz,���,���,�׎�

ryd,�ꤧ��,�ꥧ��,�؎���
ryh,��夦,��奦,�؎���
ryj,����,����,�؎���
ryk,��礯,��祯,�؎���
ryl,����,����,�؎���
ryn,����,����,�؎���
ryp,��礦,��祦,�؎���
ryq,��㤤,��㥤,�؎���
ryw,�ꤧ��,�ꥧ��,�؎���
ryz,����,����,�؎���

sd,����,����,����
sf,����,����,����
sh,����,����,����
sj,����,����,����
sk,����,����,����
sl,����,����,����
sm,����,����,����
sn,����,����,����
sp,����,����,����
sq,����,����,����
sr,����,����,����
ss,����,����,����
st,����,����,����
sv,����,����,����
sw,����,����,����
sz,����,����,����

syd,������,������,������
syh,���夦,���奦,������
syj,�����,�����,������
syl,�����,�����,������
syp,���礦,���祦,������
syq,���㤤,���㥤,������
syw,������,������,������
syz,�����,�����,������

tU,��,��,��
tb,����,����,���ˎ�
td,�Ƥ�,�ƥ�,�Î�
th,�Ĥ�,�ĥ�,��
tj,�Ĥ�,�ĥ�,��
tk,����,����,����
tl,�Ȥ�,�ȥ�,�Ď�
tm,����,����,����
tn,����,����,����
tp,�Ȥ�,�ȥ�,�Ď�
tq,����,����,����
tr,����,����,����
tt,����,����,����
tw,�Ƥ�,�ƥ�,�Î�
tz,����,����,����
tgh,�Ƥ�,�ƥ塼,�Î���
tgi,�Ƥ�,�ƥ�,�Î�
tgk,�Ƥ���,�ƥ���,�Î���
tgp,�Ȥ�,�ȥ���,�Ď���
tgu,�Ƥ�,�ƥ�,�Î�
tsU,��,��,��
tsa,�Ĥ�,�ĥ�,��
tse,�Ĥ�,�ĥ�,��
tsi,�Ĥ�,�ĥ�,��
tso,�Ĥ�,�ĥ�,��
tyd,������,������,������
tyh,���夦,���奦,������
tyj,�����,�����,������
tyl,�����,�����,������
tyn,�����,�����,������
typ,���礦,���祦,������
tyq,���㤤,���㥤,������
tyw,������,������,������
tyz,�����,�����,������

vd,��,������,���ގ���
vk,��,������,���ގ���
vl,��,������,���ގ���
vn,��,������,���ގ���
vp,��,������,���ގ���
vq,��,������,���ގ���
vw,��,������,���ގ���
vz,��,������,���ގ���
vya,��,����,���ގ�
vye,��,����,���ގ�
vyo,��,����,���ގ�
vyu,��,����,���ގ�

wA,��,��,��
wd,������,������,������
wf,��,��,��
wk,������,������,������
wl,������,������,������
wn,���,���,�܎�
wp,����,������,������
wq,�襤,�磻,�܎�
wr,���,���,�܎�
wt,�錄,�勵,�܎�
wz,���,���,�܎�
wha,����,����,����
whe,����,����,����
whi,����,����,����
who,����,����,����
whu,��,��,��
wso,����,����,����

x;,��,��,;
z;,��,��,:

xa,����,����,����
xc,����,����,����
xd,������,������,������
xe,����,����,����
xf,������,������,������
xh,���夦,���奦,������
xi,��,��,��
xj,�����,�����,������
xk,����,����,����
xl,�����,�����,������
xn,�����,�����,������
xo,����,����,����
xp,���礦,���祦,������
xq,���㤤,���㥤,������
xt,�����,�����,������
xu,����,����,����
xv,���㤤,���㥤,������
xw,������,������,������
xz,�����,�����,������
xxa,��,��,��
xxe,��,��,��
xxi,��,��,��
xxo,��,��,��
xxu,��,��,��

yh,�椦,�楦,�Վ�
yi,��,��,��
yj,���,���,�Վ�
yl,���,���,�֎�
yn,���,���,�Ԏ�
yp,�褦,�襦,�֎�
yq,�䤤,�䥤,�Ԏ�
yr,���,���,�֎�
yv,�椦,�楦,�Վ�
yz,���,���,�Ԏ�

z.,��,��,����
zc,��,��,����
zd,����,����,���ގ�
zf,��,��,����
zh,����,����,���ގ�
zj,����,����,���ގ�
zk,����,����,���ގ�
zl,����,����,���ގ�
zn,����,����,���ގ�
zp,����,����,���ގ�
zq,����,����,���ގ�
zr,����,����,���ގ�
zv,����,����,���ގ�
zw,����,����,���ގ�
zx,����,����,���ގ�
zz,����,����,���ގ�
zyd,������,������,���ގ���
zyh,���夦,���奦,���ގ���
zyj,�����,�����,���ގ���
zyl,�����,�����,���ގ���
zyn,�����,�����,���ގ���
zyp,���礦,���祦,���ގ���
zyq,���㤤,���㥤,���ގ���
zyw,������,������,���ގ���
zyz,�����,�����,���ގ���
x[,��,��,��

# kana-rule.conf  �� [ ���Ф����Ѵ���§���������Ƥ���Τǡ�ToggleKana ��������ư��ʤ���
# �����ǡ� [ ���Ѵ���§�򤢤��ޤ��ˤ��ơ��Ѵ�����ʤ��褦�ˤ���
[[,��,��,��
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
        ".gitconfig".text = ''
          [user]
            name = Hyunggyu Jang
            email = murasakipurplez5@gmail.com
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

PATH="/Applications/kitty.app/Contents/MacOS${"\${PATH:+:\${PATH}}"}"

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
          "helix/config.toml".text = ''
          [editor.cursor-shape]
          insert = "bar"
          normal = "block"
          select = "underline"
        '';
          "zathura/zathurarc".text = "set selection-clipboard clipboard";
          "yabai/yabairc" = {
            text = ''
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
            executable = true;
          };
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
                        "description": "Change tab to fn if pressed with other keys, to tab if pressed alone.",
                        "manipulators": [
                            {
                                "from": {
                                    "key_code": "tab",
                                    "modifiers": {
                                        "optional": [
                                            "any"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "fn"
                                    }
                                ],
                                "to_if_alone": [
                                    {
                                        "key_code": "tab"
                                    }
                                ],
                                "type": "basic"
                            },
                            {
                                "from": {
                                    "key_code": "open_bracket",
                                    "modifiers": {
                                        "optional": [
                                            "any"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "fn"
                                    }
                                ],
                                "to_if_alone": [
                                    {
                                        "key_code": "open_bracket"
                                    }
                                ],
                                "type": "basic"
                            },
                            {
                                "from": {
                                    "key_code": "e",
                                    "modifiers": {
                                        "mandatory": [
                                            "fn"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "open_bracket",
                                        "modifiers": ["left_shift"]
                                    }
                                ],
                                "type": "basic"
                            },
                            {
                                "from": {
                                    "key_code": "r",
                                    "modifiers": {
                                        "mandatory": [
                                            "fn"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "close_bracket",
                                        "modifiers": ["left_shift"]
                                    }
                                ],
                                "type": "basic"
                            },
                            {
                                "from": {
                                    "key_code": "d",
                                    "modifiers": {
                                        "mandatory": [
                                            "fn"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "9",
                                        "modifiers": ["left_shift"]
                                    }
                                ],
                                "type": "basic"
                            },
                            {
                                "from": {
                                    "key_code": "f",
                                    "modifiers": {
                                        "mandatory": [
                                            "fn"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "0",
                                        "modifiers": ["left_shift"]
                                    }
                                ],
                                "type": "basic"
                            },
                            {
                                "from": {
                                    "key_code": "c",
                                    "modifiers": {
                                        "mandatory": [
                                            "fn"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "open_bracket"
                                    }
                                ],
                                "type": "basic"
                            },
                            {
                                "from": {
                                    "key_code": "v",
                                    "modifiers": {
                                        "mandatory": [
                                            "fn"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "close_bracket"
                                    }
                                ],
                                "type": "basic"
                            },
                            {
                                "from": {
                                    "key_code": "s",
                                    "modifiers": {
                                        "mandatory": [
                                            "fn"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "4",
                                        "modifiers": ["left_shift"]
                                    }
                                ],
                                "type": "basic"
                            },
                            {
                                "from": {
                                    "key_code": "a",
                                    "modifiers": {
                                        "mandatory": [
                                            "fn"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "6",
                                        "modifiers": ["left_shift"]
                                    }
                                ],
                                "type": "basic"
                            },
                            {
                                "from": {
                                    "key_code": "q",
                                    "modifiers": {
                                        "mandatory": [
                                            "fn"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "1",
                                        "modifiers": ["left_shift"]
                                    }
                                ],
                                "type": "basic"
                            },
                            {
                                "from": {
                                    "key_code": "z",
                                    "modifiers": {
                                        "mandatory": [
                                            "fn"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "slash",
                                        "modifiers": ["left_shift"]
                                    }
                                ],
                                "type": "basic"
                            },
                            {
                                "from": {
                                    "key_code": "t",
                                    "modifiers": {
                                        "mandatory": [
                                            "fn"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "backslash"
                                    }
                                ],
                                "type": "basic"
                            },
                            {
                                "from": {
                                    "key_code": "g",
                                    "modifiers": {
                                        "mandatory": [
                                            "fn"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "grave_accent_and_tilde"
                                    }
                                ],
                                "type": "basic"
                            },
                            {
                                "from": {
                                    "key_code": "b",
                                    "modifiers": {
                                        "mandatory": [
                                            "fn"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "grave_accent_and_tilde",
                                        "modifiers": ["left_shift"]
                                    }
                                ],
                                "type": "basic"
                            },
                            {
                                "from": {
                                    "key_code": "u",
                                    "modifiers": {
                                        "mandatory": [
                                            "fn"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "5",
                                        "modifiers": ["left_shift"]
                                    }
                                ],
                                "type": "basic"
                            },
                            {
                                "from": {
                                    "key_code": "i",
                                    "modifiers": {
                                        "mandatory": [
                                            "fn"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "equal_sign"
                                    }
                                ],
                                "type": "basic"
                            },
                            {
                                "from": {
                                    "key_code": "k",
                                    "modifiers": {
                                        "mandatory": [
                                            "fn"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "hyphen"
                                    }
                                ],
                                "type": "basic"
                            },
                            {
                                "from": {
                                    "key_code": "j",
                                    "modifiers": {
                                        "mandatory": [
                                            "fn"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "8",
                                        "modifiers": ["left_shift"]
                                    }
                                ],
                                "type": "basic"
                            },
                            {
                                "from": {
                                    "key_code": "comma",
                                    "modifiers": {
                                        "mandatory": [
                                            "fn"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "hyphen",
                                        "modifiers": ["left_shift"]
                                    }
                                ],
                                "type": "basic"
                            },
                            {
                                "from": {
                                    "key_code": "m",
                                    "modifiers": {
                                        "mandatory": [
                                            "fn"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "7",
                                        "modifiers": ["left_shift"]
                                    }
                                ],
                                "type": "basic"
                            },
                            {
                                "from": {
                                    "key_code": "h",
                                    "modifiers": {
                                        "mandatory": [
                                            "fn"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "3",
                                        "modifiers": ["left_shift"]
                                    }
                                ],
                                "type": "basic"
                            },
                            {
                                "from": {
                                    "key_code": "n",
                                    "modifiers": {
                                        "mandatory": [
                                            "fn"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "backslash",
                                        "modifiers": ["left_shift"]
                                    }
                                ],
                                "type": "basic"
                            },
                            {
                                "from": {
                                    "key_code": "l",
                                    "modifiers": {
                                        "mandatory": [
                                            "fn"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "equal_sign",
                                        "modifiers": ["left_shift"]
                                    }
                                ],
                                "type": "basic"
                            },
                            {
                                "from": {
                                    "key_code": "semicolon",
                                    "modifiers": {
                                        "mandatory": [
                                            "fn"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "quote"
                                    }
                                ],
                                "type": "basic"
                            },
                            {
                                "from": {
                                    "key_code": "quote",
                                    "modifiers": {
                                        "mandatory": [
                                            "fn"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "quote",
                                        "modifiers": ["left_shift"]
                                    }
                                ],
                                "type": "basic"
                            },
                            {
                                "from": {
                                    "key_code": "period",
                                    "modifiers": {
                                        "mandatory": [
                                            "fn"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "comma",
                                        "modifiers": ["left_shift"]
                                    }
                                ],
                                "type": "basic"
                            },
                            {
                                "from": {
                                    "key_code": "slash",
                                    "modifiers": {
                                        "mandatory": [
                                            "fn"
                                        ]
                                    }
                                },
                                "to": [
                                    {
                                        "key_code": "period",
                                        "modifiers": ["left_shift"]
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
                        "description": "Change to English layout if Left ⌘ key pressed alone, else send ⌘ key.",
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
                },
                {
                    "disable_built_in_keyboard_if_exists": true,
                    "fn_function_keys": [],
                    "identifiers": {
                        "is_keyboard": true,
                        "is_pointing_device": true,
                        "product_id": 6505,
                        "vendor_id": 12951
                    },
                    "ignore": true,
                    "manipulate_caps_lock_led": false,
                    "simple_modifications": []
                },
                {
                    "disable_built_in_keyboard_if_exists": true,
                    "fn_function_keys": [],
                    "identifiers": {
                        "is_keyboard": true,
                        "is_pointing_device": false,
                        "product_id": 6505,
                        "vendor_id": 12951
                    },
                    "ignore": true,
                    "manipulate_caps_lock_led": false,
                    "simple_modifications": []
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
        };
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


            # opam
            # [[ ! -r /Users/hyunggyujang/.opam/opam-init/init.zsh ]] || source /Users/hyunggyujang/.opam/opam-init/init.zsh  > /dev/null 2> /dev/null
        fi

        if ! whence load_nvmrc; then
            autoload -U add-zsh-hook
            load_nvmrc() {
              local node_version="$(nvm version)"
              local nvmrc_path="$(nvm_find_nvmrc)"

              if [ -n "$nvmrc_path" ]; then
                local nvmrc_node_version=$(nvm version "$(cat "$nvmrc_path")")

                if [ "$nvmrc_node_version" = "N/A" ]; then
                  nvm install
                elif [ "$nvmrc_node_version" != "$node_version" ]; then
                  nvm use
                fi
              elif [ "$node_version" != "$(nvm version default)" ]; then
                echo "Reverting to nvm default version"
                nvm use default
              fi
            }
            add-zsh-hook chpwd load_nvmrc
            load_nvmrc
        fi
        '';
      };

      programs.fzf.enable = true;
      programs.fzf.enableZshIntegration = true;
      programs.browserpass.enable = true;
      programs.browserpass.browsers = [ "firefox" ];
      programs.firefox.enable = true;
      programs.firefox.package = pkgs.runCommand "firefox-0.0.0" {} "mkdir $out";
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
            extensions =
              with nur.repos.rycee.firefox-addons; [
                ublock-origin
                browserpass
                tridactyl
                darkreader
                # For work with kazuki
                metamask
                # Need to add zotero-connector
              ];
          };
        };
    };
                         in
                           {
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
        LIBGS = "/opt/homebrew/lib/libgs.dylib"; # For tikz's latex preview.
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
      ];
      systemPackages = with pkgs; [
        nixfmt
        yaskkserv2
        darwin-zsh-completions
        skhd
        shellcheck
        solc-select
        tree-sitter
        stack
        llvm
        # WASM
        rustup
        pandoc
        openssl
        # Mail
        # TODO: Move emacs, notmuch, lieer, afew to Nix.
        # lieer # Curretly installed manually by cloning the repo as instructed: https://afew.readthedocs.io/en/latest/installation.html
        # afew # Currently installed using pip3 install afew
        # Latex
        (texlive.combine {
          inherit (texlive) scheme-medium;
        })
        # foundry for solidity repl
        foundry
        # OutsideIn(X)
        cabal-install
        ghc
      ];
      pathsToLink = [
        "/lib"
      ];
      shells = [
        pkgs.zsh
      ];
    };

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
    services =
      {
        nix-daemon.enable = true;
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
open < f : skhd -k "ctrl - g"; open -a "/Applications/Firefox Developer Edition.app"

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
      settings.trusted-users = ["root" "hyunggyujang"];
      package = pkgs.nix;
      nixPath = [
        {
          inherit darwin;
          nixpkgs = nixpkgsSrc;
          localconfig = "${hgj_darwin_home}/${localconfig.hostname}.nix";
        }
      ];
    };

    homebrew =  {
      enable = true;
      onActivation.upgrade = true;
      onActivation.autoUpdate = true;
      onActivation.cleanup = "zap";
      global.brewfile = true;
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
        "mac-cleanup/mac-cleanup-py"
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
        "gmp"
        "coreutils"
        "gnuplot"
        "imagemagick"
        "fd"
        "poppler"
        "automake"
        "cmake"
        "findutils"
        "pinentry-mac"
        # Fonts
        "svn"
        # emacs-mac dependencies
        "jansson"
        "libxml2"
        "texinfo"
        # suggested by Doom emacs
        "pyenv"
        # For projectile
        "ctags"
        # Lexic
        "sdcv"
        # Javascript
        "nvm"
        # TODO: remove this dependency for slither
        "poetry"
        # emacs-mac
        "libgccjit"
        "gcc"
        # Garrigue project
        # "ocaml"
        "opam"
        # "coq"
        "parallel"
        "youtube-dl"
        # To cleanup system data
        "mac-cleanup-py"
        # python
        "python"
        # For node v14
        "python@3.10"
        "pyright"
        # mail
        "notmuch"
        # moonlander
        "libusb"
        # minicaml
        "rlwrap"
        # Astar
        "protobuf"
        # OutsideIn(X)
        "agda"
      ];
      casks = [
        "appcleaner"
        "slack"
        "kitty"
        "aquaskk"
        "hammerspoon"
        "karabiner-elements"
        "onedrive"
        "zoom"
        "zotero"
        # elegant-emacs
        "font-roboto-mono"
        "font-roboto-slab"
        # math font
        "font-dejavu"
        # beamer with xelatex
        "font-fira-sans"
        "font-fira-mono"
        "discord"
        # Docker
        "docker"
        # Garrigue lab
        "element"
        "skype"
        # Data analysis class
        "microsoft-excel"
        # School
        "microsoft-word"
        # audit
        "telegram"
        # For Bing AI + Google meet
        "microsoft-edge"
        # Experiment with modern IDE
        "visual-studio-code"
      ];
      extraConfig = ''
        brew "emacs-mac", args: ["with-native-comp", "with-no-title-bars", "with-starter"]
        cask "firefox-developer-edition", args: { language: "en-KR" }
        brew "yabai", start_service: true
      '';
    };
  }
