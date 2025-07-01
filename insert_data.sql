INSERT INTO "institutions" ("id", "name", "type") VALUES
(1, 'Nubank', 'Bank'),
(2, 'XP', 'Investment Company');

INSERT INTO "accounts" ("id", "institution_id", "name", "type", "currency") VALUES
(1, 1, 'Checking', 'Checking', 'BRL'),
(2, 2, 'Conta Investimento', 'Investment', 'BRL');

INSERT INTO "categories" ("id", "name") VALUES
(1, 'Charity'),
(2, 'Child Care'),
(3, 'Debt Repayment'),
(4, 'Education'),
(5, 'Groceries and Food'),
(6, 'Healthcare'),
(7, 'Housing and Utilities'),
(8, 'Miscellaneous'),
(9, 'Personal'),
(10, 'Savings'),
(11, 'Transportation'),
(12, 'Credit Card'),
(13, 'Entries');

INSERT INTO "transactions" ("id", "account_id", "category_id", "date", "description", "amount", "is_recurring") VALUES
(1, 1, 7, '2025-01-05', 'Rent', -200000, 1),
(2, 1, 5, '2025-01-10', 'Supermarket', -60000, 1),
(3, 1, 11, '2025-01-12', 'Gas', -30000, 1),
(4, 1, 13, '2025-01-25', 'Salary', 500000, 1),
(5, 1, 9, '2025-01-18', 'Cinema', -6000, 0),
(6, 1, 6, '2025-01-22', 'Pharmacy', -15000, 0),
(7, 1, 13, '2025-02-25', 'Salary', 500000, 1),
(8, 1, 5, '2025-02-10', 'Supermarket', -65000, 1),
(9, 1, 7, '2025-02-05', 'Rent', -200000, 1),
(10, 1, 11, '2025-02-13', 'Uber', -18000, 0);

INSERT INTO "budgets" ("id", "year", "month", "category_id", "amount") VALUES
(1, 2025, 1, 5, 50000),  -- Groceries Jan
(2, 2025, 1, 11, 30000), -- Transportation Jan
(3, 2025, 2, 5, 50000),  -- Groceries Feb
(4, 2025, 2, 11, 30000); -- Transportation Feb

INSERT INTO "investments" ("id", "account_id", "asset_name", "asset_type", "current_quantity", "current_value") VALUES
(1, 1, 'Tesouro Selic 2026', 'Fixed income', 1, 1050000),
(2, 1, 'Fundo Imobiliário XPML11', 'Equities', 2, 620000),
(3, 2, 'Ouro ETF GOLD11', 'Commodities', 20, 380000);

INSERT INTO "investment_transactions" ("id", "investment_id", "date", "type", "amount", "unit_price", "quantity") VALUES
(1, 1, '2025-01-10', 'purchase', 500000, 10000, 5000),
(2, 1, '2025-03-05', 'purchase', 300000, 10000, 3000),
(3, 2, '2025-02-15', 'purchase', 400000, 10000, 4000),
(4, 2, '2025-04-10', 'purchase', 150000, 10000, 1500),
(5, 3, '2025-03-01', 'sell', 200000, 10000, 2000),
(6, 3, '2025-05-01', 'purchase', 100000, 10000, 1000);

INSERT INTO "credit_cards" ("id", "institution_id", "name", "limit", "currency") VALUES
(1, 1, 'Visa Gold', 800000, 'BRL'),
(2, 2, 'Mastercard Platinum', 1200000, 'BRL');

INSERT INTO "credit_card_charges" ("id", "credit_card_id", "date", "description", "amount", "category_id") VALUES
(1, 1, '2025-01-15', 'Supermarket', 45000, 5),   -- Groceries
(2, 1, '2025-01-25', 'Pharmacy', 12000, 6),      -- Healthcare
(3, 2, '2025-02-10', 'Gas', 30000, 11),          -- Transportation
(4, 2, '2025-03-05', 'Netflix', 5500, 9),        -- Personal
(5, 1, '2025-03-20', 'Donation', 10000, 1);      -- Charity
