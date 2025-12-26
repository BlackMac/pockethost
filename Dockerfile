FROM node:20-alpine

# Install Docker CLI (for dockerode to communicate with host Docker daemon)
# and other required tools
RUN apk add --no-cache docker-cli bash curl

# Install pnpm and PM2 globally
RUN npm install -g pnpm pm2

WORKDIR /app

# Copy package files first for better layer caching
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml .npmrc ./
COPY packages/pockethost/package.json ./packages/pockethost/
COPY packages/dashboard/package.json ./packages/dashboard/
COPY packages/pockethost-instance/package.json ./packages/pockethost-instance/
COPY packages/pockethost/src/mothership-app/package.json ./packages/pockethost/src/mothership-app/

# Install dependencies
RUN pnpm install --frozen-lockfile

# Copy source code
COPY . .

# Create data directories
RUN mkdir -p /data/pockethost/data /data/pockethost/gobot

# Expose ports:
# 3000 - Edge daemon (instance proxy)
# 8091 - Mothership (central PocketBase)
EXPOSE 3000 8091

# Use the Coolify-specific PM2 config
CMD ["pm2-runtime", "ecosystem.config.coolify.cjs"]
