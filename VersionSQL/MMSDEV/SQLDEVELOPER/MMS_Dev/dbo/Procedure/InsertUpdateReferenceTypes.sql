/****** Object:  Procedure [dbo].[InsertUpdateReferenceTypes]    Committed by VersionSQL https://www.versionsql.com ******/

--dbo.InsertUpdateReferenceTypes    @pSrReferenceType_Id=0, @pSrReferenceType_Name='MO Fee', @pSrReferenceType_Unit='Rs/kWh', @pUserId=100    
CREATE   PROCEDURE dbo.InsertUpdateReferenceTypes        
            @pSrReferenceType_Id int        
           ,@pSrReferenceType_Name varchar(100)        
           ,@pSrReferenceType_Unit    nvarchar(50)        
           ,@pUserId      DECIMAL(18,0)       
AS                   
BEGIN    
SET NOCOUNT ON;    
BEGIN TRY    
  if(@pSrReferenceType_Name is null)    
  BEGIN    
    RAISERROR('Reference Name should not be empty', 16, -1)    
        
    RETURN;    
        
  END    
  if(@pSrReferenceType_Unit is null)    
  BEGIN    
    RAISERROR('Reference Unit should not be empty', 16, -1)    
        
    RETURN;    
        
  END    
    
IF NOT EXISTS (SELECT    
   1    
  FROM SrReferenceType    
  WHERE SrReferenceType_Id = @pSrReferenceType_Id)    
BEGIN    
/***************** Insertion case *************/    
INSERT INTO SrReferenceType (SrReferenceType_Name, SrReferenceType_Unit, SrReferenceType_CreatedOn, SrReferenceType_CreatedBy)    
 VALUES ( @pSrReferenceType_Name, @pSrReferenceType_Unit, GETDATE(), @pUserId)    
  
select 1 as response;  
END    
    
ELSE    
BEGIN    
/***************** Updation case *************/    
UPDATE SrReferenceType    
SET SrReferenceType_Name = @pSrReferenceType_Name    
   ,SrReferenceType_Unit = @pSrReferenceType_Unit    
   ,SrReferenceType_ModifiedOn = GETDATE()    
   ,SrReferenceType_ModifiedBy = @pUserId    
WHERE SrReferenceType_Id = @pSrReferenceType_Id    
  
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
