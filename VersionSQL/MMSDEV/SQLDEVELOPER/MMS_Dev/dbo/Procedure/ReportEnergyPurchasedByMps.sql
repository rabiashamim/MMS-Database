/****** Object:  Procedure [dbo].[ReportEnergyPurchasedByMps]    Committed by VersionSQL https://www.versionsql.com ******/

--ReportEnergyPurchasedByMps 82
CREATE   PROCEDURE dbo.ReportEnergyPurchasedByMps
@pAggregatedStatementId INT=null
,@pPartyId INT=0

AS
BEGIN

/********	Data insertion into table starts here	******/

IF NOT EXISTS(SELECT 1 from ReportEnergyPurchasedByMpsData where ReportEnergyPurchasedByMpsData_AggregatedStatementId=@pAggregatedStatementId)
BEGIN

 SET NOCOUNT ON;
     IF 1=0 BEGIN
       SET FMTONLY OFF
     END
DROP TABLE IF EXISts #tempCdpHourlyData
DROP TABLE IF EXISts #temp_MPEnergy
DROP TABLE IF EXISts #tempTitle


SELECT value into #tempTitle FROM STRING_SPLIT('Title1,Title2,Title3,Title4,Title5,Title6,Title7,Title8,Title9,Title10,Title11,Title12,Title13,Title14,Title15,Title16,Title17,Title18' , ',');
DECLARE @vBmeId as int;
set @vBmeId=dbo.GetBMEtatementProcessIdFromASC(@pAggregatedStatementId)
select --top 10 
--CdpOwner.BmeStatementData_OwnerPartyRegisteration_Id
--,MtPartyRegisteration_Id as PartyDspId
case WHEN MtPartyRegisteration_Id is null then BmeStatementData_OwnerPartyRegisteration_Id else MtPartyRegisteration_Id end as BmeStatementData_OwnerPartyRegisteration_Id
,CdpOwner.BmeStatementData_OwnerPartyRegisteration_Name
,CdpOwner.BmeStatementData_OwnerPartyCategory_Code
,CdpOwner.BmeStatementData_OwnerPartyType_Code
,CDP.BmeStatementData_LineVoltage
,CDP.BmeStatementData_IncEnergyImport
,CDP.BmeStatementData_IncEnergyExport
,CDP.BmeStatementData_AdjustedEnergyExport
,CDP.BmeStatementData_AdjustedEnergyImport
,CDP.BmeStatementData_FromPartyRegisteration_Id
,CDP.BmeStatementData_FromPartyRegisteration_Name
,CDP.BmeStatementData_FromPartyCategory_Code
,CDP.BmeStatementData_FromPartyType_Code
,CDP.BmeStatementData_ToPartyRegisteration_Id
,CDP.BmeStatementData_ToPartyRegisteration_Name
,CDP.BmeStatementData_ToPartyCategory_Code
,CDP.BmeStatementData_ToPartyType_Code
into #tempCdpHourlyData
from BmeStatementDataCdpHourly_SettlementProcess CDP
inner join BmeStatementDataCdpOwnerParty_SettlementProcess CdpOwner
on CDP.BmeStatementData_CdpId=CdpOwner.BmeStatementData_CdpId
left join MtPartyRegisteration MPR on MPR.MtPartyRegisteration_MPId=CdpOwner.BmeStatementData_OwnerPartyRegisteration_Id

where 
CDP.BmeStatementData_StatementProcessId=@vBmeId
AND CdpOwner.BmeStatementData_StatementProcessId=@vBmeId
 AND BmeStatementData_OwnerPartyRegisteration_Id not in (1,23,24)
AND MtPartyRegisteration_Id not in (23,24)
--AND (@pPartyId=0 or BmeStatementData_OwnerPartyRegisteration_Id=@pPartyId)

 --group by BmeStatementData_OwnerId


CREATE TABLE #temp_MPEnergy  (
MPId  decimal(18,0),
MPName NVARCHAR(200),
Title nvarchar(max),
Energy  decimal(25,8),
AdjustedEnergy decimal(25,8)
)
insert into #temp_MPEnergy(MPId, MPName, Title,Energy,AdjustedEnergy)
select distinct BmeStatementData_OwnerPartyRegisteration_Id,BmeStatementData_OwnerPartyRegisteration_Name,  value,0,0 from #tempCdpHourlyData ,#tempTitle
;

/**************************************************		
				Case 1	
***************************************************/
UPDATE MP
SET ENergy = t1.Energy
   ,AdjustedEnergy = t1.AdjustedEnergy
FROM (SELECT
		t.BmeStatementData_OwnerPartyRegisteration_Id
	   ,SUM(t.Energy) AS Energy
	   ,SUM(t.AdjustedEnergy) AS AdjustedEnergy
	FROM (SELECT
			CDP.BmeStatementData_OwnerPartyRegisteration_Id
		   ,CASE
				WHEN BmeStatementData_ToPartyRegisteration_Id = BmeStatementData_OwnerPartyRegisteration_Id AND
					CDP.BmeStatementData_FromPartyRegisteration_Id = 25 THEN (ISNULL(CDP.BmeStatementData_IncEnergyExport, 0))
				WHEN
					CDP.BmeStatementData_FromPartyRegisteration_Id = CDP.BmeStatementData_OwnerPartyRegisteration_Id AND
					CDP.BmeStatementData_ToPartyRegisteration_Id = 25 THEN (ISNULL(CDP.BmeStatementData_IncEnergyImport, 0))
				ELSE 0
			END
			AS Energy
		   ,CASE
				WHEN BmeStatementData_ToPartyRegisteration_Id = BmeStatementData_OwnerPartyRegisteration_Id AND
					CDP.BmeStatementData_FromPartyRegisteration_Id = 25 THEN (ISNULL(CDP.BmeStatementData_AdjustedEnergyExport, 0))
				WHEN
					CDP.BmeStatementData_FromPartyRegisteration_Id = CDP.BmeStatementData_OwnerPartyRegisteration_Id AND
					CDP.BmeStatementData_ToPartyRegisteration_Id = 25 THEN (ISNULL(CDP.BmeStatementData_AdjustedEnergyImport, 0))
				ELSE 0
			END
			AS AdjustedEnergy

		FROM #tempCdpHourlyData CDP
		WHERE  (CDP.BmeStatementData_LineVoltage > 11 and CDP.BmeStatementData_LineVoltage <= 132) OR
		CDP.BmeStatementData_LineVoltage =220) AS t
	GROUP BY t.BmeStatementData_OwnerPartyRegisteration_Id) AS t1
INNER JOIN #temp_MPEnergy MP
	ON MP.MPId = t1.BmeStatementData_OwnerPartyRegisteration_Id
WHERE MP.Title = 'Title1'
;
/**************************************************		
				Case 2	: kWh received at 132kV from Generation
***************************************************/

UPDATE MP
SET ENergy = t1.Energy
   ,AdjustedEnergy = t1.AdjustedEnergy
FROM (SELECT
		t.BmeStatementData_OwnerPartyRegisteration_Id
	   ,SUM(t.Energy) AS Energy
	   ,SUM(t.AdjustedEnergy) AS AdjustedEnergy
	FROM (SELECT
			CDP.BmeStatementData_OwnerPartyRegisteration_Id
		   ,CASE
				WHEN BmeStatementData_ToPartyRegisteration_Id = BmeStatementData_OwnerPartyRegisteration_Id AND
					CDP.BmeStatementData_FromPartyCategory_Code = 'GEN' THEN (ISNULL(CDP.BmeStatementData_IncEnergyExport, 0))
				WHEN
					CDP.BmeStatementData_FromPartyRegisteration_Id = CDP.BmeStatementData_OwnerPartyRegisteration_Id AND
					CDP.BmeStatementData_ToPartyCategory_Code = 'GEN' THEN (ISNULL(CDP.BmeStatementData_IncEnergyImport, 0))
				ELSE 0
			END
			AS Energy
		   ,CASE
				WHEN BmeStatementData_ToPartyRegisteration_Id = BmeStatementData_OwnerPartyRegisteration_Id AND
					CDP.BmeStatementData_FromPartyCategory_Code = 'GEN' THEN (ISNULL(CDP.BmeStatementData_AdjustedEnergyExport, 0))
				WHEN
					CDP.BmeStatementData_FromPartyRegisteration_Id = CDP.BmeStatementData_OwnerPartyRegisteration_Id AND
					CDP.BmeStatementData_ToPartyCategory_Code = 'GEN' THEN (ISNULL(CDP.BmeStatementData_AdjustedEnergyImport, 0))
				ELSE 0
			END
			AS AdjustedEnergy

		FROM #tempCdpHourlyData CDP
		WHERE (CDP.BmeStatementData_LineVoltage > 11 and CDP.BmeStatementData_LineVoltage <= 132) OR
		CDP.BmeStatementData_LineVoltage =220) AS t
	GROUP BY t.BmeStatementData_OwnerPartyRegisteration_Id) AS t1
INNER JOIN #temp_MPEnergy MP
	ON MP.MPId = t1.BmeStatementData_OwnerPartyRegisteration_Id
WHERE MP.Title = 'Title2'
;


/**************************************************		
				Case 3	: kWh received at 132kV from Generation
***************************************************/

WITH CTE_Title3Case as (
SELECT
MP.MPId,
ISNULL(Sum(MP.Energy),0) as Energy,
ISNULL(Sum(MP.AdjustedEnergy),0) as AdjustedEnergy

from #temp_MPEnergy MP 
WHERE MP.Title='Title1' or MP.Title='Title2'
GROUP by MP.MPId
)

update MP
SET

Energy = CDP.Energy
,AdjustedEnergy  = CDP.AdjustedEnergy

FROM
#temp_MPEnergy MP
inner join CTE_Title3Case CDP on MP.MPId=CDP.MPId
where MP.Title='Title3';
/**************************************************		
				Case 4	: kWh received at 11kV from Generation
***************************************************/

UPDATE MP
SET ENergy = t1.Energy
   ,AdjustedEnergy = t1.AdjustedEnergy
FROM (SELECT
		t.BmeStatementData_OwnerPartyRegisteration_Id
	   ,SUM(t.Energy) AS Energy
	   ,SUM(t.AdjustedEnergy) AS AdjustedEnergy
	FROM (SELECT
			CDP.BmeStatementData_OwnerPartyRegisteration_Id
		   ,CASE
				WHEN BmeStatementData_ToPartyRegisteration_Id = BmeStatementData_OwnerPartyRegisteration_Id AND
					CDP.BmeStatementData_FromPartyCategory_Code = 'GEN' THEN (ISNULL(CDP.BmeStatementData_IncEnergyExport, 0))
				WHEN
					CDP.BmeStatementData_FromPartyRegisteration_Id = CDP.BmeStatementData_OwnerPartyRegisteration_Id AND
					CDP.BmeStatementData_ToPartyCategory_Code = 'GEN' THEN (ISNULL(CDP.BmeStatementData_IncEnergyImport, 0))
				ELSE 0
			END
			AS Energy
		   ,CASE
				WHEN BmeStatementData_ToPartyRegisteration_Id = BmeStatementData_OwnerPartyRegisteration_Id AND
					CDP.BmeStatementData_FromPartyCategory_Code = 'GEN' THEN (ISNULL(CDP.BmeStatementData_AdjustedEnergyExport, 0))
				WHEN
					CDP.BmeStatementData_FromPartyRegisteration_Id = CDP.BmeStatementData_OwnerPartyRegisteration_Id AND
					CDP.BmeStatementData_ToPartyCategory_Code = 'GEN' THEN (ISNULL(CDP.BmeStatementData_AdjustedEnergyImport, 0))
				ELSE 0
			END
			AS AdjustedEnergy

		FROM #tempCdpHourlyData CDP
		WHERE  CDP.BmeStatementData_LineVoltage = 11 ) AS t
	GROUP BY t.BmeStatementData_OwnerPartyRegisteration_Id) AS t1
INNER JOIN #temp_MPEnergy MP
	ON MP.MPId = t1.BmeStatementData_OwnerPartyRegisteration_Id
WHERE MP.Title = 'Title4'
;

/**************************************************		
				Case 5	: kWh received at 11kV from Generation
***************************************************/

WITH CTE_Title3Case as (
SELECT
MP.MPId,
ISNULL(Sum(MP.Energy),0) as Energy,
ISNULL(Sum(MP.AdjustedEnergy),0) as AdjustedEnergy

from #temp_MPEnergy MP 
WHERE MP.Title='Title4'
GROUP by MP.MPId
)

update MP
SET

Energy = CDP.Energy
,AdjustedEnergy  = CDP.AdjustedEnergy

FROM
#temp_MPEnergy MP
inner join CTE_Title3Case CDP on MP.MPId=CDP.MPId
where MP.Title='Title5';

/**************************************************		
				Case 6	: kWh exported to DISCO's 132kV 
***************************************************/

UPDATE MP
SET ENergy = t1.Energy
   ,AdjustedEnergy = t1.AdjustedEnergy
FROM (SELECT
		t.BmeStatementData_OwnerPartyRegisteration_Id
	   ,SUM(t.Energy) AS Energy
	   ,SUM(t.AdjustedEnergy) AS AdjustedEnergy
	FROM (SELECT
			CDP.BmeStatementData_OwnerPartyRegisteration_Id
		   ,CASE
				WHEN BmeStatementData_ToPartyRegisteration_Id = BmeStatementData_OwnerPartyRegisteration_Id AND
					CDP.BmeStatementData_FromPartyCategory_Code = 'DSP' THEN (ISNULL(CDP.BmeStatementData_IncEnergyImport, 0))
				WHEN
					CDP.BmeStatementData_FromPartyRegisteration_Id = CDP.BmeStatementData_OwnerPartyRegisteration_Id AND
					CDP.BmeStatementData_ToPartyCategory_Code = 'DSP' THEN (ISNULL(CDP.BmeStatementData_IncEnergyExport, 0))
				ELSE 0
			END
			AS Energy
		   ,CASE
				WHEN BmeStatementData_ToPartyRegisteration_Id = BmeStatementData_OwnerPartyRegisteration_Id AND
					CDP.BmeStatementData_FromPartyCategory_Code = 'DSP' THEN (ISNULL(CDP.BmeStatementData_AdjustedEnergyImport, 0))
				WHEN
					CDP.BmeStatementData_FromPartyRegisteration_Id = CDP.BmeStatementData_OwnerPartyRegisteration_Id AND
					CDP.BmeStatementData_ToPartyCategory_Code = 'DSP' THEN (ISNULL(CDP.BmeStatementData_AdjustedEnergyExport, 0))
				ELSE 0
			END
			AS AdjustedEnergy

		FROM #tempCdpHourlyData CDP
		WHERE CDP.BmeStatementData_LineVoltage > 11 and CDP.BmeStatementData_LineVoltage <= 132) AS t
	GROUP BY t.BmeStatementData_OwnerPartyRegisteration_Id) AS t1
INNER JOIN #temp_MPEnergy MP
	ON MP.MPId = t1.BmeStatementData_OwnerPartyRegisteration_Id
WHERE MP.Title = 'Title6'
;


/**************************************************		
				Case 7	:kWh imported to DISCO's 132kV 
***************************************************/

UPDATE MP
SET ENergy = t1.Energy
   ,AdjustedEnergy = t1.AdjustedEnergy
FROM (SELECT
		t.BmeStatementData_OwnerPartyRegisteration_Id
	   ,SUM(t.Energy) AS Energy
	   ,SUM(t.AdjustedEnergy) AS AdjustedEnergy
	FROM (SELECT
			CDP.BmeStatementData_OwnerPartyRegisteration_Id
		   ,CASE
				WHEN BmeStatementData_ToPartyRegisteration_Id = BmeStatementData_OwnerPartyRegisteration_Id AND
					CDP.BmeStatementData_FromPartyCategory_Code = 'DSP' THEN (ISNULL(CDP.BmeStatementData_IncEnergyExport, 0))
				WHEN
					CDP.BmeStatementData_FromPartyRegisteration_Id = CDP.BmeStatementData_OwnerPartyRegisteration_Id AND
					CDP.BmeStatementData_ToPartyCategory_Code = 'DSP' THEN (ISNULL(CDP.BmeStatementData_IncEnergyImport, 0))
				ELSE 0
			END
			AS Energy
		   ,CASE
				WHEN BmeStatementData_ToPartyRegisteration_Id = BmeStatementData_OwnerPartyRegisteration_Id AND
					CDP.BmeStatementData_FromPartyCategory_Code = 'DSP' THEN (ISNULL(CDP.BmeStatementData_AdjustedEnergyExport, 0))
				WHEN
					CDP.BmeStatementData_FromPartyRegisteration_Id = CDP.BmeStatementData_OwnerPartyRegisteration_Id AND
					CDP.BmeStatementData_ToPartyCategory_Code = 'DSP' THEN (ISNULL(CDP.BmeStatementData_AdjustedEnergyImport, 0))
				ELSE 0
			END
			AS AdjustedEnergy

		FROM #tempCdpHourlyData CDP
		WHERE CDP.BmeStatementData_LineVoltage > 11 and CDP.BmeStatementData_LineVoltage <= 132) AS t
	GROUP BY t.BmeStatementData_OwnerPartyRegisteration_Id) AS t1
INNER JOIN #temp_MPEnergy MP
	ON MP.MPId = t1.BmeStatementData_OwnerPartyRegisteration_Id
WHERE MP.Title = 'Title7'
;
/**************************************************		
				Case 8: KWhr exported to Power Plants at 132 KV
***************************************************/
UPDATE MP
SET ENergy = t1.Energy
   ,AdjustedEnergy = t1.AdjustedEnergy
FROM (SELECT
		t.BmeStatementData_OwnerPartyRegisteration_Id
	   ,SUM(t.Energy) AS Energy
	   ,SUM(t.AdjustedEnergy) AS AdjustedEnergy
	FROM (SELECT
			CDP.BmeStatementData_OwnerPartyRegisteration_Id
		   ,CASE
				WHEN BmeStatementData_ToPartyRegisteration_Id = BmeStatementData_OwnerPartyRegisteration_Id AND
					CDP.BmeStatementData_FromPartyCategory_Code = 'GEN' THEN (ISNULL(CDP.BmeStatementData_IncEnergyImport, 0))
				WHEN
					CDP.BmeStatementData_FromPartyRegisteration_Id = CDP.BmeStatementData_OwnerPartyRegisteration_Id AND
					CDP.BmeStatementData_ToPartyCategory_Code = 'GEN' THEN (ISNULL(CDP.BmeStatementData_IncEnergyExport, 0))
				ELSE 0
			END
			AS Energy
		   ,CASE
				WHEN BmeStatementData_ToPartyRegisteration_Id = BmeStatementData_OwnerPartyRegisteration_Id AND
					CDP.BmeStatementData_FromPartyCategory_Code = 'GEN' THEN (ISNULL(CDP.BmeStatementData_AdjustedEnergyImport, 0))
				WHEN
					CDP.BmeStatementData_FromPartyRegisteration_Id = CDP.BmeStatementData_OwnerPartyRegisteration_Id AND
					CDP.BmeStatementData_ToPartyCategory_Code = 'GEN' THEN (ISNULL(CDP.BmeStatementData_AdjustedEnergyExport, 0))
				ELSE 0
			END
			AS AdjustedEnergy

		FROM #tempCdpHourlyData CDP
		WHERE CDP.BmeStatementData_LineVoltage > 11 and CDP.BmeStatementData_LineVoltage <= 132) AS t
	GROUP BY t.BmeStatementData_OwnerPartyRegisteration_Id) AS t1
INNER JOIN #temp_MPEnergy MP
	ON MP.MPId = t1.BmeStatementData_OwnerPartyRegisteration_Id
WHERE MP.Title = 'Title8'
;
/**************************************************		
				Case 9: KWhrs exported to NTDC at 132 kV
***************************************************/
UPDATE MP
SET ENergy = t1.Energy
   ,AdjustedEnergy = t1.AdjustedEnergy
FROM (SELECT
		t.BmeStatementData_OwnerPartyRegisteration_Id
	   ,SUM(t.Energy) AS Energy
	   ,SUM(t.AdjustedEnergy) AS AdjustedEnergy
	FROM (SELECT
			CDP.BmeStatementData_OwnerPartyRegisteration_Id
		   ,CASE
				WHEN BmeStatementData_ToPartyRegisteration_Id = BmeStatementData_OwnerPartyRegisteration_Id AND
					CDP.BmeStatementData_FromPartyRegisteration_Id = 25 THEN (ISNULL(CDP.BmeStatementData_IncEnergyImport, 0))
				WHEN
					CDP.BmeStatementData_FromPartyRegisteration_Id = CDP.BmeStatementData_OwnerPartyRegisteration_Id AND
					CDP.BmeStatementData_ToPartyRegisteration_Id = 25 THEN (ISNULL(CDP.BmeStatementData_IncEnergyExport, 0))
				ELSE 0
			END
			AS Energy
		   ,CASE
				WHEN BmeStatementData_ToPartyRegisteration_Id = BmeStatementData_OwnerPartyRegisteration_Id AND
					CDP.BmeStatementData_FromPartyRegisteration_Id = 25 THEN (ISNULL(CDP.BmeStatementData_AdjustedEnergyImport, 0))
				WHEN
					CDP.BmeStatementData_FromPartyRegisteration_Id = CDP.BmeStatementData_OwnerPartyRegisteration_Id AND
					CDP.BmeStatementData_ToPartyRegisteration_Id = 25 THEN (ISNULL(CDP.BmeStatementData_AdjustedEnergyExport, 0))
				ELSE 0
			END
			AS AdjustedEnergy

		FROM #tempCdpHourlyData CDP
		WHERE CDP.BmeStatementData_LineVoltage > 11 and CDP.BmeStatementData_LineVoltage <= 132) AS t
	GROUP BY t.BmeStatementData_OwnerPartyRegisteration_Id) AS t1
INNER JOIN #temp_MPEnergy MP
	ON MP.MPId = t1.BmeStatementData_OwnerPartyRegisteration_Id
WHERE MP.Title = 'Title9'
;

/**************************************************		
				Case 10: KWhrs exported to Market BPCs at 132 kV
***************************************************/

UPDATE MP
SET ENergy = t1.Energy
   ,AdjustedEnergy = t1.AdjustedEnergy
FROM (SELECT
		t.BmeStatementData_OwnerPartyRegisteration_Id
	   ,SUM(t.Energy) AS Energy
	   ,SUM(t.AdjustedEnergy) AS AdjustedEnergy
	FROM (SELECT
			CDP.BmeStatementData_OwnerPartyRegisteration_Id
		   ,CASE
				WHEN BmeStatementData_ToPartyRegisteration_Id = BmeStatementData_OwnerPartyRegisteration_Id AND
					CDP.BmeStatementData_FromPartyCategory_Code = 'BPC' THEN (ISNULL(CDP.BmeStatementData_IncEnergyImport, 0))
				WHEN
					CDP.BmeStatementData_FromPartyRegisteration_Id = CDP.BmeStatementData_OwnerPartyRegisteration_Id AND
					CDP.BmeStatementData_ToPartyCategory_Code = 'BPC' THEN (ISNULL(CDP.BmeStatementData_IncEnergyExport, 0))
				ELSE 0
			END
			AS Energy
		   ,CASE
				WHEN BmeStatementData_ToPartyRegisteration_Id = BmeStatementData_OwnerPartyRegisteration_Id AND
					CDP.BmeStatementData_FromPartyCategory_Code = 'BPC' THEN (ISNULL(CDP.BmeStatementData_AdjustedEnergyImport, 0))
				WHEN
					CDP.BmeStatementData_FromPartyRegisteration_Id = CDP.BmeStatementData_OwnerPartyRegisteration_Id AND
					CDP.BmeStatementData_ToPartyCategory_Code = 'BPC' THEN (ISNULL(CDP.BmeStatementData_AdjustedEnergyExport, 0))
				ELSE 0
			END
			AS AdjustedEnergy

		FROM #tempCdpHourlyData CDP
		WHERE CDP.BmeStatementData_LineVoltage > 11 and CDP.BmeStatementData_LineVoltage <= 132) AS t
	GROUP BY t.BmeStatementData_OwnerPartyRegisteration_Id) AS t1
INNER JOIN #temp_MPEnergy MP
	ON MP.MPId = t1.BmeStatementData_OwnerPartyRegisteration_Id
WHERE MP.Title = 'Title10'
;
/**************************************************		
				Case 11
***************************************************/

WITH CTE_Title9ACase as (
SELECT
MP.MPId,
ISNULL(Sum(MP.Energy),0) as Energy,
ISNULL(Sum(MP.AdjustedEnergy),0) as AdjustedEnergy
from #temp_MPEnergy MP 
WHERE MP.Title='Title6' or MP.Title='Title8' or MP.Title='Title9' or MP.Title='Title10'
GROUP by MP.MPId
),

CTE_Title9BCase as (
SELECT
MP.MPId,
ISNULL(MP.Energy,0)-ISNULL(CTE.Energy,0) as Energy,
ISNULL(MP.AdjustedEnergy,0)-ISNULL(CTE.AdjustedEnergy,0) as AdjustedEnergy

from #temp_MPEnergy MP 
inner join CTE_Title9ACase CTE on CTE.MPId=MP.MPId
WHERE MP.Title='Title7'
)


update MP
SET

Energy = CDP.Energy
,AdjustedEnergy  = CDP.AdjustedEnergy
FROM
#temp_MPEnergy MP
inner join CTE_Title9BCase CDP on MP.MPId=CDP.MPId
where MP.Title='Title11';

/**************************************************		
				Case 12
***************************************************/

UPDATE MP
SET ENergy = t1.Energy
   ,AdjustedEnergy = t1.AdjustedEnergy
FROM (SELECT
		t.BmeStatementData_OwnerPartyRegisteration_Id
	   ,SUM(t.Energy) AS Energy
	   ,SUM(t.AdjustedEnergy) AS AdjustedEnergy
	FROM (SELECT
			CDP.BmeStatementData_OwnerPartyRegisteration_Id
		   ,CASE
				WHEN BmeStatementData_ToPartyRegisteration_Id = BmeStatementData_OwnerPartyRegisteration_Id AND
					CDP.BmeStatementData_FromPartyCategory_Code = 'DSP' THEN (ISNULL(CDP.BmeStatementData_IncEnergyImport, 0))
				WHEN
					CDP.BmeStatementData_FromPartyRegisteration_Id = CDP.BmeStatementData_OwnerPartyRegisteration_Id AND
					CDP.BmeStatementData_ToPartyCategory_Code = 'DSP' THEN (ISNULL(CDP.BmeStatementData_IncEnergyExport, 0))
				ELSE 0
			END
			AS Energy
		   ,CASE
				WHEN BmeStatementData_ToPartyRegisteration_Id = BmeStatementData_OwnerPartyRegisteration_Id AND
					CDP.BmeStatementData_FromPartyCategory_Code = 'DSP' THEN (ISNULL(CDP.BmeStatementData_AdjustedEnergyImport, 0))
				WHEN
					CDP.BmeStatementData_FromPartyRegisteration_Id = CDP.BmeStatementData_OwnerPartyRegisteration_Id AND
					CDP.BmeStatementData_ToPartyCategory_Code = 'DSP' THEN (ISNULL(CDP.BmeStatementData_AdjustedEnergyExport, 0))
				ELSE 0
			END
			AS AdjustedEnergy

		FROM #tempCdpHourlyData CDP
		WHERE CDP.BmeStatementData_LineVoltage = 11) AS t
	GROUP BY t.BmeStatementData_OwnerPartyRegisteration_Id) AS t1
INNER JOIN #temp_MPEnergy MP
	ON MP.MPId = t1.BmeStatementData_OwnerPartyRegisteration_Id
WHERE MP.Title = 'Title12'
;
/**************************************************		
				Case 13
***************************************************/
UPDATE MP
SET ENergy = t1.Energy
   ,AdjustedEnergy = t1.AdjustedEnergy
FROM (SELECT
		t.BmeStatementData_OwnerPartyRegisteration_Id
	   ,SUM(t.Energy) AS Energy
	   ,SUM(t.AdjustedEnergy) AS AdjustedEnergy
	FROM (SELECT
			CDP.BmeStatementData_OwnerPartyRegisteration_Id
		   ,CASE
				WHEN BmeStatementData_ToPartyRegisteration_Id = BmeStatementData_OwnerPartyRegisteration_Id AND
					CDP.BmeStatementData_FromPartyCategory_Code = 'GEN' THEN (ISNULL(CDP.BmeStatementData_IncEnergyImport, 0))
				WHEN
					CDP.BmeStatementData_FromPartyRegisteration_Id = CDP.BmeStatementData_OwnerPartyRegisteration_Id AND
					CDP.BmeStatementData_ToPartyCategory_Code = 'GEN' THEN (ISNULL(CDP.BmeStatementData_IncEnergyExport, 0))
				ELSE 0
			END
			AS Energy
		   ,CASE
				WHEN BmeStatementData_ToPartyRegisteration_Id = BmeStatementData_OwnerPartyRegisteration_Id AND
					CDP.BmeStatementData_FromPartyCategory_Code = 'GEN' THEN (ISNULL(CDP.BmeStatementData_AdjustedEnergyImport, 0))
				WHEN
					CDP.BmeStatementData_FromPartyRegisteration_Id = CDP.BmeStatementData_OwnerPartyRegisteration_Id AND
					CDP.BmeStatementData_ToPartyCategory_Code = 'GEN' THEN (ISNULL(CDP.BmeStatementData_AdjustedEnergyExport, 0))
				ELSE 0
			END
			AS AdjustedEnergy

		FROM #tempCdpHourlyData CDP
		WHERE CDP.BmeStatementData_LineVoltage = 11) AS t
	GROUP BY t.BmeStatementData_OwnerPartyRegisteration_Id) AS t1
INNER JOIN #temp_MPEnergy MP
	ON MP.MPId = t1.BmeStatementData_OwnerPartyRegisteration_Id
WHERE MP.Title = 'Title13'
;
/**************************************************		
				Case 14
***************************************************/
UPDATE MP
SET ENergy = t1.Energy
   ,AdjustedEnergy = t1.AdjustedEnergy
FROM (SELECT
		t.BmeStatementData_OwnerPartyRegisteration_Id
	   ,SUM(t.Energy) AS Energy
	   ,SUM(t.AdjustedEnergy) AS AdjustedEnergy
	FROM (SELECT
			CDP.BmeStatementData_OwnerPartyRegisteration_Id
		   ,CASE
				WHEN BmeStatementData_ToPartyRegisteration_Id = BmeStatementData_OwnerPartyRegisteration_Id AND
					CDP.BmeStatementData_FromPartyRegisteration_Id = 25 THEN (ISNULL(CDP.BmeStatementData_IncEnergyImport, 0))
				WHEN
					CDP.BmeStatementData_FromPartyRegisteration_Id = CDP.BmeStatementData_OwnerPartyRegisteration_Id AND
					CDP.BmeStatementData_ToPartyRegisteration_Id = 25 THEN (ISNULL(CDP.BmeStatementData_IncEnergyExport, 0))
				ELSE 0
			END
			AS Energy
		   ,CASE
				WHEN BmeStatementData_ToPartyRegisteration_Id = BmeStatementData_OwnerPartyRegisteration_Id AND
					CDP.BmeStatementData_FromPartyRegisteration_Id = 25 THEN (ISNULL(CDP.BmeStatementData_AdjustedEnergyImport, 0))
				WHEN
					CDP.BmeStatementData_FromPartyRegisteration_Id = CDP.BmeStatementData_OwnerPartyRegisteration_Id AND
					CDP.BmeStatementData_ToPartyRegisteration_Id = 25 THEN (ISNULL(CDP.BmeStatementData_AdjustedEnergyExport, 0))
				ELSE 0
			END
			AS AdjustedEnergy

		FROM #tempCdpHourlyData CDP
		WHERE CDP.BmeStatementData_LineVoltage = 11) AS t
	GROUP BY t.BmeStatementData_OwnerPartyRegisteration_Id) AS t1
INNER JOIN #temp_MPEnergy MP
	ON MP.MPId = t1.BmeStatementData_OwnerPartyRegisteration_Id
WHERE MP.Title = 'Title14'
;

/**************************************************		
				Case 15
***************************************************/

UPDATE MP
SET ENergy = t1.Energy
   ,AdjustedEnergy = t1.AdjustedEnergy
FROM (SELECT
		t.BmeStatementData_OwnerPartyRegisteration_Id
	   ,SUM(t.Energy) AS Energy
	   ,SUM(t.AdjustedEnergy) AS AdjustedEnergy
	FROM (SELECT
			CDP.BmeStatementData_OwnerPartyRegisteration_Id
		   ,CASE
				WHEN BmeStatementData_ToPartyRegisteration_Id = BmeStatementData_OwnerPartyRegisteration_Id AND
					CDP.BmeStatementData_FromPartyCategory_Code = 'BPC' THEN (ISNULL(CDP.BmeStatementData_IncEnergyImport, 0))
				WHEN
					CDP.BmeStatementData_FromPartyRegisteration_Id = CDP.BmeStatementData_OwnerPartyRegisteration_Id AND
					CDP.BmeStatementData_ToPartyCategory_Code = 'BPC' THEN (ISNULL(CDP.BmeStatementData_IncEnergyExport, 0))
				ELSE 0
			END
			AS Energy
		   ,CASE
				WHEN BmeStatementData_ToPartyRegisteration_Id = BmeStatementData_OwnerPartyRegisteration_Id AND
					CDP.BmeStatementData_FromPartyCategory_Code = 'BPC' THEN (ISNULL(CDP.BmeStatementData_AdjustedEnergyImport, 0))
				WHEN
					CDP.BmeStatementData_FromPartyRegisteration_Id = CDP.BmeStatementData_OwnerPartyRegisteration_Id AND
					CDP.BmeStatementData_ToPartyCategory_Code = 'BPC' THEN (ISNULL(CDP.BmeStatementData_AdjustedEnergyExport, 0))
				ELSE 0
			END
			AS AdjustedEnergy

		FROM #tempCdpHourlyData CDP
		WHERE CDP.BmeStatementData_LineVoltage = 11) AS t
	GROUP BY t.BmeStatementData_OwnerPartyRegisteration_Id) AS t1
INNER JOIN #temp_MPEnergy MP
	ON MP.MPId = t1.BmeStatementData_OwnerPartyRegisteration_Id
WHERE MP.Title = 'Title15'
;
/**************************************************		
				Case 16
***************************************************/


UPDATE MP
SET ENergy = t1.Energy
   ,AdjustedEnergy = t1.AdjustedEnergy
FROM (SELECT
		t.BmeStatementData_OwnerPartyRegisteration_Id
	   ,SUM(t.Energy) AS Energy
	   ,SUM(t.AdjustedEnergy) AS AdjustedEnergy
	FROM (SELECT
			CDP.BmeStatementData_OwnerPartyRegisteration_Id
		   ,CASE
				WHEN BmeStatementData_ToPartyRegisteration_Id = BmeStatementData_OwnerPartyRegisteration_Id AND
					CDP.BmeStatementData_FromPartyCategory_Code = 'DSP' THEN (ISNULL(CDP.BmeStatementData_IncEnergyExport, 0))
				WHEN
					CDP.BmeStatementData_FromPartyRegisteration_Id = CDP.BmeStatementData_OwnerPartyRegisteration_Id AND
					CDP.BmeStatementData_ToPartyCategory_Code = 'DSP' THEN (ISNULL(CDP.BmeStatementData_IncEnergyImport, 0))
				ELSE 0
			END
			AS Energy
		   ,CASE
				WHEN BmeStatementData_ToPartyRegisteration_Id = BmeStatementData_OwnerPartyRegisteration_Id AND
					CDP.BmeStatementData_FromPartyCategory_Code = 'DSP' THEN (ISNULL(CDP.BmeStatementData_AdjustedEnergyExport, 0))
				WHEN
					CDP.BmeStatementData_FromPartyRegisteration_Id = CDP.BmeStatementData_OwnerPartyRegisteration_Id AND
					CDP.BmeStatementData_ToPartyCategory_Code = 'DSP' THEN (ISNULL(CDP.BmeStatementData_AdjustedEnergyImport, 0))
				ELSE 0
			END
			AS AdjustedEnergy

		FROM #tempCdpHourlyData CDP
		WHERE CDP.BmeStatementData_LineVoltage = 11) AS t
	GROUP BY t.BmeStatementData_OwnerPartyRegisteration_Id) AS t1
INNER JOIN #temp_MPEnergy MP
	ON MP.MPId = t1.BmeStatementData_OwnerPartyRegisteration_Id
WHERE MP.Title = 'Title16'
;
/**************************************************		
				Case 17
***************************************************/

WITH CTE_Title15ACase as (
SELECT
MP.MPId,
ISNULL(Sum(MP.Energy),0) as Energy,
ISNULL(Sum(MP.AdjustedEnergy),0) as AdjustedEnergy

from #temp_MPEnergy MP 
WHERE MP.Title='Title12' or MP.Title='Title13' or MP.Title='Title14' or MP.Title='Title15'
GROUP by MP.MPId
),

CTE_Title15BCase as (
SELECT
MP.MPId,
ISNULL(MP.Energy,0)-ISNULL(CTE.Energy,0) as Energy,
ISNULL(MP.AdjustedEnergy,0)-ISNULL(CTE.AdjustedEnergy,0) as AdjustedEnergy
from #temp_MPEnergy MP 
inner join CTE_Title15ACase CTE on CTE.MPId=MP.MPId
WHERE MP.Title='Title16'
)


update MP
SET

Energy = CDP.Energy
,AdjustedEnergy  = CDP.AdjustedEnergy
FROM
#temp_MPEnergy MP
inner join CTE_Title15BCase CDP on MP.MPId=CDP.MPId
where MP.Title='Title17';

/**************************************************		
				Case 18
***************************************************/

WITH CTE_Title16Case as (
SELECT
MP.MPId,
ISNULL(Sum(MP.Energy),0) as Energy,
ISNULL(Sum(MP.AdjustedEnergy),0) as AdjustedEnergy


from #temp_MPEnergy MP 
WHERE MP.Title='Title17' or MP.Title='Title11' or MP.Title='Title3' or MP.Title='Title5' 
GROUP by MP.MPId
)
update MP
SET

Energy = CDP.Energy
,AdjustedEnergy  = CDP.AdjustedEnergy
FROM
#temp_MPEnergy MP
inner join CTE_Title16Case CDP on MP.MPId=CDP.MPId
where MP.Title='Title18';

/**************************************************		
				Final Output	
***************************************************/

insert into ReportEnergyPurchasedByMpsData(
ReportEnergyPurchasedByMpsData_MPId
,ReportEnergyPurchasedByMpsData_MPName 
,ReportEnergyPurchasedByMpsData_AggregatedStatementId
,ReportEnergyPurchasedByMpsData_Title 
,ReportEnergyPurchasedByMpsData_Energy  
,ReportEnergyPurchasedByMpsData_AdjustedEnergy
,ReportEnergyPurchasedByMpsData_Total)

select
MPId ,	
MPName,
@pAggregatedStatementId,
--@pPartyId as MPName,
Title,
Energy,
AdjustedEnergy,
CASE WHEN Title in ('Title3','Title5','Title11','Title17') THEN 1 when Title in ('Title18') THEN 2 ELSE 0 END as Total

from #temp_MPEnergy 
where MPId<>1
order by 
MPId,CAST(SUBSTRING(Title , 6 , 2) as int)



DROP TABLE IF EXISts #tempCdpHourlyData
DROP TABLE IF EXISts #temp_MPEnergy
DROP TABLE IF EXISts #tempTitle
END
/********	Data insertion into table ends here	******/
select 
ReportEnergyPurchasedByMpsData_MPId as MPId,	
ReportEnergyPurchasedByMpsData_MPName as MPName,
CASE WHEN ReportEnergyPurchasedByMpsData_Title='Title1' THEN 'kWh received at 132kV/ 220kV from NTDC Network'
WHEN ReportEnergyPurchasedByMpsData_Title='Title2' THEN 'kWh received at 132kV/ 220kV from Generation'
WHEN ReportEnergyPurchasedByMpsData_Title='Title3' THEN 'Total kWh received at 132kV '
WHEN ReportEnergyPurchasedByMpsData_Title='Title4' THEN 'kWh received at 11kV from Generation'
WHEN ReportEnergyPurchasedByMpsData_Title='Title5' THEN 'Total kWh received at 11kV '
WHEN ReportEnergyPurchasedByMpsData_Title='Title6' THEN 'kWh exported to DISCOs 132kV '
WHEN ReportEnergyPurchasedByMpsData_Title='Title7' THEN 'kWh imported from DISCOs 132kV '
WHEN ReportEnergyPurchasedByMpsData_Title='Title8' THEN 'kWh exported to Power Plants at 132 kV'
WHEN ReportEnergyPurchasedByMpsData_Title='Title9' THEN 'kWh exported to NTDC at 132 kV'
WHEN ReportEnergyPurchasedByMpsData_Title='Title10' THEN 'kWh exported to Market BPCs at 132 kV'
WHEN ReportEnergyPurchasedByMpsData_Title='Title11' THEN 'Net kWh purchased at 132kV '
WHEN ReportEnergyPurchasedByMpsData_Title='Title12' THEN 'kWh exported to DISCOs 11kV'
WHEN ReportEnergyPurchasedByMpsData_Title='Title13' THEN 'kWh exported to Power Plants at 11 kV'
WHEN ReportEnergyPurchasedByMpsData_Title='Title14' THEN 'kWh exported to NTDC at 11 kV'
WHEN ReportEnergyPurchasedByMpsData_Title='Title15' THEN 'kWh exported to Market BPCs 11  kV'
WHEN ReportEnergyPurchasedByMpsData_Title='Title16' THEN 'kWh imported from DISCOs 11kV '
WHEN ReportEnergyPurchasedByMpsData_Title='Title17' THEN 'Net kWh purchased at 11kV '
WHEN ReportEnergyPurchasedByMpsData_Title='Title18' THEN 'Total kWh Purchased '
ELSE ReportEnergyPurchasedByMpsData_Title END AS Title,
ReportEnergyPurchasedByMpsData_Energy as Energy,
ReportEnergyPurchasedByMpsData_AdjustedEnergy as AdjustedEnergy,
ReportEnergyPurchasedByMpsData_Total as Sum
from ReportEnergyPurchasedByMpsData 
where ReportEnergyPurchasedByMpsData_AggregatedStatementId=@pAggregatedStatementId
AND (@pPartyId=0 or @pPartyId is NULL or @pPartyId=(
select Max( MtPartyRegisteration_MPId) from MtPartyRegisteration where MtPartyRegisteration_id=ReportEnergyPurchasedByMpsData_MPId and ISNULL(isDeleted,0)=0)
)
order by 
ReportEnergyPurchasedByMpsData_MPId,CAST(SUBSTRING(ReportEnergyPurchasedByMpsData_Title , 6 , 2) as int)
END
