/****** Object:  Procedure [dbo].[GETMonthlyMDIDataList]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[GETMonthlyMDIDataList]    
 AS    

 DROP TABLE IF EXISTS #Temp
 DROP TABLE IF EXISTS #ConnectedCDPs
 BEGIN  

SELECT    COUNT(*) as totalRecords,
MtMonthlyMDI_Month as month
, MtMonthlyMDI_Year as Year,
MonthName=(select Distinct(Concat(DATENAME(MONTH, DATEADD(MONTH, mbr5.MtMonthlyMDI_Month, '2000-12-01')),' ',mbr5.MtMonthlyMDI_Year)) from MtMonthlyMDI mbr5 where
mbr5.MtMonthlyMDI_Month=mbr1.MtMonthlyMDI_Month
and mbr5.MtMonthlyMDI_Year=mbr1.MtMonthlyMDI_Year
),
totalCdpCount=(select count(DISTINCT mbr2.RuCDPDetail_CdpId) from MtMonthlyMDI mbr2 where mbr2.MtMonthlyMDI_Month=mbr1.MtMonthlyMDI_Month and 
 mbr2.MtMonthlyMDI_Year=mbr1.MtMonthlyMDI_Year),
lastupdatedDatetime=(select max(mbr3.MtMonthlyMDI_CreatedOn) from MtMonthlyMDI mbr3 where 
mbr3.MtMonthlyMDI_Month=mbr1.MtMonthlyMDI_Month
and mbr3.MtMonthlyMDI_Year=mbr1.MtMonthlyMDI_Year
)
 ,connectedCDPs=(
						 select 
						COUNT(distinct MtMonthlyMDI.RuCDPDetail_CdpId) 
					FROM 
						MtMonthlyMDI 
						inner join RuCDPDetail CDP on MtMonthlyMDI.RuCDPDetail_CdpId=CDP.RuCDPDetail_CdpId AND 
							ISNULL(CDP.RuCDPDetail_ConnectedFromID,0) > 0 AND ISNULL(CDP.RuCDPDetail_ConnectedToID,0) > 0 
							AND CDP.RuCDPDetail_ConnectedFromID <> CDP.RuCDPDetail_ConnectedToID
						WHERE 
							MtMonthlyMDI.MtMonthlyMDI_Month=mbr1.MtMonthlyMDI_Month and
							MtMonthlyMDI.MtMonthlyMDI_Year=mbr1.MtMonthlyMDI_Year
					)

into #temp
FROM     MtMonthlyMDI mbr1-- MtBvmReading  mbr1
GROUP BY MtMonthlyMDI_Month,MtMonthlyMDI_Year

select * from #temp

--select * ,
--CASE
--	WHEN Month = MONTH(GETDATE()) AND Year = YEAR(GETDATE()) 
--		THEN CAST(CAST(totalRecords as decimal(18,5))/ CAST((totalCdpCount*DAY(GETDATE())*24) as Decimal(18,5)) as decimal(18,5))*100
--	ELSE
--		CAST(CAST(totalRecords as decimal(18,5))/ CAST((totalCdpCount*DAY(EOMONTH([MonthName]))*24) as Decimal(18,5)) as decimal(18,5))*100
--END as DataStatus
--from #Temp
--order by Year desc, Month desc
END
