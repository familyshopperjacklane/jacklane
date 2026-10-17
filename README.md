# Family Shopper

A responsive React + Vite product catalogue for Family Shopper, backed by Supabase Auth, Postgres and Storage.

## Current project connection
- Supabase project: `familyshop`
- Project reference: `cmtkqsuxzholfpvtvmbo`
- Region: `eu-north-1`
- Browser URL and publishable key are in `.env.example`. These are intended for public client use; never add a service-role or secret key.

## Features
- Responsive product catalogue, search, category filters, and GBP prices
- Supabase email/password sign-up and login
- Email one-time passcode login
- Google and Apple OAuth sign-in flows (provider credentials still required)
- Admin-only product create, edit, delete and image uploads
- Row Level Security protects products, profiles, admin membership and product image writes
- Six starter non-alcoholic sample products are already in the database

## Run locally
1. Install Node.js 20.19+ or 22.12+.
2. Copy `.env.example` to `.env.local` (the current project URL and publishable key are prefilled).
3. Run `npm install`, then `npm run dev`.

## Supabase setup status
The catalogue tables, RLS policies and `product-images` Storage bucket have been created on the existing Supabase project.

Remaining steps requiring your own account/provider access:
1. In Authentication → URL Configuration, set the production Site URL and add your local and deployed URLs to allowed redirects.
2. In Authentication → Providers, enable Google and Apple and enter OAuth client credentials from those providers.
3. To use numeric email OTPs, set the Supabase Auth email template to include `{{ .Token }}`, and configure production email delivery if needed.
4. Create your own account through the website. Copy its UUID from Authentication → Users, then run this in the SQL Editor:
   `insert into public.admin_users (user_id) values ('YOUR-USER-UUID');`
5. Deploy the Vite app to a host such as Vercel and add the two `VITE_SUPABASE_*` environment variables. Set the production domain in Supabase redirect settings.

## Security
- Never expose Supabase service-role or secret keys in browser code or `VITE_*` variables.
- Admin rights are granted only by the server-side `public.admin_users` table and enforced by RLS.
- The public catalogue can read only in-stock products. Only authorised admins can manage products or upload images.
- This is a product showcase, not an online checkout or alcohol-sales system. Check applicable licensing and age-related requirements before publishing regulated products.
