/****** Object:  Procedure [dbo].[FCCA_GetSummaryDetails]    Committed by VersionSQL https://www.versionsql.com ******/

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  
    
--  dbo.FCCA_GetSummaryDetails  27,1    
CREATE   PROCEDUREdbo.FCCA_GetSummaryDetails     
    
@pMtFCCAMaster_Id decimal(18,0),    
@pUserId int    
AS     
BEGIN    
  
DECLARE @Status AS VARCHAR(15)
	   ,@vPartyId DECIMAL(18, 0);
SELECT
	@Status = MtFCCAMaster_Status
   ,@vPartyId = MtPartyRegisteration_Id
FROM MtFCCAMaster
WHERE MtFCCAMaster_Id = @pMtFCCAMaster_Id;

IF @vPartyId = 1
BEGIN
	SELECT

		fccaG.MtFCCAMaster_Id
	   ,fccaG.MtFCCAGenerator_Id AS MtFCCAGenerator_Id
	   ,fccaD.MtFCCADetails_Id AS MtFCCADetails_Id
	   ,fccaD.MtContractRegistration_Id AS MtContractRegistration_Id
	   ,fccaD.MtPartyRegistration_BuyerId AS MtPartyRegistration_BuyerId
	   ,Buyer.MtPartyRegisteration_Name AS MtPartyRegistration_BuyerName
	   ,fccaG.MtGenerator_Id
	   ,Gen.MtGenerator_Name AS MtGenerator_Name
	   ,fccaD.MtFCCADetails_AllocationFactor AS MtFCCADetails_AllocationFactor
	   ,ROUND(fccaD.MtFCCADetails_AssociatedCapacity, 1) AS MtFCCADetails_AssociatedCapacity
	   ,CR.MtContractRegistration_EffectiveTo AS MtContractRegistration_ExpiryDate
	   ,FCCAA.MtFCCAAssigmentDetails_FromCertificate AS MtFCCADetails_FromCertificate
	   ,FCCAA.MtFCCAAssigmentDetails_ToCertificate AS MtFCCADetails_ToCertificate
	   ,(SELECT DISTINCT
				PR.MtPartyRegisteration_Name
			FROM MtFCCDetails FCCD
			INNER JOIN MtPartyRegisteration PR
				ON FCCD.MtFCCDetails_OwnerPartyId = PR.MtPartyRegisteration_Id
			WHERE FCCD.MtFCCDetails_CertificateId = FCCAA.MtFCCAAssigmentDetails_FromCertificate)
		AS CurrentOwner
	   ,
		--(select top 1 case when ( MtFCCDetails_Status) =1 then 'Blocked' else '' end from MtFCCDetails where MtFCCDetails_CertificateId=MtFCCADetails_FromCertificate)    
		--fccD.MtFCCDetails_Status as MtFCCADetails_Status    
		'Blocked'
		AS MtFCCADetails_Status

	FROM MtFCCAGenerator fccaG
	INNER JOIN MtFCCADetails fccaD
		ON fccaG.MtFCCAGenerator_Id = fccaD.MtFCCAGenerator_Id
	INNER JOIN MtPartyRegisteration Buyer
		ON Buyer.MtPartyRegisteration_Id = fccaD.MtPartyRegistration_BuyerId
	INNER JOIN MtGenerator Gen
		ON Gen.MtGenerator_Id = fccaG.MtGenerator_Id
	INNER JOIN MtContractRegistration CR
		ON fccaD.MtContractRegistration_Id = CR.MtContractRegistration_Id
	INNER JOIN MtFCCAAssigmentDetails FCCAA
		ON fccaD.MtFCCADetails_Id = FCCAA.MtFCCADetails_Id
	--inner join MtFCCDetails fccD on fccD.MtFCCDetails_CertificateId=fccaD.MtFCCADetails_FromCertificate    
	WHERE ISNULL(fccaG.MtFCCAGenerator_IsDeleted, 0) = 0
	AND ISNULL(fccaD.MtFCCADetails_IsDeleted, 0) = 0
	AND FCCAA.MtFCCAAssigmentDetails_IsDisabled = 0
	AND fccaG.MtFCCAMaster_Id = @pMtFCCAMaster_Id
	--AND CR.MtContractRegistration_Status = 'CATV'    
	ORDER BY fccaG.MtGenerator_Id,
	MtPartyRegistration_BuyerId

END

ELSE
BEGIN
	SELECT DISTINCT
		(SELECT
				MtPartyRegisteration_Name
			FROM MtPartyRegisteration PR
			WHERE MtPartyRegisteration_Id = CR.MtContractRegistration_BuyerId)
		AS MtPartyRegistration_BuyerName
	   ,CC.MtContractRegistration_Id
	   ,CR.MtContractRegistration_EffectiveTo AS MtContractRegistration_ExpiryDate
	   ,GP.MtGenerator_Id
	   ,GP.MtGenerator_Name
	   ,MtContractCertificates_FromCertificate AS MtFCCADetails_FromCertificate
	   ,MtContractCertificates_ToCertificate AS MtFCCADetails_ToCertificate
	   ,MtContractCertificates_AssociatedCapacity AS MtFCCADetails_AssociatedCapacity
	   ,(SELECT
				MtPartyRegisteration_Name
			FROM MtFCCDetails FCCD
			INNER JOIN MtPartyRegisteration PR
				ON FCCD.MtFCCDetails_OwnerPartyId = PR.MtPartyRegisteration_Id
			WHERE MtFCCDetails_CertificateId = MtContractCertificates_FromCertificate)
		AS CurrentOwner
	   ,'Blocked' AS MtFCCADetails_Status
	FROM MtFCCAMaster FCCA
	INNER JOIN MtContractCertificates CC
		ON FCCA.MtPartyRegisteration_Id = CC.GeneratorParty_Id
	INNER JOIN MtFCCDetails FCCD
		ON FCCD.MtFCCDetails_CertificateId = CC.MtContractCertificates_FromCertificate
	INNER JOIN MtFCCMaster fcc
		ON FCCD.MtFCCMaster_Id = fcc.MtFCCMaster_Id
	INNER JOIN vw_GeneratorParties GP
		ON GP.MtGenerator_Id = fcc.MtGenerator_Id
	INNER JOIN MtContractRegistration CR
		ON CR.MtContractRegistration_Id = CC.MtContractRegistration_Id
	WHERE CC.GeneratorParty_Id = @vPartyId
	AND FCCA.MtFCCAMaster_Id = @pMtFCCAMaster_Id
	AND MtContractCertificates_IsDeleted = 0
	AND MtContractRegistration_IsDeleted = 0
	AND ISNULL(CC.MtContractCertificates_IsDisabled, 0) = 0


END
--END    
    END
