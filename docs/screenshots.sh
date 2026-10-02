#!/usr/bin/env bash
# Regenerates the README screenshots in docs/screenshots/ from the VHS tapes in docs/tapes/.
#
#   bash docs/screenshots.sh            # all tapes
#   bash docs/screenshots.sh tab        # only docs/tapes/tab.tape
#
# Needs herdr, lazysql, jq, docker, vhs (brew install vhs; pulls ttyd and ffmpeg) and optionally
# pngquant/oxipng.
#
# Nothing touches your herdr or your lazysql connections: a separate herdr server runs with its own HOME in
# a throwaway sandbox (its own config, socket and sessions), with only this plugin linked, and lazysql reads
# a demo config from that HOME. The database is a throwaway Postgres container with the made-up shop data
# from docs/demo.sql. The server, the container and the sandbox are removed afterwards.
set -euo pipefail

repo=$(cd "$(dirname "$0")/.." && pwd)
herdr_bin=$(command -v herdr || echo "$HOME/.local/bin/herdr")
cd "$repo"

# short path: herdr's unix sockets live under $HOME/.config/herdr
sandbox=$(cd "$(mktemp -d /tmp/hd.XXXXXX)" && pwd -P)
home="$sandbox/h"
container="herdr-lazysql-demo-$$"
cleanup() {
	[ -x "$sandbox/env.sh" ] && "$sandbox/env.sh" herdr server stop >/dev/null 2>&1 || true
	docker rm -f "$container" >/dev/null 2>&1 || true
	rm -rf "$sandbox"
}
trap cleanup EXIT

# --- demo database ---
docker run -d --name "$container" -p 127.0.0.1::5432 \
	-e POSTGRES_USER=shop -e POSTGRES_PASSWORD=shop -e POSTGRES_DB=shop postgres:17-alpine >/dev/null
for _ in $(seq 60); do
	docker exec "$container" pg_isready -U shop -d shop >/dev/null 2>&1 && break
	sleep 0.5
done
sleep 1
docker exec -i "$container" psql -q -U shop -d shop -v ON_ERROR_STOP=1 <docs/demo.sql
port=$(docker port "$container" 5432/tcp | head -n1 | sed 's/.*://')

# --- sandbox HOME: a demo project, lazysql config, herdr config ---
mkdir -p "$sandbox/bin" "$home/shop"/{src,public,config} "$home/Library/Application Support/lazysql" "$home/.config/herdr"
touch "$home/shop"/{composer.json,composer.lock,docker-compose.yml,README.md}
ln -s "$herdr_bin" "$sandbox/bin/herdr"
cat >"$home/Library/Application Support/lazysql/config.toml" <<EOF
[[database]]
Name = 'shop (local)'
Provider = 'postgres'
DBName = 'shop'
URL = 'postgres://shop:shop@localhost:$port/shop?sslmode=disable'

[[database]]
Name = 'shop (staging)'
Provider = 'postgres'
DBName = 'shop'
URL = 'postgres://shop@db.staging.example:5432/shop'
ReadOnly = true

[[database]]
Name = 'blog'
Provider = 'mysql'
DBName = 'blog'
URL = 'mysql://blog@blog.example.org:3306/blog'
EOF
mkdir -p "$home/.config/lazysql"
cp "$home/Library/Application Support/lazysql/config.toml" "$home/.config/lazysql/config.toml" # Linux path

cat >"$home/.config/herdr/config.toml" <<'EOF'
onboarding = false

[theme]
name = "dracula"

[terminal]
new_cwd = "~/shop"

[update]
version_check = false
manifest_check = false

[[keys.command]]
key = "prefix+s"
type = "plugin_action"
command = "herdr-lazysql.open-lazysql"
description = "lazysql"

[[keys.command]]
key = "prefix+t"
type = "plugin_action"
command = "herdr-lazysql.open-lazysql-tab"
description = "lazysql tab"
EOF
# a neutral prompt for the shell panes
printf "PROMPT='%%F{cyan}%%~%%f %%F{magenta}❯%%f '\n" >"$home/.zshrc"

# the environment of the sandboxed herdr (server, panes and plugin commands inherit it)
cat >"$sandbox/env.sh" <<EOF
#!/bin/sh
cd "$home/shop"
exec env -i HOME="$home" PATH="$sandbox/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin" \\
	TERM=xterm-256color SHELL=/bin/zsh LANG=en_US.UTF-8 "\$@"
EOF
chmod +x "$sandbox/env.sh"

start_herdr() {
	"$sandbox/env.sh" herdr server >>"$sandbox/server.log" 2>&1 &
	for _ in $(seq 50); do
		"$sandbox/env.sh" herdr status server 2>/dev/null | grep -q 'status: running' && break
		sleep 0.2
	done
	"$sandbox/env.sh" herdr plugin link "$repo" >/dev/null
}
stop_herdr() {
	"$sandbox/env.sh" herdr server stop >/dev/null 2>&1 || true
	rm -rf "$home/.config/herdr/session.json" "$home/.config/herdr/session-snapshots"
	sleep 1
}

export HERDR_DEMO="$sandbox/env.sh"
tapes=("$@")
if [ ${#tapes[@]} -eq 0 ]; then
	for f in docs/tapes/*.tape; do
		[ "$(basename "$f")" = config.tape ] || tapes+=("$(basename "$f" .tape)")
	done
fi
for t in "${tapes[@]}"; do
	echo "== $t"
	start_herdr # a fresh herdr session per tape
	vhs "docs/tapes/$t.tape"
	stop_herdr
done
[ -n "${KEEP_VHS:-}" ] || rm -rf .vhs

cd docs/screenshots
command -v pngquant >/dev/null && pngquant --force --skip-if-larger --quality 80-95 --ext .png ./*.png || true
command -v oxipng >/dev/null && oxipng -q -o 4 --strip safe ./*.png || true
ls -lh
