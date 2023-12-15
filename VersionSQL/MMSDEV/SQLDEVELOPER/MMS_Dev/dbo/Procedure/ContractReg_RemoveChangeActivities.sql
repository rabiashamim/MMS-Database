/****** Object:  Procedure [dbo].[ContractReg_RemoveChangeActivities]    Committed by VersionSQL https://www.versionsql.com ******/

--=============================================      
-- Author:  Rabia Shamim  
-- CREATE date: Nov 22, 2022     
-- ALTER date:     
-- Reviewer:    
-- Description:     
    
-- =============================================     
  
CREATE procedure dbo.ContractReg_RemoveChangeActivities      
    @pContractRegistrationActivity_Id DECIMAL(18, 0),      
    @pContractRegisteration_Id DECIMAL(18, 0),      
    @pContractApprovalStatus char(4),    
 @pContractStatus char(4),      
    @pUserId DECIMAL(18, 0)      
as      
      
update MtContractRegistrationActivities      
set MtContractRegistrationActivities_Deleted=1,  
    MtContractRegistrationActivities_FinalDecision=1 ,
	MtContractRegistrationActivities_ActivityDateTime=getdate()
where MtContractRegistrationActivity_Id = @pContractRegistrationActivity_Id      

EXEC [dbo].[SystemLogs] @user=@pUserId,
								 @moduleName='Contract Registration',
								 @CrudOperationName='Update',
								 @logMessage='Contract Updated. Contract ID:@pContractRegisteration_Id , Action Performed: Modification Canceled, Contract Status: Approved',
								 @getip=0,
								 @RegistrationID=0,
								 @CategoryID=0,
								 @featurePK=0,
								 @username=0

/***********		Check recent status of contract */
     Declare @vRecentStatus char(4)

select top 1 @vRecentStatus=MtContractRegistrationActivities_Action from MtContractRegistrationActivities where MtContractRegistration_Id=@pContractRegisteration_Id and 
--ISNULL--(MtContractRegistrationActivities_Deleted,0)=0 and
MtContractRegistrationActivities_Action<>'CASD'
order by MtContractRegistrationActivity_Id desc


UPDATE [dbo].[MtContractRegistration]      
SET [MtContractRegistration_ApprovalStatus] = case 
when @pContractApprovalStatus = ('CASD') and @vRecentStatus='CAMD' then 
'CAMA'
when @pContractApprovalStatus = ('CASD') and @vRecentStatus<>'CAMD' then 
'CAAP'
when @pContractApprovalStatus in ('CAMD','CADD')    
             then 'CAAP'    
When @pContractApprovalStatus in ('CAWD','CATD')    
             then 'CASA'    
             end    
WHERE MtContractRegistration_Id = @pContractRegisteration_Id      
      and isnull(MtContractRegistration_IsDeleted, 0) = 0 

	  EXEC [dbo].[SystemLogs] @user=@pUserId,
								 @moduleName='Contract Registration',
								 @CrudOperationName='Update',
								 @logMessage='Contract Updated. Contract ID:@pContractRegisteration_Id. Action Performed: Modification Canceled, Contract Status: Approved',
								 @getip=0,
								 @RegistrationID=0,
								 @CategoryID=0,
								 @featurePK=0,
								 @username=0
