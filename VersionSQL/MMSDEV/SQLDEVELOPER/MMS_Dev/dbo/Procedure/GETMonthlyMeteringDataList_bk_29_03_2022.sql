/****** Object:  Procedure [dbo].[GETMonthlyMeteringDataList_bk_29_03_2022]    Committed by VersionSQL https://www.versionsql.com ******/

 CREATE PROCEDURE [dbo].[GETMonthlyMeteringDataList_bk_29_03_2022]    
 AS    

 DROP TABLE IF EXISTS #Temp
 DROP TABLE IF EXISTS #ConnectedCDPs
 BEGIN  



 
 select 
					--distinct(CM.MtCDPDetail_Id) AS MMS_CdpId
					CDP.RuCDPDetail_CdpId   AS RuCDPDetail_CdpId
				into #ConnectedCDPs
				from 
					MtConnectedMeter CM
				JOIN RuCDPDetail CDP ON CM.MtCDPDetail_Id=CDP.RuCDPDetail_Id
				where
					CM.IsAssigned=1
					AND MtConnectedMeter_isDeleted=0
				GROUP BY 
					MtCDPDetail_Id
					,CDP.RuCDPDetail_CdpId
					
				HAVING 
					count(MtCDPDetail_Id)=2 




SELECT    COUNT(*) as totalRecords,
MONTH(mbr1.MtBvmReadingIntf_NtdcDateTime) as month
, YEAR(mbr1.MtBvmReadingIntf_NtdcDateTime) as Year,
MonthName=(select Distinct(Concat(DATENAME(month,mbr5.MtBvmReadingIntf_NtdcDateTime),' ',YEAR(mbr5.MtBvmReadingIntf_NtdcDateTime))) from MtBvmReading mbr5 where Month(mbr5.MtBvmReadingIntf_NtdcDateTime)=Month(mbr1.MtBvmReadingIntf_NtdcDateTime) 
and  Year(mbr5.MtBvmReadingIntf_NtdcDateTime)=Year(mbr1.MtBvmReadingIntf_NtdcDateTime)),
totalCdpCount=(select count(DISTINCT mbr2.RuCDPDetail_CdpId) from MtBvmReading mbr2 where Month(mbr2.MtBvmReadingIntf_NtdcDateTime)=Month(mbr1.MtBvmReadingIntf_NtdcDateTime) and  Year(mbr2.MtBvmReadingIntf_NtdcDateTime)=Year(mbr1.MtBvmReadingIntf_NtdcDateTime)),


lastupdatedDatetime=(select max(MtBvmReadingIntf_NtdcDateTime) from MtBvmReading mbr3 where  Month(mbr3.MtBvmReadingIntf_NtdcDateTime)=Month(mbr1.MtBvmReadingIntf_NtdcDateTime) and  Year(mbr3.MtBvmReadingIntf_NtdcDateTime)=Year(mbr1.MtBvmReadingIntf_NtdcDateTime))

 ,connectedCDPs=(
						Select 
							count(distinct(RuCDPDetail_CdpId)) 
						FROM 
						    MtBvmReading MBR2 
						WHERE 
						    RuCDPDetail_CdpId IN
							(SELECT RuCDPDetail_CdpId FROM #ConnectedCDPs)
						    AND Month(mbr2.MtBvmReadingIntf_NtdcDateTime)=Month(mbr1.MtBvmReadingIntf_NtdcDateTime) 
							and  Year(mbr2.MtBvmReadingIntf_NtdcDateTime)=Year(mbr1.MtBvmReadingIntf_NtdcDateTime)
						
					)
into #temp
FROM      MtBvmReading  mbr1
--WHERE     YEAR(MtBvmReadingIntf_NtdcDateTime) = '2021' 
GROUP BY  MONTH(MtBvmReadingIntf_NtdcDateTime),YEAR(MtBvmReadingIntf_NtdcDateTime)



select * 
,CAST(CAST(totalRecords as decimal(18,5))/ CAST((totalCdpCount*DAY(EOMONTH([MonthName]))*24) 
as Decimal(18,5)) as decimal(18,5))*100 as DataStatus

from #Temp
   order by Year desc, Month desc
    END
--select EOMONTH(MonthName)  from #Temp
	-- [dbo].[GETMonthlyMeteringDataList]  
