-- q1
select store,manager
from sales_by_store
order by total_sales desc
limit 1;


-- q2
select category
from sales_by_film_category
order by total_sales desc
limit 3;


-- q3
select title
from film
order by length
limit 5;


-- q4
select first_name, last_name
from staff
where picture is NULL;


-- q5
SELECT
 EXTRACT(YEAR FROM payment_date) AS year,
 EXTRACT(MONTH FROM payment_date) AS mon,
 SUM(amount) as rev
FROM payment
GROUP BY year, mon
ORDER BY year, mon;


----q6
SELECT
DATE(payment_date) AS dt,
SUM(amount)
FROM payment
WHERE EXTRACT(MONTH FROM payment_date) = '6'
AND EXTRACT(YEAR FROM payment_date) = '2020'
GROUP BY dt
ORDER BY dt;


--q7
SELECT
    EXTRACT(YEAR from rental_date) as year,
    EXTRACT(MONTH from rental_date) as mon,
    COUNT (DISTINCT customer_id) as uu_cnt
FROM rental
GROUP BY year, mon
ORDER BY year, mon;


--q8
SELECT
    EXTRACT(YEAR from payment_date) as year,
    EXTRACT(MONTH from payment_date) as mon,
    SUM(amount)/COUNT(DISTINCT customer_id) as avg_spend
FROM payment
GROUP BY year, mon
ORDER BY year, mon;


--q9
SELECT
    year, mon,
    COUNT(DISTINCT customer_id) as num_hp_customers
FROM (
    SELECT
     EXTRACT(YEAR from payment_date) as year,
     EXTRACT(MONTH from payment_date) as mon,
     customer_id,
     SUM(amount) total
    FROM payment
    GROUP BY year,mon, customer_id
    ) X
WHERE total > 20
GROUP BY year, mon;

-- q10
SELECT min(total) as min_spend,
    max(total) as max_spend
FROM (
     SELECT
            SUM(amount) as total
     FROM payment
     WHERE EXTRACT(MONTH FROM payment_date) ='6' AND EXTRACT(YEAR FROM payment_date) = '2020'
     GROUP BY customer_id
         ) S;

-- q10 alternate solution
WITH cust_tot_amt AS (
    SELECT
        customer_id,
        SUM(amount) AS tot_amt
    FROM payment
    WHERE DATE(payment_date) >= '2007-02-01'
    AND DATE(payment_date) <= '2007-02-28'
    GROUP BY customer_id
)
SELECT
    MIN(tot_amt) AS min_spend,
    MAX(tot_amt) AS max_spend
FROM cust_tot_amt;


-- q11
SELECT last_name, count(*)
FROM actor
WHERE UPPER(last_name) IN ('DAVIS','BRODY','ALLEN','BERRY')
GROUP BY last_name;


-- q12
SELECT last_name, count(*)
FROM actor
WHERE last_name LIKE '%en' or last_name LIKE '%ry'
GROUP BY last_name;


-- q13
WITH actor_cat AS (
    SELECT
        CASE
         WHEN first_name LIKE 'A%' THEN 'a_actors'
         WHEN first_name LIKE 'B%' THEN 'b_actors'
         WHEN first_name LIKE 'C%' THEN 'c_actors'
         ELSE 'other_actors'
        END AS actor_category
    FROM actor)
SELECT actor_category, count(*)
FROM actor_cat
GROUP BY actor_category;


-- q13 better solution
SELECT
    CASE
     WHEN first_name LIKE 'A%' THEN 'a_actors'
     WHEN first_name LIKE 'B%' THEN 'b_actors'
     WHEN first_name LIKE 'C%' THEN 'c_actors'
     ELSE 'other_actors'
    END AS actor_category,
    COUNT(*)
FROM actor
GROUP BY actor_category;


-- q14
WITH daily_rentals AS (
    SELECT DATE(rental_date) AS date, COUNT(*) AS count
    FROM rental
    WHERE DATE(rental_date) >= '2005-05-01' AND DATE(rental_date) <= '2005-05-31'
    GROUP BY date
)
SELECT
    SUM(CASE WHEN count > 100 THEN 1
        ELSE 0
        END) AS good_days,
    31 - SUM(CASE WHEN count > 100 THEN 1
        ELSE 0
        END) AS bad_days
FROM daily_rentals;


-- q15
WITH customer_watcher_category AS (
SELECT customer_id,
    CASE WHEN AVG(ROUND(DATE_PART('day',return_date-rental_date))+1) > 5 THEN 'slow_watcher'
        ELSE 'fast_watcher'
    END AS watcher_category
FROM rental
WHERE return_date IS NOT NULL
GROUP BY customer_id)
SELECT watcher_category, count(*)
FROM customer_watcher_category
GROUP BY watcher_category;


-- q16
SELECT S.first_name, S.last_name
FROM staff S INNER JOIN address A
ON S.address_id = A.address_id
INNER JOIN city C ON A.city_id = C.city_id
WHERE C.city = 'Woodridge';


-- q17
SELECT actor_id
FROM actor
WHERE first_name = 'Groucho' AND last_name = 'Williams';


-- q18
SELECT category_id, COUNT(*) AS film_cnt
FROM category
GROUP BY category_id
ORDER BY film_cnt DESC
LIMIT 1;


-- q19
SELECT A.first_name, A.last_name
FROM actor A INNER JOIN film_actor FA
ON A.actor_id = FA.actor_id
GROUP BY A.actor_id
ORDER BY COUNT(FA.film_id) DESC
LIMIT 1;


-- q20 customer who spent the most
SELECT C.first_name, C.last_name
FROM customer C INNER JOIN payment P
ON P.customer_id = C.customer_id
WHERE DATE(P.payment_date) >= '2007-02-01' AND DATE(P.payment_date) <= '2007-02-28'
GROUP BY C.customer_id
ORDER BY SUM(P.amount) DESC
LIMIT 1;


-- q21 customer who rented the most
SELECT C.first_name, C.last_name --, count(*), C.customer_id
FROM customer C INNER JOIN rental r on C.customer_id = R.customer_id
WHERE DATE(R.rental_date) >='2005-05-01' AND DATE(R.rental_date) <= '2005-05-31'
GROUP BY C.customer_id
ORDER BY count(*) DESC
LIMIT 1;


-- q22
SELECT AVG(amount)
FROM payment
WHERE DATE(payment_date) >=' 2007-02-01' AND DATE(payment_date) <= '2007-02-28';


-- q23
WITH cust_avg_spend AS (
    SELECT customer_id, SUM(amount) total_spend
    FROM payment
    WHERE DATE(payment_date) >= '2007-02-01' AND DATE(payment_date) <= '2007-02-28'
    GROUP BY customer_id)
SELECT AVG(total_spend)
FROM cust_avg_spend;


-- q24
SELECT  f.title
FROM film f INNER JOIN film_actor fa on f.film_id = fa.film_id
GROUP BY f.film_id
HAVING COUNT(actor_id) >= 10;


-- q25
SELECT title
FROM film
ORDER BY length
LIMIT 1;


-- q26  ambiguous
SELECT title, length
FROM film
ORDER BY length
LIMIT 1 OFFSET 1;


-- q27
WITH actor_count_per_film AS (
    SELECT film_id
    FROM film_actor
    GROUP BY film_id
    ORDER BY count(*) DESC
    LIMIT 1)
SELECT title
FROM film
WHERE film_id = (SELECT film_id from actor_count_per_film);


-- q28
WITH actor_count_per_film AS (
    SELECT film_id
    FROM film_actor
    GROUP BY film_id
    ORDER BY count(*) DESC
    LIMIT 1 OFFSET 1)
SELECT title
FROM film
WHERE film_id = (SELECT film_id from actor_count_per_film);


-- select film_id, count(*)
-- from film_actor
-- group by film_id
-- order by count(*) desc;


-- q29 second highest spend customer
SELECT C.first_name, C.last_name --, SUM(P.amount)
FROM customer C INNER JOIN payment P
ON P.customer_id = C.customer_id
WHERE DATE(P.payment_date) >= '2007-02-01' AND DATE(P.payment_date) <= '2007-02-28'
GROUP BY C.customer_id
ORDER BY SUM(P.amount) DESC
LIMIT 1 OFFSET 1;

-- q30 inactive customers in may
SELECT COUNT (*)
FROM customer
WHERE customer_id NOT IN (
    SELECT customer_id
    FROM rental
    WHERE DATE(rental_date) >= '2020-05-01'
    AND DATE(rental_date) <= '2020-05-31'
    );

-- q31 movies that have not been returned
SELECT f.title
FROM rental r INNER JOIN inventory i on r.inventory_id = i.inventory_id
INNER JOIN film f on f.film_id = i.film_id
WHERE r.return_date IS NULL
GROUP BY f.film_id;

-- q32 flims with no rentals in Feb 2020 -- ambiguous
WITH unpopular_film_ids AS (
    SELECT DISTINCT film_id
    FROM inventory
    WHERE inventory_id NOT IN (
    SELECT inventory_id
    FROM rental
    WHERE DATE(rental_date) >='2020-02-01' AND DATE(rental_date) <= '2020-02-29'
    )
)
SELECT title
FROM film
WHERE film_id in (SELECT film_id FROM unpopular_film_ids);

WITH rented_film AS (
SELECT DISTINCT film_id
FROM inventory
WHERE inventory_id IN(
SELECT inventory_id
FROM rental
WHERE DATE(rental_date) >= '2020-02-01'
AND DATE(rental_date) <= '2020-02-29'
))
SELECT title
FROM film
WHERE film_id NOT IN(
 SELECT film_id
 FROM rented_film
);

-- q33 customers who rented in both may and june 2020
WITH common_customers AS (
    SELECT customer_id
    FROM rental
    WHERE date(rental_date) >= '2020-05-01' AND date(rental_date) <= '2020-05-31'
    INTERSECT
    SELECT customer_id
    FROM rental
    WHERE date(rental_date) >= '2020-06-01' AND date(rental_date) <= '2020-06-30'
)
SELECT count(distinct(customer_id))
FROM common_customers;

-- q34 stocked up movies
SELECT title
FROM film
WHERE film_id in (
    SELECT film_id
    FROM inventory
    GROUP BY film_id
    HAVING count(*) > 7
    );

-- q35 film length report
SELECT CASE
            WHEN length >= 100 THEN 'long'
            WHEN length <60 THEN 'short'
            ELSE 'medium'
        END AS film_category,
    COUNT(*)
FROM film
GROUP BY film_category;


-------------MULTI-TABLE OPERATIONS-------------

-- q36 actors from film AFRICAN EGG
SELECT first_name, last_name
FROM actor a INNER JOIN film_actor fa on a.actor_id = fa.actor_id
INNER JOIN film f on fa.film_id = f.film_id
WHERE f.title = 'African Egg';

-- q37 most popular movie category
SELECT c.name --, count(*)
FROM category c INNER JOIN film_category fc
ON c.category_id = fc.category_id
GROUP BY c.name
ORDER BY count(*) DESC
LIMIT 1;

-- q38 most popular movie category(name and id)
SELECT c.category_id, MAX(c.name) AS name --, count(*)
FROM category c INNER JOIN film_category fc
ON c.category_id = fc.category_id
GROUP BY c.category_id
ORDER BY count(*) DESC
LIMIT 1;

-- q39 Most productive actor with inner join
SELECT a.actor_id, a.first_name, a.last_name
FROM actor a INNER JOIN film_actor fa
ON a.actor_id = fa.actor_id
GROUP BY a.actor_id
ORDER BY count(*) DESC
LIMIT 1;

-- q40 Top 5 most rented movie in June 2020
SELECT f.film_id, MAX(f.title) AS title--, count(*)
FROM film f INNER JOIN inventory i on f.film_id = i.film_id
INNER JOIN rental r on i.inventory_id = r.inventory_id
WHERE DATE(rental_date) >= '2005-08-01' AND DATE(rental_date) <= '2005-08-31'
GROUP BY f.film_id
ORDER BY count(*) DESC
LIMIT 5;

-- q41 productive actors vs less productive actors
WITH CTE as (
    SELECT a.actor_id, count(*) as count
    FROM actor a inner join film_actor fa on a.actor_id = fa.actor_id
    GROUP BY a.actor_id
)
SELECT CASE
    WHEN count >= 30 THEN 'productive'
    ELSE 'less-productive'
    END AS actor_category, Count(*)
    FROM CTE
    GROUP BY actor_category;
-- alternate solution
SELECT actor_category,
 COUNT(*)
FROM (
    SELECT
        A.actor_id,
        CASE
            WHEN COUNT(DISTINCT FA.film_id) >= 30 THEN 'productive'
            ELSE 'less productive'
        END AS actor_category
    FROM actor A
    LEFT JOIN film_actor FA
    ON FA.actor_id = A.actor_id
    GROUP BY A.actor_id
) X
GROUP BY actor_category;

-- q42 films in stock vs not in stock
WITH CTE AS (
    SELECT f.film_id, Count(inventory_id) AS stock
    FROM film f left join inventory i on f.film_id = i.film_id
    GROUP BY f.film_id
)
SELECT
    CASE
        WHEN stock > 0 THEN 'in stock'
        ELSE 'not in stock'
    END AS in_stock, COUNT(*)
FROM CTE
GROUP BY in_stock;

-- better solution
SELECT in_stock, COUNT(*)
FROM (
SELECT
F.film_id,
MAX(CASE WHEN I.inventory_id IS NULL THEN 'not in stock' ELSE 'in
stock' END) in_stock
FROM film F
LEFT JOIN INVENTORY I
ON F.film_id =I.film_id
GROUP BY F.film_id
) X
GROUP BY in_stock;

-- q43 Customers who rented vs. those who did not
SELECT has_rented, COUNT(*)
FROM (
    SELECT c.customer_id,
           (CASE WHEN r.customer_id IS NULL THEN 'never-rented'
               ELSE 'rented' END) AS has_rented
    FROM customer c LEFT JOIN rental r on c.customer_id = r.customer_id
    WHERE DATE(r.rental_date) >= '2005-07-01' AND DATE(r.rental_date) <= '2005-07-31'
    GROUP BY c.customer_id
         ) X
GROUP BY has_rented;

SELECT have_rented, COUNT(*)
FROM (
SELECT
 C.customer_id,
 CASE WHEN R.customer_id IS NOT NULL THEN 'rented' ELSE 'neverrented' END AS have_rented
FROM customer C
LEFT JOIN (
 SELECT DISTINCT customer_id
FROM rental
 WHERE DATE(rental_date) >= '2005-07-01'
 AND DATE(rental_date) <= '2005-07-31'
 ) R
ON R.customer_id = C.customer_id
) X
GROUP BY have_rented;

-- q44 In-demand vs not-in-demand movies
SELECT demand_category, Count(*)
FROM (
SELECT f.film_id, CASE
                    WHEN Count(r.rental_id) > 1 THEN 'in-demand'
                    ELSE 'not-in-demand'
                END AS demand_category
FROM film f LEFT JOIN inventory i on f.film_id = i.film_id
LEFT JOIN
    (
    SELECT rental_id, inventory_id
    FROM rental
    WHERE DATE(rental_date) >= '2005-05-01' AND DATE(rental_date) <= '2005-05-31'
    ) r
on i.inventory_id = r.inventory_id
GROUP BY f.film_id) X
GROUP BY demand_category;

-- q45 movie inventory optimization

-- select i2.inventory_id
-- from inventory i2 inner join film f2 on i2.film_id = f2.film_id
-- where f2.film_id not in
SELECT COUNT(inventory_id)
from inventory
where film_id not in
(
select f.film_id
from film f inner join inventory i
on f.film_id = i.film_id
inner join rental r on r.inventory_id = i.inventory_id
where DATE(rental_date) >= '2005-05-01' AND DATE(rental_date) <= '2005-05-31');

-- q46 actors and customers whose last name starts with 'A'
SELECT first_name, last_name
FROM actor
WHERE last_name LIKE 'A%'
UNION
SELECT first_name,last_name
FROM customer
WHERE last_name LIKE 'A%';


-- q47 Actors and customers whose first names end in 'D'
SELECT actor_id as id, first_name, last_name
FROM actor
WHERE first_name LIKE '%d'
UNION
SELECT customer_id as id, first_name,last_name
FROM customer
WHERE first_name LIKE '%d';


-- q48 Movie and TV actors
-- SELECT m.actor_id, m.first_name, m.last_name
-- FROM actor_movie m INNER JOIN actor_tv t
-- ON m.actor_id = t.actor_id;


-- q49 top 3 money making movie categories
SELECT c.name as category, sum(p.amount) as revenue
FROM rental r INNER JOIN inventory i on r.inventory_id = i.inventory_id
INNER JOIN payment p on r.rental_id = p.rental_id
INNER JOIN film f on i.film_id = f.film_id
INNER JOIN film_category fc on f.film_id = fc.film_id
INNER JOIN category c on fc.category_id = c.category_id
GROUP BY category
ORDER BY revenue DESC
LIMIT 3;

-- q50 top 5 cities for movie rentals
SELECT city, SUM(amount) as revenue
FROM payment p
INNER JOIN customer c on p.customer_id = c.customer_id
INNER JOIN address a on c.address_id = a.address_id
INNER JOIN city ct on a.city_id = ct.city_id
WHERE EXTRACT(YEAR FROM payment_date) = '2007'
GROUP BY city
ORDER BY revenue DESC
LIMIT 5;

-- q51 movie only actor
-- SELECT m.first_name, m.last_name
-- FROM actor_movie m LEFT JOIN actor_tv t
-- ON m.actor_id = t.actor_id
-- WHERE  t.actor_id IS NULL;

-- q52 movies cast by movie only actors
-- SELECT f.film_id
-- FROM Film f
-- LEFT JOIN (
--     SELECT DISTINCT fa.film_id
--     FROM film_actor fa
--     INNER JOIN actor_tv t
--     ON t.actor_id = fa.actor_id
--     ) X
-- ON f.film_id = X.film_id
-- WHERE X.film_id IS NULL;

-- q53 movie groups by rental income
WITH CTE AS (
SELECT f.film_id,
       CASE
            WHEN SUM(p.amount)  >= 100 THEN 'high'
            WHEN SUM(p.amount)  >= 20 THEN 'medium'
            ELSE 'low'
       END AS film_group
FROM film f LEFT JOIN inventory i on f.film_id = i.film_id
LEFT JOIN rental r on i.inventory_id = r.inventory_id
LEFT JOIN payment p on r.rental_id = p.rental_id
GROUP BY f.film_id)
SELECT film_group, COUNT(*)
FROM CTE
GROUP BY film_group;

-- q54 customer groups by movie rental spends
SELECT customer_group, COUNT(*)
FROM
(SELECT c.customer_id,
       CASE
           WHEN SUM(p.amount) >= 150 THEN 'high'
           WHEN SUM(p.amount) >= 100 THEN 'medium'
           ELSE 'low'
       END AS customer_group
FROM customer c LEFT JOIN payment p on c.customer_id = p.customer_id
GROUP BY c.customer_id) S
GROUP BY customer_group;

-- q55 Busy days and slow days
SELECT date_category, COUNT(*)
FROM (
SELECT DATE(rental_date) AS date,
       CASE
           WHEN COUNT(rental_id) >= 100 THEN 'busy'
           ELSE 'slow'
       END AS date_category
FROM rental
WHERE EXTRACT(YEAR FROM rental_date) = '2005' AND EXTRACT(MONTH FROM rental_date) = '5'
GROUP BY date) S
GROUP BY date_category;

-- q56 total number of actors
-- SELECT COUNT(*)
-- FROM (
--      SELECT COALESCE(m.actor_id, t.actor_id)
--      FROM actor_movie m FULL OUTER JOIN actor_tv t
--      ON m.actor_id = t.actor_id
--          ) S;

-- q57 total number of actors with UNION
-- SELECT COUNT(*)
-- FROM (
--   SELECT actor_id
--   FROM actor_tv
--   UNION
--   SELECT actor_id
--   FROM actor_movie
-- ) S;

SELECT
 title,
 rating,
 replacement_cost,
 AVG(replacement_cost) OVER(PARTITION BY rating) AS avg_cost
FROM film;

-- q58 percentage of revenue per movie
select film_id,
       revenue * 100/SUM(revenue) OVER() as revenue_percentage
from (
    select i.film_id, sum(p.amount) as revenue
    from rental inner join inventory i on i.inventory_id = rental.inventory_id
    inner join payment p on rental.rental_id = p.rental_id
    group by i.film_id) S
order by film_id
LIMIT 10;


-- q59 percentage of revenue per movie category
select film_id, category_name,
       revenue * 100 / SUM(revenue) OVER(partition by category_name) as revenue_percent_category
from
(select i.film_id, MAX(c.name) category_name, SUM(p.amount) revenue
from payment p inner join rental r on p.rental_id = r.rental_id
inner join inventory i on r.inventory_id = i.inventory_id
inner join film f on f.film_id = i.film_id
inner join film_category fc on fc.film_id = f.film_id
inner join category c on fc.category_id = c.category_id
group by 1) S
ORDER BY film_id
LIMIT 10;


-- q60 movie rentals and average rentals in same category
WITH movie_rentals_category AS (
    select i.film_id, count(i.inventory_id) rentals
    from rental r inner join inventory i on i.inventory_id = r.inventory_id
    group by i.film_id)
select mrc.film_id, c.name as category_name, rentals,
       AVG(rentals) OVER(PARTITION BY c.name) as avg_rentals_category
from movie_rentals_category mrc inner join film_category fc on mrc.film_id = fc.film_id
inner join category c on fc.category_id = c.category_id
order by film_id
limit 10;


-- q61 customer spend vs average spend in same store
with customer_spendings_store as (
    select c.customer_id, max(store_id) store_id, sum(amount) as ltd_spend
    from payment p inner join customer c  on c.customer_id = p.customer_id
    group by c.customer_id)
select customer_id, store_id, ltd_spend, avg
from (
select customer_id, store_id, ltd_spend,
    avg(ltd_spend) over(partition by store_id) as avg
from customer_spendings_store) S
where customer_id in (1, 100, 101, 200, 201, 300, 301, 400, 401, 500)
order by 1;

-- q62 shortest film by category
select film_id, title, length, category, row_num
from
(select f.film_id, f.title, f.length, c.name as category,
       ROW_NUMBER() OVER(PARTITION BY c.name ORDER BY f.length) as row_num
from film f inner join film_category fc on f.film_id = fc.film_id
inner join category c on fc.category_id = c.category_id) S
where row_num = 1;

-- q63 top 5 customers by store
select store_id, customer_id, revenue, ranking
from
(select Max(store_id) as store_id, c.customer_id, sum(amount) as revenue,
    dense_rank() over(partition by store_id order by sum(amount) desc) as ranking
from payment p inner join customer c on c.customer_id = p.customer_id
group by c.customer_id) S
where ranking <= 5;

-- q64 top2 films by category
with film_revenue as (
    select i.film_id, sum(p.amount) as revenue
    from payment p inner join rental r on r.rental_id = p.rental_id
    inner join inventory i on r.inventory_id = i.inventory_id
    group by i.film_id)
select category, film_id, revenue, row_num
from (
     select fr.film_id, revenue, c.name as category,
            row_number() over (partition by c.name order by revenue desc) as row_num
     from film_revenue fr inner join film_category fc on fr.film_id = fc.film_id
     inner join category c on fc.category_id = c.category_id
         ) S
where row_num <= 2;


-- q65 movie revenue percentiles
with film_revenues as (
    select film_id, sum(amount) as revenue
    from payment p inner join rental r on p.rental_id = r.rental_id
    inner join inventory i on r.inventory_id = i.inventory_id
    group by film_id )
select * from (
select film_id, revenue,
    ntile(100) over(order by revenue desc) as percentile
from film_revenues ) S
where film_id in (1,10,11,20,21,30);


-- q66 movie percentiles by revenue by category
with film_revenues as (
    select film_id, sum(amount) as revenue
    from payment p inner join rental r on p.rental_id = r.rental_id
    inner join inventory i on r.inventory_id = i.inventory_id
    group by film_id )
select * from (
    select c.name as category,
           fr.film_id,
           revenue,
           ntile(100) over(partition by c.name order by revenue desc) as percentile
    from film_revenues fr inner join film_category fc on fr.film_id = fc.film_id
    inner join category c on fc.category_id = c.category_id
                  ) I
where film_id <= 20
order by film_id;


-- q67 quartile by number of rentals
with film_rental_counts as (
    select i.film_id, count(*) as num_rentals,
            ntile(4) over(order by count(*) desc) as quartile
    from rental r inner join inventory i on r.inventory_id = i.inventory_id
    group by i.film_id
)
select *
from film_rental_counts
where film_id in (1, 10, 11, 20, 21, 30);

-- q68 spend difference between first and second rentals
with customer_spending as (
    select customer_id, amount current,
           lag(amount,1) over (partition by customer_id order by payment_date) prev,
           row_number() over (partition by customer_id order by payment_date) row_num
    from payment
)
select customer_id, prev-current as delta
from customer_spending
where row_num = 2
and customer_id in (1,2,3,4,5,6,7,8,9,10);


-- q69 number of happy customers
with cte as (
select customer_id, Date(rental_date) as current,
    Date(lead(rental_date, 1) over(partition by customer_id order by rental_id)) as next
from rental
    )
select Count(distinct customer_id)
from
(select customer_id,
       case when date(next)-date(current) = 1 then 'YES'
        else 'NO' end as temp
from cte
where date(current) >= '2005-05-24' and date(current) <= '2005-05-31') S
where temp = 'YES';


-- q70 cumulative spend
with customer_spends_by_date as (
select date(payment_date) date, customer_id, Sum(amount) spends
from payment
where customer_id in (1, 2, 3)
group by date, customer_id)
select date, customer_id, spends as daily_spend,
       sum(spends) over(partition by customer_id order by date) as cumulative_spend
from customer_spends_by_date;


-- q71 cumulative rentals
with customer_rentals_by_date as (
    select date(rental_date) date, customer_id, COUNT(rental_id) as daily_rental
    from rental
    where customer_id in (3,4,5)
    group by date, customer_id
)
select date, customer_id, daily_rental,
       sum(daily_rental) over(partition by customer_id order by date)
from customer_rentals_by_date;


-- q72 days when they became happy customers
select customer_id, date
from (
    select customer_id, date(rental_date) date,
           row_number() over(partition by customer_id order by rental_date) row_num
    from rental
    where customer_id in (1,2,3,4,5,6,7,8,9,10)
    ) S
where row_num = 10;


-- q73 number of days to become happy customer
with cte as (
    select customer_id, (rental_date) as date,
           row_number() over (partition by customer_id order by rental_date) row_num
    from rental
)
select round(avg(delta)) from (
select row_num,customer_id,
        extract(days from lead(date, 9) over(partition by customer_id order by row_num) - date) as delta
from cte) S
where row_num = 1;

--alternate solution --lower cost
with cte as (
    select customer_id, (rental_date) as date,
           row_number() over (partition by customer_id order by rental_date) row_num
    from rental
)
select round(avg(delta))
from (
select c1.customer_id, extract(days from (c2.date - c1.date)) as delta
from cte c1 inner join cte c2
on c1.customer_id = c2.customer_id
and c1.row_num = 1 and c2.row_num = 10) S ;

-- text book solution
WITH cust_rental_ts AS (
    SELECT
    customer_id,
    rental_date,
    ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY rental_date)
    rental_idx
    FROM rental
)
SELECT ROUND(AVG(delta)) AS avg_days
FROM (
    SELECT
    customer_id,
    first_rental_ts,
    tenth_rental_ts,
    EXTRACT(DAYS FROM tenth_rental_ts - first_rental_ts) AS delta
    FROM (
        SELECT
        customer_id,
        MAX(CASE WHEN rental_idx = 1 THEN rental_date ELSE NULL END) AS
        first_rental_ts,
        MAX(CASE WHEN rental_idx = 10 THEN rental_date ELSE NULL END) AS
        tenth_rental_ts
        FROM cust_rental_ts
        GROUP BY customer_id
        ) X
    WHERE tenth_rental_ts IS NOT NULL
)Y;


-- q74 most productive actor by category
select category_id, actor_id, num_movies
from (
select fc.category_id, a.actor_id,
       count(*) num_movies,
       row_number() over(partition by category_id order by count(*) desc) row_num
from actor a inner join film_actor fa on a.actor_id = fa.actor_id
inner join film_category fc on fa.film_id = fc.film_id
group by category_id, a.actor_id) S
where row_num = 1;


-- q75 top customers by movie category
WITH cust_revenue_by_cat AS (
    SELECT
    P.customer_id,
    FC.category_id,
    SUM(P.amount) AS revenue
    FROM payment P
    INNER JOIN rental R
    ON R.rental_id = P.rental_id
    INNER JOIN inventory I
    ON I.inventory_id = R.inventory_id
    INNER JOIN film F
    ON F.film_id = I.film_id
    INNER JOIN film_category FC
    ON FC.film_id = F.film_id
    GROUP BY P.customer_id, FC.category_id
)
select category_id, customer_id
from (
    select category_id, customer_id,
            row_number() over (partition by category_id order by revenue desc) as row_num
    from cust_revenue_by_cat) S
where row_num = 1;


-- q76 districts with the most and least customers
with cte as
(select district, count(*) count
from customer c inner join address a on c.address_id = a.address_id
group by district)

(select district, 'most' as cat
from cte
order by count desc
limit 1)
union
(select district, 'least' as cat
from cte
order by count
limit 1);


-- q77 movie revenue percentiles by category
WITH movie_rev_by_cat AS (
    SELECT
    F.film_id,
    MAX(FC.category_id) AS category_id,
    SUM(P.amount) AS revenue
    FROM film F
    INNER JOIN inventory I
    ON I.film_id = F.film_id
    INNER JOIN rental R
    ON R.inventory_id = I.inventory_id
    INNER JOIN payment P
    ON P.rental_id = R.rental_id
    INNER JOIN film_category FC
    ON FC.film_id = F.film_id
    GROUP BY F.film_id
)
select * from (
select film_id,
    ntile(100) over(partition by category_id order by revenue) perc_by_cat
from movie_rev_by_cat) S
where film_id in (1,2,3,4,5);


-- q78 quartile buckets by number of rentals
WITH cust_rentals AS (
    SELECT C.customer_id,
    MAX(C.store_id) AS store_id, -- one customer can only belong to one store
    COUNT(*) AS num_rentals FROM
    rental R
    INNER JOIN customer C
    ON C.customer_id = R.customer_id
    GROUP BY C.customer_id
)
select * from (
select customer_id, store_id,
       ntile(4) over(partition by store_id order by num_rentals) quartile
from cust_rentals) S
where customer_id in (1,2,3,4,5,6,7,8,9,10);


-- q79 spend difference between the last and the second last rentals
with cte as
(
    select customer_id, amount,
       row_number() over (partition by customer_id order by payment_date desc) row_num
from payment )
select customer_id, last-second_last as delta
from (
select customer_id,
       MAX(CASE WHEN row_num = 1 THEN amount END) as last,
       MAX(CASE WHEN row_num = 2 THEN amount END) as second_last
from cte
group by customer_id) S
where second_last is NOT NULL and
customer_id in (1,2,3,4,5,6,7,8,9,10);
-- text book solution
WITH cust_spend_seq AS (
SELECT
 customer_id,
 payment_date,
 amount AS current_payment,
 LAG(amount, 1) OVER(PARTITION BY customer_id ORDER BY payment_date) AS
prev_payment,
 ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY payment_date DESC)
AS payment_idx
FROM payment P
)
SELECT
 customer_id,
 current_payment - prev_payment AS delta
FROM cust_spend_seq
WHERE customer_id IN(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
AND payment_idx = 1;


-- q80 DoD revenue growth for each store
WITH store_daily_rev AS (
 SELECT
 I.store_id,
 DATE(P.payment_date) date,
 SUM(amount) AS daily_rev
 FROM
 payment P
 INNER JOIN rental R
 ON R.rental_id = P.rental_id
 INNER JOIN inventory I
 ON I.inventory_id = R.inventory_id
 WHERE DATE(P.payment_date) >= '2007-04-27'
 AND DATE(P.payment_date) <= '2007-04-30'
 GROUP BY I.store_id, DATE(P.payment_date)
)
select store_id, date,
       lag(daily_rev, 1) over(partition by store_id order by date) prev,
       daily_rev current,
       ROUND((daily_rev / lag(daily_rev, 1) over(partition by store_id order by date) - 1) * 100) dod_growth
from store_daily_rev;