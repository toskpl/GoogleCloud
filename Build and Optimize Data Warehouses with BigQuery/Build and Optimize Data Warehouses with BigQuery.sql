###########################################################################################################################################
--Task 1: Create a table partitioned by date
###########################################################################################################################################

Dataset ID : ecommerce


CREATE OR REPLACE TABLE ecommerce.sample 
PARTITION BY date 
OPTIONS ( partition_expiration_days=90,
description="COVID 19 data"
) AS 
SELECT * 
FROM bigquery-public-data.covid19_govt_response.oxford_policy_tracker 
WHERE alpha_3_code != 'USA' AND alpha_3_code != 'GBR'



###########################################################################################################################################
--Task 2: Add new columns to your table
###########################################################################################################################################


ALTER TABLE ecommerce.sample
ADD COLUMN IF NOT EXISTS population INT64,
ADD COLUMN IF NOT EXISTS country_area FLOAT64,
ADD COLUMN IF NOT EXISTS mobility STRUCT<
avg_retail FLOAT64,
avg_grocery FLOAT64,
avg_parks FLOAT64,
avg_transit FLOAT64,
avg_workplace FLOAT64,
avg_residential FLOAT64
>


##########################################################################################################################################
--Task 3: Add country population data to the population column
###########################################################################################################################################

UPDATE `<PROJECT_ID>.ecommerce.sample` count
SET count.population = count1.pop_data_2019
FROM `bigquery-public-data.covid19_ecdc.covid_19_geographic_distribution_worldwide` count1
WHERE count.date = count1.date AND count.alpha_3_code=count1.country_territory_code


###########################################################################################################################################
--Task 4: Add country area data to the country_area column
###########################################################################################################################################

UPDATE `<PROJECT_ID>.ecommerce.sample` count
SET count.country_area = count1.country_area
FROM `bigquery-public-data.census_bureau_international.country_names_area` count1
WHERE count.country_name = count1.country_name

##########################################################################################################################################
--Task 5: Populate the mobility record data
##########################################################################################################################################

UPDATE `<PROJECT_ID>.ecommerce.sample` count
SET count.mobility = STRUCT<
avg_retail FLOAT64, avg_grocery FLOAT64, avg_parks FLOAT64, avg_transit FLOAT64, avg_workplace FLOAT64, avg_residential FLOAT64
>
(count1.avg_retail, count1.avg_grocery, count1.avg_parks, count1.avg_transit, count1.avg_workplace, count1.avg_residential)
FROM ( SELECT country_region, date, 
      AVG(retail_and_recreation_percent_change_from_baseline) as avg_retail,
      AVG(grocery_and_pharmacy_percent_change_from_baseline)  as avg_grocery,
      AVG(parks_percent_change_from_baseline) as avg_parks,
      AVG(transit_stations_percent_change_from_baseline) as avg_transit,
      AVG( workplaces_percent_change_from_baseline ) as avg_workplace,
      AVG( residential_percent_change_from_baseline)  as avg_residential
      FROM `bigquery-public-data.covid19_google_mobility.mobility_report`
      GROUP BY country_region, date) AS count1
WHERE count.country_name = count1.country_region
AND count.date = count1.date

##########################################################################################################################################
--Task 6: Query missing data in population & country_area columns
##########################################################################################################################################

SELECT DISTINCT country_name
FROM `<PROJECT_ID>.ecommerce.sample`
WHERE population is NULL 
UNION ALL
SELECT DISTINCT country_name
FROM `<PROJECT_ID>.ecommerce.sample`
WHERE country_area IS NULL 
ORDER BY country_name ASC