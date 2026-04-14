create extension if not exists pgcrypto;

create or replace function public.handle_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create or replace function public.generate_share_code()
returns text
language sql
as $$
  select upper(substring(replace(gen_random_uuid()::text, '-', '') from 1 for 6));
$$;

create table if not exists public.trips (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  description text,
  start_date date not null,
  end_date date not null,
  owner_id uuid not null,
  share_code text not null unique default public.generate_share_code(),
  is_archived boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.days (
  id uuid primary key default gen_random_uuid(),
  trip_id uuid not null references public.trips(id) on delete cascade,
  date date not null,
  label text not null,
  subtitle text,
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.stops (
  id uuid primary key default gen_random_uuid(),
  day_id uuid not null references public.days(id) on delete cascade,
  time time,
  title text not null,
  note text,
  badge text,
  map_url text,
  latitude double precision,
  longitude double precision,
  is_highlight boolean not null default false,
  reminder_minutes integer not null default 30,
  geofence_radius_m integer not null default 500,
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.parking_spots (
  id uuid primary key default gen_random_uuid(),
  stop_id uuid not null references public.stops(id) on delete cascade,
  name text not null,
  map_url text not null,
  sort_order integer not null default 0
);

create table if not exists public.shared_access (
  id uuid primary key default gen_random_uuid(),
  trip_id uuid not null references public.trips(id) on delete cascade,
  user_id uuid not null,
  joined_at timestamptz not null default now(),
  unique(trip_id, user_id)
);

create index if not exists idx_days_trip_id on public.days(trip_id);
create index if not exists idx_stops_day_id on public.stops(day_id);
create index if not exists idx_parking_spots_stop_id on public.parking_spots(stop_id);
create index if not exists idx_shared_access_trip_user on public.shared_access(trip_id, user_id);
create unique index if not exists idx_days_trip_date on public.days(trip_id, date);

drop trigger if exists set_trips_updated_at on public.trips;
create trigger set_trips_updated_at
before update on public.trips
for each row
execute function public.handle_updated_at();

drop trigger if exists set_days_updated_at on public.days;
create trigger set_days_updated_at
before update on public.days
for each row
execute function public.handle_updated_at();

drop trigger if exists set_stops_updated_at on public.stops;
create trigger set_stops_updated_at
before update on public.stops
for each row
execute function public.handle_updated_at();

alter table public.trips enable row level security;
alter table public.days enable row level security;
alter table public.stops enable row level security;
alter table public.parking_spots enable row level security;
alter table public.shared_access enable row level security;

drop policy if exists "trips_owner_all" on public.trips;
create policy "trips_owner_all"
on public.trips
for all
using (owner_id = auth.uid())
with check (owner_id = auth.uid());

drop policy if exists "trips_shared_read" on public.trips;
create policy "trips_shared_read"
on public.trips
for select
using (
  exists (
    select 1
    from public.shared_access sa
    where sa.trip_id = trips.id and sa.user_id = auth.uid()
  )
);

drop policy if exists "days_owner_all" on public.days;
create policy "days_owner_all"
on public.days
for all
using (
  exists (
    select 1
    from public.trips t
    where t.id = days.trip_id and t.owner_id = auth.uid()
  )
)
with check (
  exists (
    select 1
    from public.trips t
    where t.id = days.trip_id and t.owner_id = auth.uid()
  )
);

drop policy if exists "days_shared_read" on public.days;
create policy "days_shared_read"
on public.days
for select
using (
  exists (
    select 1
    from public.shared_access sa
    where sa.trip_id = days.trip_id and sa.user_id = auth.uid()
  )
);

drop policy if exists "stops_owner_all" on public.stops;
create policy "stops_owner_all"
on public.stops
for all
using (
  exists (
    select 1
    from public.days d
    join public.trips t on t.id = d.trip_id
    where d.id = stops.day_id and t.owner_id = auth.uid()
  )
)
with check (
  exists (
    select 1
    from public.days d
    join public.trips t on t.id = d.trip_id
    where d.id = stops.day_id and t.owner_id = auth.uid()
  )
);

drop policy if exists "stops_shared_read" on public.stops;
create policy "stops_shared_read"
on public.stops
for select
using (
  exists (
    select 1
    from public.days d
    join public.shared_access sa on sa.trip_id = d.trip_id
    where d.id = stops.day_id and sa.user_id = auth.uid()
  )
);

drop policy if exists "parking_spots_owner_all" on public.parking_spots;
create policy "parking_spots_owner_all"
on public.parking_spots
for all
using (
  exists (
    select 1
    from public.stops s
    join public.days d on d.id = s.day_id
    join public.trips t on t.id = d.trip_id
    where s.id = parking_spots.stop_id and t.owner_id = auth.uid()
  )
)
with check (
  exists (
    select 1
    from public.stops s
    join public.days d on d.id = s.day_id
    join public.trips t on t.id = d.trip_id
    where s.id = parking_spots.stop_id and t.owner_id = auth.uid()
  )
);

drop policy if exists "parking_spots_shared_read" on public.parking_spots;
create policy "parking_spots_shared_read"
on public.parking_spots
for select
using (
  exists (
    select 1
    from public.stops s
    join public.days d on d.id = s.day_id
    join public.shared_access sa on sa.trip_id = d.trip_id
    where s.id = parking_spots.stop_id and sa.user_id = auth.uid()
  )
);

drop policy if exists "shared_access_insert_self" on public.shared_access;
create policy "shared_access_insert_self"
on public.shared_access
for insert
with check (user_id = auth.uid());

drop policy if exists "shared_access_read_self" on public.shared_access;
create policy "shared_access_read_self"
on public.shared_access
for select
using (user_id = auth.uid());

drop policy if exists "shared_access_delete_self" on public.shared_access;
create policy "shared_access_delete_self"
on public.shared_access
for delete
using (user_id = auth.uid());

create or replace function public.join_trip_by_share_code(input_share_code text)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  target_trip_id uuid;
begin
  if auth.uid() is null then
    raise exception 'Authentication required';
  end if;

  select id
  into target_trip_id
  from public.trips
  where upper(share_code) = upper(trim(input_share_code))
    and is_archived = false
  limit 1;

  if target_trip_id is null then
    raise exception 'Invite code not found';
  end if;

  if exists (
    select 1
    from public.trips
    where id = target_trip_id and owner_id = auth.uid()
  ) then
    raise exception 'Owner cannot join own trip as guest';
  end if;

  insert into public.shared_access (trip_id, user_id)
  values (target_trip_id, auth.uid())
  on conflict (trip_id, user_id) do nothing;

  return target_trip_id;
end;
$$;

revoke all on function public.join_trip_by_share_code(text) from public;
grant execute on function public.join_trip_by_share_code(text) to authenticated;
