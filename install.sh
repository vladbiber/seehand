#!/bin/sh
# Creates a venv next to the script and links seehand into ~/.local/bin.
set -eu
dir=$(cd "$(dirname "$0")" && pwd)
python3 -c 'import gi; gi.require_version("Atspi", "2.0")' 2>/dev/null || {
	echo "install PyGObject and AT-SPI first (Arch: python-gobject at-spi2-core, Debian: python3-gi gir1.2-atspi-2.0)" >&2
	exit 1
}
python3 -m venv --system-site-packages "$dir/venv"
"$dir/venv/bin/pip" install -q -r "$dir/requirements.txt"
mkdir -p "$HOME/.local/bin"
printf '#!/bin/sh\nexec "%s/venv/bin/python" "%s/seehand" "$@"\n' "$dir" "$dir" > "$HOME/.local/bin/seehand"
chmod +x "$HOME/.local/bin/seehand"
echo "installed: $HOME/.local/bin/seehand"
