{
  config,
  lib,
  pkgs,
  hgj_darwin_home,
  hgj_projects,
  brewpath,
  ...
}:
{
  programs = {
    zsh = {
      enable = true;
      autosuggestion.enable = true;
      defaultKeymap = "emacs";
      sessionVariables = {
        RPROMPT = "";
      };
      shellAliases = {
        dbuild = "cd ${hgj_darwin_home} && TERM=xterm-256color make && cd -";
        dswitch = "cd ${hgj_darwin_home} && TERM=xterm-256color caffeinate -i make switch && cd -";
        drb = "cd ${hgj_darwin_home} && TERM=xterm-256color make rollback && cd -";
        cognee = "uv run --project ${hgj_projects}/cognee cognee-cli";
        cognee-mcp-stdio = "cd ${hgj_projects}/cognee/cognee-mcp && uv run python src/server.py";
        cognee-mcp-http = "cd ${hgj_projects}/cognee/cognee-mcp && uv run python src/server.py --transport http --port 8000";
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
      dotDir = config.home.homeDirectory;
      initContent = lib.mkMerge [
        (lib.mkOrder 550 ''
          echo >&2 "Homebrew completion path..."
          if [ -f ${brewpath}/bin/brew ]; then
              fpath+=$(brew --prefix)/share/zsh/site-functions
              if [[ $INSIDE_EMACS != vterm && $TERM_PROGRAM != vscode ]]; then
                 PATH=${brewpath}/bin:$PATH
              fi
          else
              echo -e "\e[1;31merror: Homebrew is not installed, skipping...\e[0m" >&2
          fi
        '')
        (lib.mkOrder 1000 ''
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
        '')
      ];
    };
  };
}
