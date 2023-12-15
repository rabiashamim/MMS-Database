/****** Object:  Procedure [dbo].[ContractReg_FCCSummaryDetails]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE dbo.ContractReg_FCCSummaryDetails @pMtContractRegistration_Id DECIMAL(18, 0),  
@pUserId INT  
AS  
BEGIN  
  
 DECLARE @vIsLegacy BIT = 0;  
  
 SELECT  
  @vIsLegacy =  
  CASE  
   WHEN MtContractRegistration_SellerId = 1 THEN 1 --treat this differently for legacy    
   ELSE 0  
  END  
 FROM MtContractRegistration CR  
 WHERE MtContractRegistration_Id = @pMtContractRegistration_Id  
  
 IF @vIsLegacy = 1  
 BEGIN  
  
  
  SELECT  
  DISTINCT  
   --Buyer.MtPartyRegisteration_Name AS MtPartyRegistration_BuyerName    
   --,fccaD.MtContractRegistration_Id AS MtContractRegistration_Id    
   --,CR.MtContractRegistration_EffectiveTo AS MtContractRegistration_ExpiryDate    
   fccaD.MtFCCADetails_AllocationFactor AS MtFCCADetails_AllocationFactor  
     ,ROUND(fccaD.MtFCCADetails_AssociatedCapacity, 1) AS MtFCCADetails_AssociatedCapacity  
     ,Gen.MtGenerator_Name AS MtGenerator_Name  
     ,Gen.MtGenerator_Id AS MtGenerator_Id  
     ,fccaad.MtFCCAAssigmentDetails_FromCertificate AS MtFCCADetails_FromCertificate  
     ,fccaad.MtFCCAAssigmentDetails_ToCertificate AS MtFCCADetails_ToCertificate  
     ,'Blocked'  
   AS MtFCCADetails_Status  
     ,(SELECT  
     MIN(FCCD.MtFCCDetails_CertificateId)  
    FROM MtFCCDetails FCCD  
    INNER JOIN MtFCCMaster FCC  
     ON FCCD.MtFCCMaster_Id = FCC.MtFCCMaster_Id  
    WHERE FCC.MtGenerator_Id = Gen.MtGenerator_Id  
    AND ISNULL(FCC.MtFCCMaster_IsDeleted, 0) = 0  
    AND ISNULL(FCCD.MtFCCDetails_IsDeleted, 0) = 0)  
   AS  
   start_CertificateId  
     ,(SELECT  
     MAX(FCCD.MtFCCDetails_CertificateId)  
    FROM MtFCCDetails FCCD  
    INNER JOIN MtFCCMaster FCC  
     ON FCCD.MtFCCMaster_Id = FCC.MtFCCMaster_Id  
    WHERE FCC.MtGenerator_Id = Gen.MtGenerator_Id  
    AND ISNULL(FCC.MtFCCMaster_IsDeleted, 0) = 0  
    AND ISNULL(FCCD.MtFCCDetails_IsDeleted, 0) = 0)  
   AS end_CertificateId  
     ,ISNULL(MtFCCAAssigmentDetails_IsDisabled, 0) AS IsDisabledRow  
     ,MtFCCAAssigmentDetails_Id  
     ,MtFCCAAssigmentDetails_DisabledDate  
     ,MtFCCAAssigmentDetails_OwnerPartyId AS OwnerPartyId  
     ,(SELECT  
     MtPartyRegisteration_Name  
    FROM MtPartyRegisteration  
    WHERE MtPartyRegisteration_Id = MtFCCAAssigmentDetails_OwnerPartyId)  
   AS OwnerPartyName  
  FROM MtFCCAGenerator fccaG  
  INNER JOIN MtFCCADetails fccaD  
   ON fccaG.MtFCCAGenerator_Id = fccaD.MtFCCAGenerator_Id  
  INNER JOIN MtPartyRegisteration Buyer  
   ON Buyer.MtPartyRegisteration_Id = fccaD.MtPartyRegistration_BuyerId  
  INNER JOIN MtGenerator Gen  
   ON Gen.MtGenerator_Id = fccaG.MtGenerator_Id  
  INNER JOIN MtContractRegistration CR  
   ON fccaD.MtContractRegistration_Id = CR.MtContractRegistration_Id  
  LEFT JOIN MtFCCDetails fccD  
   ON fccD.MtFCCMaster_Id = fccaG.MtFCCMaster_Id  
  LEFT JOIN MtFCCAAssigmentDetails fccaad  
   ON fccaad.MtFCCADetails_Id = fccaD.MtFCCADetails_Id  
  WHERE ISNULL(fccaG.MtFCCAGenerator_IsDeleted, 0) = 0  
  AND ISNULL(fccaD.MtFCCADetails_IsDeleted, 0) = 0  
  AND CR.MtContractRegistration_Id = @pMtContractRegistration_Id  
  ORDER BY IsDisabledRow ASC,  
  Gen.MtGenerator_Id DESC,  
  MtFCCAAssigmentDetails_Id DESC  
  
 END  
 ELSE  
 BEGIN  
  SELECT DISTINCT  
   MtContractCertificates_AssociatedCapacity AS MtFCCADetails_AssociatedCapacity  
     ,NULL AS MtFCCADetails_AllocationFactor  
     ,CC.MtContractCertificates_FromCertificate AS MtFCCADetails_FromCertificate  
     ,CC.MtContractCertificates_ToCertificate AS MtFCCADetails_ToCertificate  
     ,FCC.MtGenerator_Id AS MtGenerator_Id  
     ,(SELECT  
     GP.MtGenerator_Name  
    FROM vw_GeneratorParties GP  
    WHERE GP.MtGenerator_Id = FCC.MtGenerator_Id)  
   AS MtGenerator_Name  
     ,(SELECT  
     MIN(FCCD.MtFCCDetails_CertificateId)  
    FROM MtFCCDetails FCCD  
    INNER JOIN MtFCCMaster FCCL  
     ON FCCD.MtFCCMaster_Id = FCC.MtFCCMaster_Id  
    WHERE FCCL.MtGenerator_Id = FCC.MtGenerator_Id  
    AND ISNULL(FCC.MtFCCMaster_IsDeleted, 0) = 0  
    AND ISNULL(FCCD.MtFCCDetails_IsDeleted, 0) = 0)  
   AS  
   start_CertificateId  
     ,(SELECT  
     MAX(FCCD.MtFCCDetails_CertificateId)  
    FROM MtFCCDetails FCCD  
    INNER JOIN MtFCCMaster FCCL  
     ON FCCD.MtFCCMaster_Id = FCC.MtFCCMaster_Id  
    WHERE FCCL.MtGenerator_Id = FCC.MtGenerator_Id  
    AND ISNULL(FCC.MtFCCMaster_IsDeleted, 0) = 0  
    AND ISNULL(FCCD.MtFCCDetails_IsDeleted, 0) = 0)  
   AS end_CertificateId  
  
     ,(SELECT  
     MtPartyRegisteration_Name  
    FROM MtPartyRegisteration  
    WHERE MtPartyRegisteration_Id = FCCD.MtFCCDetails_OwnerPartyId)  
   AS OwnerPartyName  
     ,'Blocked' AS MtFCCADetails_Status  
     ,ISNULL(CC.MtContractCertificates_IsDisabled, 0) AS IsDisabledRow  
     ,CC.MtContractCertificates_Id AS MtFCCAAssigmentDetails_Id  
     ,CC.MtContractCertificates_DisabledDate AS MtFCCAAssigmentDetails_DisabledDate  
     ,FCCD.MtFCCDetails_OwnerPartyId AS OwnerPartyId  
  FROM MtContractRegistration CR  
  INNER JOIN MtContractCertificates CC  
   ON CR.MtContractRegistration_Id = CC.MtContractRegistration_Id  
  INNER JOIN MtFCCDetails FCCD  
   ON FCCD.MtFCCDetails_CertificateId = CC.MtContractCertificates_FromCertificate  
  INNER JOIN MtFCCMaster FCC  
   ON FCC.MtFCCMaster_Id = FCCD.MtFCCMaster_Id  
  WHERE CC.MtContractRegistration_Id = @pMtContractRegistration_Id  
  
  ORDER BY IsDisabledRow ASC,  
  FCC.MtGenerator_Id DESC,  
  CC.MtContractCertificates_Id DESC  
 --END    
  
 END  
END
