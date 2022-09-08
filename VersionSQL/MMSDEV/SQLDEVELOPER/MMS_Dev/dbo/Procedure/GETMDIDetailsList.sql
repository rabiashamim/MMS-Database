/****** Object:  Procedure [dbo].[GETMDIDetailsList]    Committed by VersionSQL https://www.versionsql.com ******/

--use MMS_PreProd
/****************************************************************************************  
Test Cases  
*************************************************************************************************/  
 -- [dbo].[GETMDIDetailsList]   @pSearchCriteria='Batch',@pBatchId=2

 CREATE PROCEDURE [dbo].[GETMDIDetailsList]      
  @pSearchCriteria varchar(50)=null,--'Monthly',-- =null  ,--is month or batch  
  @pMonthYear varchar(50) =null,--'October, 2021',--null, -- month,year(January, 2022) or batch   
  @pBatchId int =null,  
  @pCdpParameter bit=null
  AS      
 BEGIN     
  
  
/***********************************************************************************************  
  
*************************************************************************************************/  
select DISTINCT 
	mdm.MtMonthlyMDI_Id
	, import.MtMDIImportInfo_BatchNo
	, import.MtMDIImportInfo_ImportInMMSDate
	, mdm.MtMDIImportInfo_Id
	, mdm.MtMonthlyMDI_Month
	, mdm.MtMonthlyMDI_Year
	, mdm.RuCDPDetail_CdpId
	, mdm.MtMonthlyMDI_MdiMonthImport
	, mdm.MtMonthlyMDI_MdiMonthExport 
	, cdp.RuCDPDetail_CdpName
	, mdm.MtMonthlyMDI_MeterIdImport
	, mdm.MtMonthlyMDI_MeterIdExport
	, mdm.MtMonthlyMDI_DataSourceImport
	, mdm.MtMonthlyMDI_DataSourceExport
	, mdm.MtMonthlyMDI_MeterQualifierImport
	, mdm.MtMonthlyMDI_MeterQualifierExport
	,mdm.MtMonthlyMDI_DateTimeStampImport
	, mdm.MtMonthlyMDI_DataLabelImport
	, mdm.MtMonthlyMDI_DataStatusImport
	,mdm.MtMonthlyMDI_DateTimeStampExport
	, mdm.MtMonthlyMDI_DataLabelExport
	, mdm.MtMonthlyMDI_DataStatusExport
	, CdpStatus=(  
      select case WHEN R1.RuCDPDetail_ConnectedFromID>0 and R1.RuCDPDetail_ConnectedToID>0 THEN 'Connected' ELSE 'Not Connected'   
            END  from RuCDPDetail R1 where  R1.RuCDPDetail_CdpId=CDP.RuCDPDetail_CdpId  
      )    
	 , CDP.RuCDPDetail_FromCustomer  
	 , CDP.RuCDPDetail_ToCustomer  
	 , CDP.RuCDPDetail_LineVoltage  
	 ,PRT.MtPartyRegisteration_Name AS MMSConnectedFrom  
	 ,PRF.MtPartyRegisteration_Name AS MMSConnectedTo  
	 
	 into #temp1
from MtMonthlyMDI mdm
inner join MtMDIImportInfo import on import.MtMDIImportInfo_Id=mdm.MtMDIImportInfo_Id
left join RuCDPDetail cdp on cdp.RuCDPDetail_CdpId=mdm.RuCDPDetail_CdpId
 LEFT JOIN MtPartyRegisteration PRT ON PRT.MtPartyRegisteration_Id = CDP.RuCDPDetail_ConnectedFromID 
 LEFT JOIN MtPartyRegisteration PRF ON PRF.MtPartyRegisteration_Id = 
 CDP.RuCDPDetail_ConnectedToID

  WHERE
   
(@pSearchCriteria='Batch'  and import.MtMDIImportInfo_BatchNo = @pBatchId)  
OR  
(@pSearchCriteria='Monthly' and  Concat(DATENAME(Month,DATEFROMPARTS(DATEPART(year, GETDATE()), mdm.MtMonthlyMDI_Month,1)) ,' ',mdm.MtMonthlyMDI_Year)=@pMonthYear)  
 
 
/***********************************************************************************************  
CDP Filtering Batch wise or Monthly Wise and save data in #temp1  
*************************************************************************************************/  
--select *    
--into #temp1   
--from #temp

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
  
  
Select  
ROW_NUMBER() over(order by MtMonthlyMDI_Id) rn,  
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
--AND (@pMonthParameter is null or   
--(MtMonthlyMDI_Month= @pMonthParameter)  
--)  
  
/***********************************************************************************************  
Paggination  
*************************************************************************************************/  
SELECT   
 *   
FROM   
 #temp2  
  
  
  
/***********************************************************************************************  
Shows Top Summary  
1. BVM Records  
2. Total CDPs  
3. Connected CDPs  
 -- [dbo].[GETBVMDetailsList]  @pSearchCriteria='Batch',@pBatchId=2,@pageSize=10, @pageNumber=1,@pMonthParameter='November, 2021'  
*************************************************************************************************/  
select   
  count(1) as totalMDIRecords  
   , count(DISTINCT RuCDPDetail_CdpId) as totalCdps,  
  ConnectedCdps=(  
  select count(distinct(concat(RuCDPDetail_CdpId,CdpStatus)))  
  from #temp2  
  where CdpStatus='Connected'  
  )  
  
from #temp2  
  
/***********************************************************************************************  
For Showing import date   
*************************************************************************************************/  
 select TOP 1  
 import.MtMDIImportInfo_ImportInMMSDate   
 from   
 MtMDIImportInfo import
inner join  MtMonthlyMDI mdm on import.MtMDIImportInfo_Id=mdm.MtMDIImportInfo_Id
where   
 
(@pSearchCriteria='Batch'  and MtMDIImportInfo_BatchNo = @pBatchId)  
OR  
(@pSearchCriteria='Monthly' and  Concat(DATENAME(Month,DATEFROMPARTS(DATEPART(year, GETDATE()), MtMonthlyMDI_Month,1)) ,' ',mdm.MtMonthlyMDI_Year)=@pMonthYear)  
 
  
/***********************************************************************************************  
FOR server side pagination we need total number of reccords.  
*************************************************************************************************/  
select count(1) as totalMDIRecords from #temp2  
   END  
