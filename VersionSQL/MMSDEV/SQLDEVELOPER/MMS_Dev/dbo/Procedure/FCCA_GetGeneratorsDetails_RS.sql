/****** Object:  Procedure [dbo].[FCCA_GetGeneratorsDetails_RS]    Committed by VersionSQL https://www.versionsql.com ******/

---- FCCA_GetGeneratorsDetails_RS 15,1  
--select * from MtFCCAMaster
CREATE Procedure dbo.FCCA_GetGeneratorsDetails_RS   
@pMtFCCAMaster_Id decimal(18,0),  
@pUserId int  
AS   
BEGIN  
  
  
Declare @Status as varchar(15)
select @Status=MtFCCAMaster_Status
from MtFCCAMaster where MtFCCAMaster_Id=@pMtFCCAMaster_Id;  

--declare @MtFCCMaster_Id decimal(18,0),@MtFCCMaster_RefernceId decimal(18,0)
--,@latestApproved_MtFCCMaster_Id decimal(18,0)
--select @MtFCCMaster_Id=MtFCCMaster_Id from MtFCCAGenerator where MtFCCAMaster_Id=@pMtFCCAMaster_Id;  
--/*get latest Approved FCC master ID where referenceID is the FCC ID of this FCCA*/
--select @latestApproved_MtFCCMaster_Id=max(MtFCCMaster_Id)
--from MtFCCMaster where MtFCCMaster_RefernceId=@MtFCCMaster_Id
--and LuStatus_Code='Completed' and MtFCCMaster_ApprovalCode='Approved'



if(@Status='New' or @Status='Reverted')  
BEGIN  
  
/* select   
 distinct  
 MtFCCAMaster_KEShare  
 ,MtFCCAMaster_ApprovalStatus  
 ,f.MtPartyRegisteration_Id  
 ,MtFCCAMaster_Id  
 ,v.MtGenerator_Name  
from MtFCCAMaster f  
inner join vw_GeneratorParties v on v.MtPartyRegisteration_Id=f.MtPartyRegisteration_Id  
  
where MtFCCAMaster_Id=@pMtFCCAMaster_Id  
and ISNULL(MtFCCAMaster_IsDeleted,0)=0  
*/  
  
;  WITH cte_LatestFCC  
  AS  
  (SELECT  
    ROW_NUMBER() OVER (PARTITION BY FCC.MtGenerator_Id ORDER BY FCC.MtFCCMaster_Id DESC) AS row_number  
      ,FCC.MtGenerator_Id  
      ,GP.MtGenerator_Name  
      ,FCC.MtFCCMaster_Id  
      ,FCDG.MtFCDGenerators_InitialFirmCapacity  
   FROM MtFCCMaster FCC  
   INNER JOIN MtFCDGenerators FCDG  
    ON FCC.MtFCDMaster_Id = FCDG.MtFCDMaster_Id  
   INNER JOIN vw_GeneratorParties GP  
    ON GP.MtPartyRegisteration_Id = FCC.MtPartyRegistration_Id  
    AND GP.MtGenerator_Id = FCC.MtGenerator_Id  
   WHERE FCC.MtFCCMaster_TotalCertificates IS NOT NULL  
   AND FCDG.MtFCDGenerators_InitialFirmCapacity IS NOT NULL  
   AND FCC.MtFCCMaster_IsDeleted = 0  
   AND FCDG.MtFCDGenerators_IsDeleted = 0  
   AND FCC.MtFCCMaster_ApprovalCode = 'Approved'  
   )  
  
   SELECT  
    @pMtFCCAMaster_Id  
      ,cte.MtFCCMaster_Id  
      ,cte.MtGenerator_Id  
      ,cte.MtGenerator_Name as MtGenerator_Name  
      ,cte.MtFCDGenerators_InitialFirmCapacity as MtFCCMaster_InitialFirmCapacity  
      , t.MtFCCMaster_Start as MtFCCMaster_Start  
      ,t.MtFCCMaster_End  
      ,t.MtFCCMaster_FccCount 
	  ,ToBeCancelecount
	  ,ToBeCanceledate
   FROM cte_LatestFCC cte  
  
   inner join  
   (select fccM.MtFCCMaster_Id,MtGenerator_Id,min(MtFCCDetails_CertificateId) as MtFCCMaster_Start  
   ,max(MtFCCDetails_CertificateId) as MtFCCMaster_End  
   , count(1) as MtFCCMaster_FccCount
   ,sum(MtFCCDetails_ToBeCanceledFlag)ToBeCancelecount
   ,max(MtFCCDetails_ToBeCanceledDate)ToBeCanceledate
   from MtFCCDetails fccD  
   inner join MtFCCMaster fccM on fccM.MtFCCMaster_Id=fccD.MtFCCMaster_Id  
      group by fccM.MtFCCMaster_Id, fccM.MtGenerator_Id) as t  
      on t.MtGenerator_Id=cte.MtGenerator_Id  
      and t.MtFCCMaster_Id=cte.MtFCCMaster_Id  
  
   WHERE row_number = 1;  
  
END  
  
ELSE  
BEGIN  
    ;    WITH cte_GetFCCDetails  
        AS  
        (  
Select fccD.MtFCCMaster_Id, min(fccD.MtFCCDetails_CertificateId) as MinimumCertificate,  
max(fccD.MtFCCDetails_CertificateId) as MaximumCertificate,  
fccM.MtGenerator_Id  
,fccM.MtFCCMaster_InitialFirmCapacity  
,count(1) as MtFCCMaster_FccCount  
,RIGHT(min(fccD.MtFCCDetails_CertificateId), CHARINDEX('-',REVERSE(min(fccD.MtFCCDetails_CertificateId)))-1)  
 as FromCertificates  
,RIGHT(max(fccD.MtFCCDetails_CertificateId), CHARINDEX('-',REVERSE(max(fccD.MtFCCDetails_CertificateId)))-1)  
 as ToCertificates  
,sum(MtFCCDetails_ToBeCanceledFlag)ToBeCancelecount
,max(MtFCCDetails_ToBeCanceledDate)ToBeCanceledate
 from MtFCCDetails fccD  
inner join(  
   SELECT  
                ROW_NUMBER() OVER (PARTITION BY FCDG.MtGenerator_Id ORDER BY FCDG.MtFCDMaster_Id DESC) AS row_number  
        ,MtFCCMaster_Id  
               ,FCDG.MtGenerator_Id  
               ,FCDG.MtFCCMaster_InitialFirmCapacity  
            FROM MtFCCMaster FCDG  
    where ISNULL(MtFCCMaster_IsDeleted,0)=0  
    ) as fccM on fccM.MtFCCMaster_Id=fccD.MtFCCMaster_Id  
    and fccM.row_number=1  
where ISNULL(MtFCCDetails_IsDeleted,0)=0  
group by fccD.MtFCCMaster_Id, fccM.MtGenerator_Id  
,fccM.MtFCCMaster_InitialFirmCapacity  
)  
  
select   
distinct  
fcc.MtFCCMaster_Id ,  
fcc.MinimumCertificate as MtFCCMaster_Start,  
fcc.MaximumCertificate as MtFCCMaster_End,  
fcc.MtGenerator_Id,  
fcc.MtFCCMaster_FccCount,  
fcc.MtFCCMaster_InitialFirmCapacity,  
gen.MtGenerator_Name,  
fcca.MtFCCAGenerator_KEShare,  
fcca.MtFCCAGenerator_WithoutKE,  
fccaD.MtFCCADetails_FromCertificate as FromCertificates,  
fccaD.MtFCCADetails_ToCertificate as ToCertificates
,ToBeCancelecount
,ToBeCanceledate
from cte_GetFCCDetails fcc  
inner join MtFCCAGenerator fcca on fcca.MtGenerator_Id=fcc.MtGenerator_Id  
inner join MtGenerator gen on gen.MtGenerator_Id=fcc.MtGenerator_Id  
inner join MtFCCADetails fccaD on fccaD.MtFCCAGenerator_Id=fcca.MtFCCAGenerator_Id  
and MtPartyRegistration_BuyerId not in (  
select MtPartyRegisteration_Id from MtPartyRegisteration where MtPartyRegisteration_IsKE=1  
)  
  
where   
fcca.MtFCCAMaster_Id=@pMtFCCAMaster_Id  
and ISNULL(isDeleted,0)=0  
and ISNULL(MtGenerator_IsDeleted,0)=0  
and ISNULL(MtFCCAGenerator_IsDeleted,0)=0  
END  
END
