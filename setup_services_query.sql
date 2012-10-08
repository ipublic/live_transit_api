insert into stop_time_services
select st.id, st.stop_id, t.service_id, st.arrival_time, st.departure_time from stop_times st
join trips t on t.trip_id = st.trip_id
27 sec
