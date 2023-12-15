/****** Object:  Procedure [dbo].[ASC_StepEPerform]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--    [dbo].[ASC_Step1Perform] 2021,11
CREATE   Procedure dbo.ASC_StepEPerform(			 
			@Year int,
			@Month int
			,@StatementProcessId decimal(18,0)
			)
AS
BEGIN
	SET NOCOUNT ON;
BEGIN TRY    
   IF EXISTS(SELECT TOP 1 AscStatementData_Id FROM AscStatementDataGuHourly WHERE  AscStatementData_Year=@Year and AscStatementData_Month=@Month and AscStatementData_StatementProcessId=@StatementProcessId)
   BEGIN
 
  DECLARE @BmeStatementProcessId decimal(18,0) =null;

DECLARE @KE_RegisterationId decimal(18,0) = null;
DECLARE @KE_ZoneIdForTP_SOLR decimal(18,0) = 2;
DECLARE @PowerPool_ZoneIdForKE_ES decimal(18,0) = 1;

DECLARE @PowerPoolRegisterationId decimal(18,0) = null;
------------------------------------------------
Set @BmeStatementProcessId = (SELECT top 1 P.MtStatementProcess_ID from [V_StatementProcesses] P where P.SrProcessDef_Name='BME' AND P.CurrentStatementProcess_ID = @StatementProcessId);
-----------------------------------------
Set @KE_RegisterationId =(Select top 1 p.MtPartyRegisteration_Id From MtPartyRegisteration p WHERE p.MtPartyRegisteration_IsKE=1 and isnull(p.isDeleted,0)=0);
-----------------------------------------
Set @PowerPoolRegisterationId = (Select top 1 p.MtPartyRegisteration_Id From MtPartyRegisteration p WHERE p.MtPartyRegisteration_IsPowerPool=1 and isnull(p.isDeleted,0)=0);
-----------------------------------

drop Table if Exists #Temp_EPs_SPs_MP_KE

Select P.PartyRegisteration_Id
INTO #Temp_EPs_SPs_MP_KE
From Bme_Parties P WHERE (P.PartyRegisteration_Id = @KE_RegisterationId or P.MPId=@KE_RegisterationId);

 ------------------------------------
drop Table if Exists #Temp_EPs_MP_PowerPool

Select P.PartyRegisteration_Id
INTO #Temp_EPs_MP_PowerPool
From Bme_Parties P WHERE (P.PartyRegisteration_Id = @PowerPoolRegisterationId);-- or P.MPId=@PowerPoolRegisterationId);

-----------------------------------
drop Table if Exists #TempContractSellers

Select distinct C.BmeStatementData_SellerPartyRegisteration_Id 
INTO #TempContractSellers
From BmeStatementDataMpContractHourly_SettlementProcess  C WHERE c.BmeStatementData_BuyerPartyRegisteration_Id = @PowerPoolRegisterationId
 AND C.BmeStatementData_Year=@Year and C.BmeStatementData_Month=@Month and C.BmeStatementData_StatementProcessId=@BmeStatementProcessId;

drop Table if Exists #TempContractBuyers

Select distinct C.BmeStatementData_BuyerPartyRegisteration_Id 
INTO #TempContractBuyers
From BmeStatementDataMpContractHourly_SettlementProcess  C WHERE c.BmeStatementData_SellerPartyRegisteration_Id  = @PowerPoolRegisterationId
 AND C.BmeStatementData_Year=@Year and C.BmeStatementData_Month=@Month and C.BmeStatementData_StatementProcessId=@BmeStatementProcessId;


WITH POWERPOOL_TP_CTE
AS
(
    SELECT AscStatementData_CongestedZoneID, SUM(MZM.AscStatementData_PAYABLE) as TP , SUM(MZM.AscStatementData_RECEIVABLE) as TR 
    FROM AscStatementDataMpZoneMonthly MZM 
    WHERE  MZM.AscStatementData_Year=@Year and MZM.AscStatementData_Month=@Month and MZM.AscStatementData_StatementProcessId=@StatementProcessId
     AND (
         MZM.AscStatementData_PartyRegisteration_Id in(select C.PartyRegisteration_Id FROM #Temp_EPs_MP_PowerPool C)
        OR MZM.AscStatementData_PartyRegisteration_Id IN(SELECT C.BmeStatementData_SellerPartyRegisteration_Id FROM #TempContractSellers C)
      )   
      GROUP by MZM.AscStatementData_CongestedZoneID

)

UPDATE AscStatementDataZoneMonthly set AscStatementData_TP=T.TP,AscStatementData_TR=T.TR
FROM AscStatementDataZoneMonthly MZM
INNER JOIN POWERPOOL_TP_CTE T ON 
MZM.AscStatementData_CongestedZoneID=T.AscStatementData_CongestedZoneID

 WHERE  MZM.AscStatementData_Year=@Year and MZM.AscStatementData_Month=@Month and MZM.AscStatementData_StatementProcessId=@StatementProcessId;

-----------------------------

WITH POWERPOOL_ES_BS_CTE
AS
(
/*
    SELECT C.AscStatementData_CongestedZoneID
    , SUM(C.AscStatementData_ES) as ES_BS 
	FROM AscStatementDataMpZoneMonthly C 
    WHERE  C.AscStatementData_Year=@Year and C.AscStatementData_Month=@Month and C.AscStatementData_StatementProcessId=@StatementProcessId
     and C.AscStatementData_PartyRegisteration_Id IN(SELECT TB.BmeStatementData_BuyerPartyRegisteration_Id FROM #TempContractBuyers TB
    -- where TB.BmeStatementData_BuyerPartyRegisteration_Id<>@KE_RegisterationId
	*/
	SELECT ZM.AscStatementData_CongestedZoneID
    --, SUM(C.AscStatementData_ES) as ES_BS 
	, SUM(BM.BmeStatementData_EnergySuppliedActual) as ES_BS 
	FROM AscStatementDataMpZoneMonthly ZM
	JOIN BmeStatementDataMpMonthly_SettlementProcess  BM ON ZM.AscStatementData_PartyRegisteration_Id=BM.BmeStatementData_PartyRegisteration_Id
    WHERE  
	ZM.AscStatementData_Year=@Year 
	and ZM.AscStatementData_Month=@Month 
	and ZM.AscStatementData_StatementProcessId=@StatementProcessId
	AND BM.BmeStatementData_Year=@Year 
	and BM.BmeStatementData_Month=@Month 
	and BM.BmeStatementData_SettlementProcessId=@BmeStatementProcessId
    and ZM.AscStatementData_PartyRegisteration_Id 
	IN(SELECT TB.BmeStatementData_BuyerPartyRegisteration_Id FROM #TempContractBuyers TB
    -- where TB.BmeStatementData_BuyerPartyRegisteration_Id<>@KE_RegisterationId

     )       
    GROUP by ZM.AscStatementData_CongestedZoneID
)

UPDATE AscStatementDataZoneMonthly set AscStatementData_ES_BS=T.ES_BS
FROM AscStatementDataZoneMonthly MZM
INNER JOIN POWERPOOL_ES_BS_CTE T ON MZM.AscStatementData_CongestedZoneID=T.AscStatementData_CongestedZoneID

 WHERE  MZM.AscStatementData_Year=@Year and MZM.AscStatementData_Month=@Month and MZM.AscStatementData_StatementProcessId=@StatementProcessId;
  
DECLARE @KE_EB DECIMAL(25,13)=NULL;

SET @KE_EB=(select SUM(C.BmeStatementData_EnergyTradedBought)  from BmeStatementDataMpContractHourly_SettlementProcess  c WHERE c.BmeStatementData_StatementProcessId=@BmeStatementProcessId and c.BmeStatementData_SellerPartyRegisteration_Id=@PowerPoolRegisterationId and c.BmeStatementData_BuyerPartyRegisteration_Id=@KE_RegisterationId);

WITH POWERPOOL_KE_ES_CTE
AS
(
  SELECT
    isnull( CASE 
      WHEN  Exists(select top (1) 1 from #Temp_EPs_SPs_MP_KE P where  P.PartyRegisteration_Id=CDP.BmeStatementData_ToPartyRegisteration_Id)  
	    THEN
	    --ISNULL(CDP.BmeStatementData_IncEnergyExport,0)
		ISNULL(CDP.BmeStatementData_IncEnergyExport,0)-ISNULL(CDP.BmeStatementData_IncEnergyImport,0)
	  WHEN  Exists(select top (1) 1 from #Temp_EPs_SPs_MP_KE P where  P.PartyRegisteration_Id=CDP.BmeStatementData_FromPartyRegisteration_Id)  
	    THEN
	        --ISNULL(CDP.BmeStatementData_IncEnergyImport,0) 
			ISNULL(CDP.BmeStatementData_IncEnergyImport,0) - ISNULL(CDP.BmeStatementData_IncEnergyExport,0) 
       
        end,0) * (1.0 + DH.BmeStatementData_UpliftTransmissionLosses) AS KE_ES
   from BmeStatementDataCdpContractHourly CH 
  INNER JOIN DBO.BmeStatementDataCdpHourly CDP ON 
  CH.BmeStatementData_CdpId=CDP.BmeStatementData_CdpId
  AND CH.BmeStatementData_NtdcDateTime=CDP.BmeStatementData_NtdcDateTime
  AND CH.BmeStatementData_StatementProcessId=CDP.BmeStatementData_StatementProcessId
  INNER JOIN BmeStatementDataHourly DH ON
   DH.BmeStatementData_NtdcDateTime=CDP.BmeStatementData_NtdcDateTime
  AND DH.BmeStatementData_StatementProcessId=CDP.BmeStatementData_StatementProcessId

  where CH.BmeStatementData_SellerPartyRegisteration_Id = @PowerPoolRegisterationId
  AND ch.BmeStatementData_BuyerPartyRegisteration_Id = @KE_RegisterationId AND CH.BmeStatementData_StatementProcessId=@BmeStatementProcessId
)

UPDATE AscStatementDataZoneMonthly set AscStatementData_KE_ES = (SELECT SUM(KE_ES) FROM POWERPOOL_KE_ES_CTE),AscStatementData_KE_EB =@KE_EB
WHERE  AscStatementData_Year=@Year and AscStatementData_Month=@Month and AscStatementData_StatementProcessId=@StatementProcessId
AND AscStatementData_CongestedZoneID=@PowerPool_ZoneIdForKE_ES;
;

--------------------------

/**task id 3933 * date 27-sep-2023*/
DECLARE @vBmeStatementData_EnergyTradedBought DECIMAL(25,13)
DECLARE @vBmeStatementData_LegacyReceiveable DECIMAL(25,13)


SELECT  @vBmeStatementData_EnergyTradedBought=SUM(BmeStatementData_EnergyTradedBought) 
FROM BmeStatementDataMpContractHourly_SettlementProcess    
WHERE BmeStatementData_StatementProcessId=@BmeStatementProcessId
AND BmeStatementData_SellerPartyRegisteration_Id=1 -- only for leagacy


SELECT
	@vBmeStatementData_LegacyReceiveable=AscStatementData_RECEIVABLE
FROM AscStatementDataMpZoneMonthly
WHERE AscStatementData_StatementProcessId = @StatementProcessId
AND AscStatementData_PartyRegisteration_Id=1


UPDATE AscStatementDataMPZoneMonthly
SET AscStatementData_TP_SOLR=
(MH.AscStatementData_ET * ZM.AscStatementData_TP)/NULLIF( ISNULL(ZM.AscStatementData_ES_BS,0), 0)

, AscStatementData_SOLR_ETB_Legacy=
(MH.AscStatementData_ET * ZM.AscStatementData_TP)/NULLIF( ISNULL(@vBmeStatementData_EnergyTradedBought,0), 0)

, AscStatementData_LegacyShareInReceiveable=
(ISNULL(MH.AscStatementData_ET,0) * @vBmeStatementData_LegacyReceiveable)/NULLIF( ISNULL(@vBmeStatementData_EnergyTradedBought,0), 0)



FROM AscStatementDataMPZoneMonthly MH 
INNER JOIN AscStatementDataZoneMonthly ZM
ON MH.AscStatementData_Year=ZM.AscStatementData_Year and MH.AscStatementData_Month=ZM.AscStatementData_Month and MH.AscStatementData_StatementProcessId=ZM.AscStatementData_StatementProcessId
and MH.AscStatementData_CongestedZoneID=ZM.AscStatementData_CongestedZoneID
where MH.AscStatementData_Year=@Year and MH.AscStatementData_Month=@Month 
and ZM.AscStatementData_StatementProcessId=@StatementProcessId and MH.AscStatementData_StatementProcessId=@StatementProcessId
and MH.AscStatementData_PartyRegisteration_Id IN(
SELECT TB.BmeStatementData_BuyerPartyRegisteration_Id FROM #TempContractBuyers TB
     --where TB.BmeStatementData_BuyerPartyRegisteration_Id<>@KE_RegisterationId
     );

DECLARE @PowerPool_TP_FOR_KE decimal(25,13)=0;
DECLARE @PowerPool_TR_FOR_KE decimal(25,13)=0;

SELECT TOP 1 @PowerPool_TP_FOR_KE=ZM.AscStatementData_TP,@PowerPool_TR_FOR_KE=ZM.AscStatementData_TR FROM AscStatementDataZoneMonthly ZM WHERE 
ZM.AscStatementData_Year=@Year and ZM.AscStatementData_Month=@Month 
and ZM.AscStatementData_StatementProcessId=@StatementProcessId AND ZM.AscStatementData_CongestedZoneID=@PowerPool_ZoneIdForKE_ES ;
/*
DECLARE @PowerPool_SUM_TP_SOLR DECIMAL(25,13)=0;
DECLARE @PowerPool_SUM_TR_SOLR DECIMAL(25,13)=0;

SELECT @PowerPool_SUM_TP_SOLR=SUM(MZM.AscStatementData_TP_SOLR),@PowerPool_SUM_TR_SOLR=SUM(MZM.AscStatementData_TR_SOLR) 
FROM AscStatementDataMpZoneMonthly MZM 
WHERE MZM.AscStatementData_Year=@Year and MZM.AscStatementData_Month=@Month 
and MZM.AscStatementData_StatementProcessId=@StatementProcessId AND MZM.AscStatementData_CongestedZoneID=@PowerPool_ZoneIdForKE_ES
 and MZM.AscStatementData_PartyRegisteration_Id IN(SELECT TB.BmeStatementData_BuyerPartyRegisteration_Id FROM #TempContractBuyers TB
     where TB.BmeStatementData_BuyerPartyRegisteration_Id<>@KE_RegisterationId
     );*/
/*
UPDATE AscStatementDataMPZoneMonthly
SET AscStatementData_TP_SOLR=(@PowerPool_TP_FOR_KE - ISNULL(@PowerPool_SUM_TP_SOLR,0))
, AscStatementData_TR_SOLR=(@PowerPool_TR_FOR_KE - ISNULL(@PowerPool_SUM_TR_SOLR,0))
where AscStatementData_Year=@Year and AscStatementData_Month=@Month and AscStatementData_StatementProcessId=@StatementProcessId
and AscStatementData_PartyRegisteration_Id = @KE_RegisterationId and AscStatementData_CongestedZoneID=@KE_ZoneIdForTP_SOLR;
*/
----------------------------------------------------------------
-- MP Monthly Payable and Receivable
--------------------------------------------------------------
WITH MpMonthly_CTE
as
(
	select MH.AscStatementData_StatementProcessId, MH.AscStatementData_PartyRegisteration_Id
	,MH.AscStatementData_PartyName
	,MH.AscStatementData_PartyType_Code	
	,MH.AscStatementData_Year,MH.AscStatementData_Month,
	SUM(MH.AscStatementData_MAC) AS AscStatementData_MAC,
	SUM(MH.AscStatementData_MRC) AS AscStatementData_MRC,
	SUM(MH.AscStatementData_IG_AC) AS AscStatementData_IG_AC,
	SUM(MH.AscStatementData_RG_AC) AS AscStatementData_RG_AC,
	SUM(MH.AscStatementData_GS_SC) AS AscStatementData_GS_SC,
	SUM(MH.AscStatementData_GBS_BSC) AS AscStatementData_GBS_BSC,
	--Task Id ** 4092 ** update 24 oct 2023
	--SUM(ISNULL(MH.AscStatementData_PAYABLE,0) + ISNULL(MH.AscStatementData_TP_SOLR,0)) AS AscStatementData_PAYABLE,
	--SUM(ISNULL(MH.AscStatementData_RECEIVABLE,0) + ISNULL(MH.AscStatementData_TR_SOLR,0) ) AS AscStatementData_RECEIVABLE   
	CASE 
		WHEN MH.AscStatementData_PartyRegisteration_Id=1 THEN 0
		ELSE SUM(ISNULL(MH.AscStatementData_PAYABLE,0) + ISNULL(MH.AscStatementData_SOLR_ETB_Legacy,0)) END AS AscStatementData_PAYABLE,
	CASE
		WHEN MH.AscStatementData_PartyRegisteration_Id=1 THEN 0
		ELSE SUM(ISNULL(MH.AscStatementData_RECEIVABLE,0) + ISNULL(MH.AscStatementData_LegacyShareInReceiveable,0) ) end AS AscStatementData_RECEIVABLE   
	from AscStatementDataMpZoneMonthly MH
	where MH.AscStatementData_Year=@Year and MH.AscStatementData_Month=@Month
     and MH.AscStatementData_StatementProcessId=@StatementProcessId
     and MH.AscStatementData_PartyRegisteration_Id NOT IN(SELECT C.PartyRegisteration_Id FROM #Temp_EPs_MP_PowerPool C where c.PartyRegisteration_Id<>@KE_RegisterationId)
     and AscStatementData_PartyRegisteration_Id NOT IN(SELECT C.BmeStatementData_SellerPartyRegisteration_Id FROM #TempContractSellers C where c.BmeStatementData_SellerPartyRegisteration_Id<>@KE_RegisterationId)
     and (ISNULL(MH.AscStatementData_PAYABLE,0)<>0 or ISNULL(MH.AscStatementData_RECEIVABLE,0)<>0 or ISNULL(MH.AscStatementData_TP_SOLR,0)<>0)     
	
    group by MH.AscStatementData_PartyRegisteration_Id,MH.AscStatementData_PartyName,MH.AscStatementData_PartyType_Code,
    MH.AscStatementData_Year,MH.AscStatementData_Month,MH.AscStatementData_StatementProcessId
)
insert into AscStatementDataMpMonthly
(
    [AscStatementData_StatementProcessId]
	,[AscStatementData_Year]
      ,[AscStatementData_Month]      
      ,[AscStatementData_PartyRegisteration_Id]
      ,[AscStatementData_PartyName]
      ,[AscStatementData_PartyType_Code]
      ,[AscStatementData_MRC]
      ,[AscStatementData_RG_AC]
      ,[AscStatementData_IG_AC]
      ,[AscStatementData_MAC]      
      ,[AscStatementData_GS_SC]
      ,[AscStatementData_GBS_BSC]
	  ,[AscStatementData_PAYABLE]
	  ,[AscStatementData_RECEIVABLE]
      
	  )
select 
    [AscStatementData_StatementProcessId]
    ,[AscStatementData_Year]
      ,[AscStatementData_Month]      
      ,[AscStatementData_PartyRegisteration_Id]
      ,[AscStatementData_PartyName]
      ,[AscStatementData_PartyType_Code]
      ,[AscStatementData_MRC]
      ,[AscStatementData_RG_AC]
      ,[AscStatementData_IG_AC]
      ,[AscStatementData_MAC]      
      ,[AscStatementData_GS_SC]
      ,[AscStatementData_GBS_BSC]
	  ,[AscStatementData_PAYABLE]
	  ,[AscStatementData_RECEIVABLE]
      
	  from MpMonthly_CTE C;  

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
