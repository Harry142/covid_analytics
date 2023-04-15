select *
from PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL AND total_cases IS NOT NULL AND total_deaths IS NOT NULL
order by 3,4

-- select *
-- from PortfolioProject..CovidVaccinations$
-- order by 3,4

-- Select data that we are going to be using

select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths$
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in country
select Location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where Location like '%states%' and total_cases is not null and total_deaths is not null
order by 1,2


-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

select Location, date, Population, total_cases, (cast(total_deaths as float)/cast(Population as float))*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
-- where Location like '%states%'
order by 1,2


-- Looking at Countries with Highest Infection Rate compared to Population
SELECT Location, MAX(CAST(total_cases AS INT)) AS HighestInfectionCount, max((cast(total_cases as float)/cast(Population as float))*100) as PercentPopulationInfected
from PortfolioProject..CovidDeaths$
-- where Location like '%states%'
GROUP BY Location, population
ORDER BY PercentPopulationInfected DESC

--Showing Countries with Highest Death Count per Population

Select Location, Max(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
WHERE Location NOT IN ('High income', 'Upper middle income', 'Lower middle income')
GROUP BY Location
ORDER BY TotalDeathCount DESC

-- Showing continents with the highest death count per population
Select continent, Max(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC


--Global Numbers
SELECT date, SUM(CASE WHEN ISNUMERIC(total_cases) = 1 THEN CAST(total_cases AS INT) ELSE 0 END) AS total_cases_sum, 
              SUM(CASE WHEN ISNUMERIC(total_deaths) = 1 THEN CAST(total_deaths AS INT) ELSE 0 END) AS total_deaths_sum
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL 
GROUP BY date


-- Looking at total population vs vaccinations
with PopvsVac ( Location, Date, Population, TotalVaccinations) AS
(
	SELECT dea.location, dea.date, dea.population,
	SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location, dea.date) as TotalVaccinations
	FROM PortfolioProject..CovidDeaths$ dea
	JOIN PortfolioProject..CovidVaccinations$ vac
		ON dea.location = vac.location
		AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL AND vac.new_vaccinations IS NOT NULL
)
SELECT Location, Date, Population, TotalVaccinations, 
       FORMAT(CAST(TotalVaccinations AS FLOAT) / Population * 100, 'P2') AS VaccinationRate
FROM PopvsVac
GROUP BY Location, Date, Population, TotalVaccinations
ORDER BY Location, Date;


-- TEMP Table
IF OBJECT_ID('tempdb..#PercentPopulationVaccinated') IS NOT NULL
    DROP TABLE #PercentPopulationVaccinated;
CREATE TABLE #PercentPopulationVaccinated
(
    Continent nvarchar(255),
    Location nvarchar(255),
    Date datetime,
    Population numeric(18,2),
    New_vaccinations numeric(18,2),
    PercentPopulationVaccinated numeric(18,2)
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       (vac.new_vaccinations / dea.population) * 100 AS PercentPopulationVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL AND vac.new_vaccinations IS NOT NULL

SELECT *
FROM #PercentPopulationVaccinated;


SELECT Location, SUM((New_vaccinations / Population) * 100) AS PercentPopulationVaccinated
FROM #PercentPopulationVaccinated
GROUP BY Location;
-- some countries have a vaccination rate higher than 100%: People in the country have received more than one dose of the vaccine. In this case, the vaccination rate will be calculated based on the total number of doses given, not the number of people vaccinated.






