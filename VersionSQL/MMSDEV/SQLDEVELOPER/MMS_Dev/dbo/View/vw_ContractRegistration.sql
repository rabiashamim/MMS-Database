/****** Object:  View [dbo].[vw_ContractRegistration]    Committed by VersionSQL https://www.versionsql.com ******/

--exec WF_Get_ApprovalPopUp @ProcessId=108,@Process_Template_Id=1,@RuModules_Id=12,@level_id=1
--select * from vw_so
CREATE view vw_ContractRegistration
as

SELECT        
  SrContractType_Name   Contract_Type     
   , ((SELECT        
   MtPartyRegisteration_Name        
  FROM MtPartyRegisteration        
  WHERE MtPartyRegisteration_Id = MtContractRegistration_BuyerId)        
 + '-' + (SELECT        
   SrCategory_Name        
  FROM MtPartyCategory PC        
  INNER JOIN SrCategory C        
   ON PC.SrCategory_Code = C.SrCategory_Code        
  WHERE PC.MtPartyCategory_Id = MtContractRegistration_BuyerCategoryId)        
 )  Buyer_name_Category       
   , ((SELECT        
   MtPartyRegisteration_Name        
  FROM MtPartyRegisteration        
  WHERE MtPartyRegisteration_Id = MtContractRegistration_SellerId)        
 + '-' + (SELECT        
   SrCategory_Name        
  FROM MtPartyCategory PC        
  INNER JOIN SrCategory C        
   ON PC.SrCategory_Code = C.SrCategory_Code        
  WHERE PC.MtPartyCategory_Id = MtContractRegistration_SellerCategoryId)        
 )   Seller_name_Category     
   , 
   FORMAT(ISNULL(MtContractRegistration_ContractDate, ''), 'dd-MMM-yyyy')Contract_Registration_Date--MtContractRegistration_ContractDate    Contract_Registration_Date    
   ,
   FORMAT(ISNULL(MtContractRegistration_ApplicationDate, ''), 'dd-MMM-yyyy')Application_Date--MtContractRegistration_ApplicationDate   Application_Date       
   , 
  
   MtContractRegistration_ApplicationNubmer      ApplicationNumber   
   , FORMAT(ISNULL(MtContractRegistration_EffectiveFrom, ''), 'dd-MMM-yyyy') + '-' + FORMAT(ISNULL(MtContractRegistration_EffectiveTo, ''), 'dd-MMM-yyyy')ContractDuration        
   ,MtContractRegistration_Id     
FROM MtContractRegistration mpr        
INNER JOIN SrContractType CT        
 ON mpr.SrContractType_Id = ct.SrContractType_Id  
 where isnull(MtContractRegistration_IsDeleted,0)=0
