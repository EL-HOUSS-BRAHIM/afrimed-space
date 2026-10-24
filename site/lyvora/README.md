# Lyvora presentation pages

Legacy presentation routes `/lyvora/` and `/lyvora/download.html` redirect to
https://lyvora-finance.tech/ and its download page. The standalone source and
pipeline now live in `lyvora-site/` and `deploy-lyvora-website.yml`. These legacy
files are retained for recovery; edit the standalone source for future changes.

The pages use local artwork, system fonts and CSS only. No account forms, analytics, app credentials or remote scripts are included. The phone illustration is explicitly labelled as example data.

The direct download is hosted on the VPS, outside Git: `downloads/current/lyvora-preview.apk` and its matching SHA-256 file. The initial installer is from Budgetify release `preview-v1.0.38.38172796291.1`. Budgetify's preview workflow includes a public-download job after successful release publication. It transfers the already verified ARM64-compatible APK, checks its checksum again on the VPS, and atomically switches the `current` directory link. OTA-only deliveries retain the compatible installer. Website deployments copy files recursively and preserve this server-managed downloads directory.

The website bundles this installer intentionally for public download. GitHub repository and release details remain subject to the private repository's access controls. This changes the earlier policy of keeping preview APKs out of the public website directory for this selected installer only.

The Afrimed workflow preserves the server-managed installer directory. The
standalone Lyvora workflow publishes presentation files separately. App API
hosts and their gateway routes are unchanged.
