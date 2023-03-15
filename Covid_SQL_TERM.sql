--Skills used: Joins, CTE's, Temp Tables, Windows funtions, Aggregate functions, creating views, converting data types

Select *
From Portfolioproject..CovidDeaths$
where continent is not null
order by 3,4

--Select data that we are going to be starting with

Select location, date, total_cases, new_cases, total_deaths, population
from Portfolioproject..CovidDeaths$
where continent is not null
order by 1,2

--Shows likelihood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from Portfolioproject..CovidDeaths$
where location like '%states%'
and continent is not null
order by 1,2


--Shows what percentage of population infected with Covid

select location, date, population, total_cases, (total_deaths/population)*100 as DeathPercentage
from Portfolioproject..CovidDeaths$
--where location like '%states%'
order by 1,2

-- Countries with highest infection rate compared to population

select location, population, max(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as 
PercentPopulationInfected
from Portfolioproject..CovidDeaths$
group by location, population
order by PercentPopulationInfected desc

--countries with highest death count per population

select location, Max(cast(total_deaths as int)) as TotalDeathCount
from Portfolioproject..CovidDeaths$
where continent is null
group by location
order by TotalDeathCount desc

-- Showing continents with the highest death count per population

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from Portfolioproject..CovidDeaths$
where continent is not null
group by continent
order by TotalDeathCount desc

-- Global numbers

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
sum(cast(new_deaths as int))/sum(New_cases)*100 as DeathPercentage
from Portfolioproject..CovidDeaths$
where continent is not null
order by 1,2

--Shows Percentage of population that recieved at least on covid vaccine

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(Convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from Portfolioproject..CovidDeaths$ dea
join Portfolioproject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- using cte to proform calculation on partition by in previous query

with PopVsVac (Continent , Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(Convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from Portfolioproject..CovidDeaths$ dea
join Portfolioproject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopVsVac

-- Using temp table to preform calculation on partition by in pervious query

Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(Convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from Portfolioproject..CovidDeaths$ dea
join Portfolioproject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating view to store data for later visualizations

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
From Portfolioproject..CovidDeaths$ dea
join Portfolioproject..CovidVaccinations$ vac
		on dea.location = vac.location
		and dea.date = vac.date
where dea.continent is not null
