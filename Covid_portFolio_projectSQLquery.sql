--death_percentage

select location,date,F6 as total_cases, total_deaths,
(total_deaths/F6)*100 as death_percentage,population 
from PortfolioDAProject..CovidDeaths 
where location like 'india'

--looking at percentage of population got effected
select location,date,F6 as total_cases, population, 
(F6 /population)*100 as percentage_population
from PortfolioDAProject..CovidDeaths 
where location like 'india'

--looking at countries with highest infection rate over population 

select location, population, MAX(F6 ) as highest_infection_rate,
max((F6 /population)*100) as percentage_population
from PortfolioDAProject..CovidDeaths 
group by location,population 
order by percentage_population desc

--Highest Death count in countries with population 

select location,population,max(cast(total_deaths as int)) as total_deathcount,
max((total_deaths/population)*100) as Highest_deathrate  
from PortfolioDAProject..CovidDeaths
where continent is not null
group by location, population
order by total_deathcount desc

--lets breaks down continent wise

select continent,max(cast(total_deaths as int)) as total_deathcount,
max((total_deaths/population)*100) as Highest_deathrate  
from PortfolioDAProject..CovidDeaths
where continent is not null
group by continent
order by total_deathcount desc

-- continent with highest death count






select continent,max(cast(total_deaths as int)) as total_deathcount,
max((total_deaths/population)*100) as Highest_deathrate  
from PortfolioDAProject..CovidDeaths
where continent is not null
group by continent
order by Highest_deathrate  desc

-- all over the world
select sum(F6)as world_totalcases, sum(cast(total_deaths as int))as world_totaldeaths
from PortfolioDAProject..CovidDeaths 
where continent is not null
--Total population vs vaccinations
select dea.date,dea.location,dea.population,vac.total_vaccinations from PortfolioDAProject..CovidDeaths dea
join 
PortfolioDAProject..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date = vac.date 
where dea.continent is not null and dea.location like 'albania'




-- population vs vaccination
--CTE (COMMON TABLE EXPRESSION)
with popvsvacci(continent,location,population,date,new_vaccinations,total_vaccinated_count_so_far)
as
(
select dea.continent,dea.location,dea.population,dea.date,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over 
(partition by dea.location order by dea.date) as total_vaccinated_count_so_far
--(total_vaccinated_count_so_far/dea.location)*100
from PortfolioDAProject..CovidDeaths dea
join  PortfolioDAProject..CovidVaccinations vac
on dea.location=vac.location and dea.date = vac.date where vac.new_vaccinations is not null and dea.continent is not null
--order by dea.continent,dea.location
)
select * ,(total_vaccinated_count_so_far/population)*100 as vaccination_rate from popvsvacci


--TEMP TABLE
drop table if exists vaccine_percentage_rate
 
create table vaccine_percentage_rate
( 
continent nvarchar(255),
location nvarchar(255),
population numeric,
date datetime,
new_vaccinations numeric,
total_vaccinated_count_so_far numeric
)
insert into vaccine_percentage_rate
select dea.continent,dea.location,dea.population,dea.date,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over 
(partition by dea.location order by dea.date) as total_vaccinated_count_so_far
--(total_vaccinated_count_so_far/dea.location)*100
from PortfolioDAProject..CovidDeaths dea
join  PortfolioDAProject..CovidVaccinations vac
on dea.location=vac.location and dea.date = vac.date where vac.new_vaccinations is not null and dea.continent is not null
--order by dea.continent,dea.location

select * ,(total_vaccinated_count_so_far/population)*100 as vaccination_rate from vaccine_percentage_rate


create view vaccination_rates as

select dea.continent,dea.location,dea.population,dea.date,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over 
(partition by dea.location order by dea.date) as total_vaccinated_count_so_far
--(total_vaccinated_count_so_far/dea.location)*100
from PortfolioDAProject..CovidDeaths dea
join  PortfolioDAProject..CovidVaccinations vac
on dea.location=vac.location and dea.date = vac.date where vac.new_vaccinations is not null and dea.continent is not null
--order by dea.continent,dea.location
