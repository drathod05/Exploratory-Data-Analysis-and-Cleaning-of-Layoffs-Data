-- Data Cleaning

-- 1st Step : Removing duplicate records

select *, row_number() over(partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as `Row_Number`
from layoffs_staging;
-- Partition by all given columns
-- Created Row Number Column because we don't have any unique row identifier for identifying duplicate rows 

select version();

select * from layoffs_staging;

WITH duplicate_cte AS 
(select *, row_number() over(partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as `Row_Number`
from layoffs_staging)
delete from
duplicate_cte 
where `Row_Number` > 1;
-- created CTE by adding Row_Number column to the layoffs_staging table
-- Row_Number > 1 means there are duplicate rows. Output : 5 rows having Row_Number > 1
-- If there no duplicate then Row_Number column should only be 1
-- Since we cannot delete rows from CTE, so we create another table 'layoffs_staging2' to copy layoffs_staging data + row_number column
-- And then we can delete rows that have Row_Number > 1

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `Row_Number` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT * FROM layoffs_staging2;

INSERT layoffs_staging2
select *, row_number() over(partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as `Row_Number`
from layoffs_staging;

-- Important syntax : inserting date from another table into layoofs_staging2 table

delete from layoffs_staging2
where `Row_Number` > 1;

-- Created another buffer table layoffs_staging2 to remove duplicates as we cannot delete or update from CTE : duplicate_cte
-- Removed 5 duplicate Rows

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 2nd Step - Standardize Data : Finding issues in data and fixing it

SELECT distinct(country) FROM layoffs_staging2 ORDER BY 1;
select TRIM(company) from layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);	

SELECT * FROM layoffs_staging2
WHERE industry LIKE 'Crypto%'
ORDER BY industry DESC;

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry = 'CryptoCurrency' OR industry = 'Crypto Currency';
-- We have 3 diiferent industry values - 'Crypto', 'CryptoCurrency' and 'Crypto Currency'
-- So we have to standardize it to 1 value - 'Crypto'
-- Another way : where industry like 'Crypto%';

UPDATE layoffs_staging2
SET country = 'United States'
WHERE country LIKE 'United States%';
-- We have 2 entries for USA - United States and United States.
-- 2nd entry has dot at the end of States so we have to remove it
-- Another way : set country = TRIM(TRAILING '.' FROM country);

select `date` from layoffs_staging2;

SELECT `date`,STR_TO_DATE(`date`, '%m/%d/%Y') FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');
-- Still the data type of date column is text (and not date data type)

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;
-- Changed the data type of `date` column from text to date

-- 2nd Step : Standardize Data : 
-- Trim 'company' column 
-- Change 'industry' column values 
-- Set 'country' column
-- Convert `date` column (text data type) to date data type 
  
-------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 3rd Step : Working with NULL and Blank values

SELECT * FROM layoffs_staging2;

SELECT * FROM layoffs_staging2 
where industry = ''  or 
industry is null;

SELECT * FROM layoffs_staging2 where company = 'Airbnb';

UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

-- Self Join to identify which values to populate in place of NULL values in 'industry' column
SELECT st1.industry, st2.industry 
FROM layoffs_staging2 st1
JOIN layoffs_staging2 st2
	ON st1.company = st2.company
    AND st1.location = st2.location
WHERE (st1.industry IS NULL) AND st2.industry IS NOT NULL;

UPDATE layoffs_staging2 st1
JOIN layoffs_staging2 st2
	ON st1.company = st2.company
    AND st1.location = st2.location
SET st1.industry = st2.industry
WHERE (st1.industry IS NULL) AND st2.industry IS NOT NULL;

select * from layoffs_staging2
where company = "Bally's Interactive";

SELECT * FROM layoffs_staging2
WHERE total_laid_off IS NULL 
AND percentage_laid_off IS NULL;

DELETE FROM layoffs_staging2
WHERE total_laid_off IS NULL 
AND percentage_laid_off IS NULL;

-- Deleting records have 'total_laid_off' and 'percentage_laid_off' values as NULL because it is not useful

SELECT * FROM layoffs_staging2;

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 4th Drop any unnecessary column

ALTER TABLE layoffs_staging2
DROP COLUMN `Row_Number`;

-- Column `Row_Number` is not needed so we have to remove that column

















