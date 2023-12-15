/****** Object:  Procedure [dbo].[GetSettlementPeriod]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================            
-- Author:  Sadaf Malik        
-- CREATE date: Dec 1, 2022           
-- ALTER date:  19/12/2022 (Ammama)         
-- Reviewer:  Ali Imran | Kapil        
-- Description:           
-- =============================================          
-- GetSettlementPeriod 3  
CREATE
PROCEDURE dbo.GetSettlementPeriod @pLuSoFileTemplateId INT  
  
AS  
BEGIN  
  
 DECLARE @vPeriodType AS INT;  
 SELECT  
  @vPeriodType = LuSOFileTemplate_PeriodType  
 FROM LuSOFileTemplate  
 WHERE LuSOFileTemplate_Id = @pLuSoFileTemplateId  
  
  
 SELECT  
  LuAccountingMonth_Id  
    ,  
  --  ,CASE    
  -- WHEN @pLuSoFileTemplateId IN (9, 10, 11) THEN CAST(LuAccountingMonth_Year AS VARCHAR(20))    
  -- ELSE LuAccountingMonth_MonthName    
  --END    
  --AS   
  LuAccountingMonth_MonthName  
 FROM LuAccountingMonth  
 WHERE   
 LuStatus_Code = 'OPEN'  
 --OR   
 --LuStatus_Code = 'CLSD')  
 AND LuAccountingMonth_IsDeleted = 0  
 AND PeriodTypeID = (SELECT  
   LuSOFileTemplate_PeriodType  
  FROM LuSOFileTemplate  
  WHERE LuSOFileTemplate_Id = @pLuSoFileTemplateId)  
  
 --CASE    
 -- WHEN @pLuSoFileTemplateId IN (9, 10, 11,12) THEN '2'    
 -- ELSE '1'    
 --END    
 ORDER BY 1  
  
END
