/****** Object:  Procedure [dbo].[BME_Step2Perform]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================  
-- Author:  M.Asghar(.Net/SQL Consultant), Ali Imran (.Net/SQL Developer)  
-- CREATE date: March 17, 2022 
-- ALTER date: June 09, 2022   
-- Description: This procedure is used to update Adjusted Energy.
--              1) Set CDP Adjusted Energy Import is equal to Energy Import and Adjusted Energy Export is equal to Energy Export where CDP Conected From or Connected To Parties are belong to TSP category.
--              2) Set DSP's Adjusted Energy Export with distribution losses 
--              2) fetch BVM reading data and insert into BME CDP hourly table.
--              
-- Parameters: @Year, @Month, @StatementProcessId  
-- =============================================  
-- [dbo].[BME_Step2Perform] 2022,5,9
CREATE   Procedure [dbo].[BME_Step2Perform](			 
			@Year int,
			@Month int
			,@StatementProcessId decimal(18,0)
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
BEGIN TRY
DECLARE @MONTH_EFFECTIVE_FROM as DATETIME = DATETIMEFROMPARTS(@Year,@Month,1,0,0,0,0);
DECLARE @MONTH_EFFECTIVE_TO as DATETIME = DATEADD(MONTH,1,@MONTH_EFFECTIVE_FROM);

 IF EXISTS(SELECT TOP 1 BmeStatementData_Id FROM BmeStatementDataCdpHourly WHERE  BmeStatementData_Year=@Year and BmeStatementData_Month=@Month and BmeStatementData_StatementProcessId=@StatementProcessId)
    BEGIN

/*
if (ConnectedTo == TSP) or (ConnectedFrom == TSP)
      adj_E_Export = Energy_Export (BVM)
      adj_E_Import = Energy_Import (BVM)
else
 [
if {    ConnectedFrom== DSP and ConnectedTo== DSP
 adj_E_Export = Energy_Export / (1 - dist_loss (ConnectedFrom DSP_Loss_Factor) )
 adj_E_Import = Energy_Import / (1 - dist_loss (ConnectedTo DSP_Loss_Factor))    }
if { ConnectedTo =DSP
  adj_E_Import = Energy_Import / (1 - dist_loss_Of_that_Line_Voltage)
 adj_E_Export = Energy_Export }
if {ConnectedFrom =DSP
  adj_E_Import = Energy_Import
  adj_E_Export = Energy_Export / (1 - dist_loss_Of_that_Line_Voltage) }
]

*/

	-------------------------Step 2.2 Starts
		UPDATE dbo.BmeStatementDataCdpHourly SET 
           BmeStatementData_AdjustedEnergyImport=BmeStatementData_IncEnergyImport
		   ,BmeStatementData_AdjustedEnergyExport=BmeStatementData_IncEnergyExport
				  where 
				  BmeStatementData_Year=@Year 
				  AND BmeStatementData_Month=@Month and BmeStatementData_StatementProcessId=@StatementProcessId				  
				  and (BmeStatementData_FromPartyCategory_Code='TSP' OR BmeStatementData_ToPartyCategory_Code='TSP'
				  or ISNULL(IsBackfeedInclude,0)=0
				  );

------------------------------------------------------------------------------------------------------------
	
	UPDATE dbo.BmeStatementDataCdpHourly SET 
    BmeStatementData_DistLosses_Factor=toDL.Lu_DistLosses_Factor,
    BmeStatementData_DistLosses_EffectiveFrom=toDL.Lu_DistLosses_EffectiveFrom,
    BmeStatementData_DistLosses_EffectiveTo=toDL.Lu_DistLosses_EffectiveTo 
	,BmeStatementData_AdjustedEnergyExport=cdp.BmeStatementData_IncEnergyExport/NULLIF(1 - toDL.Lu_DistLosses_Factor/100.0,0)
    FROM  dbo.BmeStatementDataCdpHourly as cdp                 
				  inner JOIN
                  dbo.Lu_DistLosses as toDL ON cdp.BmeStatementData_FromPartyRegisteration_Id = toDL.MtPartyRegisteration_Id 
				  and cdp.BmeStatementData_LineVoltage = toDL.Lu_DistLosses_LineVoltage
				  where CDP.BmeStatementData_Year=@Year and CDP.BmeStatementData_Month=@Month 
				  and CDP.BmeStatementData_StatementProcessId=@StatementProcessId 
				  AND ISNULL(cdp.IsBackfeedInclude,0)=1
				  AND BmeStatementData_FromPartyCategory_Code='DSP' and BmeStatementData_ToPartyCategory_Code <>'TSP' --and BmeStatementData_ToPartyCategory_Code ='DSP'
				  and cdp.BmeStatementData_NtdcDateTime>=toDL.Lu_DistLosses_EffectiveFrom 
				  and cdp.BmeStatementData_NtdcDateTime<=ISNULL(toDL.Lu_DistLosses_EffectiveTo,@MONTH_EFFECTIVE_TO)
                  ;

	------------------------------------------------------------------------------------------
	
	 UPDATE dbo.BmeStatementDataCdpHourly SET 
	 BmeStatementData_AdjustedEnergyImport=BmeStatementData_IncEnergyImport
    FROM  dbo.BmeStatementDataCdpHourly as cdp                 
				  where CDP.BmeStatementData_Year=@Year and CDP.BmeStatementData_Month=@Month and CDP.BmeStatementData_StatementProcessId=@StatementProcessId 
				 
				  AND BmeStatementData_FromPartyCategory_Code='DSP'
				  AND BmeStatementData_ToPartyCategory_Code not in ('DSP','TSP');
    
	------------------------------------------------------------------

    UPDATE dbo.BmeStatementDataCdpHourly SET 
    BmeStatementData_DistLosses_Factor=toDL.Lu_DistLosses_Factor,
    BmeStatementData_DistLosses_EffectiveFrom=toDL.Lu_DistLosses_EffectiveFrom,
    BmeStatementData_DistLosses_EffectiveTo=toDL.Lu_DistLosses_EffectiveTo 
	,BmeStatementData_AdjustedEnergyImport=BmeStatementData_IncEnergyImport/NULLIF(1 - toDL.Lu_DistLosses_Factor/100.0,0)
	
    FROM  dbo.BmeStatementDataCdpHourly as cdp                 
				  inner JOIN
                  dbo.Lu_DistLosses as toDL ON cdp.BmeStatementData_ToPartyRegisteration_Id = toDL.MtPartyRegisteration_Id 
				  and cdp.BmeStatementData_LineVoltage = toDL.Lu_DistLosses_LineVoltage
				  where CDP.BmeStatementData_Year=@Year and CDP.BmeStatementData_Month=@Month
				  and CDP.BmeStatementData_StatementProcessId=@StatementProcessId 
				  
				  AND BmeStatementData_ToPartyCategory_Code='DSP' 
				  AND ISNULL(cdp.IsBackfeedInclude,0)=1
				  and BmeStatementData_FromPartyCategory_Code <>'TSP' --and BmeStatementData_FromPartyCategory_Code ='DSP'
				  and cdp.BmeStatementData_NtdcDateTime>=toDL.Lu_DistLosses_EffectiveFrom 
				  and cdp.BmeStatementData_NtdcDateTime<=ISNULL(toDL.Lu_DistLosses_EffectiveTo,@MONTH_EFFECTIVE_TO);

------------------------------

  UPDATE dbo.BmeStatementDataCdpHourly SET 
	 BmeStatementData_AdjustedEnergyExport=BmeStatementData_IncEnergyExport
    FROM  dbo.BmeStatementDataCdpHourly as cdp                 
				  where CDP.BmeStatementData_Year=@Year and CDP.BmeStatementData_Month=@Month 
				  and CDP.BmeStatementData_StatementProcessId=@StatementProcessId 
				 
				  AND BmeStatementData_ToPartyCategory_Code='DSP'
				  AND BmeStatementData_FromPartyCategory_Code not in ('DSP','TSP');
	
	
EXEC [dbo].[BME_Step2APerform] @Year,@Month,@StatementProcessId;

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
