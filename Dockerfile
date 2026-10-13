# Runs Cloudflare OS via `pnpm run-local` (wrangler + workerd) as a long-lived service.
# Upstream has no first-party server deployment yet; see README "Deploy to your own server".
FROM node:22-bookworm-slim

RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates git socat netcat-openbsd \
 && rm -rf /var/lib/apt/lists/*

RUN corepack enable

WORKDIR /app

COPY . .

# run-local skips install/build when the source hash is unchanged, so warm the install here and
# leave only the first build to container start.
RUN pnpm install --frozen-lockfile

# Also the origin the gatekeepers derive their OAuth redirect URIs from, so it must match the URL
# the browser actually uses.
ENV VITE_BACKEND_HOST=localhost:8787

EXPOSE 8788

CMD ["./docker-entrypoint.sh"]
