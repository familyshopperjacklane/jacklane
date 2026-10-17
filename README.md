# Family Shopper

A responsive React + Vite catalogue for a neighbourhood off-licence, backed by Supabase Auth, Postgres and Storage.

## Features
- Responsive product catalogue, category filters and search
- Supabase email/password sign-up and login
- Email one-time passcode (OTP) login
- Google and Apple OAuth buttons
- Admin-only product creation, editing, deletion and product photo uploads
- Row Level Security (RLS) protects product changes and admin access
- GBP pricing (stored as integer pence)

## Run locally
1. Install Node.js 20.19+ or 22.12+.
2. Copy `.env.example` to `.env.local` and add your Supabase project URL and publishable key.
3. Run `npm install`, then `npm run dev`.

## Supabase setup
1. Run `supabase/schema.sql` in the Supabase SQL Editor.
2. In Authentication → URL Configuration, set your site URL and add your local and deployed URLs to allowed redirects.
3. In Authentication → Providers, enable Google and Apple and enter the credentials from those providers.
4. To receive numeric email OTPs, edit the Supabase Auth email template to include `{{ .Token }}`. Configure production email delivery.
5. Create a user via the app, then use Authentication → Users to copy your user UUID. In SQL Editor run:
   `insert into public.admin_users (user_id) values ('YOUR-USER-UUID');`
6. Deploy the repository with a Vite-capable host such as Vercel and add the same environment variables.

## Security notes
- Only the Supabase publishable key belongs in browser environment variables. Never expose service-role/secret keys.
- Admin access is granted by the server-side `public.admin_users` table and enforced by RLS, not by a hidden button.
- Apple and Google sign-in need provider credentials and redirect configuration before they will work.
- This is a catalogue, not a checkout or online alcohol-sales system. Verify applicable age, licensing and local requirements before adding regulated products.

## Existing repository
This project is prepared for the GitHub repository `familyshopperjacklane/jacklane`.