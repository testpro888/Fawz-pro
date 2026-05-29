-- Migration: Add referral_agents column to customers table
-- Allows tagging customers to multiple referral agents (comma-separated names)

ALTER TABLE customers
ADD COLUMN IF NOT EXISTS referral_agents TEXT DEFAULT NULL;

COMMENT ON COLUMN customers.referral_agents IS 'Comma-separated names of referral agents who can access this customer';
