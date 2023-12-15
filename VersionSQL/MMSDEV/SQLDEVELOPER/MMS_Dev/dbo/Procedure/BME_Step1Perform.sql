/****** Object:  Procedure [dbo].[BME_Step1Perform]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================  
-- Author:  M.Asghar(.Net/SQL Consultant), Ali Imran (.Net/SQL Developer)  
-- CREATE date: March 16, 2022 
-- ALTER date: June 09, 2022   
-- Description: This procedure  
--              1) fetch CDPs data and insert into BME CDPs party table. 
--              2) fetch BVM reading data and insert into BME CDP hourly table.
--              
-- Parameters: @Year, @Month, @StatementProcessId  
-- =============================================  
 -- dbo.BME_Step1Perform 2022,5,9
CREATE   PROCEDURE dbo.BME_Step1Perform(			 
			@Year INT ,
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

    IF NOT EXISTS(SELECT TOP 1 BmeStatementData_Id FROM BmeStatementDataCdpHourly WHERE  BmeStatementData_Year=@Year and BmeStatementData_Month=@Month and BmeStatementData_StatementProcessId=@StatementProcessId)
    BEGIN
 /*
  DROP TABLE if EXISTS #TempHours;


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
OPTION(MAXRECURSION 0); --There is no way to perform a recursion more than 32767 
*/
-------------------------------------------------------------------
/*****************************************************************/
-- View replacement code
/*****************************************************************/


DROP TABLE IF EXISTS #tempCM
DROP TABLE IF EXISTS #tempCDPParty

SELECT DISTINCT
	MtConnectedMeter_UnitId,MtCDPDetail_Id
INTO #tempCM
FROM MtConnectedMeter
WHERE ISNULL(MtConnectedMeter_isDeleted, 0) = 0 
                        and MtConnectedMeter_UnitId is not null


SELECT cdp.RuCDPDetail_Id, cdp.RuCDPDetail_CdpId, cdp.RuCDPDetail_LineVoltage, fromParty.PartyRegisteration_Id AS FromPartyRegisteration_Id, 
                  fromParty.PartyRegisteration_Name AS FromPartyRegisteration_Name,fromParty.MPId as FromPartyMPId,fromParty.IsPowerPool as FromPartyIsPowerPool,
                  cdp.RuCDPDetail_FromCustomerCategory AS FromPartyCategory_Code,
                  fromParty.PartyType_Code AS FromPartyType_Code,
                  ToParty.PartyRegisteration_Id AS ToPartyRegisteration_Id, 
                  ToParty.PartyRegisteration_Name AS ToPartyRegisteration_Name, 
                  cdp.RuCDPDetail_ToCustomerCategory AS ToPartyCategory_Code, 
                  ToParty.PartyType_Code AS ToPartyType_Code, ToParty.MPId as ToPartyMPId,toParty.IsPowerPool as ToPartyIsPowerPool
                  ,case when fromParty.IsPowerPool=1 or toParty.IsPowerPool=1 then 1 else 0 END as IsLegacy,
                  cdp.RuCDPDetail_IsEnergyImported,
                  cdp.RuCDPDetail_TaxZoneID
                 ,cdp.RuCDPDetail_CongestedZoneID
                 ,cz.MtCongestedZone_Name
                 ,cdp.IsBackfeedInclude

/* Task Id 1623 * Add Column */
				  , ISNULL
                     ((SELECT TOP (1) 1 AS Expr1
                        FROM      dbo.Bme_GuParties as BGU
                        WHERE   (
						BGU.MtGenerationUnit_Id IN
						(SELECT MtConnectedMeter_UnitId FROM #tempCM WHERE MtCDPDetail_Id=cdp.RuCDPDetail_Id)
								) 
						AND (ISNULL(BGU.Lu_CapUnitGenVari_Id,0) =3)
						), 0) AS IsActualGeneration
	
                 ,ISNULL
                     ((SELECT TOP (1) 1 AS Expr1
                        FROM      dbo.Bme_GuParties as BGU
                        WHERE   (BGU.MtGenerationUnit_Id in(SELECT MtConnectedMeter_UnitId FROM #tempCM WHERE MtCDPDetail_Id=cdp.RuCDPDetail_Id)) AND (BGU.SrTechnologyType_Code IN ('ARE', 'HYD'))), 0) AS IsARE
                        , ISNULL
                      ((SELECT TOP (1) 1 AS Expr1
                        FROM      dbo.Bme_GuParties AS BGU
                        WHERE   (BGU.MtGenerationUnit_Id IN (SELECT MtConnectedMeter_UnitId  from #tempCM where  MtCDPDetail_Id=cdp.RuCDPDetail_Id)) AND (BGU.SrTechnologyType_Code = 'THR')), 0) AS IsThermal
                      ,  CDP.RuCDPDetail_EffectiveFrom,CDP.RuCDPDetail_EffectiveTo
INTO #tempCDPParty
FROM     dbo.RuCDPDetail cdp INNER JOIN
                  dbo.Bme_Parties AS fromParty ON cdp.RuCDPDetail_ConnectedFromID = fromParty.PartyRegisteration_Id INNER JOIN
                  dbo.Bme_Parties AS ToParty ON cdp.RuCDPDetail_ConnectedToID = ToParty.PartyRegisteration_Id
                    inner join dbo.MtCongestedZone as cz
  on  cdp.RuCDPDetail_CongestedZoneID=cz.MtCongestedZone_Id
  where cdp.RuCDPDetail_CongestedZoneID is not null          




SELECT DISTINCT cdp.RuCDPDetail_Id, cdp.RuCDPDetail_CdpId,cdp.RuCDPDetail_CongestedZoneID,cdp.MtCongestedZone_Name,
cdp.RuCDPDetail_TaxZoneID, P.MtPartyRegisteration_Id AS OwnerPartyRegisteration_Id,
 P.MtPartyRegisteration_Name AS OwnerPartyRegisteration_Name, P.SrPartyType_Code AS OwnerPartyType_Code,
						PC.SrCategory_Code as OwnerPartyCategory_Code,
						cdp.FromPartyRegisteration_Id, 
                        cdp.FromPartyRegisteration_Name,
                         cdp.FromPartyType_Code, 
                  cdp.FromPartyCategory_Code,
                   cdp.ToPartyRegisteration_Id, 
                   cdp.ToPartyRegisteration_Name,
                    cdp.ToPartyType_Code, 
                    cdp.ToPartyCategory_Code,
                    
                     cdp.IsARE
                     ,cdp.IsThermal
                     ,cdp.IsLegacy
                     ,cdp.RuCDPDetail_IsEnergyImported
                        ,ISNULL(P.MtPartyRegisteration_IsPowerPool,0) AS IsPowerPool
                        ,CDP.RuCDPDetail_EffectiveFrom as EffectiveFrom,
                        CDP.RuCDPDetail_EffectiveTo as EffectiveTo
INTO #tempCDPOwnerParty
FROM     dbo.MtPartyRegisteration AS P INNER JOIN                  
                  dbo.MtPartyCategory AS PC ON PC.MtPartyRegisteration_Id = P.MtPartyRegisteration_Id INNER JOIN
                  dbo.MtConnectedMeter AS MC ON MC.MtPartyCategory_Id = PC.MtPartyCategory_Id INNER JOIN
                  #tempCDPParty AS cdp ON MC.MtCDPDetail_Id = cdp.RuCDPDetail_Id
                  where p.isDeleted=0 and PC.isDeleted=0 AND MC.MtConnectedMeter_isDeleted=0
				  and p.LuStatus_Code_Applicant='AACT' and P.SrPartyType_Code='MP'

UNION
SELECT 	
        CDP.RuCDPDetail_Id
        ,CDP.[RuCDPDetail_CdpId]  
	    ,CDP.RuCDPDetail_CongestedZoneID
       ,CDP.MtCongestedZone_Name
       ,cdp.RuCDPDetail_TaxZoneID
	   ,CDP.FromPartyRegisteration_Id as OwnerPartyRegisteration_Id
       ,cdp.FromPartyRegisteration_Name as OwnerPartyRegisteration_Name	 
       ,cdp.FromPartyType_Code as OwnerPartyType_Code
       ,cdp.FromPartyCategory_Code as OwnerPartyCategory_Code
	   
       ,cdp.FromPartyRegisteration_Id
      ,cdp.FromPartyRegisteration_Name	 
      ,cdp.FromPartyType_Code
      ,cdp.FromPartyCategory_Code	  
      ,cdp.ToPartyRegisteration_Id
      ,cdp.ToPartyRegisteration_Name	 
       ,cdp.ToPartyType_Code
      ,cdp.ToPartyCategory_Code
	  
	   ,CDP.IsARE
	   ,CDP.IsThermal
       ,CDP.IsLegacy
	   ,CDP.RuCDPDetail_IsEnergyImported
	   ,cdp.FromPartyIsPowerPool as IsPowerPool    
       ,CDP.RuCDPDetail_EffectiveFrom as EffectiveFrom,
       CDP.RuCDPDetail_EffectiveTo as EffectiveTo   
      FROM 
   	  #tempCDPParty as cdp   
      WHERE  cdp.FromPartyType_Code='MP'       
       UNION       
SELECT 	
       CDP.RuCDPDetail_Id
        ,CDP.[RuCDPDetail_CdpId]  
	    ,CDP.RuCDPDetail_CongestedZoneID
       ,CDP.MtCongestedZone_Name
       ,cdp.RuCDPDetail_TaxZoneID
	   ,CDP.ToPartyRegisteration_Id as OwnerPartyRegisteration_Id
       ,cdp.ToPartyRegisteration_Name as OwnerPartyRegisteration_Name	 
       ,cdp.ToPartyType_Code as OwnerPartyType_Code
       ,cdp.ToPartyCategory_Code as OwnerPartyCategory_Code
	   

      ,cdp.FromPartyRegisteration_Id
      ,cdp.FromPartyRegisteration_Name	 
      ,cdp.FromPartyType_Code
      ,cdp.FromPartyCategory_Code
	  
      ,cdp.ToPartyRegisteration_Id
      ,cdp.ToPartyRegisteration_Name	 
       ,cdp.ToPartyType_Code
      ,cdp.ToPartyCategory_Code
	  
	   ,CDP.IsARE
	   ,CDP.IsThermal
       ,CDP.IsLegacy
	   ,CDP.RuCDPDetail_IsEnergyImported
	   ,cdp.ToPartyIsPowerPool as IsPowerPool    
       ,CDP.RuCDPDetail_EffectiveFrom as EffectiveFrom,
       CDP.RuCDPDetail_EffectiveTo as EffectiveTo   
	  
      FROM 
   	  #tempCDPParty as cdp   
      WHERE  cdp.ToPartyType_Code='MP';                        





/*****************************************************************/
/*****************************************************************/
-------------------------------------------------------------------
    INSERT INTO [dbo].[BmeStatementDataCdpOwnerParty]
           (
            [BmeStatementData_StatementProcessId]
		   ,[BmeStatementData_CdpId]
		   
		   ,[BmeStatementData_OwnerPartyRegisteration_Id]
           ,[BmeStatementData_OwnerPartyRegisteration_Name]
           ,[BmeStatementData_OwnerPartyCategory_Code]
           ,[BmeStatementData_OwnerPartyType_Code]
           
           ,[BmeStatementData_FromPartyRegisteration_Id]
           ,[BmeStatementData_FromPartyRegisteration_Name]
           ,[BmeStatementData_FromPartyCategory_Code]
           ,[BmeStatementData_FromPartyType_Code]

           ,[BmeStatementData_ToPartyRegisteration_Id]
           ,[BmeStatementData_ToPartyRegisteration_Name]
           ,[BmeStatementData_ToPartyCategory_Code]
           ,[BmeStatementData_ToPartyType_Code]
		   ,BmeStatementData_ISARE
		   ,BmeStatementData_ISThermal
		   ,BmeStatementData_IsEnergyImported
		   ,BmeStatementData_IsPowerPool
           ,BmeStatementData_IsLegacy
		   ,BmeStatementData_RuCDPDetail_Id
		   ,BmeStatementData_CongestedZoneID
           ,BmeStatementData_CongestedZone
		   )
          	  
      SELECT 	
        @StatementProcessId
       ,CDP.[RuCDPDetail_CdpId]  
	   
	   ,cdp.OwnerPartyRegisteration_Id
       ,cdp.OwnerPartyRegisteration_Name	 
       ,cdp.OwnerPartyCategory_Code
	   ,cdp.OwnerPartyType_Code

      ,cdp.FromPartyRegisteration_Id
      ,cdp.FromPartyRegisteration_Name	 
      ,cdp.FromPartyCategory_Code
	   ,cdp.FromPartyType_Code

      ,cdp.ToPartyRegisteration_Id
      ,cdp.ToPartyRegisteration_Name	 
      ,cdp.ToPartyCategory_Code
	   ,cdp.ToPartyType_Code
	   ,CDP.IsARE
	   ,CDP.IsThermal
	   ,CDP.RuCDPDetail_IsEnergyImported
	   ,CDP.IsPowerPool
       ,CDP.IsLegacy
	   ,CDP.RuCDPDetail_Id
	   ,CDP.RuCDPDetail_CongestedZoneID
       ,CDP.MtCongestedZone_Name
      FROM 
   	  #tempCDPOwnerParty as cdp
      WHERE-- cdp.EffectiveFrom<=@MONTH_EFFECTIVE_FROM 
	  (	@MONTH_EFFECTIVE_FROM >= cdp.EffectiveFrom  
  OR  cdp.EffectiveFrom  BETWEEN @MONTH_EFFECTIVE_FROM AND @MONTH_EFFECTIVE_TO  )

	  and ISNULL(cdp.EffectiveTo,@MONTH_EFFECTIVE_TO)>=@MONTH_EFFECTIVE_TO;
	 
-------------------------------------------------------------
	   

	----1----------Insert distinct party Ids in MpHourly Table
    INSERT INTO [dbo].[BmeStatementDataCdpContractHourly]
           (
		   [BmeStatementData_StatementProcessId]
           ,[BmeStatementData_NtdcDateTime]
           ,[BmeStatementData_Year]
           ,[BmeStatementData_Month]
           ,[BmeStatementData_Day]
           ,[BmeStatementData_Hour]

		    ,[BmeStatementData_SellerPartyRegisteration_Id]
           ,[BmeStatementData_SellerPartyRegisteration_Name]
           ,[BmeStatementData_SellerPartyCategory_Code]
           ,[BmeStatementData_SellerPartyType_Code]

           ,[BmeStatementData_BuyerPartyRegisteration_Id]
           ,[BmeStatementData_BuyerPartyRegisteration_Name]
           ,[BmeStatementData_BuyerPartyCategory_Code]
           ,[BmeStatementData_BuyerPartyType_Code]

		   ,[BmeStatementData_ContractId]
        ,[BmeStatementData_CDPID]
      ,[BmeStatementData_ContractType]     
      ,[BmeStatementData_ContractedQuantity]
      ,[BmeStatementData_CapQuantity]
      ,[BmeStatementData_AncillaryServices]
      ,[BmeStatementData_Contract_Id]
      ,[BmeStatementData_Percentage]
      ,[BmeStatementData_ContractType_Id]
	  ,BmeStatementData_ContractSubType_Id
	  ,BmeStatementData_CongestedZoneID
	  ,BmeStatementData_CongestedZone
       )
     	select distinct 
        @StatementProcessId
	   ,DATEADD(HOUR,Cast(MtBilateralContract_Hour as int)+1, cast(MtBilateralContract_Date as datetime)) AS BmeStatementData_NtdcDateTime
      ,DATEPART(YEAR, MtBilateralContract_Date) AS BmeStatementData_Year
      ,DATEPART(MONTH,MtBilateralContract_Date) AS BmeStatementData_Month
      ,DATEPART(DAY, MtBilateralContract_Date) AS BmeStatementData_Day
      ,Cast(MtBilateralContract_Hour as int)+1 AS BmeStatementData_Hour 
	   ,[SellerPartyRegisteration_Id]
           ,[SellerPartyRegisteration_Name]
           ,[SellerPartyCategory_Code]
           ,[SellerPartyType_Code]

           ,[BuyerPartyRegisteration_Id]
           ,[BuyerPartyRegisteration_Name]
           ,[BuyerPartyCategory_Code]
           ,[BuyerPartyType_Code]

      , [MtBilateralContract_ContractId]
      ,ISNULL([MtBilateralContract_CDPID],'')
      ,[MtBilateralContract_ContractType]     
      ,[MtBilateralContract_ContractedQuantity]
      ,[MtBilateralContract_CapQuantity]
      ,[MtBilateralContract_AncillaryServices]
      ,[MtBilateralContract_Id]
      ,[MtBilateralContract_Percentage]
      ,[SrContractType_Id]
	  ,ContractSubType_Id
	  ,RuCDPDetail_CongestedZoneID
      ,MtCongestedZone_Name
	  from dbo.Bme_ContractParties
	 WHERE DATEPART(YEAR, MtBilateralContract_Date)  = @Year and DATEPART(MONTH,MtBilateralContract_Date) = @Month
	 and   MtSOFileMaster_Id=dbo.GetMtSoFileMasterId(@StatementProcessId, 8);

-------------------------------

INSERT INTO BmeStatementDataCdpHourly (
        [BmeStatementData_StatementProcessId]
       ,[BmeStatementData_NtdcDateTime]
      ,[BmeStatementData_Year]
      ,[BmeStatementData_Month]
      ,[BmeStatementData_Day]
      ,[BmeStatementData_Hour]
      ,[BmeStatementData_CdpId]
      ,[BmeStatementData_MeterIdImport]
      ,[BmeStatementData_IncEnergyImport]
      ,[BmeStatementData_DataSourceImport]
      ,[BmeStatementData_MeterIdExport]
      ,[BmeStatementData_IncEnergyExport]
      ,[BmeStatementData_DataSourceExport]
      ,[BmeStatementData_CreatedBy]
      ,[BmeStatementData_CreatedOn]
      ,[BmeStatementData_ModifiedBy]
      ,[BmeStatementData_ModifiedOn]
      ,[BmeStatementData_LineVoltage]
      ,[BmeStatementData_FromPartyRegisteration_Id]
      ,[BmeStatementData_FromPartyRegisteration_Name]
      ,[BmeStatementData_FromPartyCategory_Code]
      ,[BmeStatementData_FromPartyType_Code]
      ,[BmeStatementData_ToPartyRegisteration_Id]
      ,[BmeStatementData_ToPartyRegisteration_Name]
      ,[BmeStatementData_ToPartyCategory_Code] 
     ,[BmeStatementData_ToPartyType_Code] 
	  ,BmeStatementData_IsEnergyImported
	  ,BmeStatementData_AdjustedEnergyImport
	  ,BmeStatementData_AdjustedEnergyExport
	  ,BmeStatementData_CongestedZoneID
      ,BmeStatementData_CongestedZone
      ,BmeStatementData_IsARE
	  ,BmeStatementData_IsThermal
      ,BmeStatementData_IsLegacy
	  ,IsBackfeedInclude
	  ,BmeStatementData_IsActualGenerationUnit
      )
      
      SELECT 
	   @StatementProcessId
       ,DATEADD(HOUR,MtBvmReading_ReadingHour,CAST(MtBvmReading_ReadingDate as datetime))
      ,DATEPART(YEAR, MtBvmReading_ReadingDate) AS BmeStatementData_Year
      ,DATEPART(MONTH,MtBvmReading_ReadingDate) AS BmeStatementData_Month
      ,DATEPART(DAY, MtBvmReading_ReadingDate) AS BmeStatementData_Day
      ,MtBvmReading_ReadingHour AS BmeStatementData_Hour
      ,MtBvmReading.[RuCDPDetail_CdpId]
      ,[RuCdpMeters_MeterIdImport]
      ,[MtBvmReading_IncEnergyImport]
      ,[MtBvmReading_DataSourceImport]
      ,[RuCdpMeters_MeterIdExport]
      ,[MtBvmReading_IncEnergyExport]
      ,[MtBvmReading_DataSourceExport]
      ,[MtBvmReading_CreatedBy]
      ,[MtBvmReading_CreatedOn]
      ,[MtBvmReading_ModifiedBy]
      ,[MtBvmReading_ModifiedOn]
      ,cdp.RuCDPDetail_LineVoltage
      ,cdp.FromPartyRegisteration_Id
      ,cdp.FromPartyRegisteration_Name
      ,cdp.FromPartyCategory_Code
      ,cdp.FromPartyType_Code
      ,cdp.ToPartyRegisteration_Id
      ,cdp.ToPartyRegisteration_Name
      ,cdp.ToPartyCategory_Code
	  ,cdp.ToPartyType_Code
	  ,cdp.[RuCDPDetail_IsEnergyImported]
      ,[MtBvmReading_IncEnergyImport]
	  ,[MtBvmReading_IncEnergyExport]
	  ,cdp.RuCDPDetail_CongestedZoneID
      ,cdp.MtCongestedZone_Name
	  ,cdp.IsARE
	  ,cdp.IsThermal
      ,cdp.IsLegacy
	  ,cdp.IsBackfeedInclude
	  ,cdp.IsActualGeneration
      FROM MtBvmReading  INNER JOIN
      #tempCDPParty as cdp on MtBvmReading.RuCDPDetail_CdpId=cdp.RuCDPDetail_CdpId WHERE  DATEPART(YEAR, MtBvmReading_ReadingDate)=@Year AND DATEPART(MONTH, MtBvmReading_ReadingDate)=@Month
    AND --(cdp.RuCDPDetail_EffectiveFrom<=@MONTH_EFFECTIVE_FROM )
(	@MONTH_EFFECTIVE_FROM >= cdp.RuCDPDetail_EffectiveFrom  
  OR  cdp.RuCDPDetail_EffectiveFrom  BETWEEN @MONTH_EFFECTIVE_FROM AND @MONTH_EFFECTIVE_TO  )
  
	and ISNULL(cdp.RuCDPDetail_EffectiveTo,@MONTH_EFFECTIVE_TO)>=@MONTH_EFFECTIVE_TO;
	 -- AND ISNULL(cdp.RuCDPDetail_EffectiveFrom,@MONTH_EFFECTIVE_FROM)<=@MONTH_EFFECTIVE_FROM and ISNULL(cdp.RuCDPDetail_EffectiveTo,@MONTH_EFFECTIVE_TO)>=@MONTH_EFFECTIVE_TO;

------------------------------------
	  	  --update legacy bit in owner
/*UPDATE BmeStatementDataCdpOwnerParty
SET BmeStatementData_IsLegacy=1
FROM BmeStatementDataCdpOwnerParty OP
WHERE  OP.BmeStatementData_OwnerPartyRegisteration_Id in (select PartyRegisteration_Id from dbo.Bme_Parties where IsPowerPool=1)
 or OP.BmeStatementData_OwnerPartyRegisteration_Id in (
								 select distinct CH.BmeStatementData_SellerPartyRegisteration_Id from BmeStatementDataCdpContractHourly CH 
                                 where CH.BmeStatementData_Year=@Year and CH.BmeStatementData_Month=@Month and CH.BmeStatementData_StatementProcessId=@StatementProcessId
                                 and CH.BmeStatementData_BuyerPartyRegisteration_Id
								 in (select PartyRegisteration_Id from dbo.Bme_Parties where IsPowerPool=1)
						 );
                         */
-----------------------------------                         
/*update BmeStatementDataCdpHourly set 

 BmeStatementData_IsLegacy=
 ISNULL((
	  SELECT TOP (1) 1  from BmeStatementDataCdpOwnerParty cdpo
where cdph.BmeStatementData_CdpId=cdpo.BmeStatementData_CdpId
	  and cdpo.BmeStatementData_IsLegacy=1
      and cdpo.BmeStatementData_StatementProcessId=@StatementProcessId      
	  ),0)  
from BmeStatementDataCdpHourly CDPH
 WHERE  CDPH.BmeStatementData_Year=@Year and CDPH.BmeStatementData_Month=@Month and CDPH.BmeStatementData_StatementProcessId=@StatementProcessId
*/



/**********************************************************************************************************************************************************************/
-- 1. Fetching Data for CDP , Generator and Unit
/**********************************************************************************************************************************************************************/
INSERT INTO BmeStatementDataCDPGenUnit (
  RuCDPDetail_CdpId, BmeStatementDataـGenName, 
  MtGenerator_Id, MtGenerationUnit_Id, 
  MtGenerationUnit_SOUnitId, SrTechnologyType_Code, 
  MtGenerationUnit_InstalledCapacity_KW, 
  Lu_CapUnitGenVari_Id, BmeStatementData_StatementProcessId
) 
SELECT 
  DISTINCT cdp.RuCDPDetail_CdpId, 
  g.MtGenerator_Name, 
  g.MtGenerator_Id, 
  gu.MtGenerationUnit_Id, 
  gu.MtGenerationUnit_SOUnitId, 
  gu.[SrTechnologyType_Code], 
  gu.MtGenerationUnit_InstalledCapacity_KW, 
  gu.Lu_CapUnitGenVari_Id, 
  @StatementProcessId 
FROM 
  MtGenerator g 
  INNER JOIN MtGenerationUnit gu ON gu.MtGenerator_Id = g.MtGenerator_Id 
  INNER JOIN MtConnectedMeter mcm ON mcm.MtConnectedMeter_UnitId = gu.MtGenerationUnit_Id 
  INNER JOIN RuCDPDetail cdp ON cdp.RuCDPDetail_Id = mcm.MtCDPDetail_Id 
WHERE 
  ISNULL(g.MtGenerator_IsDeleted, 0) = 0 
  AND ISNULL(
    gu.MtGenerationUnit_IsDeleted, 0
  ) = 0 
  AND ISNULL(
    mcm.MtConnectedMeter_isDeleted, 
    0
  ) = 0 
  AND ISNULL(g.isDeleted, 0) = 0 
  AND mcm.MtPartyCategory_Id NOT IN (
    SELECT 
      MtPartyCategory_Id 
    FROM 
      MtPartyCategory MPC 
    WHERE 
      MPC.SrCategory_Code = 'BPC' 
      AND ISNULL(MPC.isDeleted, 0) = 0
  );


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
