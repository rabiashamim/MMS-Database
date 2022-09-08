/****** Object:  Procedure [dbo].[BME_Step7Perform_old]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[BME_Step7Perform_old](			 
			@Year int,
			@Month int
			,@StatementProcessId decimal(18,0) = null)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
     IF EXISTS(SELECT TOP 1 BmeStatementData_Id FROM BmeStatementDataHourly 
     WHERE  [BmeStatementData_Year] = @Year and [BmeStatementData_Month] = @Month)
    BEGIN
-------------------------------------

	

------------------------------------

--steps  7.1
	UPDATE BmeStatementDataHourly 
	set 
	BmeStatementData_ActualCapacity =AD.ActualCapacity
	FROM BmeStatementDataHourly
	INNER JOIN (
	
------------	Legacy Thermal Plants only

SELECT DATEADD(HOUR,CAST(MtAvailibilityData.MtAvailibilityData_Hour AS INT)+1,CAST(MtAvailibilityData.MtAvailibilityData_Date AS datetime)) AS MtAvailibilityDataDateHour
, SUM(MtAvailibilityData.MtAvailibilityData_ActualCapacity) AS ActualCapacity
FROM            
						 MtAvailibilityData 
						 INNER JOIN
                         MtGenerationUnit ON MtAvailibilityData.MtGenerationUnit_Id = MtGenerationUnit.MtGenerationUnit_SOUnitId
						 inner join MtGenerator on MtGenerator.MtGenerator_Id = MtGenerationUnit.MtGenerator_Id
						 inner join MtPartyCategory on MtPartyCategory.MtPartyCategory_Id = MtGenerator.MtPartyCategory_Id
						 inner join MtPartyRegisteration on MtPartyRegisteration.MtPartyRegisteration_Id = MtPartyCategory.MtPartyRegisteration_Id
						 where SrTechnologyType_Code='THR'
						 and MtPartyRegisteration.MtPartyRegisteration_Id in (
								 select distinct MtBilateralContract_SellerMPId from MtBilateralContract where MtBilateralContract_BuyerMPId in (
								 select MtPartyRegisteration_Id from MtPartyRegisteration where MtPartyRegisteration_IsPowerPool=1) and MtSOFileMaster_Id=dbo.GetMtSoFileMasterId(@StatementProcessId, 8)
						 )
						 AND MtAvailibilityData.MtSOFileMaster_Id=dbo.GetMtSoFileMasterId(@StatementProcessId, 2)
						   AND  DATEPART(YEAR,MtAvailibilityData_Date)= @Year AND DATEPART(MONTH,MtAvailibilityData_Date) = @Month
						 GROUP BY MtAvailibilityData.MtAvailibilityData_Date,MtAvailibilityData.MtAvailibilityData_Hour
						 ) 
		as AD on  BmeStatementDataHourly.BmeStatementData_NtdcDateTime = AD.MtAvailibilityDataDateHour;


		----------------------------

	UPDATE BmeStatementDataMpHourly 
	set 
	BmeStatementData_ActualCapacity =AD.ActualCapacity
	FROM BmeStatementDataMpHourly
	INNER JOIN (
	
------------	Legacy Thermal Plants only

SELECT MtPartyRegisteration.MtPartyRegisteration_Id, DATEADD(HOUR,CAST(MtAvailibilityData.MtAvailibilityData_Hour AS INT)+1,CAST(MtAvailibilityData.MtAvailibilityData_Date AS datetime)) AS MtAvailibilityDataDateHour
, SUM(MtAvailibilityData.MtAvailibilityData_ActualCapacity) AS ActualCapacity
FROM            
						 MtAvailibilityData 
						 INNER JOIN
                         MtGenerationUnit ON MtAvailibilityData.MtGenerationUnit_Id = MtGenerationUnit.MtGenerationUnit_SOUnitId
						 inner join MtGenerator on MtGenerator.MtGenerator_Id = MtGenerationUnit.MtGenerator_Id
						 inner join MtPartyCategory on MtPartyCategory.MtPartyCategory_Id = MtGenerator.MtPartyCategory_Id
						 inner join MtPartyRegisteration on MtPartyRegisteration.MtPartyRegisteration_Id = MtPartyCategory.MtPartyRegisteration_Id
						 where SrTechnologyType_Code='THR'
						 and MtPartyRegisteration.MtPartyRegisteration_Id in (
								 select distinct MtBilateralContract_SellerMPId from MtBilateralContract where MtBilateralContract_BuyerMPId in (
								 select MtPartyRegisteration_Id from MtPartyRegisteration where MtPartyRegisteration_IsPowerPool=1)  and MtSOFileMaster_Id=dbo.GetMtSoFileMasterId(@StatementProcessId, 8)
						 )
						 AND MtAvailibilityData.MtSOFileMaster_Id=dbo.GetMtSoFileMasterId(@StatementProcessId, 2)
						   AND  DATEPART(YEAR,MtAvailibilityData_Date)= @Year AND DATEPART(MONTH,MtAvailibilityData_Date) = @Month
						 GROUP BY MtPartyRegisteration.MtPartyRegisteration_Id,MtAvailibilityData.MtAvailibilityData_Date,MtAvailibilityData.MtAvailibilityData_Hour
						 ) 
		as AD on AD.MtPartyRegisteration_Id = BmeStatementDataMpHourly.BmeStatementData_PartyRegisteration_Id and  BmeStatementDataMpHourly.BmeStatementData_NtdcDateTime = AD.MtAvailibilityDataDateHour;




		------------	Legacy Renewable Plants only

UPDATE BmeStatementDataHourly 
	set 
	BmeStatementData_EnergySuppliedGeneratedLegacy = CDPH.BmeStatementData_EnergySuppliedGenerated
	FROM BmeStatementDataHourly as dh inner join
           (
		   select BmeStatementData_NtdcDateTime, 		   
		   Sum(
	    ISNULL( CASE WHEN cdp.BmeStatementData_ToPartyType_Code='MP'
		 THEN
	      cdp.BmeStatementData_AdjustedEnergyImport
		  END ,0)
		  +
		ISNULL( CASE WHEN cdp.BmeStatementData_FromPartyType_Code='MP'
		 THEN
	      cdp.BmeStatementData_AdjustedEnergyExport
		END,0)

	) as BmeStatementData_EnergySuppliedGenerated			  
from BmeStatementDataCdpHourly cdp
WHERE 
BmeStatementData_IsEnergyImported=0
AND BmeStatementData_ISARE=1
AND BmeStatementData_IsLegacy=1
AND [BmeStatementData_Year] = @Year and [BmeStatementData_Month] = @Month

		GROUP BY BmeStatementData_NtdcDateTime
		   ) CDPH  on dh.BmeStatementData_NtdcDateTime = CDPH.BmeStatementData_NtdcDateTime
						   
---------------------
UPDATE BmeStatementDataMpHourly 
	set 
	BmeStatementData_EnergySuppliedGeneratedLegacy = cdp.BmeStatementData_EnergySuppliedGenerated
	FROM BmeStatementDataMpHourly as dh inner join
           (
		   select OP.BmeStatementData_OwnerPartyRegisteration_Id,BmeStatementData_NtdcDateTime, 
		   Sum(
	    ISNULL( CASE WHEN CDPH.BmeStatementData_ToPartyType_Code='MP'
		 THEN
	      CDPH.BmeStatementData_AdjustedEnergyImport
		  END ,0)
		  +
		ISNULL( CASE WHEN CDPH.BmeStatementData_FromPartyType_Code='MP'
		 THEN
	      CDPH.BmeStatementData_AdjustedEnergyExport
		END,0)

	) as BmeStatementData_EnergySuppliedGenerated	
from BmeStatementDataCdpHourly CDPH
	INNER JOIN  BmeStatementDataCdpOwnerParty  OP 
	ON OP.BmeStatementData_ToPartyRegisteration_Id = CDPH.BmeStatementData_ToPartyRegisteration_Id
	AND OP.BmeStatementData_CdpId=CDPH.BmeStatementData_CdpId  
	AND OP.BmeStatementData_FromPartyRegisteration_Id=CDPH.BmeStatementData_FromPartyRegisteration_Id
	where CDPH.BmeStatementData_Year = @Year and CDPH.BmeStatementData_Month = @Month
AND CDPH.BmeStatementData_IsEnergyImported=0
AND CDPH.BmeStatementData_ISARE=1
AND CDPH.BmeStatementData_IsLegacy=1

		GROUP BY OP.BmeStatementData_OwnerPartyRegisteration_Id, BmeStatementData_NtdcDateTime
		   ) cdp  on dh.BmeStatementData_PartyRegisteration_Id = cdp.BmeStatementData_OwnerPartyRegisteration_Id and dh.BmeStatementData_NtdcDateTime = cdp.BmeStatementData_NtdcDateTime
						   

UPDATE BmeStatementDataHourly 
	set 
	BmeStatementData_EnergySuppliedImportedLegacy = CDPH.BmeStatementData_EnergySuppliedImported
	FROM BmeStatementDataHourly as dh inner join
           (
		   select BmeStatementData_NtdcDateTime, 	 Sum(
	    ISNULL( CASE WHEN cdp.BmeStatementData_ToPartyType_Code='MP'
		 THEN
	      cdp.BmeStatementData_AdjustedEnergyImport
		  END ,0)
		  +
		ISNULL( CASE WHEN cdp.BmeStatementData_FromPartyType_Code='MP'
		 THEN
	      cdp.BmeStatementData_AdjustedEnergyExport
		END,0)

	) as BmeStatementData_EnergySuppliedImported
from BmeStatementDataCdpHourly  cdp
WHERE 
BmeStatementData_IsEnergyImported=1
AND BmeStatementData_ISARE=1
AND BmeStatementData_IsLegacy=1
AND [BmeStatementData_Year] = @Year and [BmeStatementData_Month] = @Month
		GROUP BY BmeStatementData_NtdcDateTime
		   ) CDPH  on dh.BmeStatementData_NtdcDateTime = CDPH.BmeStatementData_NtdcDateTime
		   
----------------------
UPDATE BmeStatementDataMpHourly 
	set 
	BmeStatementData_EnergySuppliedImportedLegacy = cdp.BmeStatementData_EnergySuppliedImported
	FROM BmeStatementDataMpHourly as dh inner join
           (
		   select OP.BmeStatementData_OwnerPartyRegisteration_Id,BmeStatementData_NtdcDateTime, 
		 Sum(
	    ISNULL( CASE WHEN CDPH.BmeStatementData_ToPartyType_Code='MP'
		 THEN
	      CDPH.BmeStatementData_AdjustedEnergyImport
		  END ,0)
		  +
		ISNULL( CASE WHEN CDPH.BmeStatementData_FromPartyType_Code='MP'
		 THEN
	      CDPH.BmeStatementData_AdjustedEnergyExport
		END,0)

	) as BmeStatementData_EnergySuppliedImported
from BmeStatementDataCdpHourly CDPH
	INNER JOIN  BmeStatementDataCdpOwnerParty  OP 
	ON OP.BmeStatementData_ToPartyRegisteration_Id = CDPH.BmeStatementData_ToPartyRegisteration_Id
	AND OP.BmeStatementData_CdpId=CDPH.BmeStatementData_CdpId  
	AND OP.BmeStatementData_FromPartyRegisteration_Id=CDPH.BmeStatementData_FromPartyRegisteration_Id
	where CDPH.BmeStatementData_Year = @Year and CDPH.BmeStatementData_Month = @Month
AND CDPH.BmeStatementData_IsEnergyImported=1
AND CDPH.BmeStatementData_ISARE=1
AND CDPH.BmeStatementData_IsLegacy=1

		GROUP BY OP.BmeStatementData_OwnerPartyRegisteration_Id, BmeStatementData_NtdcDateTime
		   ) cdp  on dh.BmeStatementData_PartyRegisteration_Id=cdp.BmeStatementData_OwnerPartyRegisteration_Id and dh.BmeStatementData_NtdcDateTime = cdp.BmeStatementData_NtdcDateTime
		   


    END       
END




--update Cap excluding allocation factor

UPDATE BmeStatementDataHourly
SET 
BmeStatementData_CAPLegacy=
(ISNULL( BmeStatementData_EnergySuppliedGeneratedLegacy,0)+ ISNULL(BmeStatementData_EnergySuppliedImportedLegacy,0)+ISNULL(BmeStatementData_ActualCapacity,0))
-ISNULL
((SELECT SUM(LuAllocationFactors_StaticCapValue) FROM LuAllocationFactors WHERE LuAllocationFactors_StaticCapValue>0),0)
WHERE 
 [BmeStatementData_Year] = @Year and [BmeStatementData_Month] = @Month




 UPDATE BmeStatementDataMpHourly
 SET BmeStatementData_CAPLegacy= BmeStatementDataHourly.BmeStatementData_CAPLegacy * ISNULL(
 (SELECT TOP (1) LuAllocationFactors_Factor FROM LuAllocationFactors
 WHERE MtPartyRegisteration_Id=BmeStatementDataMpHourly.BmeStatementData_PartyRegisteration_Id
 AND LuAllocationFactors_Factor>0
 )
 ,0)*0.01
 FROM BmeStatementDataMpHourly
 INNER JOIN BmeStatementDataHourly ON BmeStatementDataHourly.BmeStatementData_NtdcDateTime= BmeStatementDataMpHourly.BmeStatementData_NtdcDateTime
 WHERE 
 BmeStatementDataHourly.[BmeStatementData_Year] = @Year and BmeStatementDataHourly.[BmeStatementData_Month] = @Month

 EXECUTE [dbo].[BME_Step7APerform] @Year ,@Month,@StatementProcessId 
 SELECT 1;
 --RETURN @@rowcount;
