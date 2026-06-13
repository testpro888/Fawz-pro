-- ============================================================================
-- Migration: Create sales_commission_settings table
-- Feature:   Sales Target & Commission Settings
-- Date:      Run once in Supabase SQL Editor
--
-- Requirements: 7.2, 7.5, 8.1, 8.2, 8.3, 8.4, 8.5, 8.6
-- ============================================================================

-- ── NEW TABLE ────────────────────────────────────────────────────────────────
-- Stores per-sales per-period commission configuration.
-- A Settings_Record for period 'YYYY-MM' is the Effective_Settings for that month.
-- Writes are isolated per period — updating one period does NOT affect others.

CREATE TABLE public.sales_commission_settings (
  id          UUID          NOT NULL DEFAULT gen_random_uuid(),
  sales_id    UUID          NOT NULL REFERENCES public.sales(id) ON DELETE CASCADE,
  sales_name  VARCHAR(255)  NOT NULL,           -- denormalized for display
  period      VARCHAR(7)    NOT NULL,            -- format: 'YYYY-MM'
  target_fee  NUMERIC(15,2) NOT NULL,            -- Rupiah, e.g. 10000000
  rate_above  NUMERIC(5,4)  NOT NULL,            -- decimal: 0.0100–1.0000
  rate_below  NUMERIC(5,4)  NOT NULL,            -- decimal: 0.0100–1.0000
  created_by  VARCHAR(255)  NOT NULL,            -- username from fawz_user session
  created_at  TIMESTAMPTZ   NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ   NULL,

  -- Primary key
  CONSTRAINT pk_sales_commission_settings
    PRIMARY KEY (id),

  -- One active setting per sales per period
  CONSTRAINT uq_sales_commission_period
    UNIQUE (sales_id, period),

  -- Data integrity: target must be positive
  CONSTRAINT chk_target_fee_positive
    CHECK (target_fee > 0),

  -- Data integrity: rate_above must be 1%–100% expressed as decimal
  CONSTRAINT chk_rate_above_range
    CHECK (rate_above >= 0.01 AND rate_above <= 1),

  -- Data integrity: rate_below must be 1%–100% expressed as decimal
  CONSTRAINT chk_rate_below_range
    CHECK (rate_below >= 0.01 AND rate_below <= 1)
);

-- ── PERFORMANCE INDEX ────────────────────────────────────────────────────────
-- Optimises the batch query pattern: SELECT ... WHERE period = $1
-- which is the primary access pattern from both sales.html and sales-commission.html.

CREATE INDEX idx_commission_settings_period_sales
  ON public.sales_commission_settings (period, sales_id);


-- ── ROW LEVEL SECURITY ───────────────────────────────────────────────────────
ALTER TABLE public.sales_commission_settings ENABLE ROW LEVEL SECURITY;

-- SELECT: all authenticated roles that access commission pages
-- (head_account, admin, sales, head_sales can all read)
-- Note: Since Fawz Pro uses anon key + custom session storage (not Supabase Auth),
-- per-user filtering is enforced at the application layer. RLS here acts as a
-- coarse guard; the app's canWriteSettings() is the primary write gate.
CREATE POLICY "commission_settings_select_all"
  ON public.sales_commission_settings
  FOR SELECT
  USING (true);


-- INSERT: only head_sales and head_account
--
-- IMPLEMENTATION NOTE: Fawz Pro uses anon key without Supabase Auth, so
-- auth.uid() is not available. Two recommended approaches:
--
-- Option A (recommended): Route all writes through server.js using the
--   service-role key after server-side validation of the fawz_user session.
--   This matches patterns already used for other sensitive operations.
--
-- Option B (DB-level, shown below): Requires the app to SET LOCAL
--   app.current_user_role before each write, e.g.:
--     await supabase.rpc('set_config', { parameter: 'app.current_user_role',
--       value: user.role, is_local: true })
--   This adds a round-trip but enforces policy at DB level.
--
-- The policy below implements Option B. If using Option A (server proxy),
-- you may simplify or remove the INSERT/UPDATE policies and rely on the
-- service-role key + server-side validation.

CREATE POLICY "commission_settings_insert_authorized"
  ON public.sales_commission_settings
  FOR INSERT
  WITH CHECK (
    current_setting('app.current_user_role', true) IN ('head_sales', 'head_account')
  );

-- UPDATE: only head_sales and head_account
-- UPSERT operations targeting an existing row will invoke this policy.
CREATE POLICY "commission_settings_update_authorized"
  ON public.sales_commission_settings
  FOR UPDATE
  USING (
    current_setting('app.current_user_role', true) IN ('head_sales', 'head_account')
  )
  WITH CHECK (
    current_setting('app.current_user_role', true) IN ('head_sales', 'head_account')
  );

-- DELETE: prohibited for all roles (history must be preserved — Req 6.4)
CREATE POLICY "commission_settings_no_delete"
  ON public.sales_commission_settings
  FOR DELETE
  USING (false);


-- ── VERIFICATION QUERIES ─────────────────────────────────────────────────────
-- Run these after migration to confirm schema is correct:

-- SELECT column_name, data_type, is_nullable, column_default
-- FROM information_schema.columns
-- WHERE table_name = 'sales_commission_settings'
-- ORDER BY ordinal_position;

-- SELECT constraint_name, constraint_type
-- FROM information_schema.table_constraints
-- WHERE table_name = 'sales_commission_settings';

-- SELECT indexname, indexdef
-- FROM pg_indexes
-- WHERE tablename = 'sales_commission_settings';
