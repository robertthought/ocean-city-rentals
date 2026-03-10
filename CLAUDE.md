# Ocean City Rentals - Project Context

## Deployment Setup

**Production URL**: https://ocnjweeklyrentals.com
**Server**: Hetzner VPS at `178.156.196.11` (hostname: `snowy-river`)
**Platform**: Ploi.io for server management
**User**: `ploi`

## Tech Stack

- **Framework**: Rails 8.1.2
- **Ruby**: 3.4.8 (via rbenv at `/home/ploi/.rbenv/shims/`)
- **Server**: Puma 7.2.0
- **Database**: PostgreSQL 17.6
- **Reverse Proxy**: nginx

## Server Paths

```
App directory:    /home/ploi/ocnjweeklyrentals.com
Ruby/Bundle:      /home/ploi/.rbenv/shims/bundle
Logs:             /home/ploi/ocnjweeklyrentals.com/log/production.log
Environment:      /home/ploi/ocnjweeklyrentals.com/.env
Puma config:      /home/ploi/ocnjweeklyrentals.com/config/puma.rb
```

## Deployment

Deployments are triggered via Ploi. The deploy script is at `ploi-deploy.sh`.

**IMPORTANT**: The app runs via a Ploi daemon (supervisor). After any deploy:
- The daemon should auto-restart the app
- If not, manually restart via Ploi Dashboard → Server → Daemons

### Daemon Configuration (Ploi)

```
Command:          ~/.rbenv/shims/bundle exec puma -C config/puma.rb
Directory:        /home/ploi/ocnjweeklyrentals.com
Environment file: /home/ploi/ocnjweeklyrentals.com/.env
User:             ploi
Processes:        1
```

## Troubleshooting

### 502 Bad Gateway

This means nginx can't reach Puma. Check if Puma is running:

```bash
ssh root@178.156.196.11  # or use Ploi console
ps aux | grep puma
```

If not running:
1. Go to Ploi Dashboard → Server → Daemons
2. Find the ocnjweeklyrentals daemon and click Restart
3. Or manually: `cd /home/ploi/ocnjweeklyrentals.com && ~/.rbenv/shims/bundle exec puma -C config/puma.rb -d`

### Check Logs

```bash
# App logs
tail -100 /home/ploi/ocnjweeklyrentals.com/log/production.log

# Supervisor logs
sudo tail -50 /var/log/supervisor/supervisord.log

# nginx logs
sudo tail -50 /var/log/nginx/error.log
```

### Common Issues

1. **Deploy kills app but doesn't restart**: The `ploi-deploy.sh` script must restart the daemon after deploying
2. **Ruby not found**: Use full path `/home/ploi/.rbenv/shims/bundle` or `/home/ploi/.rbenv/shims/ruby`
3. **Supervisor not running**: Go to Ploi → Services → Start supervisor

## Port Configuration

- nginx listens on 80/443 and proxies to Puma
- Puma port is configured in `config/puma.rb` (check this matches nginx upstream)

## Related Sites on Same Server

- `str.ocnjweeklyrentals.com` - Node.js app (separate)
- `office.dlsnproperties.com` - Another Rails app
