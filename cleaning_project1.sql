-- 1. Creating table and getting csv file in it 
CREATE TABLE laid_off (
	company TEXT,
	location TEXT,
	industry TEXT,
	total_laid_off INT,
	percentage_laid_off NUMERIC(3,2),
	date DATE,
	stage TEXT,
	country TEXT,
	funds_raised_millions NUMERIC(8,1)
);

--Let's have a look at the data 

SELECT * 
FROM laid_off;


-- Creating copy of the row data to have a back up in case of mistakes 
CREATE TABLE layoffs_copy 
(LIKE laid_off INCLUDING ALL);

INSERT INTO layoffs_copy
SELECT *
FROM laid_off;

--2.Handling Duplicates 
--Duplicates (lets number the rows and look for number higher than 1)
WITH dup_cte AS (
SELECT ctid,
ROW_NUMBER () OVER (
	PARTITION BY company, 
		     location,
		     industry, 
		     total_laid_off, 
		     percentage_laid_off,
		     stage,
		     country, 
		     funds_raised_millions,
		     date
	ORDER BY ctid	
	) AS row_num 
FROM layoffs_copy
)

--Need to delete a dupe and keep the original one 
DELETE FROM layoffs_copy
WHERE ctid IN (
  SELECT ctid FROM dup_cte WHERE row_num > 1
);

-- 3.Standardizing data 
SELECT * 
FROM layoffs_copy

SELECT DISTINCT industry
FROM layoffs_copy
ORDER BY 1;

--Crypto industry has several different names, change all variations to 'Crypto' 

SELECT *
FROM layoffs_copy
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_copy
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

--Lets check if all locations are distinct 
SELECT DISTINCT location
FROM layoffs_copy
ORDER BY 1;
--2 dupes 

--There is one location written in German 'Düsseldorf'
SELECT *
FROM layoffs_copy
WHERE location LIKE 'Dus%';

UPDATE layoffs_copy
SET location = 'Dusseldorf'
WHERE location LIKE 'Düs%';

--Same problem with Malmo 

SELECT *
FROM layoffs_copy
WHERE location LIKE 'Malm%';

UPDATE layoffs_copy
SET location = 'Malmo'
WHERE location LIKE 'Malm%';

--Dupes in country 
SELECT DISTINCT country
FROM layoffs_copy
ORDER BY 1;

SELECT DISTINCT country
FROM layoffs_copy
WHERE country LIKE '% States%'
    
-- There are 'United States' and 'United States.' Lets change it 
UPDATE layoffs_copy
SET country = 'United States'
WHERE country LIKE 'United States%';


-- HANDLING NULLs 
--Industry NULLs
SELECT *
FROM layoffs_copy
WHERE industry IS NULL
OR industry = '';

SELECT *
FROM layoffs_copy
WHERE company = 'Airbnb';

UPDATE layoffs_copy
SET industry = NULL
WHERE industry = '';

--Do self join to see if there are other rows for the same companies with industry filled in 
SELECT *
FROM layoffs_copy t1
JOIN layoffs_copy t2
	ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL
ORDER BY t1.company;

--Lets update blank ones populating info from not blank rows of the same companies 
UPDATE layoffs_copy AS t1
SET industry = t2.industry
FROM layoffs_copy AS t2
WHERE t1.company = t2.company
  AND (t1.industry IS NULL OR t1.industry = '')
  AND t2.industry IS NOT NULL;


--Total laid off Nulls and percentage Nulls too 
SELECT *
FROM layoffs_copy
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

--These rows does not have enough information and can't be trusted, so better to delete them
DELETE 
FROM layoffs_copy
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;
