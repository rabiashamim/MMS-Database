/****** Object:  Procedure [dbo].[ContractReg_InsertUpdatePhysicalAssets]    Committed by VersionSQL https://www.versionsql.com ******/

  
CREATE procedure dbo.ContractReg_InsertUpdatePhysicalAssets    
 @pId INT=0    
, @pContractId decimal(18,0)    
,@pGenerationUnitId decimal(18,0)   
,@pPercentInstallEnergyTransaction decimal(18,4) = NULL  
,@pPercentInstallCapacityTransaction decimal(18,4) = NULL  
,@pPercentAssignedASCBuyer decimal(18,4) = NULL  
,@pPercentAssignedASCSeller decimal(18,4)   = NULL  
,@user_id decimal(18,0)    
As    
BEGIN    
  
 declare @output VARCHAR(max);
 IF (@pId=0)  
BEGIN    
INSERT INTO [dbo].[MtContractPhysicalAssets]  
           ([MtContractRegistration_Id]  
           ,[MtGenerationUnit_Id]  
           ,[MtContractPhysicalAssetsـPercentInstallEnergyTransaction]  
           ,[MtContractPhysicalAssetsـPercentInstallCapacityTransaction]  
           ,[MtContractPhysicalAssetsـPercentAssignedASCBuyer]  
           ,[MtContractPhysicalAssetsـPercentAssignedASCSeller]  
           ,[MtContractPhysicalAssets_CreatedBy]  
           ,[MtContractPhysicalAssets_CreatedOn]  
     ,MtContractPhysicalAssets_IsDeleted)  
     VALUES    
           (  @pContractId  
     ,@pGenerationUnitId  
     ,@pPercentInstallEnergyTransaction  
     ,@pPercentInstallCapacityTransaction  
     ,@pPercentAssignedASCBuyer  
     ,@pPercentAssignedASCSeller  
     ,@user_id  
     ,DateAdd(Hour,5,GETUTCDATE())  
     ,0  
           )    
     select @@identity    
    	SET @output='Physical Assets Updated. Contract ID:' + convert(varchar(max),@pContractId)

		EXEC [dbo].[SystemLogs]  
		 @user=@user_id,
         @moduleName='Contract Registration',  
         @CrudOperationName='Update',  
         @logMessage=@output 
     RETURN @@identity 
	 
	
		
  
END  
ELSE  
BEGIN  
  
UPDATE [dbo].[MtContractPhysicalAssets]  
Set  
           [MtGenerationUnit_Id]=@pGenerationUnitId  
           ,[MtContractPhysicalAssetsـPercentInstallEnergyTransaction]=@pPercentInstallEnergyTransaction  
           ,[MtContractPhysicalAssetsـPercentInstallCapacityTransaction]=@pPercentInstallCapacityTransaction  
           ,[MtContractPhysicalAssetsـPercentAssignedASCBuyer]=@pPercentAssignedASCBuyer  
           ,[MtContractPhysicalAssetsـPercentAssignedASCSeller]=@pPercentAssignedASCSeller  
           ,[MtContractPhysicalAssets_ModifiedBy]=@user_id  
           ,[MtContractPhysicalAssets_ModifiedOn]=DateAdd(Hour,5,GETUTCDATE())  
     WHERE MtContractPhysicalAssets_Id=@pId  
--------------logs ------------

			SET @output='Physical Assets Updated. Contract ID:' + convert(varchar(max),@pContractId)

		EXEC [dbo].[SystemLogs]  
		 @user=@user_id,
         @moduleName='Contract Registration',  
         @CrudOperationName='Update',  
         @logMessage=@output 
END  
END    
    
