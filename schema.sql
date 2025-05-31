-- Financial Institutions
CREATE TABLE "institutions" (
    "id" INTEGER PRIMARY KEY,
    "name" TEXT NOT NULL,
    "type" TEXT NOT NULL CHECK (type IN ('Bank', 'Credit Union', 'Insurance Company', 'Investment Company'))
);

-- Bank accounts
CREATE TABLE "accounts" (
    "id" INTEGER PRIMARY KEY,
    "institution_id" INTEGER NOT NULL,
    "name" TEXT NOT NULL,
    "type" TEXT NOT NULL CHECK (type IN ('Checking', 'Saving', 'Investment', 'Other')),
    "currency" TEXT NOT NULL DEFAULT 'BRL',
    FOREIGN KEY ("institution_id") REFERENCES "institutions"("id")
);

CREATE TABLE "categories" (
    "id" INTEGER PRIMARY KEY,
    "name" TEXT NOT NULL UNIQUE, -- 'Housing and Utilities', 'Transportation', 'Groceries', 'Healthcare', 'Debt Repayment', 'Savings', 'Personal', 'Charity', 'Child Care', 'Education', 'Miscellaneous'
    "description" TEXT
);

-- Bank transactions
CREATE TABLE "transactions" (
    "id" INTEGER PRIMARY KEY,
    "account_id" INTEGER NOT NULL,
    "category_id" INTEGER NOT NULL,
    "date"  DATE NOT NULL,
    "description" TEXT,
    "amount" REAL NOT NULL,
    "is_recurring" BOOLEAN,
    FOREIGN KEY ("account_id") REFERENCES "accounts"("id"),
    FOREIGN KEY ("category_id") REFERENCES "categories"("id")
);

-- Credit Cards
CREATE TABLE "credit_cards" (
    "id" INTEGER PRIMARY KEY,
    "institution_id" INTEGER NOT NULL,
    "name" TEXT NOT NULL,
    "limit" REAL,
    "currency" TEXT NOT NULL DEFAULT 'BRL',
    FOREIGN KEY ("institution_id") REFERENCES "institutions"("id")
);

-- Credit Cards Charges
CREATE TABLE "credit_card_charges" (
    "id" INTEGER PRIMARY KEY,
    "credit_card_id" INTEGER NOT NULL,
    "date" DATE NOT NULL,
    "description" TEXT,
    "amount" REAL NOT NULL,
    "category_id" INTEGER NOT NULL,
    FOREIGN KEY ("credit_card_id") REFERENCES "credit_cards"("id"),
    FOREIGN KEY ("category_id") REFERENCES "categories"("id")

);

-- Investments
CREATE TABLE "investments" (
    "id" INTEGER PRIMARY KEY,
    "account_id" INTEGER NOT NULL,
    "asset_name" TEXT NOT NULL,
    "asset_type" TEXT NOT NULL, -- Cash and cash equivalents, Fixed income, Equities, Commodities
    "current_value" REAL, -- Current value of the investment
    "current_quantity" REAL,
    FOREIGN KEY ("account_id") REFERENCES "accounts"("id")
);

-- Investment Transactions
CREATE TABLE "investment_transactions" (
    "id" INTEGER PRIMARY KEY,
    "investment_id" INTEGER NOT NULL,
    "date" DATE NOT NULL,
    "type" TEXT NOT NULL, -- sell, purchase...
    "amount" REAL NOT NULL,
    "unit_price" REAL,
    "quantity" REAL,
    FOREIGN KEY ("investment_id") REFERENCES "investments"("id")
);

-- Monthly budgets per category
CREATE TABLE "budgets" (
    "id" INTEGER PRIMARY KEY,
    "year" INTEGER NOT NULL CHECK (length("year") = 4),
    "month" INTEGER NOT NULL CHECK ("month" > 0 AND "month" < 13),
    "category_id" INTEGER NOT NULL,
    "amount" REAL NOT NULL,
    FOREIGN KEY ("category_id") REFERENCES "categories"("id")
);

-- Update current value of investments after transactions
CREATE TRIGGER "update_current_quantity_after_transaction"
AFTER INSERT ON "investment_transactions"
FOR EACH ROW
BEGIN
    -- If it's a purchase, increase the current quantity
    UPDATE "investments"
    SET "current_quantity" = "current_quantity" + NEW."quantity"
    WHERE "id" = NEW."investment_id" AND NEW."type" = 'purchase';

    -- If it's a sell, decrease the current quantity
    UPDATE "investments"
    SET "current_quantity" = "current_quantity" - NEW."quantity"
    WHERE "id" = NEW."investment_id" AND NEW."type" = 'sell';
END;

-- Prevent negative quantity in investment transactions
CREATE TRIGGER "prevent_negative_quantity"
BEFORE INSERT ON "investment_transactions"
FOR EACH ROW
WHEN NEW."type" = 'sell'
BEGIN
    -- Verifica se a quantidade disponível é suficiente
    SELECT
        CASE
            WHEN (SELECT "current_quantity" FROM "investments" WHERE "id" = NEW."investment_id") < NEW."quantity"
            THEN RAISE(ABORT, 'Venda excede a quantidade disponível')
        END;
END;

-- Prevent zero amounts in transactions
CREATE TRIGGER "prevent_zero_transaction"
BEFORE INSERT ON "transactions"
FOR EACH ROW
WHEN NEW."amount" = 0
BEGIN
    SELECT
        RAISE(ABORT, 'Transaction amount must be non-zero');
END;

-- Prevent zero amounts in credit card charges
CREATE TRIGGER "prevent_zero_credit_card_charge"
BEFORE INSERT ON "credit_card_charges"
FOR EACH ROW
WHEN NEW."amount" = 0
BEGIN
    SELECT
        RAISE(ABORT, 'Credit card charge amount must be non-zero');
END;

-- Prevent zero amounts in investment transactions
CREATE TRIGGER "prevent_zero_investment_transaction"
BEFORE INSERT ON "investment_transactions"
FOR EACH ROW
WHEN NEW."amount" = 0
BEGIN
    SELECT
        RAISE(ABORT, 'Investment transaction amount must be non-zero');
END;

-- Verify credit card charges do not exceed the credit card limit
CREATE TRIGGER "prevent_credit_limit_exceeded"
BEFORE INSERT ON "credit_card_charges"
FOR EACH ROW
WHEN (
    SELECT SUM("amount") FROM "credit_card_charges"
    WHERE "credit_card_id" = NEW."credit_card_id"
) + NEW."amount" > (
    SELECT "limit" FROM "credit_cards" WHERE "id" = NEW."credit_card_id"
)
BEGIN
    SELECT
        RAISE(ABORT, 'Credit card charge exceeds the credit limit');
END;
