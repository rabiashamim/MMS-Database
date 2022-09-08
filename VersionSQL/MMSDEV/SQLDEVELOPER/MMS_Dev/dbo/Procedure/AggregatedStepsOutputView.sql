/****** Object:  Procedure [dbo].[AggregatedStepsOutputView]    Committed by VersionSQL https://www.versionsql.com ******/

-- [dbo].AggregatedStepsOutputView 41,2

CREATE PROCEDURE [dbo].[AggregatedStepsOutputView] 
@pSettlementProcessId INT
,@pStepId INT
--DECLARE @pSettlementProcessId INT = 41
--DECLARE @pStepId DECIMAL(4, 1) = 2
AS
BEGIN


/************************************************************************************************************ 

************************************************************************************************************/
DECLARE @LuAccountingMonth_Id AS INT
DROP TABLE IF EXISTS #tempAggregatedESS
DROP TABLE IF EXISTS #tempAggregatedFSS
DROP TABLE IF EXISTS #tempAgrragatedFSSData
DROP TABLE IF EXISTS #tempAgrragatedESSData
DROP TABLE IF EXISTS #tempAdjustedESS
DROP TABLE IF EXISTS #tempAdjustedESSFinal
/************************************************************************************************************ 

************************************************************************************************************/
SELECT
	@LuAccountingMonth_Id = LuAccountingMonth_Id_Current
FROM MtStatementProcess
WHERE MtStatementProcess_ID = @pSettlementProcessId;

PRINT @LuAccountingMonth_Id



/************************************************************************************************************ 
aggreagated ESS
************************************************************************************************************/
SELECT
	MtStatementProcess_ID
   ,SrProcessDef_ID
   ,LuAccountingMonth_Id
   ,LuAccountingMonth_Id_Current INTO #tempAggregatedESS
FROM MtStatementProcess
WHERE LuAccountingMonth_Id = @LuAccountingMonth_Id
AND SrProcessDef_ID IN (12) --12 means aggreagated ESS
AND ISNULL(MtStatementProcess_IsDeleted, 0) = 0

/************************************************************************************************************ 
aggreagated FSS
************************************************************************************************************/


SELECT
	* INTO #tempAggregatedFSS
FROM MtStatementProcess msp
WHERE msp.LuAccountingMonth_Id_Current in (SELECT
		msp1.LuAccountingMonth_Id_Current
	FROM #tempAggregatedESS msp1)
AND msp.SrProcessDef_ID = 11 --11 means aggreagated FSS


/************************************************************************************************************ 
Net Adjustment: Aggregated ESS Oct - Aggregated FSS Oct
************************************************************************************************************/

SELECT
	* INTO #tempAgrragatedFSSData
FROM StatementDataAggregated
WHERE MtStatementProcess_ID in (SELECT
		ae.MtStatementProcess_ID
	FROM #tempAggregatedFSS ae);

SELECT
	* INTO #tempAgrragatedESSData
FROM StatementDataAggregated
WHERE MtStatementProcess_ID in (SELECT 
		ae.MtStatementProcess_ID
	FROM #tempAggregatedESS ae);

/************************************************************************************************************ 

************************************************************************************************************/
SELECT
	ess.StatementDataAggregated_Month 
   ,ess.StatementDataAggregated_Year
   ,ess.StatementDataAggregated_PartyRegisteration_Id 
   ,ess.StatementDataAggregated_PartyName 
   ,(ISNULL(ess.StatementDataAggregated_BmeStatementData_AmountPayableReceivable, 0) + ISNULL(ess.StatementDataAggregated_AscStatementData_PAYABLE, 0) + ISNULL(ess.StatementDataAggregated_AscStatementData_RECEIVABLE, 0))
	- (ISNULL(fss.StatementDataAggregated_BmeStatementData_AmountPayableReceivable, 0) + ISNULL(fss.StatementDataAggregated_AscStatementData_PAYABLE, 0) + ISNULL(fss.StatementDataAggregated_AscStatementData_RECEIVABLE, 0))
	AS AdjustmentESS
INTO #tempAdjustedESS
FROM #tempAgrragatedFSSData fss
JOIN #tempAgrragatedESSData ess
	ON fss.StatementDataAggregated_PartyRegisteration_Id = ess.StatementDataAggregated_PartyRegisteration_Id
	AND Fss.StatementDataAggregated_Month=ess.StatementDataAggregated_Month
	AND FSS.StatementDataAggregated_Year=ess.StatementDataAggregated_Year


/************************************************************************************************************ 

************************************************************************************************************/
IF (@pStepId = 2)
BEGIN
	SELECT
		ROW_NUMBER() OVER (ORDER BY SDA.StatementDataAggregated_Id) AS [Sr]
	   ,SDA.StatementDataAggregated_Month AS [Month]
	   ,SDA.StatementDataAggregated_Year
		AS [Year]
	   ,SDA.StatementDataAggregated_PartyRegisteration_Id AS [Party Registration Id]
	   ,SDA.StatementDataAggregated_PartyName AS [Party Name]
	   ,ISNULL(SDA.StatementDataAggregated_BmeStatementData_AmountPayableReceivable,0) AS [BME Charges]
	   ,ISNULL(SDA.StatementDataAggregated_AscStatementData_PAYABLE,0) AS [ASC Payable]
	   ,SDA.StatementDataAggregated_AscStatementData_RECEIVABLE AS [ASC Receivable]
	   ,ISNULL(SDA.StatementDataAggregated_BmeStatementData_AmountPayableReceivable, 0) + ISNULL(SDA.StatementDataAggregated_AscStatementData_PAYABLE, 0) + ISNULL(SDA.StatementDataAggregated_AscStatementData_RECEIVABLE, 0) AS [Net Amount]
	   ,CONCAT(AE.StatementDataAggregated_Year ,'-',DATENAME(MONTH,DATEFROMPARTS(AE.StatementDataAggregated_Year,AE.StatementDataAggregated_Month,1)) ) AS ESSMonthName	   
	   ,AE.AdjustmentESS 
       INTO #tempAdjustedESSFinal 
	FROM StatementDataAggregated SDA
	LEFT JOIN #tempAdjustedESS AE ON SDA.StatementDataAggregated_PartyRegisteration_Id=AE.StatementDataAggregated_PartyRegisteration_Id
	WHERE SDA.MtStatementProcess_ID =@psettlementProcessId
--	AND AE.AdjustmentESS  IS NOT null
	ORDER BY AE.StatementDataAggregated_Month,SDA.StatementDataAggregated_PartyRegisteration_Id;

/************************************************************************************************************ 

************************************************************************************************************/

declare @months nvarchar(max),
@query nvarchar(max);
select @months = ISNULL(@months+',','')+ QUOTENAME(rtrim(AE.ESSMonthName)) from (select distinct ESSMonthName from #tempAdjustedESSFinal) AE;

/************************************************************************************************************ 

************************************************************************************************************/

--set @query='Select * from( SELECT [Month],[Year],[Party Registration Id],[Party Name],[BME Charges],[ASC Payable],[ASC Receivable],[Net Amount],AdjustmentESS,ESSMonthName FROM #tempAdjustedESSFinal)  s
--pivot (
--sum([AdjustmentESS])
--for [ESSMonthName] in('+@months+')) as pt';

if(@months='[-]')
BEGIN
set @query='SELECT [Month],[Year],[Party Registration Id],[Party Name],[BME Charges],[ASC Payable],[ASC Receivable],[Net Amount] FROM #tempAdjustedESSFinal';
END
ELSE
BEGIN
set @query='Select * from( SELECT [Month],[Year],[Party Registration Id],[Party Name],[BME Charges],[ASC Payable],[ASC Receivable],[Net Amount],AdjustmentESS,ESSMonthName FROM #tempAdjustedESSFinal)  s
pivot (
sum([AdjustmentESS])
for [ESSMonthName] in('+@months+')) as pt';


END

exec (@query);

END

END
