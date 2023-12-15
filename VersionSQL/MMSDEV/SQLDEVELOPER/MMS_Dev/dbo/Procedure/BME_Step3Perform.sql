/****** Object:  Procedure [dbo].[BME_Step3Perform]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================  
-- Author:  M.Asghar(.Net/SQL Consultant), Ali Imran (.Net/SQL Developer)  
-- CREATE date: March 18, 2022 
-- ALTER date: June 10, 2022   
-- Description: 
--              
-- Parameters: @Year, @Month, @StatementProcessId
-- =============================================  
-- dbo.BME_Step3Perform 2021,11,216
CREATE PROCEDURE dbo.BME_Step3Perform(			 
			@Year int,
			@Month int
			,@StatementProcessId decimal(18,0)
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
/*
BME	Step03.1	
"Transmission Network wise Losses
Calculate the difference between Energy Injected in the network of a Transmission Licensee and the Energy 
withdrawn from the network of the Transmission Licensee. 
You need to check that Energy flow from the ""Connected From"" towards ""Connected To"" is recorded in Export column 
and vice versa is recorded in Import column"

*/

BEGIN TRY




     IF NOT EXISTS(SELECT TOP 1 BmeStatementData_Id FROM BmeStatementDataTspHourly WHERE  BmeStatementData_Year=@Year and BmeStatementData_Month=@Month and BmeStatementData_StatementProcessId=@StatementProcessId)
    BEGIN
	insert into BmeStatementDataTspHourly (
        [BmeStatementData_StatementProcessId]
         ,[BmeStatementData_NtdcDateTime]
        ,[BmeStatementData_Year]
        ,[BmeStatementData_Month]
        ,[BmeStatementData_Day]
        ,[BmeStatementData_Hour]
        ,[BmeStatementData_PartyRegisteration_Id]
		,[BmeStatementData_PartyName]
		,[BmeStatementData_PartyCategory_Code]       
		,[BmeStatementData_PartyType_Code]       

)
	select distinct 
    @StatementProcessId
	     ,[BmeStatementData_NtdcDateTime]
        ,[BmeStatementData_Year]
        ,[BmeStatementData_Month]
        ,[BmeStatementData_Day]
        ,[BmeStatementData_Hour] 
		,BmeStatementData_FromPartyRegisteration_Id
		,BmeStatementData_FromPartyRegisteration_Name
		,BmeStatementData_FromPartyCategory_Code		
		,BmeStatementData_FromPartyType_Code		

 from BmeStatementDataCdpHourly
	 WHERE  BmeStatementData_Year=@Year and BmeStatementData_Month=@Month and BmeStatementData_StatementProcessId=@StatementProcessId AND BmeStatementData_FromPartyCategory_Code='TSP'
	 

	UNION
	select distinct
        @StatementProcessId      
		 ,[BmeStatementData_NtdcDateTime]
        ,[BmeStatementData_Year]
        ,[BmeStatementData_Month]
        ,[BmeStatementData_Day]
        ,[BmeStatementData_Hour]  
		,BmeStatementData_ToPartyRegisteration_Id 
		,BmeStatementData_ToPartyRegisteration_Name
		,BmeStatementData_ToPartyCategory_Code
		,BmeStatementData_ToPartyType_Code
 from BmeStatementDataCdpHourly
	 WHERE  BmeStatementData_Year=@Year and BmeStatementData_Month=@Month and BmeStatementData_StatementProcessId=@StatementProcessId AND BmeStatementData_ToPartyCategory_Code='TSP';

---------------------------------------------------------------
-----------Case 1

WITH FROM_TSP_ENERGY_CTE
AS(
    select CH.BmeStatementData_StatementProcessId,CH.BmeStatementData_FromPartyRegisteration_Id,CH.BmeStatementData_NtdcDateTime, Sum(CH.BmeStatementData_AdjustedEnergyImport) as BmeStatementData_AdjustedEnergyImport, Sum(CH.BmeStatementData_AdjustedEnergyExport) as BmeStatementData_AdjustedEnergyExport	 
	from BmeStatementDataCdpHourly CH
	where CH.BmeStatementData_Year=@Year and CH.BmeStatementData_Month=@Month and CH.BmeStatementData_StatementProcessId=@StatementProcessId
	and CH.BmeStatementData_FromPartyCategory_Code in ('TSP')
	GROUP by BmeStatementData_StatementProcessId,BmeStatementData_FromPartyRegisteration_Id,BmeStatementData_NtdcDateTime		
)

	UPDATE BmeStatementDataTspHourly set 
    BmeStatementData_TransmissionLosses = ISNULL(cdp.BmeStatementData_AdjustedEnergyImport,0)-ISNULL(cdp.BmeStatementData_AdjustedEnergyExport,0),
	BmeStatementData_AdjustedEnergyImport =ISNULL(cdp.BmeStatementData_AdjustedEnergyImport,0),
	BmeStatementData_AdjustedEnergyExport =ISNULL(cdp.BmeStatementData_AdjustedEnergyExport,0)
	FROM BmeStatementDataTspHourly TH
	INNER JOIN FROM_TSP_ENERGY_CTE as cdp on 
    TH.BmeStatementData_StatementProcessId=cdp.BmeStatementData_StatementProcessId 
    AND TH.BmeStatementData_PartyRegisteration_Id=cdp.BmeStatementData_FromPartyRegisteration_Id 
	and TH.BmeStatementData_NtdcDateTime = cdp.BmeStatementData_NtdcDateTime

    where TH.BmeStatementData_Year=@Year and TH.BmeStatementData_Month=@Month and TH.BmeStatementData_StatementProcessId=@StatementProcessId ;

-----------Case 2

WITH TO_TSP_ENERGY_CTE
AS
(   select BmeStatementData_StatementProcessId,BmeStatementData_ToPartyRegisteration_Id,BmeStatementData_NtdcDateTime, Sum(BmeStatementData_AdjustedEnergyImport) as BmeStatementData_AdjustedEnergyImport, Sum(BmeStatementData_AdjustedEnergyExport) as BmeStatementData_AdjustedEnergyExport	 
	from BmeStatementDataCdpHourly
	where BmeStatementDataCdpHourly.BmeStatementData_Year=@Year and BmeStatementDataCdpHourly.BmeStatementData_Month=@Month and BmeStatementDataCdpHourly.BmeStatementData_StatementProcessId=@StatementProcessId
	and BmeStatementDataCdpHourly.BmeStatementData_ToPartyCategory_Code in ('TSP')
	GROUP by BmeStatementData_StatementProcessId,BmeStatementData_ToPartyRegisteration_Id,BmeStatementData_NtdcDateTime
)

	UPDATE BmeStatementDataTspHourly set BmeStatementData_TransmissionLosses =IsNull(TH.BmeStatementData_TransmissionLosses,0) + (ISNULL(cdp.BmeStatementData_AdjustedEnergyExport,0) - ISNULL(cdp.BmeStatementData_AdjustedEnergyImport,0)),
	BmeStatementData_AdjustedEnergyImport =IsNull(TH.BmeStatementData_AdjustedEnergyImport,0)+ ISNULL(cdp.BmeStatementData_AdjustedEnergyExport,0),
	BmeStatementData_AdjustedEnergyExport =IsNull(TH.BmeStatementData_AdjustedEnergyExport,0)+ ISNULL(cdp.BmeStatementData_AdjustedEnergyImport,0)
	FROM BmeStatementDataTspHourly TH
	INNER JOIN TO_TSP_ENERGY_CTE as cdp on 
    TH.BmeStatementData_StatementProcessId=cdp.BmeStatementData_StatementProcessId 
    AND TH.BmeStatementData_PartyRegisteration_Id=cdp.BmeStatementData_ToPartyRegisteration_Id 
	and TH.BmeStatementData_NtdcDateTime = cdp.BmeStatementData_NtdcDateTime
    
    where TH.BmeStatementData_Year=@Year and TH.BmeStatementData_Month=@Month and TH.BmeStatementData_StatementProcessId=@StatementProcessId;

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
