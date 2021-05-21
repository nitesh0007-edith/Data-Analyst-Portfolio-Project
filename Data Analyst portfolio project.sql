select * 
from PortfolioProject..CovidDeaths
order by 3,4


----select * 
----from PortfolioProject..CovidVaccination
----order by 3,4

----selecting the data which we are going to use

select location,date,total_cases, new_cases,total_deaths,population
from PortfolioProject..CovidDeaths
order by 1,2

-- Looking at Total cases vs Total Death
-- showing likelihood of dying if you contract covid in your country
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS Death_Percentage
from PortfolioProject..CovidDeaths
where location='India'
order by 1,2

-- Looking at Total cases vs population in India
-- shows what percentage of population got infected
select location,date,population,total_cases,(total_cases/population)*100 AS Infected_Percentage
from PortfolioProject..CovidDeaths
where location='India'
order by 1,2

-- Looking at Countries with Highest Rate of Infection compared to Population
select location,population,MAX(total_cases) as Highest_Infection_count,MAX((total_cases/population))*100 AS Highest_Infected_Percentage
from PortfolioProject..CovidDeaths
Group by Location,Population 
order by Highest_Infected_Percentage desc

-- showing countries with highest death count per population
Select Location,Max(cast(total_deaths as int)) AS Highest_Death_Count
from PortfolioProject..CovidDeaths
where continent is not null
Group by location
order by Highest_Death_Count desc


Select Location,Population,Max(cast(total_deaths as int)) AS Highest_Death_Count, MAX((total_deaths/Population))*100 AS Highest_Death_Percentage
from PortfolioProject..CovidDeaths
where continent is not null
Group by location,population
order by Highest_Death_Percentage desc

-- Let's Break the Things Down by Continent


Select location,Max(cast(total_deaths as int)) AS Highest_Death_Count
from PortfolioProject..CovidDeaths
where continent is  null
Group by location
order by Highest_Death_Count desc

-- showing the countinents with the height death count
Select continent,Max(cast(total_deaths as int)) AS Highest_Death_Count
from PortfolioProject..CovidDeaths
where continent is not null
Group by continent
order by Highest_Death_Count desc


-- GLOBAl Numbers

select SUM(new_cases) as Total_Cases,sum(cast(new_deaths as int)) as Total_Deaths ,
sum(cast(new_deaths as int))/sum(New_cases)*100 as Death_Percentage
from PortfolioProject..CovidDeaths
--where location='India'
where continent is not null
--Group by Date
order by 1,2

-- looking at Total population vs vaccination
select d.continent,d.location,d.date,d.population,v.new_vaccinations,
sum(cast(v.new_vaccinations as int)) over (Partition by d.location 
order by d.location,d.date) as rollingPeopleVaccinated
--, (rollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths d
Join PortfolioProject..CovidVaccination v
on d.location=v.location
and d.date = v.date
where d.continent is not null
order by 1,2

-- USE CTE

with PopvsVac (Continenet,location,date,population,new_vaccinations
,rollingPeopleVaccinated)

as
(
select d.continent,d.location,d.date,d.population,v.new_vaccinations,
sum(cast(v.new_vaccinations as int)) over (Partition by d.location 
order by d.location,d.date) as rollingPeopleVaccinated
--, (rollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths d
Join PortfolioProject..CovidVaccination v
on d.location=v.location
and d.date = v.date
where d.continent is not null
--order by 1,2
)

select *,(rollingPeopleVaccinated/population)*100 
from PopvsVac


-- Temp Table

drop table if exists #PercentPopulationVaccinated  
create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
Population numeric,
New_Vaccination numeric,
RollingPeoplevaccinated numeric
)

Insert into #PercentPopulationVaccinated
select d.continent,d.location,d.date,d.population,v.new_vaccinations,
sum(cast(v.new_vaccinations as int)) over (Partition by d.location 
order by d.location,d.date) as rollingPeopleVaccinated
--, (rollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths d
Join PortfolioProject..CovidVaccination v
on d.location=v.location
and d.date = v.date
--where d.continent is not null
--order by 1,2

select *,(rollingPeopleVaccinated/population)*100 
from #PercentPopulationVaccinated


-- creating view to store data for later visualization

--drop view if exists PercentPopulationVaccinated
Create view PercentPopulationVaccinated as
select d.continent,d.location,d.date,d.population,v.new_vaccinations,
sum(cast(v.new_vaccinations as int)) over (Partition by d.location 
order by d.location,d.date) as rollingPeopleVaccinated
--, (rollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths d
Join PortfolioProject..CovidVaccination v
on d.location=v.location
and d.date = v.date
where d.continent is not null
--order by 1,2

--drop view PercentPopulationVaccinated