/****** Object:  Procedure [dbo].[DataManagement_Read]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================        
-- Author:  ALINA JAVED      
-- CREATE date: 03 July 2023      
-- Description:       
-- =============================================       
 -- EXEC DataManagement_Read    
CREATE PROCEDURE DataManagement_Read      
AS      
BEGIN      
  SELECT   
    msfm.MtSOFileMaster_Id,  
    lft.LuSOFileTemplate_Id,  
    lft.LuSOFileTemplate_Name,  
    lam.LuAccountingMonth_Id,  
    lam.LuAccountingMonth_MonthName,  
    msfm.MtSOFileMaster_FileName,  
    CASE    
        WHEN lft.LuSOFileTemplate_Name = 'Data for Determination of Security Cover' THEN    
            CONCAT('Seller - ',    
                (  
                    SELECT CONCAT(PR.MtPartyRegisteration_Name, ' (', CAST(PR.MtPartyRegisteration_Id AS NVARCHAR(MAX)), ')')    
                    FROM MtPartyRegisteration PR    
                    WHERE pr.MtPartyRegisteration_Id IN (    
                        SELECT CAST(MTDeterminationSecurityCover_SellerID AS NVARCHAR(MAX))    
                        FROM MTDeterminationSecurityCover    
                        WHERE MTDeterminationSecurityCover.MtSOFileMaster_Id = msfm.MtSOFileMaster_Id  
                       UNION   
      SELECT TOP 1 MTDeterminationofSecurityCover_Interface_Seller_Id AS SellerID  
      FROM MTDeterminationofSecurityCover_Interface  
      WHERE MTDeterminationofSecurityCover_Interface.MtSOFileMaster_Id = msfm.MtSOFileMaster_Id  
      and MTDeterminationofSecurityCover_Interface_Seller_Id is not NULL or MTDeterminationofSecurityCover_Interface_Seller_Id <> ''  
    AND NOT EXISTS (  
     SELECT 1  
     FROM MTDeterminationSecurityCover  
     WHERE MTDeterminationSecurityCover.MtSOFileMaster_Id = msfm.MtSOFileMaster_Id  
    )     
                    )    
                ),    
                ' | Buyer - ',    
     (  
     SELECT CONCAT(PR.MtPartyRegisteration_Name, ' (', CAST(PR.MtPartyRegisteration_Id AS NVARCHAR(MAX)), ')')  
      FROM MtPartyRegisteration PR  
      WHERE PR.MtPartyRegisteration_Id IN (  
    SELECT CAST(MTDeterminationSecurityCover_BuyerID AS NVARCHAR(MAX))  
    FROM MTDeterminationSecurityCover  
    WHERE MTDeterminationSecurityCover.MtSOFileMaster_Id = msfm.MtSOFileMaster_Id  
    UNION   
    SELECT TOP 1 MTDeterminationofSecurityCover_Interface_Buyer_Id AS BuyerID  
    FROM MTDeterminationofSecurityCover_Interface  
    WHERE MTDeterminationofSecurityCover_Interface.MtSOFileMaster_Id = msfm.MtSOFileMaster_Id   
    and MTDeterminationofSecurityCover_Interface_Buyer_Id is not NULL or MTDeterminationofSecurityCover_Interface_Buyer_Id <> ''  
     AND NOT EXISTS (  
      SELECT 1  
      FROM MTDeterminationSecurityCover  
      WHERE MTDeterminationSecurityCover.MtSOFileMaster_Id = msfm.MtSOFileMaster_Id  
     )  
   )  
                )    
              )  
        ELSE ' '    
    END AS MtSOFileMaster_Description,    
    msfm.MtSOFileMaster_Version,  
    ls.LuStatus_Code,  
    ls.LuStatus_Name,  
    msfm.MtSOFileMaster_ApprovalStatus,  
    msfm.MtSOFileMaster_IsUseForSettlement,  
    msfm.MtSOFileMaster_FilePath,  
    msfm.MtSOFileMaster_CreatedOn  
FROM    
    MtSOFileMaster msfm    
    INNER JOIN LuSOFileTemplate lft ON lft.LuSOFileTemplate_Id = msfm.LuSOFileTemplate_Id    
    INNER JOIN LuAccountingMonth lam ON lam.LuAccountingMonth_Id = msfm.LuAccountingMonth_Id    
    INNER JOIN LuStatus ls ON ls.LuStatus_Code = msfm.LuStatus_Code    
WHERE    
    ISNULL(MtSOFileMaster_IsDeleted, 0) = 0    
ORDER BY    
    msfm.MtSOFileMaster_Id DESC       
END 
