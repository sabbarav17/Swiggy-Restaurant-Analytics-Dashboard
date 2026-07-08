--Dataset Profiling Report

--Total Records
select count(*) as total_records from swiggy_data

--Total Columns
SELECT COUNT(*) AS total_columns
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'swiggy_data';

--Total States
select distinct state from swiggy_data
select count(distinct state) as total_states from swiggy_data

--Total Cities
select distinct city from swiggy_data
select count(distinct city) as total_city from swiggy_data

--Total Restaurants
select  restaurant_name from swiggy_data
select distinct restaurant_name from swiggy_data
select count(distinct restaurant_name) as total_restuarants from swiggy_data

--Total Categories
select  category from swiggy_data
select distinct category from swiggy_data
select count(distinct category) as total_category from swiggy_data

--Total Dishes
select  dish_name from swiggy_data
select distinct dish_name from swiggy_data
select count(distinct dish_name) as total_dishes from swiggy_data

--Date Range
select min(order_date) as first_order_date, max(order_date) as latest_order_date
from swiggy_data

---Data Quality Report

--Null values by column
select 
sum(case when state is null then 1 else 0 end) as state_nulls,
sum(case when city is null then 1 else 0 end) as city_nulls,
sum(case when order_date is null then 1 else 0 end) as order_date_nulls,
sum(case when restaurant_name is null then 1 else 0 end) as restaurant_name_nulls,
sum(case when location is null then 1 else 0 end) as location_nulls,
sum(case when category is null then 1 else 0 end) as category_nulls,
sum(case when dish_name is null then 1 else 0 end) as dish_name_nulls,
sum(case when price_inr is null then 1 else 0 end) as price_inr_nulls,
sum(case when rating is null then 1 else 0 end) as rating_nulls,
sum(case when rating_count is null then 1 else 0 end) as rating_count_nulls
from swiggy_data

--empty strings 
SELECT
    SUM(CASE WHEN TRIM(state) = '' THEN 1 ELSE 0 END) AS empty_state,
    SUM(CASE WHEN TRIM(city) = '' THEN 1 ELSE 0 END) AS empty_city,
    SUM(CASE WHEN TRIM(restaurant_name) = '' THEN 1 ELSE 0 END) AS empty_restaurant,
    SUM(CASE WHEN TRIM(location) = '' THEN 1 ELSE 0 END) AS empty_location,
    SUM(CASE WHEN TRIM(category) = '' THEN 1 ELSE 0 END) AS empty_category,
    SUM(CASE WHEN TRIM(dish_name) = '' THEN 1 ELSE 0 END) AS empty_dish_name
FROM swiggy_data;


--duplicate_records
SELECT
    state,
    city,
    order_date,
    restaurant_name,
    location,
    category,
    dish_name,
    price_inr,
    rating,
    rating_count,
    COUNT(*) AS duplicate_count
FROM swiggy_data
GROUP BY
    state,
    city,
    order_date,
    restaurant_name,
    location,
    category,
    dish_name,
    price_inr,
    rating,
    rating_count
HAVING COUNT(*) > 1;


--count of Duplicate records
WITH cte AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY state,
                            city,
                            order_date,
                            restaurant_name,
                            location,
                            category,
                            dish_name,
                            price_inr,
                            rating,
                            rating_count
               ORDER BY (SELECT NULL)
           ) AS rn
    FROM swiggy_data
)
SELECT COUNT(*) AS duplicate_rows
FROM cte
WHERE rn > 1;

--Invalid ratings
--Rating < 0 , Rating > 5

select count(*) as invalid_rating_count
from swiggy_data
where rating < 0 or rating > 5

--Invalid prices Price <= 0
select count(*) as invalid_price 
from swiggy_data
where price_inr <= 0;

--City name inconsistencies
select distinct city from swiggy_data;

--Check for case and space issues

SELECT
    UPPER(TRIM(city)) AS standardized_city,
    COUNT(*) AS records
FROM swiggy_data
GROUP BY UPPER(TRIM(city))
ORDER BY standardized_city;

--Find cities that appear in multiple formats
SELECT
    UPPER(TRIM(city)) AS standardized_city,
    COUNT(DISTINCT city) AS variations
FROM swiggy_data
GROUP BY UPPER(TRIM(city))
HAVING COUNT(DISTINCT city) > 1;

--State name inconsistencies
select distinct state from swiggy_data;

--Check for case and space issues
select 
     upper(trim(state)) as standardized_state,
     count(distinct state) as variations
from swiggy_data
group by upper(trim(state))
order by standardized_state

--Find cities that appear in multiple formats

select 
     upper(trim(state)) as standardized_state,
     count(distinct state) as variations
from swiggy_data
group by upper(trim(state))
having count(distinct state) > 1;

--Restaurant name inconsistencies

select 
     upper(trim(restaurant_name)) as standardized_restaurant_name,
     count(distinct restaurant_name) as variables
from swiggy_data
group by upper(trim(restaurant_name))
order by standardized_restaurant_name

--Find Restaurant name that appear in multiple formats
select 
     upper(trim(restaurant_name)) as standardized_restaurant_name,
     count(distinct restaurant_name) as variables
from swiggy_data
group by upper(trim(restaurant_name))
having  count(distinct restaurant_name) > 1;


--creating new table without duplicates
WITH cte AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY state,
                            city,
                            order_date,
                            restaurant_name,
                            location,
                            category,
                            dish_name,
                            price_inr,
                            rating,
                            rating_count
               ORDER BY (SELECT NULL)
           ) AS rn
    FROM swiggy_data
)
SELECT
    state,
    city,
    order_date,
    restaurant_name,
    location,
    category,
    dish_name,
    price_inr,
    rating,
    rating_count
INTO swiggy_data_cleaned
FROM cte
WHERE rn = 1;

SELECT COUNT(*) AS source_rows
FROM swiggy_data;

SELECT COUNT(*) AS cleaned_rows
FROM swiggy_data_cleaned;

---exploratory data analysys----



--city level summary--
-- top 5 performing cities based on total_rating_count

select top 5
     city,
     count(distinct restaurant_name) as total_restaurants,
     round(avg(rating),2) as avg_rating , 
     sum(rating_count) as total_rating_count,
     count(distinct dish_name) as no_of_dishes,
     count(distinct category) as no_of_categories
from swiggy_data_cleaned
group by city
order by total_rating_count desc ;

-- Which restaurants are the strongest performers
-- Restaurant Performance Analysis
select top 10 
     city,
     restaurant_name,
     round(avg(rating),2) as avg_rating , 
     sum(rating_count) as total_rating_count,
     count(distinct dish_name) as no_of_dishes,
     count(distinct category) as no_of_categories
from swiggy_data_cleaned
group by city, restaurant_name
order by total_rating_count desc ;

--Which food categories perform best across the platform
--
select * from swiggy_data

select top 10
     category,
     round(avg(rating),2) as avg_rating,
     sum(rating_count) as total_rating_count,
     count(distinct restaurant_name) as total_restaurants,
     count(distinct dish_name) as no_of_dishes,
     round(avg(price_inr),2) as avg_price,
     count(distinct city) as no_of_cities
from swiggy_data_cleaned
group by category
having sum(rating_count) >= 1000
ORDER BY total_rating_count DESC;

-- dishes

select top 10
     dish_name,
     round(avg(rating),2) as avg_rating,
     sum(rating_count) as total_rating_count,
     count(distinct restaurant_name) as total_restaurants,
     round(avg(price_inr),2) as avg_price,
     count(distinct city) as no_of_cities
from swiggy_data_cleaned
group by dish_name
order by total_rating_count desc

--Restaurant Performance Score

select 
      restaurant_name,
      round(avg(rating),2) as avg_rating,
      sum(rating_count) as total_rating_count,
      count(distinct dish_name) as no_of_dishes
from swiggy_data_cleaned
group by restaurant_name
order by total_rating_count desc;

--Restaurant Metrics CTE

with restaurant_metrics as
( 
    select 
         restaurant_name,
         round(avg(rating),2) as avg_rating,
         sum(rating_count) as total_rating,
         count(distinct dish_name) as no_of_dishes
    from swiggy_data_cleaned
    group by restaurant_name
),
restaurant_stats as
(
        select *,
              min(avg_rating) over() as min_rating,
              max(avg_rating) over() as max_rating,

              min(total_rating) over() as min_total_rating,
              max(total_rating) over() as max_total_rating,

              min(no_of_dishes) over() as min_dishes,
              max(no_of_dishes) over() as max_dishes
        from restaurant_metrics
        --order by total_rating desc
),
restaurant_scores as
(
select *,
      (avg_rating - min_rating) * 100.0 / (max_rating - min_rating) as rating_score,
      (total_rating - min_total_rating) * 100.0 / (max_total_rating - min_total_rating) as total_rating_score,
      (no_of_dishes - min_dishes) * 100.0 / (max_dishes - min_dishes) as dish_score
from restaurant_stats
)

select *,
       (
        0.40 * rating_score
        +
        0.40 * total_rating_score
        +
        0.20 * dish_score
    ) AS restaurant_performance_score
FROM restaurant_scores
ORDER BY restaurant_performance_score DESC;

--city performance score
 
 with city_metrics as
 (
             select
                  city,
                  round(avg(rating),2) as avg_rating,
                  sum(rating_count) as total_rating,
                  count(distinct restaurant_name) as no_of_restaurants
             from swiggy_data_cleaned
             group by city
),
city_stats as 
(
             select *,
                    min(avg_rating) over() as min_rating,
                    max(avg_rating) over() as max_rating,

                    min(total_rating) over() as min_total_rating,
                    max(total_rating) over() as max_total_rating,

                    min(no_of_restaurants) over() as min_restaurants,
                    max(no_of_restaurants) over() as max_restaurants
            from city_metrics
),
city_score as
(
            select*,
                  (avg_rating - min_rating) * 100.0 / (max_rating - min_rating) as rating_score,
                  (total_rating - min_total_rating) * 100.0 / (max_total_rating - min_total_rating) as total_rating_score,
                  (no_of_restaurants - min_restaurants) * 100.0 / (max_restaurants - min_restaurants) as restaurants_score
            from city_stats
)

select *,
       ( 0.40 * rating_score + 0.40 * total_rating_score + 0.20 * restaurants_score) as city_performance_score
from city_score
order by city_performance_score desc
    

---creating views for powe_bi design---

--restuarent performance view--

CREATE VIEW 
vw_restuarent_performance AS
with restaurant_metrics as
( 
    select 
         restaurant_name,
         round(avg(rating),2) as avg_rating,
         sum(rating_count) as total_rating,
         count(distinct dish_name) as no_of_dishes
    from swiggy_data_cleaned
    group by restaurant_name
),
restaurant_stats as
(
        select *,
              min(avg_rating) over() as min_rating,
              max(avg_rating) over() as max_rating,

              min(total_rating) over() as min_total_rating,
              max(total_rating) over() as max_total_rating,

              min(no_of_dishes) over() as min_dishes,
              max(no_of_dishes) over() as max_dishes
        from restaurant_metrics
        --order by total_rating desc
),
restaurant_scores as
(
select *,
      (avg_rating - min_rating) * 100.0 / (max_rating - min_rating) as rating_score,
      (total_rating - min_total_rating) * 100.0 / (max_total_rating - min_total_rating) as total_rating_score,
      (no_of_dishes - min_dishes) * 100.0 / (max_dishes - min_dishes) as dish_score
from restaurant_stats
)

select *,
       (
        0.40 * rating_score
        +
        0.40 * total_rating_score
        +
        0.20 * dish_score
    ) AS restaurant_performance_score
FROM restaurant_scores
--ORDER BY restaurant_performance_score DESC;

---restuarent performance view---

CREATE VIEW 
vw_city_performance AS
 with city_metrics as
 (
             select
                  city,
                  round(avg(rating),2) as avg_rating,
                  sum(rating_count) as total_rating,
                  count(distinct restaurant_name) as no_of_restaurants
             from swiggy_data_cleaned
             group by city
),
city_stats as 
(
             select *,
                    min(avg_rating) over() as min_rating,
                    max(avg_rating) over() as max_rating,

                    min(total_rating) over() as min_total_rating,
                    max(total_rating) over() as max_total_rating,

                    min(no_of_restaurants) over() as min_restaurants,
                    max(no_of_restaurants) over() as max_restaurants
            from city_metrics
),
city_score as
(
            select*,
                  (avg_rating - min_rating) * 100.0 / (max_rating - min_rating) as rating_score,
                  (total_rating - min_total_rating) * 100.0 / (max_total_rating - min_total_rating) as total_rating_score,
                  (no_of_restaurants - min_restaurants) * 100.0 / (max_restaurants - min_restaurants) as restaurants_score
            from city_stats
)

select *,
       ( 0.40 * rating_score + 0.40 * total_rating_score + 0.20 * restaurants_score) as city_performance_score
from city_score
--order by city_performance_score desc

















