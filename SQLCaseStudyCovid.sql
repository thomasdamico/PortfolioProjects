Select *
From PortfolioProject..CovidDeaths

-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelyhood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location = 'italy'
order by 1,2

-- Looking at the Total Cases vs Population
--Shows what percentage of population got Covid
Select Location, date,  population, total_cases, (total_cases/population)*100 as PercentPopultaionInfected
From PortfolioProject..CovidDeaths
--Where location = 'Italy'
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Popultaion
--Shows what percentage of population got Covid
Select Location, population, MAX(total_cases) AS HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopultaionInfected
From PortfolioProject..CovidDeaths
--Where location = 'Italy'
Group by Location, population
order by 4 desc

--LET'S BREAK THINGS DOWN BY CONTINENT
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is null AND location not in ('European Union', 'High income', 'International', 'Low income', 'Lower middle income', 'Upper middle income', 'World')
Group by location
order by TotalDeathCount desc

-- Showing Countries with the highest Death Count per Population
Select Location, Population, MAX(cast(total_deaths as int)) as TotalDeathCount, MAX(cast(total_deaths as int)/population)*100 as PercentPopultaionDeaths
From PortfolioProject..CovidDeaths
Where continent is not null
Group by Location, population
order by PercentPopultaionDeaths desc

-- Showing continents with the highest death count
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is null AND location not in ('European Union', 'High income', 'International', 'Low income', 'Lower middle income', 'Upper middle income', 'World')
Group by location
order by TotalDeathCount desc



-- GLOBAL NUMBERS 
Select date, SUM(new_cases) as TotalCasesAtThatDate, SUM(cast(new_deaths as int)) as TotalDeathsAtThatDate, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths 
--Where location = 'italy'
Where continent is not null and new_cases is not null
GROUP BY date
order by 1,2

Select SUM(new_cases) as TotalCasesAtThatDate, SUM(cast(new_deaths as int)) as TotalDeathsAtThatDate, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths 
--Where location = 'italy'
Where continent is not null and new_cases is not null
--GROUP BY date
order by 1,2



--Looking at Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, population, new_vaccinations
, SUM(convert(int, new_vaccinations)) OVER (Partition by dea.location ORDER By dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinates vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null and new_vaccinations is not null


-- USE TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date nvarchar (255),
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, population, new_vaccinations
, SUM(cast(new_vaccinations as bigint)) OVER (Partition by dea.location ORDER By dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinates vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null and new_vaccinations is not null

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated
ORDER BY Location

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, population, new_vaccinations
, SUM(cast(new_vaccinations as bigint)) OVER (Partition by dea.location ORDER By dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinates vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null and new_vaccinations is not null
