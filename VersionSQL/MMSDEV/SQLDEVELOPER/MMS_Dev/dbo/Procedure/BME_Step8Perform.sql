/****** Object:  Procedure [dbo].[BME_Step8Perform]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================  
-- Author:  M.Asghar(.Net/SQL Consultant)  
-- CREATE date: March 18, 2022 
-- ALTER date: June 01, 2022   
-- Description: 
--              
-- Parameters: @Year, @Month, @StatementProcessId
-- ============================================= 
--  [dbo].[BME_Step8Perform] 2021,11,3

CREATE   Procedure [dbo].[BME_Step8Perform](			 
			@Year int,
			@Month int
			,@StatementProcessId decimal(18,0))
AS
BEGIN
	SET NOCOUNT ON;
	--------------------------------------------------------	
	------		MP Hourly Calculations
	--------------------------------------------------------
BEGIN TRY
   
   

     IF EXISTS(SELECT TOP 1 BmeStatementData_Id FROM BmeStatementDataMpHourly 
     WHERE  BmeStatementData_Year=@Year and BmeStatementData_Month=@Month and BmeStatementData_StatementProcessId=@StatementProcessId)
    BEGIN
-------------------------------------
---		Step 8.1	Calculate Hourly Imbalance
---		Imbalance = ESG + ESI + ET - ESA
	
	Update BmeStatementDataMpHourly set BmeStatementData_Imbalance=
	CAST(IsNull(BmeStatementData_EnergySuppliedGenerated,0) + IsNull(BmeStatementData_EnergySuppliedImported,0) + IsNull(BmeStatementData_EnergyTraded,0) -  IsNull(BmeStatementData_EnergySuppliedActual,0) AS DECIMAL(18,2))
	where BmeStatementData_Year=@Year and BmeStatementData_Month=@Month and BmeStatementData_StatementProcessId=@StatementProcessId;

---------------------------------------------
---		Step 8.2 Fetch Marginal Price

	Update MPH set  MPH.BmeStatementData_MarginalPrice = MP.MtMarginalPrice_Price
	from BmeStatementDataMpHourly MPH
	inner Join MtMarginalPrice MP on 
		MPH.BmeStatementData_NtdcDateTime = DATEADD(HOUR,CAST(MP.MtMarginalPrice_Hour AS INT)+1,CAST(MP.MtMarginalPrice_Date AS datetime))
		Where MPH.BmeStatementData_Year=@Year and MPH.BmeStatementData_Month=@month and MPH.BmeStatementData_StatementProcessId=@StatementProcessId
		AND MP.MtSOFileMaster_Id=dbo.GetMtSoFileMasterId(@StatementProcessId, 1);
--------------------------------------------
---		Step 8.3 Calculate Imbalance Charges Hourly


	Update BmeStatementDataMpHourly 
	set BmeStatementData_ImbalanceCharges= IsNull(BmeStatementData_Imbalance,0) * IsNull(BmeStatementData_MarginalPrice,0)
	where BmeStatementData_Year=@Year and BmeStatementData_Month=@Month and BmeStatementData_StatementProcessId=@StatementProcessId;


	--------------------------------------------------------	
	------		MP Monthly Calculations
	--------------------------------------------------------

---		Step 8.4 Calculate Imbalance Charges MP Monthly 
   
	
    INSERT INTO [dbo].[BmeStatementDataMpMonthly]
           (
               [BmeStatementData_StatementProcessId]
               ,[BmeStatementData_Year]
           ,[BmeStatementData_Month]
           ,[BmeStatementData_PartyRegisteration_Id]
           ,[BmeStatementData_PartyName]
           ,[BmeStatementData_PartyType_Code]
		  ,[BmeStatementData_IsPowerPool]
		)
		Select DISTINCT  
        @StatementProcessId
        ,[BmeStatementData_Year]
		,[BmeStatementData_Month] 
		,[BmeStatementData_PartyRegisteration_Id]
		, [BmeStatementData_PartyName],
		[BmeStatementData_PartyType_Code]
        ,[BmeStatementData_IsPowerPool]
		from BmeStatementDataMpHourly
		where BmeStatementData_Year=@Year and BmeStatementData_Month=@Month and BmeStatementData_StatementProcessId=@StatementProcessId
		and BmeStatementData_PartyType_Code='MP';


		------	Group Hourly Imbalance Charges to Monthly Imbalance Charges
		update  BmeStatementDataMpMonthly set 
		BmeStatementData_EnergySuppliedActual=MPH.BmeStatementData_EnergySuppliedActual,
		BmeStatementData_ImbalanceCharges=MPH.BmeStatementData_ImbalanceCharges  
		FROM BmeStatementDataMpMonthly MPM
		inner join
		(
		select Sum(BmeStatementData_EnergySuppliedActual) as BmeStatementData_EnergySuppliedActual,
		Sum(BmeStatementData_ImbalanceCharges) as BmeStatementData_ImbalanceCharges, MPH.BmeStatementData_PartyRegisteration_Id,
		MPH.BmeStatementData_Year,MPH.BmeStatementData_Month
		FROM BmeStatementDataMpHourly MPH 
		where MPH.BmeStatementData_Year=@Year and  MPH.BmeStatementData_Month=@Month and MPH.BmeStatementData_StatementProcessId=@StatementProcessId 
		Group by MPH.BmeStatementData_PartyRegisteration_Id,MPH.BmeStatementData_Year,MPH.BmeStatementData_Month
		) as MPH
		on MPH.BmeStatementData_PartyRegisteration_Id=MPM.BmeStatementData_PartyRegisteration_Id	
		and MPH.BmeStatementData_Year=MPM.BmeStatementData_Year	
		and MPH.BmeStatementData_Month=MPM.BmeStatementData_Month	
		Where MPM.BmeStatementData_Year=@Year and  MPM.BmeStatementData_Month=@Month and MPM.BmeStatementData_StatementProcessId=@StatementProcessId;


-----------------------------------------
	--------------------------------------------------------	
	------		MP Category Monthly Calculations
	--------------------------------------------------------

-----------------------------------------------

    INSERT INTO [dbo].[BmeStatementDataMpCategoryMonthly]
           (
               [BmeStatementData_StatementProcessId]
               ,[BmeStatementData_Year]
           ,[BmeStatementData_Month]
           ,[BmeStatementData_PartyRegisteration_Id]
           ,[BmeStatementData_PartyName]
          ,[BmeStatementData_PartyCategory_Code]
           ,[BmeStatementData_PartyType_Code]
		   ,BmeStatementData_CongestedZoneID
           ,BmeStatementData_CongestedZone
           ,[BmeStatementData_IsPowerPool]
		)
		Select DISTINCT  
        @StatementProcessId
        ,[BmeStatementData_Year]
		,[BmeStatementData_Month] 
		,[BmeStatementData_PartyRegisteration_Id]
		, [BmeStatementData_PartyName],
		[BmeStatementData_PartyCategory_Code], 
		[BmeStatementData_PartyType_Code],
		[BmeStatementData_CongestedZoneID],
        [BmeStatementData_CongestedZone],
        [BmeStatementData_IsPowerPool]
		from BmeStatementDataMpCategoryHourly
		where BmeStatementData_Year=@Year and BmeStatementData_Month=@Month and BmeStatementData_StatementProcessId=@StatementProcessId
		and BmeStatementData_PartyType_Code='MP';


		------	Group Hourly Energy Supplied Actual to Monthly Energy Supplied Actual
		update  BmeStatementDataMpCategoryMonthly set 	
		BmeStatementData_EnergySuppliedActual=MPH.BmeStatementData_EnergySuppliedActual	
		 from BmeStatementDataMpCategoryMonthly MPM
		inner join
		(
		select Sum(BmeStatementData_EnergySuppliedActual) as BmeStatementData_EnergySuppliedActual	
		,MPH.BmeStatementData_PartyRegisteration_Id,MPH.BmeStatementData_PartyCategory_Code
		,MPH.BmeStatementData_CongestedZoneID
		,MPH.BmeStatementData_Year,MPH.BmeStatementData_Month 
		from BmeStatementDataMpCategoryHourly MPH 
		where MPH.BmeStatementData_Year=@Year and  MPH.BmeStatementData_Month=@Month and MPH.BmeStatementData_StatementProcessId=@StatementProcessId 
		Group by MPH.BmeStatementData_PartyRegisteration_Id,MPH.BmeStatementData_PartyCategory_Code
			,MPH.BmeStatementData_CongestedZoneID
			,MPH.BmeStatementData_Year,MPH.BmeStatementData_Month
		) as MPH
		on MPH.BmeStatementData_PartyRegisteration_Id=MPM.BmeStatementData_PartyRegisteration_Id
		and MPH.BmeStatementData_PartyCategory_Code=MPM.BmeStatementData_PartyCategory_Code
		and MPH.BmeStatementData_Year=MPM.BmeStatementData_Year
		and MPH.BmeStatementData_Month=MPM.BmeStatementData_Month
		AND MPH.BmeStatementData_CongestedZoneID=MPM.BmeStatementData_CongestedZoneID
		Where MPM.BmeStatementData_Year=@Year and  MPM.BmeStatementData_Month=@Month and MPM.BmeStatementData_StatementProcessId=@StatementProcessId;


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
