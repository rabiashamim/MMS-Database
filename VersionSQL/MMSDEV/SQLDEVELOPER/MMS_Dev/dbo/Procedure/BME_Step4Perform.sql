/****** Object:  Procedure [dbo].[BME_Step4Perform]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
-- [BME_Step4Perform]  2022,6,18
CREATE PROCEDURE dbo.BME_Step4Perform(			 
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

     IF  EXISTS(SELECT TOP 1 BmeStatementData_Id FROM BmeStatementDataHourly 
     WHERE  BmeStatementData_Year=@Year and BmeStatementData_Month=@Month and BmeStatementData_StatementProcessId=@StatementProcessId)
    BEGIN
-------------------------------------
/*
	insert into BmeStatementDataHourly (
         [BmeStatementData_StatementProcessId]
         ,[BmeStatementData_NtdcDateTime]
        ,[BmeStatementData_Year]
        ,[BmeStatementData_Month]
        ,[BmeStatementData_Day]
        ,[BmeStatementData_Hour]
  
)
	select distinct 
	     @StatementProcessId
         ,[BmeStatementData_NtdcDateTime]
        ,[BmeStatementData_Year]
        ,[BmeStatementData_Month]
        ,[BmeStatementData_Day]
        ,[BmeStatementData_Hour] 


 from BmeStatementDataCdpHourly
	 WHERE  BmeStatementData_Year=@Year and BmeStatementData_Month=@Month and BmeStatementData_StatementProcessId=@StatementProcessId
*/	 
/*
	
	/**************************		Temp Table for Generators Information ********************************/
	/*****************************************************************************************************/
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

	/*****************************************************************************************************/
	/*****************************************************************************************************/




------------------------------------
--steps  3.3
-- Case 1
	--UPDATE BmeStatementDataHourly 
	--set 
	--BmeStatementData_DemandedEnergy =
	--IsNull(DH.BmeStatementData_DemandedEnergy,0)+ (ISNULL(cdp.BmeStatementData_AdjustedEnergyExport,0))
	--FROM BmeStatementDataHourly DH
	--INNER JOIN (select BmeStatementData_NtdcDateTime
	--, Sum(BmeStatementData_AdjustedEnergyImport) as BmeStatementData_AdjustedEnergyImport
	--, Sum(BmeStatementData_AdjustedEnergyExport) as BmeStatementData_AdjustedEnergyExport	 from BmeStatementDataCdpHourly
	--where BmeStatementDataCdpHourly.BmeStatementData_Year=@Year and BmeStatementDataCdpHourly.BmeStatementData_Month=@Month and BmeStatementDataCdpHourly.BmeStatementData_StatementProcessId=@StatementProcessId
	--AND IsBackfeedInclude=1
	--AND	 BmeStatementData_FromPartyCategory_Code='TSP' 
 --   AND BmeStatementData_ToPartyCategory_Code='DSP' 
	--GROUP by BmeStatementData_NtdcDateTime	
	--) as cdp on  DH.BmeStatementData_NtdcDateTime = cdp.BmeStatementData_NtdcDateTime
 --    where DH.BmeStatementData_Year=@Year and DH.BmeStatementData_Month=@Month and DH.BmeStatementData_StatementProcessId=@StatementProcessId ;
	UPDATE BmeStatementDataHourly 
	set 
	BmeStatementData_DemandedEnergy =IsNull(DH.BmeStatementData_DemandedEnergy,0)+ (IsNull(cdp.BmeStatementData_AdjustedEnergyExport,0)-ISNULL(cdp.BmeStatementData_AdjustedEnergyImport,0))	
	FROM BmeStatementDataHourly DH
	INNER JOIN (select BmeStatementData_NtdcDateTime
	, Sum(BmeStatementData_AdjustedEnergyImport) as BmeStatementData_AdjustedEnergyImport
	, Sum(BmeStatementData_AdjustedEnergyExport) as BmeStatementData_AdjustedEnergyExport	 from BmeStatementDataCdpHourly
	where BmeStatementDataCdpHourly.BmeStatementData_Year=@Year and BmeStatementDataCdpHourly.BmeStatementData_Month=@Month and BmeStatementDataCdpHourly.BmeStatementData_StatementProcessId=@StatementProcessId
	AND	 BmeStatementData_FromPartyCategory_Code='TSP' 
    AND BmeStatementData_ToPartyCategory_Code='DSP' 
	GROUP by BmeStatementData_NtdcDateTime	
	) as cdp on  DH.BmeStatementData_NtdcDateTime = cdp.BmeStatementData_NtdcDateTime
     where DH.BmeStatementData_Year=@Year and DH.BmeStatementData_Month=@Month and DH.BmeStatementData_StatementProcessId=@StatementProcessId ;



-- case 2

--UPDATE BmeStatementDataHourly 
--	set 
--	BmeStatementData_DemandedEnergy =
--	IsNull(DH.BmeStatementData_DemandedEnergy,0)+ (IsNull(cdp.BmeStatementData_AdjustedEnergyExport,0)-ISNULL(cdp.BmeStatementData_AdjustedEnergyImport,0))	
--	FROM BmeStatementDataHourly DH
--	INNER JOIN (select BmeStatementData_NtdcDateTime
--	, Sum(BmeStatementData_AdjustedEnergyImport) as BmeStatementData_AdjustedEnergyImport
--	, Sum(BmeStatementData_AdjustedEnergyExport) as BmeStatementData_AdjustedEnergyExport	 from BmeStatementDataCdpHourly
--	where BmeStatementDataCdpHourly.BmeStatementData_Year=@Year and BmeStatementDataCdpHourly.BmeStatementData_Month=@Month and BmeStatementDataCdpHourly.BmeStatementData_StatementProcessId=@StatementProcessId
--	AND IsBackfeedInclude=0
--	AND	 BmeStatementData_FromPartyCategory_Code='TSP' 
--    AND BmeStatementData_ToPartyCategory_Code='DSP' 
--	GROUP by BmeStatementData_NtdcDateTime	
--	) as cdp on  DH.BmeStatementData_NtdcDateTime = cdp.BmeStatementData_NtdcDateTime
--     where DH.BmeStatementData_Year=@Year and DH.BmeStatementData_Month=@Month and DH.BmeStatementData_StatementProcessId=@StatementProcessId ;


	UPDATE BmeStatementDataHourly 
	set 
	BmeStatementData_DemandedEnergy =IsNull(DH.BmeStatementData_DemandedEnergy,0)+ (ISNULL(cdp.BmeStatementData_AdjustedEnergyImport,0)- ISNULL(cdp.BmeStatementData_AdjustedEnergyExport,0))	
	FROM BmeStatementDataHourly DH
	INNER JOIN (select BmeStatementData_NtdcDateTime
	, Sum(BmeStatementData_AdjustedEnergyImport) as BmeStatementData_AdjustedEnergyImport
	, Sum(BmeStatementData_AdjustedEnergyExport) as BmeStatementData_AdjustedEnergyExport	 from BmeStatementDataCdpHourly
	where BmeStatementDataCdpHourly.BmeStatementData_Year=@Year and BmeStatementDataCdpHourly.BmeStatementData_Month=@Month and BmeStatementDataCdpHourly.BmeStatementData_StatementProcessId=@StatementProcessId
	AND	 BmeStatementData_FromPartyCategory_Code='DSP' 
    AND BmeStatementData_ToPartyCategory_Code='TSP' 
	GROUP by BmeStatementData_NtdcDateTime	
	) as cdp on  DH.BmeStatementData_NtdcDateTime = cdp.BmeStatementData_NtdcDateTime
      where DH.BmeStatementData_Year=@Year and DH.BmeStatementData_Month=@Month and DH.BmeStatementData_StatementProcessId=@StatementProcessId ;


	--steps  3.3

--Update dbo.BmeStatementDataHourly
--	set	BmeStatementData_DemandedEnergy=BmeStatementData_AdjustedEnergyExport-BmeStatementData_AdjustedEnergyImport
--WHERE 
--BmeStatementData_Year=@Year and BmeStatementData_Month=@Month and BmeStatementData_StatementProcessId=@StatementProcessId and
--   BmeStatementData_FromPartyCategory_Code='TSP' 
--   AND BmeStatementData_ToPartyCategory_Code='DSP' ;

--case 4A

	--UPDATE BmeStatementDataHourly 
	--set 
	--BmeStatementData_DemandedEnergy =IsNull(DH.BmeStatementData_DemandedEnergy,0)+ ISNULL(cdp.BmeStatementData_AdjustedEnergyImport,0)	
	--FROM BmeStatementDataHourly DH
	--INNER JOIN (select BmeStatementData_NtdcDateTime
	--, Sum(BmeStatementData_AdjustedEnergyImport) as BmeStatementData_AdjustedEnergyImport
	--, Sum(BmeStatementData_AdjustedEnergyExport) as BmeStatementData_AdjustedEnergyExport	 from BmeStatementDataCdpHourly
	--where BmeStatementDataCdpHourly.BmeStatementData_Year=@Year and BmeStatementDataCdpHourly.BmeStatementData_Month=@Month and BmeStatementDataCdpHourly.BmeStatementData_StatementProcessId=@StatementProcessId
	--AND IsBackfeedInclude=1
	--AND	 BmeStatementData_FromPartyCategory_Code='DSP' 
 --   AND BmeStatementData_ToPartyCategory_Code='TSP' 
	--GROUP by BmeStatementData_NtdcDateTime	
	--) as cdp on  DH.BmeStatementData_NtdcDateTime = cdp.BmeStatementData_NtdcDateTime
 --     where DH.BmeStatementData_Year=@Year and DH.BmeStatementData_Month=@Month and DH.BmeStatementData_StatementProcessId=@StatementProcessId ;

--case 4B

	--UPDATE BmeStatementDataHourly 
	--set 
	--BmeStatementData_DemandedEnergy =IsNull(DH.BmeStatementData_DemandedEnergy,0)+ (ISNULL(cdp.BmeStatementData_AdjustedEnergyImport,0)- ISNULL(cdp.BmeStatementData_AdjustedEnergyExport,0))	
	--FROM BmeStatementDataHourly DH
	--INNER JOIN (select BmeStatementData_NtdcDateTime
	--, Sum(BmeStatementData_AdjustedEnergyImport) as BmeStatementData_AdjustedEnergyImport
	--, Sum(BmeStatementData_AdjustedEnergyExport) as BmeStatementData_AdjustedEnergyExport	 from BmeStatementDataCdpHourly
	--where BmeStatementDataCdpHourly.BmeStatementData_Year=@Year and BmeStatementDataCdpHourly.BmeStatementData_Month=@Month and BmeStatementDataCdpHourly.BmeStatementData_StatementProcessId=@StatementProcessId
	--AND IsBackfeedInclude=0
	--AND	 BmeStatementData_FromPartyCategory_Code='DSP' 
 --   AND BmeStatementData_ToPartyCategory_Code='TSP' 
	--GROUP by BmeStatementData_NtdcDateTime	
	--) as cdp on  DH.BmeStatementData_NtdcDateTime = cdp.BmeStatementData_NtdcDateTime
 --     where DH.BmeStatementData_Year=@Year and DH.BmeStatementData_Month=@Month and DH.BmeStatementData_StatementProcessId=@StatementProcessId ;

 ---------- Case 3A
	UPDATE BmeStatementDataHourly 
	set 
	BmeStatementData_DemandedEnergy =IsNull(BmeStatementData_DemandedEnergy,0)+ (ISNULL(cdp.BmeStatementData_AdjustedEnergyExport,0))	
	FROM BmeStatementDataHourly DH
	INNER JOIN (select BmeStatementData_NtdcDateTime
	, Sum(BmeStatementData_AdjustedEnergyImport) as BmeStatementData_AdjustedEnergyImport
	, Sum(BmeStatementData_AdjustedEnergyExport) as BmeStatementData_AdjustedEnergyExport	 from BmeStatementDataCdpHourly
	where BmeStatementDataCdpHourly.BmeStatementData_Year=@Year and BmeStatementDataCdpHourly.BmeStatementData_Month=@Month and BmeStatementDataCdpHourly.BmeStatementData_StatementProcessId=@StatementProcessId
	AND IsBackfeedInclude=1
	AND BmeStatementData_ToPartyCategory_Code NOT in ('TSP','DSP')	
    AND BmeStatementData_FromPartyCategory_Code='TSP' 
	GROUP by BmeStatementData_NtdcDateTime	
	) as cdp on  DH.BmeStatementData_NtdcDateTime = cdp.BmeStatementData_NtdcDateTime
      where DH.BmeStatementData_Year=@Year and DH.BmeStatementData_Month=@Month and DH.BmeStatementData_StatementProcessId=@StatementProcessId ;

	   ---------- Case 3B
	UPDATE BmeStatementDataHourly 
	set 
	BmeStatementData_DemandedEnergy =IsNull(BmeStatementData_DemandedEnergy,0)+ --(ISNULL(cdp.BmeStatementData_AdjustedEnergyExport,0))	
	ISNULL(
		CASE WHEN (ISNULL(BmeStatementData_AdjustedEnergyImport,0)- ISNULL(BmeStatementData_AdjustedEnergyExport,0))>0
    THEN 0
    ELSE
     ABS((ISNULL(BmeStatementData_AdjustedEnergyImport,0)- ISNULL(BmeStatementData_AdjustedEnergyExport,0)))
     END,0)


	FROM BmeStatementDataHourly DH
	INNER JOIN (select BmeStatementData_NtdcDateTime
	, Sum(BmeStatementData_AdjustedEnergyImport) as BmeStatementData_AdjustedEnergyImport
	, Sum(BmeStatementData_AdjustedEnergyExport) as BmeStatementData_AdjustedEnergyExport	 
	from BmeStatementDataCdpHourly
	    JOIN #tempCdpGen t ON t.RuCDPDetail_CdpId=BmeStatementData_CdpId
where BmeStatementDataCdpHourly.BmeStatementData_Year=@Year and BmeStatementDataCdpHourly.BmeStatementData_Month=@Month and BmeStatementDataCdpHourly.BmeStatementData_StatementProcessId=@StatementProcessId
	AND BmeStatementData_ToPartyCategory_Code NOT in ('TSP','DSP')	
    AND BmeStatementData_FromPartyCategory_Code='TSP' 
	AND IsBackfeedInclude=0
	GROUP by BmeStatementData_NtdcDateTime,T.MtGenerator_Id	
	) as cdp on  DH.BmeStatementData_NtdcDateTime = cdp.BmeStatementData_NtdcDateTime
      where DH.BmeStatementData_Year=@Year and DH.BmeStatementData_Month=@Month and DH.BmeStatementData_StatementProcessId=@StatementProcessId ;

--------------- Case 4A
	UPDATE BmeStatementDataHourly 
	set 
	BmeStatementData_DemandedEnergy =IsNull(BmeStatementData_DemandedEnergy,0)+ (ISNULL(cdp.BmeStatementData_AdjustedEnergyImport,0))	
	FROM BmeStatementDataHourly DH
	INNER JOIN (select BmeStatementData_NtdcDateTime
	, Sum(BmeStatementData_AdjustedEnergyImport) as BmeStatementData_AdjustedEnergyImport
	, Sum(BmeStatementData_AdjustedEnergyExport) as BmeStatementData_AdjustedEnergyExport	 from BmeStatementDataCdpHourly
	where BmeStatementDataCdpHourly.BmeStatementData_Year=@Year and BmeStatementDataCdpHourly.BmeStatementData_Month=@Month and BmeStatementDataCdpHourly.BmeStatementData_StatementProcessId=@StatementProcessId
	AND BmeStatementData_FromPartyCategory_Code NOT in ('TSP','DSP')	
    AND BmeStatementData_ToPartyCategory_Code='TSP' 
	AND IsBackfeedInclude=1
	GROUP by BmeStatementData_NtdcDateTime	
	) as cdp on  DH.BmeStatementData_NtdcDateTime = cdp.BmeStatementData_NtdcDateTime
      where DH.BmeStatementData_Year=@Year and DH.BmeStatementData_Month=@Month and DH.BmeStatementData_StatementProcessId=@StatementProcessId ;

--------------- Case 4B
		UPDATE BmeStatementDataHourly 
	set 
	BmeStatementData_DemandedEnergy =IsNull(BmeStatementData_DemandedEnergy,0)+CDp2.DemandSum
FROM BmeStatementDataHourly DHA
INNER JOIN(
SELECT
       DH.BmeStatementData_NtdcDateTime,
	SUM(ISNULL(CASE WHEN (ISNULL(BmeStatementData_AdjustedEnergyExport,0)- ISNULL(BmeStatementData_AdjustedEnergyImport,0))>0
    THEN 0
    ELSE
     ABS((ISNULL(BmeStatementData_AdjustedEnergyExport,0)- ISNULL(BmeStatementData_AdjustedEnergyImport,0)))
     END,0)) AS DemandSum
	FROM BmeStatementDataHourly DH
	INNER JOIN (select BmeStatementData_NtdcDateTime
	, Sum(BmeStatementData_AdjustedEnergyImport) as BmeStatementData_AdjustedEnergyImport
	, Sum(BmeStatementData_AdjustedEnergyExport) as BmeStatementData_AdjustedEnergyExport	 
	from BmeStatementDataCdpHourly
		    JOIN #tempCdpGen t ON t.RuCDPDetail_CdpId=BmeStatementData_CdpId

	where BmeStatementDataCdpHourly.BmeStatementData_Year=@Year and BmeStatementDataCdpHourly.BmeStatementData_Month=@Month and BmeStatementDataCdpHourly.BmeStatementData_StatementProcessId=@StatementProcessId
	AND BmeStatementData_FromPartyCategory_Code NOT in ('TSP','DSP')	
    AND BmeStatementData_ToPartyCategory_Code='TSP' 
	AND IsBackfeedInclude=0
	GROUP by BmeStatementData_NtdcDateTime	,T.MtGenerator_Id	
	) as cdp on  DH.BmeStatementData_NtdcDateTime = cdp.BmeStatementData_NtdcDateTime
      where DH.BmeStatementData_Year=@Year and DH.BmeStatementData_Month=@Month and DH.BmeStatementData_StatementProcessId=@StatementProcessId 
	  GROUP BY  DH.BmeStatementData_NtdcDateTime
	  ) AS CDp2
	  ON
DHA.BmeStatementData_NtdcDateTime = cdp2.BmeStatementData_NtdcDateTime
      where DHA.BmeStatementData_Year=@Year and DHA.BmeStatementData_Month=@Month and DHA.BmeStatementData_StatementProcessId=@StatementProcessId ;


--------- Case 5A
		UPDATE BmeStatementDataHourly 
	set 
	BmeStatementData_DemandedEnergy =IsNull(BmeStatementData_DemandedEnergy,0)+ (ISNULL(cdp.BmeStatementData_AdjustedEnergyExport,0))	
	FROM BmeStatementDataHourly DH
	INNER JOIN (select BmeStatementData_NtdcDateTime
	, Sum(BmeStatementData_AdjustedEnergyImport) as BmeStatementData_AdjustedEnergyImport
	, Sum(BmeStatementData_AdjustedEnergyExport) as BmeStatementData_AdjustedEnergyExport	 from BmeStatementDataCdpHourly
	where BmeStatementDataCdpHourly.BmeStatementData_Year=@Year and BmeStatementDataCdpHourly.BmeStatementData_Month=@Month and BmeStatementDataCdpHourly.BmeStatementData_StatementProcessId=@StatementProcessId
	AND BmeStatementData_FromPartyCategory_Code NOT in ('TSP','DSP')	
    AND BmeStatementData_ToPartyCategory_Code='DSP' 
	    AND IsBackfeedInclude=1
	GROUP by BmeStatementData_NtdcDateTime	
	) as cdp on  DH.BmeStatementData_NtdcDateTime = cdp.BmeStatementData_NtdcDateTime
      where DH.BmeStatementData_Year=@Year and DH.BmeStatementData_Month=@Month and DH.BmeStatementData_StatementProcessId=@StatementProcessId ;

	  --------- Case 5B
		UPDATE BmeStatementDataHourly 
	set 
	BmeStatementData_DemandedEnergy =IsNull(BmeStatementData_DemandedEnergy,0)+CDp2.DemandSum
FROM BmeStatementDataHourly DHA
INNER JOIN(
SELECT
       DH.BmeStatementData_NtdcDateTime,
	   SUM(
	ISNULL(
	CASE WHEN (ISNULL(BmeStatementData_AdjustedEnergyExport,0)- ISNULL(BmeStatementData_AdjustedEnergyImport,0))<0
    THEN 0
    ELSE
     (ISNULL(BmeStatementData_AdjustedEnergyExport,0)- ISNULL(BmeStatementData_AdjustedEnergyImport,0))
     END,0))AS DemandSum

	FROM BmeStatementDataHourly DH
	INNER JOIN (select BmeStatementData_NtdcDateTime
	, Sum(BmeStatementData_AdjustedEnergyImport) as BmeStatementData_AdjustedEnergyImport
	, Sum(BmeStatementData_AdjustedEnergyExport) as BmeStatementData_AdjustedEnergyExport	 
	from BmeStatementDataCdpHourly 
    JOIN #tempCdpGen t ON t.RuCDPDetail_CdpId=BmeStatementData_CdpId
	where BmeStatementDataCdpHourly.BmeStatementData_Year=@Year and BmeStatementDataCdpHourly.BmeStatementData_Month=@Month and BmeStatementDataCdpHourly.BmeStatementData_StatementProcessId=@StatementProcessId
	AND BmeStatementData_FromPartyCategory_Code NOT in ('TSP','DSP')	
    AND BmeStatementData_ToPartyCategory_Code='DSP' 
	    AND IsBackfeedInclude=0
	GROUP by BmeStatementData_NtdcDateTime	,T.MtGenerator_Id

	) as cdp on  DH.BmeStatementData_NtdcDateTime = cdp.BmeStatementData_NtdcDateTime
      where DH.BmeStatementData_Year=@Year and DH.BmeStatementData_Month=@Month and DH.BmeStatementData_StatementProcessId=@StatementProcessId 
GROUP BY  DH.BmeStatementData_NtdcDateTime
	  ) AS CDp2
	  ON
DHA.BmeStatementData_NtdcDateTime = cdp2.BmeStatementData_NtdcDateTime
      where DHA.BmeStatementData_Year=@Year and DHA.BmeStatementData_Month=@Month and DHA.BmeStatementData_StatementProcessId=@StatementProcessId ;



	  --------------- Case 6A
		UPDATE BmeStatementDataHourly 
	set 
	BmeStatementData_DemandedEnergy =IsNull(DH.BmeStatementData_DemandedEnergy,0)+ ISNULL(cdp.BmeStatementData_AdjustedEnergyImport,0)	
	FROM BmeStatementDataHourly DH
	INNER JOIN (select BmeStatementData_NtdcDateTime
	, Sum(BmeStatementData_AdjustedEnergyImport) as BmeStatementData_AdjustedEnergyImport
	, Sum(BmeStatementData_AdjustedEnergyExport) as BmeStatementData_AdjustedEnergyExport	 from BmeStatementDataCdpHourly
	where BmeStatementDataCdpHourly.BmeStatementData_Year=@Year and BmeStatementDataCdpHourly.BmeStatementData_Month=@Month and BmeStatementDataCdpHourly.BmeStatementData_StatementProcessId=@StatementProcessId
	AND BmeStatementData_ToPartyCategory_Code NOT in ('TSP','DSP')	
    AND BmeStatementData_FromPartyCategory_Code='DSP' 
    AND IsBackfeedInclude=1
	GROUP by BmeStatementData_NtdcDateTime	
	) as cdp on  DH.BmeStatementData_NtdcDateTime = cdp.BmeStatementData_NtdcDateTime
      where DH.BmeStatementData_Year=@Year and DH.BmeStatementData_Month=@Month and DH.BmeStatementData_StatementProcessId=@StatementProcessId ;

	  	  --------------- Case 6B
		UPDATE BmeStatementDataHourly 
	set 
	BmeStatementData_DemandedEnergy =IsNull(BmeStatementData_DemandedEnergy,0)+CDp2.DemandSum
FROM BmeStatementDataHourly DHA
INNER JOIN(
SELECT
       DH.BmeStatementData_NtdcDateTime,
	SUM(ISNULL(
	CASE WHEN (ISNULL(BmeStatementData_AdjustedEnergyImport,0)- ISNULL(BmeStatementData_AdjustedEnergyExport,0))<0
    THEN 0
    ELSE
     (ISNULL(BmeStatementData_AdjustedEnergyImport,0)- ISNULL(BmeStatementData_AdjustedEnergyExport,0))
     END,0)) AS DemandSum
	FROM BmeStatementDataHourly DH
	INNER JOIN (select BmeStatementData_NtdcDateTime
	, Sum(BmeStatementData_AdjustedEnergyImport) as BmeStatementData_AdjustedEnergyImport
	, Sum(BmeStatementData_AdjustedEnergyExport) as BmeStatementData_AdjustedEnergyExport	
	from BmeStatementDataCdpHourly
		    JOIN #tempCdpGen t ON t.RuCDPDetail_CdpId=BmeStatementData_CdpId
	where BmeStatementDataCdpHourly.BmeStatementData_Year=@Year and BmeStatementDataCdpHourly.BmeStatementData_Month=@Month and BmeStatementDataCdpHourly.BmeStatementData_StatementProcessId=@StatementProcessId
	AND BmeStatementData_ToPartyCategory_Code NOT in ('TSP','DSP')	
    AND BmeStatementData_FromPartyCategory_Code='DSP' 
    AND IsBackfeedInclude=0
	GROUP by BmeStatementData_NtdcDateTime	,T.MtGenerator_Id
	) as cdp on  DH.BmeStatementData_NtdcDateTime = cdp.BmeStatementData_NtdcDateTime
      where DH.BmeStatementData_Year=@Year and DH.BmeStatementData_Month=@Month and DH.BmeStatementData_StatementProcessId=@StatementProcessId 
GROUP BY  DH.BmeStatementData_NtdcDateTime
	  ) AS CDp2
	  ON
DHA.BmeStatementData_NtdcDateTime = cdp2.BmeStatementData_NtdcDateTime
      where DHA.BmeStatementData_Year=@Year and DHA.BmeStatementData_Month=@Month and DHA.BmeStatementData_StatementProcessId=@StatementProcessId  ;


--Update dbo.BmeStatementDataCdpHourly
--	set	BmeStatementData_DemandedEnergy=BmeStatementData_AdjustedEnergyImport
--WHERE  BmeStatementData_Year=@Year and BmeStatementData_Month=@Month and BmeStatementData_StatementProcessId=@StatementProcessId and
--   BmeStatementData_ToPartyCategory_Code IN ('GEN','CSUP')
--   AND BmeStatementData_FROMPartyCategory_Code='DSP';


*/
  

DROP TABLE IF EXISTS #Genration
DROP TABLE IF EXISTS #losses
SELECT BmeStatementData_NtdcDateTime,SUM(ISNULL(BmeStatementData_UnitWiseGeneration,0)) GenerationHourly 
INTO #Genration
FROM BmeStatementDataGenUnitHourly 
WHERE BmeStatementData_StatementProcessId=@StatementProcessId
AND BmeStatementData_Year=@Year AND BmeStatementData_Month=@Month
GROUP BY BmeStatementData_NtdcDateTime


SELECT BmeStatementData_NtdcDateTime,SUM(ISNULL(BmeStatementData_TransmissionLosses,0)) AS TranmissionLossesHourly 
INTO #losses
FROM BmeStatementDataTspHourly
WHERE BmeStatementData_StatementProcessId=@StatementProcessId
AND BmeStatementData_Year=@Year AND BmeStatementData_Month=@Month
GROUP BY BmeStatementData_NtdcDateTime


SELECT G.BmeStatementData_NtdcDateTime, (GenerationHourly-TranmissionLossesHourly) AS HourlyDemand 
INTO #HourlyDemand
FROM #Genration G
JOIN  #losses L ON L.BmeStatementData_NtdcDateTime=G.BmeStatementData_NtdcDateTime
ORDER BY 1


UPDATE DH 
SET 
DH.BmeStatementData_DemandedEnergy=D.HourlyDemand
FROM BmeStatementDataHourly DH
JOIN #HourlyDemand D ON DH.BmeStatementData_NtdcDateTime=D.BmeStatementData_NtdcDateTime
WHERE
DH.BmeStatementData_StatementProcessId=@StatementProcessId
AND DH.BmeStatementData_Year=@Year
AND DH.BmeStatementData_Month=@Month


--UPDATE BmeStatementDataHourly 
--	set 
--	BmeStatementData_DemandedEnergy

------------------------------------------------------------------------
UPDATE BmeStatementDataHourly
SET BmeStatementData_TransmissionLosses=CDP.BmeStatementData_TransmissionLosses, 
BmeStatementData_UpliftTransmissionLosses=cast(CDP.BmeStatementData_TransmissionLosses as DECIMAL(25,13))/NULLIF(DH.BmeStatementData_DemandedEnergy,0) 
from BmeStatementDataHourly DH

INNER JOIN (
SELECT SUM(BmeStatementData_TransmissionLosses) as BmeStatementData_TransmissionLosses, BmeStatementData_NtdcDateTime 
from BmeStatementDataTspHourly TH
where TH.BmeStatementData_Year=@Year and TH.BmeStatementData_Month=@Month and TH.BmeStatementData_StatementProcessId=@StatementProcessId
GROUP by BmeStatementData_NtdcDateTime	
	) as cdp on  DH.BmeStatementData_NtdcDateTime = cdp.BmeStatementData_NtdcDateTime
where DH.BmeStatementData_Year=@Year and DH.BmeStatementData_Month=@Month and DH.BmeStatementData_StatementProcessId=@StatementProcessId ;


 
--EXECUTE [dbo].[BME_Step4APerform] @Year, @Month, @StatementProcessId

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
