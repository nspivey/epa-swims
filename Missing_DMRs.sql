SELECT 
 substr(p.ohio_epa_No, 1, 8) as permit_no
 , COUNT(DISTINCT dmr_period) as n_distinct_missing_months
 , COUNT(dmr_period) as n_missing_dmrs

FROM swims.permit p
 INNER JOIN swims.sampling_monitor_pt s ON p.permit_id = s.permit_id
 CROSS JOIN 
  ( --create all months of the period
    SELECT add_months('01-JAN-2020', level-1 ) dmr_period
    FROM dual
    CONNECT BY LEVEL <= 12
  )

WHERE p.ohio_epa_no LIKE '3IH00074%'
 AND p.permit_status IN ('ACTIVE', 'EXPIRED') --ignore draft permits.
 AND p.effective_date <= dmr_period -- permit needs to be effective
 AND p.permit_id =
  ( --correlated subquery; 
    --give me the most recent permit version that was in effect prior to the DMR period
   SELECT max(p2.permit_id)
   FROM swims.permit p2 
   WHERE substr(p2.ohio_epa_no,1,8) = substr(p.ohio_epa_no,1,8) 
    AND p2.permit_status in ('ACTIVE','EXPIRED') 
    AND p2.effective_date <= dmr_period 
  )
 AND NOT EXISTS
  ( --Did they submit something? If so, no need to worry!
    SELECT null
    FROM swims.measurement_header mh
    WHERE mh.begin_date = dmr_period
     AND mh.core_Place_Id = s.core_Place_Id
   )
 AND EXISTS
  (
    -- Were they required to submit?
    SELECT null
    FROM swims.sampling_station_limits sl 
    INNER JOIN swims.limits l                    ON sl.limit_id = l.limit_id 
    INNER JOIN swims.season se                   ON l.season_type_id = se.season_type_id 

   WHERE s.core_place_id = sl.core_place_id 
    AND ((dmr_period between l.begin_date and l.end_date)  --dmr period must be between limit begin and end date
    OR (l.limit_type = 93 and dmr_period >= l.begin_date)) --unless we have an administratively continued permit
    AND EXTRACT (month FROM dmr_period) = se.month 
    AND l.measuring_frequency_id <> 
      (
        SELECT measuring_frequency_id 
         FROM swims.measuring_frequency 
        WHERE frequency_name = 'When Disch.' --compliance excludes "WHEN DISCH" parameters
       ) 
  ) 
GROUP BY substr(p.ohio_epa_No, 1, 8);
