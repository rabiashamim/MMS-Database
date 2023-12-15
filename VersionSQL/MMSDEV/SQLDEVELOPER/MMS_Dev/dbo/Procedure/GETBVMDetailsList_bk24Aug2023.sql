/****** Object:  Procedure [dbo].[GETBVMDetailsList_bk24Aug2023]    Committed by VersionSQL https://www.versionsql.com ******/

--use MMS_PreProd    
/****************************************************************************************      
Test Cases      
*************************************************************************************************/  
-- [dbo].[GETBVMDetailsList]  @pSearchCriteria='Monthly',@pMonthYear='June 2022',@pageSize=10, @pageNumber=1    
-- [dbo].[GETBVMDetailsList]  @pSearchCriteria='Monthly',@pMonthYear='October, 2021',@pageSize=10, @pageNumber=3, @pCdpParameter=0      
-- [dbo].[GETBVMDetailsList]  @pSearchCriteria='Batch',@pBatchId=2,@pageSize=10, @pageNumber=1      
-- [dbo].[GETBVMDetailsList]  @pSearchCriteria='Batch',@pBatchId=2,@pageSize=10, @pageNumber=1,@pMonthParameter='November, 2021'      
-- [dbo].[GETBVMDetailsList]  @pSearchCriteria='Batch',@pBatchId=18,@pageSize=10, @pageNumber=1,@pMonthParameter='August, 2021',@pCdpParameter=null      
CREATE PROCEDURE dbo.GETBVMDetailsList_bk24Aug2023 @pSearchCriteria VARCHAR(50) = NULL,--'Monthly',-- =null  ,--is month or batch      
@pMonthYear VARCHAR(50) = NULL,--'October, 2021',--null, -- month,year(January, 2022) or batch       
@pBatchId INT = NULL,  
@pageSize INT = NULL,  
@pageNumber INT = NULL,  
@pCdpParameter BIT = NULL,  
@pMonthParameter VARCHAR(50) = NULL  
AS  
BEGIN  
  
  
 /***********************************************************************************************      
       
 *************************************************************************************************/  
  
 SELECT DISTINCT  
  MtBvmReading.MtBvmReading_Id  
    ,MtBvmReading.MtBvmReadingIntf_NtdcDateTime  
    ,MtBvmReading.RuCDPDetail_CdpId  
    ,CDP.RuCDPDetail_CdpName  
    ,CDP.RuCDPDetail_FromCustomer  
    ,CDP.RuCDPDetail_ToCustomer  
    ,RuCDPDetail_LineVoltage  
    ,MtBvmReading.MtBvmReading_IncEnergyImport  
    ,RuCdpMeters_MeterIdImport  
    ,MtBvmReading_DataSourceImport  
    ,MtBvmReading_MeterQualifierImport  
    ,MtBvmReading.MtBvmReading_IncEnergyExport  
    ,RuCdpMeters_MeterIdExport  
    ,MtBvmReading_DataSourceExport  
    ,MtBvmReading_MeterQualifierExport  
    ,PRT.MtPartyRegisteration_Name AS MMSConnectedFrom  
    ,PRF.MtPartyRegisteration_Name AS MMSConnectedTo  
    ,Concat(DATENAME(MONTH, MtBvmReadingIntf_NtdcDateTime), ' ', YEAR(MtBvmReadingIntf_NtdcDateTime)) AS NtdcMonthYear  
    ,MtMeteringImportInfo_BatchNo  
    ,MtMeteringImportInfo.MtMeteringImportInfo_ImportInMMSDate  
    ,CdpStatus = (  
   --select       
   -- case when( count(*)=2) THEN 'Connected' ELSE 'Not Connected'       
   -- END       
   --from       
   -- MtConnectedMeter mcm1       
   --where       
   -- mcm1.MtCDPDetail_Id=CDP.RuCDPDetail_Id       
   -- and ISNULL(MtConnectedMeter_isDeleted,0)=0        
   -- and ISNULL(IsAssigned,0)=1;      
  
   SELECT  
    CASE  
     WHEN R1.RuCDPDetail_ConnectedFromID > 0 AND  
      R1.RuCDPDetail_ConnectedToID > 0 THEN 'Connected'  
     ELSE 'Not Connected'  
    END  
   FROM RuCDPDetail R1  
   WHERE R1.RuCDPDetail_CdpId = CDP.RuCDPDetail_CdpId) INTO #temp  
 FROM MtBvmReading  
 INNER JOIN MtMeteringImportInfo  
  ON MtBvmReading.MtMeteringImportInfo_Id = MtMeteringImportInfo.MtMeteringImportInfo_Id  
 INNER JOIN RuCDPDetail CDP  
  ON MtBvmReading.RuCDPDetail_CdpId = CDP.RuCDPDetail_CdpId  
 LEFT JOIN MtConnectedMeter MC  
  ON MC.MtCDPDetail_Id = CDP.RuCDPDetail_Id  
   AND MC.IsAssigned = 1  
   AND MC.MtConnectedMeter_isDeleted = 0  
 LEFT JOIN MtPartyRegisteration PRT  
  ON PRT.MtPartyRegisteration_Id = CDP.RuCDPDetail_ConnectedFromID  
 --MC.MtConnectedMeter_ConnectedTo      
 LEFT JOIN MtPartyRegisteration PRF  
  ON PRF.MtPartyRegisteration_Id =  
   CDP.RuCDPDetail_ConnectedToID  
 --MC.MtConnectedMeter_ConnectedFrom      
 WHERE (@pSearchCriteria = 'Batch'  
 AND MtMeteringImportInfo_BatchNo = @pBatchId)  
 OR (@pSearchCriteria = 'Monthly'  
 AND Concat(DATENAME(MONTH, MtBvmReadingIntf_NtdcDateTime), ' ', YEAR(MtBvmReadingIntf_NtdcDateTime)) = @pMonthYear)  
  
 /***********************************************************************************************      
 CDP Filtering Batch wise or Monthly Wise and save data in #temp1      
 *************************************************************************************************/  
 SELECT  
  * INTO #temp1  
 FROM #temp  
  
 --where         
 --(@pSearchCriteria='Batch'  and MtMeteringImportInfo_BatchNo = @pBatchId)      
 --OR      
 --(@pSearchCriteria='Monthly' and NtdcMonthYear=@pMonthYear)      
  
 /***********************************************************************************************      
 Filter if shows       
 1. connected       
 2. not connected       
 3. show for specific month only       
 AND save data in #temp2      
 *************************************************************************************************/  
  
  
 SELECT  
  ROW_NUMBER() OVER (ORDER BY MtBvmReading_Id) rn  
    ,* INTO #temp2  
 FROM #temp1  
 WHERE (@pCdpParameter IS NULL  
 OR (  
 (@pCdpParameter = 1  
 AND CdpStatus = 'Connected')  
 OR (@pCdpParameter = 0  
 AND CdpStatus = 'Not Connected')  
 )  
 )  
 AND (@pMonthParameter IS NULL  
 OR (ntdcmonthyear = @pMonthParameter)  
 )  
  
 /***********************************************************************************************      
 Paggination      
 *************************************************************************************************/  
 SELECT  
  *  
 FROM #temp2  
 WHERE (rn > ((@pageNumber - 1) * @pageSize)  
 AND rn <= (@pageNumber * @pageSize))  
  
  
  
 /***********************************************************************************************      
 Shows Top Summary      
 1. BVM Records      
 2. Total CDPs      
 3. Connected CDPs      
  -- [dbo].[GETBVMDetailsList]  @pSearchCriteria='Batch',@pBatchId=2,@pageSize=10, @pageNumber=1,@pMonthParameter='November, 2021'      
 *************************************************************************************************/  
 SELECT  
  COUNT(1) AS totalBVMRecords  
    ,COUNT(DISTINCT RuCDPDetail_CdpId) AS totalCdps  
    ,ConnectedCdps = (SELECT  
    COUNT(DISTINCT (concat(RuCDPDetail_CdpId, CdpStatus)))  
   FROM #temp2  
   WHERE CdpStatus = 'Connected')  
  
 FROM #temp2  
  
 /***********************************************************************************************      
 Month wise summary      
 *************************************************************************************************/  
  
 SELECT DISTINCT  
  Concat(DATENAME(MONTH, MtBvmReadingIntf_NtdcDateTime), ' ', YEAR(MtBvmReadingIntf_NtdcDateTime)) AS MonthYear  
    ,COUNT(Concat(DATENAME(MONTH, MtBvmReadingIntf_NtdcDateTime), ' ', YEAR(MtBvmReadingIntf_NtdcDateTime))) AS totalCount  
 FROM #temp1  
  
 GROUP BY Concat(DATENAME(MONTH, MtBvmReadingIntf_NtdcDateTime), ' ', YEAR(MtBvmReadingIntf_NtdcDateTime))  
 ORDER BY Concat(DATENAME(MONTH, MtBvmReadingIntf_NtdcDateTime), ' ', YEAR(MtBvmReadingIntf_NtdcDateTime)) DESC  
  
 /***********************************************************************************************      
 For Showing import date       
 *************************************************************************************************/  
 SELECT TOP 1  
  MtMeteringImportInfo_ImportInMMSDate  
 FROM MtMeteringImportInfo  
 WHERE MtMeteringImportInfo_BatchNo = @pBatchId  
 AND @pSearchCriteria = 'Batch'  
  
 /***********************************************************************************************      
 FOR server side pagination we need total number of reccords.      
 *************************************************************************************************/  
 SELECT  
  COUNT(1) AS totalBVMRecords  
 FROM #temp2  
END
