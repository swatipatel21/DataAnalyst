
select * 
from PortfolioProjectCovid19..CovidDeaths
order by 3,4

select * 
from PortfolioProjectCovid19..CovidVaccinations
order by 3,4

-- alter column datatype for total_deaths from nvarchar to float and new_deaths from nvarchar to float 
alter table PortfolioProjectCovid19..CovidDeaths
alter column total_deaths float

alter table PortfolioProjectCovid19..CovidDeaths
alter column new_deaths float

-- How has the number of COVID-19 deaths evolved over time globally?

select date, sum(cast (total_deaths as int)) as global_deaths
from PortfolioProjectCovid19..CovidDeaths
group by date
order by date

--Which countries have reported the highest total number of COVID-19 deaths?

select Location, sum(cast(total_deaths as int)) as total_number_of_deaths
from PortfolioProjectCovid19..CovidDeaths
group by Location
order by total_number_of_deaths desc

--What is the current global mortality rate for COVID-19?

select date, sum(cast(total_deaths as int)) as total_deaths, sum(total_cases) as total_Cases, 
(sum(cast(total_deaths as int)) * 100.0 / sum(total_cases)) as mortality_rate
from PortfolioProjectCovid19..CovidDeaths
group by date 
order by date desc

--How does the COVID-19 mortality rate vary between different regions or continents?

select Location, continent,  
(sum(cast(total_deaths as int)) * 100.0 / sum(total_cases)) as mortality_rate
from PortfolioProjectCovid19..CovidDeaths
group by location, continent 
order by continent 

--Is there a correlation between a country's population size and the total number of COVID-19 deaths reported?
-- x is population and y is total_deaths

with correlation_between_population_and_deaths as (
     select Location,
	        population,
			total_deaths,
			avg(population) as avg_population,
			avg(total_deaths) as avg_total_deaths
	 from PortfolioProjectCovid19..CovidDeaths
	 group by Location, population,total_deaths
)
select Location,
       max(population) as population,
	   sum(total_deaths) as total_deaths,
	   sum((population - avg_population) * (total_deaths - avg_total_deaths)) /
	   (sqrt(sum(power(population - avg_population, 2)) * sum(power(total_deaths - avg_total_deaths,2)))) as correlation
from correlation_between_population_and_deaths
group by Location, population, total_deaths

--Which countries have successfully reduced their COVID-19 mortality rate over time?

select Location, date,  
(sum(cast(total_deaths as int)) * 100.0 / sum(total_cases)) as mortality_rate
from PortfolioProjectCovid19..CovidDeaths
group by location, date 
order by date desc, mortality_rate 

--What is the ratio of confirmed COVID-19 deaths to total confirmed COVID-19 cases in different countries, and how does this ratio vary?

select Location, 
       sum(total_cases) as total_cases,
	   sum(total_deaths) as total_deaths,
	   isnull(sum(total_deaths) / nullif(sum(total_cases),0),0) as death_total_case_ratio
from PortfolioProjectCovid19..CovidDeaths 
group by Location

-- Total COVID-19 Deaths, Vaccinations, and Population for Each Location

select cd.Location,
       sum(cd.total_deaths) as total_deaths,
	   nullif(sum(cast(cv.people_vaccinated as float)),0) as total_vaccination,
	   cd.population as total_population
from PortfolioProjectCovid19..CovidDeaths cd
join PortfolioProjectCovid19..CovidVaccinations cv
on cd.Location = cv.location
group by cd.Location, cd.population

--Countries with the Highest Vaccination Coverage (Percentage Vaccinated)

select cd.Location, 
       nullif(sum(cast(cv.people_vaccinated as float)),0) as total_vaccination,
	   nullif(sum(cast(cv.people_vaccinated as float)),0) * 100 / cd.population as vaccination_percentage
from PortfolioProjectCovid19..CovidDeaths cd
join PortfolioProjectCovid19..CovidVaccinations cv
on cd.Location = cv.location
group by cd.Location, cd.population

--Top 10 Countries with the Highest Deaths rate per 1000000 Population and Vaccinations per Population

select top 10 cd.Location,
       sum(cd.total_deaths) as total_deaths,
	   nullif(sum(cast(cv.people_vaccinated as float)),0) as total_vaccination,
	   cd.population as total_population,
	   (sum(cd.total_deaths) * 1000000.0) / cd.population as deaths_per_million,
	   (nullif(sum(cast(cv.people_vaccinated as float)),0) * 100.0) / cd.population as vaccination_percentage
from PortfolioProjectCovid19..CovidDeaths cd
join PortfolioProjectCovid19..CovidVaccinations cv
on cd.Location = cv.location
group by cd.Location, cd.population
order by deaths_per_million desc

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

--using cte

with rolling_people_vaccination (Location, Date, New_Vaccinations, Population, RollingPeopleVaccinated)
as (
select cd.Location, cd.date, cv.new_vaccinations, cd.population,
       sum(cast(cv.new_vaccinations as int)) over (partition by cd.Location order by cd.Location, cd.date) as RollingPeopleVaccinated	  
from PortfolioProjectCovid19..CovidDeaths cd
join PortfolioProjectCovid19..CovidVaccinations cv
on cd.Location = cv.location
and cd.date = cv.date
)
select *, (RollingPeopleVaccinated/Population) * 100 as percentage_of_population_vaccinated
from rolling_people_vaccination

-- using temp table

drop table if exists #rolling_people_vaccination

create table #rolling_people_vaccination
(
Location nvarchar(255),
Date datetime, 
New_Vaccinations numeric, 
Population numeric, 
RollingPeopleVaccinated numeric
)

insert into #rolling_people_vaccination
select cd.Location, cd.date, cv.new_vaccinations, cd.population,
       sum(cast(cv.new_vaccinations as int)) over (partition by cd.Location order by cd.Location, cd.date) as RollingPeopleVaccinated	  
from PortfolioProjectCovid19..CovidDeaths cd
join PortfolioProjectCovid19..CovidVaccinations cv
on cd.Location = cv.location
and cd.date = cv.date

select *, (RollingPeopleVaccinated/Population) * 100 as percentage_of_population_vaccinated
from #rolling_people_vaccination

-- using view to store data fro future visualizations
go
create view [rollingpeoplevaccination] 
as
select cd.Location, cd.date, cv.new_vaccinations, cd.population,
       sum(cast(cv.new_vaccinations as int)) over (partition by cd.Location order by cd.Location, cd.date) as RollingPeopleVaccinated	  
from PortfolioProjectCovid19..CovidDeaths cd
join PortfolioProjectCovid19..CovidVaccinations cv
on cd.Location = cv.location
and cd.date = cv.date
go

select *, (RollingPeopleVaccinated/Population) * 100 as percentage_of_population_vaccinated
from rollingpeoplevaccination
