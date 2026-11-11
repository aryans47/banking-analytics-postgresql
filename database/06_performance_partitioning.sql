-- ============================================================
-- BANKING ANALYTICS & RISK INTELLIGENCE
-- Performance Optimization & Data Quality
-- PostgreSQL 18
-- ============================================================


-- ============================================================
-- 1. INDEXES
-- ============================================================

CREATE INDEX IF NOT EXISTS idx_accounts_customer_id
ON accounts(customer_id);

CREATE INDEX IF NOT EXISTS idx_transactions_account_id
ON transactions(account_id);

CREATE INDEX IF NOT EXISTS idx_transactions_timestamp
ON transactions(txn_timestamp);

CREATE INDEX IF NOT EXISTS idx_transactions_account_timestamp
ON transactions(account_id, txn_timestamp);

CREATE INDEX IF NOT EXISTS idx_loans_customer_id
ON loans(customer_id);

CREATE INDEX IF NOT EXISTS idx_loan_payments_loan_id
ON loan_payments(loan_id);

CREATE INDEX IF NOT EXISTS idx_loan_payments_loan_date
ON loan_payments(loan_id, payment_date);


-- ============================================================
-- 2. CHECK INDEXES
-- ============================================================

SELECT
    schemaname,
    tablename,
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;


-- ============================================================
-- 3. EXPLAIN ANALYZE
-- ============================================================

EXPLAIN ANALYZE
SELECT
    account_id,
    txn_timestamp,
    txn_type,
    amount
FROM transactions
WHERE account_id = 10
ORDER BY txn_timestamp;


-- ============================================================
-- 4. RANGE PARTITIONING
-- ============================================================

-- Partitioned transaction table already created separately.
-- Monthly partitions:
--
-- transactions_2026_01
-- transactions_2026_02
-- transactions_2026_03
-- transactions_2026_04
-- transactions_2026_05


-- ============================================================
-- 5. VERIFY PARTITIONS
-- ============================================================

SELECT
    c.relname AS partition_name
FROM pg_inherits i
JOIN pg_class c
    ON i.inhrelid = c.oid
JOIN pg_class p
    ON i.inhparent = p.oid
WHERE p.relname = 'transactions_partitioned'
ORDER BY c.relname;


-- ============================================================
-- 6. PARTITION PRUNING TEST
-- ============================================================

EXPLAIN ANALYZE
SELECT *
FROM transactions_partitioned
WHERE txn_timestamp >= '2026-05-01'
  AND txn_timestamp < '2026-06-01';


-- ============================================================
-- 7. PARTITION DATA VALIDATION
-- ============================================================

SELECT
    COUNT(*) AS total_partitioned_transactions,
    COALESCE(SUM(amount), 0) AS total_partitioned_amount
FROM transactions_partitioned;


-- ============================================================
-- 8. DATA QUALITY CHECKS
-- ============================================================

SELECT
    (SELECT COUNT(*)
     FROM customers
     WHERE full_name IS NULL)
        AS customers_missing_name,

    (SELECT COUNT(*)
     FROM accounts
     WHERE customer_id IS NULL)
        AS accounts_missing_customer,

    (SELECT COUNT(*)
     FROM transactions
     WHERE account_id IS NULL
        OR amount IS NULL
        OR txn_timestamp IS NULL)
        AS transactions_missing_required_data,

    (SELECT COUNT(*)
     FROM loans
     WHERE customer_id IS NULL
        OR principal IS NULL)
        AS loans_missing_required_data,

    (SELECT COUNT(*)
     FROM loan_payments
     WHERE loan_id IS NULL
        OR amount_paid IS NULL)
        AS payments_missing_required_data;


-- ============================================================
-- 9. REFERENTIAL INTEGRITY CHECKS
-- ============================================================

SELECT
    (SELECT COUNT(*)
     FROM customers c
     LEFT JOIN accounts a
       ON c.customer_id = a.customer_id
     WHERE a.account_id IS NULL)
        AS customers_without_accounts,

    (SELECT COUNT(*)
     FROM accounts a
     LEFT JOIN customers c
       ON a.customer_id = c.customer_id
     WHERE c.customer_id IS NULL)
        AS accounts_without_customers,

    (SELECT COUNT(*)
     FROM transactions t
     LEFT JOIN accounts a
       ON t.account_id = a.account_id
     WHERE a.account_id IS NULL)
        AS transactions_without_accounts,

    (SELECT COUNT(*)
     FROM loans l
     LEFT JOIN customers c
       ON l.customer_id = c.customer_id
     WHERE c.customer_id IS NULL)
        AS loans_without_customers,

    (SELECT COUNT(*)
     FROM loan_payments lp
     LEFT JOIN loans l
       ON lp.loan_id = l.loan_id
     WHERE l.loan_id IS NULL)
        AS payments_without_loans;


-- ============================================================
-- END
-- ============================================================