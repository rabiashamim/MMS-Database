/****** Object:  Procedure [dbo].[BME_Step7Perform_bk-19Sep2023]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================  
-- Author:  M.Asghar(.Net/SQL Consultant)  
-- CREATE date: March 18, @Year 
-- ALTER date: June 01, @Year   
-- Description: 
--              
-- Parameters: @Year, @Month, @StatementProcessId
-- ============================================= 
Create     Procedure dbo.BME_Step7Perform_bk-19Sep2023(			 
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

IF EXISTS(SELECT TOP 1 BmeStatementData_Id FROM BmeStatementDataHourly 
     WHERE  BmeStatementData_Year=@Year and BmeStatementData_Month=@Month and BmeStatementData_StatementProcessId=@StatementProcessId)
BEGIN
-------------------------------------

	

------------------------------------
--*****************************************************		Temp Table for Generators******************
--***********************************************************************
    select DISTINCT cdp.RuCDPDetail_CdpId,
g.MtGenerator_Name 
,g.MtGenerator_Id
INTO #tempCdpGen
FROM MtGenerator g
inner join MtGenerationUnit gu on gu.MtGenerator_Id=g.MtGenerator_Id
inner JOIN MtConnectedMeter mcm on mcm.MtConnectedMeter_UnitId=gu.MtGenerationUnit_Id
inner join RuCDPDetail cdp on cdp.RuCDPDetail_Id=mcm.MtCDPDetail_Id
where isnull( g.MtGenerator_IsDeleted,0)=0
and isnull(gu.MtGenerationUnit_IsDeleted,0)=0
and isnull(mcm.MtConnectedMeter_isDeleted,0)=0
AND mcm.MtPartyCategory_Id 
NOT IN (SELECT MtPartyCategory_Id FROM MtPartyCategory MPC 
WHERE MPC.SrCategory_Code IN ('BPC','EBPC') AND ISNULL(MPC.isDeleted,0)=0);  
--***********************************************************************
--***********************************************************************
--steps  7.1
	UPDATE BmeStatementDataHourly 
	set 
	BmeStatementData_ActualCapacity =AD.ActualCapacity
	FROM BmeStatementDataHourly DH
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
						 where 
						 ISNULL(MtGenerator.MtGenerator_IsDeleted,0)=0
						 AND ISNULL(MtGenerator.isDeleted,0)=0
						 AND ISNULL(MtGenerationUnit.MtGenerationUnit_IsDeleted,0)=0
						 AND ISNULL(MtGenerationUnit.isDeleted,0)=0
						 AND ISNULL(MtPartyCategory.isDeleted,0)=0
						 AND ISNULL(MtPartyRegisteration.isDeleted,0)=0
						 AND SrTechnologyType_Code='THR'
						 and (
                                MtPartyRegisteration.MtPartyRegisteration_Id in(select MtPartyRegisteration_Id from MtPartyRegisteration where MtPartyRegisteration_IsPowerPool=1) 
                                or  MtPartyRegisteration.MtPartyRegisteration_Id in (
								 select distinct MtBilateralContract_SellerMPId from MtBilateralContract where MtBilateralContract_BuyerMPId in (
								 select MtPartyRegisteration_Id from MtPartyRegisteration where MtPartyRegisteration_IsPowerPool=1) and MtSOFileMaster_Id=dbo.GetMtSoFileMasterId(@StatementProcessId, 8)
						        )
                            )
						 AND MtAvailibilityData.MtSOFileMaster_Id=dbo.GetMtSoFileMasterId(@StatementProcessId, 2)
						   AND  DATEPART(YEAR,MtAvailibilityData_Date)= @Year AND DATEPART(MONTH,MtAvailibilityData_Date) = @Month
						 GROUP BY MtAvailibilityData.MtAvailibilityData_Date,MtAvailibilityData.MtAvailibilityData_Hour
						 ) 
		as AD on  DH.BmeStatementData_NtdcDateTime = AD.MtAvailibilityDataDateHour
         where DH.BmeStatementData_Year = @Year 
		 and DH.BmeStatementData_Month = @Month 
		 AND DH.BmeStatementData_StatementProcessId=@StatementProcessId 



		----------------------------
--------------------------------------------------
 -- MP Category Zone Hourly
----------------------------------------------------
	UPDATE BmeStatementDataMpCategoryHourly 
	set 
	BmeStatementData_ActualCapacity =AD.ActualCapacity
	FROM BmeStatementDataMpCategoryHourly CH
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
						 where 
						  ISNULL(MtGenerator.MtGenerator_IsDeleted,0)=0
						 AND ISNULL(MtGenerator.isDeleted,0)=0
						 AND ISNULL(MtGenerationUnit.MtGenerationUnit_IsDeleted,0)=0
						 AND ISNULL(MtGenerationUnit.isDeleted,0)=0
						 AND ISNULL(MtPartyCategory.isDeleted,0)=0
						 AND ISNULL(MtPartyRegisteration.isDeleted,0)=0
						 AND SrTechnologyType_Code='THR'
						 and  (
                                MtPartyRegisteration.MtPartyRegisteration_Id in(select MtPartyRegisteration_Id from MtPartyRegisteration where MtPartyRegisteration_IsPowerPool=1) 
                                or  MtPartyRegisteration.MtPartyRegisteration_Id in (
								 select distinct MtBilateralContract_SellerMPId from MtBilateralContract where MtBilateralContract_BuyerMPId in (
								 select MtPartyRegisteration_Id from MtPartyRegisteration where MtPartyRegisteration_IsPowerPool=1) and MtSOFileMaster_Id=dbo.GetMtSoFileMasterId(@StatementProcessId, 8)
						        )
                            )
						 AND MtAvailibilityData.MtSOFileMaster_Id=dbo.GetMtSoFileMasterId(@StatementProcessId, 2)
						   AND  DATEPART(YEAR,MtAvailibilityData_Date)= @Year AND DATEPART(MONTH,MtAvailibilityData_Date) = @Month
						 GROUP BY MtPartyRegisteration.MtPartyRegisteration_Id,MtAvailibilityData.MtAvailibilityData_Date
						 ,MtAvailibilityData.MtAvailibilityData_Hour
						 ) 
		as AD on AD.MtPartyRegisteration_Id = CH.BmeStatementData_PartyRegisteration_Id
		and  CH.BmeStatementData_NtdcDateTime = AD.MtAvailibilityDataDateHour
         where CH.BmeStatementData_Year = @Year and CH.BmeStatementData_Month = @Month AND CH.BmeStatementData_StatementProcessId=@StatementProcessId 




--------------------------------------------------
 -- Hourly
----------------------------------------------------
		------------	Legacy Renewable Plants only

UPDATE BmeStatementDataHourly 
	set 
	BmeStatementData_EnergySuppliedGeneratedLegacy = CDPH.BmeStatementData_EnergySuppliedGenerated
	FROM BmeStatementDataHourly as DH inner join
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
--isnull(BmeStatementData_IsEnergyImported,0)=0 AND
 BmeStatementData_ISARE=1
AND BmeStatementData_IsLegacy=1
        AND IsBackfeedInclude=1
AND BmeStatementData_Year=@Year and BmeStatementData_Month=@Month and BmeStatementData_StatementProcessId=@StatementProcessId

		GROUP BY BmeStatementData_NtdcDateTime
		   ) CDPH  on DH.BmeStatementData_NtdcDateTime = CDPH.BmeStatementData_NtdcDateTime
where DH.BmeStatementData_Year = @Year and DH.BmeStatementData_Month = @Month AND DH.BmeStatementData_StatementProcessId=@StatementProcessId 

           ;

------**********************	BackFeed=0 and From Party='MP'
------***********************************************************



			UPDATE cdpActual 
	set 
	BmeStatementData_EnergySuppliedGeneratedLegacy = ISNULL(BmeStatementData_EnergySuppliedGeneratedLegacy,0)
	+ ISNULL(DHGenLeg.GenlegacyActual,0)
	FROM BmeStatementDataHourly cdpActual INNER JOIN(
	SELECT   DHA.BmeStatementData_NtdcDateTime,Sum(IsNull(CDP2.LegacyGeneration,0)) AS GenlegacyActual
FROM BmeStatementDataHourly DHA
INNER JOIN(
SELECT
       DH.BmeStatementData_NtdcDateTime,
cdp.MtGenerator_Id,cdp.MtGenerator_Name
       ,
       SUM(
    ISNULL(
    CASE WHEN (ISNULL(BmeStatementData_AdjustedEnergyExport,0)- ISNULL(BmeStatementData_AdjustedEnergyImport,0))<0
    THEN 0
    ELSE
     (ISNULL(BmeStatementData_AdjustedEnergyExport,0)- ISNULL(BmeStatementData_AdjustedEnergyImport,0))
     END,0))AS LegacyGeneration
    FROM BmeStatementDataHourly DH
    INNER JOIN (select BmeStatementData_NtdcDateTime,t.MtGenerator_Id,t.MtGenerator_Name
    , Sum(ISNULL(BmeStatementData_AdjustedEnergyImport,0)) as BmeStatementData_AdjustedEnergyImport
    , Sum(ISNULL(BmeStatementData_AdjustedEnergyExport,0)) as BmeStatementData_AdjustedEnergyExport     
    from BmeStatementDataCdpHourly 
    JOIN #tempCdpGen t ON t.RuCDPDetail_CdpId=BmeStatementData_CdpId
      where BmeStatementDataCdpHourly.BmeStatementData_Year=@Year and BmeStatementDataCdpHourly.BmeStatementData_Month=@Month and BmeStatementDataCdpHourly.BmeStatementData_StatementProcessId=@StatementProcessId 
    AND BmeStatementData_FromPartyType_code ='MP'
    AND BmeStatementData_ISARE=1
AND BmeStatementData_IsLegacy=1
        AND IsBackfeedInclude=0
    GROUP by BmeStatementData_NtdcDateTime    ,T.MtGenerator_Id,T.MtGenerator_Name
    ) as cdp on  DH.BmeStatementData_NtdcDateTime = cdp.BmeStatementData_NtdcDateTime
      where DH.BmeStatementData_Year=@Year and DH.BmeStatementData_Month=@Month and DH.BmeStatementData_StatementProcessId=@StatementProcessId 
GROUP BY  DH.BmeStatementData_NtdcDateTime,cdp.MtGenerator_Id,cdp.MtGenerator_Name
--ORDER BY 3
      ) AS CDp2
      ON
DHA.BmeStatementData_NtdcDateTime = cdp2.BmeStatementData_NtdcDateTime
      where DHA.BmeStatementData_Year=@Year and DHA.BmeStatementData_Month=@Month
      and DHA.BmeStatementData_StatementProcessId=@StatementProcessId 
GROUP BY DHA.BmeStatementData_NtdcDateTime
)
AS DHGenLeg 
ON cdpActual.BmeStatementData_NtdcDateTime=DHGenLeg.BmeStatementData_NtdcDateTime
      where cdpActual.BmeStatementData_Year=@Year and cdpActual.BmeStatementData_Month=@Month
      and cdpActual.BmeStatementData_StatementProcessId=@StatementProcessId 
;

------**********************	BackFeed=0 and To Party='MP'
------***********************************************************
				UPDATE cdpActual 
	set 
	BmeStatementData_EnergySuppliedGeneratedLegacy = ISNULL(BmeStatementData_EnergySuppliedGeneratedLegacy,0)
	+ ISNULL(DHGenLeg.GenlegacyActual,0)
	FROM BmeStatementDataHourly cdpActual INNER JOIN(
	SELECT   DHA.BmeStatementData_NtdcDateTime,Sum(IsNull(CDP2.LegacyGeneration,0)) AS GenlegacyActual
FROM BmeStatementDataHourly DHA
INNER JOIN(
SELECT
       DH.BmeStatementData_NtdcDateTime,
cdp.MtGenerator_Id,cdp.MtGenerator_Name
       ,
       SUM(
    ISNULL(
    CASE WHEN (ISNULL(BmeStatementData_AdjustedEnergyImport,0)- ISNULL(BmeStatementData_AdjustedEnergyExport,0))<0
    THEN 0
    ELSE
     (ISNULL(BmeStatementData_AdjustedEnergyImport,0)- ISNULL(BmeStatementData_AdjustedEnergyExport,0))
     END,0))AS LegacyGeneration
    FROM BmeStatementDataHourly DH
    INNER JOIN (select BmeStatementData_NtdcDateTime,t.MtGenerator_Id,t.MtGenerator_Name
    , Sum(ISNULL(BmeStatementData_AdjustedEnergyImport,0)) as BmeStatementData_AdjustedEnergyImport
    , Sum(ISNULL(BmeStatementData_AdjustedEnergyExport,0)) as BmeStatementData_AdjustedEnergyExport     
    from BmeStatementDataCdpHourly 
    JOIN #tempCdpGen t ON t.RuCDPDetail_CdpId=BmeStatementData_CdpId
      where BmeStatementDataCdpHourly.BmeStatementData_Year=@Year and BmeStatementDataCdpHourly.BmeStatementData_Month=@Month and BmeStatementDataCdpHourly.BmeStatementData_StatementProcessId=@StatementProcessId 
    AND BmeStatementData_ToPartyType_code ='MP'
    AND BmeStatementData_ISARE=1
AND BmeStatementData_IsLegacy=1
        AND IsBackfeedInclude=0
    GROUP by BmeStatementData_NtdcDateTime    ,T.MtGenerator_Id,T.MtGenerator_Name
    ) as cdp on  DH.BmeStatementData_NtdcDateTime = cdp.BmeStatementData_NtdcDateTime
      where DH.BmeStatementData_Year=@Year and DH.BmeStatementData_Month=@Month and DH.BmeStatementData_StatementProcessId=@StatementProcessId 
GROUP BY  DH.BmeStatementData_NtdcDateTime,cdp.MtGenerator_Id,cdp.MtGenerator_Name
--ORDER BY 3
      ) AS CDp2
      ON
DHA.BmeStatementData_NtdcDateTime = cdp2.BmeStatementData_NtdcDateTime
      where DHA.BmeStatementData_Year=@Year and DHA.BmeStatementData_Month=@Month
      and DHA.BmeStatementData_StatementProcessId=@StatementProcessId 
GROUP BY DHA.BmeStatementData_NtdcDateTime
)
AS DHGenLeg 
ON cdpActual.BmeStatementData_NtdcDateTime=DHGenLeg.BmeStatementData_NtdcDateTime
      where cdpActual.BmeStatementData_Year=@Year and cdpActual.BmeStatementData_Month=@Month
      and cdpActual.BmeStatementData_StatementProcessId=@StatementProcessId 
;

						   
/*
---------------------

UPDATE BmeStatementDataMpCategoryHourly 
	set 
	BmeStatementData_EnergySuppliedGeneratedLegacy = cdp.BmeStatementData_EnergySuppliedGenerated
	FROM BmeStatementDataMpCategoryHourly as dh inner join
           (
		   select OP.BmeStatementData_OwnerPartyRegisteration_Id,op.BmeStatementData_OwnerPartyCategory_Code
		   ,OP.BmeStatementData_CongestedZoneID
		   ,BmeStatementData_NtdcDateTime, 
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
	where CDPH.BmeStatementData_Year = @Year and CDPH.BmeStatementData_Month = @Month AND CDPH.BmeStatementData_StatementProcessId=@StatementProcessId
AND CDPH.BmeStatementData_IsEnergyImported=0
AND CDPH.BmeStatementData_ISARE=1
AND CDPH.BmeStatementData_IsLegacy=1

		GROUP BY OP.BmeStatementData_OwnerPartyRegisteration_Id, BmeStatementData_NtdcDateTime
		,OP.BmeStatementData_OwnerPartyCategory_Code,OP.BmeStatementData_CongestedZoneID
		   ) cdp  on 
		   dh.BmeStatementData_PartyRegisteration_Id = cdp.BmeStatementData_OwnerPartyRegisteration_Id 
		   and dh.BmeStatementData_NtdcDateTime = cdp.BmeStatementData_NtdcDateTime
		   and dh.BmeStatementData_PartyCategory_Code=cdp.BmeStatementData_OwnerPartyCategory_Code
		   and dh.BmeStatementData_CongestedZoneID=cdp.BmeStatementData_CongestedZoneID;
*/						   
-----------------------------------------

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
isnull(BmeStatementData_IsEnergyImported,0)=1
AND BmeStatementData_ISARE=1
AND BmeStatementData_IsLegacy=1
AND BmeStatementData_Year=@Year and BmeStatementData_Month=@Month and BmeStatementData_StatementProcessId=@StatementProcessId
		GROUP BY BmeStatementData_NtdcDateTime
		   ) CDPH  on DH.BmeStatementData_NtdcDateTime = CDPH.BmeStatementData_NtdcDateTime

 where DH.BmeStatementData_Year = @Year and DH.BmeStatementData_Month = @Month AND DH.BmeStatementData_StatementProcessId=@StatementProcessId 

		   
----------------------
/*
UPDATE BmeStatementDataMpCategoryHourly 
	set 
	BmeStatementData_EnergySuppliedImportedLegacy = cdp.BmeStatementData_EnergySuppliedImported
	FROM BmeStatementDataMpCategoryHourly as dh inner join
           (
		   select OP.BmeStatementData_OwnerPartyRegisteration_Id,BmeStatementData_NtdcDateTime
		   ,OP.BmeStatementData_OwnerPartyCategory_Code
		   ,OP.BmeStatementData_CongestedZoneID, 
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
	where CDPH.BmeStatementData_Year = @Year and CDPH.BmeStatementData_Month = @Month AND CDPH.BmeStatementData_StatementProcessId=@StatementProcessId
AND CDPH.BmeStatementData_IsEnergyImported=1
AND CDPH.BmeStatementData_ISARE=1
AND CDPH.BmeStatementData_IsLegacy=1

		GROUP BY OP.BmeStatementData_OwnerPartyRegisteration_Id,OP.BmeStatementData_OwnerPartyCategory_Code,
		OP.BmeStatementData_CongestedZoneID,BmeStatementData_NtdcDateTime
		   ) cdp  on dh.BmeStatementData_PartyRegisteration_Id=cdp.BmeStatementData_OwnerPartyRegisteration_Id 
		   and dh.BmeStatementData_NtdcDateTime = cdp.BmeStatementData_NtdcDateTime
		   and dh.BmeStatementData_PartyCategory_Code=cdp.BmeStatementData_OwnerPartyCategory_Code
		   and dh.BmeStatementData_CongestedZoneID=cdp.BmeStatementData_CongestedZoneID;

 */          

 

--update Cap excluding allocation factor
UPDATE BmeStatementDataHourly
SET 
BmeStatementData_CAPLegacy=
(ISNULL( BmeStatementData_EnergySuppliedGeneratedLegacy,0)
+ISNULL(BmeStatementData_ActualCapacity,0))
From BmeStatementDataHourly
WHERE 
 BmeStatementData_Year=@Year and BmeStatementData_Month=@Month
 and BmeStatementData_StatementProcessId=@StatementProcessId



SELECT 1 AS [IS_VALID], @@ROWCOUNT AS [ROW_COUNT], OBJECT_NAME(@@PROCID) AS [SP_NAME];

-----------------------------
-- Energy Traded
-----------------------------
 EXECUTE [dbo].[BME_Step7APerform] @Year ,@Month,@StatementProcessId ;

----------------------------------
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
