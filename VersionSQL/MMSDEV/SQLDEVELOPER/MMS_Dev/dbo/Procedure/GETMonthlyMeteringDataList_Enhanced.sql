/****** Object:  Procedure [dbo].[GETMonthlyMeteringDataList_Enhanced]    Committed by VersionSQL https://www.versionsql.com ******/

--==========================================================================================  
-- Author: AMMAMA GILL  
-- CREATE date: 28 SEP 2023  
-- ALTER date:      
-- Description: To read stats relevant to the MtBvmReading table from  
---    MtBVMDataHeader and enhance grid read performance.  
--==========================================================================================  

CREATE procedure GETMonthlyMeteringDataList_Enhanced 
as begin
	select MtBVMDataHeader_TotalRecords as totalRecords
	,MtBVMDataHeader_Month as [month]
	,MtBVMDataHeader_Year as Year
	    ,MtBVMDataHeader_MonthName AS [MonthName]  
		,MtBVMDataHeader_TotalCDPs as totalCdpCount
		,MtBVMDataHeader_TotalActiveCDPs as totalActiveCdpCount
		,MtBVMDataHeader_LastUpdatedOn as lastupdatedDatetime
		,MtBVMDataHeader_ConnectedCDPs as connectedCDPs
		,MtBVMDataHeader_DataStatus as DataStatus
	from MtBVMDataHeader 
end
