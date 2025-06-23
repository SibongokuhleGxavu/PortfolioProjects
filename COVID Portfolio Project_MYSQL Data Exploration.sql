select *
from coviddeaths_1
-- Where continent is not null
order by 3,4;

-- select *
-- from covidvaccinations_1
-- order by 3,4;

select location, date, total_cases, new_cases, total_deaths, population
from coviddeaths_1
order by 1 ASC;

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in the United States

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100  as DeathPercentage
from coviddeaths_1
Where location like '%states%'
order by 1;

-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid

select location, date, total_cases, population,  (total_cases/population)*100  as PercentPopulationInfected
from coviddeaths_1
Where location like '%states%'
order by 1; 

-- Looking at Countries with Highest Infection Rate compared to Population

select location, population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population)*100) as PercentPopulationInfected
from coviddeaths_1
-- Where location like '%states%'
Where continent is not null
Group by location, population
order by PercentPopulationInfected DESC; 

-- Showiing Countries with Highest Death Count per Population

select location, MAX(cast(total_deaths as unsigned)) as TotalDeathCount
from coviddeaths_1
-- Where location like '%states%'
Where continent is not null
Group by location
order by TotalDeathCount DESC; 

-- LET'S BREAK THINGS DOWN BY CONTINENT
-- Showing continents with highedy death count per population

select continent, SUM(cast(total_deaths as unsigned)) as TotalDeathCount
from coviddeaths_1
-- Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount DESC; 

-- GLOBAL NUMBERS

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as unsigned)) as total_deaths, SUM(cast(new_deaths as unsigned))/SUM(new_cases)*100 DeathPercentage
From coviddeaths_1
-- Where location like '%states%'
Where continent is not null
Group by date
order by 2 ASC;

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as unsigned)) as total_deaths, SUM(cast(new_deaths as unsigned))/SUM(new_cases)*100 DeathPercentage
From coviddeaths_1
-- Where location like '%states%'
Where continent is not null
-- Group by date
order by 2 ASC;

-- Looking at Total Population vs Vaccination

Select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
  SUM(CAST(IFNULL(vac.new_vaccinations, 0) As unsigned)) 
    Over (
      Partition by dea.location Order by CAST(dea.date AS DATE) ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) As RollingPeopleVaccinated
From coviddeaths_1 dea
Join covidvaccinations_1 vac
  On dea.location = vac.location 
  And dea.date = vac.date
Where dea.continent is not null
Order by dea.location, CAST(dea.date AS DATE);

-- Use CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
As
(Select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
  SUM(CAST(IFNULL(vac.new_vaccinations, 0) As unsigned)) 
    Over (
      Partition by dea.location Order by CAST(dea.date AS DATE) ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) As RollingPeopleVaccinated
From coviddeaths_1 dea
Join covidvaccinations_1 vac
  On dea.location = vac.location 
  And dea.date = vac.date
Where dea.continent is not null
-- Order by dea.location, CAST(dea.date AS DATE)
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac;

-- Drop Table if exists

DROP Temporary Table if exists PercentPopulationVaccinated;

-- Create temp table
Create Temporary Table PercentPopulationVaccinated
 (
 continent varchar(255), 
 location varchar(255), 
 date datetime, 
 population numeric, 
 new_vaccinations numeric, 
 RollingPeopleVaccinated numeric
 );

Insert into PercentPopulationVaccinated 
Select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
  SUM(CAST(IFNULL(vac.new_vaccinations, 0) As unsigned)) 
    Over (
      Partition by dea.location Order by CAST(dea.date AS DATE) ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) As RollingPeopleVaccinated
From coviddeaths_1 dea
Join covidvaccinations_1 vac
  On dea.location = vac.location 
  And dea.date = vac.date;

Select *, (RollingPeopleVaccinated/Population)*100 As PercentagePeopleVaccinated
From PercentPopulationVaccinated;


-- Creating view to store data for later visualizations

Create view PercentPopulationVaccinated AS
Select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
  SUM(CAST(IFNULL(vac.new_vaccinations, 0) As unsigned)) 
    Over (
      Partition by dea.location Order by CAST(dea.date AS DATE) ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) As RollingPeopleVaccinated
From coviddeaths_1 dea
Join covidvaccinations_1 vac
  On dea.location = vac.location 
  And dea.date = vac.date
Where dea.continent is not null
-- Order by dea.location, CAST(dea.date AS DATE)




