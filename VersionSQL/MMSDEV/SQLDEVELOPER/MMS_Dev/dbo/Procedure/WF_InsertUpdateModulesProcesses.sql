/****** Object:  Procedure [dbo].[WF_InsertUpdateModulesProcesses]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE    PROCEDURE dbo.WF_InsertUpdateModulesProcesses        


            @pRuModules_Id int  =0    
			,@pRuModulesProcess_ProcessTemplateId int=0
           ,@pRuModulesProcessName varchar(128) =null
           ,@pRuModulesProcessLinkedObject    nvarchar(256)  =null       
		   ,@pRuModulesProcess_Id int=0
           ,@pUserId      DECIMAL(18,0)=0       
AS                   
BEGIN    
SET NOCOUNT ON;    
  if(@pRuModulesProcessName is null)    
  BEGIN    
    RAISERROR('Process Name should not be empty', 16, -1)    
        
    RETURN;    
        
  END    
  if(@pRuModulesProcessLinkedObject is null)    
  BEGIN    
    RAISERROR('Linked object should not be empty', 16, -1)    
        
    RETURN;            
  END    

  if(@pRuModules_Id =0)    
  BEGIN    
    RAISERROR('Module Id should not be empty', 16, -1)    
        
    RETURN;            
  END    
    


  if exists(select 1 from RuModulesProcess where RuModulesProcess_Name=@pRuModulesProcessName and ISNULL(RuModulesProcess_IsDeleted,0)=0 and (@pRuModulesProcess_Id=0 or RuModulesProcess_Id <> @pRuModulesProcess_Id) )
  BEGIN
    RAISERROR('Module Process Name is already used by some other process.', 16, -1)            
    RETURN;            
  END

  
    if exists(select 1 from RuModulesProcess where RuModules_Id=@pRuModules_Id and ISNULL(RuModulesProcess_IsDeleted,0)=0 and
(	(@pRuModulesProcess_Id=0 AND RuModulesProcess_ProcessTemplateId=@pRuModulesProcess_ProcessTemplateId)
	OR
	(RuModulesProcess_Id<>@pRuModulesProcess_Id AND RuModulesProcess_ProcessTemplateId=@pRuModulesProcess_ProcessTemplateId)
	)
	)
  BEGIN
    RAISERROR('Module Process Template Id is already used by some other process.', 16, -1)            
    RETURN;            
  END


IF NOT EXISTS (SELECT    
   1    
  FROM RuModulesProcess    
  WHERE RuModulesProcess_Id = @pRuModulesProcess_Id)    
BEGIN    
/***************** Insertion case *************/    
DECLARE @vMaxRuModulesProcess_Id as int;
select @vMaxRuModulesProcess_Id=isnull(max(RuModulesProcess_Id),0)+1 from RuModulesProcess

INSERT INTO [dbo].[RuModulesProcess]
           ([RuModulesProcess_Id]
           ,[RuModulesProcess_Name]
           ,[RuModulesProcess_IsActive]
           ,[RuModulesProcess_CreatedBy]
           ,[RuModulesProcess_CreatedOn]
           ,[RuModulesProcess_IsDeleted]
           ,[RuModules_Id]
           ,[RuModulesProcess_LinkedObject]
		   ,RuModulesProcess_ProcessTemplateId)
     VALUES
           (@vMaxRuModulesProcess_Id
           ,@pRuModulesProcessName
           ,1
           ,@pUserId
           ,GETDATE()
           ,0
           ,@pRuModules_Id
           ,@pRuModulesProcessLinkedObject
		   ,@pRuModulesProcess_ProcessTemplateId)
		   
		   END    
    
ELSE    
BEGIN    
/***************** Updation case *************/    
  
UPDATE [dbo].[RuModulesProcess]
   SET 
      [RuModulesProcess_Name] = @pRuModulesProcessName
      ,[RuModulesProcess_IsActive] = 1
      ,[RuModulesProcess_ModifiedBy] = @pUserId
      ,[RuModulesProcess_ModifiedOn] = GETDATE()
      ,[RuModules_Id] = @pRuModules_Id
      ,[RuModulesProcess_LinkedObject] =@pRuModulesProcessLinkedObject
	  ,[RuModulesProcess_ProcessTemplateId]=@pRuModulesProcess_ProcessTemplateId
 WHERE RuModulesProcess_Id=@pRuModulesProcess_Id

END    
END
/**************************************************/
