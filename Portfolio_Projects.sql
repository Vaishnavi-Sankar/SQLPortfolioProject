
Select *
From Portfolio_Projects..CovidDeaths
Where continent is not null
order by 3,4


--Select *
--From Portfolio_Projects..CovidVaccinations
--order by 3,4

--Select rows for to use the data

Select Location, date, total_cases, new_cases, total_deaths, population
From Portfolio_Projects..CovidDeaths
order by 1,2 

--Total cases vs Total Deaths in India

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Portfolio_Projects..CovidDeaths
Where location like '%India%'
order by 1,2  

--Total cases vs Total Populations in India
--Shows the percentage of population got effected in Covid

Select Location, date, population, total_cases, (total_cases/population)*100 as InfectedPoplnPercentage
From Portfolio_Projects..CovidDeaths
Where location like '%India%'
order by 1,2  

--Countries with highest infection rate compared to popln

Select Location, population, Max(total_cases) as Total_Infected_Count, Max(total_cases/population)*100 as InfectedPoplnPercentage
From Portfolio_Projects..CovidDeaths
Group by location, population
order by InfectedPoplnPercentage desc

--Countries with highest death count compared to popln

Select Location, Max(cast(total_deaths as int)) as Total_Death_Count
From Portfolio_Projects..CovidDeaths
Where continent is not null
Group by location
order by Total_Death_Count desc

--LET'S BREAK THINGS BY CONTINENT

Select continent, Max(cast(total_deaths as int)) as Total_Death_Count
From Portfolio_Projects..CovidDeaths
Where continent is not null
Group by continent
order by Total_Death_Count desc

--Showing Continent with highest death count as per popln.

Select continent, Max(cast(total_deaths as int)) as Highest_Total_Death_Count
From Portfolio_Projects..CovidDeaths
Where continent is not null
Group by continent
order by Highest_Total_Death_Count desc

--Global Numders

Select date, Sum(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths, (Sum(cast(new_deaths as int))/Sum(new_cases))*100 as Total_deaths_Percent
From Portfolio_Projects..CovidDeaths
Where continent is not null
Group by date
order by 1,2


--Join 2 tables - Total popln vs vaccinated Using CTE

With PopVSVAC (continent,location,date, population, new_vaccinations, Rolling_People_Vaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as Rolling_People_Vaccinated
from Portfolio_Projects..CovidDeaths dea
join Portfolio_Projects..CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 Where dea.continent is not null
--order by 2,3
)
Select *, (Rolling_People_Vaccinated/population)*100 as Vaccinated
From PopVSVAC

--Temp Table

Drop table if exists #PercentPoplnVaccn

Create table #PercentPoplnVaccn
(continent nvarchar(255), 
location nvarchar(255), 
date datetime,
population nvarchar(255),
new_vaccinations numeric,
Rolling_People_Vaccinated numeric,

)

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as Rolling_People_Vaccinated
from Portfolio_Projects..CovidDeaths dea
join Portfolio_Projects..CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 --Where dea.continent is not null
--order by 2,3
Select *, (Rolling_People_Vaccinated/population)*100 as Vaccinated
From #PercentPoplnVaccn


--Create View 

Create view PercentPoplnVaccn as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as Rolling_People_Vaccinated
from Portfolio_Projects..CovidDeaths dea
join Portfolio_Projects..CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 Where dea.continent is not null
--order by 2,3