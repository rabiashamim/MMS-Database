/****** Object:  Procedure [dbo].[GETMonthlySettlementListing]    Committed by VersionSQL https://www.versionsql.com ******/

--======================================================================                    
--Author  : Sadaf Malik                    
--Reviewer : <>                    
--CreatedDate : 01 Mar 2022                    
--Comments :                     
--======================================================================                    
--use mms                    
--dbo.GETMonthlySettlementListing 260                  
CREATE PROCEDURE dbo.GETMonthlySettlementListing @pSettlementProcessId AS DECIMAL(18, 0) = NULL
AS
BEGIN

	SELECT
		MtStatementProcess_ID
	   ,SrProcessDef_ID
	   ,ProcessName = (SELECT
				CONCAT(SPD.SrProcessDef_Name, ' - ', SSD.SrStatementDef_Name)
			FROM SrStatementDef SSD
			INNER JOIN SrProcessDef SPD
				ON SPD.SrStatementDef_ID = SSD.SrStatementDef_ID
			WHERE SPD.SrProcessDef_ID = MtStatementProcess.SrProcessDef_ID)
	   ,EssSettlementPeriod = (SELECT
				LuAccountingMonth_MonthName
			FROM LuAccountingMonth
			WHERE LuAccountingMonth_Id = MtStatementProcess.LuAccountingMonth_Id)

	   ,CASE
			WHEN (SELECT
						CONCAT(SPD.SrProcessDef_Name, ' - ', SSD.SrStatementDef_Name)
					FROM SrStatementDef SSD
					INNER JOIN SrProcessDef SPD
						ON SPD.SrStatementDef_ID = SSD.SrStatementDef_ID
					WHERE SPD.SrProcessDef_ID = MtStatementProcess.SrProcessDef_ID)
				= 'BMC - Preliminary' THEN (SELECT
						RuModulesProcess_Id
					FROM RuModulesProcess
					WHERE RuModulesProcess_IsActive = 1
					AND RuModulesProcess_IsDeleted = 0
					AND RuModulesProcess_Name = 'BMC - Preliminary')
			WHEN (SELECT
						CONCAT(SPD.SrProcessDef_Name, ' - ', SSD.SrStatementDef_Name)
					FROM SrStatementDef SSD
					INNER JOIN SrProcessDef SPD
						ON SPD.SrStatementDef_ID = SSD.SrStatementDef_ID
					WHERE SPD.SrProcessDef_ID = MtStatementProcess.SrProcessDef_ID)
				= 'BMC - Final' THEN (SELECT
						RuModulesProcess_Id
					FROM RuModulesProcess
					WHERE RuModulesProcess_IsActive = 1
					AND RuModulesProcess_IsDeleted = 0
					AND RuModulesProcess_Name = 'BMC - Final')
			WHEN (SELECT
						CONCAT(SPD.SrProcessDef_Name, ' - ', SSD.SrStatementDef_Name)
					FROM SrStatementDef SSD
					INNER JOIN SrProcessDef SPD
						ON SPD.SrStatementDef_ID = SSD.SrStatementDef_ID
					WHERE SPD.SrProcessDef_ID = MtStatementProcess.SrProcessDef_ID)
				= 'BMC - PYSS' THEN (SELECT
						RuModulesProcess_Id
					FROM RuModulesProcess
					WHERE RuModulesProcess_IsActive = 1
					AND RuModulesProcess_IsDeleted = 0
					AND RuModulesProcess_Name = 'BMC - PYSS')
			WHEN (SELECT
						CONCAT(SPD.SrProcessDef_Name, ' - ', SSD.SrStatementDef_Name)
					FROM SrStatementDef SSD
					INNER JOIN SrProcessDef SPD
						ON SPD.SrStatementDef_ID = SSD.SrStatementDef_ID
					WHERE SPD.SrProcessDef_ID = MtStatementProcess.SrProcessDef_ID)
				= 'ETL - PYSS' THEN (SELECT
						RuModulesProcess_Id
					FROM RuModulesProcess
					WHERE RuModulesProcess_IsActive = 1
					AND RuModulesProcess_IsDeleted = 0
					AND RuModulesProcess_Name = 'ETL - PYSS')
			ELSE ''
		END AS WfModuleProcessID

	   ,LuAccountingMonth_MonthName AS SettlementPeriod
	   ,CASE
			WHEN SrProcessDef_ID IN (1, 2, 4, 5, 10, 11,24,25) THEN LuAccountingMonth_MonthName -- for BME/ASC pss/fss
			ELSE CASE -- for all BMC/ETL Processes along with BME/ASC ess 
					WHEN SrProcessDef_ID IN (7,8,9,12, 14, 15, 16, 17, 18, 19, 20, 21, 22,23) THEN (SELECT
								LuAccountingMonth_MonthName
							FROM LuAccountingMonth
							WHERE LuAccountingMonth_Id = MtStatementProcess.LuAccountingMonth_Id)
				END
			
		END
		AS CurrentSettlementPeriod
	   ,LuAccountingMonth_Month AS Month
	   ,LuAccountingMonth_Year AS Year
	   ,MtStatementProcess_Status
	   ,MtStatementProcess_ApprovalStatus
	   ,MtStatementProcess_ExecutionStartDate
	   ,MtStatementProcess_ExecutionFinishDate AS approvalDate
	   ,MtStatementProcess_UpdatedDate AS UpdatedDate
	   ,MtStatementProcess_ExecutionStartDate
	   ,MtStatementProcess_ExecutionFinishDate
	   ,MtStatementProcess_CreatedOn
	FROM MtStatementProcess

	LEFT JOIN LuAccountingMonth
		ON LuAccountingMonth.LuAccountingMonth_Id = MtStatementProcess.LuAccountingMonth_Id_Current
	--case when SrProcessDef_ID=19 then MtStatementProcess.LuAccountingMonth_Id else MtStatementProcess.LuAccountingMonth_Id_Current end
	WHERE ISNULL(MtStatementProcess_IsDeleted, 0) = 0
	AND (
	@pSettlementProcessId IS NULL
	OR (@pSettlementProcessId IS NOT NULL
	AND MtStatementProcess.MtStatementProcess_ID = @pSettlementProcessId)
	)

	ORDER BY LuAccountingMonth_Year DESC, LuAccountingMonth_Month DESC, MtStatementProcess_ID ASC
END
