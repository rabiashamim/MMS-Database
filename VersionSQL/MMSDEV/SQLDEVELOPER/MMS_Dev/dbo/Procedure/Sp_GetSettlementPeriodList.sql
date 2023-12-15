/****** Object:  Procedure [dbo].[Sp_GetSettlementPeriodList]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================        
-- Author:  <Aymen Khalid>        
-- Create date: <24-01-2022>        
-- Description: <Read the Grid for Settlement Period Dashboard >        
-- =============================================        
CREATE PROCEDURE dbo.Sp_GetSettlementPeriodList        
 -- Add the parameters for the stored procedure here        
   
        
AS        
BEGIN        
 -- SET NOCOUNT ON added to prevent extra result sets from        
 -- interfering with SELECT statements.        
 SET NOCOUNT ON;        
        
SELECT  LuAccountingMonth_Id,  
  LuAccountingMonth_Month      ,  
  LuAccountingMonth_MonthName  ,  
  LuAccountingMonth_Year       ,  
  LuAccountingMonth_CreatedBy  ,  
  LuAccountingMonth_CreatedOn  ,  
  LuAccountingMonth_ModifiedBy ,  
  LuAccountingMonth_ModifiedOn ,  
  LuAccountingMonth_IsDeleted  ,  
  A.PeriodTypeID ,  
  A.LuStatus_Code,  
  C.LuStatus_Name,  
  LuAccountingMonth_Description,  
  LuAccountingMonth_MonthShort,  
  PeriodTypeName,
  A.LuAccountingMonth_FromDate,
  A.LuAccountingMonth_ToDate
 from [dbo].[LuAccountingMonth] A JOIN PeriodType B   
   ON A.PeriodTypeID = B.PeriodTypeID   
  JOIN LuStatus C   
   ON C.LuStatus_Code = A.LuStatus_Code  
 where   
  LuAccountingMonth_IsDeleted=0   
  AND C.LuStatus_Category='Settlement Period'   
  order by LuAccountingMonth_CreatedOn desc     
      
END 
