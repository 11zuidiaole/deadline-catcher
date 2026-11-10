-- Deadline 清单：在 Supabase 的 SQL Editor 里整段运行一次

create table if not exists public.boards (
  user_id uuid primary key default auth.uid() references auth.users on delete cascade,
  data jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

create table if not exists public.board_history (
  id bigint generated always as identity primary key,
  user_id uuid not null default auth.uid() references auth.users on delete cascade,
  data jsonb not null,
  created_at timestamptz not null default now()
);

alter table public.boards enable row level security;
alter table public.board_history enable row level security;

grant select, insert, update on public.boards to authenticated;
grant select, insert on public.board_history to authenticated;

drop policy if exists "own board select" on public.boards;
drop policy if exists "own board insert" on public.boards;
drop policy if exists "own board update" on public.boards;
drop policy if exists "own history select" on public.board_history;
drop policy if exists "own history insert" on public.board_history;

create policy "own board select" on public.boards for select to authenticated using (auth.uid() = user_id);
create policy "own board insert" on public.boards for insert to authenticated with check (auth.uid() = user_id);
create policy "own board update" on public.boards for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "own history select" on public.board_history for select to authenticated using (auth.uid() = user_id);
create policy "own history insert" on public.board_history for insert to authenticated with check (auth.uid() = user_id);

-- 自动存历史版本：每 10 分钟最多存一份改动前的内容，每人保留最近 200 份
create or replace function public.snapshot_board() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  if not exists (
    select 1 from board_history
    where user_id = old.user_id and created_at > now() - interval '10 minutes'
  ) then
    insert into board_history (user_id, data) values (old.user_id, old.data);
    delete from board_history
    where user_id = old.user_id
      and id not in (select id from board_history where user_id = old.user_id order by id desc limit 200);
  end if;
  return new;
end $$;

drop trigger if exists boards_snapshot on public.boards;
create trigger boards_snapshot before update on public.boards
for each row execute function public.snapshot_board();
