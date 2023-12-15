/****** Object:  Procedure [dbo].[InsertUpdateReferenceValues]    Committed by VersionSQL https://www.versionsql.com ******/

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  
    
      
        
-- =============================================            
-- Author:  Sadaf Malik      
-- CREATE date: DEC 13, 2022           
-- ALTER date:           
-- Reviewer:          
-- Description:           
-- =============================================           
--dbo.InsertUpdateReferenceValues    @pMtReferenceValue_Id=0, @pSrReferenceType_Id=1, @pMtReferenceValue_Value=100, @pMtReferenceValue_EffectiveFrom='2022-10-1',@pMtReferenceValue_EffectiveTo='2025-10-1', @pUserId=100      
CREATE   PROCEDURE dbo.InsertUpdateReferenceValues          
            @pMtReferenceValue_Id int          
   ,@pSrReferenceType_Id int    
   ,@pMtReferenceValue_Value decimal(24,8)    
   ,@pMtReferenceValue_EffectiveFrom dateTime    
   ,@pMtReferenceValue_EffectiveTo dateTime    
            ,@pUserId      DECIMAL(18,0)         
AS                     
BEGIN      
SET NOCOUNT ON;      
BEGIN TRY      
  if(@pSrReferenceType_Id is null)      
  BEGIN      
    RAISERROR('Reference type should not be empty', 16, -1)      
          
    RETURN;      
          
  END      
  if(@pMtReferenceValue_Value is null)      
  BEGIN      
    RAISERROR('Reference value should not be empty', 16, -1)            
    RETURN;            
  END      
    
  if(@pMtReferenceValue_EffectiveFrom is null)      
  BEGIN      
    RAISERROR('Effective from date should not be empty', 16, -1)            
    RETURN;            
  END      
    
  if(@pMtReferenceValue_EffectiveTo is null)      
  BEGIN      
    RAISERROR('Effective to should not be empty', 16, -1)            
    RETURN;            
  END      
  
  if(@pMtReferenceValue_EffectiveFrom > @pMtReferenceValue_EffectiveTo)      
  BEGIN      
    RAISERROR('Effective from date should be less than Effective to date', 16, -1)            
    RETURN;            
  END      

if exists( select 1 from RuReferenceValue where SrReferenceType_Id=@pSrReferenceType_Id
	  and	  
	  (
	  (RuReferenceValue_EffectiveFrom between @pMtReferenceValue_EffectiveFrom and @pMtReferenceValue_EffectiveTo)
	  or
	  (RuReferenceValue_EffectiveTo between @pMtReferenceValue_EffectiveFrom and @pMtReferenceValue_EffectiveTo)
	  )
	  and (RuReferenceValue_Id<>@pMtReferenceValue_Id or @pMtReferenceValue_Id=0)
	  and SrReferenceType_Id=@pSrReferenceType_Id
	  and ISNULL(RuReferenceValue_IsDeleted,0)=0)
    BEGIN
	    RAISERROR('Please select different date range. Values already exist for same period.', 16, -1)            
	    RETURN;            
	END;
IF NOT EXISTS (SELECT      
   1      
  FROM RuReferenceValue      
  WHERE RuReferenceValue_Id = @pMtReferenceValue_Id)      
BEGIN      
/***************** Insertion case *************/      
INSERT INTO RuReferenceValue ( SrReferenceType_Id, RuReferenceValue_Value, RuReferenceValue_EffectiveFrom, RuReferenceValue_EffectiveTo, RuReferenceValue_CreatedOn, RuReferenceValue_CreatedBy)      
 VALUES ( @pSrReferenceType_Id, @pMtReferenceValue_Value, @pMtReferenceValue_EffectiveFrom, @pMtReferenceValue_EffectiveTo, GETDATE(), @pUserId)      
select 1 as response;  
END      
      
ELSE      
BEGIN      
/***************** Updation case *************/      
UPDATE RuReferenceValue      
SET RuReferenceValue_Value = @pMtReferenceValue_Value      
   ,RuReferenceValue_EffectiveFrom= @pMtReferenceValue_EffectiveFrom       
   ,RuReferenceValue_EffectiveTo=@pMtReferenceValue_EffectiveTo    
   ,RuReferenceValue_ModifiedOn = GETDATE()      
   ,RuReferenceValue_ModifiedBy = @pUserId      
WHERE RuReferenceValue_Id = @pMtReferenceValue_Id  AND    
SrReferenceType_Id=@pSrReferenceType_Id    
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
