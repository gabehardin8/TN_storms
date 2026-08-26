[README.md](https://github.com/user-attachments/files/31335805/README.md)

# Are TN Counties Becoming More Vulnerable to Extreme Weather Over Time?

**Author:** Gabriel Hardin — Nashville Software School Data Analytics Capstone
**Dashboard file:** `Gabe_hardin_NSS_capstone.pbix` (Power BI Desktop)
**Contact:** gabehardin56@gmail.com

## Overview

This project started as an attempt to see whether Tennessee weather patterns reflected global climate-change trends, but the available data turned out to be too limited to support a question that broad. The question narrowed to something more answerable: how much damage do Tennessee counties experience because of storms, and how has that changed over time? Using the NOAA Storm Events database, storm reports were scored for severity and broken down by county and disaster type, with the goal of showing the distinct storm vulnerabilities of different TN counties in a way that's useful to government officials, policymakers, and county residents.

The finished product is a five-page Power BI dashboard covering the overall scale of storm damage and where it's headed, how county-level vulnerability has shifted since 2016, which disaster types drive damage in which regions, a month-by-month view of severity, and a closing set of conclusions and recommendations.

## Objectives

**What is the current impact of storms in TN (2016–2025), and how might that change?** The dashboard's opening page reports 171 fatalities and 698 injuries over the period, an average of $160,091 in damage per event, about 1.55K damage reports per year, and 62.11% of counties trending worse over time. A conservative damage projection — based only on property and crop damage — estimates a cumulative ~$4.76 billion in damages from 2026–2030 if the current trend continues, which the report frames as up to $4 billion in avoidable damage over five years if left unaddressed.

**How has county vulnerability to storms changed over time?** A statewide severity map, a per-county severity trend line, and a total-storms count are read together: the number of storms per year has stayed roughly flat (ranging from about 139 to 208), but the damage-severity trend and total damage incidents both show an upward trajectory, climbing to their highest points in 2024–2025. A ranked table of yearly rate-of-change highlights the counties gaining severity fastest, led by Lincoln, Henry, Lauderdale, Moore, and Franklin.

**What disaster types drive major damages in TN counties?** Damages are broken out three ways — economic (crop and property damage), human cost (deaths and injuries), and infrastructure (power outages and road closures) — each toggleable by disaster type. Tornadoes dominate economic damage (about $1.86B) and human cost, flash floods dominate infrastructure damage, and storms cluster heavily in summer and spring. The page's own takeaways: West and Middle TN are hit hardest by tornadoes and winter storms, West TN shows unusually uniform exposure to heat- and cold-related deaths, Davidson and Shelby counties see more average deaths from heat/cold than from tornadoes, and high winds in East TN drive outsized crop damage.

**How has damage severity changed over time?** A month-by-month severity view (filterable by year) surfaces two patterns worth flagging: a noticeable dip during the COVID years, plausibly tied to reduced development and social activity rather than reduced storm risk, and a recurring seasonal spike from May through June.

**What patterns and recommendations follow from the above?** The closing page concludes that while storm frequency is roughly constant, damage severity, the volume of damage reports, and county severity scores are all rising — suggesting counties are becoming more vulnerable, largely concentrated in cities due to population density. Davidson and Wilson counties are notable exceptions, having reduced their severity scores over time even as 62% of counties are worsening. West and Middle TN are called out as the clearest areas of opportunity (tornado exposure, heat/cold mortality, and winter road closures), alongside Sevier and Greene counties for wind-driven crop damage.

## Methodology

Severity scoring started from free-text incident narratives in the NOAA data, which didn't reliably flag structural outcomes like power loss or road closures as clean fields. Regex pattern matching (in a Python/Jupyter notebook) was used to scan those narratives for phrases like "power loss," "power outages," "road closure," and "road closed," turning that into a usable road-closure/power-outage flag per event. From there, each disaster report was assigned a percentile-based "damage severity" score between 0.0 and 1.0, combining road closures, power outages, fatalities, injuries, property damage, and crop damage into a single comparable measure.

For data modeling, the cleaned CSV data was loaded into PostgreSQL through pgAdmin 4, then restructured from a single flat file into a star schema — dimension tables for date, event type, and county surrounding a central storm-events fact table — using standard CREATE/DROP DDL. That modeled data was brought into Power BI Desktop, where the star schema powers the report's KPI cards, maps, trend charts, and toggleable metric views described above.

## Technologies Used

- **Python** (regex-based text mining in a Jupyter notebook) for deriving road-closure and power-outage flags from narrative text and building the damage-severity score
- **PostgreSQL / pgAdmin 4** for loading and modeling the data into a star schema
- **Power BI Desktop** for the reporting layer, including Azure Maps visuals, a decomposition tree, KPI cards, and field-parameter-driven toggles across the report's five pages
- **NOAA Storm Events Database** as the source dataset

## Dashboard

[View the dashboard export (PDF)](sql_analysis_modelling/Gabe_hardin_NSS_capstone1.pdf)

## Contact

Questions about this project can be directed to gabehardin56@gmail.com or https://www.linkedin.com/in/gabriel-hardin-8897683a4/
