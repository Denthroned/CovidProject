--SELECT *
--FROM PortolioProjects..CovidDeaths
--Order by 3,4

--SELECT*
--FROM PortolioProjects..CovidVaccinations
--Order by 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortolioProjects..CovidDeaths
Order by 1,2

--A Scope at total cases Vs Total Deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortolioProjects..CovidDeaths
WHERE Location like '%Nigeria%'
Order by 1,2

--Looking at the number of total cases against the population

SELECT location, population, date, total_cases, (total_cases/population)*100 AS DeathPercentage
FROM CovidDeaths
--WHERE Location like '%Nigeria%'
Order by 1,2

--A glance at total cases vs population showing the percentage of the population with covid

SELECT location, date, population, total_cases,  (total_cases/population)*100 AS DeathPercentage
FROM CovidDeaths
WHERE Location like '%Nigeria%'
Order by 1,2


--Countries with the highest infection rate

--SELECT location, Population, MAX(total_cases) AS HighestInfectionCount,  MAX((total_cases/population))*100 AS PercentofPopulationInfected
--FROM CovidDeaths
--GROUP BY location, population
--ORDER BY PercentofPopulationInfected DESC


--Countries with the highest death count per population

SELECT location, MAX(Cast(total_deaths as int)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent is NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--Continent with the Higgehst Death Count

SELECT location, MAX(Cast(total_deaths as int)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent is NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


--global Numbers

SELECT date, SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths as int)) AS TotalDeath, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE continent is not null
GROUP BY date 
ORDER BY 1,2

SELECT SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths as int)) AS TotalDeath, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE continent is not null

ORDER BY 1,2


--LOOKING AT VACCINATION RATE

SELECT *
FROM CovidDeaths AS Cdeath
JOIN CovidVaccinations AS CVacc
  ON Cdeath.location = CVacc.location
  AND Cdeath.date = CVacc.date


  --Vaccination rate in NIgeria
--SELECT cdeath.continent, cdeath.location,cdeath.date, cdeath.population, cvacc.new_vaccinations
--FROM CovidDeaths AS Cdeath
--JOIN CovidVaccinations AS CVacc
--  ON Cdeath.location = CVacc.location
--  AND Cdeath.date = CVacc.date
--  WHERE cdeath.continent is not null 
--  and cdeath.location like '%nigeria%'
--  ORDER BY 1,2,3

  
SELECT cdeath.continent, cdeath.location,cdeath.date, cdeath.population, cvacc.new_vaccinations
FROM CovidDeaths AS Cdeath
JOIN CovidVaccinations AS CVacc
  ON Cdeath.location = CVacc.location
  AND Cdeath.date = CVacc.date
  WHERE cdeath.continent is not null 
  ORDER BY 1,2

  SELECT cdeath.continent, cdeath.location, cdeath.date, cdeath.population, cvacc.new_vaccinations, 
  SUM(CAST(cvacc.new_vaccinations AS int)) OVER (Partition by cdeath.location ORDER BY cdeath.location, cdeath.date) AS TotalNoVaccinationPerDay
FROM CovidDeaths AS Cdeath
JOIN CovidVaccinations AS CVacc
  ON Cdeath.location = CVacc.location
  AND Cdeath.date = CVacc.date
  WHERE cdeath.continent is not null 
  ORDER BY 2,3

  --using CTE with TotalNoVaccinationPerDay to determine the number of vaccination against the number of population

  WITH VACPOP (continent, location, date, population, new_vaccination, TotalNoVaccinationPerDay) AS

  (
   SELECT cdeath.continent, cdeath.location, cdeath.date, cdeath.population, cvacc.new_vaccinations, 
  SUM(CAST(cvacc.new_vaccinations AS int)) OVER (Partition by cdeath.location ORDER BY cdeath.location, cdeath.date) AS TotalNoVaccinationPerDay
FROM CovidDeaths AS Cdeath
JOIN CovidVaccinations AS CVacc
  ON Cdeath.location = CVacc.location
  AND Cdeath.date = CVacc.date
  WHERE cdeath.continent is not null 
  )
  SELECT * ,(TotalNoVaccinationPerDay/Population)*100
  FROM VACPOP



  --creating a view for later

  CREATE VIEW PercentPopulation AS

  SELECT cdeath.continent, cdeath.location, cdeath.date, cdeath.population, cvacc.new_vaccinations, 
  SUM(CAST(cvacc.new_vaccinations AS int)) OVER (Partition by cdeath.location ORDER BY cdeath.location, cdeath.date) AS TotalNoVaccinationPerDay
FROM CovidDeaths AS Cdeath
JOIN CovidVaccinations AS CVacc
  ON Cdeath.location = CVacc.location
  AND Cdeath.date = CVacc.date
  WHERE cdeath.continent is not null 
  
