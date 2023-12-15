/****** Object:  Procedure [dbo].[ETLFetchData]    Committed by VersionSQL https://www.versionsql.com ******/

--==========================================================================================
-- Author: Sadaf Malik
-- CREATE date: 13 Jan 2022
-- ALTER date:    
-- Description:               
--==========================================================================================
 --dbo.ETLFetchData  34
/*****   25-NTDC	26-Pak Mitiari
Select * FROM [dbo].[EtlTspHourly] 
Select * FROM [dbo].[EtlHourly]
Select * from [dbo].[EtlTspData]
Select * from [dbo].[EtlMpData]

DELETE FROM [dbo].[EtlTspHourly] 
DELETE FROM [dbo].[EtlHourly]
DELETE from [dbo].[EtlTspData]
DELETE from [dbo].[EtlMpData]


******/
CREATE   PROCEDURE dbo.ETLFetchData 
@pStatementProcessId DECIMAL(18, 0)
AS
BEGIN

DECLARE @luaccountingMonth AS INT
 ;
 

SELECT
	@luaccountingMonth = LuAccountingMonth_Id_Current 
FROM MtStatementProcess
WHERE MtStatementProcess_ID = @pStatementProcessId

DECLARE @FromDate AS DATETIME;
DECLARE @ToDate AS DATETIME;

DROP TABLE IF EXISTS #StatementIDs

/*==========================================================================================
		Get From date and To Date of Financial Year
==========================================================================================*/
SELECT
	@FromDate = LuAccountingMonth_FromDate
   ,@ToDate = LuAccountingMonth_ToDate
FROM LuAccountingMonth
WHERE LuAccountingMonth_Id = @luaccountingMonth

Set @ToDate=DATEADD(hour,23,@ToDate);
/*==========================================================================================
		Generate Hourly Profile for ETL Time span
		==========================================================================================*/
DROP TABLE IF EXISTS #TempHours;


DECLARE @INC_Hour AS INT = 1;

WITH ROWCTE
AS
(SELECT
		@FromDate AS dateTimeHour
	UNION ALL
	SELECT
		DATEADD(HOUR, @INC_Hour, dateTimeHour)
	FROM ROWCTE
	WHERE dateTimeHour < @ToDate)

SELECT
	* INTO #TempHours
FROM ROWCTE
OPTION (MAXRECURSION 0); --There is no way to perform a recursion more than 32767   

/*==========================================================================================
		Fetch All statement process Id of the BME year.  ESS/FSS only
==========================================================================================*/

SELECT
	MAX(MtStatementProcess_ID) AS StatementIDs INTO #StatementIDs
FROM MtStatementProcess SP
INNER JOIN LuAccountingMonth AM
	ON SP.LuAccountingMonth_Id_Current = AM.LuAccountingMonth_Id
WHERE DATEFROMPARTS(AM.LuAccountingMonth_Year, AM.LuAccountingMonth_Month, 1) BETWEEN @FromDate AND @ToDate
AND ISNULL(SP.MtStatementProcess_IsDeleted, 0) = 0
AND ISNULL(AM.LuAccountingMonth_IsDeleted, 0) = 0
AND SP.SrProcessDef_ID IN (4, 7)
GROUP BY LuAccountingMonth_Id_Current

/*==========================================================================================

==========================================================================================*/


IF NOT EXISTS (SELECT TOP 1 1 FROM #StatementIDs)
BEGIN

--EXEC [dbo].[SaveMtSattlementProcessLogs] @StatementProcessId = @pStatementProcessId
--													,@pRuStepDef_ID = 0
--													,@LogsMessage = 'No BME settlements exist for current financial year.'
--													,@OutputMessage = 'Warning'
--													,@OutputStatus = 1

RAISERROR ('No BME settlements exist for current financial year.', 16, -1);

END 
/*==========================================================================================
		Fetch Transmission Losses
==========================================================================================*/
IF NOT EXISTS (SELECT TOP 1
			1
		FROM [dbo].[EtlTspHourly] bd
		WHERE MtStatementProcess_ID = @pStatementProcessId)
BEGIN



INSERT INTO [dbo].[EtlTspHourly] ([MtStatementProcess_ID]
, [EtlTspHourly_Year]
, [EtlTspHourly_Month]
, [EtlTspHourly_Day]
, [EtlTspHourly_Hour]
, [MTPartyRegisteration_Id]
)


	SELECT
		@pStatementProcessId
	   ,DATEPART(YEAR, dateTimeHour) AS [Year]
	   ,DATEPART(Month, dateTimeHour) AS [Month]
	   ,DATEPART(Day, dateTimeHour) AS [Day]
	   ,(DATEPART(Hour, dateTimeHour) )+1 AS [Hour]
	   ,P.BmeStatementData_PartyRegisteration_Id
	FROM #TempHours
	INNER JOIN (SELECT DISTINCT
			BmeStatementData_PartyRegisteration_Id
		FROM BmeStatementDataTspHourly_SettlementProcess
		WHERE BmeStatementData_StatementProcessId IN (SELECT
				StatementIDs
			FROM #StatementIDs)) AS P
		ON 1 = 1


update ETL
 set EtlTspHourly_AdjustedEnergyImport= tspHourly.BmeStatementData_AdjustedEnergyImport
	   ,EtlTspHourly_AdjustedEnergyExport= tspHourly.BmeStatementData_AdjustedEnergyExport
	   , EtlTspHourly_TransmissionLoss= tspHourly.BmeStatementData_TransmissionLosses
	FROM BmeStatementDataTspHourly_SettlementProcess tspHourly
	inner join 
	EtlTspHourly ETL on ETL.EtlTspHourly_Year=tspHourly.BmeStatementData_Year
	AND ETL.EtlTspHourly_Month=tspHourly.BmeStatementData_Month
	AND ETL.EtlTspHourly_Day=tspHourly.BmeStatementData_Day
	AND ETL.EtlTspHourly_Hour=tspHourly.BmeStatementData_Hour
	AND ETL.MTPartyRegisteration_Id=tspHourly.BmeStatementData_PartyRegisteration_Id
	WHERE
	ETL.MtStatementProcess_ID=@pStatementProcessId
	AND tspHourly.BmeStatementData_StatementProcessId IN (SELECT
			StatementIDs
		FROM #StatementIDs)
END
/*==========================================================================================
		Step 2: Fetch Total Demand, Transmission losses and Marginal Price
		==========================================================================================*/
IF NOT EXISTS (SELECT TOP 1
			1
		FROM [dbo].[EtlHourly] bd
		WHERE MtStatementProcess_ID = @pStatementProcessId)
BEGIN


INSERT INTO [dbo].[EtlHourly] ([MtStatementProcess_ID]
, [EtlHourly_Year]
, [EtlHourly_Month]
, [EtlHourly_Day]
, [EtlHourly_Hour]
--, [EtlHourly_TranmissionLoss]
--, [EtlHourly_Demand]
)
	SELECT
		@pStatementProcessId
	   ,DATEPART(YEAR, dateTimeHour) AS [Year]
	   ,DATEPART(Month, dateTimeHour) AS [Month]
	   ,DATEPART(Day, dateTimeHour) AS [Day]
	   ,DATEPART(Hour, dateTimeHour)+1 AS [Hour]
	FROM #TempHours



UPDATE E set
	   E.EtlHourly_TranmissionLoss= BmeStatementData_TransmissionLosses
	   ,E.EtlHourly_Demand= BmeStatementData_DemandedEnergy
	FROM BmeStatementDataHourly_SettlementProcess B
	inner join EtlHourly E
	on E.EtlHourly_Year=B.BmeStatementData_Year
	AND E.EtlHourly_Month=B.BmeStatementData_Month
	AND E.EtlHourly_Day=B.BmeStatementData_Day
	AND E.EtlHourly_Hour=B.BmeStatementData_Hour
	WHERE BmeStatementData_StatementProcessId IN (SELECT
			StatementIDs
		FROM #StatementIDs)
		AND E.MtStatementProcess_ID=@pStatementProcessId


UPDATE ETL
SET [EtlHourly_MarginalPrice] = MP.BmeStatementData_MarginalPrice
FROM [dbo].[EtlHourly] ETL
INNER JOIN BmeStatementDataMpHourly_SettlementProcess MP
	ON MP.BmeStatementData_Year = ETL.[EtlHourly_Year]
	AND MP.BmeStatementData_Month = ETL.[EtlHourly_Month]
	AND MP.BmeStatementData_Day = ETL.[EtlHourly_Day]
	AND MP.BmeStatementData_Hour = ETL.[EtlHourly_Hour]
WHERE 	 BmeStatementData_StatementProcessId IN (SELECT
			StatementIDs
		FROM #StatementIDs)
AND ETL.[MtStatementProcess_ID] = @pStatementProcessId
END

END
