/****** Object:  Procedure [dbo].[RemoveSOFiles]    Committed by VersionSQL https://www.versionsql.com ******/

    
/******************************************************************/    
-- =============================================                      
-- Author: Alina Javed                               
-- CREATE date:  16/1/2023                                       
-- ALTER date:                                         
-- Reviewer:                                        
-- Description: Insert Security Cover data into original table                                     
-- =============================================                                         
-- =============================================                 
    
   -- [dbo].[Insert_SecurityCoverBMC] 1,1,1
CREATE PROCEDURE dbo.RemoveSOFiles    
  @pMtSOFileMaster_Id DECIMAL(18, 0)    
, @pUserId INT    
   
    
AS    
BEGIN    
    
 BEGIN TRY    
  declare @version int=0;
 select @version=MtSOFileMaster_Version from MtSOFileMaster where MtSOFileMaster_Id=@pMtSOFileMaster_Id
  declare @period int=0;
  select @period =LuAccountingMonth_Id from MtSOFileMaster where MtSOFileMaster_Id=@pMtSOFileMaster_Id
  declare @pSOFileTemplate int=0;
  select @pSOFileTemplate=LuSOFileTemplate_Id from MtSOFileMaster where MtSOFileMaster_Id=@pMtSOFileMaster_Id
  declare @tempname NVARCHAR(MAX)=NULL;
SELECT @tempname=LuSOFileTemplate_Name FROM LuSOFileTemplate WHERE  LuSOFileTemplate_Id=@pSOFileTemplate

  select (select LuSOFileTemplate_Name from LuSOFileTemplate where LuSOFileTemplate_Id = MSF.LuSOFileTemplate_Id) 
                    from MtSOFileMaster MSF 
                    where MtSOFileMaster_Id = @pMtSOFileMaster_Id
    
    

		   declare @output VARCHAR(max);
			SET @output='Data for' +@tempname+ 'is removed.Settlement Period:' +convert(varchar(max),@period) +',Version:' + convert(varchar(max),@version) 

				EXEC [dbo].[SystemLogs] 
				@user=@pUserId,
				 @moduleName='Data Management',  
				 @CrudOperationName='Create',  
				 @logMessage=@output 

    
  
    
 END TRY    
 BEGIN CATCH    
  SELECT    
   ERROR_NUMBER() AS ErrorNumber    
     ,ERROR_STATE() AS ErrorState    
     ,ERROR_SEVERITY() AS ErrorSeverity    
     ,ERROR_PROCEDURE() AS ErrorProcedure    
     ,ERROR_LINE() AS ErrorLine    
     ,ERROR_MESSAGE() AS ErrorMessage;    
 END CATCH    
END 
