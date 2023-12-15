/****** Object:  Procedure [dbo].[ETLStep2Perform]    Committed by VersionSQL https://www.versionsql.com ******/

--==========================================================================================
-- Author: Sadaf Malik
-- CREATE date: 13 Jan 2022
-- ALTER date:    
-- Description:               
--==========================================================================================
 --[dbo].[ETLStep1Perform] 34
/*****   25-NTDC	26-Pak Mitiari
Select * FROM [dbo].[EtlTspHourly] 
Select * FROM [dbo].[EtlHourly]
Select * from [dbo].[EtlTspData]
Select * from [dbo].[EtlMpData]
******/
CREATE   PROCEDURE dbo.ETLStep2Perform 
@pStatementProcessId DECIMAL(18, 0)
AS
BEGIN

DECLARE @luaccountingMonth AS INT;

select
	@luaccountingMonth =  LuAccountingMonth_Id_Current
from MtStatementProcess where MtStatementProcess_ID=@pStatementProcessId


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
		Step 3: Group data MP wise
		==========================================================================================*/
IF NOT EXISTS (SELECT TOP 1
			1
		FROM [dbo].[EtlTspData]
		WHERE MtStatementProcess_ID = @pStatementProcessId)
BEGIN

INSERT INTO [dbo].[EtlTspData] ([MtStatementProcess_ID]
, [MTPartyRegisteration_Id]
, [EtlTspData_TransmissionLoss]
, [EtlTspData_TotalEnergyInjected]
, [EtlTspData_TotalEnergyWithdrawal])

	SELECT
		@pStatementProcessId
	   ,MTPartyRegisteration_Id
	   ,SUM(EtlTspHourly_TransmissionLoss) / 1000
	   ,SUM(EtlTspHourly_AdjustedEnergyImport) / 1000
	   ,SUM(EtlTspHourly_AdjustedEnergyExport) / 1000
	FROM EtlTspHourly
	WHERE MtStatementProcess_ID = @pStatementProcessId
	GROUP BY MTPartyRegisteration_Id
/******************
Update allow cap from reference values
*****************/
UPDATE EtlTspData
SET EtlTspData_AllowedCap = (
SELECT 
	MAX(CASE WHEN (@FromDate>= rrv.RuReferenceValue_EffectiveFrom AND (@ToDate BETWEEN rrv.RuReferenceValue_EffectiveFrom and rrv.RuReferenceValue_EffectiveTo)  AND srt.SrReferenceType_Name = 'Cap on Transmission Losses NTDC')
	THEN rrv.RuReferenceValue_Value ELSE 0 END) AS RM
FROM RuReferenceValue rrv
JOIN SrReferenceType SRT ON RRV.SrReferenceType_Id=SRT.SrReferenceType_Id
WHERE 
 ISNULL(srt.SrReferenceType_IsDeleted, 0) = 0
 AND ISNULL(rrv.RuReferenceValue_IsDeleted, 0) = 0
)
WHERE MTPartyRegisteration_Id = 25
AND MtStatementProcess_ID=@pStatementProcessId

UPDATE EtlTspData
SET EtlTspData_AllowedCap = (
SELECT 
	MAX(CASE WHEN (@FromDate>= rrv.RuReferenceValue_EffectiveFrom AND (@ToDate BETWEEN rrv.RuReferenceValue_EffectiveFrom and rrv.RuReferenceValue_EffectiveTo)  AND srt.SrReferenceType_Name = 'Cap on Transmission Losses Mitari')
	THEN rrv.RuReferenceValue_Value ELSE 0 END) AS RM
FROM RuReferenceValue rrv
JOIN SrReferenceType SRT ON RRV.SrReferenceType_Id=SRT.SrReferenceType_Id
WHERE 
 ISNULL(srt.SrReferenceType_IsDeleted, 0) = 0
 AND ISNULL(rrv.RuReferenceValue_IsDeleted, 0) = 0
)
WHERE MTPartyRegisteration_Id = 26
AND MtStatementProcess_ID=@pStatementProcessId


/******************
Update Annual Losses
*****************/

UPDATE [dbo].[EtlTspData]
SET EtlTspData_AnnualLosses = EtlTspData_TransmissionLoss / EtlTspData_TotalEnergyInjected * 100
   ,EtlTspData_AllowableLosses = EtlTspData_AllowedCap / 100 * EtlTspData_TotalEnergyInjected
WHERE MtStatementProcess_ID = @pStatementProcessId

/******************
Calculate Excess Losses
*****************/

UPDATE [dbo].[EtlTspData]
SET EtlTspData_ExcessLosses =
CASE
	--	WHEN EtlTspData_AnnualLosses < EtlTspData_AllowableLosses THEN 0
	--	ELSE EtlTspData_TransmissionLoss - (EtlTspData_AllowableLosses * EtlTspData_TotalEnergyInjected)
	WHEN (EtlTspData_TransmissionLoss - EtlTspData_AllowableLosses) < 0 THEN 0
	ELSE EtlTspData_TransmissionLoss - EtlTspData_AllowableLosses
END
WHERE MtStatementProcess_ID = @pStatementProcessId

/******************
Weighted Marginal Price
*****************/

UPDATE EtlTspData
SET EtlTspData_WeightedAverageMarginalPrice = (SELECT
		SUM(EtlHourly_Demand * EtlHourly_MarginalPrice) / SUM(EtlHourly_Demand)
	FROM EtlHourly
	WHERE MtStatementProcess_ID = @pStatementProcessId)
WHERE MtStatementProcess_ID = @pStatementProcessId

/******************
Excess loss charges
*****************/
UPDATE EtlTspData
SET EtlTspData_TotalPayableExcessLosses = EtlTspData_ExcessLosses * EtlTspData_WeightedAverageMarginalPrice
WHERE MtStatementProcess_ID = @pStatementProcessId



END
END
