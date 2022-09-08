/****** Object:  Procedure [dbo].[GETMDIDataList]    Committed by VersionSQL https://www.versionsql.com ******/

 CREATE PROCEDURE [dbo].[GETMDIDataList]    
 
 AS    
 BEGIN  

 


select  
	 mmii.MtMDIImportInfo_Id
	,mmii.MtMDIImportInfo_BatchNo
  
   ,totalCdps=(
				select  
					COUNT(DISTINCT mbr1.RuCDPDetail_CdpId) 
				from 
					MtMonthlyMDI mbr1 
				where 
					mbr1.MtMDIImportInfo_Id=mmii.MtMDIImportInfo_Id)
    ,bvmRecords=(
				select count(1) from MtMonthlyMDI mbr2 where mbr2.MtMDIImportInfo_Id=mmii.MtMDIImportInfo_Id)
    
	,mmii.MtMDIImportInfo_CreatedOn
	 ,connectedCDPs=(
					SELECT 
						COUNT(distinct MtMonthlyMDI.RuCDPDetail_CdpId) 
					FROM 
						MtMonthlyMDI 
						inner join MtMDIImportInfo on MtMDIImportInfo.MtMDIImportInfo_Id= MtMonthlyMDI.MtMDIImportInfo_Id 
						inner join RuCDPDetail CDP on MtMonthlyMDI.RuCDPDetail_CdpId=CDP.RuCDPDetail_CdpId AND 
							ISNULL(CDP.RuCDPDetail_ConnectedFromID,0) > 0 AND ISNULL(CDP.RuCDPDetail_ConnectedToID,0) > 0 
							AND CDP.RuCDPDetail_ConnectedFromID <> CDP.RuCDPDetail_ConnectedToID
						LEFT JOIN MtConnectedMeter MC ON MC.MtCDPDetail_Id=CDP.RuCDPDetail_Id AND MC.IsAssigned=1 AND MC.MtConnectedMeter_isDeleted=0
					WHERE MtMonthlyMDI.MtMDIImportInfo_Id  = mmii.MtMDIImportInfo_BatchNo
					)
from 

 MtMDIImportInfo mmii

order by mmii.MtMDIImportInfo_Id desc,mmii.MtMDIImportInfo_BatchNo DESC, mmii.MtMDIImportInfo_CreatedOn desc

   
    END
