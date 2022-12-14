Select *
From PortfolioProject..['Covid Deaths']
where continent is not null
Order by 3,4

--Select *
--From PortfolioProject..['Covid Vaccinations']
--Order by 3,4


--Select Data that we are going to be using
Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..['Covid Deaths']
where continent is not null
order by 1,2

-- Looking at Total Cases Vs Total Deaths
-- Shows likelihood of dying if you contact covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases*100) as DeathPercentage
From PortfolioProject..['Covid Deaths']
where location like '%india%'
and continent is not null
order by 1,2

-- Looking at Total Cases Vs Population
-- Shows what percentage of the population got covid
Select location, date, population, total_cases, total_deaths, (total_cases/population*100) as PercentPopulationInfected
From PortfolioProject..['Covid Deaths']
--where location like '%india%'
where continent is not null
order by 1,2

-- Looking at countries with Highest Infection Rate compared to Population
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population*100)) as PercentPopulationInfected
From PortfolioProject..['Covid Deaths']
--where location like '%india%'
where continent is not null
Group by location, population
order by PercentPopulationInfected desc

-- Showing countries with highest death count per population
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..['Covid Deaths']
--where location like '%india%'
where continent is not null
Group by location
order by TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT

-- Showing continents with the highesh death count per population
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..['Covid Deaths']
--where location like '%india%'
where continent is not null
Group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
From PortfolioProject..['Covid Deaths']
--where location like '%india%'
where continent is not null
--Group by date
order by 1,2

-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(BIGINT,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..['Covid Deaths'] dea
Join PortfolioProject..['Covid Vaccinations'] vac
	On  dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(BIGINT,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..['Covid Deaths'] dea
Join PortfolioProject..['Covid Vaccinations'] vac
	On  dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as VaccinatedPercent
from PopvsVac


-- TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(BIGINT,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..['Covid Deaths'] dea
Join PortfolioProject..['Covid Vaccinations'] vac
	On  dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 as VaccinatedPercent
From #PercentPopulationVaccinated


-- Creating View to store data for later Visualisations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(BIGINT,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..['Covid Deaths'] dea
Join PortfolioProject..['Covid Vaccinations'] vac
	On  dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
from PercentPopulationVaccinated