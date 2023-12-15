/****** Object:  Procedure [dbo].[EtlFyssSameAsPyss]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================          
-- Author:  Sadaf Malik                            
-- CREATE date: Jan 26, 2023                             
-- ALTER date:                             
-- Reviewer:                            
-- Description: ETL FYSS Same as PYSS                         
-- =============================================                             
-- =============================================                             
  
CREATE    PROCEDURE dbo.EtlFyssSameAsPyss 
(@pStatementProcessId DECIMAL(18, 0),  
@pUserId INT)  
  
AS  
BEGIN
  
  
 BEGIN TRY  
  
  DECLARE @vPreliminaryStatementID DECIMAL(18, 0);
SELECT
	@vPreliminaryStatementID = [dbo].[GetBMCStatementProcessID](@pStatementProcessId);




--- 1. Insert data  

INSERT INTO [dbo].[EtlHourly] (
[MtStatementProcess_ID]
, [EtlHourly_Year]
, [EtlHourly_Month]
, [EtlHourly_Day]
, [EtlHourly_Hour]
, [EtlHourly_TranmissionLoss]
, [EtlHourly_Demand]
, [EtlHourly_MarginalPrice])
	SELECT
		@pStatementProcessId
	   ,[EtlHourly_Year]
	   ,[EtlHourly_Month]
	   ,[EtlHourly_Day]
	   ,[EtlHourly_Hour]
	   ,[EtlHourly_TranmissionLoss]
	   ,[EtlHourly_Demand]
, [EtlHourly_MarginalPrice]
	FROM [EtlHourly]
	WHERE MtStatementProcess_ID = @vPreliminaryStatementID



INSERT INTO [dbo].[EtlMpData]
           ([MtStatementProcess_ID]
           ,[MTPartyRegisteration_Id]
           ,[EtlMpData_ActualEnergy]
           ,[EtlMpData_ExcessLossesCompensation]
           ,[EtlMpData_ContractedEnergy]
           ,[EtlMpData_AdditionalCompensation]
           ,[EtlMpData_TotalExcessLossesCompensation])
SELECT @pStatementProcessId
           ,[MTPartyRegisteration_Id]
           ,[EtlMpData_ActualEnergy]
           ,[EtlMpData_ExcessLossesCompensation]
           ,[EtlMpData_ContractedEnergy]
           ,[EtlMpData_AdditionalCompensation]
           ,[EtlMpData_TotalExcessLossesCompensation]
		   FROM [dbo].[EtlMpData]
	WHERE MtStatementProcess_ID = @vPreliminaryStatementID


INSERT INTO [dbo].[EtlMpMonthlyData]
           ([MtStatementProcess_ID]
           ,[MTPartyRegisteration_Id]
           ,[EtlMpMonthlyData_Month]
           ,[EtlMpMonthlyData_ActualEnergy])
SELECT @pStatementProcessId
           ,[MTPartyRegisteration_Id]
           ,[EtlMpMonthlyData_Month]
           ,[EtlMpMonthlyData_ActualEnergy]
		   FROM EtlMpMonthlyData where MtStatementProcess_ID=@vPreliminaryStatementID



INSERT INTO [dbo].[EtlTspData]
           ([MtStatementProcess_ID]
           ,[MTPartyRegisteration_Id]
           ,[EtlTspData_TransmissionLoss]
           ,[EtlTspData_TotalEnergyInjected]
           ,[EtlTspData_TotalEnergyWithdrawal]
           ,[EtlTspData_AnnualLosses]
           ,[EtlTspData_AllowedCap]
           ,[EtlTspData_AllowableLosses]
           ,[EtlTspData_ExcessLosses]
           ,[EtlTspData_WeightedAverageMarginalPrice]
           ,[EtlTspData_TotalPayableExcessLosses])
     SELECT 
	 @pStatementProcessId
           ,[MTPartyRegisteration_Id]
           ,[EtlTspData_TransmissionLoss]
           ,[EtlTspData_TotalEnergyInjected]
           ,[EtlTspData_TotalEnergyWithdrawal]
           ,[EtlTspData_AnnualLosses]
           ,[EtlTspData_AllowedCap]
           ,[EtlTspData_AllowableLosses]
           ,[EtlTspData_ExcessLosses]
           ,[EtlTspData_WeightedAverageMarginalPrice]
           ,[EtlTspData_TotalPayableExcessLosses]
		   FROM EtlTspData where MtStatementProcess_ID=@vPreliminaryStatementID


INSERT INTO [dbo].[EtlTspHourly]
           ([MtStatementProcess_ID]
           ,[EtlTspHourly_Year]
           ,[EtlTspHourly_Month]
           ,[EtlTspHourly_Day]
           ,[EtlTspHourly_Hour]
           ,[MTPartyRegisteration_Id]
           ,[EtlTspHourly_AdjustedEnergyImport]
           ,[EtlTspHourly_AdjustedEnergyExport]
           ,[EtlTspHourly_TransmissionLoss])
SELECT @pStatementProcessId
           ,[EtlTspHourly_Year]
           ,[EtlTspHourly_Month]
           ,[EtlTspHourly_Day]
           ,[EtlTspHourly_Hour]
           ,[MTPartyRegisteration_Id]
           ,[EtlTspHourly_AdjustedEnergyImport]
           ,[EtlTspHourly_AdjustedEnergyExport]
           ,[EtlTspHourly_TransmissionLoss]
		   FROM EtlTspHourly where MtStatementProcess_ID=@vPreliminaryStatementID


--------- Update logs -----------------  
INSERT INTO MtStatementProcessSteps (MtStatementProcessSteps_Status, MtStatementProcessSteps_Description, MtStatementProcess_ID, RuStepDef_ID, MtStatementProcessSteps_CreatedBy, MtStatementProcessSteps_CreatedOn)
	SELECT
		MtStatementProcessSteps_Status
	   ,MtStatementProcessSteps_Description
	   ,@pStatementProcessId
	   ,(SELECT
				rsd.RuStepDef_ID
			FROM RuStepDef rsd
			WHERE rsd.RuStepDef_BMEStepNo = (SELECT
					rsd.RuStepDef_BMEStepNo
				FROM RuStepDef rsd
				WHERE rsd.RuStepDef_ID = msps.RuStepDef_ID)
			AND rsd.SrProcessDef_ID = 18)
	   ,@pUserId
	   ,GETUTCDATE()
	FROM MtStatementProcessSteps msps
	WHERE MtStatementProcess_ID = @vPreliminaryStatementID

INSERT INTO [dbo].[MtSattlementProcessLogs] ([MtStatementProcess_ID]
, [MtSattlementProcessLog_Message]
, [MtSattlementProcessLog_CreatedBy]
, [MtSattlementProcessLog_CreatedOn])
	VALUES (@pStatementProcessId, 'Generate ETL - FYSS same as ETL - PYSS completed', 100, GETUTCDATE())

UPDATE MtStatementProcess
SET MtStatementProcess_Status = 'Executed'
   ,MtStatementProcess_ApprovalStatus = 'Draft'
   ,MtStatementProcess_ExecutionStartDate = DATEADD(HOUR, 5, GETUTCDATE())
   ,MtStatementProcess_ExecutionFinishDate = DATEADD(HOUR, 5, GETUTCDATE())
WHERE MtStatementProcess_ID = @pStatementProcessId;

END TRY
BEGIN CATCH

DECLARE @vErrorMessage VARCHAR(MAX) = '';
SELECT
	@vErrorMessage = ERROR_MESSAGE();
RAISERROR (@vErrorMessage, 16, -1);
END CATCH

END
