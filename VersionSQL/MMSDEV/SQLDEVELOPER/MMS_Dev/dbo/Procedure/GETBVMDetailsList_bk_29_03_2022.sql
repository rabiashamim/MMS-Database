/****** Object:  Procedure [dbo].[GETBVMDetailsList_bk_29_03_2022]    Committed by VersionSQL https://www.versionsql.com ******/

/***********************************************************************************************
Test Cases
*************************************************************************************************/
 -- [dbo].[GETBVMDetailsList]  @pSearchCriteria='Monthly',@pMonthYear='October, 2021',@pageSize=10, @pageNumber=2
 -- [dbo].[GETBVMDetailsList]  @pSearchCriteria='Monthly',@pMonthYear='October, 2021',@pageSize=10, @pageNumber=3, @pCdpParameter=0
 -- [dbo].[GETBVMDetailsList]  @pSearchCriteria='Batch',@pBatchId=2,@pageSize=10, @pageNumber=1
 -- [dbo].[GETBVMDetailsList]  @pSearchCriteria='Batch',@pBatchId=2,@pageSize=10, @pageNumber=1,@pMonthParameter='November, 2021'
 -- [dbo].[GETBVMDetailsList]  @pSearchCriteria='Batch',@pBatchId=18,@pageSize=10, @pageNumber=1,@pMonthParameter='August, 2021',@pCdpParameter=null
 CREATE PROCEDURE [dbo].[GETBVMDetailsList_bk_29_03_2022]    
  @pSearchCriteria varchar(50)=null,--'Monthly',-- =null  ,--is month or batch
  @pMonthYear varchar(50) =null,--'October, 2021',--null, -- month,year(January, 2022) or batch 
  @pBatchId int =null,
  @pageSize int=null,
  @pageNumber int =null,
  @pCdpParameter bit=null,
  @pMonthParameter varchar(50)=null
 AS    
 BEGIN   


/***********************************************************************************************

*************************************************************************************************/

select distinct
	MtBvmReading.MtBvmReading_Id 
	,MtBvmReading.MtBvmReadingIntf_NtdcDateTime
	,MtBvmReading.RuCDPDetail_CdpId
	,CDP.RuCDPDetail_CdpName
	,CDP.RuCDPDetail_FromCustomer
	,CDP.RuCDPDetail_ToCustomer
	,RuCDPDetail_LineVoltage
	,MtBvmReading.MtBvmReading_IncEnergyImport
	,MtBvmReading.MtBvmReading_IncEnergyExport
	--,MMSConnectedFrom=(
 --                         SELECT TOP 1
 --                         	mpr.MtPartyRegisteration_Name 
 --                         FROM
 --                         	MtPartyRegisteration mpr 
 --                         	JOIN MtPartyCategory PC ON PC.MtPartyRegisteration_Id =  MPR.MtPartyRegisteration_Id
 --                         	JOIN MtConnectedMeter CM ON CM.MtPartyCategory_Id = PC.MtPartyCategory_Id
 --                         	JOIN RuCDPDetail RCDP ON RCDP.RuCDPDetail_Id=CM.MtCDPDetail_Id
 --                         WHERE 
 --                         	RCDP.RuCDPDetail_CdpId=MtBvmReading.RuCDPDetail_CdpId)
	--,MMSConnectedTo= (
	--					SELECT TOP 1
	--						mpr.MtPartyRegisteration_Name 
	--					FROM
	--						MtPartyRegisteration mpr 
	--						JOIN MtPartyCategory PC ON PC.MtPartyRegisteration_Id =  MPR.MtPartyRegisteration_Id
	--						JOIN MtConnectedMeter CM ON CM.MtPartyCategory_Id = PC.MtPartyCategory_Id
	--						JOIN RuCDPDetail RCDP ON RCDP.RuCDPDetail_Id=CM.MtCDPDetail_Id
	--					WHERE 
	--						RCDP.RuCDPDetail_CdpId=MtBvmReading.RuCDPDetail_CdpId
	--				)
	,PRT.MtPartyRegisteration_Name AS MMSConnectedFrom
	,PRF.MtPartyRegisteration_Name AS MMSConnectedTo
	,Concat(DATENAME(month,MtBvmReadingIntf_NtdcDateTime),' ',YEAR(MtBvmReadingIntf_NtdcDateTime)) as NtdcMonthYear
	,MtMeteringImportInfo_BatchNo
	,MtMeteringImportInfo.MtMeteringImportInfo_ImportInMMSDate
    ,CdpStatus=(
        			select 
        				case when( count(*)=2) THEN 'Connected' ELSE 'Not Connected' 
        				END 
        			from 
        				MtConnectedMeter mcm1 
        			where 
        				mcm1.MtCDPDetail_Id=CDP.RuCDPDetail_Id 
        				and ISNULL(MtConnectedMeter_isDeleted,0)=0  
        				and ISNULL(IsAssigned,0)=1)  


INTO #temp
FROM 
	MtBvmReading
	inner join MtMeteringImportInfo on MtBvmReading.MtMeteringImportInfo_Id=MtMeteringImportInfo.MtMeteringImportInfo_Id
	inner join RuCDPDetail CDP on MtBvmReading.RuCDPDetail_CdpId=CDP.RuCDPDetail_CdpId
	LEFT JOIN MtConnectedMeter MC ON MC.MtCDPDetail_Id=CDP.RuCDPDetail_Id AND MC.IsAssigned=1 AND MC.MtConnectedMeter_isDeleted=0
	LEFT JOIN MtPartyRegisteration PRT ON PRT.MtPartyRegisteration_Id = MC.MtConnectedMeter_ConnectedTo
	LEFT JOIN MtPartyRegisteration PRF ON PRF.MtPartyRegisteration_Id = MC.MtConnectedMeter_ConnectedFrom



/***********************************************************************************************
CDP Filtering Batch wise or Monthly Wise and save data in #temp1
*************************************************************************************************/
select *  
into #temp1 
from #temp where 

(@pSearchCriteria='Batch'  and MtMeteringImportInfo_BatchNo = @pBatchId)
OR
(@pSearchCriteria='Monthly' and NtdcMonthYear=@pMonthYear)

/***********************************************************************************************
Filter if shows 
1. connected 
2. not connected 
3. show for specific month only 
AND save data in #temp2
*************************************************************************************************/


Select
ROW_NUMBER() over(order by MtBvmReading_Id) rn,
* 
into #temp2
From #temp1
where
(@pCdpParameter is null or(
(@pCdpParameter=1 and CdpStatus='Connected')
or
(@pCdpParameter=0 and CdpStatus='Not Connected')
)
)
AND (@pMonthParameter is null or 
(ntdcmonthyear= @pMonthParameter)
)

/***********************************************************************************************
Paggination
*************************************************************************************************/
SELECT 
	* 
FROM 
	#temp2
WHERE
	(rn>((@pageNumber-1)*@pageSize) and rn<=(@pageNumber*@pageSize))



/***********************************************************************************************
Shows Top Summary
1. BVM Records
2. Total CDPs
3. Connected CDPs
 -- [dbo].[GETBVMDetailsList]  @pSearchCriteria='Batch',@pBatchId=2,@pageSize=10, @pageNumber=1,@pMonthParameter='November, 2021'
*************************************************************************************************/
select 
		count(1) as totalBVMRecords
	  , count(DISTINCT RuCDPDetail_CdpId) as totalCdps,
		ConnectedCdps=(
		select count(distinct(concat(RuCDPDetail_CdpId,CdpStatus)))
		from #temp2
		where CdpStatus='Connected'
		)

from #temp2

/***********************************************************************************************
Month wise summary
*************************************************************************************************/

SELECT DISTINCT 
	  Concat(DATENAME(month,MtBvmReadingIntf_NtdcDateTime),' ',YEAR(MtBvmReadingIntf_NtdcDateTime)) as MonthYear
	, COUNT(Concat(DATENAME(month,MtBvmReadingIntf_NtdcDateTime),' ',YEAR(MtBvmReadingIntf_NtdcDateTime))) as totalCount
 FROM 
	#temp1
 
 GROUP BY 
	Concat(DATENAME(month,MtBvmReadingIntf_NtdcDateTime),' ',YEAR(MtBvmReadingIntf_NtdcDateTime))
ORDER BY
  Concat(DATENAME(month,MtBvmReadingIntf_NtdcDateTime),' ',YEAR(MtBvmReadingIntf_NtdcDateTime)) desc

/***********************************************************************************************
For Showing import date 
*************************************************************************************************/
 select TOP 1
	MtMeteringImportInfo_ImportInMMSDate 
 from 
	MtMeteringImportInfo 
where 
	MtMeteringImportInfo_BatchNo=@pBatchId
	and @pSearchCriteria='Batch'  

/***********************************************************************************************
FOR server side pagination we need total number of reccords.
*************************************************************************************************/
select count(1) as totalBVMRecords from #temp2
   END
