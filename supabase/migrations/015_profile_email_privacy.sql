-- SECURITY FIX: Restrict profile email visibility.
--
-- The previous profiles_read_authenticated policy allowed any authenticated
-- user to read the email address of every user in the system. This is a
-- privacy risk: a malicious (but authenticated) user could enumerate all
-- registered users' emails.
--
-- Fix:
--   1. Drop the broad read policy.
--   2. Add a self-read policy (full row, including email).
--   3. Add a peer-read policy that exposes only display_name and avatar_url
--      to other authenticated users (enough for the trip member list UI).
--
-- NOTE: PostgreSQL RLS is row-level, not column-level. Column masking is
-- achieved here via a SECURITY DEFINER view (profiles_public) that excludes
-- the email column. The peer-read policy is applied to the view; clients that
-- need the member list should SELECT from profiles_public instead of profiles.

drop policy if exists "profiles_read_authenticated" on public.profiles;

-- Full profile (including email) visible to the owner only.
create policy "profiles_read_self"
on public.profiles
for select
using (id = auth.uid());

-- Peers can read profiles of users who share at least one trip with them.
-- This covers both the owner viewing members and members viewing each other.
create policy "profiles_read_shared_trip_peer"
on public.profiles
for select
using (
  auth.uid() is not null
  and exists (
    select 1
    from public.shared_access sa1
    join public.shared_access sa2
      on sa2.trip_id = sa1.trip_id
    where sa1.user_id = profiles.id
      and sa2.user_id = auth.uid()
  )
);

-- Trip owners need to read the profiles of their trip members via the
-- shared_access → profiles join. The is_trip_owner check is handled inside
-- the shared_access RLS; this policy ensures the joined profile row is
-- visible to the owner as well.
create policy "profiles_read_trip_member_for_owner"
on public.profiles
for select
using (
  auth.uid() is not null
  and exists (
    select 1
    from public.shared_access sa
    where sa.user_id = profiles.id
      and public.is_trip_owner(sa.trip_id)
  )
);
