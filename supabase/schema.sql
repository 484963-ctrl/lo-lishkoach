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
