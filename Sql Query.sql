----####Variation of Drivers and customers across 3 weeks####------

select count(distinct client_id) as Customers, count(distinct driver_id) as Drivers,1 as week_num from [Cab week1]
union all
select count(distinct client_id) as Customers, count(distinct driver_id) as Drivers,2 as week_num from [Cab week2]
union all
select count(distinct client_id) as Customers, count(distinct driver_id) as Drivers,3 as week_num from [Cab week3]

----####Total Eta According to type of Car####------

--select day_num ,sum(distinct actual_eta) as Total_Eta from [Cab week1] group by day_num order by day_num
with week_sum1 as (
	select car_type,sum(distinct actual_eta) as Total_Eta from [Cab week1] group by car_type
	),
week_sum2 as (
	select car_type,sum(distinct actual_eta) as Total_Eta from [Cab week2] group by car_type
	),
week_sum3 as(
		select car_type,sum(distinct actual_eta) as Total_Eta from [Cab week3] group by car_type
	)
select week_sum1.car_type,week_sum1.total_eta from week_sum1 
	inner join week_sum2 on week_sum1.car_type=week_sum2.car_type
	inner join week_sum3 on week_sum1.car_type=week_sum3.car_type

----####Ridership Variation across 3 Weeks####------

select 1 as Weeks,* from (select distinct(client_id) as client_id1,car_type from [Cab week1]) as client
pivot
(
	count(client_id1) for car_type in ([Gold],[Platinum],[Silver])
) as pivottable1
union all
select 2 as Weeks,* from (select distinct(client_id) as client_id2,car_type from [Cab week2]) as client
pivot
(
	count(client_id2) for car_type in ([Gold],[Platinum],[Silver])
) as pivottable2
union all
select 3 as Weeks,* from (select distinct(client_id) as client_id3,car_type from [Cab week1]) as client
pivot
(
	count(client_id3) for car_type in ([Gold],[Platinum],[Silver])
) as pivottable3

----####Average fare in Differnt Cab types####------

with cte as 
(
	select 1 Weeks,* from (select car_type,cast(fare as float) as fare1 from [Cab week1]) as Week1
	pivot
	(
		avg(fare1) for car_type in ([Gold],[Platinum],[Silver])
	) as Pivot_1 
	union all
	select 2 Weeks,* from (select car_type,cast(fare as float) as fare2 from [Cab week2]) as Week2
	pivot
	(
		avg(fare2) for car_type in ([Gold],[Platinum],[Silver])
	) as Pivot_2 
	union all
	select 3 Weeks,* from (select car_type,cast(fare as float) as fare3 from [Cab week3]) as Week3
	pivot
	(
		avg(fare3) for car_type in ([Gold],[Platinum],[Silver])
	) as Pivot_3
) select weeks,round(gold,2) as Gold,round(Platinum,2) as Platinum, round(Silver,2) as Silver from cte

----####Different devices used####----

select * from [Cab week1]
with a as
(
	select request_device,count(request_device) as Week1_device from [Cab week1] group by request_device
),b as
(
	select request_device,count(request_device) as Week2_device  from [Cab week2] group by request_device
), c as
(
	select request_device,count(request_device) as Week3_device  from [Cab week3] group by request_device
) select a.request_device,a.Week1_device ,b.Week2_device ,c.Week3_device  from a 
	inner join b on a.request_device=b.request_device
	left join c on a.request_device=c.request_device
	order by request_device

----####Weekly Distance Range####----

select * from [Cab week1]

with cte as
(
	select 1 weeks,distance ,dense_rank() over(partition by distance order by distance desc) as rn 
	from [cab week1] 
) select weeks,distance , count(rn) as cnt from cte group by weeks,distance having count(rn)<62 order by cnt desc 

select max(distance) max_dist_travelled,min(distance) min_dist_travelled from [Cab week1]

----------#####Clients Retained######-----------

select * from [Cab week1]

with distincts as 
(
select 1 as weeks,count(distinct client_id) as clno1 from [Cab week1]
union all
----Week 1 to 2
		select 2 as weeks, count(distinct client_id) as clno2 from [Cab week2] where client_id not in
			(select distinct client_id as week1 from [Cab week1])
union all
----week 1-2-3
	select 3 as weeks, count(distinct client_id) as clno3 from [Cab week3] where client_id not in 
		(select distinct client_id from [Cab week2] where client_id not in
			(select distinct client_id as week1 from [Cab week1])
			)
),
total as (
--week 1
select 1 as weeks, count(distinct client_id) as clno1 from [Cab week1]
union all
---week 2
select 2 as weeks, count(distinct client_id) as clno2 from [Cab week2]
union all
select 3 as weeks, count(distinct client_id) as clno3 from [Cab week3]
)
select total.weeks,total.clno1,distincts.clno1 from total
left join distincts on total.weeks=distincts.weeks

---------######Total Revenue######---------
with cte as 
(
	select 1 Weeks,* from (select car_type,cast(fare as float) as fare1 from [Cab week1]) as Week1
	pivot
	(
		sum(fare1) for car_type in ([Gold],[Platinum],[Silver])
	) as Pivot_1 
	union all
	select 2 Weeks,* from (select car_type,cast(fare as float) as fare2 from [Cab week2]) as Week2
	pivot
	(
		sum(fare2) for car_type in ([Gold],[Platinum],[Silver])
	) as Pivot_2 
	union all
	select 3 Weeks,* from (select car_type,cast(fare as float) as fare3 from [Cab week3]) as Week3
	pivot
	(
		sum(fare3) for car_type in ([Gold],[Platinum],[Silver])
	) as Pivot_3
) select weeks,round(gold,2) as Gold,round(Platinum,2) as Platinum, round(Silver,2) as Silver from cte

-----#######Client Rating#######------
with cte as (
select 1 as weeks,client_rating, car_type,count(client_id)  as w3_rating
from [Cab week1] group by client_rating,car_type having client_rating>=1
union all
select 2 as weeks,client_rating, car_type,count(client_id)  as w3_rating
from [Cab week2] group by client_rating,car_type having client_rating>=1
union all
select 3 weeks,client_rating, car_type,count(client_id)  as w3_rating
from [Cab week3] group by client_rating,car_type having client_rating>=1
) select weeks,client_rating,car_type,sum(w3_rating) as Ratings from cte group by weeks,client_rating,car_type order by weeks,client_rating