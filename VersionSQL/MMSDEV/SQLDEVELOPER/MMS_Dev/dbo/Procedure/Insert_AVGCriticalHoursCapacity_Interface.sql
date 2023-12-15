/****** Object:  Procedure [dbo].[Insert_AVGCriticalHoursCapacity_Interface]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================                  
-- Author: Aymen Khalid                             
-- CREATE date:  26/12/2022                                   
-- ALTER date:                                     
-- Reviewer:                                    
-- Description: Insert Average Critical Hours Capacity data into the interface table                                  
-- =============================================                                     
-- =============================================             
      
CREATE PROCEDURE dbo.Insert_AVGCriticalHoursCapacity_Interface @pFileMasterId DECIMAL(18, 0),      
@pUserId INT,      
@pTblAVGCriticalHoursCapacity [dbo].[MtAvgCriticalHoursCapacity_Interface_UDT] READONLY      
AS      
BEGIN      
 BEGIN TRY      
      
  INSERT INTO [MtAvgCriticalHoursCapacity_Interface] (MtSOFileMaster_Id      
 ,MtAvgCriticalHoursCapacity_RowNumber    
 ,MtAvgCriticalHoursCapacity_SOUnitId    
 ,MtAvgCriticalHoursCapacity_AVGCapacity    
 ,MtAvgCriticalHoursCapacity_IsValid    
 ,MtAvgCriticalHoursCapacity_Message    
 ,MtAvgCriticalHoursCapacity_CreatedBy    
 ,MtAvgCriticalHoursCapacity_CreatedOn)    
   SELECT      
    @pFileMasterId      
      ,ROW_NUMBER() OVER (ORDER BY [AvgCriticalHoursCapacity_Interface_SOUnitId] ) AS [AvgCriticalHoursCapacity_Interface_SOUnitId]      
      ,[AvgCriticalHoursCapacity_Interface_SOUnitId]      
      ,[AvgCriticalHoursCapacity_Interface_AVGCapacity]          
      ,1      
      ,''      
      ,@pUserId      
      ,GETDATE()      
   FROM @pTblAVGCriticalHoursCapacity      
      
      
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
