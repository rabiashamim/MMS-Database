/****** Object:  Procedure [dbo].[GETMonthlyMeteringDataList_bk23Aug2023]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE dbo.GETMonthlyMeteringDataList_bk23Aug2023  
AS  
  
 DROP TABLE IF EXISTS #Temp  
 DROP TABLE IF EXISTS #ConnectedCDPs  
 BEGIN  
  
  SELECT  
   COUNT(*) AS totalRecords  
     ,MONTH(mbr1.MtBvmReading_ReadingDate) AS month  
     ,YEAR(mbr1.MtBvmReading_ReadingDate) AS Year  
     ,  
   -- Below line can easily be improved.      
  
   Concat(DATENAME(MONTH, MIN(mbr1.MtBvmReading_ReadingDate)), ' ', YEAR(MIN(mbr1.MtBvmReading_ReadingDate))) AS [MonthName]  
     ,  
   --MonthName=(select       
   --    Distinct(Concat(DATENAME(month,mbr5.MtBvmReading_ReadingDate),' ',YEAR(mbr5.MtBvmReading_ReadingDate)))       
   --   from       
   --    MtBvmReading mbr5       
   --   where       
   --    Month(mbr5.MtBvmReading_ReadingDate)=Month(mbr1.MtBvmReading_ReadingDate)       
   --   and        
   --    Year(mbr5.MtBvmReading_ReadingDate)=Year(mbr1.MtBvmReading_ReadingDate)      
   --   ),      
   totalCdpCount = (SELECT  
     COUNT(DISTINCT mbr2.RuCDPDetail_CdpId)  
    FROM MtBvmReading mbr2  
    WHERE Month(mbr2.MtBvmReading_ReadingDate) = Month(mbr1.MtBvmReading_ReadingDate)  
    AND Year(mbr2.MtBvmReading_ReadingDate) = Year(mbr1.MtBvmReading_ReadingDate))  
     ,  
   --max(MtBvmReading_ModifiedOn) as lastupdatedDatetime      
   CASE  
    WHEN MAX(MtBvmReading_ModifiedOn) IS NULL OR  
     MAX(MtBvmReading_ModifiedOn) < MAX(MtBvmReading_CreatedOn) THEN MAX(MtBvmReading_CreatedOn)  
    ELSE MAX(MtBvmReading_ModifiedOn)  
   END AS lastupdatedDatetime  
   -- Below line can easily be improved       
   --lastupdatedDatetime=(      
   --      select       
   --       max(MtBvmReading_ReadingDate)       
   --      from       
   --       MtBvmReading mbr3       
   --      where        
   --       Month(mbr3.MtBvmReading_ReadingDate)=Month(mbr1.MtBvmReading_ReadingDate)       
   --      and        
   --       Year(mbr3.MtBvmReading_ReadingDate)=Year(mbr1.MtBvmReading_ReadingDate)      
   --     )      
  
     ,connectedCDPs = (SELECT  
     COUNT(DISTINCT MtBvmReading.RuCDPDetail_CdpId)  
    FROM MtBvmReading  
    INNER JOIN RuCDPDetail CDP  
     ON MtBvmReading.RuCDPDetail_CdpId = CDP.RuCDPDetail_CdpId  
     AND ISNULL(CDP.RuCDPDetail_ConnectedFromID, 0) > 0  
     AND ISNULL(CDP.RuCDPDetail_ConnectedToID, 0) > 0  
     AND CDP.RuCDPDetail_ConnectedFromID <> CDP.RuCDPDetail_ConnectedToID  
    WHERE MONTH(MtBvmReading.MtBvmReading_ReadingDate) = Month(mbr1.MtBvmReading_ReadingDate)  
    AND YEAR(MtBvmReading.MtBvmReading_ReadingDate) = Year(mbr1.MtBvmReading_ReadingDate)) INTO #temp  
  FROM MtBvmReading mbr1  
  GROUP BY MONTH(MtBvmReading_ReadingDate)  
    ,YEAR(MtBvmReading_ReadingDate)  
  
  
  
  SELECT  
   *  
     ,CASE  
    WHEN Month = MONTH(GETDATE()) AND  
     Year = YEAR(GETDATE()) THEN CAST(CAST(totalRecords AS DECIMAL(18, 5)) / CAST((totalCdpCount * DAY(GETDATE()) * 24) AS DECIMAL(18, 5)) AS DECIMAL(18, 5)) * 100  
    ELSE CAST(CAST(totalRecords AS DECIMAL(18, 5)) / CAST((totalCdpCount * DAY(EOMONTH([MonthName])) * 24) AS DECIMAL(18, 5)) AS DECIMAL(18, 5)) * 100  
   END AS DataStatus  
  FROM #Temp  
  ORDER BY Year DESC, Month DESC  
  
 END  
  
/*************************************************/  
  
-- =============================================                  
-- Author: Ammama Gill                             
-- CREATE date:  14/12/2022                                   
-- ALTER date:                                     
-- Reviewer:                                    
-- Description: Insert valid Critical Hours capacity data into the main table.                                 
-- =============================================                                     
-- ============================================= 
