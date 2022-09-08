/****** Object:  Procedure [dbo].[ASC_Step12Perform]    Committed by VersionSQL https://www.versionsql.com ******/

    
    
    
-- =============================================  
-- Author:  M.Asghar(.Net/SQL Consultant)  
-- CREATE date: April 18, 2022 
-- ALTER date: June 10, 2022   
-- Description: 
--              
-- Parameters: @Year, @Month, @StatementProcessId
-- =============================================   
--    [dbo].[ASC_Step1Perform] 2021,9,220   
CREATE   Procedure [dbo].[ASC_Step12Perform](        
   @Year int,    
   @Month int    
   ,@StatementProcessId decimal(18,0)    
   )    
AS    
BEGIN    
 BEGIN TRY    
       
   IF EXISTS(SELECT TOP 1 AscStatementData_Id FROM AscStatementDataMpMonthly WHERE  AscStatementData_Year=@Year and AscStatementData_Month=@Month and AscStatementData_StatementProcessId=@StatementProcessId)    
    BEGIN    
    
 Declare @vPredecessorId as decimal(18,0)    
    
select @vPredecessorId=[dbo].[GetESSAdjustmentPredecessorStatementId](@StatementProcessId);    
    
select * into #tempPredecessorData from AscStatementDataMpMonthly_SettlementProcess  where  AscStatementData_Year=@Year and AscStatementData_Month=@Month and AscStatementData_StatementProcessId=@vPredecessorId;    
    
    
    
update currentESS set    

currentESS.AscStatementData_AdjustmentPAYABLE=
  case when IsNull(currentESS.AscStatementData_PAYABLE,0)>IsNull(predecessor.AscStatementData_PAYABLE,0) 
  then ISNULL(currentESS.AscStatementData_AdjustmentPAYABLE,0)+ IsNull(currentESS.AscStatementData_PAYABLE,0)-IsNull(predecessor.AscStatementData_PAYABLE,0)
  when IsNull(currentESS.AscStatementData_RECEIVABLE,0)<IsNull(predecessor.AscStatementData_RECEIVABLE,0) 
  then ISNULL(currentESS.AscStatementData_AdjustmentPAYABLE,0)+ IsNull(predecessor.AscStatementData_RECEIVABLE,0)-IsNull(currentESS.AscStatementData_RECEIVABLE,0)
end,

currentESS.AscStatementData_AdjustmentRECEIVABLE=
  case when IsNull(currentESS.AscStatementData_PAYABLE,0)<IsNull(predecessor.AscStatementData_PAYABLE,0) 
  then ISNULL(currentESS.AscStatementData_AdjustmentRECEIVABLE,0)+IsNull(predecessor.AscStatementData_PAYABLE,0)- IsNull(currentESS.AscStatementData_PAYABLE,0)
  when IsNull(currentESS.AscStatementData_RECEIVABLE,0)>IsNull(predecessor.AscStatementData_RECEIVABLE,0) 
  then ISNULL(currentESS.AscStatementData_AdjustmentRECEIVABLE,0)+IsNull(currentESS.AscStatementData_RECEIVABLE,0)- IsNull(predecessor.AscStatementData_RECEIVABLE,0)
end
--currentESS.AscStatementData_AdjustmentPAYABLE= IsNull(currentESS.AscStatementData_PAYABLE,0)-IsNull(predecessor.AscStatementData_PAYABLE,0),    
--currentESS.AscStatementData_AdjustmentRECEIVABLE=ABS(IsNull(currentESS.AscStatementData_RECEIVABLE,0))-ABS(IsNull(predecessor.AscStatementData_RECEIVABLE,0))    
from AscStatementDataMpMonthly currentESS    
JOIN #tempPredecessorData predecessor on predecessor.AscStatementData_PartyRegisteration_Id=currentESS.AscStatementData_PartyRegisteration_Id  
  AND   currentESS.AscStatementData_Year=predecessor.AscStatementData_Year   
  AND predecessor.AscStatementData_Month=currentESS.AscStatementData_Month  
WHERE   currentESS.AscStatementData_StatementProcessId=@StatementProcessId  
  
    
    
SELECT 1 AS [IS_VALID], @@ROWCOUNT AS [ROW_COUNT], OBJECT_NAME(@@PROCID) AS [SP_NAME];    
 END    
 ELSE    
 BEGIN    
 SELECT 0 AS [IS_VALID], OBJECT_NAME(@@PROCID) AS [SP_NAME];    
 END     
END TRY    
BEGIN CATCH    
  SELECT    
    ERROR_NUMBER() AS ErrorNumber,    
    ERROR_STATE() AS ErrorState,    
    ERROR_SEVERITY() AS ErrorSeverity,    
    ERROR_PROCEDURE() AS ErrorProcedure,    
    ERROR_LINE() AS ErrorLine,    
    ERROR_MESSAGE() AS ErrorMessage;    
END CATCH;    
    
END 
