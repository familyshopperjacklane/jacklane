-- Family Shopper catalogue and admin access.
-- This schema has been applied to Supabase project cmtkqsuxzholfpvtvmbo.
create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  created_at timestamptz not null default now()
);
alter table public.profiles enable row level security;

create table if not exists public.products (
  id uuid primary key default gen_random_uuid(),
  name text not null check (char_length(name) between 1 and 120),
  description text not null default '',
  category text not null default 'Essentials',
  price_pence integer not null check (price_pence >= 0),
  image_url text,
  barcode text unique,
  supplier text,
  wholesale_cost_pence integer check (wholesale_cost_pence is null or wholesale_cost_pence >= 0),
  in_stock boolean not null default true,
  featured boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
alter table public.products enable row level security;

create table if not exists public.admin_users (
  user_id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);
alter table public.admin_users enable row level security;

-- Public visitors can only read products marked in stock.
create policy "Public can view in-stock products"
  on public.products for select to anon using (in_stock = true);
create policy "Customers can view in-stock products and admins all products"
  on public.products for select to authenticated
  using (
    in_stock = true
    or exists (select 1 from public.admin_users a where a.user_id = (select auth.uid()))
  );

-- Only users explicitly added to admin_users can manage catalogue rows.
create policy "Admins can add products"
  on public.products for insert to authenticated
  with check (exists (select 1 from public.admin_users a where a.user_id = (select auth.uid())));
create policy "Admins can update products"
  on public.products for update to authenticated
  using (exists (select 1 from public.admin_users a where a.user_id = (select auth.uid())))
  with check (exists (select 1 from public.admin_users a where a.user_id = (select auth.uid())));
create policy "Admins can delete products"
  on public.products for delete to authenticated
  using (exists (select 1 from public.admin_users a where a.user_id = (select auth.uid())));

create policy "Users can read own profile"
  on public.profiles for select to authenticated using ((select auth.uid()) = id);
create policy "Users can create own profile"
  on public.profiles for insert to authenticated with check ((select auth.uid()) = id);
create policy "Users can update own profile"
  on public.profiles for update to authenticated
  using ((select auth.uid()) = id) with check ((select auth.uid()) = id);

create policy "Admins can read admin list"
  on public.admin_users for select to authenticated
  using ((select auth.uid()) = user_id);

insert into storage.buckets (id, name, public)
values ('product-images', 'product-images', true)
on conflict (id) do nothing;

create policy "Public can view product images"
  on storage.objects for select to anon, authenticated
  using (bucket_id = 'product-images');
create policy "Admins can upload product images"
  on storage.objects for insert to authenticated
  with check (bucket_id = 'product-images' and exists (
    select 1 from public.admin_users a where a.user_id = (select auth.uid())
  ));
create policy "Admins can update product images"
  on storage.objects for update to authenticated
  using (bucket_id = 'product-images' and exists (
    select 1 from public.admin_users a where a.user_id = (select auth.uid())
  ))
  with check (bucket_id = 'product-images' and exists (
    select 1 from public.admin_users a where a.user_id = (select auth.uid())
  ));
create policy "Admins can delete product images"
  on storage.objects for delete to authenticated
  using (bucket_id = 'product-images' and exists (
    select 1 from public.admin_users a where a.user_id = (select auth.uid())
  ));

-- Grant admin rights only to the intended account using its auth.users UUID.
-- Example after creating your account:
-- insert into public.admin_users(user_id) values ('YOUR-USER-UUID');
