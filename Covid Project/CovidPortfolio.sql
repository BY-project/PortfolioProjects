-- Covid 19 Data analysis

-- Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

SELECT *
FROM CovidPortfolio.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY location, date


-- Selecting the columns we are interested in

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidPortfolio.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY location, date

-- Calculating the case fatality rate 

SELECT location, date, total_cases, total_deaths, ROUND(((total_deaths / total_cases)*100), 2) AS 'Case_Fatality_Rate'
FROM CovidPortfolio.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY location, date

-- Calculating the percentage of the population infected with Covid

SELECT location, date, total_cases, total_deaths, (total_cases/population)*100 AS 'PercentPopulationInfected'
FROM CovidPortfolio.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY location, date

-- Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS Highest_Infection_Count, ROUND((MAX(total_cases/population)*100) ,2) AS 'PercentPopulationInfected'
FROM CovidPortfolio.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

-- Countries with Highest Death Count
SELECT location, MAX(CAST(total_deaths AS int)) AS Total_death_count
FROM CovidPortfolio.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY Total_death_count DESC

-- Grouping by continents instead
-- Showing contintents with the highest death count per population

SELECT continent, MAX(CAST(total_deaths AS int)) AS Total_death_count
FROM CovidPortfolio.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Total_death_count DESC

-- Global statistics

SELECT SUM(new_cases) as Total_cases, SUM(CAST(new_deaths AS int)) as Total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS 'Case_Fatality_Rate'
FROM CovidPortfolio.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Total Population vs Vaccinations with percentage of population that received at least one Covid vaccine 

SELECT DISTINCT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
SUM(CONVERT(bigint, cv.new_vaccinations)) OVER (Partition by cd.location ORDER BY cd.location, cd.date) AS Cumulative_vaccination
FROM CovidPortfolio.dbo.CovidDeaths cd
JOIN CovidPortfolio.dbo.CovidVaccination cv
ON cd.location = cv.location and cd.date = cv.date
WHERE cv.continent IS NOT NULL --and cd.location LIKE '%kingdom%'
ORDER BY 2, 3


-- Using CTE to perform Calculation on Partition By in previous query.
WITH PopvsVac (Continent, Location, Date, Population, New_vaccinations, Cumulative_vaccination) as
(
SELECT DISTINCT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
SUM(CONVERT(bigint, cv.new_vaccinations)) OVER (Partition by cd.location ORDER BY cd.location, cd.date) AS Cumulative_vaccination
FROM CovidPortfolio.dbo.CovidDeaths cd
JOIN CovidPortfolio.dbo.CovidVaccination cv
ON cd.location = cv.location and cd.date = cv.date
WHERE cv.continent IS NOT NULL -- and cd.location LIKE '%kingdom%'
--ORDER BY 2, 3
)
SELECT *, (Cumulative_vaccination/Population) *100
FROM PopvsVac
ORDER BY 2, 3


-- Alternatively using Temp Table to perform Calculation on Partition By in previous query
DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Cumulative_vaccination numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT DISTINCT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
SUM(CONVERT(bigint, cv.new_vaccinations)) OVER (Partition by cd.location ORDER BY cd.location, cd.date) AS Cumulative_vaccination
FROM CovidPortfolio.dbo.CovidDeaths cd
JOIN CovidPortfolio.dbo.CovidVaccination cv
ON cd.location = cv.location and cd.date = cv.date
WHERE cv.continent IS NOT NULL -- and cd.location LIKE '%kingdom%'
--ORDER BY 2, 3

SELECT *, (Cumulative_vaccination/Population) *100
FROM #PercentPopulationVaccinated
ORDER BY 2, 3


-- Creating View to store data for later visualizations

Create view PercentPopulationVaccinated as
SELECT DISTINCT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
SUM(CONVERT(bigint, cv.new_vaccinations)) OVER (Partition by cd.location ORDER BY cd.location, cd.date) AS Cumulative_vaccination
FROM CovidPortfolio.dbo.CovidDeaths cd
JOIN CovidPortfolio.dbo.CovidVaccination cv
ON cd.location = cv.location and cd.date = cv.date
WHERE cv.continent IS NOT NULL -- and cd.location LIKE '%kingdom%'
--ORDER BY 2, 3