/****** Object:  Procedure [dbo].[FCCA_GetSummaryDetailsHistory]    Committed by VersionSQL https://www.versionsql.com ******/

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--  dbo.FCCA_GetSummaryDetailsHistory 20,1
CREATE     Procedure dbo.FCCA_GetSummaryDetailsHistory

@pMtFCCAMaster_Id decimal(18,0),
@pUserId int
AS 
BEGIN
  

select 
distinct
fccaG.MtFCCAMaster_Id,
--fccaG.MtFCCAGenerator_Id as MtFCCAGenerator_Id,
fccaD.MtFCCADetails_Id as MtFCCADetails_Id,
fccaD.MtContractRegistration_Id as MtContractRegistration_Id,
fccaD.MtPartyRegistration_BuyerId as MtPartyRegistration_BuyerId,
Buyer.MtPartyRegisteration_Name as  MtPartyRegistration_BuyerName,
fccaG.MtGenerator_Id,
Gen.MtGenerator_Name as MtGenerator_Name,
fccaD.MtFCCADetails_AllocationFactor as MtFCCADetails_AllocationFactor,
fccaD.MtFCCADetails_AssociatedCapacity as MtFCCADetails_AssociatedCapacity,
CR.MtContractRegistration_EffectiveTo as MtContractRegistration_ExpiryDate,
fccadh.MtFCCAAssigmentDetails_FromCertificate as MtFCCADetails_FromCertificate
,fccadh.MtFCCAAssigmentDetails_ToCertificate as MtFCCADetails_ToCertificate,
(select top 1 case when ( MtFCCDetails_Status) =1 then 'Blocked' else 'Available' end from MtFCCDetails where MtFCCDetails_CertificateId=fccadh.MtFCCAAssigmentDetails_FromCertificate)

as MtFCCADetails_Status,
[MtFCCADetailsHistory_CreatedDate] as HistoryCreatedDate

from
MtFCCAGeneratorHistory fccaG 
inner join MtFCCADetailsHistory fccaD on fccaG.MtFCCAGenerator_Id=fccaD.MtFCCAGenerator_Id
inner join MtPartyRegisteration Buyer on Buyer.MtPartyRegisteration_Id=fccaD.MtPartyRegistration_BuyerId
inner join MtGenerator Gen on Gen.MtGenerator_Id=fccaG.MtGenerator_Id
inner join MtContractRegistration CR on fccaD.MtContractRegistration_Id=CR.MtContractRegistration_Id
inner join  [dbo].[MtFCCAAssigmentDetailsHistory] fccadh on fccad.MtFCCADetails_Id = fccadh.MtFCCADetails_Id
--inner join MtFCCDetails fccD on fccD.MtFCCDetails_CertificateId=fccaD.MtFCCADetails_FromCertificate
where 
isnull(fccaG.MtFCCAGenerator_IsDeleted,0)=0
and ISNULL(fccaD.MtFCCADetails_IsDeleted,0)=0
and fccaG.MtFCCAMaster_Id=@pMtFCCAMaster_Id


 union 

 SELECT
	@pMtFCCAMaster_Id,
	CC.MtContractCertificates_Id AS MtFCCADetails_Id
   ,CC.MtContractRegistration_Id AS MtContractRegistration_Id
   ,CR.MtContractRegistration_BuyerId AS MtPartyRegistration_BuyerId
   ,(SELECT
			MtPartyRegisteration_Name
		FROM MtPartyRegisteration
		WHERE MtPartyRegisteration_Id = CR.MtContractRegistration_BuyerId)
	AS MtPartyRegistration_BuyerName
   ,CC.MtContractCertificates_Generator_Id AS MtGenerator_Id
   ,(SELECT
			MtGenerator_Name
		FROM MtGenerator
		WHERE MtGenerator_Id = CC.MtContractCertificates_Generator_Id)
	AS MtGenerator_Name
   ,NULL AS allocationFactor
   ,CC.MtContractCertificates_AssociatedCapacity AS MtFCCADetails_AssociatedCapacity
   ,CR.MtContractRegistration_EffectiveTo AS MtContractRegistration_ExpiryDate
   ,MtContractCertificates_FromCertificate AS MtFCCADetails_FromCertificate
   ,MtContractCertificates_ToCertificate AS MtFCCADetails_ToCertificate
   ,(SELECT TOP 1
			CASE
				WHEN (MtFCCDetails_Status) = 1 THEN 'Blocked'
				ELSE 'Available'
			END
		FROM MtFCCDetails
		WHERE MtFCCDetails_CertificateId = MtContractCertificates_FromCertificate)

	AS MtFCCADetails_Status
   ,CC.MtContractCertificates_DisabledDate AS HistoryCreatedDate
FROM MtContractCertificates CC
INNER JOIN MtContractRegistration CR
	ON CC.MtContractRegistration_Id = CR.MtContractRegistration_Id
INNER JOIN MtFCCADetails FCCAD
	ON FCCAD.MtContractRegistration_Id = CC.MtContractRegistration_Id
INNER JOIN MtFCCAGenerator fccag
	ON fccag.MtFCCAGenerator_Id = FCCAD.MtFCCAGenerator_Id
WHERE MtContractCertificates_IsDisabled = 1
AND MtFCCAMaster_Id = @pMtFCCAMaster_Id

order by MtFCCADetails_Id asc

END
