SELECT * 
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is NOT NULL
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject.dbo.CovidVaccinations
--ORDER BY 3,4

-- Select Data we will be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract Covid in your country 

SELECT location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2


-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

SELECT location, date, population, total_cases, (CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))*100 as CovidPercentage
FROM PortfolioProject.dbo.CovidDeaths
-- WHERE location = 'Singapore'
ORDER BY 1,2


-- Looking at Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, (CONVERT(float, max(total_cases)) / NULLIF(CONVERT(float, population), 0))*100 as PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
-- WHERE location = 'Singapore'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC


-- Showing Countries with Highest Death Count per Population

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
-- WHERE location = 'Singapore'
WHERE continent is NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


-- Break things down by Continent
-- Showing Continents with Highest Death Count per Population 

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
-- WHERE location = 'Singapore'
WHERE continent is NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- Global Numbers

SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, (SUM(new_deaths)/SUM(new_cases))*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location like '%states%'
WHERE continent is NOT NULL 
--GROUP BY date
ORDER BY 1,2


-- Looking at Total Population vs Vaccinations

SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
, SUM(cast(Vac.new_vaccinations as bigint)) OVER (PARTITION BY Dea.location ORDER BY Dea.location, Dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths Dea
JOIN PortfolioProject..CovidVaccinations Vac
	ON Dea.location = Vac.location 
	and Dea.date = Vac.date
WHERE Dea.continent is NOT NULL and Dea.population is NOT NULL and Vac.new_vaccinations is NOT NULL
ORDER BY 2,3


-- USE CTE

WITH PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
, SUM(cast(Vac.new_vaccinations as bigint)) OVER (PARTITION BY Dea.location ORDER BY Dea.location, Dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths Dea
JOIN PortfolioProject..CovidVaccinations Vac
	ON Dea.location = Vac.location 
	and Dea.date = Vac.date
WHERE Dea.continent is NOT NULL and Dea.population is NOT NULL and Vac.new_vaccinations is NOT NULL
--ORDER BY 2,3
)
Select *, (RollingPeopleVaccinated/population)*100 as Percentage
FROM PopVsVac


-- TEMP TABLE

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
, SUM(cast(Vac.new_vaccinations as bigint)) OVER (PARTITION BY Dea.location ORDER BY Dea.location, Dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths Dea
JOIN PortfolioProject..CovidVaccinations Vac
	ON Dea.location = Vac.location 
	and Dea.date = Vac.date
WHERE Dea.continent is NOT NULL and Dea.population is NOT NULL and Vac.new_vaccinations is NOT NULL
ORDER BY 2,3

Select *, (RollingPeopleVaccinated/population)*100 as Percentage
FROM #PercentPopulationVaccinated


-- Creating View to store date for visualisations

CREATE VIEW PercentPopulationVaccinated as
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
, SUM(cast(Vac.new_vaccinations as bigint)) OVER (PARTITION BY Dea.location ORDER BY Dea.location, Dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths Dea
JOIN PortfolioProject..CovidVaccinations Vac
	ON Dea.location = Vac.location 
	and Dea.date = Vac.date
WHERE Dea.continent is NOT NULL and Dea.population is NOT NULL and Vac.new_vaccinations is NOT NULL
--ORDER BY 2,3


SELECT *
FROM PercentPopulationVaccinated