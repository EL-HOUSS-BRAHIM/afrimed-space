# Project search readiness — 2026-10-25

## Published sites

| Site | Canonical URL | Search Console property | Sitemap |
| --- | --- | --- | --- |
| Yaqeen | https://yaqeen-w.tech/ | `sc-domain:yaqeen-w.tech` | https://yaqeen-w.tech/sitemap.xml |
| Afrimed | https://health.afrimed.space/ | `sc-domain:health.afrimed.space` | https://health.afrimed.space/sitemap.xml |

Both domain properties were verified using dedicated Cloudflare TXT records.
Keep those records in DNS to retain verification. Both submitted sitemaps show
**Success**, with one discovered page each. Google URL Inspection's live tests
reported **URL is available to Google** and **Page can be indexed** for both.
This is crawl/index eligibility, not confirmation of inclusion or ranking.

## Validation

Production publication run: https://github.com/EL-HOUSS-BRAHIM/afrimed-space/actions/runs/40192774147

`scripts/check-coming-soon-seo.py` passed locally and against both live sites
from the VPS. It checks titles/descriptions, canonical URLs, crawler directives,
WebSite microdata, social metadata, 1200x630 PNG previews, robots permission for
Googlebot, sitemap contents, canonical redirects, and real 404 responses.
The shared hub, Lyvora website, portfolio health, and both Lyvora API health
endpoints returned HTTP 200 after deployment.

Cloudflare adds crawler-specific robots rules on Afrimed. Googlebot remains
allowed; restrictions on other agents are preserved. A generic search for
`Disallow: /` does not determine Googlebot's permission.

## After launch

Update the visible content and metadata when features are actually available.
Add new canonical content pages to the relevant sitemap. Monitor Search Console
indexing, queries, HTTPS, and field performance as Google gathers real data.
No launch dates, clinical credentials, reviews, or released product capabilities
are asserted by the coming-soon metadata.
