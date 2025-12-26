// PM2 configuration for Coolify deployment
// Excludes firewall (Traefik handles SSL/routing) and FTP services
module.exports = {
  apps: [
    {
      name: 'mothership',
      script: 'pnpm prod:cli mothership serve',
      // Mothership should start first as other services depend on it
    },
    {
      name: 'edge-daemon',
      script: 'pnpm prod:cli edge daemon serve',
      cron_restart: '0 0 * * *', // Daily restart
    },
    {
      name: 'pocketbase-update',
      script: 'pnpm prod:cli pocketbase update',
      restart_delay: 60 * 60 * 1000, // 1 hour
    },
    {
      name: 'mothership-update-versions',
      script: 'pnpm prod:cli mothership update-versions',
      restart_delay: 60 * 60 * 1000, // 1 hour
    },
    {
      name: 'health-check',
      script: 'pnpm prod:cli health check',
      restart_delay: 60 * 1000, // 1 minute
    },
    {
      name: 'health-compact',
      script: 'pnpm prod:cli health compact',
      restart_delay: 60 * 60 * 1000 * 24, // 1 day
    },
  ],
}
