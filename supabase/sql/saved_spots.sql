create table public.saved_spots (
  device_id text not null,
  spot_id text not null,
  spot_json jsonb not null,
  created_at timestamptz not null default now(),
  primary key (device_id, spot_id)
);

alter table public.saved_spots enable row level security;

-- Matches the existing device_id-keyed tables (spot_views, search_queries,
-- analytics_events, spot_photos): the app has no Supabase Auth, so device_id
-- is trusted client-side rather than enforced by RLS ownership.
create policy "anon can manage saved_spots"
  on public.saved_spots
  for all
  to anon
  using (true)
  with check (true);
