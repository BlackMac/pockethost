# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

PocketHost is a multi-user, multi-tenant hosting platform for PocketBase. It enables running hundreds or thousands of PocketBase instances on a single server or across a global edge network.

## Development Commands

```bash
# Install dependencies
pnpm install

# Local development (full stack at pockethost.lvh.me)
pnpm dev

# Frontend-only development (talks to production backend)
pnpm dev:dashboard    # Dashboard at localhost:5174

# CLI development
pnpm dev:cli          # Runs CLI in development mode

# Code quality
pnpm lint             # Check formatting
pnpm lint:fix         # Auto-format code

# Type checking
cd packages/pockethost && pnpm check:types    # Backend types (tsc --noEmit)
cd packages/dashboard && pnpm check:types     # Frontend types (svelte-check)

# Production
pnpm prod:cli         # Run CLI in production mode
```

**Prerequisites for full-stack local development:** Install Caddy (`brew install caddy`) for local HTTPS.

## Monorepo Structure

This is a pnpm workspace monorepo with three main packages:

- **`packages/pockethost`** - Main CLI and backend (Commander.js, Express, PocketBase, Docker)
- **`packages/dashboard`** - SvelteKit frontend (static site, deployed to Cloudflare Pages)
- **`packages/pockethost-instance`** - Docker container image for PocketBase instances

## Architecture

### CLI Commands (Commander.js)

The CLI at `packages/pockethost/src/cli/` provides these main command groups:

- `pockethost serve` - Quick local instance serving
- `pockethost firewall serve` - Reverse proxy with IP filtering
- `pockethost mothership serve` - Central management backend
- `pockethost edge daemon|ftp|volume` - Edge worker services
- `pockethost health check|compact` - Health monitoring and DB compaction
- `pockethost pocketbase update` - Version management

### Backend Services (`packages/pockethost/src/`)

```
services/          # Core services (InstanceService, ProxyService, CronService, etc.)
mothership-app/    # Central management PocketBase app
  pb_hooks/        # PocketBase hooks (JavaScript for JSVM)
  pb_migrations/   # Database migrations (65+)
instance-app/      # Per-instance PocketBase app (supports v22, v23)
  pb_hooks/
  pb_migrations/
common/            # Shared utilities (Logger, CleanupManager, schema validation)
constants.ts       # Global configuration and environment settings
```

### Frontend (`packages/dashboard/src/`)

SvelteKit static site with TailwindCSS + DaisyUI. Uses mdsvex for markdown content.

### Process Management (PM2)

Production uses PM2 (`ecosystem.config.cjs`) to manage 9 processes: firewall, edge-daemon, edge-ftp, edge-volume, mothership, pocketbase-update, mothership-update-versions, health-check, health-compact.

## Key Patterns

- **Factory functions over classes** - Prefer factory functions that return an API object
- **Early returns** - Prefer early return patterns
- **IoC container** - Dependency injection via `src/core/ioc.ts`
- **Settings service** - Configuration management via `src/constants.ts` and Settings service

## PocketBase Integration

- PocketBase hooks are written in JavaScript for the JSVM (in `pb_hooks/` directories)
- Migrations are in `pb_migrations/` directories
- The mothership-app manages the central database; instance-app runs per user instance

## Environment Configuration

Copy `.env-template` to `.env`. Key variables:
- `APEX_DOMAIN` - Base domain (default: pockethost.lvh.me for local dev)
- `DATA_ROOT` - Instance data storage location
- `MOTHERSHIP_ADMIN_USERNAME/PASSWORD` - Admin credentials
- `SSL_KEY/SSL_CERT` - TLS certificates

## Coolify Deployment

PocketHost can be deployed on Coolify using Docker Compose. Key files:

- `Dockerfile` - Main application image
- `docker-compose.coolify.yml` - Compose file with Traefik labels
- `ecosystem.config.coolify.cjs` - PM2 config (excludes firewall/FTP)
- `coolify.env.example` - Environment variable template

**Coolify setup:**
1. Create a new Docker Compose service pointing to this repo
2. Set environment variables from `coolify.env.example`
3. Configure wildcard SSL certificate (DNS challenge required for `*.yourdomain.com`)
4. Ensure Docker socket access is enabled for the container

**Key environment variables for Coolify:**
- `PH_DISABLE_SSL=true` - Let Traefik handle SSL
- `APEX_DOMAIN` - Your base domain
- `MOTHERSHIP_ADMIN_USERNAME/PASSWORD` - Admin credentials
- `GITHUB_TOKEN` - For fetching PocketBase releases

## Code Generation Guidelines

- Never run build commands, type checking commands, or start servers
- When editing markdown with code snippets, indent code blocks with 2 spaces (never 0 or 4)
