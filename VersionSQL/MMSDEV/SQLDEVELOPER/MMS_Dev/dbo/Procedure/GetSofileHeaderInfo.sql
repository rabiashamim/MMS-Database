/****** Object:  Procedure [dbo].[GetSofileHeaderInfo]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================    
-- Author:  ALI | AMMAMA  
-- CREATE date: 6 Dec 2022  
-- ALTER date:    
-- Description:   
-- Reviewer               
-- =============================================   
-- GetSofileHeaderInfo 611  
CREATE   PROCEDURE dbo.GetSofileHeaderInfo  
@pSofileMasterId DECIMAL(18,0)  
AS  
BEGIN  
SELECT  
 msfm.MtSOFileMaster_Id  
   ,msfm.LuSOFileTemplate_Id  
   ,lft.LuSOFileTemplate_Name  
   ,lam.LuAccountingMonth_Id  
   ,lam.LuAccountingMonth_Month  
   ,lam.LuAccountingMonth_Year  
   ,MtSOFileMaster_Description  
   ,LuAccountingMonth_MonthName  
   ,MtSOFileMaster_FileName  
   ,msfm.LuStatus_Code  
   ,MtSOFileMaster_IsUseForSettlement  
   ,MtSOFileMaster_FilePath  
   ,MtSOFileMaster_CreatedOn  
   ,LuStatus_Name  
   ,LuAccountingMonth_FromDate  
   ,MtSOFileMaster_Version  
   ,InvalidRecords  
   ,TotalRecords  
   ,MtSOFileMaster_ApprovalStatus  
   ,ldc.LuDataConfiguration_Name  ,
   msfm.MtSOFileMaster_Validations
   ,msfm.LuDataConfiguration_Id
FROM MtSOFileMaster msfm  
INNER JOIN LuSOFileTemplate lft  
 ON lft.LuSOFileTemplate_Id = msfm.LuSOFileTemplate_Id  
INNER JOIN LuDataConfiguration ldc  
 ON ldc.LuDataConfiguration_Id = msfm.LuDataConfiguration_Id  
INNER JOIN LuAccountingMonth lam  
 ON lam.LuAccountingMonth_Id = msfm.LuAccountingMonth_Id  
INNER JOIN LuStatus ls  
 ON ls.LuStatus_Code = msfm.LuStatus_Code  
WHERE MtSOFileMaster_Id = @pSofileMasterId  
  
END
