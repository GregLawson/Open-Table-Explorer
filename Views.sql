/*
 *   Copyright (C) 2009  Gregory Lawson
*  
*   This program is free software; you can redistribute it and/or modify
*   it under the terms of the GNU General Public License as published by
*   the Free Software Foundation; either version 2.1 of the License, or
*   (at your option) any later version.
* 
*   This program is distributed in the hope that it will be useful,
*   but WITHOUT ANY WARRANTY; without even the implied warranty of
*   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*   GNU General Public License for more details.
* 
*   You should have received a copy of the GNU General Public License
*   along with this program; if not, a copy is available at
#   http://www.gnu.org/licenses/gpl-2.0.html
*/
DROP VIEW Excessive_Changes;
CREATE VIEW Excessive_Changes AS
SELECT id,
 total_voltagenow,
 mtu1_voltagenow,
 total_powernow,
 total_kva,
 mtu1_powernow,
 mtu1_kva
FROM TedPrimaries
WHERE total_voltagenow>1300
 or mtu1_voltagenow>1300
 or total_powernow>3000
 or total_kva>3000
 or mtu1_powernow>3000
 or mtu1_kva>3000
 or total_voltagenow<1000
 or mtu1_voltagenow<1000
 or total_powernow<=3
 or total_kva<=3
 or mtu1_powernow<=3
 or mtu1_kva<=3
;
create VIEW dupChecks as 
select id,
 created_at,
 total_voltagenow-mtu1_voltagenow as dV0,
 total_powernow-mtu1_powernow as dP0,
 total_kva-mtu1_kva as dK0
from tedprimaries 
where  total_voltagenow-mtu1_voltagenow<>0
 or total_powernow-mtu1_powernow<>0
 or total_kva-mtu1_kva<>0;


DROP VIEW Standard_Devations;
CREATE VIEW Standard_Devations AS
select stddev(total_voltagenow) AS VT_Noise,
 stddev(mtu1_voltagenow) AS V1_Noise,
 stddev(total_powernow) AS PT_Noise,
 stddev(total_kva) AS KT_Noise,
 stddev(mtu1_powernow) AS P1_Noise,
 stddev(mtu1_kva) AS K1_Noise
from TedPrimaries;

DROP VIEW Weather_Changes;
CREATE VIEW Weather_Changes AS
select  khhr_weather,klax_weather,
 khhr_temp_f-klax_temp_f AS dTemp,
 khhr_relative_humidity-klax_relative_humidity AS dRH,
 khhr_wind_dir,klax_wind_dir,
 khhr_wind_degrees-klax_wind_degrees AS dWD,
 khhr_wind_mph-klax_wind_mph as dMPH,
 khhr_pressure_mb-klax_pressure_mb AS dPmb,
 khhr_dewpoint_f- klax_dewpoint_f AS dDP
from weathers;



DROP View hourly_ted;
CREATE View hourly_ted AS
 SELECT tedprimaries.hour, avg(tedprimaries.total_powernow) AS avg
   FROM tedprimaries
  GROUP BY tedprimaries.hour
  ORDER BY tedprimaries.hour;

DROP View hourly_production;
CREATE View hourly_production AS
SELECT date_part('hour'::text, productions.created_at) AS hour,
 avg(productions.power) AS avg
   FROM productions
  GROUP BY date_part('hour'::text, productions.created_at)
  ORDER BY date_part('hour'::text, productions.created_at);

DROP FUNCTION DayOnly(TIMESTAMP WITHOUT TIME ZONE);
CREATE FUNCTION DayOnly (ts timestamp WITHOUT TIME ZONE) RETURNS TIME AS $$
DECLARE
	roundedTime TIME;
	previousMidnight TIME;
BEGIN
	RETURN date_trunc('day',ts);
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION TOD(TIMESTAMP WITHOUT TIME ZONE);
CREATE FUNCTION TOD (ts timestamp WITHOUT TIME ZONE) RETURNS TIME AS $$
DECLARE
BEGIN
	RETURN ts-DayOnly(ts);
END;
$$ LANGUAGE plpgsql;


DROP FUNCTION TOD5M(TIMESTAMP WITHOUT TIME ZONE);
CREATE FUNCTION TOD5M (ts timestamp WITHOUT TIME ZONE) RETURNS TIME AS $$
DECLARE
BEGIN
	RETURN to_timestamp(trunc (extract(EPOCH FROM  TOD(ts)+(interval '0:2:30'))/300)*300);
END;
$$ LANGUAGE plpgsql;
 UPDATE Tedprimaries SET Production = pac FROM Producton_FTP
 WHERE Production_FTP."Date"=DayOnly(Tedprimaries.created_at) AND Production_FTP.timestamp = TOD5M(Tedprimaries.created_at);

CREATE VIEW ProdFTPNoiseByTime AS
 select r1.timestamp,stddev(r1.pac-r2.pac) as dpac 
 from production_ftp as r1,production_ftp as r2 
 where r1."Date"=r2."Date" and r1.timestamp=r2.timestamp+(interval '0:5:00') 
 group by r1.timestamp
 ORDER BY Timestamp;

-- if 300<consumption<2000 approximate normal limits
-- 0 < production < 3500
-- 0 < total_powernow < 3500
-- total_powernow=|consumption-production| ambigity of TED sign
-- consumption>production then sign=true, consumption=total_powernow+production, 300<total_powernow+production<2000
--consumption<production then sign=false, consumption=production-total_powernow, 300 < production-total_powernow<2000
-- 
-- Total_powernow>production then not net metering, sign=true
-- Total_powernow<production then  net metering, sign=false?
-- Total_powernow near zero sign ambiguous unless production>1000 or total_powernow+production>2000. sign=false


drop view prodnoisebytime;

CREATE View Daily_Totals AS
select "Date",
 max(pac) as PeakKW,
 max(e_total) AS Total_KWH,
 Max(h_on) AS Total_On 
from production_FTP 
group by "Date" 
order by "Date";

CREATE VIEW Daily_Changes AS
 select r1."Date",
r1.PeakKw as peakKW1,
r2.peakKW as PeakKW2,
r2.Total_KWH-r1.Total_KWH AS KWH,
r2.total_on-r1.total_on as Hours_On 
from Daily_Totals as r1,Daily_totals as r2 
where r1."Date"=r2."Date"-(Interval '1 day');

CREATE VIEW ProdPeriod AS
 select timestamp,
avg(pac) AS AvgKW,
max(pac)-avg(pac) as headroom,
(avg(pac)*count(*)-min(Pac))/(count(*)-0.99999999999) as trimmed, 
max(pac) AS MaxKW,
count(*)
from production_ftp 
group by timestamp 
order by timestamp;

CREATE VIEW MaxProduction AS
SELECT max(pac) AS MaxKW 
FROM Production_FTP;

DROP VIEW ProdWithPeriod;
create view ProdWithPeriod as 
select  
"Date",
production_ftp.timestamp,
pac,
avgkw,
headroom,
trimmed,
maxkw,
h_on,
h_total,
e_total 
from production_FTP,ProdPeriod 
where production_FTP.timestamp=ProdPeriod.timestamp;

DROP VIEW Huge_Anomalies;
CREATE VIEW Huge_Anomalies AS
select to_hex(total_powernow>>12) AS pContaminant,
	to_hex(total_powernow) as pHex,
	to_hex(total_kva>>12) as kContaminant,
	to_hex(total_kva) AS kHex,
	to_hex((total_powernow|total_kva)>>12) AS orMask,
	to_hex((total_powernow|total_kva)>>20) AS negMask,
	to_hex(abs((total_powernow&4095)-(total_KVA&4095))) as dif0,
	to_hex(abs((total_powernow&4095)-(~total_KVA&4095))) as dif1,
	to_hex(abs(~(total_powernow&4095)-(total_KVA&4095))) as dif2,
	to_hex(abs((~total_powernow&4095)-(~total_KVA&4095))) as dif3 
from tedprimaries;

DROP TABLE nodes;
CREATE TABLE nodes
(
  node integer,
  description character varying(255),
  parent_node integer,
  parent_description character varying(255)
);
alter table nodes add primary key (description);

DROP TABLE Breakers;
CREATE TABLE breakers
(
  volts integer,
  amps integer,
  measured_load integer
) inherits (nodes);

INSERT INTO breakers 
select distinct  breaker as node,
 label as description,
 volts,
 phase as parent_description,
 amps,
 measured_load 
from loads1nf;

DROP TABLE wired_locations;
CREATE TABLE wired_locations
(
  room character varying(255),
  wall character varying(255),
  "type" character varying(255),
  ground_test_light boolean
) INHERITS (nodes);

INSERT INTO wired_locations
select DISTINCT 
 wired_location.id AS node,
 description,
 loads1nf.breaker as parent_node,
 loads1nf.label as parent_description,
 wired_location.room,
 wired_location.wall,
 wired_location.type,
 wired_location.ground_test_light=1 as ground_test_light 
from wired_location left join loads1nf
ON (wired_location.id=loads1nf.wired_location)
WHERE wired_location.plug_in_location IS  NULL
UNION select DISTINCT 
 r1.id AS node,
 r1.description,
 r1.plug_in_location as parent_node,
 r2.description as parent_description,
 r1.room,
 r1.wall,
 r1.type,
 r1.ground_test_light=1 as ground_test_light 
from wired_location as r1 left join wired_location AS r2
ON (r1.plug_in_location=r2.id) 
WHERE r1.plug_in_location IS NOT NULL;

DROP TABLE Loads;
CREATE TABLE loads
(
  plug_in_location integer,
  x_10_address character varying(255),
  "volatile" boolean,
  daylight_savings_adjustment boolean,
  timer_savings boolean,
  motion_savings boolean,
  bedtime_savings boolean,
  away_savings boolean,
  background boolean,
  computer_common boolean,
  audio_video boolean,
  recorder boolean,
  plug_width character varying(255)
) INHERITS (nodes);

INSERT INTO Loads 
select 
 load_id AS node,
 loads1.description,
 wired_location as parent_node,
 wired_location.description as parent_description,
 plug_in_location,
 x_10_address,
 volatile=1 AS volatile,
 daylight_savings_adjustment=1 AS daylight_savings_adjustment,
 tmer_savings=1 AS timer_savings,
 motion_savings=1 AS motion_savings,
 bedtime_savings=1 AS bedtime_savings,
 away_savings=1 AS away_savings,
 background=1 AS background,
 computer_common=1 AS computer_common,
 audio_video=1 AS audio_video,
 recorder=1 AS recorder,
 plug_width 
from loads1 left outer join wired_location 
ON (wired_location=id);


DROP TABLE measurements;
create TABLE measurements as 
select   description,
 load_measurement,
 load,
 power_factor,
 period,
 duty_cycle_measurement,
 duty_cycle,
 load_id,
 va,
 mode 
from loads1;
alter table measurements alter load type real;
alter table measurements alter power_factor type real;
alter table measurements alter duty_cycle type real;
alter table measurements drop va;
 alter table measurements add va real;


DROP VIEW nodes;
CREATE TABLE nodes AS
SELECT
  description,
  node,	
  parent_description,
  parent_node,
  'loads' AS level
FROM Loads
UNION SELECT
  description,
  node,	
  parent_description,
  parent_node,
  'wired_locations' AS level
FROM wired_locations
UNION SELECT
  description,
  node,	
  parent_description,
  parent_node,
  'breakers' AS level
FROM Breakers
 ;

DROP view railsTypes;
create view railsTypes AS  
select 
 table_catalog,
 table_name,
 column_name,
 data_type,
 rails_type  
from information_schema.columns, postgresql2rails 
where data_type=postgresql_type and table_schema='public';

DROP view clean_data;
create view clean_data as 
select  * 
from tedprimaries 
where outlier<511
and switched_state is not null 
and production=0
and noise<1000
;
create view sunnywebboxip as select ip from ports where portName='hermes';
create view tedip as select ip from network where otherports=1714 and otherstate='filtered';

select outlier,count(outlier) from tedprimaries group by outlier order BY outlier;


