/****** Object:  Procedure [dbo].[ValidateGeneratorData]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================  
-- Author:  M.Asghar(.Net/SQL Consultant)  
-- CREATE date: June 27, 2022 
-- ALTER date: July 05, 2022   
-- Description: 
--              
-- ============================================= 

-- exec [dbo].[ValidateGeneratorData]
CREATE PROCEDURE [dbo].[ValidateGeneratorData]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
BEGIN TRY
/*
SELECT G.MtGenerator_Id,
      GU.MtGenerationUnit_SOUnitId
      
  FROM [MtGenerator] G left join MtGenerationUnit GU
  on G.MtGenerator_Id=GU.MtGenerator_Id
  WHERE ISNULL(G.MtGenerator_IsDeleted,0)=0 AND ISNULL(GU.MtGenerationUnit_IsDeleted,0)=0
*/
DECLARE @COUNT_GEN INT=0;
DECLARE @COUNT_GEN_UNIT INT=0;
DECLARE @COUNT_GEN_UNIT_NOT_DEFINED INT=0;
DECLARE @COUNT_GEN_UNIT_CDP_NOT_DEFINED INT=0;
DECLARE @COUNT_GEN_UNIT_FUEL_TECH_NOT_DEFINED INT=0;
select @COUNT_GEN = COUNT(1),
   @COUNT_GEN_UNIT_NOT_DEFINED =SUM(CASE WHEN GU.MtGenerationUnit_SOUnitId IS NULL THEN 1 ELSE 0 END)         
  FROM [MtGenerator] G left join MtGenerationUnit GU
  on G.MtGenerator_Id=GU.MtGenerator_Id
  WHERE ISNULL(G.MtGenerator_IsDeleted,0)=0 AND ISNULL(GU.MtGenerationUnit_IsDeleted,0)=0 AND ISNULL(G.isDeleted,0)=0 AND ISNULL(GU.isDeleted,0)=0
 AND G.MtPartyCategory_Id in(select P.PartyCategory_Id from dbo.Bme_Parties2 P);
----------------------------------------

select @COUNT_GEN_UNIT = COUNT(1),   
   -- @COUNT_GEN_UNIT_CDP_NOT_DEFINED =SUM(CASE WHEN CM.MtCDPDetail_Id IS NULL THEN 1 ELSE 0 END),          
    @COUNT_GEN_UNIT_FUEL_TECH_NOT_DEFINED =SUM(CASE WHEN GU.SrTechnologyType_Code IS NULL THEN 1 ELSE 0 END)          
  FROM MtGenerator G INNER JOIN MtGenerationUnit GU ON
  G.MtGenerator_Id=GU.MtGenerator_Id  
  LEFT JOIN MtConnectedMeter CM
  ON GU.MtGenerationUnit_Id=CM.MtConnectedMeter_UnitId
  WHERE ISNULL(GU.MtGenerationUnit_IsDeleted,0)=0
  AND ISNULL(GU.isDeleted,0)=0
  AND ISNULL(CM.MtConnectedMeter_isDeleted,0)=0
 AND G.MtPartyCategory_Id in(select P.PartyCategory_Id from dbo.Bme_Parties2 P);

 SET @COUNT_GEN_UNIT_CDP_NOT_DEFINED = (
	 select COUNT(DISTINCT GU.MtGenerationUnit_Id) 
  FROM MtGenerator G INNER JOIN MtGenerationUnit GU ON
  G.MtGenerator_Id=GU.MtGenerator_Id 
  LEFT JOIN MtConnectedMeter CM
  ON GU.MtGenerationUnit_Id=CM.MtConnectedMeter_UnitId and G.MtPartyCategory_Id=cm.MtPartyCategory_Id
  where ISNULL(GU.MtGenerationUnit_IsDeleted,0)=0
  AND ISNULL(GU.isDeleted,0)=0
  AND ISNULL(G.isDeleted,0)=0 
  AND ISNULL(G.MtGenerator_IsDeleted,0)=0
  and CM.MtCDPDetail_Id is null or CM.MtCDPDetail_Id not in(select MtCDPDetail_Id from RuCDPDetail)
 )


 DECLARE @logMessage_gen_unit_not_def VARCHAR(MAX),
 @logMessage_cdp_not_def VARCHAR(MAX),
 @logMessage_fuel_tech_not_def VARCHAR(MAX),
 @GU_LIST NVARCHAR(MAX);

 IF(@COUNT_GEN_UNIT_NOT_DEFINED > 0)
 BEGIN
 DROP TABLE IF EXISTS #TEMP_GEN; 
	SET @GU_LIST = NULL;

select DISTINCT G.MtGenerator_Id   
INTO #TEMP_GEN
  FROM [MtGenerator] G left join MtGenerationUnit GU
  on G.MtGenerator_Id=GU.MtGenerator_Id
  WHERE ISNULL(G.MtGenerator_IsDeleted,0)=0 
  AND ISNULL(G.isDeleted,0)=0
  AND ISNULL(GU.MtGenerationUnit_IsDeleted,0)=0
  AND ISNULL(GU.isDeleted,0) = 0
 AND G.MtPartyCategory_Id in(select P.PartyCategory_Id from dbo.Bme_Parties2 P)
 AND GU.MtGenerationUnit_SOUnitId IS NULL;
 
 select 
   @GU_LIST =  ISNULL(@GU_LIST + ', ', '') + CAST(G.MtGenerator_Id AS VARCHAR(MAX))        
  FROM #TEMP_GEN G;

SET @COUNT_GEN_UNIT_NOT_DEFINED=( select COUNT(*) FROM #TEMP_GEN);

	SET @logMessage_gen_unit_not_def ='Missing Total - ' + CAST(@COUNT_GEN_UNIT_NOT_DEFINED AS NVARCHAR(MAX)) + ': MP Generator defined without Generation-Unit: ' + @GU_LIST;
	
 END

 IF(@COUNT_GEN_UNIT_CDP_NOT_DEFINED > 0)
 BEGIN
	SET @GU_LIST = NULL;
	DROP TABLE IF EXISTS #TEMP_GU; 

    select DISTINCT GU.MtGenerationUnit_Id 
    INTO #TEMP_GU
  FROM MtGenerator G INNER JOIN MtGenerationUnit GU ON
  G.MtGenerator_Id=GU.MtGenerator_Id 
  LEFT JOIN MtConnectedMeter CM
  ON GU.MtGenerationUnit_Id=CM.MtConnectedMeter_UnitId and G.MtPartyCategory_Id=cm.MtPartyCategory_Id
  where ISNULL(GU.MtGenerationUnit_IsDeleted,0)=0
  AND ISNULL(GU.isDeleted,0)=0
  AND ISNULL(G.isDeleted,0)=0 
  AND ISNULL(G.MtGenerator_IsDeleted,0)=0
  and CM.MtCDPDetail_Id is null or CM.MtCDPDetail_Id not in(select MtCDPDetail_Id from RuCDPDetail);

 SELECT @GU_LIST = ISNULL(@GU_LIST + ', ', '') + CAST(gu.MtGenerationUnit_Id AS VARCHAR(MAX))
 FROM #TEMP_GU gu

 SET @COUNT_GEN_UNIT_CDP_NOT_DEFINED = (SELECT COUNT(*) FROM #TEMP_GU tg);

	SET @logMessage_cdp_not_def = 'Missing Total - ' + CAST(@COUNT_GEN_UNIT_CDP_NOT_DEFINED AS NVARCHAR(MAX)) + ': Generation Unit without CDP mapping: ' + @GU_LIST;
	
 END
 IF(@COUNT_GEN_UNIT_FUEL_TECH_NOT_DEFINED > 0)
 BEGIN
	SET @GU_LIST = NULL;
	DROP TABLE IF EXISTS #TEMP_FUELTECH; 

	SELECT DISTINCT GU.MtGenerationUnit_Id
   INTO #TEMP_FUELTECH
   FROM MtGenerator G INNER JOIN MtGenerationUnit GU ON
  G.MtGenerator_Id=GU.MtGenerator_Id  
  LEFT JOIN MtConnectedMeter CM
  ON GU.MtGenerationUnit_Id=CM.MtConnectedMeter_UnitId
  WHERE ISNULL(GU.MtGenerationUnit_IsDeleted,0)=0
  AND ISNULL(GU.isDeleted,0)=0
  AND ISNULL(CM.MtConnectedMeter_isDeleted,0)=0
 AND G.MtPartyCategory_Id in(select P.PartyCategory_Id from dbo.Bme_Parties2 P)
 AND GU.SrTechnologyType_Code IS NULL;

  SELECT @GU_LIST = ISNULL(@GU_LIST + ', ', '') + CAST(gu.MtGenerationUnit_Id AS VARCHAR(MAX))     
  FROM #TEMP_FUELTECH gu

  SET @COUNT_GEN_UNIT_FUEL_TECH_NOT_DEFINED = (SELECT COUNT(*) FROM #TEMP_FUELTECH tf);

	SET @logMessage_fuel_tech_not_def ='Missing Total - ' +  CAST(@COUNT_GEN_UNIT_FUEL_TECH_NOT_DEFINED AS NVARCHAR(MAX)) + ': Fuel Technology is not defined for all Generation-Units: ' + @GU_LIST;
	
 END

 SELECT 0 AS [IS_VALID], OBJECT_NAME(@@PROCID) AS [SP_NAME], @logMessage_gen_unit_not_def AS [LOG_MESSAGE], CASE WHEN @logMessage_gen_unit_not_def IS NOT NULL THEN 'Warning' ELSE 'Success' END AS [ERROR_LEVEL]
WHERE @logMessage_gen_unit_not_def IS NOT NULL
UNION
SELECT 0 AS [IS_VALID], OBJECT_NAME(@@PROCID) AS [SP_NAME], @logMessage_cdp_not_def AS [LOG_MESSAGE], CASE WHEN @logMessage_cdp_not_def IS NOT NULL THEN 'Warning' ELSE 'Success' END AS [ERROR_LEVEL] WHERE @logMessage_cdp_not_def IS NOT NULL
UNION
SELECT 0 AS [IS_VALID], OBJECT_NAME(@@PROCID) AS [SP_NAME], @logMessage_fuel_tech_not_def AS [LOG_MESSAGE], CASE WHEN @logMessage_fuel_tech_not_def IS NOT NULL THEN 'Warning' ELSE 'Success' END AS [ERROR_LEVEL] WHERE @logMessage_fuel_tech_not_def IS NOT NULL


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
