/****** Object:  Procedure [dbo].[GETMeteringDataList_bk3Oct23]    Committed by VersionSQL https://www.versionsql.com ******/

  
CREATE   Procedure dbo.GETMeteringDataList_bk3Oct23  
  
AS  
BEGIN  
  
 SELECT  
  --distinct(CM.MtCDPDetail_Id) AS MMS_CdpId        
  CDP.RuCDPDetail_CdpId AS RuCDPDetail_CdpId INTO #ConnectedCDPs  
 FROM MtConnectedMeter CM  
 JOIN RuCDPDetail CDP  
  ON CM.MtCDPDetail_Id = CDP.RuCDPDetail_Id  
 WHERE CM.IsAssigned = 1  
 AND CDP.RuCDPDetail_ConnectedFromID IS NOT NULL  
 AND CDP.RuCDPDetail_ConnectedToID IS NOT NULL  
 AND MtConnectedMeter_isDeleted = 0  
 GROUP BY MtCDPDetail_Id  
   ,CDP.RuCDPDetail_CdpId  
 --HAVING         
 -- count(MtCDPDetail_Id)=2         
 SELECT  
  mmii.MtMeteringImportInfo_Id  
    ,mmii.MtMeteringImportInfo_BatchNo  
    ,totalCdps = (SELECT  
    COUNT(DISTINCT mbr1.RuCDPDetail_CdpId)  
   FROM MtBvmReading mbr1  
   WHERE mbr1.MtMeteringImportInfo_Id = mmii.MtMeteringImportInfo_Id)  
    ,totalActiveCdps = (SELECT  
    COUNT(DISTINCT mbr1.RuCDPDetail_CdpId)  
   FROM MtBvmReading mbr1  
   INNER JOIN RuCDPDetail cdp  
    ON mbr1.RuCDPDetail_CdpId = cdp.RuCDPDetail_CdpId  
   WHERE mbr1.MtMeteringImportInfo_Id = mmii.MtMeteringImportInfo_Id  
   AND RuCDPDetail_CdpStatus = 'Active')  
    ,bvmRecords = (SELECT  
    COUNT(1)  
   FROM MtBvmReading mbr2  
   WHERE mbr2.MtMeteringImportInfo_Id = mmii.MtMeteringImportInfo_Id)  
  
    ,mmii.MtMeteringImportInfo_CreatedOn  
    ,connectedCDPs = (SELECT  
    COUNT(DISTINCT MtBvmReading.RuCDPDetail_CdpId)  
   FROM MtBvmReading  
   INNER JOIN MtMeteringImportInfo  
    ON MtBvmReading.MtMeteringImportInfo_Id = MtMeteringImportInfo.MtMeteringImportInfo_Id  
   INNER JOIN RuCDPDetail CDP  
    ON MtBvmReading.RuCDPDetail_CdpId = CDP.RuCDPDetail_CdpId  
    AND ISNULL(CDP.RuCDPDetail_ConnectedFromID, 0) > 0  
    AND ISNULL(CDP.RuCDPDetail_ConnectedToID, 0) > 0  
    AND CDP.RuCDPDetail_ConnectedFromID <> CDP.RuCDPDetail_ConnectedToID  
   LEFT JOIN MtConnectedMeter MC  
    ON MC.MtCDPDetail_Id = CDP.RuCDPDetail_Id  
    AND MC.IsAssigned = 1  
    AND MC.MtConnectedMeter_isDeleted = 0  
   WHERE MtBvmReading.MtMeteringImportInfo_Id = mmii.MtMeteringImportInfo_Id  
   AND RuCDPDetail_CdpStatus = 'Active')  
 FROM MtMeteringImportInfo mmii  
  
 --join MtBvmReading mbr on mbr.MtMeteringImportInfo_Id=mmii.MtMeteringImportInfo_Id         
  
 ORDER BY mmii.MtMeteringImportInfo_Id DESC, mmii.MtMeteringImportInfo_BatchNo DESC, mmii.MtMeteringImportInfo_CreatedOn DESC  
  
  
END  
