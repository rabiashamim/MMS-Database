/****** Object:  Procedure [dbo].[WF_InsertUpdateModulesProcessDetails]    Committed by VersionSQL https://www.versionsql.com ******/

    
    
-- dbo.WF_InsertUpdateModulesProcessDetails @pRuModuleProcessDetails_Id=0,@pRuModuleProcess_Id=1,@pRuModulesProcessColumnName=N'odnxoqffwnd',@pRuModulesProcessLabel=N'odddiqnwd',@pUserId=1    
    
CREATE PROCEDURE dbo.WF_InsertUpdateModulesProcessDetails         

    @pRuModuleProcessDetails_Id int  =0          
    ,@pRuModuleProcess_Id int  =0          
    ,@pRuModulesProcessColumnName varchar(128) =null    
    ,@pRuModulesProcessLabel    nvarchar(256)  =null  
	,@pRuModulesProcessDetailsSubject bit         
	,@pRuModulesProcessDetailsWhere bit 
	,@pRuModulesProcess_ShowOnScreen bit        
    ,@pUserId DECIMAL(18,0)=0           
AS                       
BEGIN        
SET NOCOUNT ON;        
  if(@pRuModulesProcessColumnName is null)        
  BEGIN        
    RAISERROR('Column Name should not be empty', 16, -1)        
            
    RETURN;        
            
  END        
  if(@pRuModulesProcessLabel is null)        
  BEGIN        
    RAISERROR('Label should not be empty', 16, -1)        
            
    RETURN;                
  END        
    
    if exists(select 1 from RuModulesProcessDetails where RuModulesProcessDetails_ColumnName =@pRuModulesProcessColumnName and ISNULL(RuModulesProcessDetails_IsDeleted,0)=0 and (@pRuModuleProcessDetails_Id=0 or @pRuModuleProcessDetails_Id <> @pRuModuleProcessDetails_Id) and RuModulesProcess_Id=@pRuModuleProcess_Id )    
  BEGIN    
    RAISERROR('Same column name is already used by this modules process.', 16, -1)                
    RETURN;                
  END    
    
    
    
    if exists(select 1 from RuModulesProcessDetails where RuModulesProcessDetails_Label =@pRuModulesProcessLabel and ISNULL(RuModulesProcessDetails_IsDeleted,0)=0 and (@pRuModuleProcessDetails_Id=0 or @pRuModuleProcessDetails_Id <> @pRuModuleProcessDetails_Id) and RuModulesProcess_Id=@pRuModuleProcess_Id )    
  BEGIN    
    RAISERROR('Same column label is already used by this modules process.', 16, -1)                
    RETURN;                
  END    
    
IF NOT EXISTS (SELECT        
   1        
  FROM RuModulesProcessDetails      
  WHERE RuModulesProcessDetails_Id = @pRuModuleProcessDetails_Id)        
BEGIN        
/***************** Insertion case *************/        
DECLARE @vMaxRuModulesProcessDetail_Id as int;    
select @vMaxRuModulesProcessDetail_Id=isnull(max(RuModulesProcessDetails_Id),0)+1 from RuModulesProcessDetails    
    
    
INSERT INTO [dbo].[RuModulesProcessDetails]    
           ([RuModulesProcessDetails_Id]    
           ,[RuModulesProcess_Id]    
           ,[RuModulesProcessDetails_ColumnName]    
           ,[RuModulesProcessDetails_Label]    
           ,[RuModulesProcessDetails_CreatedBy]    
           ,[RuModulesProcessDetails_CreatedOn]    
           ,[RuModulesProcessDetails_IsDeleted]  
		   ,[RuModulesProcessDetails_IsSubject]  
		   ,[RuModulesProcessDetails_IsWhere]
		   ,[RuModulesProcess_ShowOnScreen])    
     VALUES    
           (@vMaxRuModulesProcessDetail_Id    
           ,@pRuModuleProcess_Id    
           ,@pRuModulesProcessColumnName    
           ,@pRuModulesProcessLabel    
           ,@pUserId    
           ,GETDATE()    
           ,0  
     ,@pRuModulesProcessDetailsSubject  
     ,@pRuModulesProcessDetailsWhere
	 ,@pRuModulesProcess_ShowOnScreen)    
END    
ELSE        
BEGIN        
/***************** Updation case *************/        
    
UPDATE [dbo].[RuModulesProcessDetails]    
   SET [RuModulesProcess_Id] = @pRuModuleProcess_Id    
      ,[RuModulesProcessDetails_ColumnName] = @pRuModulesProcessColumnName    
      ,[RuModulesProcessDetails_Label] = @pRuModulesProcessLabel    
      ,[RuModulesProcessDetails_ModifiedBy] = @pUserId    
      ,[RuModulesProcessDetails_ModifiedOn] = GETDATE()   
      ,[RuModulesProcessDetails_IsSubject] = @pRuModulesProcessDetailsSubject  
      ,[RuModulesProcessDetails_IsWhere] = @pRuModulesProcessDetailsWhere
	  ,[RuModulesProcess_ShowOnScreen] = @pRuModulesProcess_ShowOnScreen
	  WHERE RuModulesProcessDetails_Id=@pRuModuleProcessDetails_Id    
    
    
END        
END    
/**************************************************/    
    
