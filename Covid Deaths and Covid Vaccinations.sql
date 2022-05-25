select * 
from  [Portfolio Project].. [Covid Death]
order by 3,4



--select * 
--from  [Portfolio Project].. ['Covid vaccinationss$']
--order by 3,4


--Select Data that I am going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From  [Portfolio Project].. [Covid Death]
Order by 1,2


-- Looking at Total cases vs Total Deaths
--This shows a rough estimate of the percentage of death rates if a person gets covid from 2020 till date in Canada

Select location, date, total_cases, total_deaths, (Total_deaths/total_cases) * 100 as Deathpercentage
From  [Portfolio Project].. [Covid Death]
Where location like '%canada%'
Order by 1,2

-- Looking at the Total cases vs the total population
-- This shows the population in Canada that caught Covid

Select location, date, population, total_cases, (Total_cases/population) * 100 as Percentofpopulationinfected
From  [Portfolio Project].. [Covid Death]
Where location like '%canada%'
Order by 1,2


-- Looking at the Countries with the highest infection rate compared to population

Select location, population, MAX(total_cases) as Highestinfeactioncount, Max((Total_cases/population)) * 100 as Percentofpopulationinfected
From  [Portfolio Project].. [Covid Death]
Group by population, location
Order by Percentofpopulationinfected desc

-- Showing countries with the highest death count per population

Select location, MAX(cast(total_deaths as int)) as Totaldeathcount
From  [Portfolio Project].. [Covid Death]
Where continent is not null
Group by location
Order by Totaldeathcount desc



-- Breaking it down by continent
-- Showing the Continents with the highest deathcount

Select continent, MAX(cast(total_deaths as int)) as Totaldeathcount
From  [Portfolio Project].. [Covid Death]
Where continent is not null
Group by continent
Order by Totaldeathcount desc;


-- Global Numbers

--Across the world the we can see the total covid cases, total deaths and death percentage by dat

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(NEW_CASES) *100 as Deathpercetage
From  [Portfolio Project].. [Covid Death]
Where continent is not null
Group by date
Order by 1,2

-- Across the world there is a death percentage of around 1%

Select  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(NEW_CASES) *100 as Deathpercetage
From  [Portfolio Project].. [Covid Death]
Where continent is not null
--Group by date
Order by 1,2


--Join both data covid death and covid vaccinations by date and location
-- Looking at total population vs vaccination (total number of people in the world that have bee vaccinated.

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, /population)*100
From [Portfolio Project]..[Covid death] dea
JOIN [Portfolio Project]..['Covid vaccinationss$'] vac
     ON dea.location = vac.location
	 and dea.date = vac.date
Where dea.continent is not null
Order by 2,3

--USE CTE

WITH PopsvsVac (continent, location, date, population,new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, rollingpeoplevaccinated/population)*100
From [Portfolio Project]..[Covid death] dea
JOIN [Portfolio Project]..['Covid vaccinationss$'] vac
     ON dea.location = vac.location
	 and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)

Select *, (RollingPeopleVaccinated/population)*100
From PopsvsVac


-- Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, rollingpeoplevaccinated /population)*100
From [Portfolio Project]..[Covid death] dea
JOIN [Portfolio Project]..['Covid vaccinationss$'] vac
     ON dea.location = vac.location
	 and dea.date = vac.date
--Where dea.continent is not null
--Order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


-- Creating a view to store date for later visualisations

Create view Percentpopulationvaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, rollingpeoplevaccinated /population)*100
From [Portfolio Project]..[Covid death] dea
JOIN [Portfolio Project]..['Covid vaccinationss$'] vac
     ON dea.location = vac.location
	 and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3