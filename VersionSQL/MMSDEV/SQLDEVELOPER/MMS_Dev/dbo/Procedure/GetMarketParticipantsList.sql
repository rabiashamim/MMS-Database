/****** Object:  Procedure [dbo].[GetMarketParticipantsList]    Committed by VersionSQL https://www.versionsql.com ******/

  
--- author: Ammama   
--GetMarketParticipantsList 'EBPC'  
CREATE PROCEDURE dbo.GetMarketParticipantsList (@pcategoryCode VARCHAR(5))  
AS  
BEGIN  
  
 SELECT DISTINCT  
  mpr.MtPartyRegisteration_Id AS PartyRegistration_Id  
    ,mpr.MtPartyRegisteration_Name AS PartyRegistration_Name  
 FROM MtPartyRegisteration mpr  
 INNER JOIN MtPartyCategory mpc  
  ON mpc.MtPartyRegisteration_Id = mpr.MtPartyRegisteration_Id  
  where mpr.SrPartyType_Code in ('MP')   
 AND ISNULL(mpr.isDeleted, 0) = 0  
 AND ISNULL(mpc.isDeleted, 0) = 0  
 AND mpr.LuStatus_Code_Applicant IN ('AACT', 'APP')  
 AND ((@pcategoryCode IN ('EBPC', 'ECG', 'EGEN')  
 AND mpc.SrCategory_Code IN ('PAKT', 'INTT', 'BSUP','CSUP'))  
 OR (@pcategoryCode = 'DSP'  
 AND mpc.SrCategory_Code = 'BSUP'))  
  
END
