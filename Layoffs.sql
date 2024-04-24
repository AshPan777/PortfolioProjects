-- Data Cleaning
SET SQL_SAFE_UPDATES = 0;
SELECT *
FROM layoffs;

CREATE TABLE layoffs_staging
LIKE layoffs;

SELECT *
FROM layoffs_staging;

INSERT layoffs_staging
SELECT *
FROM layoffs;

-- 1. Remove Duplicates
SELECT *, ROW_NUMBER() OVER(PARTITION BY company, industry, total_laid_off, percentage_laid_off, date) AS row_num
FROM layoffs_staging;

WITH duplicate_cte AS (
SELECT *, ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

SELECT *
FROM layoffs_staging
WHERE company = 'Casper';

WITH duplicate_cte AS (
SELECT *, ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
DELETE 
FROM duplicate_cte
WHERE row_num > 1;

CREATE TABLE `layoffs_staging2` (
  `company` varchar(255) DEFAULT NULL,
  `location` varchar(255) DEFAULT NULL,
  `industry` varchar(255) DEFAULT NULL,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` double DEFAULT NULL,
  `date` date DEFAULT NULL,
  `stage` varchar(255) DEFAULT NULL,
  `country` varchar(255) DEFAULT NULL,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int 
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM layoffs_staging2
WHERE row_num > 1;

INSERT INTO layoffs_staging2
SELECT *, ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

DELETE
FROM layoffs_staging2
WHERE row_num > 1;

SELECT *
FROM layoffs_staging2;

-- 2. Standardize data
SELECT company, TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

SELECT DISTINCT industry 
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE Country LIKE 'United States%';

SELECT *
FROM layoffs_staging2;

-- Done if date is not in date format. I already declared it a date type not a text type.
SELECT date, STR_TO_DATE(date, '%m/%d/%Y')
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET date = STR_TO_DATE(date, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN date DATE;

SELECT *
FROM layoffs_staging2;

-- 3. Null or blank or 0 values
SELECT *
FROM layoffs_staging2
WHERE total_laid_off is NULL
AND percentage_laid_off is NULL;

UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = ' ';

SELECT *
FROM layoffs_staging2
WHERE industry is NULL;

SELECT *
FROM layoffs_staging2
WHERE company = 'Airbnb';

SELECT t1.industry, t2.industry 
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
ON t1.company = t2.company AND t1.location = t2.location
WHERE (t1.industry IS NULL )AND t2.industry IS NOT NULL;

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
ON t1.company = t2.company AND t1.location = t2.location
SET t1.industry = t2.industry
WHERE (t1.industry IS NULL)AND t2.industry IS NOT NULL;

SELECT COUNT(*)
FROM layoffs_staging2
WHERE funds_raised_millions = 0;

UPDATE layoffs_staging2
SET funds_raised_millions = NULL
WHERE funds_raised_millions = 0;

SELECT *
FROM layoffs_staging2;


-- 4. Remove unnecessary columns
SELECT *
FROM layoffs_staging2
WHERE total_laid_off is NULL
AND percentage_laid_off is NULL;

DELETE
FROM layoffs_staging2
WHERE total_laid_off is NULL
AND percentage_laid_off is NULL;

SELECT *
FROM layoffs_staging2;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

SET SQL_SAFE_UPDATES = 1;

