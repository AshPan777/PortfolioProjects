SELECT *
FROM Covid_Deaths
WHERE continent != ""
ORDER BY 3,4;

-- Select data to use
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Covid_Deaths
WHERE continent != ""
ORDER BY 1,2;

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/ total_cases) * 100 AS death_percentage
FROM Covid_Deaths
WHERE location  like '%states%' and continent != ""
ORDER BY 1,2;

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
SELECT location, date, population, total_cases, (total_cases/population) * 100 AS percent_population_infected
FROM Covid_Deaths
WHERE location  like '%states%' and continent != ""
ORDER BY 1,2;

-- Looking at countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) AS highest_infection_count, (MAX(total_cases)/population) * 100 AS  percent_population_infected
FROM Covid_Deaths
-- WHERE location  like '%states%'
WHERE continent != ""
GROUP BY population, location
ORDER BY percent_population_infected DESC;

-- Showing the countries witht the highest death count per population
SELECT location, MAX(total_deaths) as total_death_count
FROM Covid_Deaths
-- WHERE location  like '%states%'
WHERE continent != ""
GROUP BY location
ORDER BY total_death_count DESC;

-- Breaking things down by continent
SELECT continent, MAX(total_deaths) as total_death_count
FROM Covid_Deaths
-- WHERE location  like '%states%'
WHERE continent != ""
GROUP BY continent
ORDER BY total_death_count DESC;

-- Global Numbers
SELECT date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths , SUM(new_deaths)/ SUM(new_cases) * 100 AS death_percentage
FROM Covid_Deaths
WHERE continent != ""
GROUP BY date
ORDER BY 1,2;

SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths , SUM(new_deaths)/ SUM(new_cases) * 100 AS death_percentage
FROM Covid_Deaths
WHERE continent != ""
-- GROUP BY date
ORDER BY 1,2;

-- Looking at total population vs vaccination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as rolling_people_vaccinated
-- ,(rolling_people_vaccinated/ population )*100
FROM Covid_Deaths as dea
JOIN Covid_Vaccinations as vac
ON dea.location = vac.location and dea.date = vac.date
WHERE dea.continent != ""
ORDER BY 2,3;

-- USE CTE
WITH PopvsVac(Continent, Location, Date, Population, New_Vaccinations, Rolling_People_Vaccinated) AS (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as rolling_people_vaccinated
-- ,(rolling_people_vaccinated/ population )*100
FROM Covid_Deaths as dea
JOIN Covid_Vaccinations as vac
ON dea.location = vac.location and dea.date = vac.date
WHERE dea.continent != ""
ORDER BY 2,3 )

SELECT *, (rolling_people_vaccinated/ population) * 100
FROM PopvsVac;
