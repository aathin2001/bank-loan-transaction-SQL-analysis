/* ================================================================
   NOVA BANK — LOAN & TRANSACTION ANALYTICS CASE STUDY
   ================================================================
   Author : Aathin R A
   Skills tested: Joins | Window Functions | Subqueries | CTEs | Date Functions
   ----------------------------------------------------------------
   SCENARIO:
   Nova Bank wants to understand customer borrowing behavior,
   repayment patterns, and identify at-risk accounts using their
   loan and transaction history.

   Answer the following 12 business questions using SQL.
   ================================================================ */
show tables ;
use nova_bank;

-- 1.  What is the total loan amount disbursed per loan type?

select loan_type , sum(loan_amount) as total_amount from loans
group by loan_type
;

-- 2.  How many customers are there in each city?

select city , count(*) customer_count from customers
group by city
;

-- 3.  Which customers have taken more than one loan?
with customer_loan_count as (
select customer_id , count(*) loan_count from loans
group by customer_id
having count(*) >1) 

select c.customer_name , cl.loan_count from customers c join customer_loan_count cl 
on c.customer_id = cl.customer_id
order by cl.loan_count desc
;


-- 4.  What was each customer's first transaction (date & type)?


with transaction_detail as (
select customer_id , min(transaction_date) as initial_transaction from transactions
group by customer_id
)
select c.customer_name,t2.transaction_date,t2.transaction_type from customers c join transaction_detail t1 on 
c.customer_id = t1.customer_id  join transactions t2 on t1.initial_transaction = t2.transaction_date and t1.customer_id = t2.customer_id ;


-- 5.  What is the running total of EMI payments made by each customer?
with emi_details as(
select customer_id ,transaction_date, sum(amount) over(partition by customer_id order by transaction_date ) running_total from transactions
where transaction_type = "Emi_payment")
select c.customer_name,e.transaction_date,e.running_total from customers c join emi_details e on c.customer_id = e.customer_id
;

-- 6.  How do customers rank by total loan amount within their city?
with loan_details as (
select c.customer_name,city,sum(l.loan_amount) loan_amount from customers c 
join loans l on c.customer_id = l.customer_id 
group by c.customer_name,city)
select dense_rank() over(partition by city  order by loan_amount desc) as ranking ,customer_name,city from loan_details
;

-- 7.  Which customers' most recent transaction was a withdrawal?
with t1 as (select customer_id,max(transaction_date) last_transaction from transactions
group by customer_id) 
select c.customer_name from  t1 join  transactions t on t1.customer_id = t.customer_id and t1.last_transaction = t.transaction_date join customers c on t1.customer_id = c.customer_id
where t.transaction_type ="withdrawal"
; 

select * from loans;

-- 8.  What is the month-over-month growth in total deposits?

with monthly_transaction as(
select monthname(transaction_date) mon,year(transaction_date)yr ,sum(amount) total_amount, row_number() over(order by year(transaction_date),monthname(transaction_date))
rw_no from transactions
where transaction_type = "deposit"
group by yr,mon

),
tb1 as ( select  t1.mon,t1.yr,t1.total_amount c_total_amount,ifnull(t2.total_amount ,0) p_total_amount   from monthly_transaction t1 left join monthly_transaction t2 on t1.rw_no = t2.rw_no+1)

select mon month,yr as year ,ifnull(((c_total_amount - p_total_amount)/p_total_amount)*100,c_total_amount) mom_growth    from tb1;
-- 9.  Which defaulted loans went bad within 6 months of being issued?

SELECT 
    l.loan_id,
    c.customer_name,
    l.loan_type,
    l.issue_date,
    MAX(t.transaction_date) AS last_activity_date,
    TIMESTAMPDIFF(MONTH, l.issue_date, MAX(t.transaction_date)) AS months_active
FROM loans l
JOIN customers c ON l.customer_id = c.customer_id
JOIN transactions t ON c.customer_id = t.customer_id
WHERE l.status = 'Defaulted'
GROUP BY l.loan_id, c.customer_name, l.loan_type, l.issue_date
HAVING months_active <= 6;

-- 10. How does each customer's loan amount compare to their city average?
select c.customer_name,l.loan_amount,c.city ,avg(l.loan_amount) over(partition by city) city_avg from customers c join  loans l on c.customer_id = l.customer_id 
;
-- 11. Who are the top 3 customers by total transaction volume?
select c.customer_name , sum(t.amount) total_transaction from customers c join transactions t on c.customer_id  = t.customer_id 
group by c.customer_name
order by  total_transaction desc
limit 3
;

-- 12. Which active loans have had no EMI payment in the last 60 days?

with active_loans as(
select distinct customer_id  from loans
where status = "Active"),
paid_cust as (
select distinct customer_id from transactions
where transaction_date >= 
(select date_sub( max(transaction_date),interval 60 day) due_range from transactions)
and transaction_type = "Emi_payment") 

select loan_type from loans
where customer_id in (select * from active_loans) and customer_id not in (select * from paid_cust)
;

show tables;

describe customers;
describe loans;
describe transactions;




