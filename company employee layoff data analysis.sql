SELECT *
FROM layoffs;

CREATE TABLE layoffs2
LIKE layoffs;

SELECT *
FROM layoffs2;

INSERT INTO layoffs2
SELECT * 
FROM layoffs;

# remove duplicates

SELECT *
FROM layoffs2;

SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs2; 

WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs2
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

SELECT *
FROM layoffs2
WHERE company = 'Casper';

CREATE TABLE `layoffs3` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT * 
FROM layoffs3;

INSERT INTO layoffs3
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs2;

DELETE
FROM layoffs3
WHERE row_num > 1;

SELECT *
FROM layoffs3;

# standardization

SELECT DISTINCT(company), TRIM(company)
FROM layoffs3;

UPDATE layoffs3
SET company = TRIM(company);

SELECT DISTINCT(industry)
FROM layoffs3
ORDER BY 1;

SELECT *
FROM layoffs3
WHERE industry LIKE 'Crypto%';

UPDATE layoffs3
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';
 
SELECT *
FROM layoffs3;

SELECT DISTINCT(country)
FROM layoffs3
ORDER BY 1;

UPDATE layoffs3
SET country = 'United States'
WHERE country LIKE 'United States%';

SELECT DISTINCT(stage)
FROM layoffs3
ORDER BY 1;

SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs3;

UPDATE layoffs3
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

SELECT *
FROM layoffs3;

ALTER TABLE layoffs3
MODIFY COLUMN `date` DATE;

# remove null and blanks

SELECT *
FROM layoffs3
WHERE industry IS NULL
OR industry = '';

SELECT *
FROM layoffs3
WHERE company LIKE 'Ball%';

UPDATE layoffs3
SET industry = NULL
WHERE industry = '';

SELECT t1.industry, t2.industry
FROM layoffs3 AS t1
JOIN layoffs3 AS t2
ON t1.company = t2.company
AND t1.location = t2.location
WHERE t1.industry IS NULL 
AND t2.industry IS NOT NULL;

UPDATE layoffs3 AS t1
JOIN layoffs3 AS t2
ON t1.company = t2.company
AND t1.location = t2.location
SET t1.industry = t2.industry
WHERE t1.industry IS NULL 
AND t2.industry IS NOT NULL;

SELECT * 
FROM layoffs3;

SELECT *
FROM layoffs3
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE
FROM layoffs3
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

# remove column or rows

ALTER TABLE layoffs3
DROP COLUMN row_num;

# explorarory data analysis 

SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs3;

SELECT *
FROM layoffs3
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

SELECT company, SUM(total_laid_off)
FROM layoffs3
GROUP BY company
ORDER BY 2 DESC;

SELECT company, SUM(funds_raised_millions)
FROM layoffs3
GROUP BY company
ORDER BY 2 DESC;

SELECT MIN(`date`), MAX(`date`)
FROM layoffs3;

SELECT country, SUM(total_laid_off)
FROM layoffs3
GROUP BY country
ORDER BY 2 DESC;

SELECT country, SUM(total_laid_off)
FROM layoffs3
GROUP BY country
ORDER BY 2 DESC;

SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs3
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;

SELECT stage, SUM(total_laid_off)
FROM layoffs3
GROUP BY stage
ORDER BY 2 DESC;

SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off)
FROM layoffs3
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC;

WITH Rolling_Total AS
(
SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off) AS total_off
FROM layoffs3
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC
)
SELECT `MONTH`, total_off, SUM(total_off) OVER(ORDER BY `MONTH`) AS rolling_total
FROM Rolling_Total;

SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs3
GROUP BY company, YEAR(`date`) 
ORDER BY 3 DESC;

