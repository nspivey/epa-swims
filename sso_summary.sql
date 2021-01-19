SELECT COUNT(swims.measurement.value), 
  SUM(swims.measurement.value) 
FROM coreadmin.core_place 
    
INNER JOIN swims.permit 
ON coreadmin.core_place.core_place_id = swims.permit.core_place_id 
    
INNER JOIN swims.sampling_monitor_pt 
   ON swims.sampling_monitor_pt.permit_id = swims.permit.permit_id 
    
INNER JOIN swims.measurement_header 
   ON swims.measurement_header.core_place_id = swims.sampling_monitor_pt.core_place_id 

INNER JOIN swims.measurement 
   ON swims.measurement_header.srh_id = swims.measurement.srh_id 
    
WHERE SUBSTR(swims.permit.ohio_epa_no,1,8) = '3IH00074'
 AND swims.measurement_header.version_no  = 0
AND swims.measurement_header.begin_date >= '01-JAN-20'  
AND swims.measurement_header.end_date < '01-JAN-21' 
AND ROUND(swims.measurement_header.station_code,0)=300 
AND swims.measurement.value > 0 ;