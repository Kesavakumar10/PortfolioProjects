
Select *
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 3,4

SELECT *
FROM PortfolioProject..CovidVaccinations
Order by 3,4

--Using the Data

SELECT location, date, total_cases, new_cases,total_deaths, population
FROM PortfolioProject..CovidDeaths
Order by 1,2

--Looking at total cases vs total deaths

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 As DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
Order by 1,2


--Looking at toal cases vs population
--Shows what percentage of population got Covid

Select location, date, population, total_cases,(total_cases/population)*100 As PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Order by 1,2

--Looking at countries with highest infection rate compared to population

Select location, population, MAX(total_cases) As HighestInfectionCount, MAX((total_cases/population))*100 As PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by location,population
Order by PercentPopulationInfected desc


--Showing countries with Highest death count per population

Select location, MAX(cast(total_deaths as int)) As HighestDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location
Order by HighestDeathCount Desc

--By Continent

Select location,MAX(cast(total_deaths as int)) As HighestDeathCount
From PortfolioProject..CovidDeaths
Where continent is null
Group by location
Order by HighestDeathCount 

--Global numbers

Select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 As DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
--Group by Date
Order by 1,2

--Looking at total population vs vaccinations

Select Death.continent,Death.location,Death.Date,Death.population,Vacc.new_vaccinations,
SUM(cast(Vacc.new_vaccinations as int)) OVER (Partition by Death.location ORDER BY Death.location
,Death.date) AS RollingPeopleVaccinated
From PortfolioProject..CovidDeaths AS Death
Join PortfolioProject..CovidVaccinations As Vacc
 ON Death.location = Vacc.location 
 And Death.date = Vacc.date
 Where Death.continent is not null
 group by Death.continent,Death.location,Death.Date,Death.population,Vacc.new_vaccinations
 order by 2,3

 --Use CTE

 WITH PopvsVacc (Continent, location, Date, Population,New_vaccinations, RollingPeopleVaccinated) 
 AS 
 (Select Death.continent,Death.location,Death.Date,Death.population,Vacc.new_vaccinations,
SUM(cast(Vacc.new_vaccinations as int)) OVER (Partition by Death.location ORDER BY Death.location
,Death.date) AS RollingPeopleVaccinated
From PortfolioProject..CovidDeaths AS Death
Join PortfolioProject..CovidVaccinations As Vacc
 ON Death.location = Vacc.location 
 And Death.date = Vacc.date
 Where Death.continent is not null
 group by Death.continent,Death.location,Death.Date,Death.population,Vacc.new_vaccinations
 --order by 2,3
 )
 Select *, (RollingPeopleVaccinated/Population)*100
 from PopvsVacc 

 --TEMP TABLES

 DROP Table if exists #PercentpopulationVaccinated
 CREATE TABLE #PercentpopulationVaccinated
 (
 Continent nvarchar(255),
 location nvarchar(255),
 Date datetime,
 Population numeric,
 New_vaccinations numeric,
 RollingPeopleVaccinated numeric)

 INSERT INTO #PercentpopulationVaccinated
 Select Death.continent,Death.location,Death.Date,Death.population,Vacc.new_vaccinations,
SUM(cast(Vacc.new_vaccinations as int)) OVER (Partition by Death.location ORDER BY Death.location
,Death.date) AS RollingPeopleVaccinated
From PortfolioProject..CovidDeaths AS Death
Join PortfolioProject..CovidVaccinations As Vacc
 ON Death.location = Vacc.location 
 And Death.date = Vacc.date
 --Where Death.continent is not null
 group by Death.continent,Death.location,Death.Date,Death.population,Vacc.new_vaccinations
 --order by 2,3

 Select *, (RollingPeopleVaccinated/Population)*100
 from #PercentpopulationVaccinated 


 --Creating view to store data for later visualizations

 Create View PercentpopulationVaccinated As 
 Select Death.continent,Death.location,Death.Date,Death.population,Vacc.new_vaccinations,
 SUM(cast(Vacc.new_vaccinations as int)) OVER (Partition by Death.location ORDER BY Death.location
 ,Death.date) AS RollingPeopleVaccinated
 From PortfolioProject..CovidDeaths AS Death
 Join PortfolioProject..CovidVaccinations As Vacc
 ON Death.location = Vacc.location 
 And Death.date = Vacc.date
 Where Death.continent is not null
 group by Death.continent,Death.location,Death.Date,Death.population,Vacc.new_vaccinations
--order by 2,3

Select *
From PercentpopulationVaccinated