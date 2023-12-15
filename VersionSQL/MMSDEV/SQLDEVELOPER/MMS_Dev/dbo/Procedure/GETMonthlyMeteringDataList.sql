/****** Object:  Procedure [dbo].[GETMonthlyMeteringDataList]    Committed by VersionSQL https://www.versionsql.com ******/

--==========================================================================================      
-- Author: AMMAMA GILL      
-- CREATE date: 28 SEP 2023      
-- ALTER date:          
-- Description: To read stats relevant to the MtBvmReading table from      
---    MtBVMDataHeader and enhance grid read performance.      
--==========================================================================================      

CREATE PROCEDURE GETMonthlyMeteringDataList
AS
BEGIN
	SELECT
		MtBVMDataHeader_TotalRecords AS totalRecords
	   ,MtBVMDataHeader_Month AS [month]
	   ,MtBVMDataHeader_Year AS Year
	   ,MtBVMDataHeader_MonthName AS [MonthName]
	   ,MtBVMDataHeader_TotalCDPs AS totalCdpCount
	   ,MtBVMDataHeader_TotalActiveCDPs AS totalActiveCdpCount
	   ,MtBVMDataHeader_LastUpdatedOn AS lastupdatedDatetime
	   ,MtBVMDataHeader_ConnectedCDPs AS connectedCDPs
	   ,MtBVMDataHeader_DataStatus AS DataStatus
	FROM MtBVMDataHeader
	ORDER BY MtBVMDataHeader_Year DESC, MtBVMDataHeader_Month DESC
END
