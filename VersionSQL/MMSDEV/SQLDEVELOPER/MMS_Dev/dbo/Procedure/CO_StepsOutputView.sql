/****** Object:  Procedure [dbo].[CO_StepsOutputView]    Committed by VersionSQL https://www.versionsql.com ******/

  
--==========================================================================================        
-- Author: Sadaf Malik | ALi Imran | Alina Javed     
-- CREATE date: 1 june 2023  
-- ALTER date:            
-- Description:                       
--==========================================================================================        
    --   
CREATE PROCEDURE dbo.CO_StepsOutputView (@pSettlementProcessId DECIMAL(18, 0),
@pStepId DECIMAL(4, 1))
AS
BEGIN

	IF (@pStepId = 1)
	BEGIN
		SELECT
			ROW_NUMBER() OVER (ORDER BY C.MtPartyRegisteration_Id) AS [SR]
		   ,MPR.MtPartyRegisteration_Id AS [MP ID]
		   ,MPR.MtPartyRegisteration_Name AS [MP Name]
		   ,C.YearName AS [Fiscal Year]
		   ,C.MtGenerator_Id AS [GeneratorID]
		   ,(SELECT
					mg.MtGenerator_Name
				FROM MtGenerator mg
				WHERE mg.MtGenerator_Id = C.MtGenerator_Id)
			AS [Generator Name]
		   ,C.AssociatedCapacity AS [Associated Capacity (MW)]
		   ,C.MtGenerator_EffectiveFrom AS [GeneratorEffectiveFrom]
		   ,C.MtGenerator_EffectiveTo AS [GeneratorEffectiveTo]
		   ,CASE
				WHEN C.IsEffectiveGenerator = 0 THEN 'Not Effective'
				ELSE 'Effective'
			END AS [Generator Status]
		   ,C.MtContractRegistration_EffectiveFrom AS [ContractRegistration_EffectiveFrom]
		   ,C.MtContractRegistration_EffectiveTo AS [ContractRegistration_EffectiveTo]
		   ,CASE
				WHEN c.IsEffectiveCONTRACT = 0 THEN 'Not Effective'
				ELSE 'Effective'
			END AS [Contract Status]
		FROM COCGenWise C
		INNER JOIN MtPartyRegisteration MPR
			ON MPR.MtPartyRegisteration_Id = C.MtPartyRegisteration_Id
		WHERE StatementProcessId = @pSettlementProcessId
		AND COCGenWise_IsLeagacy_CO = 1
		ORDER BY SR, GeneratorId, C.YearName

		SELECT
			ROW_NUMBER() OVER (ORDER BY C.MtPartyRegisteration_Id) AS [SR]
		   ,MPR.MtPartyRegisteration_Id AS [MP ID]
		   ,MPR.MtPartyRegisteration_Name AS [MP Name]
		   ,C.YearName AS [Fiscal Year]
		   ,c.MtContractRegistration_Id AS [Contract ID]
		   ,C.MtGenerator_Id AS [GeneratorID]
		   ,(SELECT
					mg.MtGenerator_Name
				FROM MtGenerator mg
				WHERE mg.MtGenerator_Id = C.MtGenerator_Id)
			AS [Generator NAME]
		   ,C.AssociatedCapacity AS [Associated Capacity (MW)]
		   ,C.MtGenerator_EffectiveFrom AS [GeneratorEffectiveFrom]
		   ,C.MtGenerator_EffectiveTo AS [GeneratorEffectiveTo]
		   ,CASE
				WHEN C.IsEffectiveGenerator = 0 THEN 'Not Effective'
				ELSE 'Effective'
			END AS [Generator Status]
		   ,C.MtContractRegistration_EffectiveFrom AS [ContractRegistration_EffectiveFrom]
		   ,C.MtContractRegistration_EffectiveTo AS [ContractRegistration_EffectiveTo]
		   ,CASE
				WHEN c.IsEffectiveCONTRACT = 0 THEN 'Not Effective'
				ELSE 'Effective'
			END AS [Contract Status]
		FROM COCGenWise C
		INNER JOIN MtPartyRegisteration MPR
			ON MPR.MtPartyRegisteration_Id = C.MtPartyRegisteration_Id
		WHERE StatementProcessId = @pSettlementProcessId
		AND COCGenWise_IsLeagacy_CO = 0
		ORDER BY C.MtPartyRegisteration_Id,GeneratorId,C.YearName 

	END


	ELSE
	IF (@pStepId = 2)
	BEGIN

			SELECT
			
		   mpr.MtPartyRegisteration_Id
		  ,mpr.MtPartyRegisteration_Name 
		   ,C.YearName 
		   ,CASE WHEN COCMPWise_IsLeagacy_CO=1 THEN  C.CapacityCredited ELSE 0 END AS CCL
		   ,CASE WHEN COCMPWise_IsLeagacy_CO=0 THEN  C.CapacityCredited ELSE 0 END AS CCBC
		   ,C.CapacityCredited
		INTO #temp1
		FROM COCMPWise c 
		JOIN luCOComplianceStatus cs
			ON cs.luCOComplianceStatus_Id = c.luCOComplianceStatus_Id
		JOIN MtPartyRegisteration mpr
			ON c.MtPartyRegisteration_Id = mpr.MtPartyRegisteration_Id
		WHERE c.StatementProcessId = @pSettlementProcessId
		
		SELECT 
		ROW_NUMBER() OVER (ORDER BY MtPartyRegisteration_Id) AS [SR]
		 ,MtPartyRegisteration_Id  AS [MP ID]
		,MtPartyRegisteration_Name AS [MP Name]
		,YearName  AS [Fiscal Year]
		,SUM(CCL) AS  [Capacity Credited Legacy(MW)]
		,SUM(CCBC)  AS [Capacity Credited Bilateral Contracts(MW)]
		,SUM(CCL)+SUM(CCBC) AS  [Capacity Credited (MW)]
		FROM 
		#temp1 t
		GROUP BY MtPartyRegisteration_Id
		,MtPartyRegisteration_Name
		,YearName
		ORDER BY SR, YearName, MtPartyRegisteration_Name



		--SELECT
		--	ROW_NUMBER() OVER (ORDER BY c.MtPartyRegisteration_Id) AS [SR]
		--   ,mpr.MtPartyRegisteration_Id AS [MP ID]
		--  ,mpr.MtPartyRegisteration_Name AS [MP Name]
		--   ,C.YearName AS [Fiscal Year]
		--   ,C.DemandForecast_CapacityObligation AS [Capacity Obligation (MW)]
		--   ,CASE WHEN COCMPWise_IsLeagacy_CO=1 THEN  C.CapacityCredited ELSE 0 END AS [Capacity Credited Legacy(MW)]
		--   ,CASE WHEN COCMPWise_IsLeagacy_CO=0 THEN  C.CapacityCredited ELSE 0 END AS [Capacity Credited Bilateral Contracts(MW)]
		--   ,C.CapacityCredited AS [Capacity Credited (MW)]
		--   ,C.CapacityObligationCompliance AS [Capacity Obligation Compliance(%)]
		--   ,CS.luCOComplianceStatus_Name AS [Capacity Obligation Compliance Status]
		--FROM COCMPWise c
		--JOIN luCOComplianceStatus cs
		--	ON cs.luCOComplianceStatus_Id = c.luCOComplianceStatus_Id
		--JOIN MtPartyRegisteration mpr
		--	ON c.MtPartyRegisteration_Id = mpr.MtPartyRegisteration_Id
		--WHERE c.StatementProcessId = @pSettlementProcessId
		--ORDER BY SR, c.YearName, mpr.MtPartyRegisteration_Name

			SELECT
		
		   mpr.MtPartyRegisteration_Id
		  ,mpr.MtPartyRegisteration_Name
		   ,C.YearName 
		   ,C.DemandForecast_CapacityObligation 
		   ,CASE WHEN COCMPWise_IsLeagacy_CO=1 THEN  C.CapacityCredited ELSE 0 END AS CCL
		   ,CASE WHEN COCMPWise_IsLeagacy_CO=0 THEN  C.CapacityCredited ELSE 0 END AS CCBC
		   ,C.CapacityCredited 
		   ,C.CapacityObligationCompliance 
		   ,CS.luCOComplianceStatus_Name 
		   INTO #temp2
		FROM COCMPWise c
		JOIN luCOComplianceStatus cs
			ON cs.luCOComplianceStatus_Id = c.luCOComplianceStatus_Id
		JOIN MtPartyRegisteration mpr
			ON c.MtPartyRegisteration_Id = mpr.MtPartyRegisteration_Id
		WHERE c.StatementProcessId = @pSettlementProcessId
		ORDER BY c.YearName, mpr.MtPartyRegisteration_Name

		SELECT 
		ROW_NUMBER() OVER (ORDER BY MtPartyRegisteration_Id) AS [SR]
		,MtPartyRegisteration_Id AS	[MP ID]
		,MtPartyRegisteration_Name AS	[MP Name]
		,YearName	 AS [Fiscal Year]
		,MIN(DemandForecast_CapacityObligation) AS [Capacity Obligation (MW)]
		--,SUM(CCL)	 AS [Capacity Credited Legacy(MW)]
		--,SUM(CCBC)	AS [Capacity Credited Bilateral Contracts(MW)]
		,SUM(CapacityCredited	) AS [Capacity Credited (MW)]
		,SUM(CapacityObligationCompliance)	AS [Capacity Obligation Compliance(%)]
		,MAX(luCOComplianceStatus_Name) AS [Capacity Obligation Compliance Status]
		FROM #temp2 
		GROUP BY  MtPartyRegisteration_Id,MtPartyRegisteration_Name,YearName

	END
END
