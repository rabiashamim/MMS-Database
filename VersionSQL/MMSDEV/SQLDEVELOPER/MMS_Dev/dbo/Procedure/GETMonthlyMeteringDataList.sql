/****** Object:  Procedure [dbo].[GETMonthlyMeteringDataList]    Committed by VersionSQL https://www.versionsql.com ******/

 CREATE PROCEDURE [dbo].[GETMonthlyMeteringDataList]    
 AS    

 DROP TABLE IF EXISTS #Temp
 DROP TABLE IF EXISTS #ConnectedCDPs
 BEGIN  



 
 --select 
	--				--distinct(CM.MtCDPDetail_Id) AS MMS_CdpId
	--				CDP.RuCDPDetail_CdpId   AS RuCDPDetail_CdpId
	--			into #ConnectedCDPs
	--			from 
	--				MtConnectedMeter CM
	--			JOIN RuCDPDetail CDP ON CM.MtCDPDetail_Id=CDP.RuCDPDetail_Id
	--			where
	--				CM.IsAssigned=1
	--				AND MtConnectedMeter_isDeleted=0
	--				AND CDP.RuCDPDetail_ConnectedToID is not null
	--				and CDP.RuCDPDetail_ConnectedFromID is not null
	--			GROUP BY 
	--				MtCDPDetail_Id
	--				,CDP.RuCDPDetail_CdpId
					
	--			--HAVING 
	--			--	count(MtCDPDetail_Id)=2 




SELECT    COUNT(*) as totalRecords,
MONTH(mbr1.MtBvmReadingIntf_NtdcDateTime) as month
, YEAR(mbr1.MtBvmReadingIntf_NtdcDateTime) as Year,
MonthName=(select Distinct(Concat(DATENAME(month,mbr5.MtBvmReadingIntf_NtdcDateTime),' ',YEAR(mbr5.MtBvmReadingIntf_NtdcDateTime))) from MtBvmReading mbr5 where Month(mbr5.MtBvmReadingIntf_NtdcDateTime)=Month(mbr1.MtBvmReadingIntf_NtdcDateTime) 
and  Year(mbr5.MtBvmReadingIntf_NtdcDateTime)=Year(mbr1.MtBvmReadingIntf_NtdcDateTime)),
totalCdpCount=(select count(DISTINCT mbr2.RuCDPDetail_CdpId) from MtBvmReading mbr2 where Month(mbr2.MtBvmReadingIntf_NtdcDateTime)=Month(mbr1.MtBvmReadingIntf_NtdcDateTime) and  Year(mbr2.MtBvmReadingIntf_NtdcDateTime)=Year(mbr1.MtBvmReadingIntf_NtdcDateTime)),
lastupdatedDatetime=(select max(MtBvmReadingIntf_NtdcDateTime) from MtBvmReading mbr3 where  Month(mbr3.MtBvmReadingIntf_NtdcDateTime)=Month(mbr1.MtBvmReadingIntf_NtdcDateTime) and  Year(mbr3.MtBvmReadingIntf_NtdcDateTime)=Year(mbr1.MtBvmReadingIntf_NtdcDateTime))
 ,connectedCDPs=(
					-- select 
					--	COUNT(distinct MtBvmReading.RuCDPDetail_CdpId) 
					--FROM 
					--	MtBvmReading 
					--	inner join MtMeteringImportInfo on MtBvmReading.MtMeteringImportInfo_Id=MtMeteringImportInfo.MtMeteringImportInfo_Id
					--	inner join RuCDPDetail CDP on MtBvmReading.RuCDPDetail_CdpId=CDP.RuCDPDetail_CdpId AND 
					--		ISNULL(CDP.RuCDPDetail_ConnectedFromID,0) > 0 AND ISNULL(CDP.RuCDPDetail_ConnectedToID,0) > 0 
					--		AND CDP.RuCDPDetail_ConnectedFromID <> CDP.RuCDPDetail_ConnectedToID
					--	LEFT JOIN MtConnectedMeter MC ON MC.MtCDPDetail_Id=CDP.RuCDPDetail_Id AND MC.IsAssigned=1 AND MC.MtConnectedMeter_isDeleted=0
					--	WHERE 
					--		MONTH(MtBvmReading.MtBvmReadingIntf_NtdcDateTime) = Month(mbr1.MtBvmReadingIntf_NtdcDateTime) AND
					--		YEAR(MtBvmReading.MtBvmReadingIntf_NtdcDateTime) = Year(mbr1.MtBvmReadingIntf_NtdcDateTime)
						 
						 select 
						COUNT(distinct MtBvmReading.RuCDPDetail_CdpId) 
					FROM 
						MtBvmReading 
						inner join RuCDPDetail CDP on MtBvmReading.RuCDPDetail_CdpId=CDP.RuCDPDetail_CdpId AND 
							ISNULL(CDP.RuCDPDetail_ConnectedFromID,0) > 0 AND ISNULL(CDP.RuCDPDetail_ConnectedToID,0) > 0 
							AND CDP.RuCDPDetail_ConnectedFromID <> CDP.RuCDPDetail_ConnectedToID
						WHERE 
							MONTH(MtBvmReading.MtBvmReadingIntf_NtdcDateTime) = Month(mbr1.MtBvmReadingIntf_NtdcDateTime) AND
							YEAR(MtBvmReading.MtBvmReadingIntf_NtdcDateTime) = Year(mbr1.MtBvmReadingIntf_NtdcDateTime)
					)
into #temp
FROM      MtBvmReading  mbr1
--WHERE     YEAR(MtBvmReadingIntf_NtdcDateTime) = '2021' 
GROUP BY  MONTH(MtBvmReadingIntf_NtdcDateTime),YEAR(MtBvmReadingIntf_NtdcDateTime)



select * ,
CASE
	WHEN Month = MONTH(GETDATE()) AND Year = YEAR(GETDATE()) 
		THEN CAST(CAST(totalRecords as decimal(18,5))/ CAST((totalCdpCount*DAY(GETDATE())*24) as Decimal(18,5)) as decimal(18,5))*100
	ELSE
		CAST(CAST(totalRecords as decimal(18,5))/ CAST((totalCdpCount*DAY(EOMONTH([MonthName]))*24) as Decimal(18,5)) as decimal(18,5))*100
END as DataStatus
from #Temp
order by Year desc, Month desc

--select * 
--,CAST(CAST(totalRecords as decimal(18,5))/ CAST((totalCdpCount*DAY(EOMONTH([MonthName]))*24) 
--as Decimal(18,5)) as decimal(18,5))*100 as DataStatus

--from #Temp
--   order by Year desc, Month desc
END
--select EOMONTH(MonthName)  from #Temp
	-- [dbo].[GETMonthlyMeteringDataList]  
