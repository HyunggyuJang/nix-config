{ ... }:
{
  programs.tmux = {
    enable = true;
    baseIndex = 1;
    clock24 = true;
    extraConfig = ''
      # Vim-style keybindings
      set -g mode-keys vi
      set -g status-keys vi

      # Doom-style leader: Ctrl-Space
      unbind C-b
      set -g prefix C-Space
      bind C-Space send-prefix
      bind C-@ send-prefix

      # Quality-of-life options
      set -g history-limit 100000
      set -g focus-events on
      set -g set-clipboard on
      set -sg escape-time 0
      set -g renumber-windows on
      setw -g pane-base-index 1

      # Copy mode (vi) + system clipboard
      bind -T copy-mode-vi v send-keys -X begin-selection
      bind -T copy-mode-vi V send-keys -X select-line
      bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "pbcopy"
      bind -T copy-mode-vi r send-keys -X rectangle-toggle

      # Doom-emacs-style window leader (prefix + w ...)
      bind w switch-client -T window

      # Window key table (panes)
      bind -T window v split-window -h \; switch-client -T root
      bind -T window s split-window -v \; switch-client -T root
      bind -T window c kill-pane \; switch-client -T root
      bind -T window m resize-pane -Z \; switch-client -T root

      bind -T window h select-pane -L \; switch-client -T root
      bind -T window j select-pane -D \; switch-client -T root
      bind -T window k select-pane -U \; switch-client -T root
      bind -T window l select-pane -R \; switch-client -T root

      bind -T window H resize-pane -L 5 \; switch-client -T root
      bind -T window J resize-pane -D 5 \; switch-client -T root
      bind -T window K resize-pane -U 5 \; switch-client -T root
      bind -T window L resize-pane -R 5 \; switch-client -T root

      bind -T window = select-layout even-horizontal \; switch-client -T root
      bind -T window + select-layout even-vertical \; switch-client -T root

      bind -T window Escape switch-client -T root

      # Doom-emacs-style buffer leader (prefix + b ...) -> tmux windows
      bind b switch-client -T buffer

      bind -T buffer b choose-window \; switch-client -T root
      bind -T buffer n next-window \; switch-client -T root
      bind -T buffer p previous-window \; switch-client -T root
      bind -T buffer l last-window \; switch-client -T root
      bind -T buffer c new-window \; switch-client -T root
      bind -T buffer d kill-window \; switch-client -T root
      bind -T buffer , command-prompt -I "#W" "rename-window '%%'" \; switch-client -T root
      bind -T buffer Escape switch-client -T root

      # Doom-emacs-style session leader (prefix + s ...)
      bind s switch-client -T session

      bind -T session s choose-session \; switch-client -T root
      bind -T session n new-session \; switch-client -T root
      bind -T session r command-prompt -I "#S" "rename-session '%%'" \; switch-client -T root
      bind -T session d detach-client \; switch-client -T root
      bind -T session l switch-client -l \; switch-client -T root
      bind -T session Escape switch-client -T root

      # Doom-emacs-style yank/clipboard leader (prefix + y ...)
      bind y switch-client -T yank

      bind -T yank y copy-mode \; switch-client -T root
      bind -T yank p paste-buffer \; switch-client -T root
      bind -T yank b choose-buffer \; switch-client -T root
      bind -T yank d delete-buffer \; switch-client -T root
      bind -T yank Escape switch-client -T root

      # Doom-emacs-style toggle leader (prefix + t ...)
      bind t switch-client -T toggle

      bind -T toggle m set -g mouse \; display-message "mouse: #{mouse}" \; switch-client -T root
      bind -T toggle s set -g status \; display-message "status: #{status}" \; switch-client -T root
      bind -T toggle p if -F '#{synchronize-panes}' 'setw synchronize-panes off' 'setw synchronize-panes on' \; display-message "sync panes: #{synchronize-panes}" \; switch-client -T root
      bind -T toggle z resize-pane -Z \; switch-client -T root
      bind -T toggle Escape switch-client -T root

      # Which-key-ish help popups (use tmux-which-key plugin if this gets too hacky)
      bind ? display-popup -E "tmux list-keys -T root | less"
      bind -T window ? display-popup -E "tmux list-keys -T window | less"
      bind -T buffer ? display-popup -E "tmux list-keys -T buffer | less"
      bind -T session ? display-popup -E "tmux list-keys -T session | less"
      bind -T yank ? display-popup -E "tmux list-keys -T yank | less"
      bind -T toggle ? display-popup -E "tmux list-keys -T toggle | less"

      # Reload config quickly
      bind r source-file ~/.tmux.conf \; display-message "tmux.conf reloaded"
    '';
  };
}
