/****** Object:  Procedure [dbo].[ASC_PostValidationReport]    Committed by VersionSQL https://www.versionsql.com ******/

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- =============================================  
-- Author: Ali Imran (.Net/SQL Developer)  
-- CREATE date: Sep 15, 2022 
-- ALTER date: 11 August 2023 
-- Description: Updated Task Id 3641
-- =============================================  
-- [ASC_PostValidationReport] 26
CREATE   PROCEDURE dbo.ASC_PostValidationReport (
 @StatementProcessId DECIMAL(18, 0))
AS
BEGIN


/************************************************************************************************
*1
************************************************************************************************/


SELECT
	/*
	* Task Id 3641
	*/
	--SUM(ISNULL(AscStatementData_AC_Total, 0) + ISNULL(AscStatementData_MRC, 0)) AS [AC_Total] 
	SUM(CASE WHEN ISNULL(AscStatementData_AC_Total, 0)<0 THEN 0 ELSE ISNULL(AscStatementData_AC_Total, 0)end)
	+SUM(ISNULL(AscStatementData_MRC, 0)) AS [AC_Total] 
	INTO #Validation1A
FROM [AscStatementDataGuHourly_SettlementProcess]
WHERE AscStatementData_StatementProcessId = @StatementProcessId

SELECT
	SUM(ISNULL(AscStatementData_PAYABLE, 0)) AS [Payable] INTO #Validation1B
FROM [AscStatementDataMpMonthly_SettlementProcess]
WHERE AscStatementData_StatementProcessId = @StatementProcessId

/************************************************************************************************
*2
************************************************************************************************/



SELECT
	CAST(ISNULL(AscStatementData_PAYABLE, 0) AS BIGINT) AS Payable
   ,CAST(ISNULL(AscStatementData_RECEIVABLE, 0) AS BIGINT) AS Receivable
   ,CAST(ISNULL(AscStatementData_PAYABLE, 0) AS BIGINT) - CAST(ISNULL(AscStatementData_RECEIVABLE, 0) AS BIGINT) AS Diff INTO #Validation2
FROM [dbo].[AscStatementDataMpMonthly_SettlementProcess]
WHERE AscStatementData_StatementProcessId = @StatementProcessId

/************************************************************************************************
*3
************************************************************************************************/


SELECT
	AscStatementData_Year
   ,AscStatementData_Month
   ,AscStatementData_Day
   ,(AscStatementData_Hour-1 ) as AscStatementData_Hour
   ,AscStatementData_SOUnitId
   ,AscStatementData_IsIG
   ,AscStatementData_IsRG
   ,AscStatementData_IsGenMR
   ,CASE WHEN AscStatementData_IsIG=1 THEN 'Included' ELSE 'Not Included' END AS AscStatementData_IsIG_MSG
   ,CASE WHEN AscStatementData_IsRG=1 THEN 'Included' ELSE 'Not Included' END AS AscStatementData_IsRG_MSG
   ,CASE WHEN AscStatementData_IsGenMR=1 THEN 'Included' ELSE 'Not Included' END AS AscStatementData_IsGenMR_MSG

INTO #Validation3
FROM [AscStatementDataGuHourly]
WHERE AscStatementData_StatementProcessId = @StatementProcessId
AND (
(ISNULL(AscStatementData_IsIG, 0) = 1
AND ISNULL(AscStatementData_IsRG, 0) = 1)
OR (ISNULL(AscStatementData_IsIG, 0) = 1
AND ISNULL(AscStatementData_IsGenMR, 0) = 1)
OR (ISNULL(AscStatementData_IsRG, 0) = 1
AND ISNULL(AscStatementData_IsGenMR, 0) = 1)
)



/************************************************************************************************
*4
************************************************************************************************/

--DROP TABLE IF EXISTS #Validation3
--DROP TABLE IF EXISTS #Validation4B
--DROP TABLE IF EXISTS #Validation4C

/***************************************4A*******AscStatementData_IsIG**************************************************/
SELECT
	AscStatementData_Year
   ,AscStatementData_Month
   ,AscStatementData_Day
   ,(AscStatementData_Hour-1) as AscStatementData_Hour
   ,AscStatementData_SOUnitId
   ,COUNT(AscStatementData_Hour) AS HourCount
   ,'Increase Gen' AS [FILE]
INTO #Validation4A
FROM [AscStatementDataGuHourly]
WHERE 1 = 1
AND AscStatementData_StatementProcessId = @StatementProcessId
AND ISNULL(AscStatementData_IsIG, 0) = 1
GROUP BY AscStatementData_SOUnitId
		,AscStatementData_Year
		,AscStatementData_Month
		,AscStatementData_Day
		,AscStatementData_Hour
HAVING COUNT(AscStatementData_Hour) > 1

/*************************************4B********AscStatementData_IsRG***************************************************/

SELECT
	AscStatementData_Year
   ,AscStatementData_Month
   ,AscStatementData_Day
   ,(AscStatementData_Hour-1) as AscStatementData_Hour
   ,AscStatementData_SOUnitId
   ,COUNT(AscStatementData_Hour) AS HourCount
   ,'Reduce Gen' AS [FILE]
INTO #Validation4B
FROM [AscStatementDataGuHourly]
WHERE 1 = 1
AND AscStatementData_StatementProcessId = @StatementProcessId
AND ISNULL(AscStatementData_IsRG, 0) = 1
GROUP BY AscStatementData_SOUnitId
		,AscStatementData_Year
		,AscStatementData_Month
		,AscStatementData_Day
		,AscStatementData_Hour
HAVING COUNT(AscStatementData_Hour) > 1


/********************************4C*********AscStatementData_IsGenMR*******************************************************/

SELECT
	AscStatementData_Year
   ,AscStatementData_Month
   ,AscStatementData_Day
   , (AscStatementData_Hour-1) as AscStatementData_Hour
   ,AscStatementData_SOUnitId
   ,COUNT(AscStatementData_Hour) AS HourCount
   ,'MustRun' AS [FILE]
INTO #Validation4C
FROM [AscStatementDataGuHourly]
WHERE 1 = 1
AND AscStatementData_StatementProcessId = @StatementProcessId
AND ISNULL(AscStatementData_IsGenMR, 0) = 1
GROUP BY AscStatementData_SOUnitId
		,AscStatementData_Year
		,AscStatementData_Month
		,AscStatementData_Day
		,AscStatementData_Hour
HAVING COUNT(AscStatementData_Hour) > 1



/************************************************************************************************
*5
************************************************************************************************/


SELECT
	AscStatementData_Year
   ,AscStatementData_Month
   ,AscStatementData_Day
   ,(AscStatementData_Hour-1) as AscStatementData_Hour
   ,AscStatementData_SOUnitId
   ,AscStatementData_MRC
   ,AscStatementData_IG_AC
   ,AscStatementData_RG_AC
INTO #Validation5
FROM [AscStatementDataGuHourly_SettlementProcess]
WHERE AscStatementData_StatementProcessId = @StatementProcessId
AND (
ISNULL(AscStatementData_MRC, 0) < 0
OR ISNULL(AscStatementData_IG_AC, 0) < 0
OR ISNULL(AscStatementData_RG_AC, 0) < 0
)






/************************************************************************************************
Summary
************************************************************************************************/

SELECT
     '1' AS [Sr],
	'Sum of TAC equality to Total payable in ASC ' AS [Verification Check]
   ,CASE
		WHEN CAST(A.AC_Total AS BIGINT) <> CAST(B.Payable AS BIGINT) THEN 'Failed'
		ELSE 'Passed'
	END AS [Status]
FROM #Validation1A A
	,#Validation1B B


/************************************************************************************************/
UNION
SELECT
'2' AS [Sr],
	'Total Payable and Receivable equality' AS [Verification Check]
   ,CASE
		WHEN SUM(Diff) <> 0 THEN 'Failed'
		ELSE 'Passed'
	END AS [Status]
FROM #Validation2


/************************************************************************************************/
UNION
SELECT
'3' AS [Sr],
	'Duplication of Values across SO Input files (MR, IG,RG)' AS [Verification Check]
   ,CASE
		WHEN COUNT(1) > 0 THEN 'Failed'
		ELSE 'Passed'
	END AS [Status]
FROM #Validation3

/************************************************************************************************/
UNION
SELECT
'4' AS [Sr],
	'Duplication of Values within same SO Input File' AS [Verification Check]
   ,CASE
		WHEN COUNT(A.AscStatementData_Year) > 0 OR COUNT(B.AscStatementData_Year)>0 OR COUNT(C.AscStatementData_Year)>0  THEN 'Failed'
		ELSE 'Passed'
	END AS [Status]
FROM #Validation4A A ,#Validation4B B, #Validation4C C

/************************************************************************************************/
UNION
SELECT
'5' AS [Sr],
	'Negative Values in Compensation Column (MR, IG,RG)' AS [Verification Check]
   ,CASE
		WHEN COUNT(AscStatementData_Year) > 0  THEN 'Failed'
		ELSE 'Passed'
	END AS [Status]
FROM #Validation5	

/************************************************************************************************/




SELECT 
'' AS [1] ,
CAST(AC_Total AS BIGINT) AS AC_Total
,cast(Payable AS BIGINT) AS Payable

FROM #Validation1A,#Validation1B;


SELECT 
'' AS [2] , SUM(Payable) AS Payable,	SUM(Receivable) AS Receivable
 FROM #Validation2;

SELECT 
'' AS [3] ,
    AscStatementData_Year     AS [Year]
   ,AscStatementData_Month	  AS [Mont]
   ,AscStatementData_Day	  AS [Day]
   ,AscStatementData_Hour	  AS [Hour]
   ,AscStatementData_SOUnitId AS [So Unit Id]
   ,AscStatementData_IsIG_MSG  AS [IG]
   ,AscStatementData_IsRG_MSG  AS [RG]
   ,AscStatementData_IsGenMR_MSG AS [MustRun]
   --,ISNULL(AscStatementData_IsIG,'')		 AS [IG]
   --,ISNULL(AscStatementData_IsRG,'')		 AS [RG]
   --,ISNULL(AscStatementData_IsGenMR,'')	 AS [MustRun]

FROM 
#Validation3 
ORDER BY AscStatementData_Day,AscStatementData_Hour,AscStatementData_SOUnitId ;

SELECT 
'' AS [4A IG] ,
    A.AscStatementData_Year     AS [Year]
   ,A.AscStatementData_Month	  AS [Mont]
   ,A.AscStatementData_Day	  AS [Day]
   ,A.AscStatementData_Hour	  AS [Hour]
   ,A.AscStatementData_SOUnitId AS [So Unit Id]
   ,A.[FILE]
FROM #Validation4A A 
ORDER BY AscStatementData_Day,AscStatementData_Hour,AscStatementData_SOUnitId;

SELECT 
'' AS [4B RG] ,
    A.AscStatementData_Year     AS [Year]
   ,A.AscStatementData_Month	  AS [Mont]
   ,A.AscStatementData_Day	  AS [Day]
   ,A.AscStatementData_Hour	  AS [Hour]
   ,A.AscStatementData_SOUnitId AS [So Unit Id]
   ,A.[FILE]
FROM #Validation4B A 


SELECT 
'' AS [4C MR] ,
    A.AscStatementData_Year     AS [Year]
   ,A.AscStatementData_Month	  AS [Mont]
   ,A.AscStatementData_Day	  AS [Day]
   ,A.AscStatementData_Hour  AS [Hour]
   ,A.AscStatementData_SOUnitId AS [So Unit Id]
   ,A.[FILE] 
FROM #Validation4C A 
ORDER BY A.AscStatementData_Day,A.AscStatementData_Hour,A.AscStatementData_SOUnitId;

--SELECT 
--	'' AS [5] ,
--    AscStatementData_Year     AS [Year]
--   ,AscStatementData_Month	  AS [Mont]
--   ,AscStatementData_Day	  AS [Day]
--   ,AscStatementData_Hour	  AS [Hour]
--   ,AscStatementData_SOUnitId AS [So Unit Id]
--   ,AscStatementData_MRC	  AS [MRC]
--   ,AscStatementData_IG_AC	  AS [IG AC]
--   ,AscStatementData_RG_AC	  AS [RG AC]

--FROM #Validation5
--ORDER BY AscStatementData_Day,AscStatementData_Hour,AscStatementData_SOUnitId;

/********* Output sheet 16.8 in Change Request 6 **********************************************************/
 DROP TABLE IF EXISTS #temp3          
          
SELECT          
            
  AscStatementData_Month           
    ,AscStatementData_Day           
    ,AscStatementData_Hour           
    ,AscStatementData_SOUnitId           
    , AscStatementData_UnitName          
   ,AscStatementData_SO_MP          
   ,AscStatementData_SO_RG_VC          
   ,AscStatementData_SO_IG_VC          
   ,AscStatementData_SO_MR_VC          
      ,GH.AscStatementData_MR_EAG          
    ,GH.AscStatementData_MR_EPG          
    ,GH.AscStatementData_MRC           
    ,GH.AscStatementData_RG_EAG           
    ,GH.AscStatementData_SO_AC          
    ,GH.AscStatementData_AC_MOD           
    ,GH.AscStatementData_RG_LOCC          
    ,GH.AscStatementData_IG_EAG          
    ,GH.AscStatementData_SO_IG_EPG           
    ,GH.AscStatementData_IG_UPC           
    ,GH.AscStatementData_IG_AC           
    --,GH.AscStatementData_RG_AC_WithNegativeValues           
	,GH.AscStatementData_RG_AC           
    --,GH.AscStatementData_AC_Total           
    ,ISNULL(GH.AscStatementData_AC_Total,0)+ISNULL(AscStatementData_MRC,0) AS AscStatementData_AC_Total          
    ,GH.AscStatementData_CongestedZoneID          
       ,(select MtCongestedZone_Name from MtCongestedZone where MtCongestedZone_Id=GH.AscStatementData_CongestedZoneID) AS AscStatementData_CongestedZone          
            
   INTO #temp3          
 FROM           
  [dbo].[AscStatementDataGuHourly_SettlementProcess] GH          
 WHERE           
  GH.AscStatementData_StatementProcessId = @StatementProcessId          
--  AND ISNULL(GH.AscStatementData_AC_Total,0) > 0 
    AND (
ISNULL(AscStatementData_MRC, 0) < 0
OR ISNULL(AscStatementData_IG_AC, 0) < 0
OR ISNULL(AscStatementData_RG_AC, 0) < 0
--OR ISNULL(AscStatementData_RG_AC_WithNegativeValues, 0) < 0
)

SELECT          
	'' AS [5] ,
  ROW_NUMBER() OVER (ORDER BY GH.AscStatementData_Month,GH.AscStatementData_Day,GH.AscStatementData_Hour,G.MtPartyRegisteration_Id,G.MtGenerator_Id,G.MtGenerationUnit_Id) AS [Sr]          
  ,AscStatementData_Month AS [Month]          
    ,AscStatementData_Day AS [Day]          
    ,AscStatementData_Hour -1 AS [Hour]          
    ,G.MtPartyRegisteration_Id AS [MP_ID]          
    ,G.MtPartyRegisteration_Name AS [MP Name]          
    ,G.MtGenerator_Id AS [Generator ID]          
    ,G.MtGenerator_Name AS [Generator Name]          
    ,AscStatementData_SOUnitId AS [SO Unit Id]          
    , AscStatementData_UnitName AS [Generation Unit Name]          
    ,GH.AscStatementData_CongestedZone AS [Congested Zone]          
    ,AscStatementData_SO_MP AS MP    
--MR     
,Format(GH.AscStatementData_MR_EAG,'N') AS [MR_EAG(kWh)]          
,Format(GH.AscStatementData_MR_EPG,'N') AS [MR_EPG (kWh)]          
,Format(AscStatementData_SO_MR_VC,'N') AS [MR_VC]         
,Format(GH.AscStatementData_MRC,'N') AS [Must Run Compensation (MRC)]          
--RG     
,Format(GH.AscStatementData_RG_EAG,'N') AS [RG_EAG]          
,Format(GH.AscStatementData_SO_AC,'N') AS [AC]          
,Format(GH.AscStatementData_AC_MOD,'N') AS [AC_MOD]          
,Format(GH.AscStatementData_RG_LOCC,'N') AS [LOCC]          
,Format(AscStatementData_SO_RG_VC,'N') AS [RG_VC]          
--,Format(GH.AscStatementData_RG_AC_WithNegativeValues,'N') AS [Reduced Generation]        
,Format(GH.AscStatementData_RG_AC,'N') AS [Reduced Generation]        
--IG    
,Format(GH.AscStatementData_IG_EAG,'N') AS [IG_EAG]          
,Format(GH.AscStatementData_SO_IG_EPG  ,'N') AS [IG_EPG]          
,Format(GH.AscStatementData_IG_UPC ,'N') AS [IG_UPC]          
,Format(AscStatementData_SO_IG_VC,'N') AS [IG_VC]          
,Format(GH.AscStatementData_IG_AC,'N') AS [Increased Generation]      
    
,Format(GH.AscStatementData_AC_Total  ,'N') AS [AC_Total]    
 FROM           
  #temp3 GH          
 JOIN [dbo].[ASC_GuParties] G          
  ON GH.AscStatementData_SOUnitId = G.MtGenerationUnit_SOUnitId          
    /********* Output sheet 16.8 in Change Request 6 **********************************************************/
       

END
