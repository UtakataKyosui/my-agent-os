#!/bin/sh
# run-dev-server.ts starts `wrangler dev` without an --ip flag, so wrangler binds to
# 127.0.0.1 inside the container and is unreachable through a published port. Publish
# 8788 instead and forward it to wrangler's loopback listener, which keeps the
# externally visible origin on 8787 so the gatekeeper OAuth redirect URIs still match.
set -e

pnpm run-local &
APP_PID=$!

trap 'kill "$APP_PID" 2>/dev/null' INT TERM

while ! nc -z 127.0.0.1 8787; do
  if ! kill -0 "$APP_PID" 2>/dev/null; then
    echo "run-local exited before the server came up" >&2
    wait "$APP_PID"
    exit 1
  fi
  sleep 1
done

socat TCP-LISTEN:8788,fork,reuseaddr TCP:127.0.0.1:8787 &

wait "$APP_PID"
