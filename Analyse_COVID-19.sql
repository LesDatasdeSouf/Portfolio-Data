
-- Shows likelihood of dying if you contract covid in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
where location like '%France%'
ORDER BY 1, 2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
SELECT Location, date, total_cases, Population, (total_cases/Population)*100 as GotCovid
FROM PortfolioProject..CovidDeaths
where location like '%France%'
ORDER BY 1,2

-- Looking at countries with highest infection rate compared to population
SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/Population))*100 as GotCovid
FROM PortfolioProject..CovidDeaths
-- where location like '%France%'
Group by Location, Population
ORDER BY GotCovid desc

-- LET'S BREAK THINGS DOWN BY CONTINENT


-- Showing countries with highest Death Count per Population
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
-- where location like '%France%'
Where continent is not null
Group by continent
ORDER BY TotalDeathCount desc

-- GLOBAL NUMBERS

-- Chiffres France total
SELECT SUM(new_cases) as total_cases, SUM(cast(total_deaths as int)) as total_death, SUM(cast(total_deaths as int))/SUM(total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
where location like '%France%'
-- WHERE continent is not null
ORDER BY 1, 2


-- Looking at Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated --, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVacc vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2, 3

-- USE CTE method
With PopvsVacc (continent, location, date, population,new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated --, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVacc vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
)

Select *, (RollingPeopleVaccinated/population)*100
From PopvsVacc

-- TEMP TABLE method

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated --, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVacc vac
	On dea.location = vac.location
	and dea.date = vac.date
-- WHERE dea.continent is not null
ORDER BY 2, 3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

CREATE VIEW PercentPopVacc as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated --, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVacc vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
-- ORDER BY 2, 3
