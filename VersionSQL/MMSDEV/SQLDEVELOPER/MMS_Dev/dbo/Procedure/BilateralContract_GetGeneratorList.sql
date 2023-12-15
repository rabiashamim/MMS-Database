/****** Object:  Procedure [dbo].[BilateralContract_GetGeneratorList]    Committed by VersionSQL https://www.versionsql.com ******/

-- ================================================================================                  
-- Author:  Ammama Gill | Ali Imran                
-- CREATE date: 07 June, 2023                
-- ALTER date:                 
-- Description:                 
-- =================================================================================                 
--[BilateralContract_GetGeneratorList] 130            
  
  
CREATE   PROCEDUREdbo.BilateralContract_GetGeneratorList (@pBilateralContractId DECIMAL(18, 0) = NULL, @pFCCAMasterId DECIMAL(18, 0) = NULL)  
AS  
BEGIN  
  
 IF @pBilateralContractId <> 0  
 BEGIN  
  DECLARE @vSrCategory_Code VARCHAR(4)  
  ;  
  SELECT  
   @vSrCategory_Code = SrCategory_Code  
  FROM MtContractRegistration CR  
  INNER JOIN MtPartyCategory PC  
   ON CR.MtContractRegistration_SellerCategoryId = PC.MtPartyCategory_Id  
  WHERE CR.MtContractRegistration_Id = @pBilateralContractId;  
  
  
  
  IF @vSrCategory_Code in( 'GEN','EGEN')  
  BEGIN  
  
   SELECT  
   DISTINCT  
    G.MtGenerator_Id AS GeneratorId  
      ,G.MtGenerator_Name AS GeneratorName  
   FROM MtContractRegistration CR  
   INNER JOIN MtPartyCategory PC  
    ON CR.MtContractRegistration_SellerCategoryId = PC.MtPartyCategory_Id  
   INNER JOIN MtGenerator G  
    ON G.MtPartyCategory_Id = CR.MtContractRegistration_SellerCategoryId  
   WHERE MtContractRegistration_Id = @pBilateralContractId  
   AND ISNULL(MtContractRegistration_IsDeleted, 0) = 0  
   AND ISNULL(G.isDeleted, 0) = 0  
   AND ISNULL(MtGenerator_IsDeleted, 0) = 0  
   AND ISNULL(PC.isDeleted, 0) = 0  
  
  END  
  
  ELSE  
  BEGIN  
   DECLARE @vSellerId DECIMAL(18, 0);  
   SELECT  
    @vSellerId = MtContractRegistration_SellerId  
   FROM MtContractRegistration CR  
   WHERE MtContractRegistration_Id = @pBilateralContractId;  
  
   SELECT  
   DISTINCT  
    FCC.MtGenerator_Id AS GeneratorId  
      ,AG.Generator_Name AS GeneratorName  
   FROM MtFCCMaster FCC  
   INNER JOIN MtFCCDetails FCCD  
    ON FCC.MtFCCMaster_Id = FCCD.MtFCCMaster_Id  
   INNER JOIN vw_ActiveGenerator AG  
    ON AG.Generator_Id = FCC.MtGenerator_Id  
   WHERE MtFCCDetails_OwnerPartyId = @vSellerId  
  
  
  END  
 END  
  
 ELSE  
 IF @pFCCAMasterId <> 0  
 BEGIN  
  ;  
  WITH cte_FCCAGenerators  
  AS  
  (SELECT  
   DISTINCT  
    FCCAG.MtGenerator_Id  
   FROM MtFCCAMaster FCCA  
   INNER JOIN MtFCCAGenerator FCCAG  
    ON FCCA.MtFCCAMaster_Id = FCCAG.MtFCCAMaster_Id  
   WHERE FCCA.MtFCCAMaster_Id = @pFCCAMasterId)  
  
  SELECT  
   FCC.MtGenerator_Id AS GeneratorId  
     ,AG.Generator_Name AS GeneratorName  
  FROM cte_FCCAGenerators cFCCAG  
  INNER JOIN MtFCCMaster FCC  
   ON cFCCAG.MtGenerator_Id = FCC.MtGenerator_Id  
  INNER JOIN MtFCCDetails FCCD  
   ON FCC.MtFCCMaster_Id = FCCD.MtFCCMaster_Id  
  INNER JOIN vw_ActiveGenerator AG  
   ON AG.Generator_Id = FCC.MtGenerator_Id  
  WHERE ISNULL(MtFCCDetails_Status, 0) = 0  
  GROUP BY FCC.MtGenerator_Id  
    ,AG.Generator_Name  
 END  
END
