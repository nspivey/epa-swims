SELECT swims.event.event_sched_start_date,
SUM(CASE WHEN swims.event.event_type_id = 6535 THEN 1 ELSE 0 END) fiveSum,
SUM(CASE WHEN swims.event.event_type_id = 6536 THEN 1 ELSE 0 END) sixSum
    
FROM swims.event_measurement 
    
INNER JOIN swims.event 
ON swims.event_measurement.event_id = swims.event.event_id 

INNER JOIN swims.measurement 
ON swims.event_measurement.sr_id = swims.measurement.sr_id 
    
INNER JOIN swims.measurement_header 
ON swims.measurement.srh_id = swims.measurement_header.srh_id 

WHERE swims.event.event_type_id IN (6537,6536,6535) 
AND swims.event.expire_flag IS NULL 
AND swims.event.event_sched_start_date BETWEEN '01-JAN-20' AND '01-JAN-21'
AND swims.measurement_header.version_no = 0
AND SUBSTR(swims.measurement_header.ohio_epa_no,1,8) = '3IH00074' 
group by swims.event.event_sched_start_date;



