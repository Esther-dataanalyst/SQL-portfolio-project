SELECT *
FROM [Portfolio Project]..CovidDeaths
Where continent is null
ORDER BY 3,4

--SELECT *
--FROM [Portfolio Project]..CovidVaccinations
--ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project]..CovidDeaths
Where continent is null
ORDER BY 1,2

--Total cases vs total deaths

SELECT location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM [Portfolio Project]..CovidDeaths
Where continent is null
ORDER BY 1,2

 --The likelihood of dying if you contract COVID in Africa

SELECT location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM [Portfolio Project]..CovidDeaths
WHERE location like 'Kenya%'
and continent is not null
ORDER BY 1,2

--Total cases vs Population
--Shows the percentage population that got Covid

SELECT location, date, population,total_cases,  (total_cases/population)*100 as CasePercentage
FROM [Portfolio Project]..CovidDeaths
--WHERE location like 'Kenya%'
Where continent is not null
ORDER BY 1,2

--Showing continents with highest infection rate compared to population

SELECT continent, population, MAX(total_cases) as HighestInfectionCount,  MAX((total_cases/population))*100 as PercentageofPopulationInfected
FROM [Portfolio Project]..CovidDeaths
--WHERE location like 'Kenya%'
Where continent is not null
GROUP BY continent,population
ORDER BY PercentageofPopulationInfected desc

--Showing countries with highest death count per population

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM [Portfolio Project]..CovidDeaths
--WHERE location like 'Kenya%'
Where continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc

--BY CONTINENT

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM [Portfolio Project]..CovidDeaths
--WHERE location like 'Kenya%'
Where continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc


--Showing continents with highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM [Portfolio Project]..CovidDeaths
--WHERE location like 'Kenya%'
Where continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

--GLOBAL NUMBERS


SELECT SUM(new_cases) as total_cases, SUM(Cast (new_deaths as int)) as total_deaths, SUM(Cast (new_deaths as int))/ SUM(new_cases)*100 as DeathPercentage
FROM [Portfolio Project]..CovidDeaths
--WHERE location like 'Kenya%'
WHERE continent is not null
ORDER BY 1,2

SELECT date, SUM(new_cases) as total_cases, SUM(Cast (new_deaths as int)) as total_deaths, SUM(Cast (new_deaths as int))/ SUM(new_cases)*100 as DeathPercentage
FROM [Portfolio Project]..CovidDeaths
--WHERE location like 'Kenya%'
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

--Total Population vs Vaccinations


SELECT dea.continent, dea.location, dea.date, dea. population, vac.new_vaccinations
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
  WHERE dea. continent is not null
ORDER BY 2,3


--USING CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea. population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
  WHERE dea. continent is not null
--ORDER BY 2,3
)
SELECT*,(RollingPeopleVaccinated/population)*100
FROM PopvsVac


--Temp Table

DROP TABLE if exists #PercentagePopulationVaccinated
CREATE TABLE #PercentagePopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric,
)

INSERT INTO #PercentagePopulationVaccinated 
SELECT dea.continent, dea.location, dea.date, dea. population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
  --WHERE dea. continent is not null
--ORDER BY 2,3
SELECT*,(RollingPeopleVaccinated/population)*100
FROM #PercentagePopulationVaccinated



--Creating view to store data for later visualizations

CREATE VIEW PercentagePopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea. population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
  WHERE dea. continent is NOT null
  --ORDER BY 2,3

  SELECT*
  FROM PercentagePopulationVaccinated