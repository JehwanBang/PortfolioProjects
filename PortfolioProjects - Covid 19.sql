/* Coronavirus Pandemic (Covid-19) Data Exploration

Data Source : https://ourworldindata.org/covid-deaths

Date Extracted From 2020-01-28 To 2021-07-10

SQL Skills: Update, Alter Table, Joins, Temp Tables, Converting Data Types, CTE's, Functions & etc 

Date 2021-07-11

Created By Jehwan Bang
*/

-- Test to see if the table is loaded correctly to sql server
Select *
From [Portfolio - Covid Cases]..CovidCases
order by 3,4


-- change column data types
Alter Table CovidCases
Alter Column date Date;

Alter Table CovidCases
Alter Column new_deaths float;

Alter Table CovidCases
Alter Column total_cases float;

Alter Table CovidCases
Alter Column new_cases float;

Alter Table CovidCases
Alter Column total_deaths float;





-- Create UniqueID
-- Combine an iso_code and the 6 digit date (last two digit of year,month and day) Note that date was converted to nvarchar so we can use it as string
-- which allowed us to use the date in a substring and concat function.
-- Tables can be linked without creating unique id. For example, join where location and date is matched. 
Update CovidCases
set iso_code = CONCAT(iso_code,SUBSTRING(convert(nvarchar(255),date),3,2),SUBSTRING(convert(nvarchar(255),date),6,2),SUBSTRING(convert(nvarchar(255),date),9,2))

-- Rename Column From iso_code To UniqueID
-- Renaming Column could affect other codes so check where the original column name is used before changing it
Exec sp_rename '[Portfolio - Covid Cases]..CovidCases.iso_code', 'UniqueID', 'COLUMN';

-- Select Data to work with
-- "where continent is not null" is required to remove 6 continents (Asia, Africa, North America, South America, Oceania, and Europe)

Select Location, date, total_cases,new_cases,total_deaths,population
From [Portfolio - Covid Cases]..CovidCases
where continent is not null
order by 1,2

-- Mortality Rate (Total Deaths/Total Cases) for Canada
-- Shows likelihood of dying of covid patient in Canada.

Select Location, date, total_cases,total_deaths,cast((total_deaths/total_cases)*100 as decimal(18,4)) as MortalityRate
From [Portfolio - Covid Cases]..CovidCases
where location like '%anad%'  --Where location = 'Canada' works as well
order by 2

-- Total Cases vs Population
-- How many people are infected with covid

Select Location, date, population,total_cases, (total_cases/population)*100 as InfPerc
From [Portfolio - Covid Cases]..CovidCases
where continent is not null
order by 1,2

-- Highest Infection Rate based on the Population size

-- order by Highest Cases
Select Location, date, population,MAX(total_cases) as HighestCases, cast(max((total_cases/population))*100 as decimal(18,4)) as HighestInfPerc
From [Portfolio - Covid Cases]..CovidCases
where continent is not null
group by location, population, date
order by HighestCases Desc, HighestInfPerc Desc

-- order by Highest Infected Percentage
Select Location, date, population,MAX(total_cases) as HighestCases, cast(max((total_cases/population))*100 as decimal(18,4)) as HighestInfPerc
From [Portfolio - Covid Cases]..CovidCases
where continent is not null
group by location, population, date
order by HighestInfPerc Desc, HighestCases Desc

-- Highest Death Count based on the Population size

-- order by Highest Deaths Count
Select Location, MAX(total_deaths) as HighestDeath
From [Portfolio - Covid Cases]..CovidCases
where continent is not null
group by location
order by HighestDeath Desc

-- Based on 6 continents
Select location, Sum(new_deaths) as HighestDeaths
From [Portfolio - Covid Cases]..CovidCases
where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by HighestDeaths desc

-- World Wide Total
Select SUM(new_cases) as total_cases, SUM(new_deaths)  as total_deaths, Convert(decimal(18,4),SUM(new_deaths)/SUM(new_cases)*100) as Mort
From [Portfolio - Covid Cases]..CovidCases
where continent is not null 


--Working with Covid Tests data
-- Test to see if the table is loaded correctly to sql server
Select *
From [Portfolio - Covid Cases]..CovidTests
order by 3,4

-- change column data types

Alter Table CovidTests
Alter Column date Date

Alter Table CovidTests
Alter Column new_tests float

Alter Table CovidTests
Alter Column total_tests float

Alter Table CovidTests
Alter Column positive_rate float


-- Create UniqueID
-- Same as Covid Cases
Update CovidTests
set iso_code = CONCAT(iso_code,SUBSTRING(convert(nvarchar(255),date),3,2),SUBSTRING(convert(nvarchar(255),date),6,2),SUBSTRING(convert(nvarchar(255),date),9,2))

-- Rename Column From iso_code To UniqueID
-- Renaming Column could affect other codes so check where the original column name is used before changing it
Exec sp_rename '[Portfolio - Covid Cases]..CovidTests.iso_code', 'UniqueID', 'COLUMN';

-- Select Data to work with
-- "where continent is not null" is required to remove 8 continents (Asia, Africa, North America, South America, Oceania, and Europe)

Select Location, date, new_tests,total_tests,positive_rate,population
From [Portfolio - Covid Cases]..CovidTests
where continent is not null
order by 1,2


-- Highest Tests Count
Select location, sum(new_tests) as HighestTests, (sum(new_tests)/population)*100 as TestRates
From [Portfolio - Covid Cases]..CovidTests
where continent is not null
Group by location, population
order by HighestTests desc, TestRates desc

--Highest Tests Count by Population Size
Select location, sum(new_tests) as HighestTests, (sum(new_tests)/population)*100 as TestRates
From [Portfolio - Covid Cases]..CovidTests
where continent is not null
Group by location, population
order by TestRates desc, HighestTests desc

-- Based on 6 Continent
-- We see that United States are the first in the world but North America is the third on the Contient
Select continent, sum(new_tests) as HighestTests
From [Portfolio - Covid Cases]..CovidTests
where continent is not null
and location not in ('World', 'European Union', 'International')
Group by continent
order by HighestTests desc


-- Since new tests are performed every day but the test results come out like 1-3 days.(It was slower in the beginning like 2 weeeks)
-- Direct calculation like new tests * positive rate may not be approciated. 
-- Capture the Trend (New Tests and Positive Rate)

Select Location, date, new_tests,positive_rate
From [Portfolio - Covid Cases]..CovidTests
where continent is not null
order by 1,2


--Working with Covid Vaccinations data
-- Test to see if the table is loaded correctly to sql server

Select *
From [Portfolio - Covid Cases]..CovidVaccinations
order by 3,4

-- change column data types

Alter Table CovidVaccinations
Alter Column date Date

Alter Table CovidVaccinations
Alter Column total_vaccinations float

Alter Table CovidVaccinations
Alter Column new_vaccinations float

Alter Table CovidVaccinations
Alter Column people_vaccinated float

Alter Table CovidVaccinations
Alter Column people_fully_vaccinated float

-- Create UniqueID
-- Combine an iso_code and the 6 digit date (last two digit of year,month and day) Note that date was converted to nvarchar so we can use it as string
-- which allowed us to use the date in a substring and concat function.
-- Tables can be linked without creating unique id. For example, join where location and date is matched. 
Update CovidVaccinations
set iso_code = CONCAT(iso_code,SUBSTRING(convert(nvarchar(255),date),3,2),SUBSTRING(convert(nvarchar(255),date),6,2),SUBSTRING(convert(nvarchar(255),date),9,2))

-- Rename Column From iso_code To UniqueID
-- Renaming Column could affect other codes so check where the original column name is used before changing it
Exec sp_rename '[Portfolio - Covid Cases]..CovidVaccinations.iso_code', 'UniqueID', 'COLUMN';

-- Select Data to work with
-- "where continent is not null" is required to remove 8 continents (Asia, Africa, North America, South America, Oceania, and Europe)

Select uniqueID, Location, date, total_cases,new_cases,total_deaths,population
From [Portfolio - Covid Cases]..CovidCases
where continent is not null
order by 1,2


-- Percentage of at least one Covid Vaccine Shot

Select vac.uniqueid, cas.continent, vac.location, vac.date, vac.population, vac.new_vaccinations
, sum(vac.new_vaccinations) OVER (Partition by cas.Location Order by cas.UniqueID) as PopVac
From [Portfolio - Covid Cases]..CovidCases cas
Join [Portfolio - Covid Cases]..CovidVaccinations vac
	On cas.UniqueID = vac.uniqueID
where cas.continent is not null 
order by 3,4


-- CTE Method for the previous query
With VacPop (uniqueid, Continent, Location, Date, Population, New_Vaccinations, PopVac)
as
(
Select vac.uniqueid, cas.continent, vac.location, vac.date, vac.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by cas.Location Order by cas.location, cas.Date) as PopVac
From [Portfolio - Covid Cases]..CovidCases cas
Join [Portfolio - Covid Cases]..CovidVaccinations vac
	On cas.UniqueID = vac.uniqueID
where cas.continent is not null 
)
Select *, convert(decimal(18,4),(PopVac/Population)*100) as PercVacPop
From VacPop

-- Temp Table Method for the previous query

DROP Table if exists #PercVacPop
Create Table #PercVacPop
(
uniqueid nvarchar(255),
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
PopVac numeric
)

Insert into #PercVacPop
Select vac.uniqueid, cas.continent, vac.location, vac.date, vac.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by cas.Location Order by cas.location, cas.Date) as PopVac
From [Portfolio - Covid Cases]..CovidCases cas
Join [Portfolio - Covid Cases]..CovidVaccinations vac
	On cas.UniqueID = vac.uniqueID
where cas.continent is not null 

Select *, cast((PopVac/Population)*100 as decimal(18,4)) as PercVacPop
From #PercVacPop
order by 3,4

-- Fully Vaccinated People Percentage
Select vac.uniqueid, cas.continent, vac.location, vac.date, vac.population, vac.people_fully_vaccinated,convert(decimal(18,4), (max(vac.people_fully_vaccinated)/vac.population)*100) as FulVaccineRate
From [Portfolio - Covid Cases]..CovidCases cas
Join [Portfolio - Covid Cases]..CovidVaccinations vac
	On cas.UniqueID = vac.uniqueID
where cas.continent is not null 
group by vac.location, vac.uniqueid, cas.continent, vac.date, vac.population, vac.people_fully_vaccinated
order by 3,4




-- Create View and use stored data to create visualizations later

Create View PercVacPop as 
Select vac.uniqueid, cas.continent, vac.location, vac.date, vac.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by cas.Location Order by cas.location, cas.Date) as PopVac
From [Portfolio - Covid Cases]..CovidCases cas
Join [Portfolio - Covid Cases]..CovidVaccinations vac
	On cas.UniqueID = vac.uniqueID
where cas.continent is not null 




