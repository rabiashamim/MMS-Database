/****** Object:  Procedure [dbo].[BME_Step11Perform_bk17June]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[BME_Step11Perform_bk17June](			 
			@Year int,
			@Month int
		,@StatementProcessId decimal(18,0) --ESS Statement Process Id for current month
)
AS
BEGIN
	SET NOCOUNT ON;
BEGIN TRY
	--------------------------------------------------------	
	------		MP Hourly Calculations
	--------------------------------------------------------

     IF EXISTS(SELECT TOP 1 BmeStatementData_Id FROM BmeStatementDataMpMonthly_SettlementProcess 
     WHERE  BmeStatementData_Year=@Year and BmeStatementData_Month=@Month and BmeStatementData_StatementProcessId=@StatementProcessId)
    BEGIN

Declare @vPredecessorId as decimal(18,0)

select @vPredecessorId=[dbo].[GetESSAdjustmentPredecessorStatementId](@StatementProcessId);

select * into #tempPredecessorData from BmeStatementDataMpMonthly_SettlementProcess where  BmeStatementData_Year=@Year and BmeStatementData_Month=@Month and BmeStatementData_StatementProcessId=@vPredecessorId;

update currentESS set currentESS.BmeStatementData_ESSAdjustment=IsNull(currentESS.BmeStatementData_AmountPayableReceivable,0)-IsNull(predecessor.BmeStatementData_AmountPayableReceivable,0)
from BmeStatementDataMpMonthly_SettlementProcess currentESS
JOIN #tempPredecessorData predecessor on predecessor.BmeStatementData_PartyRegisteration_Id=currentESS.BmeStatementData_PartyRegisteration_Id

--where BmeStatementData_Year=@Year and BmeStatementData_Month=@Month and BmeStatementData_StatementProcessId=@StatementProcessId 
 
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
