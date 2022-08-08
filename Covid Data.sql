Select *
From ProtfolioProject ..['Covid-Deaths']
Where continent is not null
order by 3,4

--Select *
--From ProtfolioProject ..['Covid-Vaccinations']
--order by 3,4

-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From ProtfolioProject .. ['Covid-Deaths']
order by 1,2

-- Looking at Total Cases vs Total Deaths

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From ProtfolioProject .. ['Covid-Deaths']
Where location like '%Pakistan%'
order by 1,2

-- Looking at Total Cases vs Population 
-- shows what population has gotten covid

Select Location, date, total_cases, population, (total_cases/population)*100 as PercentofPopulation
From ProtfolioProject .. ['Covid-Deaths']
Where location like '%Pakistan%'
order by 1,2


-- Looking at Countries with Higest Infrection Rate compared to Population 
Select Location,Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentofPopulationInfected
From ProtfolioProject .. ['Covid-Deaths']
--Where location like '%Pakistan%'
Group by Location, population
order by PercentofPopulationInfected desc

-- Break it down by contientent 
-- Showing Higest Death Count per Population 
Select continent, MAX(cast(total_deaths as bigint)) as TotalDeathCount
From ProtfolioProject .. ['Covid-Deaths']
Where continent is not null
Group by continent
order by TotalDeathCount desc


-- Showing Higest Death Count per Population 
Select Location, MAX(cast(total_deaths as bigint)) as TotalDeathCount
From ProtfolioProject .. ['Covid-Deaths']
Where continent is not null
Group by Location
order by TotalDeathCount desc

-- Global numbers

Select SUM(cast(new_cases as bigint)) as total_cases , SUM(cast(new_deaths as bigint)) as total_deaths, SUM(cast(new_deaths as int)) / SUM(new_cases)*100 as DeathPercentage 
From ProtfolioProject .. ['Covid-Deaths']
--where location like '%Pakistan%' 
where continent is not null
--Group by date
order by 1,2


-- Looking at total population vs Vaccination 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From ProtfolioProject ..['Covid-Deaths'] dea
Join ProtfolioProject ..['Covid-Vaccinations'] vac
ON dea.location = vac.location
AND dea.date = vac.date
where dea.continent is not null
order by 2,3


--USE CTE


With PopvsVac (Continent, Location, Date, Population , New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From ProtfolioProject ..['Covid-Deaths'] dea
Join ProtfolioProject ..['Covid-Vaccinations'] vac
	ON dea.location = vac.location
	AND dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--TEMP TABLE
DROP Table IF exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric,
)

Insert into #PercentPopulationVaccinated

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From ProtfolioProject ..['Covid-Deaths'] dea
Join ProtfolioProject ..['Covid-Vaccinations'] vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating View to store data for visualization

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From ProtfolioProject ..['Covid-Deaths'] dea
Join ProtfolioProject ..['Covid-Vaccinations'] vac
	ON dea.location = vac.location
	AND dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select * 
From PercentPopulationVaccinated