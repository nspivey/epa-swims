 SELECT county 
  ,facn 
  ,facnam 
  ,major 
  ,station 
  ,reporting_code 
  ,parameter_name 
  ,MAX(percent_exceedance) as Max_Percent_Exceed
  ,SUM(decode(sign(percent_exceedance-decode(paratype,1,40,20)),1,1,0)) as Months_Big_Vios
  ,COUNT(*) as Months_Vios
  ,DECODE(SUBSTR(facn,1,1),'0','Southeast','1','Southwest','2','Northwest','3','Northeast','4','Central') as District
 
 FROM
     ( 
   SELECT cc.county_name county, 
       SUBSTR(p.ohio_epa_no,1,8) facn, 
       cp.core_place_name facnam, fr.major major, 
       to_number(substr(e.event_comments,2,3)) station, 
       substr(e.event_comments,23,5) reporting_code, 
       SUBSTR(e.event_comments,28,23) parameter_name, 
       to_char(e.event_sched_start_date, 'FMMonth yyyy') viomonth, 
       ROUND(max(ABS(substr(e.event_comments,68,7)-substr(e.event_comments,61,7))/substr(e.event_comments,61,7)),3)*100 percent_exceedance, 
       g.no_of_samples paratype 
  
  FROM swims.event e 
    INNER JOIN swims.event_permit ep      ON e.event_id = ep.event_id 
    INNER JOIN swims.permit p             ON ep.permit_id = p.permit_id 
    INNER JOIN coreadmin.core_place cp    ON p.core_place_id = cp.core_place_id 
    INNER JOIN coreadmin.core_facility cf ON cp.core_place_id = cf.core_place_id 
    INNER JOIN coreadmin.cmtb_county cc   ON cf.fips_county_code = cc.fips_county_code 
    INNER JOIN swims.mor_preprint_base g  ON g.rep_code = substr(e.event_comments,23,5) 
    
    LEFT OUTER JOIN  
       (    SELECT core_place_id, 
                    'M' major 
             FROM swims.facility_relationship 
             WHERE fac_type_id = 3693 
        ) fr 
       ON p.core_place_id = fr.core_place_id 
  
  WHERE p.permit_type_id in (153,154) 
    AND e.event_type_id = 6535 
    AND e.expire_flag is null 
    AND e.event_sched_start_date >= TO_DATE('01-Feb-2020','dd-mon-yyyy') 
    AND e.event_sched_start_date < TO_DATE('01-Aug-2020','dd-mon-yyyy') 
  --     AND e.event_sched_start_date >= TO_DATE('" & Format(datQueryStart, "dd-mmm-yyyy") & "','dd-mon-yyyy') 
  --     AND e.event_sched_start_date < TO_DATE('" & Format(datQueryEnd, "dd-mmm-yyyy") & "','dd-mon-yyyy') 
  --      and cc.county_name in (" & strCounty & ") 
  --     AND p.ohio_epa_no like '" & UCase(Left(strOhioNo, 8)) & "%' 
    AND trim(substr(e.event_comments,61,7)) is not null 
    AND trim(substr(e.event_comments,68,7)) is not null 
    AND trim(substr(e.event_comments,68,7)) <> '.' 
    AND substr(trim(substr(e.event_comments,68,7)),1,1) <> '#' 
    AND to_number(trim(substr(e.event_comments,61,7))) > 0 
    AND g.no_of_samples in (1,2,3)
    AND g.form_status_flag = 'P' 
    AND (ABS(substr(e.event_comments,68,7)-substr(e.event_comments,61,7))/substr(e.event_comments,61,7)) > .01 
    AND SUBSTR(p.ohio_epa_no,1,1) <> '9' 
  GROUP BY cc.county_name, 
    SUBSTR(p.ohio_epa_no,1,8), 
    cp.core_place_name, fr.major, 
    to_number(substr(e.event_comments,2,3)), 
    substr(e.event_comments,23,5), 
    SUBSTR(e.event_comments,28,23), 
    to_char(e.event_sched_start_date, 'FMMonth yyyy'), 
    g.no_of_samples
  )    
WHERE NOT (facn='0IB00026' and station=2  )
  OR NOT (facn='0IB00027' and station=1  ) 
  OR NOT (facn='2IE00000' and station=99 ) 
  OR NOT (facn='2IG00007' and reporting_code='00015' and station = 602 ) 
  OR NOT (facn='2IG00007' and reporting_code='00680' and station = 2 ) 
  OR NOT (facn='3IF00017' and reporting_code='00530' and station = 2 ) 
  OR NOT (facn='3IY00081' and reporting_code='00400' and station = 1) 

GROUP BY county 
  ,facn
  ,facnam
  ,major 
  ,station 
  ,reporting_code 
  ,parameter_name
  ,DECODE(SUBSTR(facn,1,1),'0','Southeast','1','Southwest','2','Northeast','3','Northwest','4','Central') 

HAVING count(*) >= 4 
  OR SUM(decode(sign(percent_exceedance-decode(paratype,1,40,20)),1,1,0)) >= 2 

Order By county, facn, parameter_name 
