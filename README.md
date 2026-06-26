# Nova Bank — Loan & Transaction Analytics (SQL Case Study)

A SQL case study analyzing customer loans and transaction behavior for a fictional bank, **Nova Bank**. Built to demonstrate practical SQL skills — joins, window functions, subqueries, CTEs, and date-based analysis — applied to a realistic, internally-consistent banking dataset.

## 📊 Scenario

Nova Bank wants to understand customer borrowing behavior, repayment patterns, and identify at-risk accounts using their loan and transaction history. This case study answers 12 business questions using SQL, progressing from basic aggregation to advanced window functions and correlated subqueries.

## 🗂️ Schema

**3 tables · 100 customers · 156 loans · 1,072 transactions**
*(synthetic data generated with Python + Faker — see `generate_data.py`)*

```
customers    (customer_id, customer_name, age, city, account_open_date)
loans        (loan_id, customer_id, loan_type, loan_amount, interest_rate, issue_date, status)
transactions (transaction_id, customer_id, transaction_date, amount, transaction_type)
```

Relationships: one customer can have multiple loans and multiple transactions. Data is fully internally consistent — no transaction occurs before its customer's account was opened, and no EMI payment occurs before its loan was issued.

## 📁 Files

| File | Purpose |
|---|---|
| `schema.sql` | Table definitions (`CREATE TABLE` statements only) |
| `sample_data.sql` | Sample data — 100 customers, 156 loans, 1,072 transactions |
| `case_study_questions.sql` | The 12 business questions, unanswered |
| `case_study_answers.sql` | Full SQL solutions with explanatory comments |
| `generate_data.py` | Python + Faker script used to generate the dataset |

## ▶️ How to run

1. Run `schema.sql` first to create the tables
2. Run `sample_data.sql` to populate them
3. Try answering `case_study_questions.sql` yourself, or check `case_study_answers.sql` for solutions

## ❓ Questions Answered

1. Total loan amount disbursed per loan type
2. Customer count per city
3. Customers with more than one loan
4. Each customer's first transaction (date & type)
5. Running total of EMI payments per customer
6. Customer ranking by total loan amount within their city
7. Customers whose most recent transaction was a withdrawal
8. Month-over-month growth in total deposits
9. Defaulted loans that went bad within 6 months of issue
10. Customer loan amount vs. their city average
11. Top 3 customers by total transaction volume
12. Active loans with no EMI payment in the last 60 days (risk flag)

## 🛠️ SQL Concepts Used

| Concept | Where it's used |
|---|---|
| `JOIN` | Throughout — combining customers, loans, transactions |
| `GROUP BY` / `HAVING` | Q1, Q3, Q9 |
| `ROW_NUMBER()` | Q4 — first transaction per customer (handles tie-dates safely) |
| `SUM() OVER (PARTITION BY...)` | Q5 — running totals per customer |
| `RANK()` / `DENSE_RANK()` | Q6, Q11 — ranking within groups and top-N with tie handling |
| `LAG()` (self-join alternative) | Q8 — month-over-month growth comparison |
| Correlated subqueries | Q7, Q10 |
| `NOT EXISTS` / `NOT IN` | Q12 — flagging accounts with no recent activity |
| Date functions (`TIMESTAMPDIFF`, `DATE_SUB`) | Q8, Q9, Q12 |

## ✅ Validation

All 12 queries were tested end-to-end against a live database to confirm correctness — including catching and fixing real bugs along the way:
- A join missing a `customer_id` key that caused cross-customer date collisions (Q7)
- A `PARTITION BY` clause initially omitted from a running-total window function (Q5)
- A silent `HAVING` no-op caused by a missing comparison operator (Q7, early draft)
- A case-sensitivity mismatch (`"active"` vs `"Active"`) that zeroed out an entire CTE (Q12)

## 💡 Key Insight

Several "Active" loans showed no EMI payment in 60+ days despite not being formally marked as defaulted (Q12) — this kind of query is exactly how banks build early-warning systems for credit risk before an account is officially flagged.

---
*Built by Aathin R A as a self-directed SQL practice project.*
