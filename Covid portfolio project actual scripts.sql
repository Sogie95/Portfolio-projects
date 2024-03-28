SELECT*
FROM [Portfolio Project]..[Covid deaths]
ORDER BY 3,4

--SELECT*
--FROM [Portfolio Project]..[Covid vaccinations]
--ORDER BY 3,4


SELECT Location,date,total_cases,new_cases,total_deaths,population
FROM [Portfolio Project]..[Covid deaths]
ORDER BY 1,2


--Looking at total cases vs Total deaths


SELECT 
    Location, 
    date, 
    TRY_CONVERT(INT, total_cases) AS total_cases, 
    TRY_CONVERT(INT, total_deaths) AS total_deaths,
    CASE 
        WHEN TRY_CONVERT(INT, total_cases) = 0 THEN NULL
        ELSE total_deaths / TRY_CONVERT(INT, total_cases)
    END AS mortality_rate
FROM 
    [Portfolio Project]..[Covid deaths]
ORDER BY 
    Location, 
    date;

	--Looking at total cases vs population
	--shows what population of people got infected

	SELECT
	  Location,
	  date,
	  TRY_CONVERT (INT, total_cases) AS total_cases,
	  TRY_CONVERT (INT, population) AS population,
	  CASE 
	      WHEN TRY_CONVERT(INT, total_cases) = 0 THEN NULL
		  ELSE population/ TRY_CONVERT(INT, total_cases)
       END AS Deathpercentage
FROM 
    [Portfolio Project]..[Covid deaths]
ORDER BY 
    Location,
	date;

	--Looking at countries with highest infection rate compared to population 

--	SELECT
--    Location,
--    date,
--    TRY_CONVERT(INT, total_cases) AS total_cases,
--    TRY_CONVERT(INT, population) AS population,
--    CASE 
--        WHEN TRY_CONVERT(INT, total_cases) = 0 THEN NULL
--        ELSE (TRY_CONVERT(INT, total_cases) * 100.0) / NULLIF(population, 0)
--    END AS percent_population_infected
--FROM 
--    [Portfolio Project]..[Covid deaths]
--WHERE
--Location LIKE '%Nigeria%'
--ORDER BY 
--    Location,
--    date;

-- Break things down by contintnet

SELECT Continent,MAX(CAST(Total_deaths AS INT)) AS Totaldeathcount
FROM [Portfolio Project]..[Covid deaths]
WHERE Continent is not null
GROUP BY Continent
ORDER BY Totaldeathcount desc


	SELECT
    SUM(TRY_CONVERT(INT, new_cases)) AS total_cases,
    SUM(TRY_CONVERT(INT, new_deaths)) AS total_deaths,
    CASE 
        WHEN SUM(TRY_CONVERT(INT, new_deaths)) = 0 THEN NULL
        ELSE (SUM(TRY_CONVERT(INT, new_cases)) * 100.0) / NULLIF(SUM(population), 0)
    END AS Deathpercentage 
FROM 
    [Portfolio Project]..[Covid deaths]
WHERE 
    Continent IS NOT NULL 
    -- AND Location LIKE '%Nigeria%'
ORDER BY 1, 2;


--Total Population vs Vaccinations

WITH popvsvac (continent,location, date, population,new_vaccinations, rollingpeoplevaccinated)
AS
(
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location) AS total_new_vaccinations
FROM
    [Portfolio Project]..[Covid deaths] dea
JOIN
    [Portfolio Project]..[Covid vaccinations] vac
ON
    dea.location = vac.location
    AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL

	)
	SELECT*, (rollingpeoplevaccinated/population)*100
	FROM popvsvac


	--Temp table

	CREATE TABLE #percentpopulationvaccinated
	(
	continent nvarchar (255),
	location nvarchar (255),
	date datetime,
	population numeric,
	new_vaccinations numeric,
	rollingpeoplevaccinated numeric
	)
INSERT INTO #percentpopulationvaccinated

	SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location) AS total_new_vaccinations
FROM
    [Portfolio Project]..[Covid deaths] dea
JOIN
    [Portfolio Project]..[Covid vaccinations] vac
ON
    dea.location = vac.location
    AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL
ORDER BY 
    2,3

SELECT*, (rollingpeoplevaccinated/population)*100
	FROM #percentpopulationvaccinated


	--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATION 


IF OBJECT_ID('Percentpopulationvaccinated', 'V') IS NOT NULL
    DROP VIEW Percentpopulationvaccinated;


CREATE VIEW Percentpopulationvaccinated AS
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CONVERT(BIGINT, ISNULL(vac.new_vaccinations, 0))) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rollingpeoplevaccinated
FROM
    [Portfolio Project]..[Covid deaths] dea
JOIN
    [Portfolio Project]..[Covid vaccinations] vac ON dea.location = vac.location
    AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL;

	SELECT*
	FROM Percentpopulationvaccinated
	










