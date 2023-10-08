USE PortfolioProject;

SELECT * FROM CovidDeaths
WHERE continent is not null
ORDER BY 3,4;



SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
WHERE continent is not null
ORDER BY 1,2;


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you had contracted covid in a particular country

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE location LIKE '%india%' AND continent is not null
ORDER BY 1,2;



-- Looking at Total Cases vs Population
-- Shows what percentage of population got infected by Covid

SELECT Location, date, total_cases, population, (total_cases/population)*100 AS PercentPopulationInfected
FROM CovidDeaths
WHERE continent is not null
ORDER BY 1,2;



-- Looking at Countries with Highest Infection Rate Compared to Population

SELECT Location, MAX(total_cases) AS HighestInfectionCount, population, (MAX(total_cases)/population)*100 AS PercentPopulationInfected
FROM CovidDeaths
WHERE continent is not null
GROUP BY Location, population
ORDER BY PercentPopulationInfected desc;



-- Showing Countries with Highest Death Count 

SELECT Location, MAX(cast(total_deaths AS INT)) AS MaxDeathCount
FROM CovidDeaths
WHERE continent is not null
GROUP BY Location
ORDER BY MaxDeathCount desc;



-- Showing continents with the highest death count 

SELECT continent, MAX(cast(total_deaths AS INT)) AS MaxDeathCount
FROM CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY MaxDeathCount desc;


-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS INT)) AS total_deaths, (SUM(cast(new_deaths AS INT))/SUM(new_cases))*100 AS DeathPercentage
FROM CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2;




-- Looking at Total Population  vs Vaccination
-- Shows Percentage of Population vaccinated at a place till a particular date 

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(cast(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
    ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3;

-- Using CTE to perform calculation on Partition By in previous query

WITH PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(cast(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
    ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *,(RollingPeopleVaccinated/Population)*100 AS PercentPeopleVaccinated
FROM PopvsVac



-- Creating view to store data for later visulizations

Create View PercentPopulationVaccinated 
AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(cast(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
    ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null


Create View HighestDeathCountsbyContinent
AS
SELECT continent, MAX(cast(total_deaths AS INT)) AS MaxDeathCount
FROM CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY MaxDeathCount desc;


