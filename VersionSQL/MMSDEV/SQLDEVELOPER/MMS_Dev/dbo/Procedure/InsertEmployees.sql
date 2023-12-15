/****** Object:  Procedure [dbo].[InsertEmployees]    Committed by VersionSQL https://www.versionsql.com ******/

--[dbo].[InsertUpdateReferenceTypes]    @pSrReferenceType_Id=0, @pSrReferenceType_Name='MO Fee', @pSrReferenceType_Unit='Rs/kWh', @pUserId=100    
CREATE PROCEDURE dbo.InsertEmployees        
            @Employee_Id decimal(18,0)       
           ,@Employee_Name varchar(50)        
           ,@Employee_Rank    nvarchar(30)        
             
AS                   
BEGIN    
SET NOCOUNT ON;    
BEGIN TRY    
  if(@Employee_Name is null)    
  BEGIN    
    RAISERROR('Employee Name should not be empty', 16, -1)    
        
    RETURN;    
        
  END    
  if(@Employee_Rank is null)    
  BEGIN    
    RAISERROR('Employee Rank should not be empty', 16, -1)    
        
    RETURN;    
        
  END    
    
IF NOT EXISTS (SELECT    
   1    
  FROM Employee    
  WHERE Employee_Id = @Employee_Id)    
BEGIN    
/***************** Insertion case *************/    
INSERT INTO Employee(Employee_Name,Employee_Rank , Employee_CreatedAt)    
 VALUES ( @Employee_Name,@Employee_Rank , GETDATE())    
  
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
END   
