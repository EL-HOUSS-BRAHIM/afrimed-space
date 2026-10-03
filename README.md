# Afrimed Space

Public introduction for **Afrimed**, **Lyvora**, and **Yaqeen**. All three projects
are marked **Coming soon**. Live at https://afrimed.space; no sign-in is required.

## Repository

- GitHub name: `afrimed-space`
- Local folder: `C:\dev\afrimed-space`
- `site/`: dependency-free HTML, CSS, and SVG brand mark
- `deploy/`: shared VPS gateway configuration
- `scripts/deploy-website.sh`: publication with gateway recovery
- `.github/workflows/deploy-website.yml`: publish main changes or run manually

This is a standalone repository. It has no Supabase dependency or application
secrets. System fonts and local assets keep it lightweight. The layout supports
mobile screens, semantic headings, visible keyboard focus, and reduced motion.
Project descriptions avoid inventing unannounced features or launch dates.

## Connect GitHub

Create an empty GitHub repository named **afrimed-space** (without generated
README or license). Then connect the local repository:

```powershell
cd C:\dev\afrimed-space
git remote add origin https://github.com/YOUR-ACCOUNT/afrimed-space.git
git push -u origin main
```

Create a GitHub environment named `website`. Add:

| Kind | Name | Value |
| --- | --- | --- |
| Secret | `VPS_SSH_KEY` | Dedicated VPS deployment private key |
| Variable | `VPS_HOST` | `169.58.97.2` |
| Variable | `VPS_USER` | `budgetify` |
| Variable | `VPS_KNOWN_HOSTS` | Previously verified SSH host key pins |

Never commit private keys. Once configured, commits touching `site/` or the
publication script on main deploy automatically. Manual publication is available
only on main. Changes to `deploy/` also trigger publication because gateway
changes require deliberate coordination with the backend repository.

## Hosting and recovery

Caddy serves `~/budgetify/website` through a read-only mount and manages HTTPS.
The gateway also serves production and preview Lyvora APIs. Website publication
and backend deployment acquire the same VPS lock. The backend repository retains
this website route and mount for subsequent tagged releases. Keep gateway edits
synchronized across the two repositories; this repository publishes the full
shared gateway configuration. It does not replace backend images.

Deployment validates Caddy, saves the previous configuration, checks public page
readiness and both API health endpoints, and restores the gateway on failure.
Last gateway backups are in `~/budgetify/gateway/website-previous.*`. Revert a
website commit and publish again to restore older page content. Cache lifetime
is five minutes.

## Initial publication

Published on 2026-10-03. The public root returned HTTP 200 through Cloudflare over
HTTPS. Production API remained version 1.0.0; preview remained available.
Source: https://github.com/EL-HOUSS-BRAHIM/afrimed-space. Initial publication was deployed directly over SSH.

## Brand assets

Original project artwork is copied unchanged:

- `afrimed-icon.png`: `Abdou05jr/AFRIMED-AI`, `apps/mobile/assets/images/icon.png`
- `lyvora-icon.png`: `EL-HOUSS-BRAHIM/Budgetify`, `apps/mobile/assets/images/icon.png`
- `yaqeen-logo.svg`: `angel-022/Yaqeen`, `frontend/public/yaqeen-logo.svg`

The arrows, rosette, and site mark are original SVG page assets.
