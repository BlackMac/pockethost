FROM node:20-alpine

# Install Docker CLI and build tools for native dependencies
# (better-sqlite3, sharp, ssh2, etc. need compilation)
RUN apk add --no-cache \
    docker-cli \
    bash \
    curl \
    python3 \
    make \
    g++ \
    git

# Install pnpm and PM2 globally
RUN npm install -g pnpm pm2

WORKDIR /app

# Copy everything (pnpm workspaces need full structure including patches)
COPY . .

# Install dependencies
RUN pnpm install --frozen-lockfile

# Create data directories
RUN mkdir -p /data/pockethost/data /data/pockethost/gobot

# Expose ports:
# 3000 - Edge daemon (instance proxy)
# 8091 - Mothership (central PocketBase)
EXPOSE 3000 8091

# Use the Coolify-specific PM2 config
CMD ["pm2-runtime", "ecosystem.config.coolify.cjs"]
