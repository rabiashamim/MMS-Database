/****** Object:  Procedure [dbo].[GETMeteringDataList_bk_29_03_2022]    Committed by VersionSQL https://www.versionsql.com ******/

 CREATE PROCEDURE [dbo].[GETMeteringDataList_bk_29_03_2022]    
 
 AS    
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
 
select  
	 mmii.MtMeteringImportInfo_Id
	,mmii.MtMeteringImportInfo_BatchNo
  
   ,totalCdps=(
				select  
					COUNT(DISTINCT mbr1.RuCDPDetail_CdpId) 
				from 
					MtBvmReading mbr1 
				where 
					mbr1.MtMeteringImportInfo_Id=mmii.MtMeteringImportInfo_Id)
    ,bvmRecords=(
				select count(1) from MtBvmReading mbr2 where mbr2.MtMeteringImportInfo_Id=mmii.MtMeteringImportInfo_Id)
    
	,mmii.MtMeteringImportInfo_CreatedOn
	 ,connectedCDPs=(
						Select 
							count(distinct(RuCDPDetail_CdpId)) 
						FROM 
						    MtBvmReading 
						WHERE 
							MtMeteringImportInfo_Id=mmii.MtMeteringImportInfo_Id
						AND RuCDPDetail_CdpId IN
							(SELECT RuCDPDetail_CdpId FROM #ConnectedCDPs)
					)
from 

	MtMeteringImportInfo mmii

 --join MtBvmReading mbr on mbr.MtMeteringImportInfo_Id=mmii.MtMeteringImportInfo_Id 

order by mmii.MtMeteringImportInfo_Id desc,mmii.MtMeteringImportInfo_BatchNo DESC, mmii.MtMeteringImportInfo_CreatedOn desc

   
    END
