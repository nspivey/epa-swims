WITH flows AS
 (
  SELECT CASE WHEN m.reporting_code = '00056' THEN m.value / 1000000 ELSE value END as value
   , mh.core_place_id
   FROM swims.measurement_header mh
   INNER JOIN swims.measurement m ON mh.srh_id = m.srh_id
   WHERE mh.begin_date >= '01-JAN-2020'
    AND mh.ohio_epa_no LIKE '0ID00001%'
    AND mh.version_no = 0
    AND m.reporting_code IN ('00056', '50050') --GPD, MGD
  )

SELECT s.station_code
, MAX(s.flow) as design_flow
, MIN(m.value),
 PERCENTILE_CONT(.1) WITHIN GROUP (ORDER BY m.value ASC), 
 PERCENTILE_CONT(.2) WITHIN GROUP (ORDER BY m.value ASC), 
 PERCENTILE_CONT(.3) WITHIN GROUP (ORDER BY m.value ASC), 
 PERCENTILE_CONT(.4) WITHIN GROUP (ORDER BY m.value ASC), 
 PERCENTILE_CONT(.5) WITHIN GROUP (ORDER BY m.value ASC), 
 PERCENTILE_CONT(.6) WITHIN GROUP (ORDER BY m.value ASC), 
 PERCENTILE_CONT(.7) WITHIN GROUP (ORDER BY m.value ASC), 
 PERCENTILE_CONT(.8) WITHIN GROUP (ORDER BY m.value ASC), 
 PERCENTILE_CONT(.9) WITHIN GROUP (ORDER BY m.value ASC), 
 MAX(m.value)
 
FROM flows m
INNER JOIN swims.sampling_monitor_pt s ON m.core_place_id = s.core_place_id

GROUP BY s.station_code
