
/*When i imported my dataset into microsoft sql server managment studio from excel, all my variables where in nvarchar
So i had to convert all my variables (nvarchar) in numerical variables in order to manipulate correctly my dataset*/
/*
When the sheet is selected
-> edit mappings
-> and i convert my variables into numerical variables
-> end
*/



-- Introduction of my dataset

select *
from portofolio.dbo.coviddeaths

select *
from portofolio.dbo.covidvaccinations


-- i dont like the format of my date variable so i change it 

alter table portofolio.dbo.coviddeaths
add dateconverted date
update portofolio.dbo.coviddeaths
set dateconverted = convert(date, Date)

alter table portofolio.dbo.covidvaccinations
add dateconverted date
update portofolio.dbo.covidvaccinations
set dateconverted = convert(date, Date)



-- Select Data that we are going to be starting with, i will always order by location and time (1,2) in oder to have clear results

Select Location, dateconverted, total_cases, new_cases, total_deaths, population
From portofolio.dbo.coviddeaths
Where continent is not null 
order by 1,2


-- Total Cases vs Total Deaths

-- Shows likelihood of dying if you contract covid in all countries

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100  as DeathPercentage
From portofolio.dbo.coviddeaths
where continent is not null 
order by 1,2




-- Shows likelihood of dying if you contract covid in France

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100  as DeathPercentage
From portofolio.dbo.coviddeaths
Where location like '%France%'
and continent is not null 
order by 1,2

-- Total  Population
-- Shows the percentage infection by time of all countries

Select Location, date, Population, total_cases, (total_cases /population)*100 as PercentPopulationInfected
From portofolio.dbo.coviddeaths
order by 1,2


-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From portofolio.dbo.coviddeaths
Group by Location, Population
order by PercentPopulationInfected desc



-- Countries with their Highest Death Count 

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From portofolio.dbo.coviddeaths
Where continent is not null 
Group by Location
order by TotalDeathCount desc



-- BREAKING THINGS DOWN BY CONTINENT

-- Showing the contintents deathcount

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From portofolio.dbo.coviddeaths
Where continent is not null 
Group by continent
order by TotalDeathCount desc



-- GLOBAL NUMBERS
--World death percentage
Select SUM(total_cases) as total_cases, SUM(total_deaths) as total_deaths, SUM(total_deaths)/SUM(total_Cases)*100 as DeathPercentage
From portofolio.dbo.coviddeaths
where continent is not null 
order by 1,2


-- Total Population vs Vaccinations
-- Shows the number of people who received at least one Covid Vaccine

Select dea.continent, dea.location, dea.dateconverted, dea.population, vac.new_people_vaccinated_smoothed
, SUM(vac.new_people_vaccinated_smoothed) OVER (Partition by dea.Location Order by dea.location, dea.Dateconverted) as RollingPeopleVaccinated
From portofolio.dbo.coviddeaths dea
Join portofolio.dbo.covidvaccinations vac
	On dea.location = vac.location
	and dea.dateconverted= vac.dateconverted
where dea.continent is not null 
order by 2,3



--  Shows the percentage of people who received at least one Covid Vaccine
-- For this i have to use a CTE to perform Calculation on Partition By in previous query

With Percentagepeoplebeingvaccinated (Continent, Location, Dateconverted, Population, new_people_vaccinated_smoothed, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.dateconverted, dea.population, vac.new_people_vaccinated_smoothed
, SUM(vac.new_people_vaccinated_smoothed) OVER (Partition by dea.Location Order by dea.location, dea.Dateconverted) as RollingPeopleVaccinated
From portofolio.dbo.coviddeaths dea
Join portofolio.dbo.covidvaccinations vac
	On dea.location = vac.location
	and dea.dateconverted= vac.dateconverted
where dea.continent is not null 
)
Select *,(RollingPeopleVaccinated/Population)*100 as Percentagepeoplebeingvaccinated
From Percentagepeoplebeingvaccinated



-- I want to see the french pourcentage
With Peoplebeingvaccinated(continent, location, dateconverted, population, new_people_vaccinated_smoothed, rollingpeoplevaccinated)
as
(
select dea.continent, dea.location, dea.dateconverted, dea.population, vac.new_people_vaccinated_smoothed
, SUM(vac.new_people_vaccinated_smoothed) over (partition by dea.location order by dea.location, dea.dateconverted ) as rollingpeoplevaccinated
from Portofolio.dbo.coviddeaths dea
join Portofolio.dbo.covidvaccinations vac
on dea.location = vac.location
and dea.dateconverted = vac.dateconverted
where dea.continent is not null
and dea.location like '%France%'
)
select *, (rollingpeoplevaccinated/population)*100 as Percentagepeoplebeingvaccinated
from Peoplebeingvaccinated


-- An another way to do it
-- I use a table creation in order to calculate the samething as before instead of using a cte

DROP Table if exists PercentPopulationVaccinated
Create Table PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
dateconverted datetime,
Population numeric,
new_people_vaccinated_smoothed numeric,
RollingPeopleVaccinated numeric
)

Insert into PercentPopulationVaccinated
Select dea.continent, dea.location, dea.dateconverted, dea.population, vac.new_people_vaccinated_smoothed
, SUM(vac.new_people_vaccinated_smoothed) OVER (Partition by dea.Location Order by dea.location, dea.dateconverted) as RollingPeopleVaccinated
From Portofolio.dbo.coviddeaths dea 
Join Portofolio.dbo.covidvaccinations vac
	On dea.location = vac.location
	and dea.dateconverted = vac.dateconverted

Select *, (RollingPeopleVaccinated/Population)*100 Percentagepeoplebeingvaccinated
From PercentPopulationVaccinated



