-- Family Shopper catalogue and admin access.
-- Run this in Supabase SQL Editor after connecting your project.
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

-- Public visitors can only read products currently marked in stock.
create policy "Anyone can view in-stock products"
  on public.products for select to anon, authenticated
  using (in_stock = true);

-- Only users explicitly added to admin_users can manage the catalogue.
create policy "Admins can view all products"
  on public.products for select to authenticated
  using (exists (select 1 from public.admin_users a where a.user_id = (select auth.uid())));
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

-- Storage bucket for product photos. Public read, authenticated admin writes only.
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

-- IMPORTANT: after signing up, add your own auth user UUID as the first admin
-- using the SQL Editor: insert into public.admin_users(user_id) values ('YOUR-AUTH-USER-UUID');
-- Never grant admin rights based on user-editable metadata or email alone.