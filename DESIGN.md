# Design Document

By LARISSA LEMOS

Video overview: <URL HERE>

## Scope

In this section you should answer the following questions:

* What is the purpose of your database?
* Which people, places, things, etc. are you including in the scope of your database?
* Which people, places, things, etc. are *outside* the scope of your database?

The "personal_finance" database stores data about personal expenditures, incomes and investments with the purpose of centralizing information from various accounts and institutions, facilitating the process of controling one's financial life.

This database can be used by anyone who wants to set monthly budgets per month and per category of expediture and easily visualizing whether this goal was met or not.

It includes 9 tables, according to below:
- Institutions, including basic information about the financial institutions to which the user has any kind of relationship
- Accounts, including basic identifying information about the account and its type
- Credit Cards, including by which institution the card was issued by and its limit
- Credit Cards Charges, including date, category and other informations about the charges
- Transactions, including information about the incoming and outcoming transactions in each account
- Investments, including information about the types of assets to help monitoring the rentability of each type
- Investments Transactions, including detailed informations about each transaction related to the assets
- Categories, including information about the defined categories of interest of the user
- Budgets, including the budget by category and month to facilitate identifying whether the user is spending more or less than once intended

## Functional Requirements

In this section you should answer the following questions:

* What should a user be able to do with your database?
* What's beyond the scope of what a user should be able to do with your database?

With this database, the user may:

- Visualize the amount or average of their expenditures per periods of time and pre defined categories
- Compare the expenditures to the pre defined budget per periods of time and categories
- Adjust their budget according to previous months analysis
- Compare expenditures and incomes
- Monitor the results of their investments per periods of time and type of investments

## Representation

Entities are captured in SQLite tables with the following schema.

### Entities

In this section you should answer the following questions:

* Which entities will you choose to represent in your database?
* What attributes will those entities have?
* Why did you choose the types you did?
* Why did you choose the constraints you did?

The database includes the following entities:

#### 1. Table: `institutions`
| Entity        | Type    | Constraints                          | Description                                  | Comments                     |
|---------------|---------|--------------------------------------|----------------------------------------------|------------------------------|
| id            | INTEGER | PRIMARY KEY                          | Unique institution identifier                | Auto-incrementing            |
| name          | TEXT    | NOT NULL                             | Name of financial institution                |                              |
| type          | TEXT    | NOT NULL, CHECK (valid types)        | Banks, Credit Unions, Insurance Companies, Investment Companies | Enforced valid values        |

#### 2. Table: `accounts`
| Entity         | Type    | Constraints                          | Description                        | Comments                     |
|----------------|---------|--------------------------------------|------------------------------------|------------------------------|
| id             | INTEGER | PRIMARY KEY                          | Unique account identifier          |                              |
| institution_id | INTEGER | NOT NULL, FOREIGN KEY                | Linked financial institution       | References institutions(id)  |
| name           | TEXT    | NOT NULL                             | Account name                       | User defined                 |
| type           | TEXT    | NOT NULL, CHECK (valid types)        | Checking, Saving, Investment, Other | Enforced valid values        |
| currency       | TEXT    | NOT NULL, DEFAULT 'BRL'              | Account currency                   | Defaults to Brazilian Real   |

#### 3. Table: `categories`
| Entity       | Type    | Constraints               | Description                   | Comments                     |
|--------------|---------|---------------------------|-------------------------------|------------------------------|
| id           | INTEGER | PRIMARY KEY               | Unique category identifier    |                              |
| name         | TEXT    | NOT NULL, UNIQUE          | Category name that refers to spendings  | Prevent duplicates           |
| description  | TEXT    |                           | Detailed description          | Optional field               |

#### 4. Table: `transactions`
| Entity       | Type    | Constraints                          | Description                     | Comments                     |
|--------------|---------|--------------------------------------|---------------------------------|------------------------------|
| id           | INTEGER | PRIMARY KEY                          | Unique transaction identifier   |                              |
| account_id   | INTEGER | NOT NULL, FOREIGN KEY                | Linked account                 | References accounts(id)      |
| category_id  | INTEGER | NOT NULL, FOREIGN KEY                | Transaction category           | References categories(id)    |
| date         | DATE    | NOT NULL                             | Transaction date               | ISO format       |
| description  | TEXT    |                                      | Transaction notes              | Optional                     |
| amount       | REAL    | NOT NULL                             | Transaction amount             | Positive/negative values     |
| is_recurring | BOOLEAN |                                      | Recurring transaction flag     |                              |

#### 5. Table: `credit_cards`
| Entity         | Type    | Constraints                          | Description                     | Comments                     |
|----------------|---------|--------------------------------------|---------------------------------|------------------------------|
| id             | INTEGER | PRIMARY KEY                          | Unique card identifier          |                              |
| institution_id | INTEGER | NOT NULL, FOREIGN KEY                | Issuing institution             | References institutions(id)  |
| name           | TEXT    | NOT NULL                             | Card nickname                   | User-defined                 |
| limit          | REAL    |                                      | Credit limit                    | Optional                     |
| currency       | TEXT    | NOT NULL, DEFAULT 'BRL'              | Card currency                   | Defaults to BRL              |

#### 6. Table: `credit_card_charges`
| Entity         | Type    | Constraints                          | Description                     | Comments                     |
|----------------|---------|--------------------------------------|---------------------------------|------------------------------|
| id             | INTEGER | PRIMARY KEY                          | Unique charge identifier        |                              |
| credit_card_id | INTEGER | NOT NULL, FOREIGN KEY                | Linked credit card              | References credit_cards(id)  |
| date           | DATE    | NOT NULL                             | Charge date                     |                              |
| description    | TEXT    |                                      | Charge description              | Optional                     |
| amount         | REAL    | NOT NULL                             | Charge amount                   | Always positive              |
| category_id    | INTEGER | NOT NULL, FOREIGN KEY                | Spending category               | References categories(id)    |

#### 7. Table: `investments`
| Entity          | Type    | Constraints                          | Description                     | Comments                     |
|-----------------|---------|--------------------------------------|---------------------------------|------------------------------|
| id              | INTEGER | PRIMARY KEY                          | Unique investment identifier    |                              |
| account_id      | INTEGER | NOT NULL, FOREIGN KEY                | Holding account                 | References accounts(id)      |
| asset_name      | TEXT    | NOT NULL                             | Investment name (e.g., 'PETR4') |                              |
| asset_type      | TEXT    | NOT NULL                             | Asset class                     |                              |
| current_value   | REAL    |                                      | Current market value            | Updates frequently           |
| current_quantity| REAL    |                                      | Number of shares/units held     | Can be fractional            |

#### 8. Table: `investment_transactions`
| Entity         | Type    | Constraints                          | Description                     | Comments                     |
|----------------|---------|--------------------------------------|---------------------------------|------------------------------|
| id             | INTEGER | PRIMARY KEY                          | Unique transaction identifier   |                              |
| investment_id  | INTEGER | NOT NULL, FOREIGN KEY                | Related investment              | References investments(id)   |
| date           | DATE    | NOT NULL                             | Transaction date                |                              |
| type           | TEXT    | NOT NULL                             | Transaction type (buy/sell)     |                              |
| amount         | REAL    | NOT NULL                             | Total transaction value         |                              |
| unit_price     | REAL    |                                      | Price per unit                  |                              |
| quantity       | REAL    |                                      | Number of units traded          |                              |

#### 9. Table: `budgets`
| Entity       | Type    | Constraints                          | Description                     | Comments                     |
|--------------|---------|--------------------------------------|---------------------------------|------------------------------|
| id           | INTEGER | PRIMARY KEY                          | Unique budget identifier        |                              |
| year         | INTEGER | NOT NULL, CHECK (4 digits)           | Budget year                     |                              |
| month        | INTEGER | NOT NULL, CHECK (1-12)               | Budget month                    |                              |
| category_id  | INTEGER | NOT NULL, FOREIGN KEY                | Budget category                 | References categories(id)    |
| amount       | REAL    | NOT NULL                             | Budgeted amount                 |                              |

#### Triggers

#### 1. Trigger: `update_current_quantity_after_transaction`
- **When**: After a new line is inserted on investment_transactions
- **Action**: Updates investment quantity automatically after trades on investments
- **Purpose**: Maintains accurate quantity for each asset

#### 2. Trigger: `prevent_negative_quantity`
- **When**: Before a new line is inserted on investment_transactions
- **Condition**: When type is equal to 'sell'
- **Action**: Blocks transactions that would result in negative holdings
- **Purpose**: Ensures data integrity

### Relationships

The below entity relationship diagram describes the relationships among the entities in the database.

![ER Diagram](diagram.png)

As detailed in the diagram:

- The table institutions connects to 3 other tables. One institution can issue 0 to many credit cards, can have 0 to many accounts and can process 0 to many transactions. Each of these 3, have to be connected to one and only one institution.
- The accounts performs 0 to many transactions and holds 0 to many investments. The user can have an account that has not been used yet. But each investment and transaction have to be connected to one and only one account.
- The investments record 1 to many investment transactions. An investment will only appear on the investments table if there is or was a transaction refered to that asset.
- Each credit card contains 0 to many credit card charges. Each charge have to be connected to one and only one credit card.
- The table categories is defined by the user. It can classify 0 to many transactions, credit card charges and budgets. But each of these 3 can only be connected to one and only one category.
- The table budget is also defined by the user. It is only connected to categories.

## Optimizations

In this section you should answer the following questions:

* Which optimizations (e.g., indexes, views) did you create? Why?

## Limitations

In this section you should answer the following questions:

* What are the limitations of your design?
* What might your database not be able to represent very well?
