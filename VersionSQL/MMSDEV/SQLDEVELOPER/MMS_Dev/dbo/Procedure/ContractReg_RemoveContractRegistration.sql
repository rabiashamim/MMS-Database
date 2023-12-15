/****** Object:  Procedure [dbo].[ContractReg_RemoveContractRegistration]    Committed by VersionSQL https://www.versionsql.com ******/

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  
-- =============================================    
-- Author:  Ali Imran  
-- CREATE OR ALTER date: Nov 22, 2022   
-- ALTER date:   
-- Reviewer:  
-- Description:   
-- =============================================   
  
CREATE   PROCEDURE dbo.ContractReg_RemoveContractRegistration  
 @pContractRegistration_Id DECIMAL(18, 0),  
 @pUserId INT  
AS  
BEGIN  
UPDATE [dbo].[MtContractRegistration]  
SET MtContractRegistration_IsDeleted = 1  
   ,MtContractRegistration_ModifiedBy = @pUserId  
   ,MtContractRegistration_ModifiedOn = GETUTCDATE()  
WHERE MtContractRegistration_Id = @pContractRegistration_Id  
  
  
UPDATE MtContractTradingCDPs  
SET MtContractTradingCDPs_IsDeleted = 1  
   ,MtContractTradingCDPs_ModifiedBy = @pUserId  
   ,MtContractTradingCDPs_ModifiedOn = GETDATE()  
WHERE MtContractRegistration_Id = @pContractRegistration_Id  
  
  
UPDATE MtContractProfileCapacity  
SET MtContractProfileCapacity_IsDeleted = 1  
   ,MtContractProfileCapacity_ModifiedBy = @pUserId  
   ,MtContractProfileCapacity_ModifiedOn = GETDATE()  
WHERE MtContractRegistration_Id = @pContractRegistration_Id  
  
UPDATE MtContractProfileEnergy  
SET MtContractProfileEnergy_IsDeleted = 1  
   ,MtContractProfileEnergy_ModifiedBy = @pUserId  
   ,MtContractProfileEnergy_ModifiedOn = GETDATE()  
WHERE MtContractRegistration_Id = @pContractRegistration_Id  
  
UPDATE MtContractPhysicalAssets  
SET MtContractPhysicalAssets_IsDeleted = 1  
   ,MtContractPhysicalAssets_ModifiedBy = @pUserId  
   ,MtContractPhysicalAssets_ModifiedOn = GETDATE()  
WHERE MtContractRegistration_Id = @pContractRegistration_Id  

-------------------
 DECLARE @name VARCHAR(20);
 SELECT @name=LuStatus_Name FROM MtContractRegistration mcr
inner join LuStatus on LuStatus.LuStatus_Code=mcr.MtContractRegistration_Status where mcr.MtContractRegistration_Id=@pContractRegistration_Id
 
 DECLARE @logMessage1 varchar(max)      
    SET      @logMessage1='Contract Removed. Contract ID: '+CONVERT(VARCHAR(MAX),@pContractRegistration_Id)
  EXEC [dbo].[SystemLogs] @user=@pUserId,        
         @moduleName='Contract Registration',        
         @CrudOperationName='Delete',        
         @logMessage=@logMessage1 


END
