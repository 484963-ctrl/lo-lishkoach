-- „לא לשכוח”: המשימות של כל משפחה, לפי קוד משפחתי. טבלה נפרדת, בלי קשר לאפליקציות אחרות.
-- אין גישה ישירה לטבלה: רק דרך שתי הפונקציות, ורק למי שיודע את הקוד (12 תווים אקראיים).
-- כבר הופעל על פרויקט ה-Supabase. בטוח להרצה חוזרת (SQL Editor).
create table if not exists public.lo_lishkoach_families (
  code text primary key check (char_length(code) = 12),
  data jsonb not null,
  updated_at timestamptz not null default now()
);
alter table public.lo_lishkoach_families enable row level security;
revoke all on public.lo_lishkoach_families from anon, authenticated;

create or replace function public.lo_lishkoach_get(p_code text)
returns jsonb language sql security definer set search_path = public as $$
  select data from public.lo_lishkoach_families where code = p_code;
$$;

create or replace function public.lo_lishkoach_put(p_code text, p_data jsonb)
returns void language plpgsql security definer set search_path = public as $$
begin
  if p_code !~ '^[A-Z0-9]{12}$' then raise exception 'bad code'; end if;
  if pg_column_size(p_data) > 2000000 then raise exception 'too large'; end if;
  insert into public.lo_lishkoach_families (code, data, updated_at) values (p_code, p_data, now())
  on conflict (code) do update set data = excluded.data, updated_at = now();
end;
$$;

revoke all on function public.lo_lishkoach_get(text) from public;
revoke all on function public.lo_lishkoach_put(text, jsonb) from public;
grant execute on function public.lo_lishkoach_get(text) to anon, authenticated;
grant execute on function public.lo_lishkoach_put(text, jsonb) to anon, authenticated;

-- קבצים מצורפים (Supabase Storage). כל קובץ בתיקייה של הקוד המשפחתי, עם מזהה אקראי ארוך בנתיב.
-- העלאה: רק לתיקייה של קוד משפחתי שקיים. הורדה: רק למי שיש את הקישור המלא (אין רשימת קבצים). כבר הופעל.
create or replace function public.lo_lishkoach_code_exists(p_code text)
returns boolean language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.lo_lishkoach_families where code = p_code);
$$;
revoke all on function public.lo_lishkoach_code_exists(text) from public;
grant execute on function public.lo_lishkoach_code_exists(text) to anon, authenticated;

insert into storage.buckets (id, name, public, file_size_limit)
values ('lo-lishkoach-files', 'lo-lishkoach-files', true, 26214400)
on conflict (id) do update set public = true, file_size_limit = 26214400;

drop policy if exists "lo_lishkoach_upload" on storage.objects;
create policy "lo_lishkoach_upload" on storage.objects for insert to anon, authenticated
with check (
  bucket_id = 'lo-lishkoach-files'
  and public.lo_lishkoach_code_exists((storage.foldername(name))[1])
  and char_length((storage.foldername(name))[2]) >= 20
);
