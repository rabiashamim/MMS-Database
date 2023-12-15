/****** Object:  Procedure [dbo].[BME_Step5Perform]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- updated /*TaskId*3897**date*02-10-2023*/
-- =============================================
--dbo.BME_Step5Perform 2023,8,227
CREATE   Procedure dbo.BME_Step5Perform(			 
			@Year int,
			@Month int
			,@StatementProcessId decimal(18,0) = null)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
BEGIN TRY
	----1----------Insert distinct party Ids in MpHourly Table
IF NOT EXISTS(SELECT TOP 1 BmeStatementData_Id FROM [BmeStatementDataMpHourly] WHERE  BmeStatementData_Year=@Year and BmeStatementData_Month=@Month and BmeStatementData_StatementProcessId=@StatementProcessId)
BEGIN
	
	

	INSERT INTO [dbo].[BmeStatementDataMpHourly]
           (
               [BmeStatementData_StatementProcessId]
		    ,[BmeStatementData_PartyRegisteration_Id]
           ,[BmeStatementData_PartyName]          
           ,[BmeStatementData_PartyType_Code]	
		   ,[BmeStatementData_Year]
           ,[BmeStatementData_Month]
		    ,[BmeStatementData_Day]
		    ,[BmeStatementData_Hour]
		   ,[BmeStatementData_NtdcDateTime]         
		   ,[BmeStatementData_IsPowerPool]		   
		)
		select distinct 
            @StatementProcessId
		   ,BmeParty.[BmeStatementData_OwnerPartyRegisteration_Id]
           ,BmeParty.[BmeStatementData_OwnerPartyRegisteration_Name]
           ,BmeParty.[BmeStatementData_OwnerPartyType_Code]
			
			,Cdp.[BmeStatementData_Year]
			,Cdp.[BmeStatementData_Month]
			,Cdp.[BmeStatementData_Day]
			,Cdp.[BmeStatementData_Hour] 
			,Cdp.[BmeStatementData_NtdcDateTime]
            ,Isnull(BmeParty.[BmeStatementData_IsPowerPool],0) 		
			
	from  [dbo].[BmeStatementDataCdpOwnerParty] BmeParty
	inner join BmeStatementDataCdpHourly cdp
	on Cdp.BmeStatementData_CdpId=BmeParty.BmeStatementData_CdpId
    and Cdp.BmeStatementData_StatementProcessId=BmeParty.BmeStatementData_StatementProcessId
	 WHERE  Cdp.BmeStatementData_Year=@Year and Cdp.BmeStatementData_Month=@Month and Cdp.BmeStatementData_StatementProcessId=@StatementProcessId AND
	  BmeParty.BmeStatementData_StatementProcessId=@StatementProcessId;
	    	/**************************		Temp Table for Generators Information ********************************/
	/*****************************************************************************************************/
	select DISTINCT cdp.RuCDPDetail_CdpId,
g.MtGenerator_Name 
,g.MtGenerator_Id
,gu.MtGenerationUnit_Id
INTO #tempCdpGen
FROM MtGenerator g
inner join MtGenerationUnit gu on gu.MtGenerator_Id=g.MtGenerator_Id
inner JOIN MtConnectedMeter mcm on mcm.MtConnectedMeter_UnitId=gu.MtGenerationUnit_Id
inner join RuCDPDetail cdp on cdp.RuCDPDetail_Id=mcm.MtCDPDetail_Id
where isnull( g.MtGenerator_IsDeleted,0)=0
and isnull(gu.MtGenerationUnit_IsDeleted,0)=0
and isnull(mcm.MtConnectedMeter_isDeleted,0)=0
AND ISNULL(g.isDeleted,0)=0
AND mcm.MtPartyCategory_Id NOT IN (SELECT MtPartyCategory_Id FROM MtPartyCategory MPC WHERE MPC.SrCategory_Code IN ('BPC','EBPC') AND ISNULL(MPC.isDeleted,0)=0); 

	
	insert into BmeStatementDataMpCategoryHourly (
        [BmeStatementData_StatementProcessId]
        ,[BmeStatementData_PartyRegisteration_Id]
		,[BmeStatementData_PartyName]
		,[BmeStatementData_PartyCategory_Code]
        ,[BmeStatementData_PartyType_Code]
		,[BmeStatementData_NtdcDateTime]
      ,[BmeStatementData_Year]
      ,[BmeStatementData_Month]
      ,[BmeStatementData_Day]
      ,[BmeStatementData_Hour]
      ,[BmeStatementData_IsPowerPool] 
	  ,BmeStatementData_CongestedZoneID
      ,BmeStatementData_CongestedZone
)
	select distinct 
            @StatementProcessId
		   ,BmeParty.[BmeStatementData_OwnerPartyRegisteration_Id]
           ,BmeParty.[BmeStatementData_OwnerPartyRegisteration_Name]
           ,BmeParty.[BmeStatementData_OwnerPartyCategory_Code]
           ,BmeParty.[BmeStatementData_OwnerPartyType_Code]
			,Cdp.[BmeStatementData_NtdcDateTime]
			,Cdp.[BmeStatementData_Year]
			,Cdp.[BmeStatementData_Month]
			,Cdp.[BmeStatementData_Day]
			,Cdp.[BmeStatementData_Hour]  
            ,Isnull(BmeParty.[BmeStatementData_IsPowerPool],0) 
			,cdp.BmeStatementData_CongestedZoneID
            ,cdp.BmeStatementData_CongestedZone
	from  [dbo].[BmeStatementDataCdpOwnerParty] BmeParty
	inner join BmeStatementDataCdpHourly cdp
	on Cdp.BmeStatementData_CdpId=BmeParty.BmeStatementData_CdpId
	WHERE  Cdp.BmeStatementData_Year=@Year and Cdp.BmeStatementData_Month=@Month and Cdp.BmeStatementData_StatementProcessId=@StatementProcessId AND
	  BmeParty.BmeStatementData_StatementProcessId=@StatementProcessId;


	/*****************************************************************************************************/
	-- Category mp wise actual energy case 2
	/*****************************************************************************************************/

WITH ActualEnergy_CTE_CategoryWise2
AS
(
select  r.BmeStatementData_OwnerPartyRegisteration_Id,r.BmeStatementData_NtdcDateTime
,r.BmeStatementData_OwnerPartyCategory_Code,r.BmeStatementData_CongestedZoneID

,SUM(ISNULL(r.Case1ActualEnergy,0)+ISNULL(r.Case2ActualEnergy,0)+ISNULL(r.Case3ActualEnergy,0)+ISNULL(r.Case4ActualEnergy,0)) as BmeStatementData_ActualEnergy 
,SUM(ISNULL(r.Case1ActualEnergy_Metered,0)+ISNULL(r.Case2ActualEnergy_Metered,0)+ISNULL(r.Case3ActualEnergy_Metered,0)+ISNULL(r.Case4ActualEnergy_Metered,0)) 
as BmeStatementData_ActualEnergy_Metered
from
  (
  select 
     OP.BmeStatementData_OwnerPartyRegisteration_Id,OP.BmeStatementData_OwnerPartyCategory_Code,OP.BmeStatementData_CongestedZoneID
	,BmeStatementData_NtdcDateTime,
	
		CASE  WHEN  CDPH.BmeStatementData_ToPartyType_Code='SP' --,'GEN','CGEN','EGEN'
		AND OP.BmeStatementData_OwnerPartyCategory_Code in ('BPC','PAKT','INTT','CSUP','EBPC')  

	THEN	
	 ISNULL(CDPH.BmeStatementData_AdjustedEnergyImport,0) 
	
	end as Case1ActualEnergy,
	



	CASE WHEN CDPH.BmeStatementData_FromPartyType_Code='SP' AND OP.BmeStatementData_OwnerPartyCategory_Code in ('BPC','PAKT','INTT','CSUP','EBPC')
	THEN
	  ISNULL(CDPH.BmeStatementData_AdjustedEnergyExport,0)
	 
	end as Case2ActualEnergy,
	

	CASE WHEN  CDPH.BmeStatementData_FromPartyType_Code ='SP' and CDPH.BmeStatementData_FromPartyCategory_Code='DSP' AND OP.BmeStatementData_OwnerPartyCategory_Code='BSUP'
    
	and  exists (SELECT 1 FROM Bme_Parties P
		WHERE P.PartyRegisteration_Id=CDPH.BmeStatementData_FromPartyRegisteration_Id
        and P.MPId = OP.BmeStatementData_OwnerPartyRegisteration_Id		 
		)
	
	THEN
 ISNULL(CDPH.BmeStatementData_AdjustedEnergyImport,0) - ISNULL(CDPH.BmeStatementData_AdjustedEnergyExport,0)
 end as Case3ActualEnergy,
  
  CASE WHEN  CDPH.BmeStatementData_ToPartyType_Code ='SP' and CDPH.BmeStatementData_ToPartyCategory_Code='DSP' AND OP.BmeStatementData_OwnerPartyCategory_Code='BSUP'
  
	
	and  exists (SELECT 1 FROM Bme_Parties P
		WHERE P.PartyRegisteration_Id=CDPH.BmeStatementData_ToPartyRegisteration_Id
        and P.MPId = OP.BmeStatementData_OwnerPartyRegisteration_Id		 
		)
	THEN
	
    ISNULL(CDPH.BmeStatementData_AdjustedEnergyExport,0)- ISNULL(CDPH.BmeStatementData_AdjustedEnergyImport,0)
	END as Case4ActualEnergy

		/*********************
	CASE 1 Metered
	*********************/
	,	CASE  WHEN  CDPH.BmeStatementData_ToPartyType_Code='SP'
		AND OP.BmeStatementData_OwnerPartyCategory_Code in ('BPC','PAKT','INTT','CSUP','EBPC')  

	THEN	
	 ISNULL(CDPH.BmeStatementData_IncEnergyImport,0) 
	
	end as Case1ActualEnergy_Metered,
		/*********************
	CASE 2 Metered
	*********************/
	CASE WHEN CDPH.BmeStatementData_FromPartyType_Code='SP' AND OP.BmeStatementData_OwnerPartyCategory_Code in ('BPC','PAKT','INTT','CSUP','EBPC')
	THEN
	 ISNULL(CDPH.BmeStatementData_IncEnergyExport,0)
	 
	end as Case2ActualEnergy_Metered,
	 /*********************
	CASE 3 Metered
	*********************/

	CASE WHEN  CDPH.BmeStatementData_FromPartyType_Code ='SP' and CDPH.BmeStatementData_FromPartyCategory_Code='DSP' AND OP.BmeStatementData_OwnerPartyCategory_Code='BSUP'
    
	and  exists (SELECT 1 FROM Bme_Parties P
		WHERE P.PartyRegisteration_Id=CDPH.BmeStatementData_FromPartyRegisteration_Id
        and P.MPId = OP.BmeStatementData_OwnerPartyRegisteration_Id		 
		)
	
	THEN
 ISNULL(CDPH.BmeStatementData_IncEnergyImport,0) - ISNULL(CDPH.BmeStatementData_IncEnergyExport,0)
 end as Case3ActualEnergy_Metered,
   /*********************
	CASE 4 Metered
	*********************/
  CASE WHEN  CDPH.BmeStatementData_ToPartyType_Code ='SP' and CDPH.BmeStatementData_ToPartyCategory_Code='DSP' AND OP.BmeStatementData_OwnerPartyCategory_Code='BSUP'
  
	
	and  exists (SELECT 1 FROM Bme_Parties P
		WHERE P.PartyRegisteration_Id=CDPH.BmeStatementData_ToPartyRegisteration_Id
        and P.MPId = OP.BmeStatementData_OwnerPartyRegisteration_Id		 
		)
	THEN
	
    ISNULL(CDPH.BmeStatementData_IncEnergyExport,0)- ISNULL(CDPH.BmeStatementData_IncEnergyImport,0)
	END as Case4ActualEnergy_Metered

	from BmeStatementDataCdpHourly CDPH
	INNER JOIN  BmeStatementDataCdpOwnerParty  OP 
	ON OP.BmeStatementData_CdpId=CDPH.BmeStatementData_CdpId  
    and OP.BmeStatementData_StatementProcessId=CDPH.BmeStatementData_StatementProcessId	
	where CDPH.BmeStatementData_Year = @Year and CDPH.BmeStatementData_Month = @Month AND CDPH.BmeStatementData_StatementProcessId=@StatementProcessId
	--and CDPH.IsBackfeedInclude=1
	/*TaskId*3897**date*02-10-2023*/
	--AND op.BmeStatementData_IsPowerPool=1
	) as r
		GROUP by r.BmeStatementData_OwnerPartyRegisteration_Id,r.BmeStatementData_OwnerPartyCategory_Code,r.BmeStatementData_CongestedZoneID
	, r.BmeStatementData_NtdcDateTime
)


UPDATE BmeStatementDataMpCategoryHourly 
set BmeStatementData_ActualEnergy = IsNull(CH.BmeStatementData_ActualEnergy,0)+cdp.BmeStatementData_ActualEnergy
,BmeStatementData_ActualEnergy_Metered = IsNull(CH.BmeStatementData_ActualEnergy_Metered,0)+cdp.BmeStatementData_ActualEnergy_Metered
	FROM BmeStatementDataMpCategoryHourly CH
	INNER JOIN  ActualEnergy_CTE_CategoryWise2 as cdp 
	on CH.BmeStatementData_PartyRegisteration_Id=cdp.BmeStatementData_OwnerPartyRegisteration_Id 
	and CH.BmeStatementData_NtdcDateTime = cdp.BmeStatementData_NtdcDateTime
	and CH.BmeStatementData_PartyCategory_Code=cdp.BmeStatementData_OwnerPartyCategory_Code 
	and CH.BmeStatementData_CongestedZoneID=cdp.BmeStatementData_CongestedZoneID 
      where CH.BmeStatementData_Year=@Year and CH.BmeStatementData_Month=@Month and CH.BmeStatementData_StatementProcessId=@StatementProcessId ;
    ;

/*--------------------------------------------------------------------------------
*
--------------------------------------------------------------------------------*/
--DROP TABLE IF EXISTS #partCategoryGen
SELECT 
	P.MtPartyRegisteration_Id
	,PC.SrCategory_Code
	,G.MtGenerator_Id 
INTO #partCategoryGen
FROM MtPartyRegisteration P
JOIN MtPartyCategory PC ON P.MtPartyRegisteration_Id=PC.MtPartyRegisteration_Id
JOIN MtGenerator G ON G.MtPartyCategory_Id=PC.MtPartyCategory_Id
WHERE ISNULL(P.isDeleted,0)=0 AND ISNULL(pc.isDeleted,0)=0 AND 
PC.SrCategory_Code IN ( 'GEN', 'CGEN', 'EGEN') 
 
/*--------------------------------------------------------------------------------
*
--------------------------------------------------------------------------------*/
 --DROP TABLE IF EXISTS #GenBF
SELECT 
 GU.BmeStatementData_MtGenerator_Id
,GU.BmeStatementData_NtdcDateTime
,SUM(ISNULL(GU.BmeStatementData_UnitWiseGenerationBackFeed,0)) AS BF 
,SUM(ISNULL(GU.BmeStatementData_UnitWiseGenerationBackFeed_Metered,0)) AS BFM 
INTO #GenBF
FROM BmeStatementDataGenUnitHourly  GU
WHERE 
--BmeStatementData_StatementProcessId=227 AND BmeStatementData_Day=1 AND BmeStatementData_Hour=1
BmeStatementData_StatementProcessId=@StatementProcessId AND GU.BmeStatementData_Month=@Month AND GU.BmeStatementData_Year=@Year
GROUP BY BmeStatementData_MtGenerator_Id,GU.BmeStatementData_NtdcDateTime

/*--------------------------------------------------------------------------------
*
--------------------------------------------------------------------------------*/
--DROP TABLE IF EXISTS #GeneratorBackFeedCategoryWise
SELECT PC.MtPartyRegisteration_Id
, PC.SrCategory_Code
,GBF.BmeStatementData_NtdcDateTime
,SUM( ISNULL(GBF.BF,0)) AS BF
,SUM(ISNULL(GBF.BFM,0)) AS BFM
INTO #GeneratorBackFeedCategoryWise
FROM #GenBF GBF
JOIN #partCategoryGen PC ON GBF.BmeStatementData_MtGenerator_Id=PC.MtGenerator_Id
GROUP BY PC.MtPartyRegisteration_Id
, PC.SrCategory_Code ,GBF.BmeStatementData_NtdcDateTime

--SELECT * FROM #GeneratorBackFeedCategoryWise WHERE MtPartyRegisteration_Id=1
/*--------------------------------------------------------------------------------
*
--------------------------------------------------------------------------------*/



UPDATE BmeStatementDataMpCategoryHourly 
	set BmeStatementData_ActualEnergy = IsNull(CH.BmeStatementData_ActualEnergy,0)+ISNULL(GBF.BF,0)
	, BmeStatementData_ActualEnergy_Metered = IsNull(CH.BmeStatementData_ActualEnergy_Metered,0)+ISNULL(GBF.BFM,0)
	
	FROM BmeStatementDataMpCategoryHourly CH
	INNER JOIN  #GeneratorBackFeedCategoryWise as GBF 
	on CH.BmeStatementData_PartyRegisteration_Id=GBF.MtPartyRegisteration_Id
	and CH.BmeStatementData_NtdcDateTime = GBF.BmeStatementData_NtdcDateTime
	and CH.BmeStatementData_PartyCategory_Code=GBF.SrCategory_Code 
	--and CH.BmeStatementData_CongestedZoneID=cdp.BmeStatementData_CongestedZoneID 
      where CH.BmeStatementData_Year=@Year and CH.BmeStatementData_Month=@Month and CH.BmeStatementData_StatementProcessId=@StatementProcessId ;
    ;

/*--------------------------------------------------------------------------------
*
--------------------------------------------------------------------------------*/
UPDATE MPH
SET MPH.BmeStatementData_ActualEnergy= CMPH.AE
,MPH.BmeStatementData_ActualEnergy_Metered= CMPH.AEM
FROM BmeStatementDataMpHourly MPH
JOIN  (
SELECT 
 CH.BmeStatementData_PartyRegisteration_Id
,CH.BmeStatementData_NtdcDateTime
,SUM(BmeStatementData_ActualEnergy) AS AE
,SUM(BmeStatementData_ActualEnergy_Metered) AS AEM

FROM BmeStatementDataMpCategoryHourly CH
where CH.BmeStatementData_Year=@Year and CH.BmeStatementData_Month=@Month and CH.BmeStatementData_StatementProcessId=@StatementProcessId 
GROUP BY BmeStatementData_PartyRegisteration_Id,BmeStatementData_NtdcDateTime
)  CMPH ON CMPH.BmeStatementData_PartyRegisteration_Id = MPH.BmeStatementData_PartyRegisteration_Id
AND CMPH.BmeStatementData_NtdcDateTime=MPH.BmeStatementData_NtdcDateTime
where MPH.BmeStatementData_Year=@Year and MPH.BmeStatementData_Month=@Month and MPH.BmeStatementData_StatementProcessId=@StatementProcessId 

/*--------------------------------------------------------------------------------
*
--------------------------------------------------------------------------------*/

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
