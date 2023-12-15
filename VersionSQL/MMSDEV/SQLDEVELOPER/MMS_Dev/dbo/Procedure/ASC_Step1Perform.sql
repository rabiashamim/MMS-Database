/****** Object:  Procedure [dbo].[ASC_Step1Perform]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================  
-- Author:  M.Asghar(SQL Consultant)
-- CREATE date: April 10, 2022 
-- ALTER date: June 29, 2022   
-- Description: This procedure  
--              1) fetch Generation Units and their parties data and insert into ASC Generation Unit party table. 
--              2) fetch BVM reading data and insert into BME CDP hourly table.
--              
-- Parameters: @Year, @Month, @StatementProcessId  
-- =============================================  
--    dbo.ASC_Step1Perform 2022,6,21
CREATE   PROCEDURE dbo.ASC_Step1Perform(			 
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

	
   IF NOT EXISTS(SELECT TOP 1 AscStatementData_Id FROM AscStatementDataGuHourly WHERE  AscStatementData_Year=@Year and AscStatementData_Month=@Month and AscStatementData_StatementProcessId=@StatementProcessId)
   BEGIN
   DROP TABLE if EXISTS #TempHours;

DECLARE @MONTH_EFFECTIVE_FROM as DATETIME = DATETIMEFROMPARTS(@Year,@Month,1,0,0,0,0);
DECLARE @MONTH_EFFECTIVE_TO as DATETIME = DATEADD(MONTH,1,@MONTH_EFFECTIVE_FROM);

DECLARE @INC_Hour as int=1;
DECLARE @MONTH_BVM_READING_START_TIME as DATETIME=DATETIMEFROMPARTS(@Year,@Month,1,1,0,0,0);
DECLARE @MONTH_BVM_READING_END_TIME as DATETIME=DATEADD(HOUR,-1,  DATEADD(MONTH,1,@MONTH_BVM_READING_START_TIME));


with ROWCTE as  
   (  
      SELECT @MONTH_BVM_READING_START_TIME as dateTimeHour   
		UNION ALL  
      SELECT DATEADD(HOUR, @INC_Hour, dateTimeHour) 
  FROM  ROWCTE  
  WHERE dateTimeHour < @MONTH_BVM_READING_END_TIME
    )  
 
SELECT * 
INTO #TempHours
FROM ROWCTE
OPTION(MAXRECURSION 0) --There is no way to perform a recursion more than 32767 

--SELECT * FROM #TempHours;
	INSERT INTO [dbo].[AscStatementDataGuHourly]
    ( 
        [AscStatementData_StatementProcessId]
       ,[AscStatementData_NtdcDateTime]
      ,[AscStatementData_Year]
      ,[AscStatementData_Month]
      ,[AscStatementData_Day]
      ,[AscStatementData_Hour]
      
      ,[AscStatementData_GenerationUnit_Id]
      ,[AscStatementData_Generator_Id]
      ,[AscStatementData_TechnologyType_Code]
      ,[AscStatementData_FuelType_Code]
      ,[AscStatementData_UnitNumber]
      ,[AscStatementData_InstalledCapacity_KW]
      
      ,[AscStatementData_IsDisabled]
      ,[AscStatementData_EffectiveFrom]
      ,[AscStatementData_EffectiveTo]
      ,[AscStatementData_UnitName]
      ,[AscStatementData_SOUnitId]
      ,[AscStatementData_IsEnergyImported]
      ,[AscStatementData_PartyRegisteration_Id]
      ,[AscStatementData_PartyRegisteration_Name]
      ,[AscStatementData_PartyType_Code]
	  ,[AscStatementData_PartyCategory_Code]
      ,AscStatementData_MtPartyCategory_Id
	  ,AscStatementData_TaxZoneID
	  ,AscStatementData_CongestedZoneID
      ,AscStatementData_CongestedZone
      ,AscStatementData_SO_RG_UT        
    )
SELECT 
@StatementProcessId
 ,T.dateTimeHour as NTDCdateTime,
@Year as Year,
@Month as Month,
DATEPART(DAY,DATEADD(HOUR,-1, t.dateTimeHour)) as Day,
DATEPART(HOUR,DATEADD(HOUR,-1, t.dateTimeHour))+1 as Hour 
      
      ,Gu.[MtGenerationUnit_Id]
      ,Gu.[MtGenerator_Id]
      ,Gu.[SrTechnologyType_Code]
      ,Gu.[SrFuelType_Code]
      ,Gu.[MtGenerationUnit_UnitNumber]
      ,Gu.[MtGenerationUnit_InstalledCapacity_KW]
      ,Gu.[MtGenerationUnit_IsDisabled]
      ,Gu.[MtGenerationUnit_EffectiveFrom]
      ,Gu.[MtGenerationUnit_EffectiveTo]
      ,Gu.[MtGenerationUnit_UnitName]
      ,Gu.[MtGenerationUnit_SOUnitId]
      ,Gu.[MtGenerationUnit_IsEnergyImported]
	  ,Gu.MtPartyRegisteration_Id
	  ,Gu.MtPartyRegisteration_Name
	  ,Gu.SrPartyType_Code
	  ,Gu.SrCategory_Code
	  ,GU.MtPartyCategory_Id
	  ,GU.RuCDPDetail_TaxZoneID
	  ,GU.RuCDPDetail_CongestedZoneID
      ,GU.MtCongestedZone_Name
      , case when GU.SrTechnologyType_Code IN ('ARE', 'HYD') then 'ARE' else GU.SrTechnologyType_Code end
      from ASC_GuParties GU      
, #TempHours T
WHERE GU.MtGenerationUnit_EffectiveFrom<=@MONTH_EFFECTIVE_FROM and ISNULL(GU.MtGenerationUnit_EffectiveTo,@MONTH_EFFECTIVE_TO)>=@MONTH_EFFECTIVE_TO
AND GU.CDP_EffectiveFrom<=@MONTH_EFFECTIVE_FROM and ISNULL(GU.CDP_EffectiveTo,@MONTH_EFFECTIVE_TO)>=@MONTH_EFFECTIVE_TO






/*
replace view with query
*/

DROP TABLE IF EXISTS #tempCM
DROP TABLE IF EXISTS #tempCDPParty

SELECT DISTINCT
	MtConnectedMeter_UnitId,MtCDPDetail_Id
INTO #tempCM
FROM MtConnectedMeter
WHERE ISNULL(MtConnectedMeter_isDeleted, 0) = 0 
                        and MtConnectedMeter_UnitId is not null



SELECT  distinct
	  MP.MtPartyRegisteration_Id
	  ,MP.MtPartyRegisteration_Name
	  ,MP.SrPartyType_Code
	  ,PC.MtPartyCategory_Id
	  ,PC.SrCategory_Code
	  ,Gu.[MtGenerationUnit_Id]
      ,Gu.[MtGenerator_Id]
      ,Gu.[SrTechnologyType_Code]
      ,Gu.[SrFuelType_Code]
      ,Gu.[MtGenerationUnit_UnitNumber]
      ,Gu.[MtGenerationUnit_InstalledCapacity_KW]
      ,Gu.[MtGenerationUnit_IsDisabled]
      ,Gu.[MtGenerationUnit_EffectiveFrom]
      ,Gu.[MtGenerationUnit_EffectiveTo]
      ,Gu.[MtGenerationUnit_UnitName]
      ,Gu.[MtGenerationUnit_SOUnitId]
      ,Gu.[MtGenerationUnit_IsEnergyImported]
	  ,cdp.RuCDPDetail_TaxZoneID
	  ,cdp.RuCDPDetail_CongestedZoneID
      ,cdp.MtCongestedZone_Name
	  ,cdp.RuCDPDetail_Id
	  ,cdp.RuCDPDetail_CdpId
	  ,cdp.FromPartyRegisteration_Id, cdp.FromPartyRegisteration_Name, cdp.FromPartyType_Code 
     ,cdp.FromPartyCategory_Code, cdp.ToPartyRegisteration_Id, cdp.ToPartyRegisteration_Name, cdp.ToPartyType_Code, cdp.ToPartyCategory_Code, cdp.RuCDPDetail_IsEnergyImported,
	 ISNULL
			 ((SELECT TOP (1) 1 AS Expr1
                        FROM      dbo.Bme_GuParties as GU
                        WHERE   (GU.MtGenerationUnit_Id in(select MtConnectedMeter_UnitId from #tempCM where  MtCDPDetail_Id=cdp.RuCDPDetail_Id)) AND (GU.SrTechnologyType_Code IN ('ARE', 'HYD'))), 0) AS IsARE, ISNULL
                      ((SELECT TOP (1) 1 AS Expr1
                        FROM      dbo.Bme_GuParties AS GU
                        WHERE   (GU.MtGenerationUnit_Id in(select MtConnectedMeter_UnitId from #tempCM where  MtCDPDetail_Id=cdp.RuCDPDetail_Id)) AND (GU.SrTechnologyType_Code = 'THR')), 0) AS IsThermal

                         ,ISNULL(MP.MtPartyRegisteration_IsPowerPool,0) AS IsPowerPool
                        ,CDP.RuCDPDetail_EffectiveFrom as CDP_EffectiveFrom,
                        CDP.RuCDPDetail_EffectiveTo as CDP_EffectiveTo
INTO #tempCDPParty
FROM MtPartyRegisteration MP
INNER JOIN MtPartyCategory PC ON MP.MtPartyRegisteration_Id=PC.MtPartyRegisteration_Id
INNER JOIN MtConnectedMeter MC ON MC.MtPartyCategory_Id = PC.MtPartyCategory_Id
INNER JOIN MtGenerator G ON G.MtPartyCategory_Id=PC.MtPartyCategory_Id
INNER JOIN MtGenerationUnit GU ON GU.MtGenerationUnit_Id=MC.MtConnectedMeter_UnitId  and GU.MtGenerator_Id = G.MtGenerator_Id
--JOIN RuCDPDetail RU ON RU.RuCDPDetail_Id=MC.MtCDPDetail_Id
INNER JOIN dbo.Bme_CdpParties AS cdp ON MC.MtCDPDetail_Id = cdp.RuCDPDetail_Id
WHERE 
ISNULL(MP.isDeleted,0)=0
AND  ISNULL(PC.isDeleted,0)=0
AND  ISNULL(MC.MtConnectedMeter_isDeleted,0)=0
AND ISNULL(G.isDeleted,0)=0
and ISNULL(GU.MtGenerationUnit_IsDisabled,0)=0
AND ISNULL(GU.isDeleted,0)=0
AND ISNULL(GU.MtGenerationUnit_IsDeleted,0)=0
--AND (MP.LuStatus_Code_Applicant<>'ATER'  and  MP.LuStatus_Code_Approval <> 'TERM' )
AND MC.MtConnectedMeter_UnitId IS NOT NULL AND cdp.RuCDPDetail_CongestedZoneID IS NOT NULL
AND  MP.LuStatus_Code_Applicant='AACT'
--AND SrPartyType_Code <> 'EP'

/***********************/
INSERT INTO [dbo].[AscStatementDataCdpGuParty]
           (
                [AscStatementData_StatementProcessId]
               ,[AscStatementData_GuPartyRegisteration_Id]
           ,[AscStatementData_GuPartyRegisteration_Name]
           ,[AscStatementData_GuPartyCategory_Code]
           ,[AscStatementData_GuPartyType_Code]
           ,[AscStatementData_CdpId]
           ,[AscStatementData_FromPartyRegisteration_Id]
           ,[AscStatementData_FromPartyRegisteration_Name]
           ,[AscStatementData_FromPartyCategory_Code]
           ,[AscStatementData_FromPartyType_Code]
           ,[AscStatementData_ToPartyRegisteration_Id]
           ,[AscStatementData_ToPartyRegisteration_Name]
           ,[AscStatementData_ToPartyCategory_Code]
           ,[AscStatementData_ToPartyType_Code]
           --,[AscStatementData_ISARE]
           --,[AscStatementData_ISThermal]
           ,[AscStatementData_RuCDPDetail_Id]
           ,[AscStatementData_IsLegacy]
           ,[AscStatementData_IsEnergyImported]
           ,[AscStatementData_IsPowerPool]
           ,[AscStatementData_GenerationUnit_Id]
           ,[AscStatementData_Generator_Id]
		   ,[AscStatementData_SOUnitId]
           ,[AscStatementData_CongestedZoneId]
           ,[AscStatementData_CongestedZone])
   
SELECT distinct
@StatementProcessId
,MtPartyRegisteration_Id
,MtPartyRegisteration_Name
,SrCategory_Code
,SrPartyType_Code
,RuCDPDetail_CdpId
,FromPartyRegisteration_Id, 
FromPartyRegisteration_Name,		
FromPartyCategory_Code,
FromPartyType_Code,
ToPartyRegisteration_Id,	
ToPartyRegisteration_Name,
ToPartyCategory_Code,
ToPartyType_Code,
--IsARE,	
--IsThermal,
RuCDPDetail_Id,
IsPowerPool as IsLegacy,
RuCDPDetail_IsEnergyImported,
IsPowerPool,
MtGenerationUnit_Id,
MtGenerator_Id,
MtGenerationUnit_SOUnitId,
RuCDPDetail_CongestedZoneID,
MtCongestedZone_Name
FROM  #tempCDPParty GU
WHERE GU.MtGenerationUnit_EffectiveFrom<=@MONTH_EFFECTIVE_FROM and ISNULL(GU.MtGenerationUnit_EffectiveTo,@MONTH_EFFECTIVE_TO)>=@MONTH_EFFECTIVE_TO
AND GU.CDP_EffectiveFrom<=@MONTH_EFFECTIVE_FROM and ISNULL(GU.CDP_EffectiveTo,@MONTH_EFFECTIVE_TO)>=@MONTH_EFFECTIVE_TO

/*
select * from MtMustRunGen where MtSOFileMaster_Id=55
select * from MtMarginalPrice where MtSOFileMaster_Id=38
select * from MtAscRG where MtSOFileMaster_Id=56
select * from MtAscIG where MtSOFileMaster_Id=52
select * from MtGeneratorBS where MtSOFileMaster_Id=57
select * from MtAvailibilityData where MtSOFileMaster_Id=36
select * from MtGeneratorStart where MtSOFileMaster_Id =59
*/
-- SELECT * FROM MtSOFileMaster WHERE MtSOFileMaster_Id=52
-- select dbo.GetMtSoFileMasterId(20, 5)

UPDATE [AscStatementDataGuHourly] 
	set 

	AscStatementData_SO_AC =ISNULL(AD.MtAvailibilityData_ActualCapacity,0),
    AscStatementData_SO_AC_ASC =ISNULL(AD.MtAvailibilityData_AvailableCapacityASC,0)
	FROM [AscStatementDataGuHourly]  as GH
	INNER JOIN MtAvailibilityData AD ON AD.MtGenerationUnit_Id=GH.AscStatementData_SOUnitId
	AND  DATEADD(HOUR,CAST(AD.MtAvailibilityData_Hour AS INT)+1,CAST(AD.MtAvailibilityData_Date AS datetime))=GH.AscStatementData_NtdcDateTime
     WHERE GH.AscStatementData_Year=@Year and GH.AscStatementData_Month=@Month and GH.AscStatementData_StatementProcessId=@StatementProcessId
      and AD.MtSOFileMaster_Id= dbo.GetMtSoFileMasterId(@StatementProcessId, 2) --36 ,dbo.GetMtSoFileMasterId(20, 2);
     
--------------------------------

UPDATE [AscStatementDataGuHourly] 
	set 
	AscStatementData_SO_MR_EP =ISNULL(AD.MtMustRunGen_EnergyProduced,0)
	,AscStatementData_SO_MR_VC =ISNULL(AD.MtMustRunGen_VariableCost,0)
    ,AscStatementData_IsGenMR=1
	FROM [AscStatementDataGuHourly]  as GH
	INNER JOIN MtMustRunGen AD ON AD.MtGenerationUnit_Id=GH.AscStatementData_SOUnitId
	AND  DATEADD(HOUR,CAST(AD.MtMustRunGen_Hour AS INT)+1,CAST(AD.MtMustRunGen_Date AS datetime))=GH.AscStatementData_NtdcDateTime
WHERE GH.AscStatementData_Year=@Year and GH.AscStatementData_Month=@Month and GH.AscStatementData_StatementProcessId=@StatementProcessId
 and AD.MtSOFileMaster_Id=dbo.GetMtSoFileMasterId(@StatementProcessId, 3)--55;

 ------------------------

UPDATE [AscStatementDataGuHourly] 
	set 
	AscStatementData_SO_MP =ISNULL(AD.MtMarginalPrice_Price,0)
	FROM [AscStatementDataGuHourly]  as GH
	INNER JOIN MtMarginalPrice AD 
	ON DATEADD(HOUR,CAST(AD.MtMarginalPrice_Hour AS INT)+1,CAST(AD.MtMarginalPrice_Date AS datetime))=GH.AscStatementData_NtdcDateTime
WHERE GH.AscStatementData_Year=@Year and GH.AscStatementData_Month=@Month and GH.AscStatementData_StatementProcessId=@StatementProcessId
and AD.MtSOFileMaster_Id=dbo.GetMtSoFileMasterId(@StatementProcessId, 1) --38;

------------------------------

UPDATE [AscStatementDataGuHourly] 
	set 	
    AscStatementData_SO_RG_VC = ISNULL(AD.MtAscRG_VariableCost,0)
    ,AscStatementData_SO_RG_EG_ARE = ISNULL(AD.MtAscRG_ExpectedEnergy,0)
	,AscStatementData_IsRG=1
	FROM [AscStatementDataGuHourly]  as GH
	INNER JOIN MtAscRG AD 
	ON DATEADD(HOUR,CAST(AD.MtAscRG_Hour AS INT)+1,CAST(AD.MtAscRG_Date AS datetime))=GH.AscStatementData_NtdcDateTime
	AND AD.MtGenerationUnit_Id = GH.AscStatementData_SOUnitId
	WHERE GH.AscStatementData_Year=@Year and GH.AscStatementData_Month=@Month and GH.AscStatementData_StatementProcessId=@StatementProcessId 
    AND AD.MtSOFileMaster_Id= dbo.GetMtSoFileMasterId(@StatementProcessId,6)--56;

----------------------------------------


UPDATE [AscStatementDataGuHourly] 
	set 
	AscStatementData_SO_IG_VC = ISNULL(AD.MtAscIG_VariableCost,0)
    , AscStatementData_SO_IG_EPG = ISNULL(NULLIF(AD.EnergyProduceIfNoAncillaryServices,''),0)
    ,AscStatementData_IsIG=1
	FROM [AscStatementDataGuHourly]  as GH
	INNER JOIN MtAscIG AD 
	ON DATEADD(HOUR,CAST(AD.MtAscIG_Hour AS INT)+1,CAST(AD.MtAscIG_Date AS datetime))=GH.AscStatementData_NtdcDateTime
	AND AD.MtGenerationUnit_Id = GH.AscStatementData_SOUnitId
	WHERE GH.AscStatementData_Year=@Year and GH.AscStatementData_Month=@Month and GH.AscStatementData_StatementProcessId=@StatementProcessId 
    AND AD.MtSOFileMaster_Id=dbo.GetMtSoFileMasterId(@StatementProcessId, 5) --52;


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
