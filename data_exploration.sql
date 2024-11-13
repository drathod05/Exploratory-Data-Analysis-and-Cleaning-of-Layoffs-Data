-- Exploratory Data Analysis (EDA)

SELECT * FROM layoffs_staging2;

SELECT company, SUM(total_laid_off) FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

SELECT country, SUM(total_laid_off) FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

SELECT industry, SUM(total_laid_off) FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

SELECT stage, SUM(total_laid_off) FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;

SELECT `date`, SUM(total_laid_off) FROM layoffs_staging2
GROUP BY `date`
ORDER BY 1 DESC;

SELECT SUBSTRING(`date`, 6,2) AS `Month`, SUM(total_laid_off) FROM layoffs_staging2
WHERE SUBSTRING(`date`, 6,2) IS NOT NULL
GROUP BY `Month`
ORDER BY 1 DESC;

SELECT SUBSTRING(`date`, 1, 7) AS `Year_Month`, SUM(total_laid_off) FROM layoffs_staging2
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY `Year_Month`
ORDER BY 1 ASC;

SELECT YEAR(`date`), SUM(total_laid_off) FROM layoffs_staging2
WHERE `date` IS NOT NULL
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;

WITH Rolling_Total_CTE AS
(
	SELECT SUBSTRING(`date`, 1, 7) AS `Year_Month`, SUM(total_laid_off) AS `Total`
    FROM layoffs_staging2
	WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
	GROUP BY `Year_Month`
	ORDER BY 1 ASC
)
SELECT `Year_Month`, `Total` ,SUM(`Total`) OVER(ORDER BY `Year_Month`) AS Rolling_Total
FROM Rolling_Total_CTE;

SELECT country, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
WHERE `date` IS NOT NULL
GROUP BY country, YEAR(`date`)
ORDER BY 3 DESC;

WITH Company_Year_Data(Company, Years, Total_Laid_Off) AS 
(
	SELECT company, YEAR(`date`), SUM(Total_Laid_Off)
	FROM layoffs_staging2
	WHERE `date` IS NOT NULL
	GROUP BY company, YEAR(`date`)
	
), Company_Year_Rank AS 
(
	SELECT *, DENSE_RANK() OVER(PARTITION BY Years ORDER BY Total_Laid_Off DESC) AS Ranking
	FROM Company_Year_Data
	WHERE Years IS NOT NULL
)
SELECT * FROM Company_Year_Rank
WHERE Ranking <=5;








