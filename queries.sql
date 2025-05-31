-- This file contains SQL queries for financial analysis and reporting.

-- View for total spent (transactions and credit card charges)
CREATE VIEW total_spent AS
SELECT
    date,
    category_id,
    'transaction' AS source,
    ABS(amount) AS amount
FROM transactions
WHERE amount < 0

UNION ALL

SELECT
    date,
    category_id,
    'credit_card' AS source,
    ABS(amount) AS amount
FROM credit_card_charges;

-------------------------------------------------------------------------------------------------------------

-- How much do I earn (positive transactions) per month
SELECT
    strftime('%Y-%m', date) AS year_month,
    SUM(amount) AS total_earned
FROM transactions
WHERE amount > 0
GROUP BY year_month
ORDER BY year_month;

-------------------------------------------------------------------------------------------------------------

-- How much do I spend monthly per category?
CREATE VIEW monthly_spending_per_category AS
SELECT
    strftime('%Y-%m', date) AS year_month,
    category_id,
    SUM(amount) AS total_spent
FROM total_spent
GROUP BY year_month, category_id
ORDER BY year_month, category_id;

SELECT
    m.year_month,
    c.name AS category,
    m.total_spent
FROM monthly_spending_per_category m
JOIN categories c ON m.category_id = c.id
ORDER BY m.year_month, c.name;

-------------------------------------------------------------------------------------------------------------

-- How much do I spend monthly per category above or below my budget?

SELECT
    s.year_month AS year_month,
    c.name AS category,
    COALESCE(ABS(s.total_spent), 0) AS total_spent,
    COALESCE(b.amount, 0) AS budgeted,
    COALESCE(b.amount, 0) - COALESCE(ABS(s.total_spent), 0) AS budget_balance
FROM categories c
LEFT JOIN (
    SELECT
        printf('%04d-%02d', year, month) AS year_month,
        category_id,
        amount
    FROM budgets
) b ON c.id = b.category_id
FULL JOIN monthly_spending_per_category s
    ON s.category_id = c.id AND s.year_month = b.year_month
ORDER BY year_month, category;

-------------------------------------------------------------------------------------------------------------

-- What is the financial balance per month, considering the total I earn and the total I spend in all categories and accounts?
SELECT
    strftime('%Y-%m', "date") AS "year_month",
    SUM("amount") AS "balance"
FROM "transactions"
GROUP BY "year_month"
ORDER BY "year_month";

-------------------------------------------------------------------------------------------------------------

-- How much money do I have invested in total per month?
WITH monthly_net_investments AS (
    SELECT
        strftime('%Y-%m', date) AS year_month,
        SUM(
            CASE
                WHEN type = 'purchase' THEN quantity * unit_price
                WHEN type = 'sell' THEN -1 * quantity * unit_price
                ELSE 0
            END
        ) AS net_invested
    FROM investment_transactions
    GROUP BY year_month
),
cumulative_investments AS (
    SELECT
        year_month,
        net_invested,
        SUM(net_invested) OVER (ORDER BY year_month) AS cumulative_invested
    FROM monthly_net_investments
)
SELECT * FROM cumulative_investments;

-------------------------------------------------------------------------------------------------------------

-- How much are my investments rentability per type?
WITH activity AS (
    SELECT
        inv.asset_type,
        SUM(CASE WHEN it.type = 'purchase' THEN ABS(it.amount) ELSE 0 END) AS invested,
        SUM(CASE WHEN it.type = 'sell' THEN it.amount ELSE 0 END) AS received
    FROM investment_transactions it
    JOIN investments inv ON it.investment_id = inv.id
    GROUP BY inv.asset_type
),
current_portfolio_value AS (
    SELECT
        asset_type,
        SUM(current_quantity * current_value) AS current_value
    FROM investments
    GROUP BY asset_type
),
combined AS (
    SELECT
        a.asset_type,
        a.invested,
        a.received,
        cp.current_value
    FROM activity a
    LEFT JOIN current_portfolio_value cp ON a.asset_type = cp.asset_type
)
SELECT
    asset_type,
    invested,
    received,
    current_value,
    ROUND(
        (COALESCE(current_value, 0) + received - invested) * 100.0 / NULLIF(invested, 0),
        2
    ) AS return_percentage
FROM combined
ORDER BY asset_type;

-------------------------------------------------------------------------------------------------------------

-- Create indexes to improve query performance
CREATE INDEX idx_transactions_date ON transactions(date);
CREATE INDEX idx_transactions_category_id ON transactions(category_id);
CREATE INDEX idx_transactions_amount ON transactions(amount);

CREATE INDEX idx_credit_card_charges_date ON credit_card_charges(date);
CREATE INDEX idx_credit_card_charges_category_id ON credit_card_charges(category_id);

CREATE INDEX idx_budgets_category_month ON budgets(category_id, year, month);
