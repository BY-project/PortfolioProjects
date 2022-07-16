-- Queries for Tableau Project

-- 1. Covid Total Stats

WITH global (Total_cases, Total_deaths) as
(
SELECT MAX(total_cases) AS Total_Cases, MAX(CAST(total_deaths AS int)) AS Total_Deaths
FROM CovidPortfolio.dbo.CovidDeaths
WHERE continent IS NULL and location = 'world'
)
SELECT *, (Total_deaths/Total_cases)*100 AS 'Case_Fatality_Rate'
FROM global


-- 2. Death count by continent

SELECT location, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM CovidPortfolio.dbo.CovidDeaths
WHERE continent IS NULL and location NOT IN ('World', 'European Union', 'International') and location NOT LIKE ('%income%')
GROUP BY location
ORDER BY TotalDeathCount DESC


-- 3. Percent Population infected

SELECT location, population, MAX(total_cases) AS Highest_Infection_Count, ROUND((MAX(total_cases/population)*100) ,2) AS 'PercentPopulationInfected'
FROM CovidPortfolio.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC


-- 4. Percent Population infected over time

SELECT location, population, date, MAX(total_cases) AS Highest_Infection_Count, ROUND((MAX(total_cases/population)*100) ,2) AS 'PercentPopulationInfected'
FROM CovidPortfolio.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population, date
ORDER BY PercentPopulationInfected DESC