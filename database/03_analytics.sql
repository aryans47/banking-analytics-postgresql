-- ============================================================
-- BANKING ANALYTICS & RISK INTELLIGENCE
-- Advanced SQL Analytics
-- ============================================================

-- 1. Overall Banking KPIs
SELECT
    (SELECT COUNT(*) FROM customers) AS total_customers,
    (SELECT COUNT(*) FROM accounts) AS total_accounts,
    (SELECT COUNT(*) FROM transactions) AS total_transactions,
    (SELECT COUNT(*) FROM loans) AS total_loans,
    (SELECT COALESCE(SUM(balance), 0) FROM accounts) AS total_deposit_balance,
    (SELECT COALESCE(SUM(amount), 0) FROM transactions) AS total_transaction_volume,
    (SELECT COALESCE(SUM(principal), 0) FROM loans) AS total_loan_exposure;


-- 2. Transaction Analysis
SELECT
    COUNT(*) AS total_transactions,
    SUM(amount) AS total_transaction_amount,
    SUM(CASE WHEN txn_type = 'CREDIT' THEN amount ELSE 0 END) AS total_credits,
    SUM(CASE WHEN txn_type = 'DEBIT' THEN amount ELSE 0 END) AS total_debits,
    SUM(
        CASE
            WHEN txn_type = 'CREDIT' THEN amount
            WHEN txn_type = 'DEBIT' THEN -amount
            ELSE 0
        END
    ) AS net_transaction_value
FROM transactions;


-- 3. Customer Transaction Analytics
SELECT
    c.customer_id,
    c.full_name,
    COUNT(t.txn_id) AS transaction_count,
    COALESCE(SUM(t.amount), 0) AS total_transaction_value,
    COALESCE(AVG(t.amount), 0) AS average_transaction_amount
FROM customers c
LEFT JOIN accounts a
    ON c.customer_id = a.customer_id
LEFT JOIN transactions t
    ON a.account_id = t.account_id
GROUP BY c.customer_id, c.full_name
ORDER BY total_transaction_value DESC;


-- 4. Monthly Transaction Trend
SELECT
    DATE_TRUNC('month', txn_timestamp)::DATE AS month,
    COUNT(*) AS transaction_count,
    SUM(amount) AS monthly_transaction_volume
FROM transactions
GROUP BY DATE_TRUNC('month', txn_timestamp)
ORDER BY month;


-- 5. Month-over-Month Transaction Growth
WITH monthly_transactions AS (
    SELECT
        DATE_TRUNC('month', txn_timestamp)::DATE AS month,
        SUM(amount) AS monthly_volume
    FROM transactions
    GROUP BY DATE_TRUNC('month', txn_timestamp)
)
SELECT
    month,
    monthly_volume,
    LAG(monthly_volume) OVER (ORDER BY month) AS previous_month_volume,
    ROUND(
        (
            (monthly_volume - LAG(monthly_volume) OVER (ORDER BY month))
            / NULLIF(LAG(monthly_volume) OVER (ORDER BY month), 0)
        ) * 100,
        2
    ) AS mom_growth_percentage
FROM monthly_transactions
ORDER BY month;


-- 6. Customer Ranking by Transaction Value
SELECT
    c.customer_id,
    c.full_name,
    SUM(t.amount) AS total_transaction_value,
    RANK() OVER (ORDER BY SUM(t.amount) DESC) AS customer_rank
FROM customers c
JOIN accounts a
    ON c.customer_id = a.customer_id
JOIN transactions t
    ON a.account_id = t.account_id
GROUP BY c.customer_id, c.full_name
ORDER BY customer_rank;


-- 7. Loan Exposure by Customer
SELECT
    c.customer_id,
    c.full_name,
    COUNT(l.loan_id) AS total_loans,
    COALESCE(SUM(l.principal), 0) AS total_loan_exposure,
    COALESCE(AVG(l.interest_rate), 0) AS average_interest_rate
FROM customers c
LEFT JOIN loans l
    ON c.customer_id = l.customer_id
GROUP BY c.customer_id, c.full_name
ORDER BY total_loan_exposure DESC;


-- 8. Loan Payment Performance
SELECT
    l.loan_id,
    l.customer_id,
    l.principal,
    COUNT(lp.payment_id) AS payment_count,
    COALESCE(SUM(lp.amount_paid), 0) AS total_amount_paid,
    COUNT(*) FILTER (WHERE lp.status = 'PAID') AS successful_payments
FROM loans l
LEFT JOIN loan_payments lp
    ON l.loan_id = lp.loan_id
GROUP BY l.loan_id, l.customer_id, l.principal
ORDER BY l.loan_id;


-- 9. Customer Segmentation
WITH customer_activity AS (
    SELECT
        c.customer_id,
        c.full_name,
        COALESCE(SUM(t.amount), 0) AS transaction_value
    FROM customers c
    LEFT JOIN accounts a
        ON c.customer_id = a.customer_id
    LEFT JOIN transactions t
        ON a.account_id = t.account_id
    GROUP BY c.customer_id, c.full_name
)
SELECT
    customer_id,
    full_name,
    transaction_value,
    CASE
        WHEN transaction_value > 1000000 THEN 'PREMIUM'
        WHEN transaction_value BETWEEN 300000 AND 1000000 THEN 'GOLD'
        ELSE 'REGULAR'
    END AS customer_segment
FROM customer_activity
ORDER BY transaction_value DESC;


-- 10. Running Transaction Value by Account
SELECT
    account_id,
    txn_timestamp,
    txn_type,
    amount,
    SUM(
        CASE
            WHEN txn_type = 'CREDIT' THEN amount
            WHEN txn_type = 'DEBIT' THEN -amount
            ELSE 0
        END
    ) OVER (
        PARTITION BY account_id
        ORDER BY txn_timestamp, txn_id
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_transaction_value
FROM transactions
ORDER BY account_id, txn_timestamp, txn_id;
