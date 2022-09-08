/****** Object:  Procedure [dbo].[BME_Step8Perform_old]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--  [dbo].[BME_Step8Perform] 2021,11,3

CREATE PROCEDURE [dbo].[BME_Step8Perform_old](			 
			@Year int,
			@Month int
			,@StatementProcessId decimal(18,0) = null)
AS
BEGIN
	SET NOCOUNT ON;
	--------------------------------------------------------	
	------		MP Hourly Calculations
	--------------------------------------------------------

     IF EXISTS(SELECT TOP 1 BmeStatementData_Id FROM BmeStatementDataMpHourly 
     WHERE  [BmeStatementData_Year] = @Year and [BmeStatementData_Month] = @Month)
    BEGIN
-------------------------------------
---		Step 8.1	Calculate Hourly Imbalance
---		Imbalance = ESG + ESI + ET - ESA
	
	Update BmeStatementDataMpHourly set BmeStatementData_Imbalance=IsNull(BmeStatementData_EnergySuppliedGenerated,0) + IsNull(BmeStatementData_EnergySuppliedImported,0) + IsNull(BmeStatementData_EnergyTraded,0) -  IsNull(BmeStatementData_EnergySuppliedActual,0)
	where BmeStatementData_Year=@Year and BmeStatementData_Month=@Month;


---------------------------------------------
---		Step 8.2 Fetch Marginal Price
	Update MPH set  MPH.BmeStatementData_MarginalPrice = MP.MtMarginalPrice_Price
	from BmeStatementDataMpHourly MPH
	inner Join MtMarginalPrice MP on 
		MPH.BmeStatementData_NtdcDateTime = DATEADD(HOUR,CAST(MP.MtMarginalPrice_Hour AS INT)+1,CAST(MP.MtMarginalPrice_Date AS datetime))
		Where MPH.BmeStatementData_Year=@Year and MPH.BmeStatementData_Month=@month
		AND MP.MtSOFileMaster_Id=dbo.GetMtSoFileMasterId(@StatementProcessId, 1)
		;


--------------------------------------------
---		Step 8.3 Calculate Imbalance Charges Hourly

	Update BmeStatementDataMpHourly 
	set BmeStatementData_ImbalanceCharges= IsNull(BmeStatementData_Imbalance,0) * IsNull(BmeStatementData_MarginalPrice,0)
	where BmeStatementData_Year=@Year and BmeStatementData_Month=@Month;

	END

	--------------------------------------------------------	
	------		MP Monthly Calculations
	--------------------------------------------------------

-----------------------------------------------
---		Step 8.4 Calculate Imbalance Charges MP Monthly 
   IF NOT EXISTS(SELECT TOP 1 BmeStatementData_Id FROM [BmeStatementDataMpMonthly] WHERE  BmeStatementData_Year=@Year and BmeStatementData_Month=@Month)
    BEGIN
	
INSERT INTO [dbo].[BmeStatementDataMpMonthly]
           ([BmeStatementData_Year]
           ,[BmeStatementData_Month]
           ,[BmeStatementData_PartyRegisteration_Id]
           ,[BmeStatementData_PartyName]
        --   ,[BmeStatementData_PartyCategory_Code]
           ,[BmeStatementData_PartyType_Code]
		)
		Select DISTINCT  [BmeStatementData_Year],[BmeStatementData_Month] ,[BmeStatementData_PartyRegisteration_Id], [BmeStatementData_PartyName],
		--[BmeStatementData_PartyCategory_Code], 
		[BmeStatementData_PartyType_Code]   from BmeStatementDataMpHourly
		where BmeStatementData_Year=@Year and BmeStatementData_Month=@Month
		and BmeStatementData_PartyType_Code='MP';


		------	Group Hourly Imbalance Charges to Monthly Imbalance Charges
		update  BmeStatementDataMpMonthly set BmeStatementData_ImbalanceCharges=
		MPH.BmeStatementData_ImbalanceCharges from BmeStatementDataMpMonthly MPM
		inner join
		(
		select Sum(BmeStatementData_ImbalanceCharges) as BmeStatementData_ImbalanceCharges, BmeStatementData_PartyRegisteration_Id from BmeStatementDataMpHourly MPH where 
--MPH.BmeStatementData_PartyRegisteration_Id=MPM.BmeStatementData_PartyRegisteration_Id and
		MPH.BmeStatementData_Year=@Year and  MPH.BmeStatementData_Month=@Month 
		Group by MPH.BmeStatementData_PartyRegisteration_Id
		) as MPH
		on MPH.BmeStatementData_PartyRegisteration_Id=MPM.BmeStatementData_PartyRegisteration_Id
		Where MPM.BmeStatementData_Year=@Year and  MPM.BmeStatementData_Month=@Month;


		--update  MPM set BmeStatementData_ImbalanceCharges=(
		--select Sum(BmeStatementData_ImbalanceCharges) from BmeStatementDataMpHourly MPH where MPH.BmeStatementData_PartyRegisteration_Id=MPM.BmeStatementData_PartyRegisteration_Id and MPH.BmeStatementData_Year=@Year and  MPH.BmeStatementData_Month=@Month 
		--Group by MPH.BmeStatementData_PartyRegisteration_Id
		--)
		--FROM  BmeStatementDataMpMonthly MPM 
		--Where MPM.BmeStatementData_Year=@Year and  MPM.BmeStatementData_Month=@Month;
		SELECT 1;
		--return @@rowcount;


	END
-----------------------------------------
END
