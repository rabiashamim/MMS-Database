/****** Object:  Procedure [dbo].[GETMeteringDataList]    Committed by VersionSQL https://www.versionsql.com ******/

--==========================================================================================          
-- Author: AMMAMA GILL          
-- CREATE date: 02 OCT 2023          
-- ALTER date:              
-- Description: To read data relevant to the MtMeteringImportInfo table          
---    and enhance grid read performance.          
--==========================================================================================          
--GETMeteringDataList_Enhanced         
  
  
CREATE PROCEDURE GETMeteringDataList  
AS  
BEGIN  
  
 SELECT  
  MII.MtMeteringImportInfo_Id  
    ,MII.MtMeteringImportInfo_BatchNo  
    ,isnull(MII.MtMeteringImportInfo_TotalCDPs,0) AS totalCdps  
    ,isnull(MII.MtMeteringImportInfo_TotalActiveCDPs,0) AS totalActiveCdps  
    ,isnull(MII.MtMeteringImportInfo_BVMRecords,0) AS bvmRecords  
    ,MII.MtMeteringImportInfo_CreatedOn  
    ,isnull(MII.MtMeteringImportInfo_ConnectedCDPs,0) AS connectedCDPs  
 FROM MtMeteringImportInfo MII  
 ORDER BY mii.MtMeteringImportInfo_Id DESC  
 , mii.MtMeteringImportInfo_BatchNo DESC  
 , mii.MtMeteringImportInfo_CreatedOn DESC  
  
  
END
