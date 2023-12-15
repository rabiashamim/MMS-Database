/****** Object:  Procedure [dbo].[ContractReg_GetActivities]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================        
-- Author:  Rabia Shamim    
-- CREATE date: Nov 21, 2022       
-- ALTER date:       
-- Reviewer:      
-- Description:       
-- =============================================       
    
    
CREATE procedure dbo.ContractReg_GetActivities        
    @pContractRegisteration_Id DECIMAL(18, 0),        
    @pUserId DECIMAL(18, 0)        
As        
DECLARE @vMtContractRegistrationActivity_Id DECIMAL(18, 0)        
SELECT @vMtContractRegistrationActivity_Id = MAX(MtContractRegistrationActivity_Id)        
FROM MtContractRegistrationActivities        
WHERE MtContractRegistration_Id = @pContractRegisteration_Id       
and ISNULL(MtContractRegistrationActivities_Deleted, 0) = 0        
        
SELECT MtContractRegistrationActivity_Id as ActivityIdCMD,        
       MtContractRegistration_Id,        
       MtContractRegistrationActivities_Action,        
       MtContractRegistrationActivities_ApplicationNo as ApplicationNumberCMD,        
       MtContractRegistrationActivities_ApplicationDate as ApplicationDateCMD,        
       MtContractRegistrationActivities_ActivityDateTime,        
       MtContractRegistrationActivities_Remarks as RemarksCMD,        
       MtContractRegistrationActivities_CreatedBy,        
       MtContractRegistrationActivities_CreatedOn,        
       MtContractRegistrationActivities_ModifiedBy,        
       MtContractRegistrationActivities_ModifiedOn,        
       MtContractRegistrationActivities_Deleted,        
       MtContractRegistrationActivities_ref_Id,        
       MtContractRegistrationActivities_Notes ,
	   MtContractRegistrationActivities_approval_date as ApprovedDateCMD
FROM MtContractRegistrationActivities        
WHERE MtContractRegistrationActivity_Id = @vMtContractRegistrationActivity_Id 
