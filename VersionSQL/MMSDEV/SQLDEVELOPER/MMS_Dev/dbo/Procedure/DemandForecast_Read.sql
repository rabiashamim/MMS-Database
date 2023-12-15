/****** Object:  Procedure [dbo].[DemandForecast_Read]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================  
-- Author:  ALINA JAVED
-- CREATE date: 16 May 2023
-- Description: 
-- ============================================= 
-- DemandForecast_Read 986,1,10,1 --@pForecast=22.642
CREATE   PROCEDURE dbo.DemandForecast_Read @pSoFileMasterId DECIMAL(18, 0)
, @pUserId INT = 1
, @pPageNumber INT
, @pPageSize INT
, @pYear NVARCHAR(MAX) = NULL
, @pMaxDemand NVARCHAR(MAX) = NULL
, @pPartyId NVARCHAR(MAX) = NULL
, @pIsValid NVARCHAR(MAX) = NULL      
, @pMessage NVARCHAR(MAX) = NULL  
, @pMpName VARCHAR(MAX) = NULL 
, @pCapObl NVARCHAR(MAX) = NULL
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
				[MTDemandForecast_Interface_Id] 
			   , ROW_NUMBER() OVER (ORDER BY MTDemandForecast_Interface_Year,MtParty_Id, MTDemandForecast_Interface_RowNumber)    AS RowNumber
			   ,[MtSOFileMaster_Id]
			   ,[MtParty_Id]
			   ,[MTDemandForecast_Interface_Year]
			   ,[MTDemandForecast_Interface_Max_Demand_during_peakhours_MW] 			   
			   ,[MTDemandForecast_Interface_IsValid] 
			   ,[MTDemandForecast_Interface_Message] 
	,(SELECT
		TOP 1
			(PR.MtPartyRegisteration_Name)
		FROM MtPartyRegisteration PR
		WHERE MTDemandForecast_Interface.MtParty_Id
		=  PR.MtPartyRegisteration_Id
		AND ISNULL(PR.isDeleted, 0) = 0)
	AS [MP Name]
			FROM [dbo].[MTDemandForecast_Interface]
			WHERE MtSOFileMaster_Id = @pSoFileMasterId
			AND (@pYear IS NULL
			OR MTDemandForecast_Interface_Year = @pYear)					
			AND (@pPartyId IS NULL
			OR [dbo].[MTDemandForecast_Interface].[MtParty_Id] = @pPartyId)
			AND (@pMaxDemand IS NULL
			OR MTDemandForecast_Interface_Max_Demand_during_peakhours_MW = @pMaxDemand)
			AND (@pCapObl IS NULL
			OR MTDemandForecast_Interface_Max_Demand_during_peakhours_MW = @pCapObl)
			AND (@pIsValid IS NULL
			OR [MTDemandForecast_Interface_IsValid] = @pIsValid)
			AND (@pMpName IS NULL
				OR (SELECT
		PR.MtPartyRegisteration_Name
		FROM MtPartyRegisteration PR
		WHERE MTDemandForecast_Interface.MtParty_Id  = PR.MtPartyRegisteration_Id
		AND ISNULL(PR.isDeleted, 0) = 0)
				LIKE '%' + @pMpName + '%')			
			
			)
			
			
			SELECT
			* INTO #tempdemforecast_Int
		FROM CTE_InterfaceData 
			

		--SELECT
		--	*
		--FROM CTE_InterfaceData cte
		--WHERE (cte.RowNumber > ((@pPageNumber - 1) * @pPageSize)
		--AND cte.RowNumber <= (@pPageNumber * @pPageSize))
		--ORDER BY cte.RowNumber

		SELECT
	*
FROM #tempdemforecast_Int TC
WHERE (RowNumber > ((@pPageNumber - 1) * @pPageSize)
		AND RowNumber <= (@pPageNumber * @pPageSize))
		ORDER BY RowNumber

SELECT
	COUNT(1) AS FilteredRows
FROM #tempdemforecast_Int TC;

	END
/*********************************************************************************
****************************From Operational ************************************
*********************************************************************************/
	ELSE
	BEGIN
		WITH CTE_InterfaceData
		AS
		(SELECT
				[MTDemandForecast_Id]
			   , ROW_NUMBER() OVER (ORDER BY MTDemandForecast_Year,MtParty_Id, MTDemandForecast_RowNumber) AS RowNumber
			   ,[MtSOFileMaster_Id]
			   ,[MtParty_Id]
			   ,[MTDemandForecast_Year]
			   ,[MTDemandForecast_Max_Demand_during_Peakhours_MW]
			   ,ISNULL([MTDemandForecast_CapacityObligation],0) as MTDemandForecast_CapacityObligation
	,(SELECT
		TOP 1
			(PR.MtPartyRegisteration_Name)
		FROM MtPartyRegisteration PR
		WHERE MTDemandForecast.MtParty_Id
		=  PR.MtPartyRegisteration_Id
		AND ISNULL(PR.isDeleted, 0) = 0)
	AS [MP Name]
			FROM [dbo].[MTDemandForecast]
			WHERE MtSOFileMaster_Id = @pSoFileMasterId
			AND (@pYear IS NULL
			OR [MTDemandForecast_Year] = @pYear)	
			AND (@pPartyId IS NULL
			OR [dbo].[MTDemandForecast].[MtParty_Id] =@pPartyId)
			AND (@pMaxDemand IS NULL
			OR floor([MTDemandForecast_Max_Demand_during_Peakhours_MW] ) =floor(cast(@pMaxDemand as decimal(28,13))))
			AND (@pMpName IS NULL
				OR (SELECT
		PR.MtPartyRegisteration_Name
		FROM MtPartyRegisteration PR
		WHERE MTDemandForecast.MtParty_Id  = PR.MtPartyRegisteration_Id
		AND ISNULL(PR.isDeleted, 0) = 0)
				LIKE '%' + @pMpName + '%')			
			)

			SELECT
			* INTO #tempdemforecast
		FROM CTE_InterfaceData 

		--SELECT
		--	*
		--FROM CTE_InterfaceData cte
		--WHERE (cte.RowNumber > ((@pPageNumber - 1) * @pPageSize)
		--AND cte.RowNumber <= (@pPageNumber * @pPageSize))
		--ORDER BY cte.RowNumber

		 SELECT  
    *  
   FROM #tempdemforecast TC  
   WHERE (RowNumber > ((@pPageNumber - 1) * @pPageSize)  
   AND RowNumber <= (@pPageNumber * @pPageSize))  
   ORDER BY MtSOFileMaster_Id ASC  
  
   SELECT  
    COUNT(1) AS FilteredRows  
   FROM #tempdemforecast TC; 


	END

DROP TABLE IF EXISTS #tempdemforecast_Int;
DROP TABLE IF EXISTS #tempdemforecast;
/*********************************************************************************
*********************************************************************************
*********************************************************************************/


END
