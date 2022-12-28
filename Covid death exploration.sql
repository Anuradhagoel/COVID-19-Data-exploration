
SELECT *
FROM coviddeath;

SELECT location, date,total_cases, new_cases, total_deaths, population
FROM coviddeath
WHERE continent is not null
ORDER BY 1,2;

--Looking at total cases v/s total deaths (% of people who died in the location)
SELECT location, date,total_cases, total_deaths, (total_deaths/total_cases)*100 AS Deathpercentage
FROM coviddeath
WHERE location LIKE '%states%'
AND continent is not null
ORDER BY 1,2;

--Looking at total cases v/s the population
-- shows what % of population has got covid
SELECT location, date,population,total_cases, (total_cases/population)*100 AS Casepercentage
FROM coviddeath
WHERE location LIKE '%states%'
AND continent is not null
ORDER BY 1,2;


--what countries have highest infection rate compared to population
SELECT location, population,MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM coviddeath
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;

--showing countries with highest death count per population
SELECT location, MAX(cast(total_deaths as int)) as Totaldeathcount
FROM coviddeath
WHERE continent is not null
GROUP BY location
ORDER BY Totaldeathcount DESC;

---Highest death count by continent
SELECT continent, MAX(cast(total_deaths as int)) as Totaldeathcount
FROM coviddeath
WHERE continent is not null
GROUP BY continent
ORDER BY Totaldeathcount DESC;


--Global analysis

---Number of cases globally with each date
SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as globaldeathpercentage
FROM coviddeath
where continent is not null
GROUP BY date
ORDER BY 1,2;

--2 table combination (total population vs vaccination)
-- percentage of people who have received atleast one vaccine
WITH popvac (continent, location, date, population, new_vaccinations, peoplevaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as peoplevaccinated 
FROM coviddeath dea
JOIN covidvaccine vac
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)

SELECT * , (peoplevaccinated/population)*100 as percentageofpeoplevaccinated
FROM popvac


--Creating view to store data for Tableau visulaizations
CREATE view Percentageofpopulationvaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as peoplevaccinated 
FROM coviddeath dea
JOIN covidvaccine vac
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent is not null

SELECT *
FROM Percentageofpopulationvaccinated

CREATE view percentageofpeoplewhogotcovid AS
SELECT location, date,population,total_cases, (total_cases/population)*100 AS Casepercentage
FROM coviddeath
WHERE location LIKE '%states%'
AND continent is not null
ORDER BY 1,2;
