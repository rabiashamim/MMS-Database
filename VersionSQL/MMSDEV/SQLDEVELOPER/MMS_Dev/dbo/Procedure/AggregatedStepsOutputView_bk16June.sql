/****** Object:  Procedure [dbo].[AggregatedStepsOutputView_bk16June]    Committed by VersionSQL https://www.versionsql.com ******/

-- [dbo].AggregatedStepsOutputView 200,2

CREATE PROCEDURE [dbo].[AggregatedStepsOutputView_bk16June] 
@pSettlementProcessId INT
,@pStepId INT
AS
BEGIN


IF (@pStepId = 2)
BEGIN
  

DROP TABLE IF EXISTS #tempProcessesList
DROP TABLE IF EXISTS #tempBME
DROP TABLE IF EXISTS #tempPtBME
DROP TABLE IF EXISTS #tempASCPayable
DROP TABLE IF EXISTS #tempASCReceivable
DROP TABLE IF EXISTS #tempPtPayable
DROP TABLE IF EXISTS #tempPtReceivable
DROP TABLE IF EXISTS #tempBMEASC
DROP TABLE IF EXISTS #temp
DROP TABLE IF EXISTS #tempMonthsList
DROP TABLE IF EXISTS #tempAdjustedESSFinal
DROP TABLE IF EXISTS #tempSortColumns
DROP TABLE IF EXISTS #tempWithAlias

DECLARE @months NVARCHAR(MAX)
	   ,@query NVARCHAR(MAX);

/**********************************************************************************************************************************************/
DECLARE @SrProcessDef_Id AS INT
DECLARE @LuAccountingMonth_Id AS INT
/**********************************************************************************************************************************************/
SELECT
	@SrProcessDef_Id = SrProcessDef_ID
   ,@LuAccountingMonth_Id = LuAccountingMonth_Id_Current
FROM MtStatementProcess
WHERE MtStatementProcess_ID = @pSettlementProcessId;
/**********************************************************************************************************************************************/
SELECT
	SrProcessDef_ID INTO #tempProcessesList
FROM SrProcessDef
WHERE SrStatementDef_ID = (SELECT
		SrStatementDef_ID
	FROM SrProcessDef
	WHERE SrProcessDef_ID = @SrProcessDef_Id)
AND SrProcessDef_ID < @SrProcessDef_Id

--**************************************************************************************  
--     Get all statements of current month BME, ASC, ESSof previous months  
--**************************************************************************************  
SELECT
	MtStatementProcess_ID
   ,SrProcessDef_ID
   ,LuAccountingMonth_Id
   ,LuAccountingMonth_Id_Current INTO #temp
FROM MtStatementProcess
WHERE LuAccountingMonth_Id_Current = @LuAccountingMonth_Id
AND SrProcessDef_ID IN (SELECT
		SrProcessDef_ID
	FROM #tempProcessesList)
AND ISNULL(MtStatementProcess_IsDeleted, 0) = 0

UNION

SELECT
	MtStatementProcess_ID
   ,SrProcessDef_ID
   ,LuAccountingMonth_Id
   ,LuAccountingMonth_Id_Current
FROM MtStatementProcess
WHERE LuAccountingMonth_Id = @LuAccountingMonth_Id
AND SrProcessDef_ID IN (7, 8)--(12) -- BME AND ASC ESS  
AND ISNULL(MtStatementProcess_IsDeleted, 0) = 0

--**************************************************************************************  
--     Populate Months Names  
--**************************************************************************************  

SELECT DISTINCT
	lm.LuAccountingMonth_Month INTO #tempMonthsList
FROM #temp t
INNER JOIN LuAccountingMonth lm
	ON lm.LuAccountingMonth_Id = t.LuAccountingMonth_Id_Current


--SELECT
--	@months = ISNULL(@months + ',', '') + QUOTENAME(RTRIM(AE.LuAccountingMonth_Month))
--FROM (SELECT DISTINCT
--		lm.LuAccountingMonth_Month
--	FROM #temp t
--	INNER JOIN LuAccountingMonth lm
--		ON lm.LuAccountingMonth_Id = t.LuAccountingMonth_Id_Current) AE;
--select @months  
--select LuAccountingMonth_Month from #tempMonthsList  
--**************************************************************************************  
--     BME Master  
--**************************************************************************************  
SELECT
	BmeStatementData_StatementProcessId
   ,BmeStatementData_Year
   ,BmeStatementData_Month
   ,CONCAT(msp.SrProcessDef_ID, '-BME-',
(   select ssf.SrStatementDef_Name from SrProcessDef sdf join SrStatementDef ssf on sdf.SrStatementDef_ID=ssf.SrStatementDef_ID
where sdf.SrProcessDef_ID=msp.SrProcessDef_ID),'  '
   , BmeStatementData_Year, '-', DATENAME(MONTH, DATEFROMPARTS(BmeStatementData_Year, BmeStatementData_Month, 1))) AS ESSMonthName
   ,BmeStatementData_PartyRegisteration_Id
   ,BmeStatementData_PartyName
	--   ,BmeStatementData_AmountPayableReceivable 
   ,CASE
		WHEN msp.SrProcessDef_ID=7
		THEN BmeStatementData_ESSAdjustment
		ELSE BmeStatementData_AmountPayableReceivable
	END AS BmeStatementData_AmountPayableReceivable INTO #tempBME
FROM BmeStatementDataMpMonthly_SettlementProcess mpMonthly
JOIN MtStatementProcess MSP
	ON MSP.MtStatementProcess_ID = mpMonthly.BmeStatementData_StatementProcessId
WHERE BmeStatementData_StatementProcessId IN (SELECT
		MtStatementProcess_ID
	FROM #temp
	WHERE SrProcessDef_ID IN (1, 4, 7))
	

--**************************************************************************************  
--     BME Months  
--**************************************************************************************  
declare @monthsBME nvarchar(max);
declare @monthsBMESum nvarchar(max);

SELECT
	@monthsBME = ISNULL(@monthsBME + ',', '') + QUOTENAME(RTRIM(AE.ESSMonthName))
   ,@monthsBMESum = ISNULL(@monthsBMESum + '+', '') + 'ISNULL(' + QUOTENAME(RTRIM(AE.ESSMonthName)) + ',0)'
FROM (SELECT DISTINCT
		ESSMonthName
	FROM #tempBME) AE;


--**************************************************************************************  
--     ASC Payable Master  
--**************************************************************************************  
------------------ Master Table  
SELECT
	AscStatementData_StatementProcessId
   ,CONCAT(msp.SrProcessDef_ID, '-ASC Payable-',
   (   select ssf.SrStatementDef_Name from SrProcessDef sdf join SrStatementDef ssf on sdf.SrStatementDef_ID=ssf.SrStatementDef_ID
where sdf.SrProcessDef_ID=msp.SrProcessDef_ID),'  '   ,
   AscStatementData_Year, '-', DATENAME(MONTH, DATEFROMPARTS(AscStatementData_Year, AscStatementData_Month, 1))) AS ESSMonthName
   ,AscStatementData_PartyRegisteration_Id
   ,AscStatementData_PartyName
	--   ,AscStatementData_PAYABLE
   ,CASE
		WHEN msp.SrProcessDef_ID=8
		THEN AscStatementData_AdjustmentPAYABLE
		ELSE AscStatementData_PAYABLE
	END AS AscStatementData_PAYABLE INTO #tempASCPayable
FROM AscStatementDataMpMonthly_SettlementProcess mpMonthly
JOIN MtStatementProcess MSP
	ON MSP.MtStatementProcess_ID = mpMonthly.AscStatementData_StatementProcessId
WHERE AscStatementData_StatementProcessId IN (SELECT
		MtStatementProcess_ID
	FROM #temp
	WHERE SrProcessDef_ID IN (2, 5, 8))

--**************************************************************************************  
--     ASC Receivable Master  
--**************************************************************************************  
------------------ Master Table  
SELECT
	AscStatementData_StatementProcessId
   ,CONCAT(msp.SrProcessDef_ID, '-ASC Receivable-',
      (   select ssf.SrStatementDef_Name from SrProcessDef sdf join SrStatementDef ssf on sdf.SrStatementDef_ID=ssf.SrStatementDef_ID
where sdf.SrProcessDef_ID=msp.SrProcessDef_ID),'  '   ,
AscStatementData_Year, '-', DATENAME(MONTH, DATEFROMPARTS(AscStatementData_Year, AscStatementData_Month, 1))) AS ESSMonthName
   ,AscStatementData_PartyRegisteration_Id
   ,AscStatementData_PartyName
	--   ,AscStatementData_RECEIVABLE 

   ,CASE WHEN msp.SrProcessDef_ID=8
   THEN AscStatementData_AdjustmentRECEIVABLE
		ELSE AscStatementData_RECEIVABLE
	END AS AscStatementData_RECEIVABLE INTO #tempASCReceivable
FROM AscStatementDataMpMonthly_SettlementProcess mpMonthly
JOIN MtStatementProcess MSP
	ON MSP.MtStatementProcess_ID = mpMonthly.AscStatementData_StatementProcessId
WHERE AscStatementData_StatementProcessId IN (SELECT
		MtStatementProcess_ID
	FROM #temp
	WHERE SrProcessDef_ID IN (2, 5, 8))

--**************************************************************************************  
--     ASC Months  
--**************************************************************************************  
declare @monthsSumPayable nvarchar(max);

declare @monthsASCPayable nvarchar(max);
SELECT
	@monthsASCPayable = ISNULL(@monthsASCPayable + ',', '') + QUOTENAME(RTRIM(AE.ESSMonthName))
   ,@monthsSumPayable = ISNULL(@monthsSumPayable + '+', '') + 'ISNULL(' + QUOTENAME(RTRIM(AE.ESSMonthName)) + ',0)'

FROM (SELECT DISTINCT
		ESSMonthName
	FROM #tempASCPayable) AE;

declare @monthsSumReceivable nvarchar(max);
declare @monthsASCReceivable nvarchar(max);

SELECT
	@monthsASCReceivable = ISNULL(@monthsASCReceivable + ',', '') + QUOTENAME(RTRIM(AE.ESSMonthName))
   ,@monthsSumReceivable = ISNULL(@monthsSumReceivable + '+', '') + 'ISNULL(' + QUOTENAME(RTRIM(AE.ESSMonthName)) + ',0)'
FROM (SELECT DISTINCT
		ESSMonthName
	FROM #tempASCReceivable) AE;
--**************************************************************************************  
--    Sort Months 
--**************************************************************************************  

SELECT
	value INTO #tempSortColumns
FROM STRING_SPLIT((@monthsBME + ',' + @monthsASCPayable + ',' + @monthsASCReceivable), ',')



SELECT
	CONCAT('IsNull(',value, ',0) as ', STUFF(value, (CHARINDEX('[', value) + 1), 2, '')) AS MonthsValues
--SELECT value AS MonthsValues
INTO #tempWithAlias
FROM #tempSortColumns
ORDER BY 1

SELECT
	CONCAT('(SELECT ISNULL(SUM(',MonthsValues, ',0) FROM #tempFinal)' ) AS MonthsValues
INTO #tempWithAliasSum
FROM #tempWithAlias
ORDER BY 1


--SELECT
--	*
--FROM #tempSortColumns
--SELECT
--	*
--FROM #tempWithAlias
--return
DECLARE @dynamicMonthNames nvarchar(max)=NULL
DECLARE @dynamicMonthNamesWithAlias nvarchar(max)=NULL
DECLARE @dynamicMonthNamesWithAliasSum nvarchar(max)=NULL

SELECT
	@dynamicMonthNames = COALESCE(@dynamicMonthNames + ',', '') + value
FROM #tempSortColumns
ORDER BY value

SELECT
	@dynamicMonthNamesWithAlias = COALESCE(@dynamicMonthNamesWithAlias + ',', '') + MonthsValues
FROM #tempWithAlias
ORDER BY MonthsValues

SELECT
	@dynamicMonthNamesWithAlias = COALESCE(@dynamicMonthNamesWithAlias + ',', '') + MonthsValues
FROM #tempWithAliasSum
ORDER BY MonthsValues

-- select * from #tempWithAlias
 --select  @dynamicMonthNames
--return
--**************************************************************************************  
--     Dynamic Pivot Queries 
--**************************************************************************************  
declare @pivotQueries nvarchar(max);



SET @pivotQueries =
'
SELECT
	*  into #tempPTBme
FROM (SELECT
	   ESSMonthName
	   ,BmeStatementData_PartyName
	   ,BmeStatementData_PartyRegisteration_Id
	   ,BmeStatementData_AmountPayableReceivable
	FROM #tempBME t) s
PIVOT (SUM([BmeStatementData_AmountPayableReceivable])
FOR [ESSMonthName] IN (' + @monthsBME + ')) AS pt

SELECT * into #tempPtPayable
FROM (SELECT ESSMonthName
	   ,AscStatementData_PartyName
	   ,AscStatementData_PartyRegisteration_Id
	   ,AscStatementData_PAYABLE
	FROM #tempASCPayable t) s
PIVOT ( SUM([AscStatementData_PAYABLE])
FOR [ESSMonthName] IN (' + @monthsASCPayable + ')) AS pt

SELECT
* into #tempPtReceivable
FROM (SELECT ESSMonthName 
	   ,AscStatementData_PartyName
	   ,AscStatementData_PartyRegisteration_Id
	   ,AscStatementData_RECEIVABLE
	FROM #tempASCReceivable t) s
PIVOT (
SUM([AscStatementData_RECEIVABLE])
FOR [ESSMonthName] IN (' + @monthsASCReceivable + ')) AS pt

select BmeStatementData_PartyRegisteration_Id, BmeStatementData_PartyName,' + @dynamicMonthNames + '
into #tempWithoutAggregated
 from #tempPTBme bme 
left join #tempPtPayable AscPay on bme.BmeStatementData_PartyRegisteration_Id=AscPay.AscStatementData_PartyRegisteration_Id
left join #tempPtReceivable AscRec on bme.BmeStatementData_PartyRegisteration_Id=AscRec.AscStatementData_PartyRegisteration_Id

SELECT 
BmeStatementData_PartyRegisteration_Id as [Party Id], BmeStatementData_PartyName as [Party Name],'
+@dynamicMonthNamesWithAlias+','
 + @monthsBMESum + '+' + @monthsSumPayable + '-IsNull((' + @monthsSumReceivable + '),0) as [Net Amount] into #tempFinal FROM #tempWithoutAggregated

INSERT INTO #tempFinal
		([Party Id]
		,[Party Name]
		,'+@dynamicMonthNamesWithAlias+'
		)
	VALUES
	(
	'',''Total'',
	#tempWithAliasSum
	)

	select * from #tempFinal
';
EXEC (@pivotQueries);


  END
  END
