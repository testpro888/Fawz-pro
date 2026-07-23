-- ============================================================
-- Migration: customer_securities table
-- Menyimpan data sekuritas & rekening per customer
--
-- Kolom:
--   SavingsID       → rdn_account_no  (No Rekening RDN)
--   SavingsBankID   → rdn_bank_id     (Bank RDN — kode/ID bank)
--   BankAccountID   → personal_bank_name (Nama Bank rekening pribadi)
--   BankAccountNo   → personal_account_no (No Rekening pribadi)
--   BankAccountName → personal_account_name (Nama di rekening)
-- ============================================================

-- 1. Buat tabel customer_securities
CREATE TABLE IF NOT EXISTS public.customer_securities (
  id                   uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id          uuid NOT NULL REFERENCES public.customers(id) ON DELETE CASCADE,
  sekuritas_name       text NOT NULL DEFAULT 'Maybank Sekuritas',

  -- RDN (Rekening Dana Nasabah)
  rdn_bank_name        text,           -- nama bank RDN (e.g. "BCA", "BNI")
  rdn_bank_id          text,           -- SavingsBankID: kode/ID bank RDN
  rdn_account_no       text,           -- SavingsID: No Rekening RDN

  -- Rekening pribadi (penarikan)
  personal_bank_name   text,           -- BankAccountID: Nama Bank
  personal_account_no  text,           -- BankAccountNo: No Rekening
  personal_account_name text,          -- BankAccountName: Nama di Rekening

  -- Urutan tampil
  sort_order           integer DEFAULT 0,

  created_at           timestamptz DEFAULT now(),
  updated_at           timestamptz DEFAULT now()
);

-- 2. Index untuk lookup cepat per customer
CREATE INDEX IF NOT EXISTS idx_customer_securities_customer_id
  ON public.customer_securities(customer_id);

-- 3. Trigger updated_at
CREATE OR REPLACE FUNCTION update_customer_securities_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_customer_securities_updated_at ON public.customer_securities;
CREATE TRIGGER trg_customer_securities_updated_at
  BEFORE UPDATE ON public.customer_securities
  FOR EACH ROW EXECUTE FUNCTION update_customer_securities_updated_at();

-- 4. RLS
ALTER TABLE public.customer_securities ENABLE ROW LEVEL SECURITY;

-- Authenticated users bisa select, insert, update, delete
CREATE POLICY "authenticated_select_customer_securities"
  ON public.customer_securities FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "authenticated_insert_customer_securities"
  ON public.customer_securities FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "authenticated_update_customer_securities"
  ON public.customer_securities FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "authenticated_delete_customer_securities"
  ON public.customer_securities FOR DELETE
  TO authenticated
  USING (true);

-- Anon bisa select (untuk halaman publik jika diperlukan)
CREATE POLICY "anon_select_customer_securities"
  ON public.customer_securities FOR SELECT
  TO anon
  USING (true);

-- 5. Migrasi data lama dari tabel customers ke customer_securities
--    (untuk customer yang belum punya entry di customer_securities)
INSERT INTO public.customer_securities (
  customer_id,
  sekuritas_name,
  rdn_bank_name,
  rdn_account_no,
  personal_bank_name,
  personal_account_no,
  personal_account_name,
  sort_order
)
SELECT
  c.id,
  'Maybank Sekuritas',
  -- rdn_bank_name: ambil dari savings_bank_name jika ada, fallback ke bank_account_id
  COALESCE(NULLIF(c.savings_bank_name, ''), NULLIF(c.bank_account_id, '')),
  -- rdn_account_no: SavingsID
  NULLIF(c.savings_id, ''),
  -- personal_bank_name: BankAccountID
  NULLIF(c.bank_account_id, ''),
  -- personal_account_no: BankAccountNo
  NULLIF(c.bank_account_no, ''),
  -- personal_account_name: BankAccountName
  NULLIF(c.bank_account_name, ''),
  0
FROM public.customers c
WHERE
  -- hanya migrate jika ada data rekening
  (c.savings_id IS NOT NULL OR c.bank_account_no IS NOT NULL)
  -- dan belum ada entry securities untuk customer ini
  AND NOT EXISTS (
    SELECT 1 FROM public.customer_securities s WHERE s.customer_id = c.id
  );
