/****** Object:  Procedure [dbo].[Insert_GenerationAvailabilityData_Interface]    Committed by VersionSQL https://www.versionsql.com ******/

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------         
                  
--CREATE TYPE [dbo].[MtAvailabilityData_UDT_Interface] AS TABLE(                  
-- [MtAvailibilityData_Date] NVARCHAR(MAX) NULL,                  
-- [MtAvailibilityData_Hour] NVARCHAR(MAX) NULL,                  
-- [MtGenerationUnit_Id] NVARCHAR(MAX) NULL,                  
-- [MtAvailibilityData_ActualCapacity] NVARCHAR(MAX) NULL,                  
-- [MtAvailibilityData_AvailableCapacityASC] NVARCHAR(MAX) NULL                  
--)                  
--GO                  
                  
                  
                  
CREATE   PROCEDURE dbo.Insert_GenerationAvailabilityData_Interface                  
@fileMasterId decimal(18,0),                  
@UserId Int,                  
@tblAvailabilityData [dbo].[MtAvailabilityData_UDT_Interface] READONLY                  
                   
AS                  
BEGIN                  
                      
                  
 INSERT INTO [dbo].MtAvailibilityData_Interface                  
 (                  
  [MtAvailibilityData_RowNumber]                  
  ,[MtSOFileMaster_Id]                  
  ,MtAvailibilityData_Date                  
  ,[MtAvailibilityData_Hour]                  
  ,MtGenerationUnit_Id                  
  ,[MtAvailibilityData_AvailableCapacityASC]                  
  ,[MtAvailibilityData_ActualCapacity]                  
  ,MtAvailibilityData_IsValid                  
  ,MtAvailibilityData_CreatedBy                  
  ,MtAvailibilityData_CreatedOn                  
  ,MtAvailibilityData_IsDeleted        
  ,MtAvailibilityData_SyncStatus        
  ,MtAvailibilityData_GeneratingCapacity)                  
 SELECT                   
  ROW_NUMBER() OVER(order by MtAvailibilityData_Date) AS num_row ,                  
  @fileMasterId,                  
  MtAvailibilityData_Date,                  
  MtAvailibilityData_Hour,                  
  MtGenerationUnit_Id,                  
  MtAvailibilityData_AvailableCapacityASC,                  
  MtAvailibilityData_ActualCapacity                  
  ,1                  
  ,@UserId                  
  ,GETUTCDATE()                  
  ,0        
  ,MtAvailibilityData_SyncStatus        
  ,CASE WHEN MtAvailibilityData_SyncStatus='0' THEN '0'        
  ELSE MtAvailibilityData_AvailableCapacityASC END AS MtAvailibilityData_GeneratingCapacity        
         
                
  FROM @tblAvailabilityData                  
              
 exec [dbo].[SOAvailabilityDataValidation] @fileMasterId,@UserId                  
                
END 
