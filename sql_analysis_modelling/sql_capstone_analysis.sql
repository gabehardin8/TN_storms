SELECT *
FROM fatalities

SELECT *
FROM locations

SELECT *
FROM storms

-- counties with the most fatalities
SELECT cz_name, COUNT(deaths_direct) AS fatalities
FROM storms INNER JOIN fatalities USING (event_id)
GROUP BY cz_name
ORDER BY fatalities DESC

SELECT begin_date_time,COUNT(deaths_direct) AS fatalities
FROM storms INNER JOIN fatalities USING(event_id)
ORDER BY fatalities DESC

SELECT cz_name, COUNT(event_narrative) as en
FROM storms
WHERE event_narrative LIKE '%road%'
GROUP BY cz_name
ORDER BY en DESC

SELECT 
	cz_name
	,COUNT(road_closures) AS road_closures
FROM storms
WHERE road_closures = 'True'
GROUP BY cz_name
ORDER BY road_closures DESC

SELECT 
	cz_name
	,COUNT(tree_damage) AS tree_damage
FROM storms
WHERE tree_damage = 'True'
GROUP BY cz_name
ORDER BY tree_damage DESC

SELECT 
	cz_name
	,COUNT(power_outage) AS power_outage
FROM storms
WHERE power_outage = 'True'
GROUP BY cz_name
ORDER BY power_outage DESC

SELECT *
FROM fatalities

SELECT SUM(deaths_direct)
FROM storms
