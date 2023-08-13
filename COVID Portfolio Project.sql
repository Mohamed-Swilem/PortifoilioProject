select*
from  PortifoilioProject .. CovidDeaths
where continent is not null
order by 3,4

select*
from  PortifoilioProject .. CovidVaccinations
order by 3,4

--select data that we are going to be using
select location,date,total_cases,new_cases,total_deaths,population
from  PortifoilioProject .. CovidDeaths
order by 1,2

--Looking at total_cases vs total_deaths
--show likelihood of dying if your contract covid in your country
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100  DeathesPercentage 
from  PortifoilioProject .. CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2

--Looking at Total cases vs Population
--Showbwhat Percentage of population got covid
select location,date,population,total_cases,(total_cases/population)*100  covidPercentage 
from  PortifoilioProject .. CovidDeaths
--where location like '%Egypt%'
where continent is not null
order by 1,2

--Loooking at countries with Highest Infection Rate compared to population
select location,population,Max(total_cases) HighestInfection,Max((total_cases/population))*100  
PercentagePopulationInfeted 
from  PortifoilioProject .. CovidDeaths
--where location like '%Egypt%'
where continent is not null
Group by location,population
order by PercentagePopulationInfeted desc

--Showing Countries with Highest Death Count Per Population
select location,Max(cast(total_deaths as int)) TotalDeathsCount 
 from  PortifoilioProject .. CovidDeaths
--where location like '%Europe%'
where continent is not null
Group by location
order by TotalDeathsCount desc

--Let`s Break Things Down By Continent
select location,Max(cast(total_deaths as int)) TotalDeathsCount 
 from  PortifoilioProject .. CovidDeaths
--where location like '%Europe%'
where continent is null
Group by location
order by TotalDeathsCount desc

--Showing continents with the highest death count per population
select continent,Max(cast(total_deaths as int)) TotalDeathsCount 
 from  PortifoilioProject .. CovidDeaths
--where location like '%Egypt%'
where continent is not null
Group by continent
order by TotalDeathsCount desc

--Global Number
select sum(new_cases) totalcases,sum(cast(new_deaths as int)) totaldeaths,sum(cast(new_deaths as int))/sum(new_cases)*100
as DeahtPercentage
from  PortifoilioProject .. CovidDeaths
--where location like '%states%'
where continent is not null
--Group by date
order by 1,2

--Looking at Total Population vs Vaccinations
with popvsvac(continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location
,dea.date) as RollingPeopleVaccinated
from  PortifoilioProject .. CovidDeaths dea
join  PortifoilioProject .. CovidVaccinations vac
     on dea.location=vac.location
	 and dea.date=vac.date
	 where dea.continent is not null
	 --order by 2,3
)
select*,(RollingPeopleVaccinated/population)*100
from popvsvac


--Temp Table
Drop table if exists #PercentagePopulationvaccinated
create table #PercentagePopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric,
)

insert into #PercentagePopulationvaccinated 
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location
,dea.date) as RollingPeopleVaccinated
from  PortifoilioProject .. CovidDeaths dea
join  PortifoilioProject .. CovidVaccinations vac
     on dea.location=vac.location
	 and dea.date=vac.date
	 --where dea.continent is not null
	 --order by 2,3
select*,(RollingPeopleVaccinated/population)*100
from #PercentagePopulationvaccinated

create View PercentagePopulationvaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location
,dea.date) as RollingPeopleVaccinated
from  PortifoilioProject .. CovidDeaths dea
join  PortifoilioProject .. CovidVaccinations vac
     on dea.location=vac.location
	 and dea.date=vac.date
	 where dea.continent is not null
	 --order by 2,3
select*
from PercentagePopulationvaccinated