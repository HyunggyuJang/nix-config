{
  config,
  hgj_home,
  hgj_localbin,
  ...
}:
{
  home.file = {
    ".direnvrc".source = ./files/direnvrc;
    ".cargo/bin/rust-analyzer".source =
      config.lib.file.mkOutOfStoreSymlink "${hgj_home}/.rustup/toolchains/stable-aarch64-apple-darwin/bin/rust-analyzer";
    ".antigravity/extensions".source =
      config.lib.file.mkOutOfStoreSymlink "${hgj_home}/.cursor/extensions";
    "Library/Application Support/Antigravity/User/keybindings.json".source =
      config.lib.file.mkOutOfStoreSymlink "${hgj_home}/Library/Application Support/Cursor/User/keybindings.json";
    "Library/Application Support/Antigravity/User/settings.json".source =
      config.lib.file.mkOutOfStoreSymlink "${hgj_home}/Library/Application Support/Cursor/User/settings.json";
    ".gnupg/gpg-agent.conf".source = ./files/gnupg/gpg-agent.conf;
    ".tridactylrc".source = ./files/tridactylrc;
    ".qutebrowser/config.py".source = ./files/qutebrowser/config.py;
    "Library/Application Support/AquaSKK/keymap.conf".source = ./files/aquaskk/keymap.conf;
    "Library/Application Support/AquaSKK/azik.conf".source = ./files/aquaskk/azik.conf;
    "Library/Application Support/AquaSKK/sub-rule.desc".source = ./files/aquaskk/sub-rule.desc;
    "Library/Application Support/AquaSKK/azik_us.rule" = import ../azik_us.nix;
    "Library/Application Support/AquaSKK/BlacklistApps.plist".source =
      ./files/aquaskk/BlacklistApps.plist;
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
    ".mailcap".source = ./files/mailcap;
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
    "${hgj_localbin}/kitty-diff" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        set -euo pipefail

        PATH="/Applications/kitty.app/Contents/MacOS${"\${PATH:+:\${PATH}}"}"

        appearance=$(defaults read -g AppleInterfaceStyle 2>/dev/null || true)
        if [[ "$appearance" == "Dark" ]]; then
            config="$HOME/.config/kitty/diff-dark.conf"
        else
            config="$HOME/.config/kitty/diff-light.conf"
        fi

        exec kitty +kitten diff --config "$config" "$@"
      '';
    };
    ".gitconfig".text = ''
      [user]
        name = Hyunggyu Jang
        email = murasakipurplez5@gmail.com

      [filter "lfs"]
        clean = git-lfs clean -- %f
        smudge = git-lfs smudge -- %f
        process = git-lfs filter-process
        required = true

      [color]
        ui = auto

      [includeIf "hasconfig:remote.*.url:gitlab.42dot.ai"]
        path = ${hgj_home}/.gitconfig-work

      [diff]
        tool = kitty

      [difftool]
        prompt = false
        trustExitCode = true

      [difftool "kitty"]
        cmd = kitty-diff "$LOCAL" "$REMOTE"

      [difftool "kitty.gui"]
        cmd = kitty-diff "$LOCAL" "$REMOTE"
    '';
  };
}
