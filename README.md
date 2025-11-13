# Zomato Analytics SQL

SQL scripts to analyze a Zomato-like sales dataset. This project includes:
- `schema.sql` — table definitions for `sales`, `product`, `goldusers_signup`.
- `insert_data.sql` — sample INSERT statements to populate tables for testing.
- `analysis_query.sql` — 10+ analysis queries (total spent per user, first product, ranking, points calculation, member-period analytics).

## How to run
1. Create a database (e.g., `zomato_db`)
2. Run `schema.sql` to create tables.
3. Run `insert_data.sql` to populate sample data.
4. Open `analysis_query.sql` and run the queries in your SQL client (SQL Server / SSMS / Azure SQL).

## Example queries included
- Total spent per customer
- Distinct days visited per customer
- First product purchased by each customer (ROW_NUMBER)
- Most purchased item overall and per customer
- Purchase before/after Gold signup
- Points calculations and ranking

## Files
- `schema.sql` — schema
- `insert_data.sql` — data
- `analysis_query.sql` — queries 



