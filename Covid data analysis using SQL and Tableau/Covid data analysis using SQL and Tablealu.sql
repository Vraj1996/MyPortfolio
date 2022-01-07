select *
from portfolio_project.dbo.covid_death$
where continent is not null
order by 3,4


select location, date, total_cases, total_deaths, population
from portfolio_project.dbo.covid_death$
where continent is not null
order by 1,2

--looking for total cases vs total deaths for india
--shows what percentage of death in canada 
select Location , date, total_cases, total_deaths, population, percentage_of_death= (total_deaths /total_cases )*100
from portfolio_project.dbo.covid_death$
where location like 'canada'
--where continent is not null
order by 1,2

--totl cases vs population
--shows what percentage of canada's population got covid
select location, date , total_cases , total_deaths , population, percentage_of_cases= (total_cases/population)*100
from portfolio_project.dbo.covid_death$
where location like 'canada'
--where continent is not null
order by 1,2

--looking at countries with highest infection rate compared to populations
select location,population, max(total_cases) as highest_cases ,percentage_of_cases= max((total_cases/population))*100
from portfolio_project.dbo.covid_death$
where continent is not null
Group by location, population
order by percentage_of_cases desc

--looking at countries with highest death rate compared to populations
select location, highest_death= max(cast(total_deaths as int)) 
from portfolio_project.dbo.covid_death$
--where location like 'canada'
where continent is not null 
Group by location
--order by  highest_death desc

--lets break things down by contienents 
--showing continents with total death rate
select continent, highest_death= max(cast(total_deaths as int))  ,percentage_of_highestdeaths= max((total_deaths/population))*100
from portfolio_project.dbo.covid_death$
--where location like 'canada'
where continent is not null 
Group by continent
order by  highest_death desc

--breaking global number 
--new cases and new deaths by date, sum of death vs sum of new case(newdeath percentage)
select date, SUM(new_cases) AS SUMofnewcases , sum(cast(new_deaths as int)) as sumofnewdeaths , sum(cast(new_deaths as int))/sum(new_cases) *100 percentageof_sumofdeath_vs_sumofnewcases
from portfolio_project.dbo.covid_death$
where location like 'canada'
--where continent is not null
group by date
order by 1,2

--total cases and tottal death all togather
select SUM(new_cases) AS SUMofnewcases , sum(cast(new_deaths as int)) as sumofnewdeaths , sum(cast(new_deaths as int))/sum(new_cases) *100 percentageof_sumofdeath_vs_sumofnewcases
from portfolio_project.dbo.covid_death$
--where location like 'canada'
where continent is not null
order by 1,2

--new cases and new cases by date
select date, SUM(new_cases) AS sumofnewcases , sum(cast(new_deaths as int)) as sumofnewdeaths 
from portfolio_project.dbo.covid_death$
--where location like 'canada'
where continent is not null
group by date
order by 1,2

--looking for total vaccination vs populations

--use CTE
with popvsvac(continent, location, date, population, new_vaccinations, people_vaccinated)
as 
(
select d.continent, d.location, d.date, d.population,
v.new_vaccinations,sum (cast(v.new_vaccinations as bigint)) over (PARTITION  by d.location order by d.location,d.date ) as people_vaccinated

from portfolio_project..covid_death$ d
join portfolio_project..covid_vaccination$ v

on d.location = v.location
and d.date = v.date
where d.continent is not null
--order by 2,3

)
select *, (people_vaccinated/population)*100 as vaccinated_rate
from popvsvac

---lets do same thing using Temp Table
drop table if exists  #vaccinated_rate
create table #vaccinated_rate(

continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_vaccinations numeric,
people_vaccinated numeric

)
insert into #vaccinated_rate
select d.continent, d.location, d.date, d.population,
v.new_vaccinations,sum (cast(v.new_vaccinations as bigint)) over (PARTITION  by d.location order by d.location,d.date ) as people_vaccinated
from portfolio_project..covid_death$ d
join portfolio_project..covid_vaccination$ v
on d.location = v.location
and d.date = v.date
where d.continent is not null
--order by 2,3


select *, (people_vaccinated/population)*100 as vaccinate_rate
from #vaccinated_rate



      /*
Queries used for Tableau
*/



-- 1. Global Numbers 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From portfolio_project..covid_death$
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


-- 2. Death Count per Continents

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From portfolio_project..covid_death$
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International','Upper middle income','High income','Lower middle income','Low income')
Group by location
order by TotalDeathCount desc


-- 3.Percentage of Population Infected per Country

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From portfolio_project..covid_death$
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


-- 4.Percentage of Population Infected per Country vs date

Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From portfolio_project..covid_death$
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc
