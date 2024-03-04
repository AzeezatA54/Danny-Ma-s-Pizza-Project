CREATE SCHEMA pizza_runner;

DROP TABLE IF EXISTS runners;
CREATE TABLE runners (
  "runner_id" INTEGER,
  "registration_date" DATE
);
INSERT INTO runners
  ("runner_id", "registration_date")
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');

DROP TABLE IF EXISTS customer_orders;
CREATE TABLE customer_orders (
  "order_id" INTEGER,
  "customer_id" INTEGER,
  "pizza_id" INTEGER,
  "exclusions" VARCHAR(4),
  "extras" VARCHAR(4),
  "order_time" DATETIME);

INSERT INTO customer_orders
  ("order_id", "customer_id", "pizza_id", "exclusions", "extras", "order_time")
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');

DROP TABLE IF EXISTS runner_orders;
CREATE TABLE runner_orders (
  "order_id" INTEGER,
  "runner_id" INTEGER,
  "pickup_time" VARCHAR(19),
  "distance" VARCHAR(7),
  "duration" VARCHAR(10),
  "cancellation" VARCHAR(23)
);


INSERT INTO runner_orders
  ("order_id", "runner_id", "pickup_time", "distance", "duration", "cancellation")
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');

  DROP TABLE IF EXISTS pizza_names;
CREATE TABLE pizza_names (
  "pizza_id" INTEGER,
  "pizza_name" TEXT
);
INSERT INTO pizza_names
  ("pizza_id", "pizza_name")
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');


DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  "pizza_id" INTEGER,
  "toppings" TEXT
);
INSERT INTO pizza_recipes
  ("pizza_id", "toppings")
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');


DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings (
  "topping_id" INTEGER,
  "topping_name" TEXT
);
INSERT INTO pizza_toppings
  ("topping_id", "topping_name")
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');

---Case Study Questions
-- A. Pizza Metrics
--1.How many pizzas were ordered?
--2.How many unique customer orders were made?
--3.How many successful orders were delivered by each runner?
--4.How many of each type of pizza was delivered?
--5.How many Vegetarian and Meatlovers were ordered by each customer?
--6.What was the maximum number of pizzas delivered in a single order?
--7.For each customer, how many delivered pizzas had at least 1 change and how many had no changes?


--Answers
--1.
Select count (@@DEF_SORTORDER_ID) as num_of_orders
from customer_orders


--2
Select count( distinct(order_id)) as unique_customer_order
from customer_orders


--3
select  sub.runner_id, count(sub.runner_id) as num_of_orders
from
(select *, isnull(cancellation , 'null') as new_cancel
from dbo.runner_orders) as sub
where sub.new_cancel in ('null', ' ')
group by sub.runner_id


--4 
select  co.pizza_id, count(co.order_id) as count_pizza_orders
from dbo.customer_orders as co join dbo.runner_orders as ro
on co.order_id = ro.order_id
where isnull(ro.cancellation, 'null') in ('null', ' ')
group by co.pizza_id


--5
select customer_id, count(case when pizza_id = 1 then 1 else null end)as meat_lovers,  count(case when pizza_id = 2 then 1 else null end )as vegeterian
from dbo.customer_orders
group by customer_id

--6 
select max(subq.count_order_id) as max_delivered_in_single_order
from
(select order_id, count(order_id) as count_order_id
from dbo.customer_orders
where order_id not in (6, 9)
group by order_id) as subq

--7
with cte_1 as
(
select c.order_id, c.customer_id, case when c.new_exclusions is null and c.new_extras is null then 'no change' else 'change' end  as status_of_change
from
(
select order_id, customer_id, case when exclusions = ' ' then null
when exclusions = 'null' then null else exclusions end as New_exclusions, case when extras = ' ' then null
when extras = 'NaN' then null when extras = 'null' then null else extras  end as new_extras
from dbo.customer_orders) as c)

select customer_id, status_of_change,count(case when status_of_change = 'no change' then 1 else 0 end) as Changess
from cte_1 
where order_id not in (6,9)
group by customer_id, status_of_change
order by customer_id


--8
select count(order_id) as pizza_with_exclusions_extra
from
(
select order_id, customer_id, case when exclusions = ' ' then null
when exclusions = 'null' then null else exclusions end as New_exclusions, case when extras = ' ' then null
when extras = 'NaN' then null when extras = 'null' then null else extras  end as new_extras
from dbo.customer_orders )as c
where new_exclusions is not null and new_extras is not null and order_id not in (6,9)


--9
select datepart(hour, order_time) as hours, count(order_id) as orders_per_hour
from dbo.customer_orders
group by datepart(hour,order_time)

--10
select datename(WEEKDAY, order_time) as days, count(order_id) as orders_per_day
from dbo.customer_orders
group by datename(WEEKDAY, order_time)  




-- B. Runner and Customer Experience
--1.How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
--2.What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
--3.Is there any relationship between the number of pizzas and how long the order takes to prepare?
--4.What was the average distance travelled for each customer?
--5.What was the difference between the longest and shortest delivery times for all orders?
--6.What was the average speed for each runner for each delivery and do you notice any trend for these values?
--7.What is the successful delivery percentage for each runner?

--1
set datefirst 5;
select DATEPART(week, registration_date) as week_period, count(runner_id)as runners
from dbo.runners
group by DATEPART(week, registration_date)

--2
with cte_2 as
(
select distinct order_id, runner_id, cast(datediff(minute, order_time,new_pickup_time) as float) as time
from
(select ro.runner_id,co.order_id, co.order_time, case when ro.pickup_time = 'null' then null else ro.pickup_time end as new_pickup_time
from dbo.runner_orders as ro join dbo.customer_orders as co
on ro.order_id = co.order_id) as sub3
where new_pickup_time is not null
)

select runner_id, avg(time) as average_time
from cte_2
group by runner_id

--3
with cte_3 as
(
select count(order_id) as no_of_orders, cast(datediff(minute, order_time,new_pickup_time) as float) as ready_time
from
(select co.order_id, co.order_time, case when ro.pickup_time = 'null' then null else ro.pickup_time end as new_pickup_time
from dbo.runner_orders as ro join dbo.customer_orders as co
on ro.order_id = co.order_id) as sub3
where new_pickup_time is not null
group by order_id, cast(datediff(minute, order_time,new_pickup_time) as float) 
)
 select no_of_orders, avg(ready_time) as avg_per_pizza, avg(ready_time/no_of_orders) as avg_per_num_pizza
 from cte_3
 group by no_of_orders
--This shows that yes, there is a propotional increase in preparation time with increase in number of orders
--It also shows that there is a slight decrease with preparation each pizza with increased number of orders 

--4
select co.customer_id , avg(convert(float,  case when ro.distance like 'null' then null 
                                when ro.distance like '%_km' then replace (ro.distance, 'km', '')
		                        else ro.distance end)) as avg_distance
	  from dbo.runner_orders as ro join customer_orders as co
	  on ro.order_id = co.order_id
	  where co.order_id not in (6,9)
	  group by co.customer_id

--5
with cte1 as
(
select convert(float,case when duration like 'null' then null
            when duration like '%minutes' then replace (duration, 'minutes','')
			when duration like '%mins' then replace (duration,'mins','')
			when duration like '%minute' then replace(duration, 'minute','')
			else duration end )as new_duration
from dbo.runner_orders
where duration is not null)

select max(new_duration) - min(new_duration) as duration_diff
from cte1

--6
with cte2 as
(select order_id, runner_id,convert(float,  case when distance like 'null' then null 
                            when distance like '%_km' then replace (distance, 'km', '')
		                        else distance end) as distance
	  from dbo.runner_orders),
cte3 as 
(select order_id, runner_id, convert(float,case when duration like 'null' then null
            when duration like '%minutes' then replace (duration, 'minutes','')
			when duration like '%mins' then replace (duration,'mins','')
			when duration like '%minute' then replace(duration, 'minute','')
			else duration end )as duration
from dbo.runner_orders)

select c2.runner_id, c2.order_id,round(avg (c2.distance/c3.duration*60),2)as avg_speed
from cte2 as c2 join cte3 as c3
on c2.order_id = c3.order_id
where c2.order_id not in (6,9)
group by c2.runner_id, c2.order_id

--7
with cte4  as
(select runner_id,case when new_cancellation is null then 1 else 0 end as delivery
from 
(select runner_id, case when cancellation like 'null' then null
            when cancellation like 'NaN' then null
			when cancellation like '' then null
			else cancellation end as new_cancellation
from dbo.runner_orders) as sub4)

select runner_id, round(100*sum(delivery)/count(*),1) as suc_delivery
from cte4
group by runner_id