DROP TABLE IF EXISTS public.mp_vitals CASCADE;
CREATE TABLE public.mp_vitals as
-- day 1
with vw1 as
(
  select p.patientunitstayid
  , min(heartrate) as heartrate_min
  , max(heartrate) as heartrate_max
  , min(coalesce(ibp_mean,nibp_mean)) as map_min
  , max(coalesce(ibp_mean,nibp_mean)) as map_max
  , min(temperature) as temperature_min
  , max(temperature) as temperature_max
  , min(spo2) as spo2_min
  , max(spo2) as spo2_max
  from pivoted_vital p
  INNER JOIN mp_cohort co
    ON  p.patientunitstayid = co.patientunitstayid
    and p.chartoffset >  co.startoffset + (-1*60)
    and p.chartoffset <= co.startoffset + (24*60)
  WHERE heartrate IS NOT NULL
  OR ibp_mean IS NOT NULL
  OR nibp_mean IS NOT NULL
  OR temperature IS NOT NULL
  OR spo2 IS NOT NULL
  group by p.patientunitstayid
)
-- day 2
, vw2 as
(
  select p.patientunitstayid
  , min(heartrate) as heartrate_min
  , max(heartrate) as heartrate_max
  , min(coalesce(ibp_mean,nibp_mean)) as map_min
  , max(coalesce(ibp_mean,nibp_mean)) as map_max
  , min(temperature) as temperature_min
  , max(temperature) as temperature_max
  , min(spo2) as spo2_min
  , max(spo2) as spo2_max
  from pivoted_vital p
  INNER JOIN mp_cohort co
    ON  p.patientunitstayid = co.patientunitstayid
    and p.chartoffset >  co.startoffset + (24*60)
    and p.chartoffset <= co.startoffset + (48*60)
  WHERE heartrate IS NOT NULL
  OR ibp_mean IS NOT NULL
  OR nibp_mean IS NOT NULL
  OR temperature IS NOT NULL
  OR spo2 IS NOT NULL
  group by p.patientunitstayid
)
select
    pat.patientunitstayid
  , vw1.heartrate_min as heartrate_min_day1
  , vw1.heartrate_max as heartrate_max_day1
  , vw1.map_min as map_min_day1
  , vw1.map_max as map_max_day1
  , vw1.temperature_min as temperature_min_day1
  , vw1.temperature_max as temperature_max_day1
  , vw1.spo2_min as spo2_min_day1
  , vw1.spo2_max as spo2_max_day1

  , vw2.heartrate_min as heartrate_min_day2
  , vw2.heartrate_max as heartrate_max_day2
  , vw2.map_min as map_min_day2
  , vw2.map_max as map_max_day2
  , vw2.temperature_min as temperature_min_day2
  , vw2.temperature_max as temperature_max_day2
  , vw2.spo2_min as spo2_min_day2
  , vw2.spo2_max as spo2_max_day2
from patient pat
left join vw1
  on pat.patientunitstayid = vw1.patientunitstayid
left join vw2
  on pat.patientunitstayid = vw2.patientunitstayid
order by pat.patientunitstayid;
