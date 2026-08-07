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
 