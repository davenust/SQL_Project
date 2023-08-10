--Covid-19 Portfolio Project: Using Nigeria as a Case Study
select *
from Portfolio_Project..CovidDeaths
where continent is not null
order by 1,2

--select *
--from Portfolio_Project..CovidVaccinnation
--order by 3,4

--Select Data we are going to be using
Select Location, date, total_cases, new_cases, total_deaths, population
from Portfolio_Project..CovidDeaths
order by 1,2

-- Total cases vs Total Deaths
-- Shows likelihood of dying if contacted Covid
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Percentage_of_Death
from Portfolio_Project..CovidDeaths
where location like '%state%'
where continent is not null
order by 1,2

-- Total Cases vs Populations: Percentation of population that has gotten covid
Select Location, date, total_cases, population, (total_cases/population)*100 as Percentage_of_Population
from Portfolio_Project..CovidDeaths
-- where location like '%Nigeria%'
where continent is not null
order by 1,2 desc

-- Countries with Highest infection rate compared to population
Select Location, population, max( total_cases) as HighestInfectionCount, Max(total_cases/population)*100 as PercentagePopulationInfected
from Portfolio_Project..CovidDeaths
group by Location, population
-- where location like '%Nigeria%'
order by PercentagePopulationInfected desc


-- Showing Countries with the Highest Death Count per Population
Select Location, max(cast(total_deaths as int)) as TotalDeathCount
from Portfolio_Project..CovidDeaths
where continent is not null
group by Location
-- where location like '%Nigeria%'
order by TotalDeathCount desc

-- LET'S BREAK DOWN BY CONTINENT
Select continent, max(cast(total_deaths as int)) as TotalDeathCount
from Portfolio_Project..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

-- Continent with the highest death counts
Select continent, max(cast(total_deaths as int)) as TotalDeathCount
from Portfolio_Project..CovidDeaths
where continent is not null
group by continent
-- where location like '%Nigeria%'
order by TotalDeathCount desc


--Global members
Select date, sum(new_cases) as TotalCases, sum(new_deaths) as TotalDeath, sum(new_deaths))/sum(new_cases)*100 as DeathPercentage
--total_deaths, -- (total_deaths/total_cases)*100 as Percentage_of_Death
from Portfolio_Project..CovidDeaths
-- where location like '%state%'
where continent is not null
group by date
order by 1,2


Select sum(new_cases) as TotalCases, sum(new_deaths) as TotalDeath, sum(new_deaths)/sum(new_cases)*100 as DeathPercentage
--total_deaths, -- (total_deaths/total_cases)*100 as Percentage_of_Death
from Portfolio_Project..CovidDeaths
-- where location like '%state%'
where continent is not null
group by date
order by 1,2

-- 
--- joining two table together
select *
from Portfolio_Project..CovidDeaths dea
join Portfolio_Project..CovidVacinnations vac
	on dea.location = vac.location
	and dea.date = vac.date

--- Total population vs vaccinations
select dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from Portfolio_Project..CovidDeaths dea
join Portfolio_Project..CovidVacinnations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


---CTE for the % of people vaccinated vs population
with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from Portfolio_Project..CovidDeaths dea
join Portfolio_Project..CovidVacinnations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac

--- TEMP TABLE
drop table if exists #PercentPopulationVaccinateds
CREATE TABLE #PercentPopulationVaccinateds
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinateds
select dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from Portfolio_Project..CovidDeaths dea
join Portfolio_Project..CovidVacinnations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from #PercentPopulationVaccinateds
