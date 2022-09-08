/****** Object:  Procedure [dbo].[BME_Step6Perform]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================  
-- Author:  M.Asghar(.Net/SQL Consultant)  
-- CREATE date: March 18, 2022 
-- ALTER date: June 01, 2022   
-- Description: 
--              
-- Parameters: @Year, @Month, @StatementProcessId
-- ============================================= 
CREATE   Procedure [dbo].[BME_Step6Perform](			 
			@Year int,
			@Month int
			,@StatementProcessId decimal(18,0))
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
BEGIN TRY    
IF EXISTS(SELECT TOP 1 BmeStatementData_Id FROM BmeStatementDataMpHourly 
     WHERE  BmeStatementData_Year=@Year and BmeStatementData_Month=@Month and BmeStatementData_StatementProcessId=@StatementProcessId)
BEGIN

	--Step 6.1
	
	 UPDATE dbo.BmeStatementDataMpHourly SET 
        BmeStatementData_TransmissionLosses = DH.BmeStatementData_TransmissionLosses,
        BmeStatementData_UpliftTransmissionLosses = DH.BmeStatementData_UpliftTransmissionLosses
		,BmeStatementData_EnergySuppliedActual = MH.BmeStatementData_ActualEnergy *(1 + DH.BmeStatementData_UpliftTransmissionLosses)
        FROM  BmeStatementDataMpHourly MH INNER JOIN
                         BmeStatementDataHourly DH ON 
                         MH.BmeStatementData_NtdcDateTime = DH.BmeStatementData_NtdcDateTime 
                         and MH.BmeStatementData_StatementProcessId = DH.BmeStatementData_StatementProcessId
				  where MH.BmeStatementData_Year=@Year and MH.BmeStatementData_Month=@Month and MH.BmeStatementData_StatementProcessId=@StatementProcessId 
                   AND DH.BmeStatementData_Year=@Year and DH.BmeStatementData_Month=@Month and DH.BmeStatementData_StatementProcessId=@StatementProcessId;
	
	              --and IsNull((select top 1 BmeStatementData_IsPowerPool from BmeStatementDataCdpOwnerParty
				  --where BmeStatementData_StatementProcessId=@StatementProcessId  AND BmeStatementData_OwnerPartyRegisteration_Id=MH.BmeStatementData_PartyRegisteration_Id),0) <> 1;	
				  -----------------------------

    UPDATE dbo.BmeStatementDataMpCategoryHourly SET 
       BmeStatementData_TransmissionLosses = DH.BmeStatementData_TransmissionLosses,
        BmeStatementData_UpliftTransmissionLosses = DH.BmeStatementData_UpliftTransmissionLosses
		,BmeStatementData_EnergySuppliedActual = MH.BmeStatementData_ActualEnergy *(1 + DH.BmeStatementData_UpliftTransmissionLosses)
        FROM    BmeStatementDataMpCategoryHourly MH INNER JOIN
                         BmeStatementDataHourly DH ON MH.BmeStatementData_NtdcDateTime = DH.BmeStatementData_NtdcDateTime
                           and MH.BmeStatementData_StatementProcessId = DH.BmeStatementData_StatementProcessId
				  where MH.BmeStatementData_Year=@Year and MH.BmeStatementData_Month=@Month and MH.BmeStatementData_StatementProcessId=@StatementProcessId 
                   AND DH.BmeStatementData_Year=@Year and DH.BmeStatementData_Month=@Month and DH.BmeStatementData_StatementProcessId=@StatementProcessId ;
				 -- and IsNull((select top 1 BmeStatementData_IsPowerPool from BmeStatementDataCdpOwnerParty
				 -- where BmeStatementData_StatementProcessId=@StatementProcessId  AND BmeStatementData_OwnerPartyRegisteration_Id=MH.BmeStatementData_PartyRegisteration_Id),0) <> 1;		




 --ESG of legacy Renewable for calculating cap

-------------Step 6.2
--------------------------------------------------
 -- MP Hourly
----------------------------------------------------
--DROP TABLE IF EXISTS #tempCdpGen
select 
DISTINCT 
PC.MtPartyRegisteration_Id
,g.MtGenerator_Id
,GU.MtGenerationUnit_IsEnergyImported
INTO #tempCdpGen
FROM MtGenerator g
inner join MtGenerationUnit gu on gu.MtGenerator_Id=g.MtGenerator_Id
inner JOIN MtConnectedMeter mcm on mcm.MtConnectedMeter_UnitId=gu.MtGenerationUnit_Id
--inner join RuCDPDetail cdp on cdp.RuCDPDetail_Id=mcm.MtCDPDetail_Id
LEFT JOIN MtPartyCategory PC ON PC.MtPartyCategory_Id=mcm.MtPartyCategory_Id
where isnull( g.MtGenerator_IsDeleted,0)=0
and isnull(gu.MtGenerationUnit_IsDeleted,0)=0
and isnull(mcm.MtConnectedMeter_isDeleted,0)=0
AND ISNULL(PC.isDeleted,0)=0

--DROP TABLE IF EXISTS #MPWiseGen

SELECT BmeStatementData_NtdcDateTime
,G.MtPartyRegisteration_Id
,SUM(ISNULL(BmeStatementData_UnitWiseGeneration,0)) GenerationHourly 
INTO #MPWiseGen
FROM BmeStatementDataGenUnitHourly UH
JOIN #tempCdpGen G ON G.MtGenerator_Id=UH.BmeStatementData_MtGenerator_Id
WHERE BmeStatementData_StatementProcessId=@StatementProcessId
AND UH.BmeStatementData_Year=@Year
AND UH.BmeStatementData_Month=@Month
AND G.MtGenerationUnit_IsEnergyImported=0
GROUP BY BmeStatementData_NtdcDateTime,G.MtPartyRegisteration_Id

UPDATE BmeStatementDataMpHourly set BmeStatementData_EnergySuppliedGenerated 
=MPG.GenerationHourly
	FROM BmeStatementDataMpHourly MH
	INNER JOIN #MPWiseGen as MPG on 
    MH.BmeStatementData_PartyRegisteration_Id=MPG.MtPartyRegisteration_Id 
	and MH.BmeStatementData_NtdcDateTime = MPG.BmeStatementData_NtdcDateTime
   where MH.BmeStatementData_Year = @Year and MH.BmeStatementData_Month = @Month 
   AND MH.BmeStatementData_StatementProcessId=@StatementProcessId
    ;


/*
WITH EnergySuppliedGenerated_CTE
AS
(select OP.BmeStatementData_StatementProcessId, OP.BmeStatementData_OwnerPartyRegisteration_Id,CDPH.BmeStatementData_NtdcDateTime, 
	--Sum(
	--    ISNULL( CASE WHEN CDPH.BmeStatementData_ToPartyType_Code='MP' and CDPH.BmeStatementData_ToPartyCategory_Code <> 'BSUP'
	--	 THEN
	--      CDPH.BmeStatementData_AdjustedEnergyImport
	--	  END ,0)
	--	  +
	--	ISNULL( CASE WHEN CDPH.BmeStatementData_FromPartyType_Code='MP' and CDPH.BmeStatementData_FromPartyCategory_Code <> 'BSUP'
	--	 THEN
	--      CDPH.BmeStatementData_AdjustedEnergyExport
	--	END,0)

	--) as BmeStatementData_EnergySuppliedGenerated	
	SUM(CASE WHEN ISNULL(CDPH.IsBackfeedInclude,0)=1 THEN(
	
	    ISNULL( CASE WHEN CDPH.BmeStatementData_ToPartyType_Code='MP' and CDPH.BmeStatementData_ToPartyCategory_Code <> 'BSUP'
		 THEN
	      CDPH.BmeStatementData_AdjustedEnergyImport
		  END ,0)
		  +
		ISNULL( CASE WHEN CDPH.BmeStatementData_FromPartyType_Code='MP' and CDPH.BmeStatementData_FromPartyCategory_Code <> 'BSUP'
		 THEN
	      CDPH.BmeStatementData_AdjustedEnergyExport
		END,0)

	)
	ELSE
	
	    ISNULL( CASE WHEN CDPH.BmeStatementData_ToPartyType_Code='MP' and CDPH.BmeStatementData_ToPartyCategory_Code <> 'BSUP'
		 THEN
	     CDPH.BmeStatementData_AdjustedEnergyImport -CDPH.BmeStatementData_AdjustedEnergyExport
		  END ,0)
		  +
		ISNULL( CASE WHEN CDPH.BmeStatementData_FromPartyType_Code='MP' and CDPH.BmeStatementData_FromPartyCategory_Code <> 'BSUP'
		 THEN
	      CDPH.BmeStatementData_AdjustedEnergyExport- CDPH.BmeStatementData_AdjustedEnergyImport
		END,0

	)
	END)
	as BmeStatementData_EnergySuppliedGenerated	
	from BmeStatementDataCdpHourly CDPH
	INNER JOIN  BmeStatementDataCdpOwnerParty  OP 
	ON 	OP.BmeStatementData_CdpId=CDPH.BmeStatementData_CdpId
    and OP.BmeStatementData_StatementProcessId = CDPH.BmeStatementData_StatementProcessId	
	where CDPH.BmeStatementData_Year = @Year and CDPH.BmeStatementData_Month = @Month AND CDPH.BmeStatementData_StatementProcessId=@StatementProcessId
	and ISNULL(CDPH.BmeStatementData_IsEnergyImported,0)=0
	and OP.BmeStatementData_OwnerPartyCategory_Code <> 'BSUP'
	--and ISNULL(OP.BmeStatementData_IsPowerPool ,0)=0
    --AND ISNULL(CDPH.IsBackfeedInclude,0)=1
	GROUP by OP.BmeStatementData_OwnerPartyRegisteration_Id,BmeStatementData_NtdcDateTime,OP.BmeStatementData_StatementProcessId
	
	)


UPDATE BmeStatementDataMpHourly set BmeStatementData_EnergySuppliedGenerated =cdp.BmeStatementData_EnergySuppliedGenerated
	FROM BmeStatementDataMpHourly MH
	INNER JOIN EnergySuppliedGenerated_CTE as cdp on 
    MH.BmeStatementData_PartyRegisteration_Id=cdp.BmeStatementData_OwnerPartyRegisteration_Id 
	and MH.BmeStatementData_NtdcDateTime = cdp.BmeStatementData_NtdcDateTime
    and  MH.BmeStatementData_StatementProcessId = cdp.BmeStatementData_StatementProcessId
   where MH.BmeStatementData_Year = @Year and MH.BmeStatementData_Month = @Month AND MH.BmeStatementData_StatementProcessId=@StatementProcessId 
    ;
*/
	
--------------------------------------------------
 -- MP Category Zone Hourly
----------------------------------------------------

	WITH EnergySuppliedGenerated_CTE
AS
(select OP.BmeStatementData_OwnerPartyRegisteration_Id,OP.BmeStatementData_OwnerPartyCategory_Code,OP.BmeStatementData_CongestedZoneID,BmeStatementData_NtdcDateTime, 
	
SUM(CASE WHEN ISNULL(CDPH.IsBackfeedInclude,0)=1 THEN(
	
	    ISNULL( CASE WHEN CDPH.BmeStatementData_ToPartyType_Code='MP' and CDPH.BmeStatementData_ToPartyCategory_Code <> 'BSUP'
		 THEN
	      CDPH.BmeStatementData_AdjustedEnergyImport
		  END ,0)
		  +
		ISNULL( CASE WHEN CDPH.BmeStatementData_FromPartyType_Code='MP' and CDPH.BmeStatementData_FromPartyCategory_Code <> 'BSUP'
		 THEN
	      CDPH.BmeStatementData_AdjustedEnergyExport
		END,0)

	)
	ELSE
	
	    ISNULL( CASE WHEN CDPH.BmeStatementData_ToPartyType_Code='MP' and CDPH.BmeStatementData_ToPartyCategory_Code <> 'BSUP'
		 THEN
	     CDPH.BmeStatementData_AdjustedEnergyImport -CDPH.BmeStatementData_AdjustedEnergyExport
		  END ,0)
		  +
		ISNULL( CASE WHEN CDPH.BmeStatementData_FromPartyType_Code='MP' and CDPH.BmeStatementData_FromPartyCategory_Code <> 'BSUP'
		 THEN
	      CDPH.BmeStatementData_AdjustedEnergyExport- CDPH.BmeStatementData_AdjustedEnergyImport
		END,0

	)
	END) as BmeStatementData_EnergySuppliedGenerated	

	--Sum(
	--    ISNULL( CASE WHEN CDPH.BmeStatementData_ToPartyType_Code='MP' and CDPH.BmeStatementData_ToPartyCategory_Code <> 'BSUP'
	--	 THEN
	--      CDPH.BmeStatementData_AdjustedEnergyImport
	--	  END ,0)
	--	  +
	--	ISNULL( CASE WHEN CDPH.BmeStatementData_FromPartyType_Code='MP' and CDPH.BmeStatementData_FromPartyCategory_Code <> 'BSUP'
	--	 THEN
	--      CDPH.BmeStatementData_AdjustedEnergyExport
	--	END,0)

	--) as BmeStatementData_EnergySuppliedGenerated	
	from BmeStatementDataCdpHourly CDPH
	INNER JOIN  BmeStatementDataCdpOwnerParty  OP 
	ON 	OP.BmeStatementData_CdpId=CDPH.BmeStatementData_CdpId
     and OP.BmeStatementData_StatementProcessId = CDPH.BmeStatementData_StatementProcessId	
	AND OP.BmeStatementData_FromPartyRegisteration_Id = CDPH.BmeStatementData_FromPartyRegisteration_Id
	and OP.BmeStatementData_ToPartyRegisteration_Id = CDPH.BmeStatementData_ToPartyRegisteration_Id	
	where CDPH.BmeStatementData_Year = @Year and CDPH.BmeStatementData_Month = @Month AND CDPH.BmeStatementData_StatementProcessId=@StatementProcessId
	and ISNULL(CDPH.BmeStatementData_IsEnergyImported,0)=0
	and OP.BmeStatementData_OwnerPartyCategory_Code <> 'BSUP'

	GROUP by OP.BmeStatementData_OwnerPartyRegisteration_Id,BmeStatementData_NtdcDateTime
	,OP.BmeStatementData_OwnerPartyCategory_Code,OP.BmeStatementData_CongestedZoneID
	
	) 
	UPDATE BmeStatementDataMpCategoryHourly set BmeStatementData_EnergySuppliedGenerated =cdp.BmeStatementData_EnergySuppliedGenerated
	FROM BmeStatementDataMpCategoryHourly
	INNER JOIN EnergySuppliedGenerated_CTE as cdp on 
    BmeStatementDataMpCategoryHourly.BmeStatementData_PartyRegisteration_Id=cdp.BmeStatementData_OwnerPartyRegisteration_Id 
	and BmeStatementDataMpCategoryHourly.BmeStatementData_NtdcDateTime = cdp.BmeStatementData_NtdcDateTime
	AND BmeStatementDataMpCategoryHourly.BmeStatementData_PartyCategory_Code=cdp.BmeStatementData_OwnerPartyCategory_Code
	AND BmeStatementDataMpCategoryHourly.BmeStatementData_CongestedZoneID=cdp.BmeStatementData_CongestedZoneID
	where BmeStatementData_Year = @Year and BmeStatementData_Month = @Month AND BmeStatementData_StatementProcessId=@StatementProcessId ;
	
------------------Step 6.2 ends
		
-- --ESI of legacy Renewable for calculating cap

		-------------Step 6.3
--------------------------------------------------
 -- MP Hourly
----------------------------------------------------

SELECT BmeStatementData_NtdcDateTime
,G.MtPartyRegisteration_Id
,SUM(ISNULL(BmeStatementData_UnitWiseGeneration,0)) GenerationHourly 
INTO #MPWiseImport
FROM BmeStatementDataGenUnitHourly UH
JOIN #tempCdpGen G ON G.MtGenerator_Id=UH.BmeStatementData_MtGenerator_Id
WHERE BmeStatementData_StatementProcessId=@StatementProcessId
AND UH.BmeStatementData_Year=@Year
AND UH.BmeStatementData_Month=@Month
AND G.MtGenerationUnit_IsEnergyImported=1
GROUP BY BmeStatementData_NtdcDateTime,G.MtPartyRegisteration_Id

UPDATE BmeStatementDataMpHourly set BmeStatementData_EnergySuppliedImported
=MPG.GenerationHourly
	FROM BmeStatementDataMpHourly MH
	INNER JOIN #MPWiseImport as MPG on 
    MH.BmeStatementData_PartyRegisteration_Id=MPG.MtPartyRegisteration_Id 
	and MH.BmeStatementData_NtdcDateTime = MPG.BmeStatementData_NtdcDateTime
   where MH.BmeStatementData_Year = @Year and MH.BmeStatementData_Month = @Month 
   AND MH.BmeStatementData_StatementProcessId=@StatementProcessId;

/*
WITH EnergySuppliedImported_CTE
AS
(
	
	select OP.BmeStatementData_OwnerPartyRegisteration_Id,BmeStatementData_NtdcDateTime	,
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
    and OP.BmeStatementData_StatementProcessId = CDPH.BmeStatementData_StatementProcessId	
	AND OP.BmeStatementData_FromPartyRegisteration_Id=CDPH.BmeStatementData_FromPartyRegisteration_Id
	where CDPH.BmeStatementData_Year = @Year and CDPH.BmeStatementData_Month = @Month AND CDPH.BmeStatementData_StatementProcessId=@StatementProcessId
	and ISNULL(CDPH.BmeStatementData_IsEnergyImported,0)=1
	
	GROUP by  OP.BmeStatementData_OwnerPartyRegisteration_Id,BmeStatementData_NtdcDateTime
	
	)

UPDATE BmeStatementDataMpHourly set 
	BmeStatementData_EnergySuppliedImported = cdp.BmeStatementData_EnergySuppliedImported
	FROM BmeStatementDataMpHourly
	INNER JOIN  EnergySuppliedImported_CTE as cdp on BmeStatementDataMpHourly.BmeStatementData_PartyRegisteration_Id=cdp.BmeStatementData_OwnerPartyRegisteration_Id 
	and BmeStatementDataMpHourly.BmeStatementData_NtdcDateTime = cdp.BmeStatementData_NtdcDateTime
    where BmeStatementData_Year = @Year and BmeStatementData_Month = @Month AND BmeStatementData_StatementProcessId=@StatementProcessId ;

*/
--------------------------------------------------
 -- MP Category Zone Hourly
----------------------------------------------------

WITH EnergySuppliedImported_CTE
AS
(
	
	select OP.BmeStatementData_OwnerPartyRegisteration_Id,OP.BmeStatementData_OwnerPartyCategory_Code,BmeStatementData_NtdcDateTime
	,OP.BmeStatementData_CongestedZoneID,
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
    and OP.BmeStatementData_StatementProcessId = CDPH.BmeStatementData_StatementProcessId	
	AND OP.BmeStatementData_FromPartyRegisteration_Id=CDPH.BmeStatementData_FromPartyRegisteration_Id
	where CDPH.BmeStatementData_Year = @Year and CDPH.BmeStatementData_Month = @Month AND CDPH.BmeStatementData_StatementProcessId=@StatementProcessId
	and ISNULL(CDPH.BmeStatementData_IsEnergyImported,0)=1
	
	GROUP by  OP.BmeStatementData_OwnerPartyRegisteration_Id,BmeStatementData_NtdcDateTime,BmeStatementData_OwnerPartyCategory_Code
	,op.BmeStatementData_CongestedZoneID
	
	)


UPDATE BmeStatementDataMpCategoryHourly set 
	BmeStatementData_EnergySuppliedImported = cdp.BmeStatementData_EnergySuppliedImported
	FROM BmeStatementDataMpCategoryHourly
	INNER JOIN  EnergySuppliedImported_CTE as cdp on BmeStatementDataMpCategoryHourly.BmeStatementData_PartyRegisteration_Id=cdp.BmeStatementData_OwnerPartyRegisteration_Id 
	and BmeStatementDataMpCategoryHourly.BmeStatementData_NtdcDateTime = cdp.BmeStatementData_NtdcDateTime
	AND BmeStatementDataMpCategoryHourly.BmeStatementData_PartyCategory_Code=cdp.BmeStatementData_OwnerPartyCategory_Code 
	AND BmeStatementDataMpCategoryHourly.BmeStatementData_CongestedZoneID=cdp.BmeStatementData_CongestedZoneID
    where BmeStatementData_Year = @Year and BmeStatementData_Month = @Month AND BmeStatementData_StatementProcessId=@StatementProcessId ;

---------------- Step 6.3 ends	

/*
---*******************************		Adjust BackFeed of NTDC in Transmission losses
--***********************************************************

update tsp set  tsp.BmeStatementData_TransmissionLosses=ISNULL(tsp.BmeStatementData_TransmissionLosses,0)-(ISNULL(tsp.BmeStatementData_TransmissionLosses,0)-Isnull(AdjustedDemandNTDC.Adjustment,0))

from BmeStatementDataHourly tsp
inner join 

(	select BmeStatementData_NtdcDateTime, 
Sum(isnull(BmeStatementData_EnergySuppliedGenerated,0))+Sum( isnull(BmeStatementData_EnergySuppliedImported,0))-Sum(Isnull(BmeStatementData_ActualEnergy,0 )) as Adjustment
	from BmeStatementDataMpHourly 
where BmeStatementData_Year=@Year and BmeStatementData_Month=@Month and BmeStatementData_StatementProcessId=@StatementProcessId
group by BmeStatementData_NtdcDateTime
) as AdjustedDemandNTDC
 on AdjustedDemandNTDC.BmeStatementData_NtdcDateTime=tsp.BmeStatementData_NtdcDateTime
 where BmeStatementData_Year=@Year and BmeStatementData_Month=@Month and BmeStatementData_StatementProcessId=@StatementProcessId
 */
 /*
---*******************************		Update Demand from Actual Energy
--***********************************************************

update tsp set  tsp.BmeStatementData_DemandedEnergy=Isnull(AdjustedDemandNTDC.Adjustment,0)

from BmeStatementDataHourly tsp
inner join 

(	select BmeStatementData_NtdcDateTime, Sum(Isnull(BmeStatementData_ActualEnergy,0 )) as Adjustment
	from BmeStatementDataMpHourly 
where BmeStatementData_Year=@Year and BmeStatementData_Month=@Month and BmeStatementData_StatementProcessId=@StatementProcessId
group by BmeStatementData_NtdcDateTime
) as AdjustedDemandNTDC
 on AdjustedDemandNTDC.BmeStatementData_NtdcDateTime=tsp.BmeStatementData_NtdcDateTime
where BmeStatementData_Year=@Year and BmeStatementData_Month=@Month and BmeStatementData_StatementProcessId=@StatementProcessId

*/

---*******************************		uplift transmission loss
--***********************************************************


UPDATE BmeStatementDataHourly

SET
BmeStatementData_UpliftTransmissionLosses=cast(BmeStatementData_TransmissionLosses as decimal(25,13))/NULLIF(BmeStatementData_DemandedEnergy,0) 
from BmeStatementDataHourly 
where  BmeStatementData_Year=@Year and BmeStatementData_Month=@Month and BmeStatementData_StatementProcessId=@StatementProcessId



/*	
				
 UPDATE dbo.BmeStatementDataMpHourly SET 
        BmeStatementData_TransmissionLosses = DH.BmeStatementData_TransmissionLosses,
        BmeStatementData_UpliftTransmissionLosses = DH.BmeStatementData_UpliftTransmissionLosses
		,BmeStatementData_EnergySuppliedActual = MH.BmeStatementData_ActualEnergy *(1 + DH.BmeStatementData_UpliftTransmissionLosses)
        FROM  BmeStatementDataMpHourly MH INNER JOIN
                         BmeStatementDataHourly DH ON 
                         MH.BmeStatementData_NtdcDateTime = DH.BmeStatementData_NtdcDateTime 
                         and MH.BmeStatementData_StatementProcessId = DH.BmeStatementData_StatementProcessId
				  where MH.BmeStatementData_Year=@Year and MH.BmeStatementData_Month=@Month and MH.BmeStatementData_StatementProcessId=@StatementProcessId 
                   AND DH.BmeStatementData_Year=@Year and DH.BmeStatementData_Month=@Month and DH.BmeStatementData_StatementProcessId=@StatementProcessId;				
	
	-----------------------------
*/
/*
    UPDATE dbo.BmeStatementDataMpCategoryHourly SET 
        BmeStatementData_TransmissionLosses = DH.BmeStatementData_TransmissionLosses,
        BmeStatementData_UpliftTransmissionLosses = DH.BmeStatementData_UpliftTransmissionLosses,
		BmeStatementData_EnergySuppliedActual = MH.BmeStatementData_ActualEnergy *(1 + DH.BmeStatementData_UpliftTransmissionLosses)
        FROM    BmeStatementDataMpCategoryHourly MH INNER JOIN
                         BmeStatementDataHourly DH ON MH.BmeStatementData_NtdcDateTime = DH.BmeStatementData_NtdcDateTime
                           and MH.BmeStatementData_StatementProcessId = DH.BmeStatementData_StatementProcessId
				  where MH.BmeStatementData_Year=@Year and MH.BmeStatementData_Month=@Month and MH.BmeStatementData_StatementProcessId=@StatementProcessId 
                   AND DH.BmeStatementData_Year=@Year and DH.BmeStatementData_Month=@Month and DH.BmeStatementData_StatementProcessId=@StatementProcessId ;
				 -- and IsNull((select top 1 BmeStatementData_IsPowerPool from BmeStatementDataCdpOwnerParty
				 -- where BmeStatementData_StatementProcessId=@StatementProcessId  AND BmeStatementData_OwnerPartyRegisteration_Id=MH.BmeStatementData_PartyRegisteration_Id),0) <> 1;		

*/



--***********************************************************
--***********************************************************
   
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
