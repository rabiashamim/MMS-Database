/****** Object:  Procedure [dbo].[UpdateEmployees]    Committed by VersionSQL https://www.versionsql.com ******/

--[dbo].[InsertUpdateReferenceTypes]    @pSrReferenceType_Id=0, @pSrReferenceType_Name='MO Fee', @pSrReferenceType_Unit='Rs/kWh', @pUserId=100    
CREATE PROCEDURE dbo.UpdateEmployees        
            @Employee_Id decimal(18,0)       
           ,@Employee_Name varchar(50)        
           ,@Employee_Rank    nvarchar(30)        
             
AS                   
BEGIN TRY   
SET NOCOUNT ON;    

BEGIN    
/***************** Updation case *************/    
UPDATE Employee    
SET Employee_Name = @Employee_Name    
   ,Employee_Rank = @Employee_Rank    
   ,Employee_CreatedAt = GETDATE()        
WHERE Employee_Id =  @Employee_Id  
  
select 1 as response;  
  
END    
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
