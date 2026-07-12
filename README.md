# Campaign Shortener API

A Rails API that generates human-readable short URLs for marketing campaigns — e.g. `sunday-bonanza`, `diwali-festival`, `hurry-festival` — instead of random codes. Built as an interview-practice project exploring URL shortener design with a twist: meaningful, campaign-driven slugs.

## Features

- Create marketing campaigns with a custom or auto-generated slug
- Redirect short campaign URLs (`/sunday-bonanza`) to the original destination URL
- Campaign types: `weekday`, `festival`, `custom`
- Time-boxed campaigns (`starts_at` / `ends_at`) — expired or not-yet-active links return `410 Gone`
- Click tracking per campaign
- Slug collision handling (`diwali-festival`, `diwali-festival-2`, ...)

## Tech Stack

- Ruby on Rails (API-only)
- PostgreSQL
- RSpec (request specs)

## Setup

```bash
git clone https://github.com/vish-patil145/short_url.git
cd campaign_shortener_api
bundle install
```

### Database

Make sure PostgreSQL is running locally, then:

```bash
rails db:create
rails db:migrate
```

> **Local Postgres auth issues?** See [Troubleshooting](#troubleshooting) below.

### Run the server

```bash
rails server
```

API available at `http://localhost:3000`.

### Run tests

```bash
bundle exec rspec
```

## API Reference

### Create a campaign

```
POST /campaigns
Content-Type: application/json
```

**Request body:**
```json
{
  "name": "Sunday Bonanza",
  "original_url": "https://shop.example.com/sunday-sale",
  "campaign_type": "weekday",
  "ends_at": "2026-07-13T23:59:59Z"
}
```

**Response — `201 Created`:**
```json
{
  "name": "Sunday Bonanza",
  "slug": "sunday-bonanza",
  "short_url": "http://localhost:3000/sunday-bonanza",
  "original_url": "https://shop.example.com/sunday-sale",
  "campaign_type": "weekday",
  "active": true,
  "starts_at": null,
  "ends_at": "2026-07-13T23:59:59.000Z",
  "clicks_count": 0
}
```

**Response — `422 Unprocessable Entity`** (validation failure):
```json
{
  "errors": ["Original url is invalid", "Slug only lowercase letters, numbers, and hyphens"]
}
```

### List campaigns

```
GET /campaigns
```

Returns an array of campaign objects in the same shape as above.

### Redirect via short URL

```
GET /:slug
```

| Scenario | Response |
|---|---|
| Active campaign | `301 Moved Permanently` → redirects to `original_url` |
| Expired / not yet started | `410 Gone` with `{ "error": "This campaign link has expired or hasn't started yet" }` |
| Slug not found | `404 Not Found` with `{ "error": "Campaign not found" }` |

## Data Model

**`Campaign`**

| Column | Type | Notes |
|---|---|---|
| `name` | string | required |
| `slug` | string | unique, auto-generated from `name` if not provided |
| `original_url` | string | required, must be a valid http/https URL |
| `campaign_type` | integer (enum) | `weekday`, `festival`, `custom` |
| `starts_at` | datetime | optional |
| `ends_at` | datetime | optional |
| `clicks_count` | integer | default `0`, incremented on each redirect |

### Slug generation

- If a `slug` is provided, it's validated (`a-z`, `0-9`, `-` only) and must be unique.
- If omitted, it's derived from `name` via `parameterize` (e.g. "Diwali Festival" → `diwali-festival`).
- Collisions are resolved with an incrementing suffix: `diwali-festival-2`, `diwali-festival-3`, etc.

## Design Notes

- **Readable over random**: unlike a typical URL shortener (`SecureRandom.urlsafe_base64`), slugs here are meant to be human-readable and marketable, so collision handling uses an incrementing suffix rather than regenerating a random code.
- **410 vs 404**: an expired/future campaign returns `410 Gone` rather than `404 Not Found` — the resource existed, it's just no longer (or not yet) available.
- **`allow_other_host: true`**: required in Rails 7+ to redirect to external domains; a deliberate security opt-in rather than a default.
- **Route constraint**: the catch-all redirect route (`get "/:slug"`) is scoped with a regex constraint so it doesn't swallow other routes like `/campaigns`.

## Troubleshooting

**`PG::ConnectionBad: fe_sendauth: no password supplied`**

Your local Postgres role needs to match your OS user or have a password configured. Quickest fix:

```bash
sudo -u postgres createuser -s $(whoami)
```

Then retry `rails db:create`.

## Possible Extensions

- Per-user/campaign-owner tracking (multiple slugs pointing to different destinations for the same campaign)
- Rate limiting on campaign creation
- Redis-backed caching for high-read redirect traffic
- Analytics dashboard (clicks over time, by campaign type)