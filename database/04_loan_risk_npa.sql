-- ============================================================
-- BANKING ANALYTICS & RISK INTELLIGENCE
-- Loan Risk & NPA Analysis
-- ============================================================


-- 1. Loan Payment Performance
SELECT
    l.loan_id,
    l.customer_id,
    l.principal,
    l.emi,
    COUNT(lp.payment_id) AS total_payments,
    COUNT(*) FILTER (WHERE lp.status = 'PAID') AS paid_payments,
    COUNT(*) FILTER (WHERE lp.status = 'MISSED') AS missed_payments,
    COALESCE(SUM(lp.amount_paid), 0) AS total_amount_paid
FROM loans l
LEFT JOIN loan_payments lp
    ON l.loan_id = lp.loan_id
GROUP BY
    l.loan_id,
    l.customer_id,
    l.principal,
    l.emi
ORDER BY l.loan_id;


-- 2. Overdue Payment Analysis
SELECT
    lp.payment_id,
    lp.loan_id,
    lp.due_date,
    lp.payment_date,
    lp.status,
    CASE
        WHEN lp.payment_date > lp.due_date
        THEN lp.payment_date - lp.due_date
        ELSE 0
    END AS days_overdue
FROM loan_payments lp
ORDER BY days_overdue DESC;


-- 3. Loan-Level Overdue Risk
SELECT
    l.loan_id,
    l.customer_id,
    l.principal,
    MAX(
        CASE
            WHEN lp.payment_date > lp.due_date
            THEN lp.payment_date - lp.due_date
            ELSE 0
        END
    ) AS maximum_days_overdue,
    CASE
        WHEN MAX(
            CASE
                WHEN lp.payment_date > lp.due_date
                THEN lp.payment_date - lp.due_date
                ELSE 0
            END
        ) >= 90 THEN 'NPA'
        WHEN MAX(
            CASE
                WHEN lp.payment_date > lp.due_date
                THEN lp.payment_date - lp.due_date
                ELSE 0
            END
        ) > 0 THEN 'OVERDUE'
        ELSE 'CURRENT'
    END AS loan_risk_status
FROM loans l
LEFT JOIN loan_payments lp
    ON l.loan_id = lp.loan_id
GROUP BY
    l.loan_id,
    l.customer_id,
    l.principal
ORDER BY maximum_days_overdue DESC;


-- 4. NPA Summary
WITH loan_risk AS (
    SELECT
        l.loan_id,
        CASE
            WHEN MAX(
                CASE
                    WHEN lp.payment_date > lp.due_date
                    THEN lp.payment_date - lp.due_date
                    ELSE 0
                END
            ) >= 90 THEN 'NPA'
            ELSE 'NON-NPA'
        END AS npa_status
    FROM loans l
    LEFT JOIN loan_payments lp
        ON l.loan_id = lp.loan_id
    GROUP BY l.loan_id
)
SELECT
    COUNT(*) AS total_loans,
    COUNT(*) FILTER (WHERE npa_status = 'NPA') AS npa_loans,
    ROUND(
        COUNT(*) FILTER (WHERE npa_status = 'NPA') * 100.0
        / NULLIF(COUNT(*), 0),
        2
    ) AS npa_percentage
FROM loan_risk;


-- 5. Default Risk Category
SELECT
    l.loan_id,
    l.customer_id,
    COUNT(*) FILTER (
        WHERE lp.status = 'MISSED'
    ) AS missed_payments,
    CASE
        WHEN COUNT(*) FILTER (
            WHERE lp.status = 'MISSED'
        ) >= 3 THEN 'HIGH RISK'
        WHEN COUNT(*) FILTER (
            WHERE lp.status = 'MISSED'
        ) = 2 THEN 'MEDIUM RISK'
        ELSE 'LOW RISK'
    END AS risk_category
FROM loans l
LEFT JOIN loan_payments lp
    ON l.loan_id = lp.loan_id
GROUP BY
    l.loan_id,
    l.customer_id
ORDER BY
    missed_payments DESC,
    l.loan_id;
