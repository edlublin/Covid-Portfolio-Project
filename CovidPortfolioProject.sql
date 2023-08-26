-- Select Data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population from code
where location = 'United States'
and continent is not null
order by location, date 

--looking at Total_cases vs Total_death

select location, date, population, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage from code
where location ilike 'poland'
and continent is not null
order by date

--shows likelihood of dying if you contract covifd in your country

select location, date, total_cases, total_deaths, (nullif(total_cases, 0)/nullif(total_deaths, 0))*100 as DeathPercentage from code
where location ilike 'united states'
and continent is not null
order by date

--Shows us how % population got a covid


select location, date, population, total_cases, (total_cases/population)*100 as DeathPercentage from code
--where location ilike 'united states'
order by date

--Looking the country with highest infection rate

select location,  population, max(total_cases) as highestCount, max((total_cases/population))*100 as PercentPopulationInfected from code
--where location ilike 'united states'
GROUP by location, population
order by PercentPopulationInfected desc

--Let's breake things down by continent

select continent, max(total_deaths) as TotalDeathCount from code
--where location ilike 'united states'
where continent is not null
group by continent
order by TotalDeathCount desc

--showing countries with highest deaths count population

select location, max(total_deaths) as TotalDeathCount from code
--where location = 'united states'
where continent is not null
group by location
order by TotalDeathCount desc

--global numbers

select sum(new_cases) as total_cases, sum(new_deaths) as total_death,
sum(nullif(new_deaths, 0))/sum(nullif(new_cases,0))*100 as DeathPercenteage
from code
where continent is not null
--group by date
order by total_cases

--Looking total population vs vaccination

with popvsvac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as

(
select code.continent, code.location, code.date, code.population, cova.new_vaccinations,
sum(new_vaccinations) over(partition by code.location order by code.location, code.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from code
join cova on
code.location = cova.location
and code.date = cova.date
where code.continent is not null
--order by code.location, code.date
)

select *, (RollingPeopleVaccinated/population)*100 from popvsvac

-- TEMP TABLE

--drop table if exists PercentvsPopulationvaccinated
create table PercentvsPopulationvaccinated
(continent text,
 location text,
 date date,
 population NUMERIC,
 new_vaccination NUMERIC,
rollingpeoplevaccinated numeric
)

insert into PercentvsPopulationvaccinated
select code.continent, code.location, code.date, code.population, cova.new_vaccinations,
sum(new_vaccinations) over(partition by code.location order by code.location, code.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from code
join cova on
code.location = cova.location
and code.date = cova.date
where code.continent is not null
--order by code.location, code.date

select *, (RollingPeopleVaccinated/population)*100 from PercentvsPopulationvaccinated


--Creating View to store data for later visualizations

create view PercentPopulationVaccinated as
select code.continent, code.location, code.date, code.population, cova.new_vaccinations,
sum(new_vaccinations) over(partition by code.location order by code.location, code.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from code
join cova on
code.location = cova.location
and code.date = cova.date
where code.continent is not null
--order by code.location, code.date