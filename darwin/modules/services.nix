{ ... }:
{
  services = {
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
        # Use HM app path directly to avoid LaunchServices selecting a stale
        # Emacs.app from an old Nix store generation.
        open < e : skhd -k "ctrl - g"; open "$HOME/Applications/Home Manager Apps/Emacs.app"
        open < shift - e : skhd -k "ctrl - g"; DEBUG=1 open "$HOME/Applications/Home Manager Apps/Emacs.app"

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

        open < c : skhd -k "ctrl - g"; open -a Cursor

        open < i : skhd -k "ctrl - g"; doom everywhere
      '';
    };
  };
}
