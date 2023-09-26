--SELECT*
--FROM PortofolioProject..CovidDeaths
--WHERE continent IS NOT NULL
--ORDER BY 3,4

--SELECT*
--FROM PortofolioProject..CovidVaccinations
--WHERE continent IS NOT NULL
--ORDER BY 3,4

-- Select the data that going to be use
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortofolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Looking at the total cases vs total deaths
-- Shows likelihood of dying in Indonesia
SELECT location, date, total_cases, total_deaths, (CONVERT(float, total_deaths)/NULLIF(CONVERT(float, total_cases),0))*100 AS DeathPercentage
FROM PortofolioProject..CovidDeaths
WHERE location like '%indonesia%'
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Looking at the total cases vs population
-- Shows the percentage of population that got covid in Indonesia
SELECT location, date, population, total_cases, (total_cases/population)*100 AS CasesPercentage
FROM PortofolioProject..CovidDeaths
WHERE location like '%indonesia%'
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Looking at the countries with the highest infection rate compared to population
SELECT location, population, MAX(total_cases) AS HighestInfectionRate, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortofolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

-- Looking at the countries with the highest death count compared to population
SELECT location, MAX(CAST(total_deaths AS bigint)) AS TotalDeathCount
FROM PortofolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Showing at the continent with the total death count
SELECT continent, MAX(CAST(total_deaths AS bigint)) AS TotalDeathCount
FROM PortofolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Global Numbers
SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortofolioProject..CovidDeaths
--WHERE location like '%indonesia%'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

-- Looking at total population vs vaccinations
-- Using CTE to perform Calculation on Partition By in previous query

WITH PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT death.continent, death.location, death.date, death.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS RollingPeopleVaccinated
FROM PortofolioProject..CovidDeaths AS death
JOIN PortofolioProject..CovidVaccinations AS vac
	ON death.location = vac.location
	AND death.date = vac.date
WHERE death.continent IS NOT NULL
--ORDER BY 1, 2, 3
)
SELECT*, (RollingPeopleVaccinated/population)*100 AS PercentageOfVaccinated
FROM PopVsVac


-- Looking at total population vs vaccinations
--Temp Table
DROP TABLE IF EXISTS #PercentagePopulationVaccinated
CREATE TABLE #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentagePopulationVaccinated
SELECT death.continent, death.location, death.date, death.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS RollingPeopleVaccinated
FROM PortofolioProject..CovidDeaths AS death
JOIN PortofolioProject..CovidVaccinations AS vac
	ON death.location = vac.location
	AND death.date = vac.date
WHERE death.continent IS NOT NULL

SELECT*, (RollingPeopleVaccinated/population)*100 AS PercentageOfVaccinated
FROM #PercentagePopulationVaccinated

--VIEW
--Creating View to Store data for visualizations
CREATE VIEW PercentagePopulationVaccinated AS
SELECT death.continent, death.location, death.date, death.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS RollingPeopleVaccinated
FROM PortofolioProject..CovidDeaths AS death
JOIN PortofolioProject..CovidVaccinations AS vac
	ON death.location = vac.location
	AND death.date = vac.date
WHERE death.continent IS NOT NULL

SELECT*
FROM PercentagePopulationVaccinated