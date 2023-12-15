/****** Object:  Procedure [dbo].[BMCStep2Perform]    Committed by VersionSQL https://www.versionsql.com ******/

--USE MMS_Dev

--==========================================================================================  
-- Author: Ali Imran  
-- CREATE date: 21 Dec 2022  
-- ALTER date:      
-- Description:                 
--==========================================================================================  
CREATE   PROCEDURE dbo.BMCStep2Perform   
  
@pStatementProcessId DECIMAL(18, 0)  
AS  
BEGIN  
  
/*==========================================================================================  
Fetch So average capacity   
==========================================================================================*/  
  
 UPDATE ACGU  
 SET ACGU.BMCAvailableCapacityGU_AvgCapacitySO = MtAvgCriticalHoursCapacity_AVGCapacity/1000 
 FROM [dbo].[MtAvgCriticalHoursCapacity] AC  
 JOIN [BMCAvailableCapacityGU] ACGU  
  ON AC.MtAvgCriticalHoursCapacity_SOUnitId = ACGU.BMCAvailableCapacityGU_SoUnitId  
 WHERE MtSOFileMaster_Id = dbo.GetMtSoFileMasterId(@pStatementProcessId, 11)  
  
  
  
/*==========================================================================================  
stop if so and mms avg capacity not match  
BMCAvailableCapacityGU_AvgCapacitySO==[BMCAvailableCapacityGU_AvgCapacityCal]  
==========================================================================================*/  
 IF   EXISTS (SELECT  
   TOP 1  
    1  
   FROM BMCAvailableCapacityGU  
   WHERE MtStatementProcess_ID = @pStatementProcessId  
   AND BMCAvailableCapacityGU_AvgCapacitySO <> BMCAvailableCapacityGU_AvgCapacityCal)  
  
 BEGIN  
  RAISERROR('SO Average Capacity not matched with Calculated Average Capacity', 16, -1)       
  RETURN;  
 END  
  
  
/*==========================================================================================  
Calculate Gen wise Average Avaialable capacity  
Insert in BMCAvailableCapacityGen  
==========================================================================================*/  
IF NOT EXISTS (SELECT TOP 1  
   1  
  FROM [dbo].[BMCAvailableCapacityGen]  
  WHERE MtStatementProcess_ID = @pStatementProcessId)  
BEGIN  
 INSERT INTO [dbo].[BMCAvailableCapacityGen] ([BMCAvailableCapacityGen_AvailableCapacityAvg]  
 , [MtGenerator_Id]  
 , [MtStatementProcess_ID])  
  
  SELECT  
   SUM(BMCAvailableCapacityGU_AvgCapacityCal)  
     ,MtGenerator_Id  
     ,MtStatementProcess_ID  
  FROM BMCAvailableCapacityGU  
  WHERE MtStatementProcess_ID = @pStatementProcessId  
  GROUP BY MtGenerator_Id  
    ,MtStatementProcess_ID  
  
END  
  
END
