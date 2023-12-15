/****** Object:  Procedure [dbo].[Sp_CheckSettlementPeriodExists_1]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================      
-- Author:  <Aymen Khalid>      
-- Create date: <24-01-2022>      
-- Description: <Checks if a settlement period already exists>      
-- =============================================      
CREATE PROCEDURE dbo.Sp_CheckSettlementPeriodExists_1      
 -- Add the parameters for the stored procedure here      
@ps_MonthAndYear varchar(255),    
@ps_LuAccountingMonth_Id int = null    
      
AS      
BEGIN      
 -- SET NOCOUNT ON added to prevent extra result sets from      
 -- interfering with SELECT statements.      
 SET NOCOUNT ON;      
      
IF(@ps_LuAccountingMonth_Id IS NULL) --INSERT CASE    
BEGIN    
    print '111'
	select @ps_MonthAndYear
	select  * FROM       
  LuAccountingMonth       
 WHERE       
  LuAccountingMonth_MonthName = @ps_MonthAndYear       
  And       
  LuAccountingMonth_IsDeleted = 0      
  SELECT COUNT(*)       
 FROM       
  LuAccountingMonth       
 WHERE       
  LuAccountingMonth_MonthName = @ps_MonthAndYear       
  And       
  LuAccountingMonth_IsDeleted = 0      
    
END    
ELSE --UPDATE CASE    
BEGIN    
    
 SELECT COUNT(*)       
 FROM       
  LuAccountingMonth       
 WHERE       
  LuAccountingMonth_MonthName = @ps_MonthAndYear       
  And       
  LuAccountingMonth_IsDeleted = 0      
  AND    
  LuAccountingMonth_Id != @ps_LuAccountingMonth_Id    
    
END    
    
    
END 
