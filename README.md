# seehand

Eyes and hands for an AI coding agent on a Linux X11 desktop, plus a text-only web debugger.

One CLI. Every command prints short plain text, so an agent can read the screen and act on it without burning tokens on screenshots.

- **Desktop:** reads any app's widgets through the AT-SPI accessibility tree, clicks buttons and fills fields through their accessibility actions, falls back to XTEST mouse/keyboard and screenshots when an app draws its own UI.
- **Web:** drives a Chromium browser over the Chrome DevTools Protocol: console errors, failed requests, DOM, JS eval, page screenshots.

Requires X11. Wayland sessions are not supported. Web commands need Chrome, Chromium or Brave (native or flatpak). Firefox removed CDP and cannot be used.

## Install

```sh
# Arch/Artix: pacman -S python-gobject at-spi2-core
# Debian/Ubuntu: apt install python3-gi gir1.2-atspi-2.0
git clone https://github.com/vladbiber/seehand && cd seehand
./install.sh          # venv + ~/.local/bin/seehand
seehand help
```

Apps only expose their widgets when accessibility is on. GTK and Qt apps usually do; Chromium/Electron apps need `--force-renderer-accessibility`.

## Desktop

```sh
seehand apps                         # accessible running apps
seehand tree --app easyeffects       # widget tree, named and actionable nodes only
seehand find "Save" --role push      # search widgets by visible text
seehand do --name "OK"               # press a button via its action, no mouse move
seehand set --name "Email" "x@y.z"   # set a text field, no keyboard
seehand info 2/0/3                   # role, states, actions, position
```

`2/0/3` is an index path printed by `tree` and `find`.

When the accessibility tree is blind (games, canvas, custom drawing):

```sh
seehand shot --scale 0.4 --region 0 0 800 600   # prints the PNG path
seehand click 540 320 -b r                      # -d double click
seehand drag 100 100 400 400
seehand scroll -3
seehand type "hello"
seehand key ctrl+s Return
seehand run "pavucontrol"
```

Screenshots go to `~/.cache/seehand/`.

## Web

```sh
seehand web-launch https://example.com   # isolated debug browser on :9222
seehand web-load https://example.com     # navigate, print console + network problems
seehand web-eval "document.title"
seehand web-log --ms 3000                # console errors/warnings (--all for everything)
seehand web-net --ms 3000                # failed and 4xx/5xx requests (--all for everything)
seehand web-dom --sel h1
seehand web-shot
seehand web-tabs
seehand web-kill
```

`web-launch` frees the port, works with flatpak Chrome (profile in `~/Documents/seehand-chrome-debug`, which the sandbox can see) and starts a separate profile, so your real browser is never touched.

### Acting as you: `web-login`

```sh
seehand web-login          # prints what it would do, changes nothing
seehand web-login --yes    # copies your real Chrome session into the debug browser
```

It reads the cookies of your own browser profile, decrypts them and injects them into the debug browser, so the agent is signed in as you on every site you are logged into.

**This is sensitive.** Anything that can reach port 9222 while the debug browser runs can act as you. Only use it on your own machine and account, and run `seehand web-kill` when done. Only `v10` cookies (Chrome's basic key, used when no keyring is running) can be decrypted; with a working GNOME Keyring or KWallet, cookies are `v11` and are skipped.

## For agents

Put this in your agent instructions:

1. Read with `tree`/`find` before you screenshot. Text is exact and costs a fraction of an image.
2. If you must screenshot, use `--scale 0.4` or `--region`.
3. Act through widgets (`do`, `set`) before raw `click`/`type`; they do not move the user's cursor.
4. For websites use `web-load`/`web-eval`, not desktop screenshots.
5. Confirm results by reading a value back, not by looking at a picture.

## Notes

- Chrome rejects the DevTools websocket unless it is launched with `--remote-allow-origins=*` and the client sends no `Origin` header. `web-launch` and the client handle both.
- Flatpak Chrome can leave half-dead processes holding the port. `web-launch` and `web-kill` clean them up by PID.
- Don't kill processes with `pkill -f <pattern>` from scripts: the pattern can match your own shell.

## License

MIT
