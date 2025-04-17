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

# 1. Create Table and Import Data

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
