/****** Object:  Procedure [dbo].[PreliminaryCheckDataManagementProcess]    Committed by VersionSQL https://www.versionsql.com ******/

--*************************** Create new data management process for Bilateral Contract Energy and Capacity  
CREATE   PROCEDURE dbo.PreliminaryCheckDataManagementProcess  
  
@pLuSoFileTemplateId int,  
@pSettlementPeriod int,  
@pDescription NVARCHAR(MAX),         
@pUserId int  
  
AS BEGIN
  
Declare @LuSoFileTemplateConfiguration as int;
SELECT
	@LuSoFileTemplateConfiguration = LuDataConfiguration_Id
FROM LuSOFileTemplate
WHERE LuSOFileTemplate_Id = @pLuSoFileTemplateId;
/*********************	Check for Bilateral Contract ENERGY	*****************/

IF (@pLuSoFileTemplateId = 8
	AND @LuSoFileTemplateConfiguration = 2)
BEGIN
DECLARE @pYear AS INT;
DECLARE @pMonth AS INT;
SELECT
	@pYear = LuAccountingMonth_Year
   ,@pMonth = LuAccountingMonth_Month
FROM LuAccountingMonth
WHERE LuAccountingMonth_Id = @pSettlementPeriod

DECLARE @MONTH_EFFECTIVE_FROM AS DATETIME = DATETIMEFROMPARTS(@pYear, @pMonth, 1, 0, 0, 0, 0);
--DECLARE @MONTH_EFFECTIVE_TO AS DATETIME = DATEADD(MONTH, 1, @MONTH_EFFECTIVE_FROM);
DECLARE @MONTH_EFFECTIVE_TO AS DATETIME = EOMONTH(@MONTH_EFFECTIVE_FROM);

DECLARE @INC_Hour AS INT = 1;
DECLARE @MONTH_BVM_READING_START_TIME AS DATETIME = DATETIMEFROMPARTS(@pYear, @pMonth, 1, 0, 0, 0, 0);
DECLARE @MONTH_BVM_READING_END_TIME AS DATETIME = DATEADD(HOUR, -1, DATEADD(MONTH, 1, @MONTH_BVM_READING_START_TIME));


WITH ROWCTE
AS
(SELECT
		@MONTH_BVM_READING_START_TIME AS dateTimeHour
	UNION ALL
	SELECT
		DATEADD(HOUR, @INC_Hour, dateTimeHour)
	FROM ROWCTE

	WHERE dateTimeHour < @MONTH_BVM_READING_END_TIME)

SELECT
	* INTO #TempHours
FROM ROWCTE
OPTION (MAXRECURSION 0)


---------------------------------------------------



SELECT
	* INTO #contracts
FROM MtContractRegistration
WHERE @MONTH_EFFECTIVE_FROM >= MtContractRegistration_EffectiveFrom
AND @MONTH_EFFECTIVE_TO <= MtContractRegistration_EffectiveTo
AND MtContractRegistration_IsDeleted = 0
AND MtContractRegistration_Status = 'CATV' --only active contract
AND MtContractRegistration_ApprovalStatus IN ('CAAP', 'CAMA','CAWA')
IF NOT EXISTS (SELECT
			1
		FROM #contracts)
BEGIN
--PRINT ('NOT Contract founds')
RAISERROR ('No Contract found to Generate Energy Profile.', 16, -1)
RETURN;
END
END
---------------------------------------------------------------------
/*********************	Check for Bilateral Contract Energy	*****************/
/*********************	Check for Bilateral Contract Capacity	*****************/

ELSE
IF (@pLuSoFileTemplateId = 9
	AND @LuSoFileTemplateConfiguration = 2)
BEGIN
DECLARE @pYearCapacity AS INT;


DECLARE @pEffectiveFromDate DATE-- = DATETIMEFROMPARTS(@pYearCapacity, 1, 1, 0, 0, 0, 0);
DECLARE @pEffectiveToDate DATE-- = DATEFROMPARTS(YEAR(@pEffectiveFromDate), 12, 31);

SELECT
	@pYearCapacity = LuAccountingMonth_Year,
	@pEffectiveFromDate = LuAccountingMonth_FromDate,
	@pEffectiveToDate = LuAccountingMonth_ToDate
FROM LuAccountingMonth
WHERE LuAccountingMonth_Id = @pSettlementPeriod;

-- 2. Generate a sequence of dates for the complete year.            
WITH dates_CTE (date)
AS
(SELECT
		@pEffectiveFromDate
	UNION ALL
	SELECT
		DATEADD(DAY, 1, date)
	FROM dates_CTE
	WHERE date < @pEffectiveToDate)
SELECT
	* INTO #YearDates
FROM dates_CTE
OPTION (MAXRECURSION 0);

-- 3. Get the capacity profile of all the contracts which cover the year in question.             
--SELECT
--	* INTO #CapacityContracts
--FROM MtContractRegistration
--WHERE @pEffectiveFromDate >= MtContractRegistration_EffectiveFrom
--AND @pEffectiveToDate <= MtContractRegistration_EffectiveTo
--AND MtContractRegistration_IsDeleted = 0
--AND MtContractRegistration_Status = 'CATV' --only active contract
--AND MtContractRegistration_ApprovalStatus IN ('CAAP', 'CAMA')

SELECT
	mcpc.MtContractRegistration_Id
   ,mcpc.MtContractProfileCapacity_Id
   ,mcpc.MtContractProfileCapacity_DateFrom
   ,mcpc.MtContractProfileCapacity_DateTo
   ,mcpc.MtContractProfileCapacity_ContractQuantity_MW
   ,mcpc.MtContractProfileCapacity_CapQuantity_MW
   ,mcpc.MtContractProfileCapacity_Percentage
   ,mcpc.MtContractProfileCapacity_IsGuaranteed
   ,mcr.MtContractRegistration_SellerId
   ,mcr.MtContractRegistration_BuyerId
   ,mcr.MtContractRegistration_BuyerCategoryId
   ,mcr.MtContractRegistration_SellerCategoryId
   ,mcr.SrContractType_Id INTO #CapacityContracts
FROM MtContractProfileCapacity mcpc
INNER JOIN MtContractRegistration mcr
	ON mcpc.MtContractRegistration_Id = mcr.MtContractRegistration_Id
WHERE --@pEffectiveFromDate >= mcr.MtContractRegistration_EffectiveFrom  AND (@pEffectiveToDate BETWEEN mcr.MtContractRegistration_EffectiveFrom AND mcr.MtContractRegistration_EffectiveTo)
(mcr.MtContractRegistration_EffectiveFrom between @pEffectiveFromDate and @pEffectiveToDate OR
mcr.MtContractRegistration_EffectiveTo between @pEffectiveFromDate and @pEffectiveToDate OR
(MtContractRegistration_EffectiveFrom <= @pEffectiveFromDate and MtContractRegistration_EffectiveTo>= @pEffectiveToDate))

AND ISNULL(mcpc.MtContractProfileCapacity_IsDeleted, 0) = 0
AND ISNULL(mcr.MtContractRegistration_IsDeleted, 0) = 0
AND mcr.MtContractRegistration_Status = 'CATV'
AND mcr.MtContractRegistration_ApprovalStatus IN ('CAAP', 'CAMA','CAWA')


IF NOT EXISTS (SELECT
			1
		FROM #CapacityContracts cc)
BEGIN
--DECLARE @vYearString VARCHAR(20) = CAST(@pYearCapacity AS VARCHAR(20));
--RAISERROR ('No capacity contracts exist for the year %s', 16, -1, @vYearString)
   DECLARE @vYearString VARCHAR(50) =CAST(@pEffectiveFromDate  AS VARCHAR(20)) + ' and ' +  CAST(@pEffectiveToDate  AS VARCHAR(20));
RAISERROR ('No active capacity contracts exist for the period %s', 16, -1, @vYearString)    
RETURN;
END

END
---------------------------------------------------------------------
/*********************	Check for Bilateral Contract Capacity	*****************/
Declare @fileName as varchar(50)
Declare @periodConfiguration as int
select @fileName=LuSOFileTemplate_Name, @periodConfiguration=LuSOFileTemplate_PeriodType from LuSOFileTemplate where LuSOFileTemplate_Id=@pLuSoFileTemplateId
Declare @Period as varchar(20)

select @Period= case when @periodConfiguration in (1,3) then LuAccountingMonth_MonthName  WHEN @periodConfiguration=2 then CAST(LuAccountingMonth_Year AS VARCHAR(20)) end from LuAccountingMonth where LuAccountingMonth_Id=@pSettlementPeriod

IF EXISTS (SELECT
			1
		FROM MtSOFileMaster
		WHERE LuSOFileTemplate_Id = @pLuSoFileTemplateId
		AND LuAccountingMonth_Id = @pSettlementPeriod
		AND ISNULL(MtSOFileMaster_IsDeleted, 0) = 0)
BEGIN
DECLARE @ApprovalStatus VARCHAR(20) = NULL;
DECLARE @Version INT = NULL;

SELECT TOP 1
	@ApprovalStatus = MtSOFileMaster_ApprovalStatus
   ,@Version = MtSOFileMaster_Version
FROM MtSOFileMaster
WHERE LuSOFileTemplate_Id = @pLuSoFileTemplateId
AND LuAccountingMonth_Id = @pSettlementPeriod
AND ISNULL(MtSOFileMaster_IsDeleted, 0) = 0
ORDER BY MtSOFileMaster_Version DESC

IF (@ApprovalStatus <> 'Approved')
BEGIN
--    Select 'Please select approve or remove version '+@Version+' before generation   new   version' as response  
Declare @errorMessage as varchar(max);
set @errorMessage='Dataset for '+@fileName+' for the period of '+@Period+' already exists in MMS in draft status. Please remove that before creating new verion.'
RAISERROR (@errorMessage, 16, -1)
END

ELSE
BEGIN
SELECT
	'Dataset for '+@fileName+' for the period of '+@Period+' already exists in MMS. Do you want to continue generating V' + CONVERT(VARCHAR(3), (@Version + 1)) + ' of '+@fileName+'?' AS response
END
END
ELSE
BEGIN
--User can generate version 1 of selected process  

--EXEC [dbo].[SofileMater_Insert] @pSettlementPeriod=@pSettlementPeriod, @pDescription=@pDescription, @pSOFileTemplate=@pLuSoFileTemplateId  
SELECT
	'1' AS response

END

END
