# Business problems;
#select * from walmartts;

#Q-1 find different payment method and number of transactions, 
#    number of quantity sold.

#select payment_method, count(*) as num_of_transactions, sum(quantity) as quantity_sold 
#from walmartts group by payment_method;

#Q-2 Identify the highest-rated category in each branch, displayying  the branch, category,
#     avg. rating

SELECT * FROM 
(
    SELECT  branch, category,         
		AVG(rating) AS avg_rating,
        RANK() OVER (PARTITION BY branch ORDER BY AVG(rating) DESC) AS rnk
    FROM walmartts 
    GROUP BY branch, category
) AS ranked_data
WHERE rnk = 1;

#Q-3  Identify the busiest day for each branch based on number of Transactions
select * from (
SELECT 
	branch,
    DAYNAME(STR_TO_DATE(date, '%d/%m/%y')) AS day_name,
    count(*) as no_transactions,
    rank() over(partition by branch order by count(*) desc) as rnk
FROM walmartts
group by branch, day_name ) as ranked_data
where rnk =1;

#Q-4 calculate the total quantity of items sold per payment method. 
#    list payment_method and total_quantity

select payment_method, count(*) as no_payments , sum(quantity) as no_qt_sold from walmartts group by payment_method;

#Q-4 Determine the average, minimum and maximum rating of category for each city,
#    list the city, average_rating, min_rating, and max_rating.

use walmartt_db;

select city, category, avg(rating), min(rating), max(rating) from walmartts group by city, category ;

#Q-5 calculate the total profit for each category by considering total_profit as
#    (unit_price * quantity * profit_margin). list category and total_profit ordered from highest to lowest profit.

select category, sum(total) as total_revenue, sum(total*profit_margin) as total_profit from walmartts group by category; 

#Q-6 determine the most common payment method for each branch.
#    display branch and the preferred_payment_method

select * from(
select branch, 
payment_method, 
count(*),
rank() over(partition by branch order by count(*) desc) as rnk
from walmartts 
group by 1,2 ) as ranked_data
where rnk=1;

#Q-7 categorize sales into 3 group morning, afternoon, evening.
#    find out which of the shift and number of invoices.
select time from walmartts;

SELECT branch, 
    CASE
        WHEN EXTRACT(HOUR FROM time) < 12 THEN 'Morning'
        WHEN EXTRACT(HOUR FROM time) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS day_time,
    count(*)
FROM walmartts
group by 1,2
order by 1,3 desc;

#Q-8 identify 5 branch with highest decrease ratio in 
#    revenue compare to last year(current year 2023 and last year 2022)

## RDR = (last_rev-cr_rev)/last_rev * 100 ->revenue decrease ration

-- 2022 sales
WITH revenue_2022 AS (
    SELECT branch,  
           SUM(total) AS revenue 
    FROM walmartts
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%y')) = 2022
    GROUP BY branch
),

revenue_2023 AS (
    SELECT branch,  
           SUM(total) AS revenue 
    FROM walmartts
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%y')) = 2023
    GROUP BY branch
)

SELECT 
    ls.branch,
    ls.revenue AS revenue_2022,
    cs.revenue AS revenue_2023,
    ROUND((ls.revenue - cs.revenue) / ls.revenue * 100, 2) AS rev_dec_ratio
FROM revenue_2022 AS ls
JOIN revenue_2023 AS cs ON ls.branch = cs.branch
WHERE ls.revenue > cs.revenue
ORDER BY rev_dec_ratio DESC limit 5;
