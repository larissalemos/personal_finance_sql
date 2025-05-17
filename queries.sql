-- How much do I spend monthly by category?
CREATE VIEW monthly_spending_per_category AS
SELECT
    strftime('%Y-%m', date) AS year_month,
    categories.id AS category_id,
    categories.name AS category,
    SUM(ABS(amount)) AS total_spent
FROM (
    -- Expenses from transactions
    SELECT
        transactions.date,
        transactions.category_id,
        transactions.amount
    FROM transactions
    JOIN categories ON transactions.category_id = categories.id
    WHERE transactions.amount < 0 AND categories.name != 'Credit Card'

    UNION ALL

    -- Expenses from credit card charges
    SELECT
        credit_card_charges.date,
        credit_card_charges.category_id,
        credit_card_charges.amount
    FROM credit_card_charges
) AS all_expenses
JOIN categories ON all_expenses.category_id = categories.id
GROUP BY year_month, category_id;

-------------------------------------------------------------------------------------------------------------

-- How much do I spend monthly by category above ou below my budget?
SELECT
    s.year_month AS year_month,
    c.name AS category,
    ABS(s.total_spent) AS total_spent,
    b.amount AS budgeted,
    b.amount - ABS(s.total_spent) AS budget_balance
FROM categories c
LEFT JOIN (
    SELECT
        printf('%04d-%02d', year, month) AS year_month,
        category_id,
        amount
    FROM budgets
) b ON c.id = b.category_id
LEFT JOIN monthly_spending_per_category s
    ON s.category_id = c.id AND s.year_month = b.year_month
ORDER BY year_month, category;

-------------------------------------------------------------------------------------------------------------

-- What is the financial balance by month, considering the total I earn and the total I spend in all categories and accounts?
SELECT
    strftime('%Y-%m', "date") AS "year_month",
    SUM("amount") AS "balance"
FROM "transactions"
GROUP BY "year_month"
ORDER BY "year_month";

-------------------------------------------------------------------------------------------------------------

-- How much money do I have invested in total by month?
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

-- How much are my investments rentability per month in percentage?
-- rentability = ((current_quantity * current_value + amount_sold - amount_purchased) / amount_purchased) * 100



-------------------------------------------------------------------------------------------------------------

-- How much are my investments rentability per month and per type in percentage?
WITH "monthly_returns" AS (
    SELECT
        strftime('%Y-%m', "it"."date") AS "year_month",
        "inv"."asset_type",
        SUM(CASE WHEN "it"."type" = 'sell' THEN "it"."amount" ELSE 0 END) -
        SUM(CASE WHEN "it"."type" = 'purchase' THEN "it"."amount" ELSE 0 END) AS "net_return",
        SUM(CASE WHEN "it"."type" = 'purchase' THEN "it"."amount" ELSE 0 END) AS "invested"
    FROM "investment_transactions" AS "it"
    JOIN "investments" AS "inv" ON "it"."investment_id" = "inv"."id"
    GROUP BY "year_month", "inv"."asset_type"
)
SELECT
    "year_month",
    "asset_type",
    SUM("net_return") * 100.0 / NULLIF(SUM("invested"), 0) AS "return_percentage"
FROM "monthly_returns"
GROUP BY "year_month", "asset_type"
ORDER BY "year_month", "asset_type";
