SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3, 4



--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3, 4


--Select Data that we are going to using

SELECT location, date, total_cases 
FROM PortfolioProject..CovidDeaths
ORDER BY 1, 2;


--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying or you contract covid in your country

SELECT location, date, total_cases,total_deaths, 
		(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS death_percentage
FROM PortfolioProject..covidDeaths
WHERE location LIKE 'Serbia'
ORDER BY 1,2


--Looking at Total Cases vs Population
--Shows what percentage of population got Covid

SELECT location, date, total_cases, population, 
		(CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)) * 100 AS population_percentage
FROM PortfolioProject..covidDeaths
WHERE location LIKE 'Serbia'
ORDER BY 1,2


SELECT location, population, 
		MAX(CONVERT(float, total_cases)) as highest_infection,
		MAX(CONVERT(float, total_cases/population))*100 as percent_pop_infected
FROM PortfolioProject..covidDeaths
--WHERE location LIKE 'Serbia'
GROUP BY location, population
ORDER BY percent_pop_infected DESC


--Showing Countries with highest death count per population

SELECT continent, 
		MAX(CONVERT(int, total_deaths)) as highest_deaths
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL  
GROUP BY continent
ORDER BY highest_deaths DESC


--Showing continents with the highest death count per population

SELECT continent, 
		MAX(total_deaths) as total_deaths_count,
		MAX(total_deaths/population)*100 as highest_deaths_perc
FROM PortfolioProject..covidDeaths
WHERE continent is not NULL
GROUP BY continent
ORDER BY highest_deaths_perc DESC


--Global numbers

SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths AS int)) as total_deaths,
		SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 as death_percentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
--GROUP BY date
ORDER BY 1,2

--CTE 
--Total Population vs Vaccinations

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, rolling_people_vac)
as 
(
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
	SUM(CONVERT(int, v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS rolling_people_vac
	--(rolling_people_vac/population)*100
FROM PortfolioProject..CovidDeaths d
JOIN PortfolioProject..CovidVaccinations v
ON d.location = v.location
AND d.date = v.date
WHERE d.continent is not NULL
--ORDER BY 2, 3
)
SELECT *, (rolling_people_vac/Population)*100
FROM PopvsVac



--TEMP TABLE

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
rolling_people_vac numeric
)

Insert into #PercentPopulationVaccinated
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
	SUM(CONVERT(int, v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS rolling_people_vac
	--(rolling_people_vac/population)*100
FROM PortfolioProject..CovidDeaths d
JOIN PortfolioProject..CovidVaccinations v
ON d.location = v.location
AND d.date = v.date
--WHERE d.continent is not NULL
--ORDER BY 2, 3

SELECT *, (rolling_people_vac/Population)*100
FROM #PercentPopulationVaccinated


--Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated as
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
	SUM(CONVERT(int, v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS rolling_people_vac
	--(rolling_people_vac/population)*100
FROM PortfolioProject..CovidDeaths d
JOIN PortfolioProject..CovidVaccinations v
ON d.location = v.location
AND d.date = v.date
WHERE d.continent is not NULL


SELECT * 
FROM PercentPopulationVaccinated