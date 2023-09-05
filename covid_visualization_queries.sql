--First Visualization
--Word's total cases, total deaths, death percentage
SELECT
	SUM(new_cases) AS total_cases,
	SUM(new_deaths) AS total_deaths,
	SUM(new_deaths) / NULLIF(SUM(new_cases), 0) * 100 AS death_percentage
FROM covid_deaths
WHERE 
	continent IS NOT NULL
ORDER BY 1, 2

--Second Visualization 
--Showing Continents with Highest Death Count 
SELECT 
	continent, 
	SUM(new_deaths) as total_deaths
FROM covid_deaths
wHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_deaths DESC

--Third Visualization	
--Looking at Contries with Highest Infection Rate compare to Population by date
SELECT 
	location,
	population,
	MAX(total_cases) total_cases,
	(MAX(total_cases) / population) * 100 Cases_Percentage
FROM covid_deaths
WHERE 
	continent IS NOT NULL
GROUP BY 
	location,
	population
ORDER BY
	Cases_Percentage DESC
	
---Fourth Visualization
SELECT
	location, 
	population, 
	date,
	MAX(total_cases) as total_cases,
	MAX((total_cases/population))*100 percentpop
FROM covid_deaths
WHERE continent IS NOT NULL --AND location LIKE '%States'
GROUP BY location, population, date
ORDER BY percentpop DESC

--SAME RESULT
SELECT
	location, 
	population, 
	date,
	total_cases,
	MAX((total_cases/population))*100 percentpop
FROM covid_deaths
WHERE continent IS NOT NULL -- AND location LIKE '%States'
GROUP BY location, population, date, total_cases
ORDER BY percentpop DESC

--Fifth Visualization
-- Top five countries with more deaths
SELECT 
	location,
	MAX(total_deaths) As total_deaths,
	ROUND(MAX(total_deaths) / population * 100, 2) as percentafe_of_deaths
FROM covid_deaths
WHERE 
	continent IS NOT NULL AND total_deaths IS NOT NULL
GROUP BY 
	location, population
ORDER BY
	2 DESC
LIMIT 5

--Top 5 countries with date
SELECT *
FROM(
	SELECT location,
	EXTRACT(YEAR FROM date) AS year,
	EXTRACT(MONTH FROM date) AS month_num,
	TO_CHAR(date, 'Month') AS month,
	SUM(new_cases) AS total_cases,
	SUM(new_deaths) AS total_deaths,
	ROUND(SUM(new_deaths) / NULLIF(SUM(new_cases), 0) * 100, 2) AS percentafe_of_deaths
	FROM covid_deaths 
	GROUP BY location, year, month, month_num)AS mexico_per_year
WHERE location in ('United States', 'Brazil', 'India', 'Russia', 'Mexico')
ORDER BY location, year, month_num