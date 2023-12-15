/****** Object:  Procedure [dbo].[ContractReg_GetContractProfileEnergy]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================  
-- Author:  Ali Imran
-- CREATE date: Nov 15, 2022 
-- ALTER date: 
-- Reviewer:
-- Description: 
-- ============================================= 
-- dbo.ContractReg_GetContractProfileEnergy 9
CREATE   PROCEDURE dbo.ContractReg_GetContractProfileEnergy 
	@pContractRegisteration_Id DECIMAL(18, 0)
AS
BEGIN

SELECT
	MtContractProfileEnergy_Id
	,MtContractRegistration_Id
	,MtContractProfileEnergy_DateFrom AS DateFrom
	,MtContractProfileEnergy_DateTo AS DateTo
	,MtContractProfileEnergy_Percentage AS Percentages
	,MtContractProfileEnergy_ContractQuantity_KWH AS ContractQuantity
	,MtContractProfileEnergy_CapQuantity_KWH AS CapQuantity
	,MtContractProfileEnergy_HourFrom AS  HourFrom
	,MtContractProfileEnergy_HourTo AS HourTo
FROM 
	[dbo].[MtContractProfileEnergy]
WHERE 
	MtContractRegistration_Id = @pContractRegisteration_Id
AND 
	MtContractProfileEnergy_IsDeleted = 0

END
