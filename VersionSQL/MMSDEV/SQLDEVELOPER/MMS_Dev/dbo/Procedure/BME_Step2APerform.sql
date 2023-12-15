/****** Object:  Procedure [dbo].[BME_Step2APerform]    Committed by VersionSQL https://www.versionsql.com ******/

  -- =============================================  
  -- Author:  Ali Imran |  Asghar
  -- CREATE date: 
  -- ALTER date: 
  -- Description:      
  -- Parameters: 
  -- ============================================= 
CREATE PROCEDURE dbo.BME_Step2APerform (
    @Year INT, 
    @Month INT, 
    @StatementProcessId DECIMAL(18, 0)
  ) AS BEGIN 
SET 
  NOCOUNT ON;
BEGIN TRY 


/**********************************************************************************************************************************************************************/
-- 1.
/**********************************************************************************************************************************************************************/
IF NOT EXISTS (
  SELECT 
    TOP 1 BmeStatementData_Id 
  FROM 
    BmeStatementDataHourly 
  WHERE 
    BmeStatementData_Year = @Year 
    AND BmeStatementData_Month = @Month 
    AND BmeStatementData_StatementProcessId = @StatementProcessId
) BEGIN 

  INSERT INTO BmeStatementDataHourly (
  [BmeStatementData_StatementProcessId], 
  [BmeStatementData_NtdcDateTime], 
  [BmeStatementData_Year], [BmeStatementData_Month], 
  [BmeStatementData_Day], [BmeStatementData_Hour]
) 
SELECT 
  DISTINCT @StatementProcessId, 
  [BmeStatementData_NtdcDateTime], 
  [BmeStatementData_Year], 
  [BmeStatementData_Month], 
  [BmeStatementData_Day], 
  [BmeStatementData_Hour] 
FROM 
  BmeStatementDataCdpHourly 
WHERE 
  BmeStatementData_Year = @Year 
  AND BmeStatementData_Month = @Month 
  AND BmeStatementData_StatementProcessId = @StatementProcessId END 
/**********************************************************************************************************************************************************************/
-- 2. 
/**********************************************************************************************************************************************************************/
  IF NOT EXISTS (
    SELECT 
      TOP 1 BmeStatementData_Id 
    FROM 
      [dbo].[BmeStatementDataGenUnitHourly] 
    WHERE 
      BmeStatementData_Year = @Year 
      AND BmeStatementData_Month = @Month 
      AND BmeStatementData_StatementProcessId = @StatementProcessId
  ) BEGIN 
  INSERT INTO [dbo].[BmeStatementDataGenUnitHourly] (
    [BmeStatementData_NtdcDateTime], 
    [BmeStatementData_Year], [BmeStatementData_Month], 
    [BmeStatementData_Day], [BmeStatementData_Hour], 
    [BmeStatementData_MtGenerator_Id], 
    [BmeStatementData_MtGeneratorUnit_Id], 
    BmeStatementData_SOUnitId, [SrTechnologyType_Code], 
    BmeStatementData_InstalledCapacity_KW, 
    [BmeStatementData_IsBackfeedInclude], 
    [BmeStatementData_StatementProcessId]
  ) 
SELECT 
  DISTINCT BmeStatementData_NtdcDateTime, 
  BmeStatementData_Year, 
  BmeStatementData_Month, 
  BmeStatementData_Day, 
  BmeStatementData_Hour, 
  MtGenerator_Id, 
  MtGenerationUnit_Id, 
  MtGenerationUnit_SOUnitId, 
  [SrTechnologyType_Code], 
  MtGenerationUnit_InstalledCapacity_KW, 
  [IsBackfeedInclude], 
  BmeStatementDataCdpHourly.BmeStatementData_StatementProcessId 
FROM 
  BmeStatementDataCdpHourly 
  JOIN BmeStatementDataCDPGenUnit t ON t.RuCDPDetail_CdpId = BmeStatementDataCdpHourly.BmeStatementData_CdpId 
WHERE 
  BmeStatementDataCdpHourly.BmeStatementData_Year = @Year 
  AND BmeStatementDataCdpHourly.BmeStatementData_Month = @Month 
  AND BmeStatementDataCdpHourly.BmeStatementData_StatementProcessId = @StatementProcessId 
  AND t.BmeStatementData_StatementProcessId = @StatementProcessId END 
/**********************************************************************************************************************************************************************/
-- 3. case 1
/**********************************************************************************************************************************************************************/
UPDATE 
  [dbo].[BmeStatementDataGenUnitHourly] 
SET 
  BmeStatementData_GenerationUnitEnergy = ISNULL(
    BmeStatementData_GenerationUnitEnergy, 
    0
  ) + CDp2.UnitGeneration, 
  BmeStatementData_GenerationUnitWiseBackfeed = ISNULL(
    BmeStatementData_GenerationUnitWiseBackfeed, 
    0
  ) + CDp2.UnitWiseBackFeed, 
  [BmeStatementData_GenerationUnitEnergy_Metered] = ISNULL(
    [BmeStatementData_GenerationUnitEnergy_Metered], 
    0
  ) + CDp2.UnitGeneration_Metered, 
  [BmeStatementData_GenerationUnitWiseBackfeed_Metered] = ISNULL(
    [BmeStatementData_GenerationUnitWiseBackfeed_Metered], 
    0
  ) + CDp2.UnitWiseBackFeed_Metered 
FROM 
  [BmeStatementDataGenUnitHourly] DHA 
  INNER JOIN (
    SELECT 
      BmeStatementData_NtdcDateTime, 
      t.MtGenerator_Id, 
      t.MtGenerationUnit_Id 
      , 
      SUM(
        BmeStatementData_AdjustedEnergyImport
      ) AS UnitWiseBackFeed, 
      SUM(
        BmeStatementData_AdjustedEnergyExport
      ) AS UnitGeneration, 
      SUM(
        BmeStatementData_IncEnergyImport
      ) AS UnitWiseBackFeed_Metered, 
      SUM(
        BmeStatementData_IncEnergyExport
      ) AS UnitGeneration_Metered 
    FROM 
      BmeStatementDataCdpHourly 
      INNER JOIN BmeStatementDataCDPGenUnit t ON t.RuCDPDetail_CdpId = BmeStatementDataCdpHourly.BmeStatementData_CdpId 
    WHERE 
      BmeStatementDataCdpHourly.BmeStatementData_Year = @Year 
      AND BmeStatementDataCdpHourly.BmeStatementData_Month = @Month 
      AND t.BmeStatementData_StatementProcessId = @StatementProcessId 
      AND BmeStatementDataCdpHourly.BmeStatementData_StatementProcessId = @StatementProcessId 
      AND BmeStatementData_FromPartyCategory_Code NOT IN ('TSP', 'DSP') 
      AND BmeStatementData_ToPartyCategory_Code IN ('DSP', 'TSP') 
      AND IsBackfeedInclude = 1 
    GROUP BY 
      BmeStatementData_NtdcDateTime, 
      t.MtGenerator_Id, 
      t.MtGenerationUnit_Id
  ) AS CDp2 ON DHA.BmeStatementData_NtdcDateTime = CDp2.BmeStatementData_NtdcDateTime 
  AND DHA.BmeStatementData_MtGenerator_Id = CDp2.MtGenerator_Id 
  AND DHA.BmeStatementData_MtGeneratorUnit_Id = CDp2.MtGenerationUnit_Id 
WHERE 
  DHA.BmeStatementData_Year = @Year 
  AND DHA.BmeStatementData_Month = @Month 
  AND DHA.BmeStatementData_StatementProcessId = @StatementProcessId PRINT (
    GETUTCDATE()
  ) 
/**********************************************************************************************************************************************************************/
-- 4. case 2
/**********************************************************************************************************************************************************************/
UPDATE 
  [dbo].[BmeStatementDataGenUnitHourly] 
SET 
  BmeStatementData_GenerationUnitEnergy = ISNULL(
    BmeStatementData_GenerationUnitEnergy, 
    0
  ) + CDp2.UnitGeneration, 
  BmeStatementData_GenerationUnitWiseBackfeed = ISNULL(
    BmeStatementData_GenerationUnitWiseBackfeed, 
    0
  ) + CDp2.UnitWiseBackFeed, 
  [BmeStatementData_GenerationUnitEnergy_Metered] = ISNULL(
    [BmeStatementData_GenerationUnitEnergy_Metered], 
    0
  ) + CDp2.UnitGeneration_Metered, 
  [BmeStatementData_GenerationUnitWiseBackfeed_Metered] = ISNULL(
    [BmeStatementData_GenerationUnitWiseBackfeed_Metered], 
    0
  ) + CDp2.UnitWiseBackFeed_Metered 
FROM 
  [BmeStatementDataGenUnitHourly] DHA 
  INNER JOIN (
    SELECT 
      BmeStatementData_NtdcDateTime, 
      t.MtGenerator_Id, 
      t.MtGenerationUnit_Id, 
      SUM(
        BmeStatementData_AdjustedEnergyImport
      ) AS UnitGeneration, 
      SUM(
        BmeStatementData_AdjustedEnergyExport
      ) AS UnitWiseBackFeed, 
      SUM(
        BmeStatementData_IncEnergyImport
      ) AS UnitGeneration_Metered, 
      SUM(
        BmeStatementData_IncEnergyExport
      ) AS UnitWiseBackFeed_Metered 
    FROM 
      BmeStatementDataCdpHourly 
      INNER JOIN BmeStatementDataCDPGenUnit t ON t.RuCDPDetail_CdpId = BmeStatementDataCdpHourly.BmeStatementData_CdpId 
    WHERE 
      BmeStatementDataCdpHourly.BmeStatementData_Year = @Year 
      AND BmeStatementDataCdpHourly.BmeStatementData_Month = @Month 
      AND BmeStatementDataCdpHourly.BmeStatementData_StatementProcessId = @StatementProcessId 
      AND t.BmeStatementData_StatementProcessId = @StatementProcessId 
      AND BmeStatementData_ToPartyCategory_Code NOT IN ('TSP', 'DSP') 
      AND BmeStatementData_FromPartyCategory_Code IN ('DSP', 'TSP') 
      AND IsBackfeedInclude = 1 
    GROUP BY 
      BmeStatementData_NtdcDateTime, 
      t.MtGenerator_Id, 
      t.MtGenerationUnit_Id 
      ) AS CDp2 ON DHA.BmeStatementData_NtdcDateTime = CDp2.BmeStatementData_NtdcDateTime 
  AND DHA.BmeStatementData_MtGenerator_Id = CDp2.MtGenerator_Id 
  AND DHA.BmeStatementData_MtGeneratorUnit_Id = CDp2.MtGenerationUnit_Id 
WHERE 
  DHA.BmeStatementData_Year = @Year 
  AND DHA.BmeStatementData_Month = @Month 
  AND DHA.BmeStatementData_StatementProcessId = @StatementProcessId 
/**********************************************************************************************************************************************************************/
-- 5. case 3
/**********************************************************************************************************************************************************************/
UPDATE 
  [dbo].[BmeStatementDataGenUnitHourly] 
SET 
  BmeStatementData_GenerationUnitEnergy = ISNULL(
    BmeStatementData_GenerationUnitEnergy, 
    0
  ) + CDp2.UnitGeneration, 
  BmeStatementData_GenerationUnitWiseBackfeed = ISNULL(
    BmeStatementData_GenerationUnitWiseBackfeed, 
    0
  ) + CDp2.UnitWiseBackFeed, 
  BmeStatementData_GenerationUnitEnergy_Metered = ISNULL(
    BmeStatementData_GenerationUnitEnergy_Metered, 
    0
  ) + CDp2.UnitGeneration_Metered, 
  BmeStatementData_GenerationUnitWiseBackfeed_Metered = ISNULL(
    BmeStatementData_GenerationUnitWiseBackfeed_Metered, 
    0
  ) + CDp2.UnitWiseBackFeed_Metered 
FROM 
  [BmeStatementDataGenUnitHourly] DHA 
  INNER JOIN (
    SELECT 
      DH.BmeStatementData_NtdcDateTime, 
      cdp.MtGenerator_Id, 
      cdp.MtGenerationUnit_Id, 
      SUM(
        ISNULL(
          CASE WHEN (
            ISNULL(
              BmeStatementData_AdjustedEnergyExport, 
              0
            ) - ISNULL(
              BmeStatementData_AdjustedEnergyImport, 
              0
            )
          ) < 0 THEN 0 ELSE (
            ISNULL(
              BmeStatementData_AdjustedEnergyExport, 
              0
            ) - ISNULL(
              BmeStatementData_AdjustedEnergyImport, 
              0
            )
          ) END, 
          0
        )
      ) AS UnitGeneration, 
      SUM(
        ISNULL(
          CASE WHEN (
            ISNULL(
              BmeStatementData_AdjustedEnergyExport, 
              0
            ) - ISNULL(
              BmeStatementData_AdjustedEnergyImport, 
              0
            )
          ) > 0 THEN 0 ELSE (
            ISNULL(
              BmeStatementData_AdjustedEnergyExport, 
              0
            ) - ISNULL(
              BmeStatementData_AdjustedEnergyImport, 
              0
            )
          ) END, 
          0
        )
      ) AS UnitWiseBackFeed, 
      SUM(
        ISNULL(
          CASE WHEN (
            ISNULL(
              BmeStatementData_IncEnergyExport, 
              0
            ) - ISNULL(
              BmeStatementData_IncEnergyImport, 
              0
            )
          ) < 0 THEN 0 ELSE (
            ISNULL(
              BmeStatementData_IncEnergyExport, 
              0
            ) - ISNULL(
              BmeStatementData_IncEnergyImport, 
              0
            )
          ) END, 
          0
        )
      ) AS UnitGeneration_Metered, 
      SUM(
        ISNULL(
          CASE WHEN (
            ISNULL(
              BmeStatementData_IncEnergyExport, 
              0
            ) - ISNULL(
              BmeStatementData_IncEnergyImport, 
              0
            )
          ) > 0 THEN 0 ELSE (
            ISNULL(
              BmeStatementData_IncEnergyExport, 
              0
            ) - ISNULL(
              BmeStatementData_IncEnergyImport, 
              0
            )
          ) END, 
          0
        )
      ) AS UnitWiseBackFeed_Metered 
    FROM 
      BmeStatementDataHourly DH 
      INNER JOIN (
        SELECT 
          BmeStatementData_NtdcDateTime, 
          t.MtGenerator_Id, 
          t.MtGenerationUnit_Id, 
          SUM(
            BmeStatementData_AdjustedEnergyImport
          ) AS BmeStatementData_AdjustedEnergyImport, 
          SUM(
            BmeStatementData_AdjustedEnergyExport
          ) AS BmeStatementData_AdjustedEnergyExport, 
          SUM(
            BmeStatementData_IncEnergyImport
          ) AS BmeStatementData_IncEnergyImport, 
          SUM(
            BmeStatementData_IncEnergyExport
          ) AS BmeStatementData_IncEnergyExport 
        FROM 
          BmeStatementDataCdpHourly 
          JOIN BmeStatementDataCDPGenUnit t ON t.RuCDPDetail_CdpId = BmeStatementData_CdpId 
        WHERE 
          BmeStatementDataCdpHourly.BmeStatementData_Year = @Year 
          AND BmeStatementDataCdpHourly.BmeStatementData_Month = @Month 
          AND BmeStatementDataCdpHourly.BmeStatementData_StatementProcessId = @StatementProcessId 
          AND t.BmeStatementData_StatementProcessId = @StatementProcessId 
          AND BmeStatementData_FromPartyCategory_Code NOT IN ('TSP', 'DSP') 
          AND BmeStatementData_ToPartyCategory_Code IN ('DSP', 'TSP') 
          AND IsBackfeedInclude = 0 
        GROUP BY 
          BmeStatementData_NtdcDateTime, 
          t.MtGenerator_Id, 
          MtGenerationUnit_Id
      ) AS cdp ON DH.BmeStatementData_NtdcDateTime = cdp.BmeStatementData_NtdcDateTime 
    WHERE 
      DH.BmeStatementData_Year = @Year 
      AND DH.BmeStatementData_Month = @Month 
      AND DH.BmeStatementData_StatementProcessId = @StatementProcessId 
    GROUP BY 
      DH.BmeStatementData_NtdcDateTime, 
      cdp.MtGenerator_Id, 
      cdp.MtGenerationUnit_Id
  ) AS CDp2 ON DHA.BmeStatementData_NtdcDateTime = CDp2.BmeStatementData_NtdcDateTime 
  AND DHA.BmeStatementData_MtGenerator_Id = CDp2.MtGenerator_Id 
  AND DHA.BmeStatementData_MtGeneratorUnit_Id = CDp2.MtGenerationUnit_Id 
WHERE 
  DHA.BmeStatementData_Year = @Year 
  AND DHA.BmeStatementData_Month = @Month 
  AND DHA.BmeStatementData_StatementProcessId = @StatementProcessId;
/**********************************************************************************************************************************************************************/
-- 6. case 4
/**********************************************************************************************************************************************************************/
UPDATE 
  [dbo].[BmeStatementDataGenUnitHourly] 
SET 
  BmeStatementData_GenerationUnitEnergy = ISNULL(
    BmeStatementData_GenerationUnitEnergy, 
    0
  ) + CDp2.UnitGeneration, 
  BmeStatementData_GenerationUnitWiseBackfeed = ISNULL(
    BmeStatementData_GenerationUnitWiseBackfeed, 
    0
  ) + CDp2.UnitWiseBackFeed, 
  BmeStatementData_GenerationUnitEnergy_Metered = ISNULL(
    DHA.BmeStatementData_GenerationUnitEnergy_Metered, 
    0
  ) + CDp2.UnitGeneration_Mtered, 
  BmeStatementData_GenerationUnitWiseBackfeed_Metered = ISNULL(
    DHA.BmeStatementData_GenerationUnitWiseBackfeed_Metered, 
    0
  ) + CDp2.UnitWiseBackFeed_Metered 
FROM 
  [BmeStatementDataGenUnitHourly] DHA 
  INNER JOIN (
    SELECT 
      DH.BmeStatementData_NtdcDateTime, 
      cdp.MtGenerator_Id, 
      cdp.MtGenerationUnit_Id, 
      SUM(
        ISNULL(
          CASE WHEN (
            ISNULL(
              BmeStatementData_AdjustedEnergyImport, 
              0
            ) - ISNULL(
              BmeStatementData_AdjustedEnergyExport, 
              0
            )
          ) < 0 THEN 0 ELSE (
            ISNULL(
              BmeStatementData_AdjustedEnergyImport, 
              0
            ) - ISNULL(
              BmeStatementData_AdjustedEnergyExport, 
              0
            )
          ) END, 
          0
        )
      ) AS UnitGeneration, 
      SUM(
        ISNULL(
          CASE WHEN (
            ISNULL(
              BmeStatementData_AdjustedEnergyImport, 
              0
            ) - ISNULL(
              BmeStatementData_AdjustedEnergyExport, 
              0
            )
          ) > 0 THEN 0 ELSE (
            ISNULL(
              BmeStatementData_AdjustedEnergyImport, 
              0
            ) - ISNULL(
              BmeStatementData_AdjustedEnergyExport, 
              0
            )
          ) END, 
          0
        )
      ) AS UnitWiseBackFeed, 
      SUM(
        ISNULL(
          CASE WHEN (
            ISNULL(
              BmeStatementData_IncEnergyImport, 
              0
            ) - ISNULL(
              BmeStatementData_IncEnergyExport, 
              0
            )
          ) < 0 THEN 0 ELSE (
            ISNULL(
              BmeStatementData_IncEnergyImport, 
              0
            ) - ISNULL(
              BmeStatementData_IncEnergyExport, 
              0
            )
          ) END, 
          0
        )
      ) AS UnitGeneration_Mtered, 
      SUM(
        ISNULL(
          CASE WHEN (
            ISNULL(
              BmeStatementData_IncEnergyImport, 
              0
            ) - ISNULL(
              BmeStatementData_IncEnergyExport, 
              0
            )
          ) > 0 THEN 0 ELSE (
            ISNULL(
              BmeStatementData_IncEnergyImport, 
              0
            ) - ISNULL(
              BmeStatementData_IncEnergyExport, 
              0
            )
          ) END, 
          0
        )
      ) AS UnitWiseBackFeed_Metered 
    FROM 
      BmeStatementDataHourly DH 
      INNER JOIN (
        SELECT 
          BmeStatementData_NtdcDateTime, 
          t.MtGenerator_Id, 
          t.MtGenerationUnit_Id, 
          SUM(
            BmeStatementData_AdjustedEnergyImport
          ) AS BmeStatementData_AdjustedEnergyImport, 
          SUM(
            BmeStatementData_AdjustedEnergyExport
          ) AS BmeStatementData_AdjustedEnergyExport, 
          SUM(
            BmeStatementData_IncEnergyImport
          ) AS BmeStatementData_IncEnergyImport, 
          SUM(
            BmeStatementData_IncEnergyExport
          ) AS BmeStatementData_IncEnergyExport 
        FROM 
          BmeStatementDataCdpHourly 
          JOIN BmeStatementDataCDPGenUnit t ON t.RuCDPDetail_CdpId = BmeStatementData_CdpId 
        WHERE 
          BmeStatementDataCdpHourly.BmeStatementData_Year = @Year 
          AND BmeStatementDataCdpHourly.BmeStatementData_Month = @Month 
          AND BmeStatementDataCdpHourly.BmeStatementData_StatementProcessId = @StatementProcessId 
          AND t.BmeStatementData_StatementProcessId = @StatementProcessId 
          AND BmeStatementData_ToPartyCategory_Code NOT IN ('TSP', 'DSP') 
          AND BmeStatementData_FromPartyCategory_Code IN ('DSP', 'TSP') 
          AND IsBackfeedInclude = 0 
        GROUP BY 
          BmeStatementData_NtdcDateTime, 
          t.MtGenerator_Id, 
          MtGenerationUnit_Id
      ) AS cdp ON DH.BmeStatementData_NtdcDateTime = cdp.BmeStatementData_NtdcDateTime 
    WHERE 
      DH.BmeStatementData_Year = @Year 
      AND DH.BmeStatementData_Month = @Month 
      AND DH.BmeStatementData_StatementProcessId = @StatementProcessId 
    GROUP BY 
      DH.BmeStatementData_NtdcDateTime, 
      cdp.MtGenerator_Id, 
      cdp.MtGenerationUnit_Id
  ) AS CDp2 ON DHA.BmeStatementData_NtdcDateTime = CDp2.BmeStatementData_NtdcDateTime 
  AND DHA.BmeStatementData_MtGenerator_Id = CDp2.MtGenerator_Id 
  AND DHA.BmeStatementData_MtGeneratorUnit_Id = CDp2.MtGenerationUnit_Id 
WHERE 
  DHA.BmeStatementData_Year = @Year 
  AND DHA.BmeStatementData_Month = @Month 
  AND DHA.BmeStatementData_StatementProcessId = @StatementProcessId;
/********************************************************************************************************************************************/
-- 7. Generation unit energy and unit wise backfeed
/**********************************************************************************************************************************************************************/
SELECT 
  GUH.BmeStatementData_NtdcDateTime, 
  GUH.BmeStatementData_MtGenerator_Id, 
  GUH.BmeStatementData_MtGeneratorUnit_Id, 
  GUH.BmeStatementData_SOUnitId, 
  GUH.BmeStatementData_GenerationUnitEnergy_Metered, 
  GUH.BmeStatementData_GenerationUnitEnergy, 
  GUH.BmeStatementData_UnitWiseGeneration, 
  GUH.BmeStatementData_GenerationUnitWiseBackfeed, 
  GUH.BmeStatementData_UnitWiseGeneration_Metered, 
  GUH.BmeStatementData_GenerationUnitWiseBackfeed_Metered, 
  ISNULL(
    SOAvail.MtAvailibilityData_AvailableCapacityASC, 
    0
  ) AS MtAvailibilityData_AvailableCapacityASC, 
  GUH.[SrTechnologyType_Code], 
  GUH.BmeStatementData_InstalledCapacity_KW, 
  GUH.BmeStatementData_IsBackfeedInclude, 
  SOAvail.MtAvailibilityData_SyncStatus INTO #tempA
FROM 
  [dbo].[BmeStatementDataGenUnitHourly] GUH 
  LEFT JOIN (
    SELECT 
      DATEADD(
        HOUR, 
        CAST(
          AD.MtAvailibilityData_Hour AS INT
        ) + 1, 
        CAST(
          AD.MtAvailibilityData_Date AS DATETIME
        )
      ) AS MtAvailibilityDataDateHour, 
      AD.MtAvailibilityData_AvailableCapacityASC, 
      AD.MtGenerationUnit_Id, 
      AD.MtAvailibilityData_SyncStatus 
    FROM 
      MtAvailibilityData AD 
    WHERE 
      MtSOFileMaster_Id = dbo.GetMtSoFileMasterId(@StatementProcessId, 2)
  ) SOAvail ON SOAvail.MtAvailibilityDataDateHour = GUH.BmeStatementData_NtdcDateTime 
  AND SOAvail.MtGenerationUnit_Id = GUH.BmeStatementData_SOUnitId 
WHERE 
  GUH.BmeStatementData_Year = @Year 
  AND GUH.BmeStatementData_Month = @Month 
  AND GUH.BmeStatementData_StatementProcessId = @StatementProcessId 
/**********************************************************************************************************************************************************************/
-- 8. Calculate available capacity ASC based on technology type
/**********************************************************************************************************************************************************************/
 
SELECT 
  BmeStatementData_NtdcDateTime, 
  BmeStatementData_MtGenerator_Id, 
  BmeStatementData_MtGeneratorUnit_Id, 
  BmeStatementData_SOUnitId, 
  cdp.RuCDPDetail_CdpId, 
  BmeStatementData_GenerationUnitEnergy, 
  BmeStatementData_UnitWiseGeneration, 
  BmeStatementData_GenerationUnitWiseBackfeed, 
  BmeStatementData_GenerationUnitEnergy_Metered, 
  BmeStatementData_UnitWiseGeneration_Metered, 
  BmeStatementData_GenerationUnitWiseBackfeed_Metered, 
  #tempA.[SrTechnologyType_Code]
  , 
  #tempA.BmeStatementData_InstalledCapacity_KW
  , 
  #tempA.BmeStatementData_IsBackfeedInclude
  , 
  MtAvailibilityData_AvailableCapacityASC, 
  CASE WHEN ISNULL(cdp.Lu_CapUnitGenVari_Id, 0) = 2 --SO Availability
  THEN MtAvailibilityData_AvailableCapacityASC * ISNULL(
    MtAvailibilityData_SyncStatus, 0
  ) ELSE BmeStatementData_InstalledCapacity_KW END AS MtAvailibilityData_CalculatedAvailableCapacityASC INTO #temp
FROM 
  #tempA
  JOIN BmeStatementDataCDPGenUnit cdp ON #tempA.BmeStatementData_MtGeneratorUnit_Id = cdp.MtGenerationUnit_Id
  WHERE cdp.BmeStatementData_StatementProcessId=@StatementProcessId
ORDER BY 
  2 
 
/**********************************************************************************************************************************************************************/
-- 9. 
/**********************************************************************************************************************************************************************/
 
SELECT 
  BmeStatementData_NtdcDateTime, 
  BmeStatementData_MtGenerator_Id, 
  RuCDPDetail_CdpId, 
  SUM(
    ISNULL(
      MtAvailibilityData_CalculatedAvailableCapacityASC, 
      0
    )
  ) AS MtAvailibilityData_AvailableCapacityASCSum, 
  SUM(
    ISNULL(
      BmeStatementData_InstalledCapacity_KW, 
      0
    )
  ) AS BmeStatementData_InstalledCapacity_KWSUM INTO #temp2
FROM 
  #temp
GROUP BY 
  BmeStatementData_NtdcDateTime, 
  BmeStatementData_MtGenerator_Id, 
  RuCDPDetail_CdpId 
/***********************************************************************************************************************************************************************/
-- 10. Prorata (Calculation) of unit wise back feed and unit generation energy.
/**********************************************************************************************************************************************************************/
SELECT 
  DISTINCT #temp.BmeStatementData_NtdcDateTime
  , 
  #temp.BmeStatementData_MtGenerator_Id
  , 
  #temp.BmeStatementData_MtGeneratorUnit_Id
  , 
  BmeStatementData_GenerationUnitEnergy, 
  BmeStatementData_GenerationUnitWiseBackfeed, 
  BmeStatementData_GenerationUnitEnergy_Metered, 
  BmeStatementData_GenerationUnitWiseBackfeed_Metered, 
  #temp.MtAvailibilityData_AvailableCapacityASC
  , 
  #temp.MtAvailibilityData_CalculatedAvailableCapacityASC
  , 
  #temp2.MtAvailibilityData_AvailableCapacityASCSum
  , 
  #temp.SrTechnologyType_Code
  , 
  #temp.BmeStatementData_InstalledCapacity_KW
  , 
  #temp2.BmeStatementData_InstalledCapacity_KWSUM
  , 
  #temp.BmeStatementData_IsBackfeedInclude
  , 
  CASE WHEN #temp2.MtAvailibilityData_AvailableCapacityASCSum > 0 THEN (ISNULL(#temp.MtAvailibilityData_CalculatedAvailableCapacityASC, 0) / ISNULL(#temp2.MtAvailibilityData_AvailableCapacityASCSum, 0))
  ELSE 0 END AS UnitGenRatio, 
  CASE WHEN #temp2.BmeStatementData_InstalledCapacity_KWSUM > 0 THEN (ISNULL(#temp.BmeStatementData_InstalledCapacity_KW, 0) / ISNULL(#temp2.BmeStatementData_InstalledCapacity_KWSUM, 0))
  ELSE 0 END AS UnitBackFeedGenRatio, 
  CASE WHEN #temp2.MtAvailibilityData_AvailableCapacityASCSum > 0 THEN (CAST(ISNULL(#temp.MtAvailibilityData_CalculatedAvailableCapacityASC, 0) AS DECIMAL(25, 13)) / CAST(ISNULL(#temp2.MtAvailibilityData_AvailableCapacityASCSum, 0) AS DECIMAL(25, 13))) * CAST(ISNULL(BmeStatementData_GenerationUnitEnergy, 0) AS DECIMAL(25, 13))
  ELSE 0 END AS UnitGeneration, 
  CASE WHEN #temp2.MtAvailibilityData_AvailableCapacityASCSum > 0 THEN (CAST(ISNULL(#temp.MtAvailibilityData_CalculatedAvailableCapacityASC, 0) AS DECIMAL(25, 13)) / CAST(ISNULL(#temp2.MtAvailibilityData_AvailableCapacityASCSum, 0) AS DECIMAL(25, 13))) * CAST(ISNULL(BmeStatementData_GenerationUnitEnergy_Metered, 0) AS DECIMAL(25, 13))
  ELSE 0 END AS UnitGeneration_Metered, 
  CASE WHEN #temp2.BmeStatementData_InstalledCapacity_KWSUM > 0 --AND #temp.BmeStatementData_IsBackfeedInclude=0
  THEN ABS(
    (
      ISNULL(
        #temp.BmeStatementData_InstalledCapacity_KW, 0) / ISNULL(#temp2.BmeStatementData_InstalledCapacity_KWSUM, 0)) * ISNULL(BmeStatementData_GenerationUnitWiseBackfeed, 0)) --WHEN #temp.BmeStatementData_IsBackfeedInclude=1 THEN ISNULL(BmeStatementData_GenerationUnitWiseBackfeed,0)
        ELSE 0 END AS UnitWiseBackfeed, 
        CASE WHEN #temp2.BmeStatementData_InstalledCapacity_KWSUM > 0 --AND #temp.BmeStatementData_IsBackfeedInclude=0
        THEN ABS(
          (
            ISNULL(
              #temp.BmeStatementData_InstalledCapacity_KW, 0) / ISNULL(#temp2.BmeStatementData_InstalledCapacity_KWSUM, 0)) * ISNULL(BmeStatementData_GenerationUnitWiseBackfeed_Metered, 0))
              ELSE 0 END AS UnitWiseBackfeed_Metered INTO #temp3
              FROM 
                #temp
                JOIN #temp2
                ON #temp.BmeStatementData_NtdcDateTime = #temp2.BmeStatementData_NtdcDateTime
                AND #temp.BmeStatementData_MtGenerator_Id = #temp2.BmeStatementData_MtGenerator_Id
                AND #temp.RuCDPDetail_CdpId = #temp2.RuCDPDetail_CdpId
                
/**********************************************************************************************************************************************************************/
-- 11.  update Unit Wise Generation and BackFeed.
/**********************************************************************************************************************************************************************/
              UPDATE 
                GUH 
              SET 
                [BmeStatementData_UnitWiseGeneration] = t.UnitGeneration, 
                [BmeStatementData_UnitWiseGenerationBackFeed] = t.UnitWiseBackfeed, 
                [BmeStatementData_UnitWiseGeneration_Metered] = t.UnitGeneration_Metered, 
                [BmeStatementData_UnitWiseGenerationBackFeed_Metered] = t.UnitWiseBackfeed_Metered, 
                [BmeStatementData_CalculatedAvailableCapacityASC] = t.MtAvailibilityData_CalculatedAvailableCapacityASC, 
                [BmeStatementData_CalculatedAvailableCapacityASCSum] = t.MtAvailibilityData_AvailableCapacityASCSum 
              FROM 
                [dbo].[BmeStatementDataGenUnitHourly] GUH 
                JOIN #temp3 t
                ON GUH.BmeStatementData_NtdcDateTime = t.BmeStatementData_NtdcDateTime 
                AND GUH.BmeStatementData_MtGeneratorUnit_Id = t.BmeStatementData_MtGeneratorUnit_Id 
              WHERE 
                GUH.BmeStatementData_Year = @Year 
                AND GUH.BmeStatementData_Month = @Month 
                AND GUH.BmeStatementData_StatementProcessId = @StatementProcessId PRINT (
                  GETUTCDATE()
                ) END TRY BEGIN CATCH 
              SELECT 
                ERROR_NUMBER() AS ErrorNumber, 
                ERROR_STATE() AS ErrorState, 
                ERROR_SEVERITY() AS ErrorSeverity, 
                ERROR_PROCEDURE() AS ErrorProcedure, 
                ERROR_LINE() AS ErrorLine, 
                ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
END
