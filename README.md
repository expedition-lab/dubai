# Deal Radar — UAE outbound

A price watchdog, not a deal site. It tracks flights out of the UAE, records
its own price history, and tells you plainly whether today is a good time to
book — including when the answer is **wait**.

## Why this can exist

Every UAE deal source (Time Out, What's On, Cobone, hotel PR) earns money only
when you book *now*, so none of them will ever tell you to hold off. Booking
links here carry an affiliate marker that pays the same whether you book today
or in six weeks — so a "wait" call costs nothing to make. That asymmetry is the
entire product.

## Run it

```bash
npm install
cp .env.example .env.local     # paste TP_TOKEN and TP_MARKER
npm run dev                    # http://localhost:3000
npm test                       # verify the verdict + scoring rules
```

No token? Sign up free at travelpayouts.com, join the **Aviasales** program,
copy the API token (Profile → API token) and your marker. Until then the app
shows setup steps — it never displays invented prices.

## What it does

**`/` — the board.** Each route shows today's fare, its 30-day average, its
30-day low, a sparkline of the actual history, and a verdict:

| Verdict | Rule |
|---|---|
| `CHEAP` | 15%+ below the route's own 30-day average |
| `HIGH` | 10%+ above it — we say wait |
| `FAIR` | in between, no urgency |
| `LEARNING` | fewer than 3 readings, no call made |

**`/record` — the public ledger.** Every CHEAP/HIGH call is logged with its
date and price, then auto-scored 14 days later against what the price actually
did. Wrong calls stay published permanently. The scorecard at the top counts
right, wrong, and pending. Nothing is curated by hand — that's the point.

**`/method` — the published rules.** Every threshold, the scoring logic, and an
honest list of what the system can't do. Trust here comes from checkable
mechanism, not from a founder's face.

**`/api/scan`** — one scan: reads real fares, appends snapshots, records
verdicts, resolves due calls. Guard it with `SCAN_KEY` when deployed.

## Make it run daily

Deploy, set `TP_TOKEN` / `TP_MARKER` / `SCAN_KEY`, then hit
`/api/scan?key=...` once a day (Vercel Cron, GitHub Actions, or
`SCAN_URL=... npm run scan`).

On serverless hosts the JSON file store resets — that's when you move
`lib/store.ts` and `lib/calls.ts` to Supabase using `schema.sql`. Same
interfaces, nothing else changes.

## Honest limits

- Prices come from the Aviasales recent-search **cache**: strong on busy
  routes, thin on quiet ones, and not a guaranteed live quote.
- It doesn't predict. It places today against the recent past.
- Day one it knows nothing. Three readings minimum before any call, and the
  ledger only becomes persuasive after a few weeks of daily scans.
- Holiday surges and new routes will fool it. That's why misses stay public.

## Next layers

1. Email alerts (Resend) on CHEAP verdicts
2. WhatsApp alerts (Cloud API templates) — the channel that matters in the UAE
3. Hotellook adapter for the hotel side, same engine
4. Curated Emirates-ID staycation deals no API carries
5. User accounts: own routes, own thresholds

## Testing without a token

```bash
npm test          # verifies the verdict thresholds and call-scoring rules
npm run simulate  # runs 30 days of SIMULATED prices through the real
                  # store/verdict/ledger modules, then renders at localhost:3000
```

`simulate` writes invented prices into `data/` so you can see the whole
machine work — verdicts, ledger entries, 14-day scoring — before your token
arrives. Delete the `data/` folder to wipe it before going live. Simulated
prices never reach users: the board only renders what's in the store, and the
store is empty until you scan or simulate.
