-- Pizza Hut Sales Analysis : - 

-- uploading csv data

create database pizzahut;
create table orders(
order_id int not null,
order_date date not null,
order_time time not null,
primary key(order_id)
);

create table order_details(
order_details_id int not null,
order_id int not null,
pizza_id text not null,
quantity int not null,
primary key(order_details_id)
);

-- analysis part :


-- Q1. What is the total volume of orders received? select * from orders;

select count(order_id) as total_orders from orders;


-- Q2. What is the total revenue generated across all pizza sales?

select sum(quantity*price)  from order_details as o
left join  pizzas as p
on o.pizza_id = p.pizza_id;


-- Q3. Which pizza has the highest price on the menu? 

select name from pizza_types as t
left join pizzas as p
on t.pizza_type_id = p.pizza_type_id
order by p.price desc 
limit 1;


-- Q4. Which pizza size drives the most orders?

select size,count(quantity) as no_of_orders from order_details as d
join pizzas as p
on d.pizza_id = p.pizza_id 
group by size 
order by count(quantity) desc 
limit 3;


-- Q5. Which are the top 5 best-selling pizzas by order volume? 

 select pizza_type_id , sum(quantity) from pizzas as p
 join  order_details as o
 on p.pizza_id = o.pizza_id
 group by pizza_type_id
 order by sum(quantity) desc 
 limit 5;

 -- OR 

 select name  , sum(quantity) as quantity from pizzas as p
 join pizza_types as t
 on t.pizza_type_id = p.pizza_type_id
 join  order_details as o
 on p.pizza_id = o.pizza_id
 group by name
 order by quantity desc 
 limit 5;


-- Q6. How does demand distribute across pizza categories?

select category , sum(quantity) as quantity from pizza_types as t
join pizzas as p
on t.pizza_type_id = p.pizza_type_id
join order_details as o 
on o.pizza_id = p.pizza_id
group by category 
order by sum(quantity) desc;


-- Q7. At what hours is order volume highest?

select hour(order_time) , count(order_id) from orders
group by hour(order_time);


-- Q8. How many pizza varieties exist per category? 

select category , count(name) from pizza_types
group by category;


- -- Q9. What is the average daily order volume?

select avg(quantity) as quantity from(
select order_date , sum(quantity) as quantity from orders as o 
join order_details as d
on o.order_id = d.order_id
group by order_date 
)
as ok;


-- Q10. Which 3 pizzas generate the most revenue overall?

select name , sum(quantity*price) as revenue from pizzas as p
join order_details as d 
on d.pizza_id=p.pizza_id
join pizza_types as t
on t.pizza_type_id = p.pizza_type_id
group by name
order by revenue desc
limit 3;


-- Q11. What is each category's revenue share (%) of total sales?

select category , round((sum(quantity*price)/( 
select round(sum(quantity*price)) from pizzas as p 
join order_details as o 
on o.pizza_id = p.pizza_id
)*100),2) as percentage  from pizzas as p
join order_details as d 
on d.pizza_id=p.pizza_id
join pizza_types as t
on t.pizza_type_id = p.pizza_type_id
group by category;

-- Q12. How has revenue accumulated day-over-day throughout the year?

select order_date , revenue , sum(revenue) over(order by order_date) 
as cumulative_revenue from 
(select order_date , round(sum(price*quantity),0) as revenue from orders as o
join order_details as d 
on o.order_id = d.order_id 
join pizzas as p
on d.pizza_id = p.pizza_id 
group by order_date) as ok;


-- Q13. Who are the top 3 revenue-generating pizzas within each category? 

select name, revenue from
(select category,name,revenue,
           rank() over(partition by category order by revenue desc) as rn
    from(
        select pizza_types.category,
               pizza_types.name,
               sum((order_details.quantity) * pizzas.price) as revenue
        from pizza_types
        join pizzas
        on pizza_types.pizza_type_id = pizzas.pizza_type_id

        join order_details
        on order_details.pizza_id = pizzas.pizza_id

        group by pizza_types.category,
                 pizza_types.name
    ) as a
) as b
where rn <= 3;
