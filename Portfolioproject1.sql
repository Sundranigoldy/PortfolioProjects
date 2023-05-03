

--select *
--from PortfolioProject..covidvaccinations
--order by 3,4

-- Select Data what we are using
select location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject..coviddeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths
select location,date,total_cases,total_deaths, CAST(total_cases as float)/CAST(total_deaths as float)*100 as DEATHPercentage
from PortfolioProject..coviddeaths where location = 'INDIA'
order by 1,2

-- Looking for  Total cases vs populatiobn
select location,date,total_cases,population, CAST(total_cases as float)/CAST(population as float)*100 as InfectedPercentage
from PortfolioProject..coviddeaths where location = 'INDIA'
order by 1,2

-- Looking for countries with highest infection rate
select location,population,MAX(total_cases) as HighestInfectionCount, MAX(CAST((total_cases) as float)/CAST((population) as float))*100 as PercentagePopulationInfected
from PortfolioProject..coviddeaths
Group By location, population
order by 1,2

-- Showing COuntries having highest death counts
select location,MAX(total_deaths) as HighestDeathCount
from PortfolioProject..coviddeaths
Group By location
order by HighestDeathCount DESC

-- Joining both death and vaccination TABLES
select *
from PortfolioProject..coviddeaths dea
join PortfolioProject..covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date

-- Loking out for total population vs vaccincation
select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations
from PortfolioProject..coviddeaths dea
join PortfolioProject..covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not NULL
order by 1,2,3

-- Creating View for future visualization
create view PercentagePopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location,dea.date) as Rollingpeoplevaccinated
from PortfolioProject..coviddeaths dea
join PortfolioProject..covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not NULL
--order by 1,2,3