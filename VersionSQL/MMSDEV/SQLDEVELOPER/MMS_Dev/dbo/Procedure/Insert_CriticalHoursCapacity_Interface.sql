/****** Object:  Procedure [dbo].[Insert_CriticalHoursCapacity_Interface]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================              
-- Author: Ammama Gill                         
-- CREATE date:  14/12/2022                               
-- ALTER date:                                 
-- Reviewer:                                
-- Description: Insert Critical Hours Capacity data into the interface table and validate the inserted data.                             
-- =============================================                                 
-- =============================================         
  
CREATE PROCEDURE dbo.Insert_CriticalHoursCapacity_Interface @pFileMasterId DECIMAL(18, 0),  
@pUserId INT,  
@pTblCriticalHoursCapacity [dbo].[MtCriticalHoursCapacity_Interface_UDT] READONLY  
AS  
BEGIN  
 BEGIN TRY  
  
  INSERT INTO MtCriticalHoursCapacity_Interface (MtSOFileMaster_Id  
  , MtCriticalHoursCapacity_RowNumber  
  , MtCriticalHoursCapacity_CriticalHour  
  , MtCriticalHoursCapacity_Date  
  , MtCriticalHoursCapacity_Hour  
  , MtCriticalHoursCapacity_SOUnitId  
  , MtCriticalHoursCapacity_Capacity  
  , MtCriticalHoursCapacity_IsValid  
  , MtCriticalHoursCapacity_Message  
  , MtCriticalHoursCapacity_CreatedBy  
  , MtCriticalHoursCapacity_CreatedOn)  
   SELECT  
    @pFileMasterId  
      ,ROW_NUMBER() OVER (ORDER BY CriticalHoursCapacity_CriticalHour ) AS CriticalHoursCapacity_CriticalHour  
      ,CriticalHoursCapacity_CriticalHour  
      ,CriticalHoursCapacity_Date  
      ,CriticalHoursCapacity_Hour  
      ,CriticalHoursCapacity_SOUnitId  
      ,CriticalHoursCapacity_Capacity  
      ,1  
      ,''  
      ,@pUserId  
      ,GETDATE()  
   FROM @pTblCriticalHoursCapacity  
  
  EXEC CriticalHoursCapacity_Validations @pFileMasterId  
             ,@pUserId;  
  
 END TRY  
 BEGIN CATCH  
  
  SELECT  
   ERROR_NUMBER() AS ErrorNumber  
     ,ERROR_STATE() AS ErrorState  
     ,ERROR_SEVERITY() AS ErrorSeverity  
     ,ERROR_PROCEDURE() AS ErrorProcedure  
     ,ERROR_LINE() AS ErrorLine  
     ,ERROR_MESSAGE() AS ErrorMessage;  
 END CATCH  
  
END
