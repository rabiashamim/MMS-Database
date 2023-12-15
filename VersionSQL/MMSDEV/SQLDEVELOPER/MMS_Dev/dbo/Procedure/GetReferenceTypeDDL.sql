/****** Object:  Procedure [dbo].[GetReferenceTypeDDL]    Committed by VersionSQL https://www.versionsql.com ******/

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  
    
      
        
-- =============================================            
-- Author:  Aymen Khalid      
-- CREATE date: DEC 14, 2022           
-- ALTER date:           
-- Reviewer:          
-- Description:           
-- =============================================           
CREATE  PROCEDURE dbo.GetReferenceTypeDDL         
      
AS                     
BEGIN      
SET NOCOUNT ON;      
BEGIN TRY      
SELECT DISTINCT 
	SrReferenceType_Id, 
	SrReferenceType_Name 
FROM 
	SrReferenceType 
WHERE 
	SrReferenceType_IsDeleted <>1   
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
