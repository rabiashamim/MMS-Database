/****** Object:  Procedure [dbo].[CO_ExecuteProcess]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================    
-- Author:  Ali Imran | Sadaf Malik    
-- CREATE date: June 01, 2023     
-- ALTER date: 
-- Description: 
-- Parameters: @Year, @Month, @StatementProcessId    
-- =============================================  
-- dbo.CO_ExecuteProcess 2176,'2022-2023',1
CREATE   PROCEDUREdbo.CO_ExecuteProcess @pStatementProcessId DECIMAL(18, 0),
@pYear VARCHAR(40),
@pUserId INT

AS
BEGIN

	BEGIN TRY

/*---------------------------------------------------------------------------------
---------------------------------------------------------------------------------*/

	UPDATE MtStatementProcess
SET MtStatementProcess_ExecutionStartDate = GETDATE()
WHERE MtStatementProcess_ID = @pStatementProcessId
/*---------------------------------------------------------------------------------
---------------------------------------------------------------------------------*/
		DECLARE @vProcessDefId INT = 0;
		DECLARE @vDescription VARCHAR(1000);
		DECLARE @vRuStepDefId INT;
/*---------------------------------------------------------------------------------
---------------------------------------------------------------------------------*/
		SELECT
			@vProcessDefId = SrProcessDef_ID
		FROM MtStatementProcess
		WHERE MtStatementProcess_ID = @pStatementProcessId

/*---------------------------------------------------------------------------------
1. starting year 2022-2023
---------------------------------------------------------------------------------*/
DROP TABLE IF EXISTS #5years

SELECT
	REPLACE(LuAccountingMonth_MonthName,' ','') AS LuAccountingMonth_MonthName
   ,LuAccountingMonth_FromDate
   ,LuAccountingMonth_ToDate 
			INTO #5years
FROM LuAccountingMonth
WHERE LuAccountingMonth_IsDeleted = 0
AND PeriodTypeID = 3
AND LuAccountingMonth_Id = (SELECT
		LuAccountingMonth_Id_Current
	FROM MtStatementProcess
	WHERE MtStatementProcess_ID = @pStatementProcessId)

--select * from #5years

/*---------------------------------------------------------------------------------
2. Generating Dates for next five years
---------------------------------------------------------------------------------*/

DECLARE @i INT
SET @i = 1
WHILE (@i <= 4)
BEGIN
INSERT INTO #5years
	SELECT TOP 1
		CAST(DATEPART(YEAR, DATEADD(YEAR, @i, LuAccountingMonth_FromDate)) AS VARCHAR(4))
		+ '-' + CAST(DATEPART(YEAR, DATEADD(YEAR, @i, LuAccountingMonth_ToDate)) AS VARCHAR(4))
	   ,DATEADD(YEAR, @i, LuAccountingMonth_FromDate)
	   ,DATEADD(YEAR, @i, LuAccountingMonth_ToDate)
	FROM #5years

SET @i = @i + 1
END


/*---------------------------------------------------------------------------------
2. Get Generators having Associated Capacity
---------------------------------------------------------------------------------*/
DROP TABLE IF EXISTS #GenAssociatedCapacity
SELECT
	MtPartyRegistration_BuyerId
   ,G.MtGenerator_Id
   ,D.MtFCCADetails_AssociatedCapacity
   ,D.MtContractRegistration_Id
   ,GEN.MtGenerator_EffectiveFrom
   ,GEN.MtGenerator_EffectiveTo
   ,1 AS IsLegacyCO
   INTO #GenAssociatedCapacity
FROM MtFCCAMaster M
JOIN MtFCCAGenerator G
	ON M.MtFCCAMaster_Id = G.MtFCCAMaster_Id
JOIN MtFCCADetails D
	ON D.MtFCCAGenerator_Id = G.MtFCCAGenerator_Id
JOIN MtGenerator GEN
	ON G.MtGenerator_Id = GEN.MtGenerator_Id
WHERE 1 = 1
AND M.MtFCCAMaster_ApprovalStatus = 'Approved'
AND M.MtFCCAMaster_IsDeleted = 0
AND G.MtFCCAGenerator_IsDeleted = 0
AND D.MtFCCADetails_IsDeleted = 0
AND ISNULL(D.MtFCCADetails_AssociatedCapacity,0)>0
UNION
SELECT
	CR.MtContractRegistration_BuyerId
   ,CC.MtContractCertificates_Generator_Id
   ,SUM(MtContractCertificates_AssociatedCapacity) AS MtFCCADetails_AssociatedCapacity
   ,CC.MtContractRegistration_Id
   ,GEN.MtGenerator_EffectiveFrom
   ,GEN.MtGenerator_EffectiveTo
   ,0 AS IsLegacyCO
FROM MtContractCertificates CC
JOIN MtContractRegistration CR
	ON CR.MtContractRegistration_Id = CC.MtContractRegistration_Id
JOIN MtGenerator GEN
	ON GEN.MtGenerator_Id = CC.MtContractCertificates_Generator_Id
WHERE ISNULL(GEN.MtGenerator_IsDeleted, 0) = 0
AND ISNULL(GEN.isDeleted, 0) = 0
AND cc.MtContractCertificates_IsDisabled=0
AND CR.MtContractRegistration_ApprovalStatus='CAAP'
GROUP BY CC.MtContractRegistration_Id
		,CC.MtContractCertificates_Generator_Id
		,CR.MtContractRegistration_BuyerId
		,GEN.MtGenerator_EffectiveFrom
		,GEN.MtGenerator_EffectiveTo

/*---------------------------------------------------------------------------------
2. Check in which year  Generators is effective.
If generator is available half fiscal year than this will be effective.
---------------------------------------------------------------------------------*/
DROP TABLE IF EXISTS #GeneratorsWithAssociatedCapacity
SELECT
	LuAccountingMonth_MonthName
   ,MtGenerator_Id
   ,MtPartyRegistration_BuyerId
   ,MtContractRegistration_Id
	--,MtFCCADetails_AssociatedCapacity
	,MtGenerator_EffectiveFrom
	,MtGenerator_EffectiveTo
   ,LuAccountingMonth_FromDate
   ,LuAccountingMonth_ToDate
   ,CASE
		WHEN MtGenerator_EffectiveTo IS NULL AND 
		--DATEPART(YEAR,LuAccountingMonth_FromDate) > DATEPART(YEAR,MtGenerator_EffectiveFrom) 
		LuAccountingMonth_ToDate > MtGenerator_EffectiveFrom
		 THEN 1
		WHEN
			(LuAccountingMonth_ToDate BETWEEN MtGenerator_EffectiveFrom AND MtGenerator_EffectiveTo OR
			LuAccountingMonth_FromDate BETWEEN MtGenerator_EffectiveFrom AND MtGenerator_EffectiveTo)
			AND MtGenerator_EffectiveTo>LuAccountingMonth_ToDate
			THEN 1
		WHEN LuAccountingMonth_FromDate > MtGenerator_EffectiveFrom THEN 1
		ELSE 0
	END AS IsEffectiveGenerator
	/*WHen Gen Is Effective than Associated Capacity is consider*/
   ,CASE
		WHEN MtGenerator_EffectiveTo IS NULL AND
			--LuAccountingMonth_FromDate >= MtGenerator_EffectiveFrom THEN MtFCCADetails_AssociatedCapacity
				LuAccountingMonth_ToDate > MtGenerator_EffectiveFrom THEN MtFCCADetails_AssociatedCapacity
		WHEN
			LuAccountingMonth_ToDate BETWEEN MtGenerator_EffectiveFrom AND MtGenerator_EffectiveTo OR
			LuAccountingMonth_FromDate BETWEEN MtGenerator_EffectiveFrom AND MtGenerator_EffectiveTo 
			AND MtGenerator_EffectiveTo>LuAccountingMonth_ToDate
			THEN MtFCCADetails_AssociatedCapacity
		ELSE 0
	END AS AssociatedCapacity
	,IsLegacyCO
	INTO #GeneratorsWithAssociatedCapacity
FROM #GenAssociatedCapacity
	,#5years


/*---------------------------------------------------------------------------------
3. Check in contract is effective.
---------------------------------------------------------------------------------*/


INSERT INTO COCGenWise (
    YearName 
   ,MtPartyRegisteration_Id 
   ,MtGenerator_Id 
   ,MtContractRegistration_Id
   ,AssociatedCapacity
   ,IsEffectiveGenerator
   ,MtGenerator_EffectiveFrom
   ,MtGenerator_EffectiveTo
   ,MtContractRegistration_EffectiveFrom
   ,MtContractRegistration_EffectiveTo
   ,IsEffectiveCONTRACT
   ,StatementProcessId
   ,COCGenWise_IsLeagacy_CO
)
SELECT
	GAC.LuAccountingMonth_MonthName
   ,GAC.MtPartyRegistration_BuyerId
   ,GAC.MtGenerator_Id
   ,GAC.MtContractRegistration_Id
   ,GAC.AssociatedCapacity
   ,GAC.IsEffectiveGenerator
   ,GAC.MtGenerator_EffectiveFrom
   ,GAC.MtGenerator_EffectiveTo
   ,CR.MtContractRegistration_EffectiveFrom
   ,CR.MtContractRegistration_EffectiveTo

   ,CASE
		WHEN MtContractRegistration_EffectiveTo IS NULL AND
			LuAccountingMonth_FromDate >= CR.MtContractRegistration_EffectiveFrom THEN 1
		WHEN
			LuAccountingMonth_ToDate BETWEEN MtContractRegistration_EffectiveFrom AND MtContractRegistration_EffectiveTo OR
			LuAccountingMonth_FromDate BETWEEN MtContractRegistration_EffectiveFrom AND MtContractRegistration_EffectiveTo THEN 1
		ELSE 0
	END AS IsEffectiveContract 
	,@pStatementProcessId
	,IsLegacyCO
	
FROM #GeneratorsWithAssociatedCapacity GAC
JOIN MtContractRegistration CR
	ON GAC.MtContractRegistration_Id = CR.MtContractRegistration_Id
--WHERE GAC.IsEffective = 1

/*---------------------------------------------------------------------------------
Calaculate Capacity Credited
---------------------------------------------------------------------------------*/
--DROP TABLE IF EXISTS #CreditedCapacity
INSERT INTO COCMPWise
(
     YearName
    ,MtPartyRegisteration_Id
    ,CapacityCredited
    ,StatementProcessId
	,COCMPWise_IsLeagacy_CO
	
)
SELECT
	YearName
   ,MtPartyRegisteration_Id
   ,SUM(AssociatedCapacity) AS CapacityCredited 
   ,@pStatementProcessId
   ,COCGenWise_IsLeagacy_CO
   --INTO #CreditedCapacity
FROM COCGenWise
--WHERE IsEffectiveContract=1
WHERE StatementProcessId=@pStatementProcessId
GROUP BY MtPartyRegisteration_Id
		,YearName,COCGenWise_IsLeagacy_CO


/*---------------------------------------------------------------------------------


---------------------------------------------------------------------------------*/
	IF NOT EXISTS (SELECT TOP 1 1
	FROM MTDemandForecast DF
	WHERE DF.MtSOFileMaster_Id = dbo.GetMtSoFileMasterId(@pStatementProcessId, 14))
	BEGIN
	

		
		SELECT
			@vRuStepDefId = RuStepDef_ID
		FROM RuStepDef
		WHERE SrProcessDef_ID = @vProcessDefId
		AND RuStepDef_BMEStepNo = 0
		EXEC [dbo].[SaveMtSattlementProcessLogs] @StatementProcessId = @pStatementProcessId
												,@pRuStepDef_ID = @vRuStepDefId
												,@LogsMessage = 'Demand Forecast data not found for this process'
												,@OutputMessage = 'Error'
												,@OutputStatus = 0

		
		
		UPDATE MtStatementProcess
		SET MtStatementProcess_Status = 'Interrupted'
		   ,MtStatementProcess_ExecutionFinishDate = GETDATE()
		WHERE MtStatementProcess_ID = @pStatementProcessId


		RAISERROR ('Demand Forecast data not found for this process', 16, -1);
			RETURN;



	END


/*---------------------------------------------------------------------------------



---------------------------------------------------------------------------------*/


SELECT DISTINCT
	CC.MtPartyRegisteration_Id 
	INTO #checkIfPartyDemandNotFind
FROM COCMPWise CC
WHERE CC.StatementProcessId = @pStatementProcessId
AND CC.MtPartyRegisteration_Id
NOT IN (SELECT DISTINCT
		DF.MtParty_Id
	FROM MTDemandForecast DF
	WHERE DF.MtSOFileMaster_Id = dbo.GetMtSoFileMasterId(@pStatementProcessId, 14))


IF EXISTS (SELECT TOP 1 1 FROM #checkIfPartyDemandNotFind)
BEGIN


	DECLARE @Parties VARCHAR(200) = NULL
			SELECT
				@Parties = COALESCE(@Parties + ',', '') + CAST(MtPartyRegisteration_Id AS VARCHAR(10))
			FROM #checkIfPartyDemandNotFind

			SET @Parties = 'MP(s) (' + @Parties + ') not find in DemandForecast data.'
			
					EXEC [dbo].[SaveMtSattlementProcessLogs] @StatementProcessId = @pStatementProcessId
												,@pRuStepDef_ID = @vRuStepDefId
												,@LogsMessage = @Parties
												,@OutputMessage = 'Error'
												,@OutputStatus = 0
			RAISERROR (@Parties, 16, -1);

		
		SELECT
			@vRuStepDefId = RuStepDef_ID
		FROM RuStepDef
		WHERE SrProcessDef_ID = @vProcessDefId
		AND RuStepDef_BMEStepNo = 3
		EXEC [dbo].[SaveMtSattlementProcessLogs] @StatementProcessId = @pStatementProcessId
												,@pRuStepDef_ID = @vRuStepDefId
												,@LogsMessage = @Parties
												,@OutputMessage = 'Error'
												,@OutputStatus = 0

		
		
		UPDATE MtStatementProcess
		SET MtStatementProcess_Status = 'Interrupted'
		   ,MtStatementProcess_ExecutionFinishDate = GETDATE()
		WHERE MtStatementProcess_ID = @pStatementProcessId

			RETURN;

END 
/*---------------------------------------------------------------------------------
---------------------------------------------------------------------------------*/		
		SELECT
			@vRuStepDefId = RuStepDef_ID
		FROM RuStepDef
		WHERE SrProcessDef_ID = @vProcessDefId
		AND RuStepDef_BMEStepNo = 1

		SET @vDescription = CONCAT('Step # 0 - completed at ', FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm tt', 'en-US'));
		EXEC [dbo].[SaveMtSattlementProcessLogs] @StatementProcessId = @pStatementProcessId
												,@pRuStepDef_ID = @vRuStepDefId
												,@LogsMessage = @vDescription
												,@OutputMessage = 'Success'
												,@OutputStatus = 1
	   SELECT
			@vRuStepDefId = RuStepDef_ID
		FROM RuStepDef
		WHERE SrProcessDef_ID = @vProcessDefId
		AND RuStepDef_BMEStepNo = 2

		SET @vDescription = CONCAT('Step # 1 -  completed at ', FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm tt', 'en-US'));
		EXEC [dbo].[SaveMtSattlementProcessLogs] @StatementProcessId = @pStatementProcessId
												,@pRuStepDef_ID = @vRuStepDefId
												,@LogsMessage = @vDescription
												,@OutputMessage = 'Success'
												,@OutputStatus = 1

		SELECT
			@vRuStepDefId = RuStepDef_ID
		FROM RuStepDef
		WHERE SrProcessDef_ID = @vProcessDefId
		AND RuStepDef_BMEStepNo = 3
		SET @vDescription = CONCAT('Step # 2 -  completed at ', FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm tt', 'en-US'));
		EXEC [dbo].[SaveMtSattlementProcessLogs] @StatementProcessId = @pStatementProcessId
												,@pRuStepDef_ID = @vRuStepDefId
												,@LogsMessage = @vDescription
												,@OutputMessage = 'Success'
												,@OutputStatus = 1


/*---------------------------------------------------------------------------------
Get Latest version of demand forecast for capacity  obligation.

--SELECT * FROM MtSOFileMaster WHERE LuSOFileTemplate_Id=14 
--AND MtSOFileMaster_ApprovalStatus = 'Approved'
---------------------------------------------------------------------------------*/


UPDATE  CC
	 SET 
		CC.DemandForecast_CapacityObligation=DF.MTDemandForecast_CapacityObligation
		,CC.CapacityObligationCompliance=
			CASE
			WHEN CC.CapacityCredited = 0 THEN 0
			ELSE ((CC.CapacityCredited - DF.MTDemandForecast_CapacityObligation) / CC.CapacityCredited) * 100
	END
FROM MTDemandForecast DF
JOIN COCMPWise CC
	ON DF.MTDemandForecast_Year = CC.YearName
		AND DF.MtParty_Id = CC.MtPartyRegisteration_Id
WHERE MtSOFileMaster_Id =   dbo.GetMtSoFileMasterId(@pStatementProcessId, 14)
AND CC.StatementProcessId=@pStatementProcessId

/*---------------------------------------------------------------------------------
Calculate Compliance status
---------------------------------------------------------------------------------*/
UPDATE COCMPWise
	SET luCOComplianceStatus_Id=
	CASE WHEN CapacityObligationCompliance >= -2 THEN 1
	WHEN CapacityObligationCompliance <-2 AND CapacityObligationCompliance >=-5 THEN 2
	ELSE 3
	END 
FROM COCMPWise C
WHERE 
C.StatementProcessId=@pStatementProcessId

/*---------------------------------------------------------------------------------
 Executed status changes
---------------------------------------------------------------------------------*/
	
		UPDATE MtStatementProcess
		SET MtStatementProcess_Status = 'Executed'
		   ,MtStatementProcess_ExecutionFinishDate = GETDATE()
		WHERE MtStatementProcess_ID = @pStatementProcessId

/*---------------------------------------------------------------------------------
Completed Successfully 
---------------------------------------------------------------------------------*/


	SELECT
			@vRuStepDefId = RuStepDef_ID
		FROM RuStepDef
		WHERE SrProcessDef_ID = @vProcessDefId
		AND RuStepDef_BMEStepNo = 3
		SET @vDescription = CONCAT('completed at ', FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm tt', 'en-US'));
		EXEC [dbo].[SaveMtSattlementProcessLogs] @StatementProcessId = @pStatementProcessId
												,@pRuStepDef_ID = @vRuStepDefId
												,@LogsMessage = @vDescription
												,@OutputMessage = 'Success'
												,@OutputStatus = 1

	UPDATE MtStatementProcess
SET MtStatementProcess_ExecutionFinishDate = GETDATE()
WHERE MtStatementProcess_ID = @pStatementProcessId
	END TRY
	BEGIN CATCH
		DECLARE @vErrorMessage VARCHAR(MAX) = '';
		SELECT
			@vErrorMessage = ERROR_MESSAGE();
				UPDATE MtStatementProcess
SET MtStatementProcess_ExecutionFinishDate = ''
,MtStatementProcess_ExecutionStartDate=''
WHERE MtStatementProcess_ID = @pStatementProcessId
		RAISERROR (@vErrorMessage, 16, -1);
		RETURN;
	END CATCH




END
