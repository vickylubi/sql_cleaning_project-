# SQL Data Cleaning Project - Layoffs Dataset
Learning project on cleaning raw data using Portgresql


This repository contains a SQL project that demonstrates the process of cleaning and transforming a layoffs dataset. The dataset includes information about companies, layoffs, industries, locations, and funds raised. This project focuses on addressing common data quality issues, such as:

- Removing duplicates
- Standardizing data (e.g., fixing inconsistencies in industry names and locations)
- Handling missing or null values
- Dropping unnecessary columns

## Project Overview

The goal of this project is to clean the layoffs dataset and make it ready for further analysis. The cleaning steps involved:

1. **Data Import**: Loading the CSV file into a PostgreSQL database.
2. **Removing Duplicates**: Identifying and deleting duplicate records.
3. **Standardizing Data**: Fixing variations in columns like `industry`, `location`, and `country`.
4. **Handling Null Values**: Updating or removing rows with missing or unreliable data.
5. **Removing Unnecessary Columns**: Dropping irrelevant columns.

### Project Output
The output of this project is a cleaned dataset, free of duplicates, standardized data, and no missing or unreliable values. The dataset is now ready for further analysis or can be exported for use in other applications.

Project Flow 

### 1. Create Table and Import Data

```sql
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


### 2. Remove Duplicates
Identify and remove duplicate rows based on key columns
```sql
WITH dup_cte AS (
    SELECT ctid,
           ROW_NUMBER () OVER (
               PARTITION BY company, location, industry, total_laid_off, 
                            percentage_laid_off, stage, country, funds_raised_millions, date
               ORDER BY ctid
           ) AS row_num 
    FROM layoffs_copy
)
DELETE FROM layoffs_copy
WHERE ctid IN (
    SELECT ctid FROM dup_cte WHERE row_num > 1
);

### 3. Standardize Data
Standardize the industry, location, and country columns to fix inconsistencies.
```sql
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

### 4. Handle Null Values
```sql
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
