/****** Object:  Procedure [dbo].[RemoveEmployee]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE dbo.RemoveEmployee        
          @Employee_Id DECIMAL(18,0)   
       
AS                   
BEGIN    
SET NOCOUNT ON;    
BEGIN TRY    
update Employee set IsDeleted=1
where Employee_Id = @Employee_Id   
    select 1 as response;
END TRY    
BEGIN CATCH    
SELECT    
 ERROR_NUMBER() AS ErrorNumber    
   ,ERROR_STATE() AS ErrorState    
   ,ERROR_SEVERITY() AS ErrorSeverity    
   ,ERROR_PROCEDURE() AS ErrorProcedure    
   ,ERROR_LINE() AS ErrorLine    
   ,ERROR_MESSAGE() AS ErrorMessage;    
END CATCH;    
    
  
END
