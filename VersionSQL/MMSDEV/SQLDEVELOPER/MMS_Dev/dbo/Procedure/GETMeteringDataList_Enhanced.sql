/****** Object:  Procedure [dbo].[GETMeteringDataList_Enhanced]    Committed by VersionSQL https://www.versionsql.com ******/

--==========================================================================================        
-- Author: AMMAMA GILL        
-- CREATE date: 02 OCT 2023        
-- ALTER date:            
-- Description: To read data relevant to the MtMeteringImportInfo table        
---    and enhance grid read performance.        
--==========================================================================================        
--GETMeteringDataList_Enhanced       


CREATE PROCEDURE GETMeteringDataList_Enhanced
AS
BEGIN

	SELECT
		MII.MtMeteringImportInfo_Id
	   ,MII.MtMeteringImportInfo_BatchNo
	   ,MII.MtMeteringImportInfo_TotalCDPs AS totalCdps
	   ,MII.MtMeteringImportInfo_TotalActiveCDPs AS totalActiveCdps
	   ,MII.MtMeteringImportInfo_BVMRecords AS bvmRecords
	   ,MII.MtMeteringImportInfo_CreatedOn
	   ,MII.MtMeteringImportInfo_ConnectedCDPs AS connectedCDPs
	FROM MtMeteringImportInfo MII
	ORDER BY mii.MtMeteringImportInfo_Id DESC
	, mii.MtMeteringImportInfo_BatchNo DESC
	, mii.MtMeteringImportInfo_CreatedOn DESC


END
