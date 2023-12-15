/****** Object:  Procedure [dbo].[GetReferenceTypeUnit]    Committed by VersionSQL https://www.versionsql.com ******/

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  
    
      
        
          
-- =============================================              
-- Author:  Aymen Khalid        
-- CREATE date: DEC 22, 2022             
-- ALTER date:             
-- Reviewer:            
-- Description:  Get teh unit of relevent Reference Type           
-- =============================================             
CREATE  PROCEDURE dbo.GetReferenceTypeUnit           
 @piSrReferenceType_Id int       
AS                       
BEGIN        
SET NOCOUNT ON;        
BEGIN TRY        
select 
	SrReferenceType_Unit 
from 
	SrReferenceType 
WHERE
	SrReferenceType_Id = @piSrReferenceType_Id
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
