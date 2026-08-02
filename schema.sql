-- Deal Radar schema. Paste this whole file into the Supabase SQL Editor
-- (Supabase dashboard -> SQL Editor -> New query -> Run).

create table if not exists price_snapshots (
  id                  bigserial primary key,
  route_key           text not null,
  price               numeric not null,
  currency            text default 'AED',
  deep_link           text,
  captured_at         timestamptz default now(),
  -- The airports the API actually priced. Can differ from the intended
  -- route (e.g. a Sharjah departure for a Dubai query) -- confirmed by a
  -- live test on 2 Aug 2026. Always shown on the board so a route never
  -- silently claims a city it didn't actually price.
  actual_origin       text,
  actual_destination  text
);
create index if not exists price_snapshots_route_time
  on price_snapshots (route_key, captured_at desc);

create table if not exists calls (
  id               uuid primary key default gen_random_uuid(),
  route_key        text not null,
  label            text not null,
  code             text not null check (code in ('CHEAP','FAIR','HIGH')),
  price_at_call    numeric not null,
  currency         text default 'AED',
  avg_at_call      numeric not null,
  line             text not null,
  made_at          timestamptz default now(),
  -- outcome, filled in 14 days later by the scan job
  resolved_at      timestamptz,
  best_price_since numeric,
  correct          boolean,
  outcome_note     text
);
create index if not exists calls_route_time on calls (route_key, made_at desc);

-- Curated deals the APIs never carry: Etihad "UAE Residents Save" promo fares,
-- Emirates-ID staycation offers, hotel-PR deals. Added by hand.
create table if not exists deals (
  id                   uuid primary key default gen_random_uuid(),
  type                 text not null default 'flight',
  title                text not null,
  price                numeric,
  currency             text default 'AED',
  affiliate_url        text,
  emirates_id_required boolean default false,
  valid_until          date,
  created_at           timestamptz default now()
);

-- Alert subscribers (used once the email/WhatsApp layer lands).
create table if not exists users (
  id           uuid primary key default gen_random_uuid(),
  email        text,
  whatsapp     text,
  home_country text,
  created_at   timestamptz default now()
);

create table if not exists watches (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid references users(id) on delete cascade,
  type       text not null check (type in ('flight','hotel')),
  params     jsonb not null,
  threshold  numeric,
  active     boolean default true,
  created_at timestamptz default now()
);

-- The app talks to Supabase with the service key from the server only, so RLS
-- stays on with no public policies: nothing is readable from the browser.
alter table price_snapshots enable row level security;
alter table calls            enable row level security;
alter table deals            enable row level security;
alter table users            enable row level security;
alter table watches          enable row level security;
