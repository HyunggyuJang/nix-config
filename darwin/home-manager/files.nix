{
  config,
  machineType,
  hgj_home,
  hgj_localbin,
  ...
}:
{
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
    ".cargo/bin/rust-analyzer".source =
      config.lib.file.mkOutOfStoreSymlink "${hgj_home}/.rustup/toolchains/stable-aarch64-apple-darwin/bin/rust-analyzer";
    ".antigravity/extensions".source =
      config.lib.file.mkOutOfStoreSymlink "${hgj_home}/.cursor/extensions";
    "Library/Application Support/Antigravity/User/keybindings.json".source =
      config.lib.file.mkOutOfStoreSymlink "${hgj_home}/Library/Application Support/Cursor/User/keybindings.json";
    "Library/Application Support/Antigravity/User/settings.json".source =
      config.lib.file.mkOutOfStoreSymlink "${hgj_home}/Library/Application Support/Cursor/User/settings.json";
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
      set theme auto
      autocmd DocStart https://excalidraw.com/ mode ignore
      autocmd DocStart https://www.figma.com/ mode ignore
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
      c.aliases['mouse-pointer'] = "open javascript:void%20function(){document.head.innerHTML+=%22%3Cstyle%3E%20*%20%20{%20cursor:%20url(data:image/png;base64,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),%20auto%20!important;%20}%20%3C/style%3E%22}();"

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
    "Library/Application Support/AquaSKK/azik_us.rule" = import ../azik_us.nix;
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
          <key>syncInputSource</key>
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
  }
  // (
    if machineType != "M3-Pro" then
      {
        ".gitconfig".text = ''
          [user]
            name = Hyunggyu Jang
            email = murasakipurplez5@gmail.com
        '';
      }
    else
      { }
  );
}
