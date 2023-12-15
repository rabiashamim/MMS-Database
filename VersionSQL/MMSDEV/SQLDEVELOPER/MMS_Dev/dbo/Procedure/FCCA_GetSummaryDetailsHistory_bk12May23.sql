/****** Object:  Procedure [dbo].[FCCA_GetSummaryDetailsHistory_bk12May23]    Committed by VersionSQL https://www.versionsql.com ******/

--  [dbo].[FCCA_GetSummaryDetailsHistory] 2,1
create     Procedure dbo.FCCA_GetSummaryDetailsHistory_bk12May23

@pMtFCCAMaster_Id decimal(18,0),
@pUserId int
AS 
BEGIN
  

select 

fccaG.MtFCCAMaster_Id,
fccaG.MtFCCAGenerator_Id as MtFCCAGenerator_Id,
fccaD.MtFCCADetails_Id as MtFCCADetails_Id,
fccaD.MtContractRegistration_Id as MtContractRegistration_Id,
fccaD.MtPartyRegistration_BuyerId as MtPartyRegistration_BuyerId,
Buyer.MtPartyRegisteration_Name as  MtPartyRegistration_BuyerName,
fccaG.MtGenerator_Id,
Gen.MtGenerator_Name as MtGenerator_Name,
fccaD.MtFCCADetails_AllocationFactor as MtFCCADetails_AllocationFactor,
fccaD.MtFCCADetails_AssociatedCapacity as MtFCCADetails_AssociatedCapacity,
CR.MtContractRegistration_EffectiveTo as MtContractRegistration_ExpiryDate,
fccaD.MtFCCADetails_FromCertificate as MtFCCADetails_FromCertificate,
fccaD.MtFCCADetails_ToCertificate as MtFCCADetails_ToCertificate,
--(select top 1 case when ( MtFCCDetails_Status) =1 then 'Blocked' else '' end from MtFCCDetails where MtFCCDetails_CertificateId=MtFCCADetails_FromCertificate)
case when fccD.MtFCCDetails_Status=0 then 'Blocked' else 'Available' end
--'Blocked'
as MtFCCADetails_Status
from
MtFCCAGeneratorHistory fccaG 
inner join MtFCCADetailsHistory fccaD on fccaG.MtFCCAGenerator_Id=fccaD.MtFCCAGenerator_Id
inner join MtPartyRegisteration Buyer on Buyer.MtPartyRegisteration_Id=fccaD.MtPartyRegistration_BuyerId
inner join MtGenerator Gen on Gen.MtGenerator_Id=fccaG.MtGenerator_Id
inner join MtContractRegistration CR on fccaD.MtContractRegistration_Id=CR.MtContractRegistration_Id
inner join MtFCCDetails fccD on fccD.MtFCCDetails_CertificateId=fccaD.MtFCCADetails_FromCertificate
where 
isnull(fccaG.MtFCCAGenerator_IsDeleted,0)=0
and ISNULL(fccaD.MtFCCADetails_IsDeleted,0)=0
and fccaG.MtFCCAMaster_Id=@pMtFCCAMaster_Id;


END
