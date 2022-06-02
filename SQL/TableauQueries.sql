/* 

Queries used for Tableau Project 

*/

-- 1. 

select sum(new_cases) as TotalCases, sum(convert(int,new_deaths)) as TotalDeaths,
sum(convert(int, new_deaths))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
-- group by date
order by 1,2

-- Just a double check based off the data provided
-- numbers are close so we will keep them - The second includes "International" location

--select sum(new_cases) as TotalCases, sum(convert(int,new_deaths)) as TotalDeaths,
--sum(convert(int, new_deaths))/sum(new_cases)*100 as DeathPercentage
--from PortfolioProject..CovidDeaths
--where continent is not null
--and location = 'World'
---- group by date
--order by 1,2


-- 2.

--We take these out as they are not included in the above queries and want to stay consistent
--European Union is a part of Europe

select location, sum(convert(int, new_deaths)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is null
and location not in ('Upper middle income', 'High income', 'Lower middle income', 'Low income', 'World', 'European Union', 'International')
group by location
order by TotalDeathCount desc

-- 3.

select Location, Population,max(total_cases) as HighestInfectionCount
, max((total_cases/population))*100 as PercentPouplationInfected
from PortfolioProject..CovidDeaths
group by location, population
order by PercentPouplationInfected desc

-- 4.

select Location, Population, Date, max(total_cases) as HighestInfectionCount
, max((total_cases/population))*100 as PercentPouplationInfected
from PortfolioProject..CovidDeaths
group by location, population, date
order by PercentPouplationInfected desc
 