select * from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--select * from PortfolioProject..CovidVaccinations
--order by 3,4

-- Select Data
select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--Looking at total cases vs total deaths
--Shows likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location = 'india' and continent is not null
order by 1,2

-- Looking at total cases vs population
-- Shows what percentage of population got covid
select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location = 'india'
order by 1,2

-- Looking at countries with highest infection rate compared to population
select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location = 'india'
group by location, population
order by PercentPopulationInfected desc


-- Showing Countries with highest death count per population
select location, MAX(cast(total_deaths as int)) as HighestDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by HighestDeathCount desc


-- LET'S BREAK THINGS DOWN BY CONTINENT

-- Showing continents with the highest death count per population

select continent, MAX(cast(total_deaths as int)) as HighestDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by HighestDeathCount desc

-- Showing location with the highest death count per population

select location, MAX(cast(total_deaths as int)) as HighestDeathCount
from PortfolioProject..CovidDeaths
where continent is null
group by location
order by HighestDeathCount desc

-- GLOBAL NUMBERS

select date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
from PortfolioProject..CovidDeaths
-- where location = 'india' 
where continent is not null
group by date
order by 1,2


select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
from PortfolioProject..CovidDeaths
-- where location = 'india' 
where continent is not null
order by 1,2


-- JOINING DEATH AND VACCINATION TABLE

select * 
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date

-- Looking at Total Population VS Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(cast(vac.new_vaccinations as bigint)) 
OVER (Partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) *100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- Use CTE (Making a Temp Table)

with popvsvac(Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(cast(vac.new_vaccinations as bigint)) 
OVER (Partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) *100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population) * 100 as VaccinatedPopulationPercent
from popvsvac


-- TEMP TABLE

Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(cast(vac.new_vaccinations as bigint)) 
OVER (Partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) *100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population) * 100 as VaccinatedPopulationPercent
from #PercentPopulationVaccinated


--Creating view to store data for later visualisations

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(cast(vac.new_vaccinations as bigint)) 
OVER (Partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) *100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated