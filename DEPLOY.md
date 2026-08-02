# Deploy from a browser only

No terminal, no local install. Roughly 30 minutes end to end.

---

## 1. Travelpayouts — get the data + the money  (5 min)

1. Sign up free at **travelpayouts.com**
2. Join the **Aviasales** program (that's the flights feed)
3. Copy two values:
   - **API token** — Profile → API token
   - **Marker** — your affiliate ID, shown on the dashboard

Keep them in a note. They go into Vercel in step 4.

---

## 2. GitHub — put the code somewhere  (5 min)

1. Sign up at **github.com**
2. **New repository** → name it `uae-deal-radar` → set **Private** → Create
3. On the empty repo page click **uploading an existing file**
4. Unzip the project on your device, then drag **all the files and folders** into the browser
   - Do NOT upload `node_modules`, `.next`, or `data` if they exist
   - There must be no `.env.local` — your token never belongs in a repo
5. **Commit changes**

---

## 3. Supabase — where the price history lives  (10 min)

This is not optional once deployed. On Vercel the filesystem resets between
runs, so without a database the price history never accumulates — and the
history is the entire product.

1. Sign up at **supabase.com** → **New project** (free tier is fine)
2. Wait for it to finish provisioning
3. Left sidebar → **SQL Editor** → **New query**
4. Open `schema.sql` from the project, paste the whole thing in, click **Run**
5. Left sidebar → **Project Settings → API**, copy:
   - **Project URL**
   - **service_role** key (the secret one — server-side only, never public)

---

## 4. Vercel — put it online  (10 min)

1. Sign up at **vercel.com** with your GitHub account
2. **Add New → Project** → import `uae-deal-radar`
3. Before deploying, open **Environment Variables** and add five:

   | Name | Value |
   |---|---|
   | `TP_TOKEN` | your Travelpayouts API token |
   | `TP_MARKER` | your Travelpayouts marker |
   | `SUPABASE_URL` | Supabase Project URL |
   | `SUPABASE_SERVICE_KEY` | Supabase service_role key |
   | `SCAN_KEY` | any random string you invent |

4. **Deploy**, then open the live URL

Your site is up. Click **Read prices now** — this is the first moment real
fares are pulled. Confirm each route returns a price.

---

## 5. The daily job

`vercel.json` already schedules `/api/scan` for 06:00 UTC daily. Vercel Cron
sends `Authorization: Bearer <SCAN_KEY>`, which the endpoint accepts, so
nothing else is needed. Check **Vercel → your project → Cron Jobs** after a day
to confirm it ran.

If the free plan limits cron frequency, use **cron-job.org** (free, browser
only) instead: schedule a daily GET to
`https://YOUR-SITE.vercel.app/api/scan?key=YOUR_SCAN_KEY`

---

## 6. Then wait

The board will read **LEARNING** on every route at first. That is correct — a
route needs three readings before it earns a call, and the track record only
becomes persuasive after a couple of weeks of daily scans.

Nothing to do in that period except let it run. The history compounds daily and
cannot be rushed later, which is exactly why it's worth something.

---

## Checks if something looks wrong

- **Board shows setup steps** → `TP_TOKEN` missing or misspelled in Vercel
- **Prices appear but history never grows** → Supabase vars missing; the app
  fell back to the file store, which resets. The footer of the board shows
  which driver is active.
- **A route always says "no cached fare"** → that route is thin in the cache.
  Remove it from `routes.config.ts` rather than publishing weak calls on it.
- **Cron never runs** → check Vercel Cron Jobs; fall back to cron-job.org
