SELECT COUNT(*) 
FROM swims.event 
INNER JOIN swims.event_place 
ON swims.event.event_id = swims.event_place.event_id 
INNER JOIN swims.sampling_monitor_pt 
 ON swims.event_place.core_place_id = swims.sampling_monitor_pt.core_place_id 
INNER JOIN swims.permit 
ON swims.sampling_monitor_pt.permit_id = swims.permit.permit_id 
WHERE swims.event.event_type_id = 6537 
AND swims.event.expire_flag IS NULL 
AND swims.event.event_sched_start_date BETWEEN '01-JAN-20' AND '01-JAN-21'
AND SUBSTR(swims.permit.ohio_epa_no,1,8) = '3IH00074';