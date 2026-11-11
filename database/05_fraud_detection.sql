-- ============================================================
-- BANKING ANALYTICS & RISK INTELLIGENCE
-- Fraud Detection & Risk Scoring
-- Rule-based analytical risk detection
-- ============================================================


-- 1. Rapid Transaction Detection
-- Identifies transactions occurring within 10 minutes
-- of another transaction on the same account.

WITH transaction_velocity AS (
    SELECT
        t.txn_id,
        t.account_id,
        t.txn_timestamp,
        t.amount,
        t.merchant,
        t.location,
        LAG(t.txn_timestamp) OVER (
            PARTITION BY t.account_id
            ORDER BY t.txn_timestamp
        ) AS previous_txn_timestamp
    FROM transactions t
)
SELECT
    txn_id,
    account_id,
    txn_timestamp,
    amount,
    merchant,
    location,
    previous_txn_timestamp,
    EXTRACT(
        EPOCH FROM (txn_timestamp - previous_txn_timestamp)
    ) / 60 AS minutes_since_previous_transaction
FROM transaction_velocity
WHERE previous_txn_timestamp IS NOT NULL
  AND txn_timestamp - previous_txn_timestamp <= INTERVAL '10 minutes'
ORDER BY account_id, txn_timestamp;


-- 2. High-Value Transaction Detection
SELECT
    txn_id,
    account_id,
    amount,
    txn_timestamp,
    merchant,
    location,
    CASE
        WHEN amount >= 50000 THEN 'HIGH AMOUNT'
        WHEN amount >= 20000 THEN 'MEDIUM AMOUNT'
        ELSE 'NORMAL'
    END AS amount_risk
FROM transactions
ORDER BY amount DESC;


-- 3. Rule-Based Fraud Risk Score
-- Amount signal + rapid transaction signal.
-- This is a risk score, NOT a statistical probability.

WITH transaction_features AS (
    SELECT
        t.txn_id,
        t.account_id,
        t.amount,
        t.txn_timestamp,
        t.merchant,
        t.location,

        LAG(t.txn_timestamp) OVER (
            PARTITION BY t.account_id
            ORDER BY t.txn_timestamp
        ) AS previous_txn_timestamp

    FROM transactions t
),
risk_features AS (
    SELECT
        *,
        CASE
            WHEN amount >= 50000 THEN 40
            WHEN amount >= 20000 THEN 25
            WHEN amount >= 10000 THEN 10
            ELSE 0
        END AS amount_score,

        CASE
            WHEN previous_txn_timestamp IS NOT NULL
             AND txn_timestamp - previous_txn_timestamp
                 <= INTERVAL '10 minutes'
            THEN 40
            ELSE 0
        END AS rapid_transaction_score

    FROM transaction_features
)
SELECT
    txn_id,
    account_id,
    amount,
    txn_timestamp,
    merchant,
    location,
    amount_score,
    rapid_transaction_score,
    amount_score + rapid_transaction_score AS fraud_risk_score,

    CASE
        WHEN amount_score + rapid_transaction_score >= 70
            THEN 'HIGH RISK'
        WHEN amount_score + rapid_transaction_score >= 40
            THEN 'MEDIUM RISK'
        ELSE 'LOW RISK'
    END AS fraud_risk_level

FROM risk_features
ORDER BY fraud_risk_score DESC, txn_timestamp;


-- 4. Account-Level Fraud Activity Summary
WITH rapid_transactions AS (
    SELECT
        t.account_id,
        COUNT(*) AS rapid_transaction_count,
        SUM(t.amount) AS rapid_transaction_value
    FROM (
        SELECT
            txn_id,
            account_id,
            amount,
            txn_timestamp,
            LAG(txn_timestamp) OVER (
                PARTITION BY account_id
                ORDER BY txn_timestamp
            ) AS previous_txn_timestamp
        FROM transactions
    ) t
    WHERE previous_txn_timestamp IS NOT NULL
      AND txn_timestamp - previous_txn_timestamp
          <= INTERVAL '10 minutes'
    GROUP BY account_id
)
SELECT
    a.account_id,
    c.customer_id,
    c.full_name,
    COALESCE(r.rapid_transaction_count, 0)
        AS rapid_transaction_count,
    COALESCE(r.rapid_transaction_value, 0)
        AS rapid_transaction_value
FROM accounts a
JOIN customers c
    ON a.customer_id = c.customer_id
LEFT JOIN rapid_transactions r
    ON a.account_id = r.account_id
ORDER BY rapid_transaction_count DESC,
         rapid_transaction_value DESC;


-- 5. Existing Fraud Analysis View Summary
SELECT
    fraud_risk_level,
    COUNT(*) AS transaction_count,
    ROUND(
        COUNT(*) * 100.0 /
        NULLIF((SELECT COUNT(*) FROM fraud_transaction_analysis), 0),
        2
    ) AS percentage_of_transactions
FROM fraud_transaction_analysis
GROUP BY fraud_risk_level
ORDER BY transaction_count DESC;


-- 6. Top Suspicious Transactions
SELECT
    txn_id,
    account_id,
    amount,
    merchant,
    location,
    txn_timestamp,
    fraud_risk_score,
    fraud_risk_level
FROM fraud_transaction_analysis
ORDER BY fraud_risk_score DESC,
         txn_timestamp
LIMIT 10;
