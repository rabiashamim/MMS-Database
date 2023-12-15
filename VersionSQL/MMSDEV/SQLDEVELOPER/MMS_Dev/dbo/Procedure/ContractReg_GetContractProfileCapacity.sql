/****** Object:  Procedure [dbo].[ContractReg_GetContractProfileCapacity]    Committed by VersionSQL https://www.versionsql.com ******/

--   dbo.ContractReg_GetContractProfileCapacity 9  
CREATE   PROCEDURE dbo.ContractReg_GetContractProfileCapacity  
 @pContractRegisteration_Id DECIMAL(18, 0)  
AS  
BEGIN  
 SELECT  
  MtContractProfileCapacity_Id,   
  MtContractRegistration_Id,  
  MtContractProfileCapacity_DateFrom AS DateFrom,  
  MtContractProfileCapacity_DateTo AS DateTo,  
  MtContractProfileCapacity_Percentage AS Percentages,  
  MtContractProfileCapacity_ContractQuantity_MW AS ContractQuantity,  
  MtContractProfileCapacity_CapQuantity_MW AS CapQuantity, 
    CASE
    WHEN MtContractProfileCapacity_IsGuaranteed = 0 THEN 'Non-Guaranteed'
    WHEN MtContractProfileCapacity_IsGuaranteed = 1  THEN 'Guaranteed'
  END
  AS IsGuranted  
--  MtContractProfileCapacity_IsGuaranteed AS IsGuranted  
 FROM   
  [dbo].[MtContractProfileCapacity] mcpc  
 WHERE   
  mcpc.MtContractRegistration_Id = @pContractRegisteration_Id  
 AND   
  MtContractProfileCapacity_IsDeleted = 0  
  
END
