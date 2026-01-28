config.load_autoconfig(True)
# c.window.hide_decoration = True

# c.colors.webpage.darkmode.enabled = True

# c.qt.args = [ "disable-gpu" ]

c.qt.environ = {"NODE_PATH": "/run/current-system/sw/lib/node_modules"}

c.url.default_page = "https://google.com"
c.url.start_pages = c.url.default_page
c.url.searchengines = {"DEFAULT": "https://google.com/search?q={}"}
with config.pattern("teams.microsoft.com") as p:
    p.content.unknown_url_scheme_policy = "allow-all"
c.content.unknown_url_scheme_policy

c.editor.command = ["emacsclient", "{}"]

c.statusbar.show = "never"
c.tabs.show = "switching"

c.bindings.commands["normal"] = {
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
    "<Meta-i>": "open javascript:location.href='org-protocol://capture?template=L&url='+encodeURIComponent(location.href)+'&title='+encodeURIComponent(document.title)+'&body='+encodeURIComponent(window.getSelection())",
}

# Doom emacs like key binding
c.bindings.commands["insert"] = {
    # editing
    "<ctrl-f>": "fake-key <Right>",
    "<ctrl-b>": "fake-key <Left>",
    "<ctrl-a>": "fake-key <cmd-left>",
    "<ctrl-e>": "fake-key <cmd-right>",
    "<ctrl-n>": "fake-key <Down>",
    "<ctrl-p>": "fake-key <Up>",
    "<alt-f>": "fake-key <Alt-Right>",
    "<alt-b>": "fake-key <Alt-Left>",
    "<ctrl-d>": "fake-key <Delete>",
    "<alt-d>": "fake-key <Alt-Delete>",
    "<ctrl-u>": "fake-key <cmd-shift-left> ;; fake-key <backspace>",
    "<ctrl-k>": "fake-key <cmd-shift-right> ;; fake-key <backspace>",
    "<ctrl-w>": "fake-key <alt-backspace>",
    "<ctrl-y>": "insert-text",
    "<ctrl-shift-e>": "edit-text",
}

c.bindings.commands["caret"] = {
    # Org roam capture
    "<Meta-Shift-L>": "open javascript:location.href='org-protocol://roam-ref?template=r&ref='+encodeURIComponent(location.href)+'&title='+encodeURIComponent(document.title)+'&body='+encodeURIComponent(window.getSelection())",
    # Plain old org capture
    "<Meta-p>": "open javascript:location.href='org-protocol://capture?template=p&url='+encodeURIComponent(location.href)+'&title='+encodeURIComponent(document.title)+'&body='+encodeURIComponent(window.getSelection())",
    # Plain old org capture at current point
    "<Meta-i>": "open javascript:location.href='org-protocol://capture?template=L&url='+encodeURIComponent(location.href)+'&title='+encodeURIComponent(document.title)+'&body='+encodeURIComponent(window.getSelection())",
}

c.bindings.commands["command"] = {
    "<ctrl-j>": "completion-item-focus next",
    "<ctrl-k>": "completion-item-focus prev",
    "<ctrl-d>": "rl-delete-char",
}

c.bindings.commands["prompt"] = {
    "<ctrl-j>": "prompt-item-focus next",
    "<ctrl-k>": "prompt-item-focus prev",
}

# Universal Emacsien C-g alias for Escape
config.bind("<Ctrl-g>", "clear-keychain ;; search ;; fullscreen --leave")
# Dark mode toggling
config.bind(
    "<cmd-d>",
    "config-cycle colors.webpage.darkmode.enabled ;; restart ;; session-load -f _autosave",
)
for mode in ["caret", "command", "hint", "insert", "passthrough", "prompt", "register"]:
    config.bind("<Ctrl-g>", "mode-leave", mode=mode)
    config.bind(
        "<cmd-d>",
        "config-cycle colors.webpage.darkmode.enabled ;; restart ;; session-load -f _autosave",
        mode=mode,
    )


config.unbind("<ctrl-q>")
config.unbind("<ctrl-n>")
config.unbind("<ctrl-t>")
config.unbind("<ctrl-w>")
config.unbind("<ctrl-shift-w>")
# I use `x` instead `d`.
config.unbind("d")

# config.bind(';;', 'hint inputs --first')  # easier to reach than ;t -> can be inserted using gi

# Open in firefox
config.bind(";g", "hint links spawn open -na Firefox --args {hint-url}")

c.aliases["readability-js"] = "spawn -u readability-js"
c.aliases["readability"] = "spawn -u readability"
c.aliases["firefox"] = "spawn open -na Firefox --args {url}"
c.aliases["removed"] = (
    "open javascript:document.location=document.URL.replace('reddit.com','removeddit.com');"
)
c.aliases["save-to-zotero"] = (
    "jseval --quiet var d=document,s=d.createElement('script');s.src='https://www.zotero.org/bookmarklet/loader.js';(d.body?d.body:d.documentElement).appendChild(s);void(0);"
)
c.aliases["mouse-pointer"] = (
    "open javascript:void%20function(){document.head.innerHTML+=%22%3Cstyle%3E%20*%20%20{%20cursor:%20url(data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAGCklEQVRYhe2XTWwd1RXHj2fmzpdnxm/G7z1btjG2lTpOU2rhNkGWElQSZCJkCQUhZJQVlCYyUutERan4kGqvyCYSrEAWWA4fKlRJXFfdRapA2WSBIAtokYUIyESgIJQ6tnHs9+b+uphrwqJ23EAXVXulq7/mfpx77rnnnP8Zkf+3/9LWQNGt7/QGKfp/piHSMC5ivSuiEPERCRGJEIkNhoj474qo8RsK/WCHW4i45qAyIrddF/kRIjtXRe5AZKf5vs3MR2a99X3PbkDEQaQRkSoivYgMInI/tv0Itv0Ytv0rg48gcr+Z7zXrGxFx5FasYd5YIZIg0onIXdj2Q7lSR3HdE3jeZO77r+P7f8h9/3U8bxLXPZErdRTbfgiRu8y+xMj595QwN08Q6UHkHizrCEqdxPNOEwTnCcOLRNFHxPEcUfQRYXiRIDiP551GqZNY1hFE7jH7E2OJLR9uG/N1IbIPpcbwvJd1ELxDFM0Rx1/S1HSVNL1Gmi6SptdoarpKHH9JFM0RBO/geS+j1Bgi+4ycRkTsrZreQ6QVkUEs64ncdacIggtE0Tyl0gJZtkK5vEqlskalUqNSWaNcXiXLViiVFoiieYLgQu66U1jWE4gMLhXyvJs+hbl9gsgObHsEpV4gCM4Tx5+Tpos0N6/S2lqjvb1OZ2edrq6czs467e11WltrNDevkqaLxPHnBMF5lHoB2x5BZIeRu6kVGkz4tCByN45zHM+bJY4/plRaoFxepa2tTnd3Tn9/zt69mn37NHv3avr7c7q7c9ra6pTLq7pUWiCOP8bzZnGc3yFyt5HrbmgFY/7AOM6DKPW8DsMLJMkVmptXaG2t0dOTMzioGRnRjI1pjh8vcGREMzio6enJjSVWSJIrhOGFXKnnEXnQyA03U8AymW0ntv0Yvv8aUfQ3SqUFKpU1OjrqDAzkHDqkmZiAF1+EV14pcGICDh3SDAzkdHTUqVTWjD/8Hd9/Ddv+JSI/QSQe3yhB/VHEvipSQmQApX6N550ljj8hTZeoVmt0d+fs36958knN5KTmrbc0p08XODlZjO/fr+nuzqlWa6TpMnH8CZ43g1K/QeRnFPL/tR8gYv9DJEVkF0odIwj+TJJ8RpYtU63W2LYtZ3hYMz6uOXVKc+aMZmamwFOnivHhYc22bYUCWbZMknxGEPwFx/ktIrsRyTbMCSYCUkR+jlJjOgj+RBxf+laBnp6cAwc0Tz+tmZoqbn/2bIFTU8X4gQOFH6wrEMef6iCYRamjiOwyF9zQAhYiyarIT7GsI/j+m8TxHGm6SKWyRmdnncFBzeHDmpMnYXpa88Ybmunp4vvw4cIROzsLHyjCcQ7ff9Nkxn5EmjYkKaNAIyK92PZI7nkvEYbv6yT5mnL5Om1tdbZvzxka0oyOFo544kThgKOjmqEhzfbt66F4nST5mjB8H897yZBVr5G/oQLrWbAdkSFcdwLfP0cUzZOmS99GQl9fzp49mgce0Dz8cIF79mj6+m5EQJouEUXz+P45XHcCkSFEOm6aDQ0JpYjciW0/jutO6TB8jyS5QpZ9Q7W6Rnt7kQF7e3N27Ciwqyunvb1OtbpGln1jcsB7uetO1W37cUTuNHI3JyXzDIGh0ntxnKe0550hij4kSb4iy5Ypl1epVmu0tNRoba3T0lKjWq0ZPlgmSb4iij7E887gOE8hcq+RF2ypSDFWaEKkD5GDuetO4HkzhOFF4viyYcIlsmyF5uYVsmyFNF0yjHiZMLyI580Y0x80cpq2TMnc4IQyInfUbfsgjvNM7rqvEgRv09j4gY7jS8TxZZLkC+L4MnF8icbGDwiCt3HdV3GcZ+q2fZCiZCtvygGbPIVnNv8YkfuwrFFc9zlcd5ogmMX3zxEEfzU4i+tO47rPYVmjiNy3WuwrI+KN30p9+B0lSqao2IXIMLb9KEodw3GezR3n9zjOsyh1DNt+FJFhRHatiHSZtO5t6d03UWK9NgzNbW43pLLbUOwvDO4247dfK9aF3EoteBNrKOPJ8UKR0yuIVBcLzBCJ54t59b1ufRNF1v+IHHPQenf4oX9I/ifaPwEDuMzfkWqgjAAAAABJRU5ErkJggg==),%20auto%20!important;%20}%20%3Cstyle%3E%22}();"
)

# Activate dracula theme
import dracula.draw

dracula.draw.blood(c, {"spacing": {"vertical": 6, "horizontal": 8}})
