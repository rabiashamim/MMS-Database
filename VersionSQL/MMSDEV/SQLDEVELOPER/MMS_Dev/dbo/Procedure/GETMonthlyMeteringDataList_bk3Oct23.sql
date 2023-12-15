/****** Object:  Procedure [dbo].[GETMonthlyMeteringDataList_bk3Oct23]    Committed by VersionSQL https://www.versionsql.com ******/

  
create  Procedure dbo.GETMonthlyMeteringDataList_bk3Oct23    
AS    
    
BEGIN    
 DROP TABLE IF EXISTS #temp    
 DROP TABLE IF EXISTS #ConnectedCDPs    
    
    
 SELECT    
  COUNT(*) AS totalRecords    
    ,month(mbr1.MtBvmReading_ReadingDate) AS month    
    ,Year(mbr1.MtBvmReading_ReadingDate) AS Year    
    ,Concat(DATENAME(MONTH, MIN(mbr1.MtBvmReading_ReadingDate)), ' ', Year(MIN(mbr1.MtBvmReading_ReadingDate))) AS [MonthName]    
    ,totalCdpCount = (SELECT    
    COUNT(DISTINCT mbr2.RuCDPDetail_CdpId)    
   FROM MtBvmReading mbr2    
   WHERE month(mbr2.MtBvmReading_ReadingDate) = month(mbr1.MtBvmReading_ReadingDate)    
   AND Year(mbr2.MtBvmReading_ReadingDate) = Year(mbr1.MtBvmReading_ReadingDate))    
    ,totalActiveCdpCount = (SELECT    
    COUNT(DISTINCT mbr2.RuCDPDetail_CdpId)    
   FROM MtBvmReading mbr2    
   INNER JOIN RuCDPDetail cdp    
    ON mbr2.RuCDPDetail_CdpId = cdp.RuCDPDetail_CdpId    
   WHERE month(mbr2.MtBvmReading_ReadingDate) = month(mbr1.MtBvmReading_ReadingDate)    
   AND Year(mbr2.MtBvmReading_ReadingDate) = Year(mbr1.MtBvmReading_ReadingDate)    
   AND RuCDPDetail_CdpStatus = 'Active')    
    
    ,CASE    
   WHEN MAX(MtBvmReading_ModifiedOn) IS NULL OR    
    MAX(MtBvmReading_ModifiedOn) < MAX(MtBvmReading_CreatedOn) THEN MAX(MtBvmReading_CreatedOn)    
   ELSE MAX(MtBvmReading_ModifiedOn)    
  END AS lastupdatedDatetime    
    
    ,connectedCDPs = (SELECT    
    COUNT(DISTINCT MtBvmReading.RuCDPDetail_CdpId)    
   FROM MtBvmReading    
   INNER JOIN RuCDPDetail CDP    
    ON MtBvmReading.RuCDPDetail_CdpId = CDP.RuCDPDetail_CdpId    
    AND ISNULL(CDP.RuCDPDetail_ConnectedFromID, 0) > 0    
    AND ISNULL(CDP.RuCDPDetail_ConnectedToID, 0) > 0    
    AND CDP.RuCDPDetail_ConnectedFromID <> CDP.RuCDPDetail_ConnectedToID    
   WHERE month(MtBvmReading.MtBvmReading_ReadingDate) = month(mbr1.MtBvmReading_ReadingDate)    
   AND Year(MtBvmReading.MtBvmReading_ReadingDate) = Year(mbr1.MtBvmReading_ReadingDate)    
   AND RuCDPDetail_CdpStatus = 'Active') INTO #temp    
 FROM MtBvmReading mbr1    
 GROUP BY month(MtBvmReading_ReadingDate)    
   ,Year(MtBvmReading_ReadingDate)    
    
    
 SELECT    
  *    
    ,CASE    
   WHEN Month = MONTH(GETDATE()) AND    
    Year = YEAR(GETDATE()) THEN CAST(CAST(totalRecords AS DECIMAL(18, 5)) / CAST((totalActiveCdpCount * DAY(GETDATE()) * 24) AS DECIMAL(18, 5)) AS DECIMAL(18, 5)) * 100    
   ELSE CAST(CAST(totalRecords AS DECIMAL(18, 5)) / CAST((totalActiveCdpCount * DAY(EOMONTH([MonthName])) * 24) AS DECIMAL(18, 5)) AS DECIMAL(18, 5)) * 100    
  END AS DataStatus    
 FROM #temp    
 ORDER BY Year DESC, Month DESC    
END  
