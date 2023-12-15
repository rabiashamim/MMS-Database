/****** Object:  Procedure [dbo].[GETMeteringDataList_bk23Aug2023]    Committed by VersionSQL https://www.versionsql.com ******/

    
 CREATE   PROCEDURE dbo.GETMeteringDataList_bk23Aug2023        
     
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
     AND CDP.RuCDPDetail_ConnectedFromID is not NULL    
     AND CDP.RuCDPDetail_ConnectedToID is not null    
     AND MtConnectedMeter_isDeleted=0    
    GROUP BY     
     MtCDPDetail_Id    
     ,CDP.RuCDPDetail_CdpId     
    --HAVING     
    -- count(MtCDPDetail_Id)=2     
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
     SELECT     
      COUNT(distinct MtBvmReading.RuCDPDetail_CdpId)     
     FROM     
      MtBvmReading     
      inner join MtMeteringImportInfo on MtBvmReading.MtMeteringImportInfo_Id=MtMeteringImportInfo.MtMeteringImportInfo_Id    
      inner join RuCDPDetail CDP on MtBvmReading.RuCDPDetail_CdpId=CDP.RuCDPDetail_CdpId AND     
       ISNULL(CDP.RuCDPDetail_ConnectedFromID,0) > 0 AND ISNULL(CDP.RuCDPDetail_ConnectedToID,0) > 0     
       AND CDP.RuCDPDetail_ConnectedFromID <> CDP.RuCDPDetail_ConnectedToID    
      LEFT JOIN MtConnectedMeter MC ON MC.MtCDPDetail_Id=CDP.RuCDPDetail_Id AND MC.IsAssigned=1 AND MC.MtConnectedMeter_isDeleted=0    
     WHERE MtBvmReading.MtMeteringImportInfo_Id = mmii.MtMeteringImportInfo_BatchNo    
     )    
from     
    
 MtMeteringImportInfo mmii    
    
 --join MtBvmReading mbr on mbr.MtMeteringImportInfo_Id=mmii.MtMeteringImportInfo_Id     
    
order by mmii.MtMeteringImportInfo_Id desc,mmii.MtMeteringImportInfo_BatchNo DESC, mmii.MtMeteringImportInfo_CreatedOn desc    
    
       
    END 
