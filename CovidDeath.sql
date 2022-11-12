Select *
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--Order by 3,4

--Select data to be used

Select location,date,total_cases,new_cases,total_deaths,population
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 1,2

--Total Cases VS Total Deaths (Death percentage)
--shows the likelihood of dying if infected by covid in India (Currently 1.187%)
Select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as death_percentage
From PortfolioProject..CovidDeaths
Where location='India'
and continent is not null
Order by 2

--Total Cases VS Total Population
--How many percentage of population got covid (Currently 3.151%)
Select location,date,population,total_cases, (total_cases/population)*100 as percent_population_infected
From PortfolioProject..CovidDeaths
Where continent is not null
--Where location='India'
Order by 1,2

--Countries with highest infection rate compared to population 
Select location,population,max(total_cases) as highest_infection_count, max((total_cases/population))*100 as percent_population_infected
From PortfolioProject..CovidDeaths
--Where location='India'
Where continent is not null
Group by location, population
Order by percent_population_infected desc

--Countries with highest death count per population 
Select location, max(cast(total_deaths as int)) as total_death_count 
From PortfolioProject..CovidDeaths
--Where location='India'
Where continent is not null
Group by location
Order by total_death_count desc

--By continent 
--Continents with the highest death count per population

Select continent, max(cast(total_deaths as int)) as total_death_count 
From PortfolioProject..CovidDeaths
--Where location='India'
Where continent is not null
Group by continent
Order by total_death_count desc

-- Global Numbers

Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/ sum(new_cases)*100 as death_percentage
From PortfolioProject..CovidDeaths
--Where location='India'
where continent is not null
--Group by date
Order by 1,2


--CovidVaccinations
--Total population vs tota vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(Convert(bigint,vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, dea.date) as rolling_people_vaccinated
--(rolling_people_vaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
Where dea.continent is not null
Order by 2,3


-- Using CTE
With PopVsVac (Continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(Convert(bigint,vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, dea.date) as rolling_people_vaccinated
--(rolling_people_vaccinated/population)*100 as RpvVsPop
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
Where dea.continent is not null
--Order by 2,3
)
Select *, (rolling_people_vaccinated/population)*100 as RpvVsPop
From PopVsVac



--By using temp table
Drop table if exists #percent_population_vaccinated 
Create table #percent_population_vaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
)

Insert into #percent_population_vaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(Convert(bigint,vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, dea.date) as rolling_people_vaccinated
--(rolling_people_vaccinated/population)*100 as RpvVsPop
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
Where dea.continent is not null
--Order by 2,3
Select *, (rolling_people_vaccinated/population)*100 as RpvVsPop
From #percent_population_vaccinated


--Creating View to store data for visualisations

Create View percent_population_vaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(Convert(bigint,vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, dea.date) as rolling_people_vaccinated
--(rolling_people_vaccinated/population)*100 as RpvVsPop
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
Where dea.continent is not null
--Order by 2,3

Drop view if exists percent_population_vaccinated

Select *
From percent_population_vaccinated