/****** Object:  Procedure [dbo].[GenForcastAndCurtailment_Read]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================  
-- Author:  ALI IMRAN
-- CREATE date: 31 march 2023
-- Description: 
-- ============================================= 
-- GenForcastAndCurtailment_Read 598,1,1,3, @pForecast=22.642
CREATE   PROCEDURE dbo.GenForcastAndCurtailment_Read @pSoFileMasterId DECIMAL(18, 0)
, @pUserId INT = 1
, @pPageNumber INT
, @pPageSize INT
, @pHour NVARCHAR(MAX) = NULL
, @pDate NVARCHAR(MAX) = NULL
, @pGeneraterId NVARCHAR(MAX) = NULL
, @pForecast NVARCHAR(MAX) = NULL
, @pCurtailemnt NVARCHAR(MAX) = NULL
, @pIsValid NVARCHAR(MAX) = NULL      
, @pMessage NVARCHAR(MAX) = NULL    
AS
BEGIN

/*********************************************************************************
*********************************************************************************
*********************************************************************************/
	DECLARE @vStatus VARCHAR(3);
	SELECT
		@vStatus =
		LuStatus_Code
	FROM MtSOFileMaster
	WHERE MtSOFileMaster_Id = @pSoFileMasterId

/*********************************************************************************
****************************From Interface **************************************
*********************************************************************************/

	IF (@vStatus = 'UPL')
	BEGIN
		WITH CTE_InterfaceData
		AS
		(SELECT
				[MTGenForcastAndCurtailment_Interface_Id]
			   ,[MTGenForcastAndCurtailment_Interface_RowNumber] AS RowNumber
			   ,[MtSOFileMaster_Id]
			   ,[MtGenerator_Id]
			   ,[MTGenForcastAndCurtailment_Interface_Date] 
			   ,[MTGenForcastAndCurtailment_Interface_Hour]
			   ,[MTGenForcastAndCurtailment_Interface_Forecast_MW]
			   ,[MTGenForcastAndCurtailment_Interface_Curtailemnt_MW]
			   ,[MTGenForcastAndCurtailment_Interface_IsValid]
			   ,[MTGenForcastAndCurtailment_Interface_Message]			   
			FROM [dbo].[MTGenForcastAndCurtailment_Interface]
			WHERE MtSOFileMaster_Id = @pSoFileMasterId
			AND (@pHour IS NULL
			OR [MTGenForcastAndCurtailment_Interface_Hour] = @pHour)
			--AND (@pDate IS NULL
			--OR CONVERT(VARCHAR(10), [MTGenForcastAndCurtailment_Interface_Date], 101) = @pDate)
			AND (@pDate IS NULL
			OR CASE
				WHEN ISDATE([MTGenForcastAndCurtailment_Interface_Date]) = 0 THEN [MTGenForcastAndCurtailment_Interface_Date]
				ELSE cast (CONVERT(DATE, [MTGenForcastAndCurtailment_Interface_Date], 101) as varchar(64))
			END = CASE
				WHEN ISDATE(CAST(@pDate AS NVARCHAR)) = 1 THEN cast (CONVERT(DATE, @pDate, 101) as varchar(64))
				ELSE @pDate
			END)
			AND (@pGeneraterId IS NULL
			OR [dbo].[MTGenForcastAndCurtailment_Interface].[MtGenerator_Id] = @pGeneraterId)
			AND (@pForecast IS NULL
			OR MTGenForcastAndCurtailment_Interface_Forecast_MW = @pForecast)
			AND (@pCurtailemnt IS NULL
			OR MTGenForcastAndCurtailment_Interface_Curtailemnt_MW = @pCurtailemnt)
			AND (@pIsValid IS NULL
			OR MTGenForcastAndCurtailment_Interface_IsValid= @pIsValid))
			
			
			SELECT
			* INTO #tempgenforcast_Int
		FROM CTE_InterfaceData 
			

		--SELECT
		--	*
		--FROM CTE_InterfaceData cte
		--WHERE (cte.RowNumber > ((@pPageNumber - 1) * @pPageSize)
		--AND cte.RowNumber <= (@pPageNumber * @pPageSize))
		--ORDER BY cte.RowNumber

		SELECT
	*
FROM #tempgenforcast_Int TC
WHERE (RowNumber > ((@pPageNumber - 1) * @pPageSize)
		AND RowNumber <= (@pPageNumber * @pPageSize))
		ORDER BY RowNumber

SELECT
	COUNT(1) AS FilteredRows
FROM #tempgenforcast_Int TC;

	END
/*********************************************************************************
****************************From Operational ************************************
*********************************************************************************/
	ELSE
	BEGIN
		WITH CTE_InterfaceData
		AS
		(SELECT
				[MTGenForcastAndCurtailment_Id]
			   ,[MTGenForcastAndCurtailment_RowNumber] AS RowNumber
			   ,[MtSOFileMaster_Id]
			   ,[MtGenerator_Id]
			   ,[MTGenForcastAndCurtailment_Date]
			   ,[MTGenForcastAndCurtailment_Hour]
			   ,[MTGenForcastAndCurtailment_Forecast_MW]
			   ,[MTGenForcastAndCurtailment_Curtailemnt_MW]
			FROM [dbo].[MTGenForcastAndCurtailment]
			WHERE MtSOFileMaster_Id = @pSoFileMasterId
			AND (@pHour IS NULL
			OR [MTGenForcastAndCurtailment_Hour] = @pHour)
			AND (@pDate IS NULL
			OR CONVERT(VARCHAR(10), [MTGenForcastAndCurtailment_Date], 101) = @pDate)		
			AND (@pGeneraterId IS NULL
			OR [dbo].[MTGenForcastAndCurtailment].[MtGenerator_Id] =@pGeneraterId)
			AND (@pForecast IS NULL
			OR floor(MTGenForcastAndCurtailment_Forecast_MW) =floor(cast(@pForecast as decimal(28,13))))
			AND (@pCurtailemnt IS NULL
			OR floor(MTGenForcastAndCurtailment_Curtailemnt_MW) = floor(cast(@pCurtailemnt as decimal(28,13))))
			)

			SELECT
			* INTO #tempgenforcast
		FROM CTE_InterfaceData 

		--SELECT
		--	*
		--FROM CTE_InterfaceData cte
		--WHERE (cte.RowNumber > ((@pPageNumber - 1) * @pPageSize)
		--AND cte.RowNumber <= (@pPageNumber * @pPageSize))
		--ORDER BY cte.RowNumber

		 SELECT  
    *  
   FROM #tempgenforcast TC  
   WHERE (RowNumber > ((@pPageNumber - 1) * @pPageSize)  
   AND RowNumber <= (@pPageNumber * @pPageSize))  
   ORDER BY RowNumber ASC  
  
   SELECT  
    COUNT(1) AS FilteredRows  
   FROM #tempgenforcast TC; 


	END
/*********************************************************************************
*********************************************************************************
*********************************************************************************/


END
