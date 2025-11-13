-- 1. what is total amount each customer spent on zomato?
 
 select s.userid,sum(p.price) as total_amount from sales s inner join product p on s.product_id=p.product_id 
 group by s.userid

 -- 2. How many days has each customer visited zomato

 select userid,count(distinct created_date) distinct_days_visited from sales group by userid

 -- 3. what was the first product purchased by each customer?
 -- ROW_NUMBER() assigns a unique sequential number to each row based on a specified order.
 
with cte  as (
select s.userid,p.product_name,s.created_date,ROW_NUMBER() over (partition by s.userid order by s.created_date) order_user_wise
 from sales s inner join product p on s.product_id=p.product_id )
select userid,product_name as first_order_purchased from cte where order_user_wise=1

-- 4 what is the most purchased item on the menu and how many times was it purchased by all customers?

select userid,count(userid) as count from sales where product_id= (
select top 1 product_id  from sales group by product_id order by count(product_id) desc)
group by userid

-- 5 which item was the most popular for each customer?
--RANK() in SQL is a window function that assigns a rank to each row based on ORDER BY, gives the same rank to duplicate values, and skips the next rank numbers after duplicates.
select userid,product_id from (
select *,rank() over(partition by userid order by cnt desc) rnk from
(select userid,product_id,count(product_id) as cnt from sales group by userid,product_id)a)b
where rnk=1

--6 which item was purchased first by the customer after they became a member

select userid,product_id as first_product_id from(
select userid,product_id,rank() over(partition by userid order by created_date asc)rnk from (
select g.userid,g.gold_signup_date,s.product_id ,s.created_date from goldusers_signup g 
inner join sales s on g.userid=s.userid and s.created_date>=g.gold_signup_date)a )b
where b.rnk=1

--7 which item was purchased just before the customer become a member?

select userid,product_id from
(
select userid,created_date,product_id, rank() over (partition by userid order by created_date desc)rnk from

(select s.userid,s.created_date,s.product_id from sales s inner join goldusers_signup g on s.userid=g.userid and s.created_date<g.gold_signup_date)a)b where b.rnk=1

--8 what is the total orders and amount spent for each member before they became a member?

select b.userid,count(b.userid) as total_orders,sum(price) as total_spent from
(select a.userid,a.created_date,a.product_id,p.price from
(select s.userid,s.created_date,s.product_id from sales s inner join goldusers_signup g on s.userid=g.userid and s.created_date<g.gold_signup_date)a inner join
product p on a.product_id=p.product_id)b group by userid

--9 If buying each product generates points for eg 5rs=2 Zomato point and each point has different purchasing points 
-- for eg p1 5rs=1 zomato point , for p2 10rs=5 zomato point and p3 5rs = 1 zomato point
-- calculate points collected by each customer and for which product most point have given tell now

select e.userid,sum(e.point) as total_point from(
select d.userid,d.product_id,d.total_amount_spent,
case when d.product_id=1 then d.total_amount_spent/5
     when d.product_id=2 then d.total_amount_spent/2
	 when d.product_id=3 then d.total_amount_spent/5
	 end as point from
(select s.userid,s.product_id,sum(p.price) as total_amount_spent from sales s inner join product p on s.product_id=p.product_id group by s.userid,s.product_id) d
)e group by e.userid;

 ----------

 select top 1 f.product_id,f.total_point from
 (select e.product_id,sum(e.point) as total_point from(
select d.userid,d.product_id,d.total_amount_spent,
case when d.product_id=1 then d.total_amount_spent/5
     when d.product_id=2 then d.total_amount_spent/2
	 when d.product_id=3 then d.total_amount_spent/5
	 end as point from
(select s.userid,s.product_id,sum(p.price) as total_amount_spent from sales s inner join product p on s.product_id=p.product_id group by s.userid,s.product_id) d)e
group by e.product_id)f order by f.total_point desc


--10 In the first one year after a customer joins the gold program (including their join date) irrespective of what the customer has purchased they earn
-- 5 zomato points for every 10 rs spent who earned more more 1 or 3 and what was their points earnings in their first year?

select top 1 n.userid,sum(n.price/2) as point from
(
select k.userid,k.created_date,k.product_id,p.price from
(select s.userid,s.created_date,s.product_id from sales s inner join goldusers_signup g on s.userid=g.userid 
where g.gold_signup_date<=s.created_date and s.created_date<=DATEADD(year,1,g.gold_signup_date))k
inner join product p on k.product_id=p.product_id)n group by n.userid order by point desc

--11 rank all the transaction of the customer

select *,rank() over(partition by userid order by created_date) rank from sales

--12 rank all the transaction for each member whenever they are a zomatogold member for every non gold member transaction mark as na

select m.*,
case when m.rnk=0 then 'na'
else rnk
end as rnkk from
(select k.*, cast((
case when gold_signup_date is NULL THEN 0
ELSE RANK() over(partition by userid order by created_date desc) 
end ) as varchar)rnk
from
(select s.userid,s.created_date,s.product_id,g.gold_signup_date from sales s left join goldusers_signup g 
on s.userid=g.userid and s.created_date>=g.gold_signup_date)k)m

