/****** Object:  Procedure [dbo].[PreCheckForModifiedContracts]    Committed by VersionSQL https://www.versionsql.com ******/

--*************************** Create new data management process for Bilateral Contract Energy and Capacity  
 --dbo.PreCheckForModifiedContracts   8,24

CREATE    PROCEDURE dbo.PreCheckForModifiedContracts  
  
@pLuSoFileTemplateId int,  
@pSettlementPeriod int,
@pUserId int
  
AS BEGIN
  
Declare @LuSoFileTemplateConfiguration as int;
SELECT
	@LuSoFileTemplateConfiguration = LuDataConfiguration_Id
FROM LuSOFileTemplate
WHERE LuSOFileTemplate_Id = @pLuSoFileTemplateId;
/*********************	Check for Bilateral Contract ENERGY	*****************/

DECLARE @vModifyDraftedContracts as VARCHAR(MAX)=null;
Declare @vErrorMessage as VARCHAR(MAX);

IF (@pLuSoFileTemplateId in (8)
	AND @LuSoFileTemplateConfiguration = 2)
BEGIN

DECLARE @MONTH_EFFECTIVE_FROM AS DATETIME;
DECLARE @MONTH_EFFECTIVE_TO AS DATETIME ;

SELECT
	@MONTH_EFFECTIVE_FROM = LuAccountingMonth_FromDate
   ,@MONTH_EFFECTIVE_TO = LuAccountingMonth_ToDate
FROM LuAccountingMonth
WHERE LuAccountingMonth_Id = @pSettlementPeriod


SELECT
	@vModifyDraftedContracts= STRING_AGG( ISNULL(cast(mcr.MtContractRegistration_Id as VARCHAR(10)), ' '), ', ') --INTO #contracts
FROM MtContractProfileEnergy mcpc
INNER JOIN MtContractRegistration mcr
	ON mcpc.MtContractRegistration_Id = mcr.MtContractRegistration_Id
WHERE 
(mcpc.MtContractProfileEnergy_DateFrom between @MONTH_EFFECTIVE_FROM and @MONTH_EFFECTIVE_TO OR
mcpc.MtContractProfileEnergy_DateTo between @MONTH_EFFECTIVE_FROM and @MONTH_EFFECTIVE_TO OR
(mcpc.MtContractProfileEnergy_DateFrom <= @MONTH_EFFECTIVE_FROM and mcpc.MtContractProfileEnergy_DateTo>= @MONTH_EFFECTIVE_TO))

AND ISNULL(mcpc.MtContractProfileEnergy_IsDeleted, 0) = 0
AND ISNULL(mcr.MtContractRegistration_IsDeleted, 0) = 0
AND mcr.MtContractRegistration_ApprovalStatus IN ('CAMD')


IF (@vModifyDraftedContracts is not null)
BEGIN
SET @vErrorMessage='Contracts ' + @vModifyDraftedContracts+' are currently in Modify-Draft state and profile of these contracts will not be generated. Do you still want to continue profile generation without these contracts?'
RAISERROR (@vErrorMessage, 16, -1)
RETURN;
END
END
---------------------------------------------------------------------
/*********************	Check for Bilateral Contract Energy	*****************/
/*********************	Check for Bilateral Contract Capacity	*****************/

ELSE
IF (@pLuSoFileTemplateId = 9
	AND @LuSoFileTemplateConfiguration = 2)
BEGIN
DECLARE @pYearCapacity AS INT;


DECLARE @pEffectiveFromDate DATE
DECLARE @pEffectiveToDate DATE
SELECT
	@pYearCapacity = LuAccountingMonth_Year,
	@pEffectiveFromDate = LuAccountingMonth_FromDate,
	@pEffectiveToDate = LuAccountingMonth_ToDate
FROM LuAccountingMonth
WHERE LuAccountingMonth_Id = @pSettlementPeriod;

SELECT
	@vModifyDraftedContracts= STRING_AGG( ISNULL(cast(mcr.MtContractRegistration_Id as VARCHAR(10)), ' '), ', ') --INTO #contracts
FROM MtContractProfileCapacity mcpc
INNER JOIN MtContractRegistration mcr
	ON mcpc.MtContractRegistration_Id = mcr.MtContractRegistration_Id
WHERE 
(mcpc.MtContractProfileCapacity_DateFrom between @pEffectiveFromDate and @pEffectiveToDate OR
mcpc.MtContractProfileCapacity_DateTo between @pEffectiveFromDate and @pEffectiveToDate OR
(mcpc.MtContractProfileCapacity_DateFrom <= @pEffectiveFromDate and mcpc.MtContractProfileCapacity_DateTo>= @pEffectiveToDate))

AND ISNULL(mcpc.MtContractProfileCapacity_IsDeleted, 0) = 0
AND ISNULL(mcr.MtContractRegistration_IsDeleted, 0) = 0
AND mcr.MtContractRegistration_ApprovalStatus IN ('CAMD')


IF (@vModifyDraftedContracts is not null)
BEGIN
SET @vErrorMessage='Contracts ' + @vModifyDraftedContracts+' are currently in Modify-Draft state and profile of these contracts will not be generated. Do you still want to continue profile generation without these contracts?'
RAISERROR (@vErrorMessage, 16, -1)
RETURN;
END

END
---------------------------------------------------------------------
/*********************	Check for Bilateral Contract Capacity	*****************/

END
