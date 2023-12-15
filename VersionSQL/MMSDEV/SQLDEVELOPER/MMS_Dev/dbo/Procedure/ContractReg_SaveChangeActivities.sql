/****** Object:  Procedure [dbo].[ContractReg_SaveChangeActivities]    Committed by VersionSQL https://www.versionsql.com ******/

--=============================================            
-- Author:  Rabia Shamim| Alina       
-- CREATE date: Nov 22, 2022           
-- ALTER date:           
-- Reviewer:          
-- Description:           
          
-- =============================================           
CREATE PROCEDURE dbo.ContractReg_SaveChangeActivities        
    @pContractRegistrationActivity_Id DECIMAL(18, 0) = null,        
    @pContractRegisteration_Id DECIMAL(18, 0),        
    @pApplication_number nvarchar(256) = null,        
    @pApplication_date datetime = null,        
    @pApplication_ApprovedDate datetime = null,        
    @pRemarks nvarchar(max) = null,        
    @pContractStatus char(4) = null,        
    @pContractApprovalStatus char(4) = null,        
    @pRef_Id DECIMAL(18, 0) = null,        
    @pNotes nvarchar(256) = null,        
    @pUserId DECIMAL(18, 0)        
As  
BEGIN TRY  
if not exists        
(        
    SELECT top 1        
        1        
    FROM MtContractRegistrationActivities        
    WHERE MtContractRegistration_Id = @pContractRegisteration_Id        
          and ISNULL(MtContractRegistrationActivities_FinalDecision, 0) = 0        
          and ISNULL(MtContractRegistrationActivities_Deleted, 0) = 0        
          and MtContractRegistrationActivities_Action = @pContractApprovalStatus      
)       
and @pContractApprovalStatus in ('CADR','CAMD','CASD','CAWD','CATD','CADD')      
BEGIN        
    declare @vmax_activity_id int        
    SELECT @vmax_activity_id = max(MtContractRegistrationActivity_Id)        
    FROM MtContractRegistrationActivities        
        
    
    insert into MtContractRegistrationActivities        
    (        
        MtContractRegistrationActivity_Id,        
        MtContractRegistration_Id,        
        MtContractRegistrationActivities_Action,        
        MtContractRegistrationActivities_ApplicationNo,        
        MtContractRegistrationActivities_ApplicationDate,        
        MtContractRegistrationActivities_ActivityDateTime,        
        MtContractRegistrationActivities_Remarks,        
        MtContractRegistrationActivities_CreatedBy,        
        MtContractRegistrationActivities_CreatedOn,        
        MtContractRegistrationActivities_ModifiedBy,        
        MtContractRegistrationActivities_ModifiedOn,        
        MtContractRegistrationActivities_Deleted,        
        MtContractRegistrationActivities_ref_Id,        
        MtContractRegistrationActivities_Notes ,    
  MtContractRegistrationActivities_approval_date    
    )        
    SELECT ISNULL(@vmax_activity_id, 0) + 1,        
           @pContractRegisteration_Id,        
           @pContractApprovalStatus,        
           @pApplication_number,        
           NULLIF(@pApplication_date, '1900-01-01 00:00:00.000'),        
           GETDATE(),        
           @pRemarks,        
           @pUserId,        
           GETDATE(),        
           null,        
           null,        
           0,        
           @pRef_Id,        
           @pNotes,    
     NULLIF(@pApplication_ApprovedDate, '1900-01-01 00:00:00.000')    
        
    UPDATE [dbo].[MtContractRegistration]        
    SET [MtContractRegistration_ApprovalStatus] = @pContractApprovalStatus,        
        [MtContractRegistration_ModifiedBy] = @pUserId,        
        [MtContractRegistration_ModifiedOn] = GETUTCDATE()        
    WHERE MtContractRegistration_Id = @pContractRegisteration_Id        
          and ISNULL(MtContractRegistration_IsDeleted, 0) = 0        
        
END        
ELSE        
BEGIN        
        
    UPDATE MtContractRegistrationActivities        
    SET              
        MtContractRegistrationActivities_ApplicationNo = @pApplication_number,        
        MtContractRegistrationActivities_ApplicationDate = @pApplication_date,        
        MtContractRegistrationActivities_ActivityDateTime = GETDATE(),        
        MtContractRegistrationActivities_Remarks = @pRemarks,        
        MtContractRegistrationActivities_ModifiedBy = @pUserId,        
        MtContractRegistrationActivities_ModifiedOn = GETDATE(),        
        MtContractRegistrationActivities_ref_Id = @pRef_Id,        
        MtContractRegistrationActivities_Notes = @pNotes ,    
  MtContractRegistrationActivities_approval_date=@pApplication_ApprovedDate    
    WHERE MtContractRegistrationActivity_Id = @pContractRegistrationActivity_Id     
  
 DECLARE @name VARCHAR(20);  
 SELECT @name=LuStatus_Name FROM MtContractRegistration mcr  
inner join LuStatus on LuStatus.LuStatus_Code=mcr.MtContractRegistration_Status where mcr.MtContractRegistration_Id=@pContractRegisteration_Id        
    DECLARE @logMessage1 varchar(max)    
    SET      @logMessage1='Contract Updated. Contract ID:'+CAST(@pContractRegisteration_Id as varchar(20))+ ', Contract Updated, Contract Status:' + @name      
    
 EXEC [dbo].[SystemLogs] @user=@pUserId,      
        @moduleName='Contract Registration',      
         @CrudOperationName='Update',      
         @logMessage=@logMessage1      
            
             
END 

END TRY  
BEGIN CATCH  

DECLARE @vErrorMessage VARCHAR(MAX) = '';  
  SELECT  
   @vErrorMessage = ERROR_MESSAGE();  
    RAISERROR (@vErrorMessage, 16, -1);  
  RETURN;

END CATCH
