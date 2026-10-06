Use PortfolioProject
GO


Select *
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--Order by 3,4

-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order by 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if yo contact covid in your country

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
Order by 1,2


-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

Select Location, date,population, total_cases, (total_cases/population)*100 as PercentPoppulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Order by 1,2


-- Looking at Countries with Highest Infection Rate compared to Population

Select Location,population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPoppulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by location, population
Order by PercentPoppulationInfected desc


-- Showing Countries with Highest Death Count per Population

Select Location, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by location
Order by TotalDeathCount desc


-- LET'S BREAK THINGS DOWN BY CONTINENT

Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by continent
Order by TotalDeathCount desc


-- Showing continent with the highest death count per population

Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by continent
Order by TotalDeathCount desc


-- GLOBAL NUMBERS

Select Sum(new_cases)as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
--Group by date
Order by 1,2  

-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- USE CTE

With PopvsVac (Continet, Location, Date, Population,New_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 1,2
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

USE PortfolioProject;
GO

CREATE OR ALTER VIEW dbo.PercentPopulationVaccinated
AS

SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,

    SUM(CONVERT(int, vac.new_vaccinations)) 
        OVER (
            PARTITION BY dea.location 
            ORDER BY dea.location, dea.date
        ) AS RollingPeopleVaccinated

FROM PortfolioProject.dbo.CovidDeaths AS dea

JOIN PortfolioProject.dbo.CovidVaccinations AS vac
    ON dea.location = vac.location
    AND dea.date = vac.date

WHERE dea.continent IS NOT NULL;
GO

Select*
From PercentPopulationVaccinated