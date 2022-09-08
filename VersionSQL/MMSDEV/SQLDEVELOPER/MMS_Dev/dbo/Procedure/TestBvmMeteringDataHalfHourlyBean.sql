/****** Object:  Procedure [dbo].[TestBvmMeteringDataHalfHourlyBean]    Committed by VersionSQL https://www.versionsql.com ******/

    
    
    
CREATE PROCEDURE [dbo].[TestBvmMeteringDataHalfHourlyBean]    
   
@tblData [dbo].[BvmMeteringDataHalfHourlyBean] READONLY    
     
AS    
BEGIN    
    SET NOCOUNT ON;    
  
     
    
      
    INSERT INTO BvmMeteringDataHalfHourlyBean  
 (    
	dateTimeStamp,
	cdpId ,
	incrementalActiveEnergyImport ,
	iMeterId,
	iMeterQualifier,
	iMeterDataSource,
	iDataStatus,
	iLabel,
	incrementalActiveEnergyExport,
	eMeterId,
	eMeterQualifier,
	eMeterDataSource,
	eDataStatus,
	eLabel 
 )    
    SELECT     
	*
 FROM @tblData    
  
  
  

END
