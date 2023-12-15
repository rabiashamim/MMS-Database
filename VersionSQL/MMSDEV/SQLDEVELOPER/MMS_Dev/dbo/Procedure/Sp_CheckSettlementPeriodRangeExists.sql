/****** Object:  Procedure [dbo].[Sp_CheckSettlementPeriodRangeExists]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================      
-- Author:  <Aymen Khalid>      
-- Create date: <02-09-2022>      
-- Description: <Checks if a settlement period already exists within the range>      
-- =============================================      
CREATE PROCEDURE dbo.Sp_CheckSettlementPeriodRangeExists      
 -- Add the parameters for the stored procedure here   
@ps_LuAccountingMonth_Id int = null
,@ps_MonthAndYear varchar(255)    
,@pd_LuAccountingMonth_FromDate date
,@pd_LuAccountingMonth_ToDate date
,@ps_LuAccountingMonth_PeriodTypeID varchar(100)
      
AS      
BEGIN      
 -- SET NOCOUNT ON added to prevent extra result sets from      
 -- interfering with SELECT statements.      
 SET NOCOUNT ON;      
      
IF(@ps_LuAccountingMonth_Id IS NULL) --INSERT CASE    
BEGIN    
    
 SELECT COUNT(*)       
 FROM       
  LuAccountingMonth       
 WHERE       
 PeriodTypeID = @ps_LuAccountingMonth_PeriodTypeID
AND
(
    (LuAccountingMonth_FromDate  between @pd_LuAccountingMonth_FromDate and @pd_LuAccountingMonth_ToDate) 
	OR 
	(LuAccountingMonth_todate  between @pd_LuAccountingMonth_FromDate and @pd_LuAccountingMonth_ToDate)
	OR 
	(LuAccountingMonth_FromDate <=@pd_LuAccountingMonth_FromDate and LuAccountingMonth_todate>=@pd_LuAccountingMonth_ToDate) 
)  
AND       
  LuAccountingMonth_IsDeleted = 0      
    
END    
ELSE --UPDATE CASE    
BEGIN    
    
 SELECT COUNT(*)       
 FROM       
  LuAccountingMonth       
 WHERE       
 PeriodTypeID = @ps_LuAccountingMonth_PeriodTypeID
AND
(
    (LuAccountingMonth_FromDate  between @pd_LuAccountingMonth_FromDate and @pd_LuAccountingMonth_ToDate) 
	OR 
	(LuAccountingMonth_todate  between @pd_LuAccountingMonth_FromDate and @pd_LuAccountingMonth_ToDate)
	OR 
	(LuAccountingMonth_FromDate <=@pd_LuAccountingMonth_FromDate and LuAccountingMonth_todate>=@pd_LuAccountingMonth_ToDate) 
) 
  And       
  LuAccountingMonth_IsDeleted = 0  
  AND    
  LuAccountingMonth_Id != @ps_LuAccountingMonth_Id    
    
END    
    
    
END 
