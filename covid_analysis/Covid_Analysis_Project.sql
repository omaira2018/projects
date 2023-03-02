


CREATE TABLE `covid_vaccinations_all` (
  `iso_code` text,
  `continent` text,
  `location` text,
  `date` text,
  `total_tests` text,
  `new_tests` text,
  `total_tests_per_thousand` text,
  `new_tests_per_thousand` text,
  `new_tests_smoothed` text,
  `new_tests_smoothed_per_thousand` text,
  `positive_rate` text,
  `tests_per_case` text,
  `tests_units` text,
  `total_vaccinations` text,
  `people_vaccinated` text,
  `people_fully_vaccinated` text,
  `total_boosters` text,
  `new_vaccinations` text,
  `new_vaccinations_smoothed` text,
  `total_vaccinations_per_hundred` text,
  `people_vaccinated_per_hundred` text,
  `people_fully_vaccinated_per_hundred` text,
  `total_boosters_per_hundred` text,
  `new_vaccinations_smoothed_per_million` text,
  `new_people_vaccinated_smoothed` text,
  `new_people_vaccinated_smoothed_per_hundred` text,
  `stringency_index` float DEFAULT NULL,
  `population_density` float DEFAULT NULL,
  `median_age` float DEFAULT NULL,
  `aged_65_older` float DEFAULT NULL,
  `aged_70_older` float DEFAULT NULL,
  `gdp_per_capita` float DEFAULT NULL,
  `extreme_poverty` text,
  `cardiovasc_death_rate` float DEFAULT NULL,
  `diabetes_prevalence` float DEFAULT NULL,
  `female_smokers` text,
  `male_smokers` text,
  `handwashing_facilities` float DEFAULT NULL,
  `hospital_beds_per_thousand` float DEFAULT NULL,
  `life_expectancy` float DEFAULT NULL,
  `human_development_index` float DEFAULT NULL,
  `excess_mortality_cumulative_absolute` text,
  `excess_mortality_cumulative` text,
  `excess_mortality` text,
  `excess_mortality_cumulative_per_million` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;





select * 
from covid_deaths_all 
order by 3, 4


select * 
from covid_vaccinations_all
order by 3, 4


# Selecting Data to be used 

select location, STR_TO_DATE(date, '%c/%e/%Y %r') as date_rec,date, total_cases, new_cases, total_deaths, population
from covid_deaths_all
order by 1, 2


ALTER table covid_deaths_all 
	add date_new datetime
	
update covid_deaths_all
set date_new = 
cast(SELECT STR_TO_DATE(date, '%c/%e/%Y %r') FROM covid_deaths_all WHERE 1)

select date, new_date from covid_deaths_all;

select convert(datetime, date, 101)
select convert(datetime, convert (varchar(30) , date), 101)


SELECT STR_TO_DATE(date, '%c/%e/%Y %r') FROM covid_deaths_all WHERE 1


SELECT STR_TO_DATE(date, '%d/%m/%y') AS new_date
FROM covid_deaths_all



select * from covid_deaths_all limit 10 ;

-- Add a new column to the table
ALTER TABLE covid_deaths_all ADD COLUMN new_date DATETIME;

-- Update the new column with the values from the query

UPDATE covid_deaths_all
SET new_date = STR_TO_DATE(date, '%d/%m/%y');

-- Drop the original text column if it's no longer needed
ALTER TABLE covid_deaths_all DROP COLUMN date;



select location, new_date, total_cases, new_cases, total_deaths, population
from covid_deaths_all
order by 1, 2





-- Likelihood of dying if one contracts covid : Death Percentage (total_deaths/total_cases)

select location, new_date, total_cases, total_deaths, ROUND(((total_deaths/total_cases) * 100 ),2) as death_percentage
from covid_deaths_all
order by 1, 2


-- Percentage of people got covid (total_cases/population)

select `location`, new_date, total_cases, population, ROUND((total_cases/population)*100,2) as Percentage_contracted_covid 
from covid_deaths_all 
order by 1, 2


-- Countries with highest infection rate 

select location, max(total_cases), population, max(ROUND((total_cases/population)*100,2)) as Percentage_contracted_covid 
from covid_deaths_all
group by location, population
order by Percentage_contracted_covid desc 



-- Countries with highest death count per population

SELECT location, MAX(CONVERT(total_deaths, SIGNED)) AS highest_death_count
FROM covid_deaths_all
where continent is not null
GROUP BY location
order by highest_death_count desc;

-- setting empty string values to null 

UPDATE covid_deaths_all
SET continent = NULLIF(continent, '')
WHERE continent = '';

-- Continents with highest death count per population 


SELECT continent, MAX(CONVERT(total_deaths, SIGNED)) AS highest_death_count
FROM covid_deaths_all
where continent is not null
GROUP BY continent
order by highest_death_count desc;


-- Global Numbers on a date 

select new_date, Sum(total_cases) as total_cases ,sum(convert(new_cases,signed)) as new_cases, Sum(convert(total_deaths,signed)) as total_deaths, (sum(convert(total_cases,signed))/sum(convert(total_deaths,signed)))*100 as death_percentage
from covid_deaths_all
group by new_date




select * from covid_vaccinations_all;


alter table covid_vaccinations_all add column new_date datetime;

UPDATE covid_vaccinations_all
set new_date = STR_TO_DATE(date, '%d/%m/%y');


alter table covid_vaccinations_all drop column date;


-- Join covid_Deaths and covid_vaccinations 


select * from 
covid_deaths_all cd join covid_vaccinations_all cv
on 
cd.`location` = cv.`location` and 
cd.new_date = cv.new_date;




-- total population vs vaccinations 


select cd.continent ,cd.`location`, cd.population, cd.new_date, new_vaccinations,
sum(CONVERT(new_vaccinations,SIGNED)) over (partition by cd.`location` order by cd.`location`, cd.new_date) as rolling_people_vaccinated
from 
covid_deaths_all cd join covid_vaccinations_all cv
on
cd.`location` = cv.`location` and 
cd.new_date = cv.new_date
order by 2,4 ;


-- creating a table for further calculations
-- USE CTE 

with PopvsVac (continent, `location`, population,new_date,new_vaccinations, rolling_people_vaccinated)
AS
( 
select cd.continent ,cd.`location`, cd.population, cd.new_date, new_vaccinations,
sum(CONVERT(new_vaccinations,SIGNED)) over (partition by cd.`location` order by cd.`location`, cd.new_date) as rolling_people_vaccinated
from 
covid_deaths_all cd join covid_vaccinations_all cv
on
cd.`location` = cv.`location` and 
cd.new_date = cv.new_date

)


-- creating view 

create view PercentagePopulationVaccinated as 
select cd.continent ,cd.`location`, cd.population, cd.new_date, new_vaccinations,
sum(CONVERT(new_vaccinations,SIGNED)) over (partition by cd.`location` order by cd.`location`, cd.new_date) as rolling_people_vaccinated
from 
covid_deaths_all cd join covid_vaccinations_all cv
on
cd.`location` = cv.`location` and 
cd.new_date = cv.new_date
where cd.continent is not null

select * from PercentagePopulationVaccinated


