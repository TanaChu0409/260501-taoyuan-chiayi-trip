-- SECURITY FIX: Remove SECURITY DEFINER from profiles_public view.
--
-- Problem: PostgreSQL views default to running with the permissions of the
-- view owner (SECURITY DEFINER behaviour), bypassing the querying user's RLS.
-- The Supabase linter flags this as a security concern.
--
-- Root cause: After migration 015, the profiles table RLS only allows a user
-- to read their own row (profiles_read_self). The profiles_public view was
-- implicitly relying on SECURITY DEFINER to bypass that restriction and join
-- peer profiles. Switching to security_invoker without compensating RLS would
-- break trip member lists entirely.
--
-- Full fix (three steps):
--   1. Add a peer-read RLS policy on profiles so the view can see peer rows
--      when running under the querying user's permissions.
--   2. Restrict the email column at the grant level so that even with the
--      broader peer-read RLS, authenticated users cannot read email addresses
--      by querying profiles directly. Email is available from auth.getUser()
--      in the Flutter app and does not need to be exposed via the table.
--   3. Recreate profiles_public with security_invoker = true. The view body
--      and grants are unchanged from migration 015.
--
-- Requires PostgreSQL 15+ (available on all Supabase Cloud projects).

-- ── Step 1: Add peer-read RLS policy on public.profiles ─────────────────────
-- Allows a user to read the profile rows of people who share a trip with them
-- (either as a co-member or as the trip owner). Self-access is already covered
-- by the profiles_read_self policy added in migration 015.
drop policy if exists "profiles_read_trip_peer" on public.profiles;
create policy "profiles_read_trip_peer"
on public.profiles
for select
using (
  auth.uid() is not null
  and (
    -- co-member: both this user and the querying user appear in shared_access
    -- for the same trip
    exists (
      select 1
      from public.shared_access sa1
      join public.shared_access sa2
        on sa2.trip_id = sa1.trip_id
      where sa1.user_id = id
        and sa2.user_id = auth.uid()
    )
    or
    -- owner: this user is a member of a trip owned by the querying user
    exists (
      select 1
      from public.shared_access sa
      join public.trips t
        on t.id = sa.trip_id
      where sa.user_id = id
        and t.owner_id = auth.uid()
    )
  )
);

-- ── Step 2: Restrict column-level access on public.profiles ──────────────────
-- Supabase grants SELECT on all public tables to authenticated by default.
-- We revoke that broad grant and re-grant only the non-sensitive columns.
-- This ensures that even with the peer-read RLS policy above, authenticated
-- users cannot read the email column by querying profiles directly.
-- (service_role retains full access via its own Supabase-managed grants.)
revoke select on public.profiles from authenticated, anon;
grant select (id, display_name, avatar_url, created_at, updated_at)
  on public.profiles to authenticated;

-- ── Step 3: Recreate profiles_public with security_invoker = true ────────────
-- The view body and grants are identical to migration 015. Now that peer-read
-- RLS exists and the email column is restricted, security_invoker is safe.
drop view if exists public.profiles_public;

create view public.profiles_public
  with (security_invoker = true)
as
select
  p.id,
  p.display_name,
  p.avatar_url
from public.profiles p
where auth.uid() is not null
  and (
    p.id = auth.uid()
    or exists (
      select 1
      from public.shared_access sa1
      join public.shared_access sa2
        on sa2.trip_id = sa1.trip_id
      where sa1.user_id = p.id
        and sa2.user_id = auth.uid()
    )
    or exists (
      select 1
      from public.shared_access sa
      join public.trips t
        on t.id = sa.trip_id
      where sa.user_id = p.id
        and t.owner_id = auth.uid()
    )
  );

revoke all on public.profiles_public from public;
grant select on public.profiles_public to authenticated;
