# SwiftBite Analytics — SQL Portfolio Project

A MySQL 8.0 analytics project for a fictional food-delivery platform. It models customers, restaurants, menus, orders, deliveries, and reviews, then answers 60 business questions ranging from basic filtering to KPI reporting with CTEs and window functions.

> This repository focuses on SQL analysis and data modelling. It intentionally does not publish invented data or fabricated business results.

## What this project demonstrates

- Designing a relational schema with primary keys, foreign keys, checks, and targeted indexes
- Writing clear SQL for customer, restaurant, delivery, and revenue analysis
- Using joins, subqueries, conditional aggregation, CTEs, and window functions
- Defining business metrics such as cancellation rate, repeat-customer rate, on-time delivery rate, and month-over-month revenue growth
- Documenting assumptions and keeping analysis reproducible

## Tech stack

- **Database:** MySQL 8.0+
- **SQL features:** CTEs, window functions, `DATE_FORMAT`, `TIMESTAMPDIFF`, conditional aggregation, and ranking functions

## Repository structure

| File | Purpose |
| --- | --- |
| `01_schema.sql` | Creates the `SwiftBite_Analytics` database, tables, relationships, and indexes |
| `02_data.sql` | Clearly documented place to load a compatible dataset |
| `03_solutions.sql` | 60 analytical SQL queries, ordered from beginner to advanced |

## Business questions answered

The query set explores areas such as:

- Restaurant performance, cuisine mix, ratings, and revenue
- Customer value, membership tiers, repeat behaviour, and lifecycle spend
- Order volume, cancellation patterns, promotion effectiveness, and payment usage
- Delivery speed, on-time rate, agent performance, and tips
- Time-based trends including peak hours, monthly revenue, and month-over-month growth
- KPI snapshots suitable for a food-delivery operations dashboard

## Getting started

1. Open MySQL Workbench or another MySQL 8.0-compatible client.
2. Run `01_schema.sql` to create the database and tables.
3. Load data that matches the schema using `02_data.sql` or your preferred import method.
4. Run individual queries from `03_solutions.sql`.

> **Note:** `01_schema.sql` begins with `DROP DATABASE IF EXISTS SwiftBite_Analytics`. Use it only when you are comfortable replacing a database with that name.

## Data note

The original exercise material contained questions and queries but not the source rows, CSVs, or a database export. Rather than inventing records or presenting fictional KPIs as real results, this project leaves a documented import point for a compatible dataset. This keeps the portfolio work transparent and easy to extend.

## Query progression

| Level | Focus |
| --- | --- |
| Beginner | `SELECT`, `WHERE`, sorting, limits |
| Intermediate | Aggregations, `GROUP BY`, `HAVING` |
| Joins | Cross-table order, customer, restaurant, and delivery analysis |
| Advanced | `CASE`, subqueries, date/time functions |
| Analytics | CTEs, window functions, rankings, running totals |
| KPIs | Revenue, retention, promotion, and delivery-health metrics |

## Author

Ravi — aspiring data/business analyst building practical SQL and dashboard projects.
