/*
Queries used for Tableu Project
*/

SELECT SUM(new_cases) AS total_cases, 
       SUM(CAST(new_deaths AS int)) AS total_deaths, 
       SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$

SELECT location, SUM(CAST(new_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NULL
  AND location NOT IN ('World','International','High income','Upper middle income','Lower middle income')
GROUP BY location
ORDER BY TotalDeathCount DESC

SELECT location, 
       population, 
       MAX(total_cases) AS HighestInfectionCount, 
       MAX((CAST(total_cases AS float)/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;


SELECT location, 
       population, 
       CONVERT(date, date) AS date,
       MAX(total_cases) AS HighestInfectionCount, 
       MAX((CAST(total_cases AS float)/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$
GROUP BY location, population, CONVERT(date, date)
ORDER BY PercentPopulationInfected DESC;

