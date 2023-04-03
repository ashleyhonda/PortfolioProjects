SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE total_deaths IS NOT Null
ORDER BY 1,2


--total cases vs total deaths for United States
--This query shows the likelihood of dying by COVID in the country of interest
--In April 2021, 1.78% or roughly 2% of those infected with COVID have died. 
SELECT location, date, ((total_deaths/total_cases)*100) as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE Location LIKE '%states%'
ORDER BY 1,2

--Total Cases vs Population
--Shows what percentage of the population got COVID at the end of April 2021
--At the end of April 2021, 9.77% or roughly 10% of the population in the United States contracted COVID
SELECT location, date, ((total_cases/population)*100) as CovidPercentage
FROM PortfolioProject..CovidDeaths
WHERE Location LIKE '%states%'
ORDER BY 1,2


--Looking at Countries with Highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) as HighInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER By PercentPopulationInfected desc

--Showing Countries with Highest Death Count per Population
--United States currently ranks the highest for death count 
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER By TotalDeathCount Desc


--LET'S BREAK THINGS DOWN BY CONTINENT

--Looking at which continent has the highest total death count
--Europe currently ranks highest for total death count
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is null 
GROUP BY continent
ORDER By TotalDeathCount Desc

--GLOBAL NUMBERS
--On April 30th, the death percentage was 1.66% or roughly 2% of people who had COVID died across the globe
SELECT date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(New_cases) * 100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

--Looking at COVID totals from the first report of COVID til April 30th, 2021
--2.11 or roughly 2% of the global population has died from COVID between the start of COVID and the reported end date.
SELECT SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(New_cases) * 100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

--Looking at total population vs vaccinations

--USE CTE
WITH PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by  dea.location ORDER BY dea.location, dea.date) as rollingpeoplevaccinated
FROM PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac
ON dea.location = vac.location 
AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population) * 100 as PopsVsVaccinated
FROM PopVsVac

--Create View to Store Data for Later Visualization

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by  dea.location ORDER BY dea.location, dea.date) as rollingpeoplevaccinated
FROM PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac
ON dea.location = vac.location 
AND dea.date = vac.date
WHERE dea.continent is not null

CREATE VIEW GlobalCasesVsDeath as
SELECT date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(New_cases) * 100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date

CREATE VIEW ContinentTotalDeathCount as
SELECT continent, MAX(cast(Total_deaths as int)) as TotalDeaths
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
Group By Continent

CREATE VIEW CasesVsPopulation as
SELECT location, date, ((total_cases/population)*100) as CovidPercentage
FROM PortfolioProject..CovidDeaths
WHERE Location LIKE '%states%'

CREATE VIEW CasesVsDeath as
SELECT location, date, ((total_deaths/total_cases)*100) as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE Location LIKE '%states%'

