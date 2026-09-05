# SwiftBite SQL Practice

This is my SQL practice project based on a food-delivery analytics dataset called **SwiftBite Analytics**. I made it while learning how to write queries from basic filtering up to joins, subqueries, CTEs and window functions.

The exercise has 60 questions. The focus is on finding useful business information such as revenue by city, popular menu items, delivery performance, repeat customers and monthly growth.

## Files

- `01_schema.sql` — MySQL 8.0 table structure based on the columns used in the exercise.
- `02_data.sql` — place for the original data import. The source file did not include the database rows, so I left this honest instead of making up results.
- `03_solutions.sql` — all 60 practice queries, kept in their original question order.

## How I would run it

1. Open MySQL Workbench or another MySQL 8.0 client.
2. Run `01_schema.sql` to create the `SwiftBite_Analytics` database and tables.
3. Add the real project data in `02_data.sql`, then run it.
4. Run individual questions from `03_solutions.sql`. The file already starts with `USE SwiftBite_Analytics;`.

## Notes

I wrote the schema from the fields referenced by the exercise because the uploaded file only had questions and queries. I did not execute these queries in this repository: no MySQL server/database export was available in this workspace. That means this project deliberately does not claim any query output or KPI numbers.

The solutions use MySQL syntax such as `DATE_FORMAT`, `DAYOFWEEK`, `TIMESTAMPDIFF`, CTEs and window functions, so MySQL 8.0+ is recommended.

## Topics I practised

- `SELECT`, `WHERE`, `ORDER BY` and `LIMIT`
- `GROUP BY`, `HAVING` and aggregate functions
- joins and missing-data checks with `LEFT JOIN`
- `CASE WHEN` categories and pivot-style counts
- subqueries, date/time functions, CTEs and window functions
- basic food-delivery business KPIs

