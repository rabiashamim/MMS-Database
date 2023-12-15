/****** Object:  Procedure [dbo].[InsertUpdateAlinaTest]    Committed by VersionSQL https://www.versionsql.com ******/

--dbo.InsertUpdateAlinaTest   @pSrReferenceType_Id=0, @pSrReferenceType_Name='MO Fee', @pSrReferenceType_Unit='Rs/kWh', @pUserId=100    
CREATE   PROCEDURE dbo.InsertUpdateAlinaTest     
		   @Test_Id int,
           @Test_Name varchar(100)  ,
		   @Test_Password varchar (50)
                
AS                   
BEGIN    
SET NOCOUNT ON;    
BEGIN TRY    
  if(@Test_Name is null)    
  BEGIN    
    RAISERROR('Name should not be empty', 16, -1)    
        
    RETURN;    
        
  END    
  if(@Test_Password is null)    
  BEGIN    
    RAISERROR('Password should not be empty', 16, -1)    
        
    RETURN;    
        
  END    
    
IF NOT EXISTS (SELECT    
   1    
  FROM Alina_Test    
  WHERE Test_Id = @Test_Id)    
BEGIN    
/***************** Insertion case *************/    
INSERT INTO Alina_Test (Test_Name, Test_Password, Test_CreatedOn)    
 VALUES (@Test_Name, @Test_Password, FORMAT(  GETDATE(), 'dd-MMM-yyyy', 'en-US' ))    
  
select 1 as response;  
END    
    
ELSE    
BEGIN    
/***************** Updation case *************/    
UPDATE Alina_Test    
SET Test_Name = @Test_Name   
   ,Test_Password = @Test_Password    
   ,Test_CreatedOn = GETDATE()       
WHERE Test_Id = @Test_Id    
  
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
/**************************************************/
