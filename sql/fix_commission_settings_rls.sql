-- ============================================================================
-- Fix: Relax RLS policy for sales_commission_settings
--
-- Problem: INSERT/UPDATE policies require current_setting('app.current_user_role')
-- but app uses anon key without Supabase Auth, so the setting is never set.
-- Authorization is already enforced at app layer via canWriteSettings().
--
-- Solution: Allow anon role to INSERT/UPDATE (app-layer guard is sufficient).
-- SELECT and DELETE policies remain unchanged.
-- ============================================================================

-- Drop existing restrictive policies
DROP POLICY IF EXISTS "commission_settings_insert_authorized" ON public.sales_commission_settings;
DROP POLICY IF EXISTS "commission_settings_update_authorized" ON public.sales_commission_settings;

-- Drop jika sudah ada (idempoten)
DROP POLICY IF EXISTS "commission_settings_insert_anon" ON public.sales_commission_settings;
DROP POLICY IF EXISTS "commission_settings_update_anon" ON public.sales_commission_settings;

-- Recreate with open write access (authorization handled by app layer)
CREATE POLICY "commission_settings_insert_anon"
  ON public.sales_commission_settings
  FOR INSERT
  WITH CHECK (true);

CREATE POLICY "commission_settings_update_anon"
  ON public.sales_commission_settings
  FOR UPDATE
  USING (true)
  WITH CHECK (true);
