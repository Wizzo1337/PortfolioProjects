/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL
ORDER BY 3,4

-- Select Data that we are going to be starting with

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract COVID in your country

SELECT Location, date, total_cases, total_deaths, (total_deaths/CAST(total_cases AS float)) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'United States'
ORDER BY 1,2

-- Total Cases vs Population
-- Show what percentage of population got Covid

SELECT Location, date, population, total_cases, (CAST(total_cases AS float)/population) * 100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location = 'United States'
ORDER BY 1,2

-- Countries with Highest Infection Rate compared to Population

SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX(CAST(total_cases AS float)/population) * 100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location = 'United States'
GROUP BY Location, population
ORDER BY PercentPopulationInfected DESC

-- Countries with Highest Death Count per Population

SELECT Location, MAX(CAST(Total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location = 'United States'
WHERE continent is NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing continents with the highest death count per population

SELECT continent, MAX(CAST(Total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location = 'United States'
WHERE continent is NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- GLOBAL NUMBERS

SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/NULLIF(SUM(new_cases), 0) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location = 'United States'
WHERE continent is NOT NULL
--GROUP BY date
ORDER BY 1,2


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location,
  dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) * 100
FROM PortfolioProject..CovidDeaths AS dea
INNER JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is NOT NULL
ORDER BY 1, 2, 3


-- Using CTE to perform Calculation on Partition By in previous query

WITH PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location,
  dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) * 100
FROM PortfolioProject..CovidDeaths AS dea
INNER JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is NOT NULL
--ORDER BY 2, 3
)

SELECT *, (RollingPeopleVaccinated/Population) * 100
FROM PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location,
  dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) * 100
FROM PortfolioProject..CovidDeaths AS dea
INNER JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent is NOT NULL
--ORDER BY 2, 3

SELECT *, (RollingPeopleVaccinated/Population) * 100
FROM #PercentPopulationVaccinated



--Creating View to store data for later visualizations

CREATE View PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location,
  dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) * 100
FROM PortfolioProject..CovidDeaths AS dea
INNER JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is NOT NULL
--ORDER BY 1, 2, 3

SELECT *
FROM PercentPopulationVaccinated
