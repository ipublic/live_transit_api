explain analyze
insert into stop_time_arrivals
select sc.stop_time_id, sc.stop_id, (td.day + sc.arrival_time), (td.day + sc.departure_time) from
stop_time_services sc
inner join trip_days td on sc.service_id = td.service_id
