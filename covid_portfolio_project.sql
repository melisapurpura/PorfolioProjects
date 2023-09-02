-- Loking at Total Cases Vs Total Deaths
--Shows likelihood of dying if you contract covid in your country
SELECT
	Location,
	date, 
	total_cases,
	total_deaths,
	(total_deaths / total_cases) *100 AS Death_Percentage
FROM covid_deaths
WHERE location LIKE '%States%'
ORDER BY
	1, 2;
	
--Looking al Total Cases Vs Today's Population
SELECT
	location,
	date, 
	population,
	total_cases,
	(total_cases/population) * 100 AS Cases_Percentage
FROM covid_deaths
WHERE 
	continent IS NOT NULL --When the continent is null, the continent appear in the location colum, here we don't need continent as location
ORDER BY	
	1, 2;
	
--Looking at Contries with Highest Infection Rate compare to Population
SELECT 
	location,
	population,
	MAX(total_cases) total_cases,
	MAX((total_cases/population)) *100 Cases_Percentage
FROM covid_deaths
WHERE 
	continent IS NOT NULL
GROUP BY 
	location,
	population
ORDER BY
	Cases_Percentage DESC
	
--Showing Countries with Highest Death Count 
SELECT
	location,
	MAX(total_deaths) AS total_deaths
FROM covid_deaths
WHERE 
	continent IS NOT NULL AND total_deaths IS NOT NULL
GROUP by
	location
ORDER BY total_deaths DESC

--Showing Continents with Highest Death Count 
SELECT
	location,
	MAX(total_deaths) AS total_deaths
FROM covid_deaths
WHERE 
	continent IS NULL --Where the continent is null, the continent is in location
GROUP by
	location
ORDER BY total_deaths DESC
-- Almost the same result but now with a new_deaths SUM, instead total_deaths MAX. Should use this for Tableau
SELECT 
	continent, 
	SUM(new_deaths) as total_deaths
FROM covid_deaths
GROUP BY continent
ORDER BY total_deaths DESC

--Global Numbers
--World cases by date
SELECT
	date,
	SUM(new_cases)
FROM covid_deaths
WHERE 
	continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2

--World deaths by date
SELECT
	date,
	SUM(new_deaths)
FROM covid_deaths
WHERE 
	continent IS NOT NULL
GROUP BY 
	date
ORDER BY 1, 2

--World's death percentage per date
SELECT
	date,
	SUM(new_cases) AS total_cases,
	SUM(new_deaths) AS total_deaths,
	SUM(new_deaths) / NULLIF(SUM(new_cases), 0) * 100 AS death_percentage
FROM covid_deaths
WHERE 
	continent IS NOT NULL
GROUP BY
	date
ORDER BY 1, 2

--Word's total cases, total deaths, death percentage
SELECT
	SUM(new_cases) AS total_cases,
	SUM(new_deaths) AS total_deaths,
	SUM(new_deaths) / NULLIF(SUM(new_cases), 0) * 100 AS death_percentage
FROM covid_deaths
WHERE 
	continent IS NOT NULL
ORDER BY 1, 2

--Let's JOIN both tables
--Showing new vaccinations and cumulative vaccinations per location per date
SELECT 
	d.continent,
	d.location, 
	d.date,
	d.population,
	v.new_vaccinations,
	SUM(v.new_vaccinations) OVER (Partition by d.location ORDER BY d.location, d.date) AS cumulative_vaccinated
--(cumulative_vaccinated/population) * 100 We can't divide the column created
From covid_deaths AS d
JOIN covid_vaccinations AS v
ON d.location = v.location
AND d.date = v.date
WHERE
	d.continent IS NOT NULL


--We can solve the division problem with a CTE
--Percentage of People vaccinated. Take care with numbers more than 100% means more than 1 vaccine
With PopVsVac (continent, location, date, population, new_vaccinations, cumulative_vaccinated)
AS
	(SELECT 
		d.continent,
		d.location, 
		d.date,
		d.population,
		v.new_vaccinations,
	SUM(v.new_vaccinations) OVER (Partition by d.location ORDER BY d.location, d.date) AS cumulative_vaccinated
	From covid_deaths AS d
	JOIN covid_vaccinations AS v
	ON d.location = v.location
	AND d.date = v.date
	WHERE
		d.continent IS NOT NULL)
SELECT 
	location,
	continent,
	population,
	MAX(cumulative_vaccinated) total_vaccinated,
    MAX(cumulative_vaccinated)/ population * 100 AS percentage_vaccinated
FROM PopVsVac
GROUP BY 
	continent, 
	location,
	population
ORDER BY percentage_vaccinated DESC

-- Creating View to store data for later visualization
CREATE VIEW population_vaccinated AS
SELECT 
	d.continent,
	d.location, 
	d.date,
	d.population,
	v.new_vaccinations,
	SUM(v.new_vaccinations) OVER (Partition by d.location ORDER BY d.location, d.date) AS cumulative_vaccinated
From covid_deaths AS d
JOIN covid_vaccinations AS v
ON d.location = v.location
AND d.date = v.date
WHERE
	d.continent IS NOT NULL
ORDER BY 2, 3


