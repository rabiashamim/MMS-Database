/****** Object:  Procedure [dbo].[GetReferenceTypes]    Committed by VersionSQL https://www.versionsql.com ******/

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  
    
      
-- =============================================          
-- Author:  Sadaf Malik    
-- CREATE date: DEC 13, 2022         
-- ALTER date:         
-- Reviewer:        
-- Description:         
-- =============================================         
CREATE  PROCEDURE dbo.GetReferenceTypes        
AS                   
BEGIN    
SET NOCOUNT ON;    
BEGIN TRY    
select SrReferenceType_Id, SrReferenceType_Name, SrReferenceType_Unit from SrReferenceType   
WHERE SrReferenceType_IsDeleted <>1  
ORDER by SrReferenceType_CreatedOn DESC
    
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
