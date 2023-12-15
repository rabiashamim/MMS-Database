/****** Object:  Procedure [dbo].[BMCStep1Perform]    Committed by VersionSQL https://www.versionsql.com ******/

--==========================================================================================
-- Author: Ali Imran
-- CREATE date: 21 Dec 2022
-- ALTER date:    
-- Description:               
--==========================================================================================
CREATE    PROCEDURE dbo.BMCStep1Perform 
@pStatementProcessId DECIMAL(18, 0)
AS
BEGIN

/*==========================================================================================
Fetch BMCVariablesData
==========================================================================================*/
IF NOT EXISTS (SELECT TOP 1 1 FROM [dbo].BMCVariablesData bd WHERE MtStatementProcess_ID=@pStatementProcessId)
BEGIN

DECLARE 
--@vYear DECIMAL(18, 0),
@vFromDate DATE
	,@vToDate DATE;
SELECT
		--@vYear=lam.LuAccountingMonth_MonthName
		@vFromDate = LAM.LuAccountingMonth_FromDate
		,@vToDate = LAM.LuAccountingMonth_ToDate
	FROM MtStatementProcess msp
	JOIN LuAccountingMonth lam ON msp.LuAccountingMonth_Id_Current=lam.LuAccountingMonth_Id
	WHERE msp.MtStatementProcess_ID = @pStatementProcessId;

INSERT INTO [dbo].[BMCVariablesData]
           ([BMCVariablesData_ReserveMargin]
           ,[BMCVariablesData_EfficientlevelReserve]
           ,[BMCVariablesData_UnitaryCostCapacity]
           ,[BMCVariablesData_KEShare_MW]
		   ,[MtStatementProcess_ID])

SELECT 
	
			MAX(CASE
				WHEN ((@vFromDate >= rrv.RuReferenceValue_EffectiveFrom  AND (@vToDate BETWEEN cast(rrv.RuReferenceValue_EffectiveFrom AS DATE) AND CAST(rrv.RuReferenceValue_EffectiveTo AS DATE))) AND
					SRT.SrReferenceType_Name = 'Reserve Margin') THEN rrv.RuReferenceValue_Value
				ELSE 0
			END) AS RM

		   ,MAX(CASE
				WHEN ((@vFromDate >= rrv.RuReferenceValue_EffectiveFrom  AND (@vToDate BETWEEN CAST(rrv.RuReferenceValue_EffectiveFrom AS DATE) AND cast(rrv.RuReferenceValue_EffectiveTo AS DATE))) AND
					SRT.SrReferenceType_Name = 'RE') THEN rrv.RuReferenceValue_Value
				ELSE 0
			END) AS RE

		   ,MAX(CASE
				WHEN ((@vFromDate >= rrv.RuReferenceValue_EffectiveFrom  AND (@vToDate BETWEEN cast(rrv.RuReferenceValue_EffectiveFrom AS DATE) AND CAST(rrv.RuReferenceValue_EffectiveTo AS DATE))) AND
					SRT.SrReferenceType_Name = 'LIC') THEN rrv.RuReferenceValue_Value
				ELSE 0
			END) AS LIC

		   ,MAX(CASE
				WHEN ((@vFromDate >= rrv.RuReferenceValue_EffectiveFrom  AND (@vToDate BETWEEN cast(rrv.RuReferenceValue_EffectiveFrom AS DATE) AND cast(rrv.RuReferenceValue_EffectiveTo AS DATE))) AND
					SRT.SrReferenceType_Name = 'KE Share') THEN rrv.RuReferenceValue_Value
				ELSE 0
			END) AS KEShare

	, @pStatementProcessId

FROM RuReferenceValue rrv
JOIN SrReferenceType SRT ON RRV.SrReferenceType_Id=SRT.SrReferenceType_Id
WHERE 
 ISNULL(srt.SrReferenceType_IsDeleted, 0) = 0
 AND ISNULL(rrv.RuReferenceValue_IsDeleted, 0) = 0

END

/*==========================================================================================
 Fetch [dbo].[BMCAllocationFactors]
==========================================================================================*/
IF NOT EXISTS (SELECT TOP 1 1 FROM [dbo].[BMCAllocationFactors] WHERE MtStatementProcess_ID=@pStatementProcessId)
BEGIN

INSERT INTO [dbo].[BMCAllocationFactors]
           ([BMCAllocationFactors_AllocationFactor]
           ,[MtPartyRegisteration_Id]
           ,[MtStatementProcess_ID])
SELECT LuAllocationFactors_Factor,MtPartyRegisteration_Id,@pStatementProcessId
FROM  dbo.LuAllocationFactors

END

/*==========================================================================================
Fetch Data from MtCriticalHoursCapacity 
INSERT in BMCAvailableCapacityGUHourly
==========================================================================================*/
IF NOT EXISTS (SELECT TOP 1
            1
        FROM [dbo].[BMCAvailableCapacityGUHourly]
        WHERE MtStatementProcess_ID = @pStatementProcessId)
	BEGIN
    INSERT INTO [dbo].[BMCAvailableCapacityGUHourly] ([BMCAvailableCapacityGUHourly_Date]
    , [BMCAvailableCapacityGUHourly_Hour]
    , [BMCAvailableCapacityGUHourly_CriticalHourCapacity]
    , [BMCAvailableCapacityGUHourly_SoUnitId]
    , [MtGenerationUnit_Id]
    , [MtGenerator_Id]
    , [MtStatementProcess_ID])
        SELECT
            MtCriticalHoursCapacity_Date
           ,MtCriticalHoursCapacity_Hour
           ,MtCriticalHoursCapacity_Capacity
           ,MtCriticalHoursCapacity_SOUnitId
           ,GU.GenUnitId
           ,GU.GenId
           ,@pStatementProcessId
        FROM [dbo].[MtCriticalHoursCapacity] CHC
        JOIN vw_OnlyGenUnit GU
            ON CHC.MtCriticalHoursCapacity_SOUnitId = GU.SoUnitId
        WHERE MtSOFileMaster_Id = dbo.GetMtSoFileMasterId(@pStatementProcessId, 10)
 
	END


/*==========================================================================================
INSERT IN BMCAvailableCapacityGU
AND
Calculate Average Capacity
==========================================================================================*/

	IF NOT EXISTS ( SELECT TOP 1
		1
	FROM [dbo].[BMCAvailableCapacityGU]
	WHERE MtStatementProcess_ID = @pStatementProcessId)
BEGIN
	INSERT INTO [dbo].[BMCAvailableCapacityGU] ([BMCAvailableCapacityGU_AvgCapacityCal]
	, [BMCAvailableCapacityGU_SoUnitId]
	, [MtGenerator_Id]
	, [MtGenerationUnit_Id]
	, [MtStatementProcess_ID])


		SELECT
			AVG(BMCAvailableCapacityGUHourly_CriticalHourCapacity)/1000 AS AvgCapacityCal
		   ,BMCAvailableCapacityGUHourly_SoUnitId
		   ,MtGenerator_Id
		   ,MtGenerationUnit_Id
		   ,MtStatementProcess_ID
		FROM BMCAvailableCapacityGUHourly GUH
		WHERE MtStatementProcess_ID = @pStatementProcessId
		GROUP BY MtGenerator_Id
				,MtGenerationUnit_Id
				,BMCAvailableCapacityGUHourly_SoUnitId
				,MtStatementProcess_ID

END
END
