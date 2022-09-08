/****** Object:  Procedure [dbo].[Insert_GenerationAvailabilityDataV2]    Committed by VersionSQL https://www.versionsql.com ******/

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  
CREATE   PROCEDURE [dbo].[Insert_GenerationAvailabilityDataV2]  
 @fileMasterId decimal(18,0),  
 @UserId Int  
    
AS  
BEGIN  
    SET NOCOUNT ON;  
 declare @vMtAvailabilityData_Id Decimal(18,0);  
  
 SELECT @vMtAvailabilityData_Id=ISNUll(MAX(MtAvailibilityData_Id),0)+1 FROM MtAvailibilityData    
   
  
  INSERT INTO [dbo].MtAvailibilityData  
           (MtAvailibilityData_Id  
     ,MtAvailibilityData_RowNumber   
           ,[MtSOFileMaster_Id]  
           ,MtAvailibilityData_Date  
           ,[MtAvailibilityData_Hour]  
     ,MtGenerationUnit_Id  
           ,[MtAvailibilityData_AvailableCapacityASC]  
     ,[MtAvailibilityData_ActualCapacity]  
           ,MtAvailibilityData_CreatedBy  
           ,MtAvailibilityData_CreatedOn  
           ,MtAvailibilityData_IsDeleted)  
     
    SELECT   
  @vMtAvailabilityData_Id +ROW_NUMBER() OVER(order by MtAvailibilityData_Date) AS num_row ,  
  MtAvailibilityData_RowNumber,  
  MtSOFileMaster_Id,  
  CAST(MtAvailibilityData_Date AS DATE),  
  MtAvailibilityData_Hour,  
  MtGenerationUnit_Id,  
  MtAvailibilityData_AvailableCapacityASC,  
  MtAvailibilityData_ActualCapacity  
     ,@UserId  
  ,GETUTCDATE()  
  ,0  
 FROM   
  [MtAvailibilityData_Interface]  
 WHERE   
 MtSOFileMaster_Id=@fileMasterId  
  
  
  
 --select * from [MtAvailibilityData_Interface] WHERE MtSOFileMaster_Id=295  
 --select *  from [MtAvailibilityData] WHERE MtSOFileMaster_Id=295  
   
END 
