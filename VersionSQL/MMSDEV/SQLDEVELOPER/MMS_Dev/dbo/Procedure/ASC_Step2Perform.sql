/****** Object:  Procedure [dbo].[ASC_Step2Perform]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================  
-- Author:  M.Asghar(.Net/SQL Consultant)  
-- CREATE date: April 18, 2022 
-- ALTER date: June 10, 2022   
-- Description: 
--              
-- Parameters: @Year, @Month, @StatementProcessId
-- ============================================= 
CREATE   Procedure  [dbo].[ASC_Step2Perform](			 
			@Year int,
			@Month int
			,@StatementProcessId decimal(18,0)
			)
AS
BEGIN
	SET NOCOUNT ON;
BEGIN TRY    
   IF EXISTS(SELECT TOP 1 AscStatementData_Id FROM AscStatementDataGuHourly WHERE  AscStatementData_Year=@Year and AscStatementData_Month=@Month and AscStatementData_StatementProcessId=@StatementProcessId)
   BEGIN

UPDATE [AscStatementDataGuHourly] 
	set 

	AscStatementData_SO_AC =AD.MtAvailibilityData_ActualCapacity,
    AscStatementData_SO_AC_ASC =AD.MtAvailibilityData_AvailableCapacityASC
	FROM [AscStatementDataGuHourly]  as GH
	INNER JOIN MtAvailibilityData AD ON AD.MtGenerationUnit_Id=GH.AscStatementData_SOUnitId
	AND  DATEADD(HOUR,CAST(AD.MtAvailibilityData_Hour AS INT)+1,CAST(AD.MtAvailibilityData_Date AS datetime))=GH.AscStatementData_NtdcDateTime
	and AD.MtSOFileMaster_Id= dbo.GetMtSoFileMasterId(@StatementProcessId, 2) and 
    GH.AscStatementData_Year = @Year and GH.AscStatementData_Month = @Month and GH.AscStatementData_StatementProcessId = @StatementProcessId;

UPDATE [AscStatementDataGuHourly] 
	set 
	AscStatementData_SO_MR_EP =AD.MtMustRunGen_EnergyProduced
	,AscStatementData_SO_MR_VC =AD.MtMustRunGen_VariableCost
	FROM [AscStatementDataGuHourly]  as GH
	INNER JOIN MtMustRunGen AD ON AD.MtGenerationUnit_Id=GH.AscStatementData_SOUnitId
	AND  DATEADD(HOUR,CAST(AD.MtMustRunGen_Hour AS INT)+1,CAST(AD.MtMustRunGen_Date AS datetime))=GH.AscStatementData_NtdcDateTime
 and AD.MtSOFileMaster_Id= dbo.GetMtSoFileMasterId(@StatementProcessId, 3) and 
 GH.AscStatementData_Year = @Year and GH.AscStatementData_Month = @Month and GH.AscStatementData_StatementProcessId = @StatementProcessId;

UPDATE [AscStatementDataGuHourly] 
	set 
	AscStatementData_SO_MP =AD.MtMarginalPrice_Price
	FROM [AscStatementDataGuHourly]  as GH
	INNER JOIN MtMarginalPrice AD 
	ON AD.BmeStatementData_NtdcDateTime=GH.AscStatementData_NtdcDateTime
	 and AD.MtSOFileMaster_Id= dbo.GetMtSoFileMasterId(@StatementProcessId, 1) AND
     GH.AscStatementData_Year = @Year and GH.AscStatementData_Month = @Month and GH.AscStatementData_StatementProcessId = @StatementProcessId


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
