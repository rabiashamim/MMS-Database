/****** Object:  Procedure [dbo].[RemoveReferenceValue]    Committed by VersionSQL https://www.versionsql.com ******/

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  
    
      
-- =============================================          
-- Author:  Sadaf Malik    
-- CREATE date: DEC 13, 2022         
-- ALTER date:         
-- Reviewer:        
-- Description:         
-- =============================================         
CREATE  PROCEDURE dbo.RemoveReferenceValue        
          @pMtReferenceValue_Id int,    
    @pUserId      DECIMAL(18,0) =   null    
AS                   
BEGIN    
SET NOCOUNT ON;    
BEGIN TRY    
update RuReferenceValue set RuReferenceValue_IsDeleted=1, RuReferenceValue_ModifiedOn=GetDate(),RuReferenceValue_ModifiedBy=@pUserId where RuReferenceValue_Id=@pMtReferenceValue_Id    
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
