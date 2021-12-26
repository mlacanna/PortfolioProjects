Select *
From PortfolioProjects..coviddeaths$
order by 3,4

--Select *
--From PortfolioProjects..covidvaccinations$
--order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProjects..coviddeaths$
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Likelihood of dying of Covid in your country
Select Location, date, total_cases, total_deaths, (Total_deaths/Total_cases) * 100 as DeathPercentage
From PortfolioProjects..coviddeaths$
--Where location like '%states%'
order by 1,2


-- Looking at Total Cases vs Population
-- Percentage that has recieved Covid
Select Location, date, Population, total_cases, (Total_cases/Population) *100 as InfectedPopulation
From PortfolioProjects..coviddeaths$
--Where location like '%states%'
order by 1,2



-- Highest infection rate by country population
Select Location, Population, MAX(total_cases) as HighestInfectionCount, Max((Total_cases/Population)) *100 as PercentPopulationInfected
From PortfolioProjects..coviddeaths$
Group By Location, population
Order by PercentPopulationInfected desc


--Countries with the Highest Death rate

Select Location, MAX(cast(Total_deaths as bigint)) as TotalDeathCount
From PortfolioProjects..coviddeaths$
Where continent is not null
Group By Location
Order by TotalDeathCount desc


--Continent with the Highest Death rate

Select location, MAX(cast(Total_deaths as bigint)) as TotalDeathCount
From PortfolioProjects..coviddeaths$
Where continent is null
Group By location
Order by TotalDeathCount desc


-- Continents with the highest death rate by population

Select continent, MAX(cast(Total_deaths as bigint)) as TotalDeathCount
From PortfolioProjects..coviddeaths$
Where continent is not null
Group By continent
Order by TotalDeathCount desc


--Global Numbers

Select date, SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(New_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProjects..coviddeaths$
where continent is not null
Group By date
order by 1,2

--Total amount of cases and death percentage
Select SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(New_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProjects..coviddeaths$
where continent is not null
order by 1,2



-- Total Population vs Vaccinations

With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RolldingVacinations)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingVaccinations
From PortfolioProjects..coviddeaths$ dea
Join PortfolioProjects..covidvaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RolldingVacinations/Population)*100 as Population_vaccinated
FROM PopvsVac



--creating view to store data for later visualizations, saving numbers

Create View PercentPopulationVaccinated as
With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RolldingVacinations)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingVaccinations
From PortfolioProjects..coviddeaths$ dea
Join PortfolioProjects..covidvaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RolldingVacinations/Population)*100 as Population_vaccinated
FROM PopvsVac


CREATE VIEW [CasesByPopulation] AS
Select Location, date, Population, total_cases, (Total_cases/Population) *100 as InfectedPopulation
From PortfolioProjects..coviddeaths$
--Where location like '%states%'
--order by 1,2

Select *
From PercentPopulationVaccinated