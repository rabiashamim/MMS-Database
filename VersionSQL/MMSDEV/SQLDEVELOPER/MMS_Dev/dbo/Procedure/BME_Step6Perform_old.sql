/****** Object:  Procedure [dbo].[BME_Step6Perform_old]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[BME_Step6Perform_old](			 
			@Year int,
			@Month int
			,@StatementProcessId decimal(18,0) = null)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
     IF EXISTS(SELECT TOP 1 BmeStatementData_Id FROM BmeStatementDataMpHourly 
     WHERE  [BmeStatementData_Year] = @Year and [BmeStatementData_Month] = @Month)
    BEGIN




	--Step 6.1
    UPDATE dbo.BmeStatementDataMpHourly SET 
        BmeStatementData_TransmissionLosses = BmeStatementDataHourly.BmeStatementData_TransmissionLosses,
        BmeStatementData_UpliftTransmissionLosses = BmeStatementDataHourly.BmeStatementData_UpliftTransmissionLosses
		,BmeStatementData_EnergySuppliedActual = BmeStatementDataMpHourly.BmeStatementData_ActualEnergy *(1 + BmeStatementDataHourly.BmeStatementData_UpliftTransmissionLosses)
        FROM    BmeStatementDataMpHourly  INNER JOIN
                         BmeStatementDataHourly ON BmeStatementDataMpHourly.BmeStatementData_NtdcDateTime = BmeStatementDataHourly.BmeStatementData_NtdcDateTime
				  where BmeStatementDataMpHourly.BmeStatementData_Year=@Year AND BmeStatementDataMpHourly.BmeStatementData_Month=@Month 
				  and IsNull((select top 1 BmeStatementData_IsPowerPool from BmeStatementDataCdpOwnerParty where BmeStatementData_OwnerPartyRegisteration_Id=BmeStatementDataMpHourly.BmeStatementData_PartyRegisteration_Id),0) <> 1;	


 --ESG of legacy Renewable for calculating cap

-------------Step 6.2

	UPDATE BmeStatementDataMpHourly set BmeStatementData_EnergySuppliedGenerated =cdp.BmeStatementData_EnergySuppliedGenerated
	FROM BmeStatementDataMpHourly
	INNER JOIN (select OP.BmeStatementData_OwnerPartyRegisteration_Id,BmeStatementData_NtdcDateTime, 
	
	Sum(
	    ISNULL( CASE WHEN CDPH.BmeStatementData_ToPartyType_Code='MP' and CDPH.BmeStatementData_ToPartyCategory_Code <> 'BSUP'
		 THEN
	      CDPH.BmeStatementData_AdjustedEnergyImport
		  END ,0)
		  +
		ISNULL( CASE WHEN CDPH.BmeStatementData_FromPartyType_Code='MP' and CDPH.BmeStatementData_FromPartyCategory_Code <> 'BSUP'
		 THEN
	      CDPH.BmeStatementData_AdjustedEnergyExport
		END,0)

	) as BmeStatementData_EnergySuppliedGenerated	
	from BmeStatementDataCdpHourly CDPH
	INNER JOIN  BmeStatementDataCdpOwnerParty  OP 
	ON 	OP.BmeStatementData_CdpId=CDPH.BmeStatementData_CdpId
	AND OP.BmeStatementData_FromPartyRegisteration_Id = CDPH.BmeStatementData_FromPartyRegisteration_Id
	and OP.BmeStatementData_ToPartyRegisteration_Id = CDPH.BmeStatementData_ToPartyRegisteration_Id	
	where CDPH.BmeStatementData_Year = @Year and CDPH.BmeStatementData_Month = @Month
	and CDPH.BmeStatementData_IsEnergyImported=0
	and OP.BmeStatementData_OwnerPartyCategory_Code <> 'BSUP'
	and ISNULL(OP.BmeStatementData_IsPowerPool ,0)<>1
	GROUP by OP.BmeStatementData_OwnerPartyRegisteration_Id,BmeStatementData_NtdcDateTime
	
	) as cdp on BmeStatementDataMpHourly.BmeStatementData_PartyRegisteration_Id=cdp.BmeStatementData_OwnerPartyRegisteration_Id 
	and BmeStatementDataMpHourly.BmeStatementData_NtdcDateTime = cdp.BmeStatementData_NtdcDateTime;
	
	
------------------Step 6.2 ends
		
-- --ESI of legacy Renewable for calculating cap

		-------------Step 6.3

	UPDATE BmeStatementDataMpHourly set 
	BmeStatementData_EnergySuppliedImported = cdp.BmeStatementData_EnergySuppliedImported
	FROM BmeStatementDataMpHourly
	INNER JOIN (
	
	select OP.BmeStatementData_OwnerPartyRegisteration_Id,BmeStatementData_NtdcDateTime,
	Sum(
	    ISNULL( CASE WHEN CDPH.BmeStatementData_ToPartyType_Code='MP'
		 THEN
	      CDPH.BmeStatementData_AdjustedEnergyImport
		 END,0)
		  +
		ISNULL( CASE WHEN CDPH.BmeStatementData_FromPartyType_Code='MP'
		THEN
	      CDPH.BmeStatementData_AdjustedEnergyExport
		END,0)
	)  as BmeStatementData_EnergySuppliedImported	
	from BmeStatementDataCdpHourly CDPH
	INNER JOIN  BmeStatementDataCdpOwnerParty  OP 
	ON OP.BmeStatementData_ToPartyRegisteration_Id = CDPH.BmeStatementData_ToPartyRegisteration_Id
	AND OP.BmeStatementData_CdpId=CDPH.BmeStatementData_CdpId  
	AND OP.BmeStatementData_FromPartyRegisteration_Id=CDPH.BmeStatementData_FromPartyRegisteration_Id
	where CDPH.BmeStatementData_Year = @Year and CDPH.BmeStatementData_Month = @Month
	and CDPH.BmeStatementData_IsEnergyImported=1
	and ISNULL(OP.BmeStatementData_IsPowerPool ,0)<>1
	GROUP by OP.BmeStatementData_OwnerPartyRegisteration_Id,BmeStatementData_NtdcDateTime
	
	) as cdp on BmeStatementDataMpHourly.BmeStatementData_PartyRegisteration_Id=cdp.BmeStatementData_OwnerPartyRegisteration_Id 
	and BmeStatementDataMpHourly.BmeStatementData_NtdcDateTime = cdp.BmeStatementData_NtdcDateTime;



---------------- Step 6.3 ends	

   --RETURN @@ROWCOUNT;
    END
	SELECT 1;
END
