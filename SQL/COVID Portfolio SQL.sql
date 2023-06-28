--------------------------------------------------------------------------------------------------------------------------------
SELECT *
	FROM PortfolioProject..CovidDeaths
	Where continent is not null
	ORDER BY 3,4

--SELECT *
--	FROM PortfolioProject..CovidVaccinations
--	ORDER BY 3,4

--Select data that we are going to be using

--------------------------------------------------------------------------------------------------------------------------------

SELECT	 Location, date, total_cases, new_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2

--------------------------------------------------------------------------------------------------------------------------------

-- Loking at Total cases vs total deaths
--Show likelihood of dying if you contract covid in your country

SELECT	 Location, date, total_cases, new_deaths, (total_deaths/total_cases)*100 as DeathPercentege
From PortfolioProject..CovidDeaths
Where location like '%states%' and continent is not null
order by 1,2

--------------------------------------------------------------------------------------------------------------------------------

-- Looking at total cases vs population
--Show what percentage of population got covid

SELECT	 Location, date, Population, total_cases, (total_cases/population)*100 as PopCovidPercentage
From PortfolioProject..CovidDeaths
Where location like '%tina%' and continent is not null
order by 1,2

--------------------------------------------------------------------------------------------------------------------------------

--Looking at countries with higest infectation rate compared to population

SELECT	 Location, Population, MAX(total_cases) AS HighestInfectationCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%tina%' and continent is not null
Group by Location, Population
order by PercentPopulationInfected desc

--------------------------------------------------------------------------------------------------------------------------------

--Showing Countries with Higest death count per Population

SELECT	 Location,MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%tina%' 
Where continent is not null
Group by Location, Population
order by TotalDeathCount desc

--------------------------------------------------------------------------------------------------------------------------------

--Let's breack things down by continent
--Showing continents with the higest death count per population

SELECT	 Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%tina%' 
Where continent is null
Group by location
order by TotalDeathCount desc

--------------------------------------------------------------------------------------------------------------------------------

-- GLOBAL NUMBERS
SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Group by date 
order by 1,2

--------------------------------------------------------------------------------------------------------------------------------

--Loking at total population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVacc
	--(RollingPeopleVacc/population)*100
	FROM PortfolioProject..CovidDeaths dea
	join PortfolioProject..CovidVaccinations vac
		on dea.location = vac.location
		and dea.date= vac.date
	where dea.continent is not null
	order by 2,3

--------------------------------------------------------------------------------------------------------------------------------

--Use CTE

with PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVacc)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVacc
	--,(RollingPeopleVacc/population)*100
	FROM PortfolioProject..CovidDeaths dea
	join PortfolioProject..CovidVaccinations vac
		on dea.location = vac.location
		and dea.date= vac.date
	where dea.continent is not null
	--order by 2,3
)
SELECT *, (RollingPeopleVacc/population)*100
FROM PopvsVac

--------------------------------------------------------------------------------------------------------------------------------

--temp table
DROP Table if exists #PercentPopulationVacinated
create table #PercentPopulationVacinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinatios numeric,
RollingPeopleVacc numeric
)

Insert into #PercentPopulationVacinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVacc
	--,(RollingPeopleVacc/population)*100
	FROM PortfolioProject..CovidDeaths dea
	join PortfolioProject..CovidVaccinations vac
		on dea.location = vac.location
		and dea.date= vac.date
	--where dea.continent is not null
	--order by 2,3

SELECT *, (RollingPeopleVacc/population)*100
FROM #PercentPopulationVacinated

--------------------------------------------------------------------------------------------------------------------------------

--Creatin view to store data fot later visualization

Create View PercentPopulationVacinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVacc
	--,(RollingPeopleVacc/population)*100
	FROM PortfolioProject..CovidDeaths dea
	join PortfolioProject..CovidVaccinations vac
		on dea.location = vac.location
		and dea.date= vac.date
	where dea.continent is not null
	--order by 2,3
