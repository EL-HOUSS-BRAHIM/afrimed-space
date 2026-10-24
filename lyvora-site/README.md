# Lyvora public website

Canonical URL: https://lyvora-finance.tech/ (www redirects to the apex).
Owner: Brahim El Houss. Source: this repository's `lyvora-site/` directory.

The standalone website uses local assets, HTML and CSS, including a native
details/summary FAQ. It has no application secrets or login form. Application
APIs continue to use their existing hostnames.

## Deployment

`deploy-lyvora-website.yml` runs browser checks for pull requests and main pushes.
Only main publishes. It uses the existing `website` GitHub environment's pinned
SSH credentials, its own workflow concurrency group, and the shared VPS lock.
It doesn't replace the Afrimed website or shared gateway configuration.

Releases are stored at `~/budgetify/website/lyvora-site/releases/<sha>-<run>-<attempt>`.
The relative `current` symlink is switched atomically after archive validation.
Origin checks verify the exact release and download page; public checks verify
the site, Afrimed, and both APIs. Failed checks restore the previous symlink.
No release is automatically deleted. `previous-release.txt` records the previous
successful target for recovery. `revision.txt` identifies the current release.

Initial provisioning installs the route from `deploy/Caddyfile.gateway` and
stages a first release. The directory is already inside the gateway's read-only
website mount, so no host service or public port is added. Gateway copies in
Budgetify and Afrimed Space must continue to match.

Manual publication: Actions → deploy-lyvora-website → Run workflow → main.
To restore a historical version, revert its source change and publish again.
For emergency symlink rollback, take `~/budgetify/deploy.lock`, validate a known
release under `releases/`, and atomically replace `current` with that relative
target. Verify `/revision.txt` directly at the HTTPS origin and public routes.

## APK delivery

The new domain's `/downloads/current/*` maps to the existing
`~/budgetify/website/lyvora/downloads/current/*`. Budgetify continues to publish
the verified installer and checksum there. Legacy download URLs still work;
website releases neither copy nor overwrite APKs. Source/release links on GitHub
may require private repository access, which is stated on the download page.
