-- ============================================================
-- Migration: customer_portfolio & portfolio_transactions tables
-- Menyimpan data portofolio saham dan transaksi per customer
-- ============================================================

-- 1. Tabel portofolio (holdings)
CREATE TABLE IF NOT EXISTS public.customer_portfolio (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id     uuid NOT NULL REFERENCES public.customers(id) ON DELETE CASCADE,
  client_id       text,
  stock           text NOT NULL,
  qty_lot         numeric NOT NULL DEFAULT 0,
  buy_price       numeric NOT NULL DEFAULT 0,
  nominal         numeric NOT NULL DEFAULT 0,
  cash_balance    numeric NOT NULL DEFAULT 0,
  buy_fee         numeric NOT NULL DEFAULT 0,
  sell_fee        numeric NOT NULL DEFAULT 0,
  created_at      timestamptz DEFAULT now(),
  updated_at      timestamptz DEFAULT now()
);

-- Index
CREATE INDEX IF NOT EXISTS idx_customer_portfolio_customer_id
  ON public.customer_portfolio(customer_id);
CREATE INDEX IF NOT EXISTS idx_customer_portfolio_client_id
  ON public.customer_portfolio(client_id);

-- Trigger updated_at
CREATE OR REPLACE FUNCTION update_customer_portfolio_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_customer_portfolio_updated_at ON public.customer_portfolio;
CREATE TRIGGER trg_customer_portfolio_updated_at
  BEFORE UPDATE ON public.customer_portfolio
  FOR EACH ROW EXECUTE FUNCTION update_customer_portfolio_updated_at();

-- 2. Tabel transaksi portofolio
CREATE TABLE IF NOT EXISTS public.portfolio_transactions (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id     uuid NOT NULL REFERENCES public.customers(id) ON DELETE CASCADE,
  client_id       text,
  stock           text NOT NULL,
  transaction_type text NOT NULL CHECK (transaction_type IN ('Buy', 'Sell', 'Bond Buy', 'Bond Sell', 'Income', 'Outcome')),
  qty_lot         numeric NOT NULL DEFAULT 0,
  price           numeric NOT NULL DEFAULT 0,
  nominal         numeric NOT NULL DEFAULT 0,
  buy_fee         numeric NOT NULL DEFAULT 0,
  sell_fee        numeric NOT NULL DEFAULT 0,
  created_at      timestamptz DEFAULT now()
);

-- Index
CREATE INDEX IF NOT EXISTS idx_portfolio_transactions_customer_id
  ON public.portfolio_transactions(customer_id);
CREATE INDEX IF NOT EXISTS idx_portfolio_transactions_client_id
  ON public.portfolio_transactions(client_id);
CREATE INDEX IF NOT EXISTS idx_portfolio_transactions_type
  ON public.portfolio_transactions(transaction_type);

-- 3. RLS
ALTER TABLE public.customer_portfolio ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.portfolio_transactions ENABLE ROW LEVEL SECURITY;

-- Policies customer_portfolio
CREATE POLICY "allow_all_customer_portfolio"
  ON public.customer_portfolio FOR ALL
  USING (true) WITH CHECK (true);

-- Policies portfolio_transactions
CREATE POLICY "allow_all_portfolio_transactions"
  ON public.portfolio_transactions FOR ALL
  USING (true) WITH CHECK (true);

-- ============================================================
-- MIGRATION: Jika tabel sudah ada dengan constraint lama,
-- jalankan ini untuk update constraint transaction_type:
-- ============================================================
-- ALTER TABLE public.portfolio_transactions
--   DROP CONSTRAINT IF EXISTS portfolio_transactions_transaction_type_check;
-- ALTER TABLE public.portfolio_transactions
--   ADD CONSTRAINT portfolio_transactions_transaction_type_check
--   CHECK (transaction_type IN ('Buy', 'Sell', 'Bond Buy', 'Bond Sell', 'Income', 'Outcome'));
