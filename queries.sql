# ----------------------------------------
/* Query 1 - query used for question 1*/
# ===================================
# ===================================
# Question 1:
# Out of all of the family movies, what are the categories of those movies and how many times has it been rented out?
select f.title as film_title,
	c.name as category_name,
	count(r.rental_date) as rental_count
from film_category as fc
join category as c
on c.category_id = fc.category_id
join film as f
on f.film_id = fc.film_id
join inventory as i
on fc.film_id = i.film_id
join rental as r
on r.inventory_id = i.inventory_id
where c.name = 'Animation' or 
	c.name = 'Children' or
	c.name = 'Classics' or
	c.name = 'Comedy' or
	c.name = 'Family' or
	c.name = 'Music'
group by film_title, category_name
order by 2,1;

# ----------------------------------------
/* Query 2 - query used for question 2*/
# ===================================
# ===================================
# Question 2
# How does the length of rental duration of these family-friendly movies compare to the duration that all movies are rented for?
# Query below returns the family-friendly movies
SELECT f.title as film_title,
        c.name as category_name,
        f.rental_duration as rental_duration,
        NTILE(4) OVER(ORDER BY f.rental_duration) AS standard_quartile
FROM film_category AS fc
JOIN category AS c
ON c.category_id = fc.category_id
JOIN film AS f
ON f.film_id = fc.film_id
WHERE c.name IN ('Animation', 'Children','Classics','Comedy','Family','Music')
ORDER BY f.rental_duration;

# Query below returns the non-family-friendly movies:
SELECT f.title as film_title,
        c.name as category_name,
        f.rental_duration as rental_duration,
        NTILE(4) OVER(ORDER BY f.rental_duration) as standard_quartile
FROM film_category AS fc
JOIN category AS c
ON c.category_id = fc.category_id
JOIN film AS f
ON f.film_id = fc.film_id
WHERE c.name NOT IN ('Animation', 'Children','Classics','Comedy','Family','Music')
ORDER BY f.rental_duration;

# ----------------------------------------
/* Query 3 - query used for question 3*/
# ===================================
# ===================================
# Question 3
# How many movies are within each combination of film category for each corresponding rental duration category?
SELECT category_name, standard_quartile, count(standard_quartile) as movie_count
FROM
	(SELECT
			c.name as category_name,
	 		f.title,
			NTILE(4) OVER(ORDER BY f.rental_duration) AS standard_quartile
	FROM film_category AS fc
	JOIN category AS c
	ON c.category_id = fc.category_id
	JOIN film AS f
	ON f.film_id = fc.film_id
	WHERE c.name IN ('Animation', 'Children','Classics','Comedy','Family','Music')) f1
GROUP BY category_name,standard_quartile
ORDER BY category_name,standard_quartile

# ----------------------------------------
/* Query 4 - query used for question 4*/
# ===================================
# ===================================
# Question 4
# How do the two stores compare in their count of rental orders during every month for all the years we have data for?
SELECT  
		rental_month, rental_year, store_id,
		sum(count_rentals_one) as count_rentals
FROM
	(SELECT
			EXTRACT(MONTH FROM r.rental_date) AS rental_month,
			EXTRACT(YEAR FROM r.rental_date) AS rental_year,
			i.store_id as store_id,
	 		count(r.rental_id) as count_rentals_one
	FROM rental r
	JOIN inventory i
	ON r.inventory_id = i.inventory_id
	GROUP BY r.rental_date, store_id) f1
GROUP BY rental_month, rental_year, store_id
ORDER BY count_rentals DESC;

# ----------------------------------------
/* Query 5 - query used for question 5*/
# ===================================
# ===================================
# Question 5
# Who were the top 10 paying customers, how many payments did they make on a monthly basis during 2007, 
# and what was the amount of the monthly payments?
SELECT f2.trunc_month, full_name, f2.pay_countpermon, f2.customer_amount
FROM
	(SELECT f1.full_name AS full_name,
			sum(customer_amount) OVER (PARTITION BY f1.full_name) AS sum_customer,
			f1.trunc_month,f1.pay_countpermon,f1.customer_amount
	FROM
	(SELECT
			date_trunc('month',p.payment_date) AS trunc_month,
			concat(c.first_name,' ',c.last_name) AS full_name,
			count(c.first_name) AS pay_countpermon,
			sum(p.amount) AS customer_amount
	FROM payment p 
	JOIN customer c
	ON c.customer_id = p.customer_id
	WHERE EXTRACT(YEAR FROM date_trunc('month',p.payment_date))=2007
	GROUP BY trunc_month,full_name) f1
	ORDER BY sum_customer DESC) f2
WHERE full_name IN 
	(
		SELECT full_name
		FROM
		(SELECT
			date_trunc('month',p.payment_date) AS trunc_month,
			concat(c.first_name,' ',c.last_name) AS full_name,
			count(c.first_name) AS pay_countpermon,
			sum(p.amount) AS customer_amount
		FROM payment p 
		JOIN customer c
		ON c.customer_id = p.customer_id
		WHERE EXTRACT(YEAR FROM date_trunc('month',p.payment_date))=2007
		GROUP BY trunc_month,full_name) f3
		GROUP BY full_name
		ORDER BY sum(customer_amount) DESC
		LIMIT 10)
ORDER BY full_name, trunc_month;

# ----------------------------------------
/* Query 6A - query used for question 6A*/
# ===================================
# ===================================
# Question 6A
# What is the difference across their monthly payments during 2007 for each of the top10 paying customers? 
WITH top_10_customers (order_month, full_name,pay_count, customer_amount) 
AS 
(
	SELECT f2.trunc_month, 
			full_name, 
			f2.pay_countpermon, 
			f2.customer_amount
	FROM
		(SELECT f1.full_name AS full_name,
				sum(customer_amount) OVER (PARTITION BY f1.full_name) AS sum_customer,
				f1.trunc_month,f1.pay_countpermon,f1.customer_amount
		FROM
			(SELECT
					date_trunc('month',p.payment_date) AS trunc_month,
					concat(c.first_name,' ',c.last_name) AS full_name,
					COUNT(c.first_name) AS pay_countpermon,
					SUM(p.amount) AS customer_amount
			FROM payment p 
			JOIN customer c
			ON c.customer_id = p.customer_id
			WHERE EXTRACT(YEAR FROM date_trunc('month',p.payment_date))=2007
			GROUP BY trunc_month,full_name) f1
		ORDER BY sum_customer DESC) f2
		WHERE full_name IN 
			(SELECT 
				full_name
			FROM
				(SELECT
					date_trunc('month',p.payment_date) AS trunc_month,
					concat(c.first_name,' ',c.last_name) AS full_name,
					COUNT(c.first_name) AS pay_countpermon,
					SUM(p.amount) AS customer_amount
				FROM payment p 
				JOIN customer c
				ON c.customer_id = p.customer_id
				WHERE EXTRACT(YEAR FROM date_trunc('month',p.payment_date))=2007
				GROUP BY trunc_month,full_name) f3
			GROUP BY full_name
			ORDER BY SUM(customer_amount) DESC
			LIMIT 10)
	ORDER BY full_name, trunc_month
)

SELECT full_name,
		order_month,
		MAX(monthly_payment_difference)
FROM
	(SELECT order_month,
			full_name,
			pay_count,
			customer_amount,
			(customer_amount-lag(customer_amount) over (partition by full_name)) AS monthly_payment_difference
	FROM top_10_customers) f4
WHERE monthly_payment_difference IS NOT NULL
GROUP BY full_name, order_month
ORDER BY 3 DESC;

# ----------------------------------------
/* Query 6B - query used for question 6B*/
# Question 6B
 # Who is the customer who paid the most difference in terms of payment?
WITH top_10_customers (order_month, full_name, pay_count, customer_amount) 
AS 
(
	SELECT f2.trunc_month, 
			full_name, 
			f2.pay_countpermon, 
			f2.customer_amount
	FROM
		(SELECT f1.full_name AS full_name,
				sum(customer_amount) OVER (PARTITION BY f1.full_name) AS sum_customer,
				f1.trunc_month,f1.pay_countpermon,f1.customer_amount
		FROM
			(SELECT
					date_trunc('month',p.payment_date) AS trunc_month,
					concat(c.first_name,' ',c.last_name) AS full_name,
					COUNT(c.first_name) AS pay_countpermon,
					SUM(p.amount) AS customer_amount
			FROM payment p 
			JOIN customer c
			ON c.customer_id = p.customer_id
			WHERE EXTRACT(YEAR FROM date_trunc('month',p.payment_date))=2007
			GROUP BY trunc_month,full_name) f1
		ORDER BY sum_customer DESC) f2
		WHERE full_name IN 
			(SELECT 
				full_name
			FROM
				(SELECT
					date_trunc('month',p.payment_date) AS trunc_month,
					concat(c.first_name,' ',c.last_name) AS full_name,
					COUNT(c.first_name) AS pay_countpermon,
					SUM(p.amount) AS customer_amount
				FROM payment p 
				JOIN customer c
				ON c.customer_id = p.customer_id
				WHERE EXTRACT(YEAR FROM date_trunc('month',p.payment_date))=2007
				GROUP BY trunc_month,full_name) f3
			GROUP BY full_name
			ORDER BY SUM(customer_amount) DESC
			LIMIT 10)
	ORDER BY full_name, trunc_month
)

SELECT full_name,
		order_month,
		MAX(monthly_payment_difference)
FROM
	(SELECT order_month,
			full_name,
			pay_count,
			customer_amount,
			(customer_amount-lag(customer_amount) over (partition by full_name)) AS monthly_payment_difference
	FROM top_10_customers) f4
WHERE monthly_payment_difference IS NOT NULL
GROUP BY full_name, order_month
ORDER BY 3 DESC
LIMIT 1;