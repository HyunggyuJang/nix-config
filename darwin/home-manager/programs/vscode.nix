{ pkgs, ... }:
{
  programs = {
          vscode = {
            enable = true;
            package = pkgs.code-cursor;
            profiles.default.extensions = (with pkgs.vscode-extensions; [
              bierner.markdown-mermaid
              bodil.file-browser
              editorconfig.editorconfig
              esbenp.prettier-vscode
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
              # {
              #   name = "vim-with-killring";
              #   publisher = "hyunggyujang";
              #   version = "1.0.8";
              #   sha256 = "sha256-8JD/GaPqwFqxW5WOV+24Fs0xDkb2GEbJS57xVuClmRA=";
              # }
              {
                name = "fuzzy-search";
                publisher = "jacobdufault";
                version = "0.0.3";
                sha256 = "sha256-oN1SzXypjpKOTUzPbLCTC+H3I/40LMVdjbW3T5gib0M=";
              }
            ];
            profiles.default.userSettings = {
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
              # "extensions.experimental.affinity" = {
              #   "HyunggyuJang.vim-with-killring" = 1;
              # };
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
                    "languageId:kotlin"
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
              "cursor.cpp.disabledLanguages" = [];
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
              "workbench.preferredLightColorTheme" = "Default Light Modern";
              "plantuml.server" = "https://www.plantuml.com/plantuml";
              "plantuml.render" = "PlantUMLServer";
              "git.blame.statusBarItem.enabled" = false;
              # nightly cursor
              "update.releaseTrack" = "dev";
              "update.mode" = "silentlyApplyOnQuit";
              "terminal.integrated.macOptionIsMeta" = true;
            };
            profiles.default.keybindings = [
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
              # {
              #   key = "alt+l";
              #   command = "editor.action.transformToLowercase";
              # }
              # {
              #   key = "alt+u";
              #   command = "editor.action.transformToUppercase";
              # }
              # {
              #   key = "alt+c";
              #   command = "editor.action.transformToTitlecase";
              # }
              # {
              #   key = "alt+w";
              #   command = "workbench.action.switchWindow";
              # }
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
              # {
              #   key = "alt+b";
              #   command = "workbench.action.terminal.sendSequence";
              #   when = "terminalFocus && !terminalTextSelected";
              #   args = {
              #     text = "[1;5D";
              #   };
              # }
              # {
              #   key = "alt+f";
              #   command = "workbench.action.terminal.sendSequence";
              #   when = "terminalFocus && !terminalTextSelected";
              #   args = {
              #     text = "[1;5C";
              #   };
              # }
              # {
              #   key = "alt+d";
              #   command = "workbench.action.terminal.sendSequence";
              #   when = "terminalFocus && !terminalTextSelected";
              #   args = {
              #     text = "d";
              #   };
              # }
              # {
              #   key = "alt+r";
              #   command = "workbench.action.terminal.sendSequence";
              #   when = "terminalFocus && !terminalTextSelected";
              #   args = {
              #     text = "r";
              #   };
              # }
              # {
              #   key = "alt+t";
              #   command = "workbench.action.terminal.sendSequence";
              #   when = "terminalFocus && !terminalTextSelected";
              #   args = {
              #     text = "t";
              #   };
              # }
              # {
              #   key = "alt+c";
              #   command = "workbench.action.terminal.sendSequence";
              #   when = "terminalFocus && !terminalTextSelected";
              #   args = {
              #     text = "c";
              #   };
              # }
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
              {
                key = "ctrl+alt+k";
                command = "opencode.addFilepathToTerminal";
              }
              {
                key = "alt+cmd+k";
                command = "-opencode.addFilepathToTerminal";
              }
              {
                key = "ctrl+alt+g";
                command = "-workbench.action.terminal.sendSequence";
                when = "terminalFocus";
              }
            ];
          };
  };
}
