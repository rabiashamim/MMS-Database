/****** Object:  Procedure [dbo].[BME_Step7APerform]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================  
-- Author:  M.Asghar(.Net/SQL Consultant)  
-- CREATE date: March 18, 2022 
-- ALTER date: June 01, 2022   
-- Description: 
--              
-- Parameters: @Year, @Month, @StatementProcessId
-- ============================================= 
CREATE   Procedure [dbo].[BME_Step7APerform]
@Year int,
@Month int
,@StatementProcessId decimal(18,0)
AS
BEGIN

BEGIN TRY
DECLARE @MONTH_EFFECTIVE_FROM as DATETIME = DATETIMEFROMPARTS(@Year,@Month,1,0,0,0,0);
DECLARE @MONTH_EFFECTIVE_TO as DATETIME = DATEADD(MONTH,1,@MONTH_EFFECTIVE_FROM);

 IF NOT EXISTS(SELECT TOP 1 BmeStatementData_Id FROM BmeStatementDataMpContractHourly 
     WHERE  BmeStatementData_Year=@Year and BmeStatementData_Month=@Month and BmeStatementData_StatementProcessId=@StatementProcessId)
    BEGIN

----------------------------------------------
INSERT INTO [dbo].[BmeStatementDataMpContractHourly]
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
      ,[BmeStatementData_ContractType]     
      ,[BmeStatementData_ContractedQuantity]
      ,[BmeStatementData_CapQuantity]
      ,[BmeStatementData_AncillaryServices]      
      ,[BmeStatementData_Percentage]
      ,[BmeStatementData_ContractType_Id]
	  ,BmeStatementData_ContractSubType_Id
	  ,BmeStatementData_CongestedZoneID
      ,BmeStatementData_CongestedZone
       )
     	select distinct 
            @StatementProcessId
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
      ,[BmeStatementData_ContractType]     
      ,[BmeStatementData_ContractedQuantity]
      ,[BmeStatementData_CapQuantity]
      ,[BmeStatementData_AncillaryServices]      
      ,[BmeStatementData_Percentage]
      ,[BmeStatementData_ContractType_Id]
	  ,BmeStatementData_ContractSubType_Id
	  ,BmeStatementData_CongestedZoneID
      ,BmeStatementData_CongestedZone
	  from dbo.BmeStatementDataCdpContractHourly
	 WHERE BmeStatementData_Year= @Year and BmeStatementData_Month = @Month AND BmeStatementData_StatementProcessId=@StatementProcessId;

	 

/**************************************/
-- update caplegacy for K.E and Contact =1111
/**************************************/


UPDATE BmeStatementDataHourly
SET 
BmeStatementData_CAPLegacy=ISNULL(DH.BmeStatementData_CAPLegacy,0)-
ISNULL(
CASE WHEN MCH.BmeStatementData_CapQuantity>MPH.BmeStatementData_EnergySuppliedActual THEN
MPH.BmeStatementData_EnergySuppliedActual
ELSE
MCH.BmeStatementData_CapQuantity END,0) 

 FROM 
BmeStatementDataHourly DH
JOIN BmeStatementDataMpHourly MPH ON DH.BmeStatementData_NtdcDateTime=MPH.BmeStatementData_NtdcDateTime
AND DH.BmeStatementData_Year=MPH.BmeStatementData_Year
AND DH.BmeStatementData_Month=MPH.BmeStatementData_Month

JOIN BmeStatementDataMpContractHourly MCH ON MCH.BmeStatementData_NtdcDateTime=DH.BmeStatementData_NtdcDateTime
AND MCH.BmeStatementData_Year=DH.BmeStatementData_Year
AND MCH.BmeStatementData_Month=DH.BmeStatementData_Month

WHERE DH.BmeStatementData_Year = @Year
AND DH.BmeStatementData_Month = @Month
AND DH.BmeStatementData_StatementProcessId = @StatementProcessId
AND MCH.BmeStatementData_StatementProcessId =@StatementProcessId
AND MPH.BmeStatementData_StatementProcessId =@StatementProcessId
--AND DH.BmeStatementData_Day = 1
--AND DH.BmeStatementData_Hour = 1
AND MCH.BmeStatementData_ContractId=1111
AND MPH.BmeStatementData_PartyRegisteration_Id=12;

-----


 UPDATE BmeStatementDataMpHourly
 SET BmeStatementData_CAPLegacy= DH.BmeStatementData_CAPLegacy * ISNULL(
 (SELECT TOP (1) AF.LuAllocationFactors_Factor FROM LuAllocationFactors AF WHERE
 MH.BmeStatementData_NtdcDateTime>=AF.LuAllocationFactors_EffectiveFrom 
 and MH.BmeStatementData_NtdcDateTime<=ISNULL(AF.LuAllocationFactors_EffectiveTo,@MONTH_EFFECTIVE_TO)
 and AF.MtPartyRegisteration_Id=MH.BmeStatementData_PartyRegisteration_Id
 AND AF.LuAllocationFactors_Factor>0
 )
 ,0)*0.01
 FROM BmeStatementDataMpHourly MH
 INNER JOIN BmeStatementDataHourly DH ON 
 DH.BmeStatementData_NtdcDateTime= MH.BmeStatementData_NtdcDateTime and DH.BmeStatementData_StatementProcessId= MH.BmeStatementData_StatementProcessId
 WHERE 
 DH.[BmeStatementData_Year] = @Year and DH.[BmeStatementData_Month] = @Month and DH.BmeStatementData_StatementProcessId=@StatementProcessId
 and MH.[BmeStatementData_Year] = @Year and MH.[BmeStatementData_Month] = @Month and MH.BmeStatementData_StatementProcessId=@StatementProcessId;


 /*
 update cap value only for K.E
 */


 UPDATE BmeStatementDataMpHourly
SET 
BmeStatementData_CAPLegacy=

 ISNULL(

MCH.BmeStatementData_CapQuantity ,0)

 FROM 
BmeStatementDataMpHourly MPH

JOIN BmeStatementDataMpContractHourly MCH ON MCH.BmeStatementData_NtdcDateTime=MPH.BmeStatementData_NtdcDateTime
AND MCH.BmeStatementData_Year=MPH.BmeStatementData_Year
AND MCH.BmeStatementData_Month=MPH.BmeStatementData_Month
AND MPH.BmeStatementData_PartyRegisteration_Id=MCH.BmeStatementData_BuyerPartyRegisteration_Id
WHERE
 MCH.BmeStatementData_StatementProcessId =@StatementProcessId
AND MPH.BmeStatementData_StatementProcessId =@StatementProcessId
AND MCH.BmeStatementData_ContractId=1111
AND MPH.BmeStatementData_PartyRegisteration_Id=12;



 --------

	 ---------------------------------------------------------------
--  1.1  Update Energy Traded Sold --Generation Following 
------------------
WITH EnergyTradedSold_CTE
AS
(
    SELECT BC.BmeStatementData_ContractId,BC.BmeStatementData_NtdcDateTime,
	   	SUM(
		(ISNULL( CASE WHEN CDPH.BmeStatementData_ToPartyType_Code='MP'
		 THEN
	      CDPH.BmeStatementData_AdjustedEnergyImport
		  END ,0)
		  +
		ISNULL( CASE WHEN CDPH.BmeStatementData_FromPartyType_Code='MP'
		 THEN
	      CDPH.BmeStatementData_AdjustedEnergyExport
		END,0)
        )* BC.BmeStatementData_Percentage * 0.01
		)  AS EnergyTradedSold
		
	from BmeStatementDataCdpHourly CDPH	
	INNER JOIN [BmeStatementDataCdpContractHourly] BC     
    on BC.BmeStatementData_CdpId=CDPH.BmeStatementData_CdpId
    AND CDPH.BmeStatementData_NtdcDateTime=BC.BmeStatementData_NtdcDateTime
    AND CDPH.BmeStatementData_StatementProcessId=BC.BmeStatementData_StatementProcessId

where BC.BmeStatementData_Year = @Year and BC.BmeStatementData_Month =  @Month and BC.BmeStatementData_StatementProcessId=@StatementProcessId
and BC.BmeStatementData_ContractType_Id=1
GROUP BY BC.BmeStatementData_ContractId,BC.BmeStatementData_NtdcDateTime
)

UPDATE BmeStatementDataMpContractHourly set
 BmeStatementData_EnergyTradedSold = ET.EnergyTradedSold,
 BmeStatementData_EnergyTradedBought = ET.EnergyTradedSold
from BmeStatementDataMpContractHourly C INNER JOIN  EnergyTradedSold_CTE as ET 
ON C.BmeStatementData_ContractId=ET.BmeStatementData_ContractId AND C.BmeStatementData_NtdcDateTime=ET.BmeStatementData_NtdcDateTime
WHERE C.[BmeStatementData_Year] = @Year and C.[BmeStatementData_Month] = @Month and C.BmeStatementData_StatementProcessId=@StatementProcessId

;
 
------------------
	-------------------------------------
----------------------------------------------------------------

--  2.1  Update Energy Traded Sold --Load Following 
------------------
WITH EnergyTradedSold_CTE
AS
(SELECT SE.BmeStatementData_ContractId,SE.BmeStatementData_NtdcDateTime,SUM( (SE.ActualEnergy*ISNULL((1 + H.BmeStatementData_UpliftTransmissionLosses),0)) *SE.BmeStatementData_Percentage*.01) AS EnergyTradedSold FROM 
(SELECT BC.BmeStatementData_ContractId,BC.BmeStatementData_NtdcDateTime,BC.BmeStatementData_Percentage,
	   	    (
		  	ISNULL( CASE  WHEN  CDPH.BmeStatementData_ToPartyType_Code='SP' AND Exists(select top (1) 1 from MtPartyCategory as c
  inner join MtConnectedMeter as mm
  on c.MtPartyCategory_Id=mm.MtPartyCategory_Id
  inner join RuCDPDetail as cdp
  on  cdp.RuCDPDetail_Id=mm.MtCDPDetail_Id where MtPartyRegisteration_Id=BC.BmeStatementData_BuyerPartyRegisteration_Id and cdp.RuCDPDetail_CdpId=CDPH.BmeStatementData_CdpId and c.SrCategory_Code in ('BPC','PAKT','INTT','CSUP','GEN','CGEN'))
	THEN	
	CDPH.BmeStatementData_AdjustedEnergyImport
	end,0)  --as Case1ActualEnergy,
	+
ISNULL(	CASE WHEN CDPH.BmeStatementData_FromPartyType_Code='SP' AND Exists(select top (1) 1 from MtPartyCategory as c
  inner join MtConnectedMeter as mm
  on c.MtPartyCategory_Id=mm.MtPartyCategory_Id
  inner join RuCDPDetail as cdp
  on  cdp.RuCDPDetail_Id=mm.MtCDPDetail_Id where MtPartyRegisteration_Id=BC.BmeStatementData_BuyerPartyRegisteration_Id and cdp.RuCDPDetail_CdpId=CDPH.BmeStatementData_CdpId and c.SrCategory_Code in ('BPC','PAKT','INTT','CSUP','GEN','CGEN'))
	THEN
	CDPH.BmeStatementData_AdjustedEnergyExport
	end,0) --as Case2ActualEnergy,
	+
ISNULL(	CASE WHEN  CDPH.BmeStatementData_FromPartyType_Code ='SP' and CDPH.BmeStatementData_FromPartyCategory_Code='DSP' AND Exists(select top (1) 1 from MtPartyCategory as c
  inner join MtConnectedMeter as mm
  on c.MtPartyCategory_Id=mm.MtPartyCategory_Id
  inner join RuCDPDetail as cdp
  on  cdp.RuCDPDetail_Id=mm.MtCDPDetail_Id where MtPartyRegisteration_Id=BC.BmeStatementData_BuyerPartyRegisteration_Id and cdp.RuCDPDetail_CdpId=CDPH.BmeStatementData_CdpId and c.SrCategory_Code='BSUP')
    
	and  exists (SELECT 1 FROM Bme_Parties P
		WHERE P.PartyRegisteration_Id=CDPH.BmeStatementData_FromPartyRegisteration_Id
        and P.MPId = BC.BmeStatementData_BuyerPartyRegisteration_Id		 
		)
	
	THEN
     ISNULL(CDPH.BmeStatementData_AdjustedEnergyImport,0) - ISNULL(CDPH.BmeStatementData_AdjustedEnergyExport,0)
 end,0) --as Case3ActualEnergy,
  +
 ISNULL( CASE WHEN  CDPH.BmeStatementData_ToPartyType_Code ='SP' and CDPH.BmeStatementData_ToPartyCategory_Code='DSP' AND Exists(select top (1) 1 from MtPartyCategory as c
  inner join MtConnectedMeter as mm
  on c.MtPartyCategory_Id=mm.MtPartyCategory_Id
  inner join RuCDPDetail as cdp
  on  cdp.RuCDPDetail_Id=mm.MtCDPDetail_Id where MtPartyRegisteration_Id=BC.BmeStatementData_BuyerPartyRegisteration_Id and cdp.RuCDPDetail_CdpId=CDPH.BmeStatementData_CdpId and c.SrCategory_Code='BSUP')
  
	
	and  exists (SELECT 1 FROM Bme_Parties P
		WHERE P.PartyRegisteration_Id=CDPH.BmeStatementData_ToPartyRegisteration_Id
        and P.MPId = BC.BmeStatementData_BuyerPartyRegisteration_Id		 
		)
        
	THEN	
    ISNULL(CDPH.BmeStatementData_AdjustedEnergyExport,0)- ISNULL(CDPH.BmeStatementData_AdjustedEnergyImport,0)
	END,0) --as Case4ActualEnergy
    ) AS ActualEnergy

		
	from BmeStatementDataCdpHourly CDPH	
	INNER JOIN [BmeStatementDataCdpContractHourly] BC     
    on BC.BmeStatementData_CdpId=CDPH.BmeStatementData_CdpId
    AND CDPH.BmeStatementData_NtdcDateTime=BC.BmeStatementData_NtdcDateTime
    AND CDPH.BmeStatementData_StatementProcessId=BC.BmeStatementData_StatementProcessId
    
where BC.BmeStatementData_Year = @Year and BC.BmeStatementData_Month =  @Month and BC.BmeStatementData_StatementProcessId=@StatementProcessId
and BC.BmeStatementData_ContractType_Id=2 and BC.BmeStatementData_ContractSubType_Id = 21
) as SE 
INNER JOIN BmeStatementDataHourly H
    on SE.BmeStatementData_NtdcDateTime=H.BmeStatementData_NtdcDateTime
WHERE H.BmeStatementData_Year = @Year and H.BmeStatementData_Month =  @Month and H.BmeStatementData_StatementProcessId=@StatementProcessId
GROUP BY SE.BmeStatementData_ContractId,SE.BmeStatementData_NtdcDateTime

)

UPDATE BmeStatementDataMpContractHourly set
 BmeStatementData_EnergyTradedSold = ET.EnergyTradedSold,
 BmeStatementData_EnergyTradedBought = ET.EnergyTradedSold
from BmeStatementDataMpContractHourly C INNER JOIN 
EnergyTradedSold_CTE AS ET
ON C.BmeStatementData_ContractId=ET.BmeStatementData_ContractId AND C.BmeStatementData_NtdcDateTime=ET.BmeStatementData_NtdcDateTime
 Where C.[BmeStatementData_Year] = @Year and C.[BmeStatementData_Month] = @Month and C.BmeStatementData_StatementProcessId=@StatementProcessId;

-----------------------------------------------------------------
----  3.1  Update Energy Traded Sold --Fixed Quantity 
--------------------
WITH EnergyTradedSold_CTE
AS
 (
    SELECT BC.BmeStatementData_ContractId,BC.BmeStatementData_NtdcDateTime,
	   	SUM(ISNULL(BmeStatementData_ContractedQuantity ,0)) AS EnergyTradedSold
		
	from BmeStatementDataCdpContractHourly BC	


where BC.BmeStatementData_Year = @Year and BC.BmeStatementData_Month =  @Month and BC.BmeStatementData_StatementProcessId=@StatementProcessId
and BC.BmeStatementData_ContractType_Id=3
GROUP BY BC.BmeStatementData_ContractId,BC.BmeStatementData_NtdcDateTime
)

UPDATE BmeStatementDataMpContractHourly set
 BmeStatementData_EnergyTradedSold = ET.EnergyTradedSold,
 BmeStatementData_EnergyTradedBought = ET.EnergyTradedSold
from BmeStatementDataMpContractHourly C INNER JOIN EnergyTradedSold_CTE AS ET 
ON C.BmeStatementData_ContractId=ET.BmeStatementData_ContractId AND C.BmeStatementData_NtdcDateTime=ET.BmeStatementData_NtdcDateTime
Where C.[BmeStatementData_Year] = @Year and C.[BmeStatementData_Month] = @Month and C.BmeStatementData_StatementProcessId=@StatementProcessId;
--	---------------------------------- 

----  4.1  Update Energy Traded Sold --Customized
WITH ActualEnergy_CTE
AS 
(
select r.BmeStatementData_BuyerPartyRegisteration_Id
	,r.BmeStatementData_ContractId, r.BmeStatementData_NtdcDateTime
	,Max(r.BmeStatementData_CapQuantity) as BmeStatementData_CapQuantity
	,SUM(ISNULL(r.Case1ActualEnergy,0)+ISNULL(r.Case2ActualEnergy,0)+ISNULL(r.Case3ActualEnergy,0)+ISNULL(r.Case4ActualEnergy,0)) as BmeStatementData_ActualEnergy from
  (select BC.BmeStatementData_BuyerPartyRegisteration_Id		
        ,BC.BmeStatementData_ContractId
	    ,CDPH.BmeStatementData_NtdcDateTime
	    ,BC.BmeStatementData_CapQuantity		
	,	
	CASE  WHEN  CDPH.BmeStatementData_ToPartyType_Code='SP' AND Exists(select top (1) 1 from MtPartyCategory as c
  inner join MtConnectedMeter as mm
  on c.MtPartyCategory_Id=mm.MtPartyCategory_Id
  inner join RuCDPDetail as cdp
  on  cdp.RuCDPDetail_Id=mm.MtCDPDetail_Id where MtPartyRegisteration_Id=BC.BmeStatementData_BuyerPartyRegisteration_Id and cdp.RuCDPDetail_CdpId=CDPH.BmeStatementData_CdpId and c.SrCategory_Code in ('BPC','PAKT','INTT','CSUP','GEN','CGEN'))
	THEN	
	ISNULL(CDPH.BmeStatementData_AdjustedEnergyImport,0)
	end as Case1ActualEnergy,
	
	CASE WHEN CDPH.BmeStatementData_FromPartyType_Code='SP' AND Exists(select top (1) 1 from MtPartyCategory as c
  inner join MtConnectedMeter as mm
  on c.MtPartyCategory_Id=mm.MtPartyCategory_Id
  inner join RuCDPDetail as cdp
  on  cdp.RuCDPDetail_Id=mm.MtCDPDetail_Id where MtPartyRegisteration_Id=BC.BmeStatementData_BuyerPartyRegisteration_Id and cdp.RuCDPDetail_CdpId=CDPH.BmeStatementData_CdpId and c.SrCategory_Code in ('BPC','PAKT','INTT','CSUP','GEN','CGEN'))
	THEN
	ISNULL(CDPH.BmeStatementData_AdjustedEnergyExport,0)
	end as Case2ActualEnergy,
	
	CASE WHEN  CDPH.BmeStatementData_FromPartyType_Code ='SP' and CDPH.BmeStatementData_FromPartyCategory_Code='DSP' AND Exists(select top (1) 1 from MtPartyCategory as c
  inner join MtConnectedMeter as mm
  on c.MtPartyCategory_Id=mm.MtPartyCategory_Id
  inner join RuCDPDetail as cdp
  on  cdp.RuCDPDetail_Id=mm.MtCDPDetail_Id where MtPartyRegisteration_Id=BC.BmeStatementData_BuyerPartyRegisteration_Id and cdp.RuCDPDetail_CdpId=CDPH.BmeStatementData_CdpId and c.SrCategory_Code='BSUP')
    
	and  exists (SELECT 1 FROM Bme_Parties P
		WHERE P.PartyRegisteration_Id=CDPH.BmeStatementData_FromPartyRegisteration_Id
        and P.MPId = BC.BmeStatementData_BuyerPartyRegisteration_Id		 
		)
	
	THEN
 ISNULL(CDPH.BmeStatementData_AdjustedEnergyImport,0) - ISNULL(CDPH.BmeStatementData_AdjustedEnergyExport,0)
 end as Case3ActualEnergy,
  
  CASE WHEN  CDPH.BmeStatementData_ToPartyType_Code ='SP' and CDPH.BmeStatementData_ToPartyCategory_Code='DSP' AND Exists(select top (1) 1 from MtPartyCategory as c
  inner join MtConnectedMeter as mm
  on c.MtPartyCategory_Id=mm.MtPartyCategory_Id
  inner join RuCDPDetail as cdp
  on  cdp.RuCDPDetail_Id=mm.MtCDPDetail_Id where MtPartyRegisteration_Id=BC.BmeStatementData_BuyerPartyRegisteration_Id and cdp.RuCDPDetail_CdpId=CDPH.BmeStatementData_CdpId and c.SrCategory_Code='BSUP')
  
	
	and  exists (SELECT 1 FROM Bme_Parties P
		WHERE P.PartyRegisteration_Id=CDPH.BmeStatementData_ToPartyRegisteration_Id
        and P.MPId = BC.BmeStatementData_BuyerPartyRegisteration_Id		 
		)
	THEN
	
    ISNULL(CDPH.BmeStatementData_AdjustedEnergyExport,0)- ISNULL(CDPH.BmeStatementData_AdjustedEnergyImport,0)
	END as Case4ActualEnergy


	from BmeStatementDataCdpHourly CDPH	
	INNER JOIN [BmeStatementDataCdpContractHourly] BC     
    on BC.BmeStatementData_CdpId=CDPH.BmeStatementData_CdpId
    AND CDPH.BmeStatementData_NtdcDateTime=BC.BmeStatementData_NtdcDateTime
	AND CDPH.BmeStatementData_StatementProcessId=BC.BmeStatementData_StatementProcessId
	where CDPH.BmeStatementData_Year = @Year and CDPH.BmeStatementData_Month = @Month AND CDPH.BmeStatementData_StatementProcessId=@StatementProcessId
	and BC.BmeStatementData_ContractType_Id=4 and BC.BmeStatementData_ContractSubType_Id=41
	) as r
	GROUP by r.BmeStatementData_BuyerPartyRegisteration_Id
	,r.BmeStatementData_ContractId, r.BmeStatementData_NtdcDateTime
)

SELECT 
con.BmeStatementData_ContractId,
 con.BmeStatementData_NtdcDateTime
,H.BmeStatementData_Hour
,H.BmeStatementData_Day
,ISNULL(
/* 
case when con.BmeStatementData_CapQuantity>0
THEN
	case when con.BmeStatementData_CapQuantity>con.BmeStatementData_ActualEnergy*ISNULL((1 + H.BmeStatementData_UpliftTransmissionLosses),0) 
    then  con.BmeStatementData_ActualEnergy*ISNULL((1 + H.BmeStatementData_UpliftTransmissionLosses),0)
	ELSE con.BmeStatementData_CapQuantity end

ELSE

case when H.BmeStatementData_CAPLegacy>con.BmeStatementData_ActualEnergy*ISNULL((1 + H.BmeStatementData_UpliftTransmissionLosses),0) 
then  con.BmeStatementData_ActualEnergy*ISNULL((1 + H.BmeStatementData_UpliftTransmissionLosses),0)
*/
case when con.BmeStatementData_CapQuantity>0
THEN
	case when con.BmeStatementData_CapQuantity>H.BmeStatementData_EnergySuppliedActual
    then  H.BmeStatementData_EnergySuppliedActual
	ELSE con.BmeStatementData_CapQuantity end

ELSE

case when H.BmeStatementData_CAPLegacy>H.BmeStatementData_EnergySuppliedActual
then  H.BmeStatementData_EnergySuppliedActual

ELSE H.BmeStatementData_CAPLegacy end
END
,0) as EnergyTradedSold
INTO #TempEnergyTradedSold
 FROM BmeStatementDataMpHourly H
	INNER JOIN  ActualEnergy_CTE as con 
	on H.BmeStatementData_PartyRegisteration_Id=con.BmeStatementData_BuyerPartyRegisteration_Id 
	and H.BmeStatementData_NtdcDateTime = con.BmeStatementData_NtdcDateTime
WHERE H.BmeStatementData_Year = @Year and H.BmeStatementData_Month =  @Month and H.BmeStatementData_StatementProcessId=@StatementProcessId
;		

-------------------------------------
UPDATE BmeStatementDataMpContractHourly set
    BmeStatementData_EnergyTradedSold = ISNULL(IMP.EnergyTradedSold,0),
    BmeStatementData_EnergyTradedBought = ISNULL(IMP.EnergyTradedSold,0)
	FROM BmeStatementDataMpContractHourly As C
	INNER JOIN #TempEnergyTradedSold as IMP ON
	C.BmeStatementData_ContractId=IMP.BmeStatementData_ContractId 
	and C.BmeStatementData_NtdcDateTime=IMP.BmeStatementData_NtdcDateTime
    where C.BmeStatementData_Year = @Year and C.BmeStatementData_Month = @Month and C.BmeStatementData_StatementProcessId=@StatementProcessId;

-------------------------------------------


    -- Customized - Load Following Meterd  42

	------------------
WITH EnergyTradedSold_CTE
AS
(	
	select BC.BmeStatementData_BuyerPartyRegisteration_Id,BC.BmeStatementData_BuyerPartyCategory_Code
	,CDPH.BmeStatementData_CongestedZoneID
	,BC.BmeStatementData_ContractId,BC.BmeStatementData_NtdcDateTime,
    Max(BC.BmeStatementData_CapQuantity) as BmeStatementData_CapQuantity
    -- ,SUM(ISNULL(CDPH.BmeStatementData_IncEnergyExport,0)) as EnergyTradedSold 
	
	,SUM(CASE WHEN BC.BmeStatementData_BuyerPartyRegisteration_Id=CDPH.BmeStatementData_FromPartyRegisteration_Id THEN
   ABS(ISNULL(CDPH.BmeStatementData_IncEnergyImport,0)-ISNULL(CDPH.BmeStatementData_IncEnergyExport,0))
   ELSE
   ABS(ISNULL(CDPH.BmeStatementData_IncEnergyExport,0)-ISNULL(CDPH.BmeStatementData_IncEnergyImport,0))
   END) AS EnergyTradedSold
   
	from BmeStatementDataCdpHourly CDPH	
	INNER JOIN [BmeStatementDataCdpContractHourly] BC     
    on BC.BmeStatementData_CdpId=CDPH.BmeStatementData_CdpId
    AND CDPH.BmeStatementData_NtdcDateTime=BC.BmeStatementData_NtdcDateTime
    AND CDPH.BmeStatementData_StatementProcessId=BC.BmeStatementData_StatementProcessId
	where CDPH.BmeStatementData_Year = @Year and CDPH.BmeStatementData_Month = @Month
	AND CDPH.BmeStatementData_StatementProcessId=@StatementProcessId
	and BC.BmeStatementData_ContractType_Id=4 and BC.BmeStatementData_ContractSubType_Id = 42

    GROUP by BC.BmeStatementData_BuyerPartyRegisteration_Id
	,BC.BmeStatementData_BuyerPartyCategory_Code
	,CDPH.BmeStatementData_CongestedZoneID
	,BC.BmeStatementData_ContractId,BC.BmeStatementData_NtdcDateTime
)

SELECT 
con.BmeStatementData_ContractId,
 con.BmeStatementData_NtdcDateTime
,MH.BmeStatementData_Hour
,MH.BmeStatementData_Day
,ISNULL(

case when con.BmeStatementData_CapQuantity>0
THEN
	case when con.BmeStatementData_CapQuantity>MH.BmeStatementData_EnergySuppliedActual--con.EnergyTradedSold
    then  MH.BmeStatementData_EnergySuppliedActual
	ELSE con.BmeStatementData_CapQuantity end

ELSE

case when MH.BmeStatementData_CAPLegacy>con.EnergyTradedSold 
then  con.EnergyTradedSold

ELSE MH.BmeStatementData_CAPLegacy end
END
,0) as EnergyTradedSold
INTO #TempEnergyTradedSold42
 FROM BmeStatementDataMpHourly MH
	INNER JOIN EnergyTradedSold_CTE as con 
	on MH.BmeStatementData_PartyRegisteration_Id=con.BmeStatementData_BuyerPartyRegisteration_Id 
	and MH.BmeStatementData_NtdcDateTime = con.BmeStatementData_NtdcDateTime
    Where MH.[BmeStatementData_Year] = @Year and MH.[BmeStatementData_Month] = @Month and MH.BmeStatementData_StatementProcessId=@StatementProcessId;		

-------------------------------------
	UPDATE BmeStatementDataMpContractHourly set
    BmeStatementData_EnergyTradedSold = ISNULL(IMP.EnergyTradedSold,0),
    BmeStatementData_EnergyTradedBought = ISNULL(IMP.EnergyTradedSold,0)
	FROM BmeStatementDataMpContractHourly As C
	INNER JOIN #TempEnergyTradedSold42 as IMP ON
	C.BmeStatementData_ContractId=IMP.BmeStatementData_ContractId 
	and C.BmeStatementData_NtdcDateTime=IMP.BmeStatementData_NtdcDateTime
    where C.BmeStatementData_Year = @Year and C.BmeStatementData_Month = @Month and C.BmeStatementData_StatementProcessId=@StatementProcessId;




-- load following 22  meter

	------------------
WITH EnergyTradedSold_CTE
AS
(select BC.BmeStatementData_ContractId,BC.BmeStatementData_NtdcDateTime
     ,SUM(ISNULL(CDPH.BmeStatementData_IncEnergyImport,0)) as EnergyTradedSold 
				
	from BmeStatementDataCdpHourly CDPH	
	INNER JOIN [BmeStatementDataCdpContractHourly] BC     
    on BC.BmeStatementData_CdpId=CDPH.BmeStatementData_CdpId
    AND CDPH.BmeStatementData_NtdcDateTime=BC.BmeStatementData_NtdcDateTime
AND CDPH.BmeStatementData_StatementProcessId=BC.BmeStatementData_StatementProcessId
	where CDPH.BmeStatementData_Year = @Year and CDPH.BmeStatementData_Month = @Month AND CDPH.BmeStatementData_StatementProcessId=@StatementProcessId
	and BC.BmeStatementData_ContractType_Id=2 and BC.BmeStatementData_ContractSubType_Id = 22

    GROUP by BC.BmeStatementData_ContractId,BC.BmeStatementData_NtdcDateTime
	)

UPDATE BmeStatementDataMpContractHourly set
    BmeStatementData_EnergyTradedSold = ISNULL(ET.EnergyTradedSold,0),
    BmeStatementData_EnergyTradedBought = ISNULL(ET.EnergyTradedSold,0)
	FROM BmeStatementDataMpContractHourly As C
	INNER JOIN 
   EnergyTradedSold_CTE as ET	
	on C.BmeStatementData_ContractId=ET.BmeStatementData_ContractId 
	and C.BmeStatementData_NtdcDateTime = ET.BmeStatementData_NtdcDateTime    
   WHERE C.BmeStatementData_Year = @Year and C.BmeStatementData_Month =  @Month and C.BmeStatementData_StatementProcessId=@StatementProcessId ;		


-- load following 23 adjusted
--------
WITH EnergyTradedSold_CTE
AS
(select BC.BmeStatementData_ContractId,BC.BmeStatementData_NtdcDateTime
     ,SUM(ISNULL(CDPH.BmeStatementData_AdjustedEnergyImport,0)) as EnergyTradedSold 
				
	from BmeStatementDataCdpHourly CDPH	
	INNER JOIN [BmeStatementDataCdpContractHourly] BC     
    on BC.BmeStatementData_CdpId=CDPH.BmeStatementData_CdpId
    AND CDPH.BmeStatementData_NtdcDateTime=BC.BmeStatementData_NtdcDateTime
AND CDPH.BmeStatementData_StatementProcessId=BC.BmeStatementData_StatementProcessId
	where CDPH.BmeStatementData_Year = @Year and CDPH.BmeStatementData_Month = @Month AND CDPH.BmeStatementData_StatementProcessId=@StatementProcessId
	and BC.BmeStatementData_ContractType_Id=2 and BC.BmeStatementData_ContractSubType_Id = 23

    GROUP by BC.BmeStatementData_ContractId,BC.BmeStatementData_NtdcDateTime
	)

UPDATE BmeStatementDataMpContractHourly set
    BmeStatementData_EnergyTradedSold = ISNULL(ET.EnergyTradedSold,0),
    BmeStatementData_EnergyTradedBought = ISNULL(ET.EnergyTradedSold,0)
	FROM BmeStatementDataMpContractHourly As C
	INNER JOIN EnergyTradedSold_CTE as ET	
	on C.BmeStatementData_ContractId=ET.BmeStatementData_ContractId 
	and C.BmeStatementData_NtdcDateTime = ET.BmeStatementData_NtdcDateTime    
   WHERE C.BmeStatementData_Year = @Year and C.BmeStatementData_Month =  @Month and C.BmeStatementData_StatementProcessId=@StatementProcessId ;		
 ;		
--------------------------


------- Update MP EnergyTraded----------------------

WITH EnergyTradedSold_CTE
AS  
(  
    SELECT 
	C.BmeStatementData_SellerPartyRegisteration_Id,C.BmeStatementData_NtdcDateTime, 
    SUM(C.BmeStatementData_EnergyTradedSold)  as EnergyTradedSold
	FROM BmeStatementDataMpContractHourly C
    where C.BmeStatementData_Year = @Year and C.BmeStatementData_Month = @Month and C.BmeStatementData_StatementProcessId=@StatementProcessId
	GROUP BY C.BmeStatementData_SellerPartyRegisteration_Id,C.BmeStatementData_NtdcDateTime  
)  

UPDATE BmeStatementDataMpHourly set
    BmeStatementData_EnergyTradedSold = ISNULL(IMP.EnergyTradedSold,0)
	FROM BmeStatementDataMpHourly MH 
	INNER JOIN EnergyTradedSold_CTE as IMP ON
	MH.BmeStatementData_PartyRegisteration_Id=IMP.BmeStatementData_SellerPartyRegisteration_Id
	and MH.BmeStatementData_NtdcDateTime=IMP.BmeStatementData_NtdcDateTime
    where MH.BmeStatementData_Year = @Year and MH.BmeStatementData_Month = @Month and MH.BmeStatementData_StatementProcessId=@StatementProcessId;

-------------------------------------------------

WITH EnergyTradedBought_CTE
AS  
(  
    SELECT 
	C.BmeStatementData_BuyerPartyRegisteration_Id,C.BmeStatementData_NtdcDateTime,
     SUM(C.BmeStatementData_EnergyTradedBought)  as EnergyTradedBought
	FROM BmeStatementDataMpContractHourly C
    where C.BmeStatementData_Year = @Year and C.BmeStatementData_Month = @Month and C.BmeStatementData_StatementProcessId=@StatementProcessId
	GROUP BY C.BmeStatementData_BuyerPartyRegisteration_Id,C.BmeStatementData_NtdcDateTime
)

 UPDATE BmeStatementDataMpHourly set
    BmeStatementData_EnergyTradedBought = ISNULL(IMP.EnergyTradedBought,0)
	FROM BmeStatementDataMpHourly MH 
	INNER JOIN EnergyTradedBought_CTE as IMP ON
	MH.BmeStatementData_PartyRegisteration_Id=IMP.BmeStatementData_BuyerPartyRegisteration_Id 
	and MH.BmeStatementData_NtdcDateTime=IMP.BmeStatementData_NtdcDateTime
    where MH.BmeStatementData_Year = @Year and MH.BmeStatementData_Month = @Month and MH.BmeStatementData_StatementProcessId=@StatementProcessId;


-----------------------------------------------------
    UPDATE BmeStatementDataMpHourly set
    BmeStatementData_EnergyTraded = ISNULL(BmeStatementData_EnergyTradedBought,0) - ISNULL(BmeStatementData_EnergyTradedSold,0)
    where BmeStatementData_Year=@Year and BmeStatementData_Month=@Month and BmeStatementData_StatementProcessId=@StatementProcessId;


-------------------------------------
WITH CategoryEnergyTradedSold_CTE
AS  
(  
    SELECT 
	C.BmeStatementData_SellerPartyRegisteration_Id,C.BmeStatementData_SellerPartyCategory_Code,c.BmeStatementData_CongestedZoneID,C.BmeStatementData_NtdcDateTime, 
    SUM(C.BmeStatementData_EnergyTradedSold)  as EnergyTradedSold
	FROM BmeStatementDataMpContractHourly C
    where C.BmeStatementData_Year = @Year and C.BmeStatementData_Month = @Month and C.BmeStatementData_StatementProcessId=@StatementProcessId
	GROUP BY C.BmeStatementData_SellerPartyRegisteration_Id,C.BmeStatementData_SellerPartyCategory_Code
	,c.BmeStatementData_CongestedZoneID
	,C.BmeStatementData_NtdcDateTime  
)  

UPDATE BmeStatementDataMpCategoryHourly set
    BmeStatementData_EnergyTradedSold = ISNULL(IMP.EnergyTradedSold,0)
	FROM BmeStatementDataMpCategoryHourly MH 
	INNER JOIN CategoryEnergyTradedSold_CTE as IMP ON
	MH.BmeStatementData_PartyRegisteration_Id=IMP.BmeStatementData_SellerPartyRegisteration_Id
	and MH.BmeStatementData_NtdcDateTime=IMP.BmeStatementData_NtdcDateTime
    and MH.BmeStatementData_PartyCategory_Code=IMP.BmeStatementData_SellerPartyCategory_Code
    and MH.BmeStatementData_CongestedZoneID=IMP.BmeStatementData_CongestedZoneID
    where MH.BmeStatementData_Year = @Year and MH.BmeStatementData_Month = @Month and MH.BmeStatementData_StatementProcessId=@StatementProcessId;

-------------------------------------------------

WITH CategoryEnergyTradedBought_CTE
AS  
(  
    SELECT 
	C.BmeStatementData_BuyerPartyRegisteration_Id,C.BmeStatementData_BuyerPartyCategory_Code,c.BmeStatementData_CongestedZoneID,C.BmeStatementData_NtdcDateTime,
     SUM(C.BmeStatementData_EnergyTradedBought)  as EnergyTradedBought
	FROM BmeStatementDataMpContractHourly C
    where C.BmeStatementData_Year = @Year and C.BmeStatementData_Month = @Month and C.BmeStatementData_StatementProcessId=@StatementProcessId
	GROUP BY C.BmeStatementData_BuyerPartyRegisteration_Id,C.BmeStatementData_BuyerPartyCategory_Code
	,C.BmeStatementData_CongestedZoneID
	,C.BmeStatementData_NtdcDateTime
)

 UPDATE BmeStatementDataMpCategoryHourly set
    BmeStatementData_EnergyTradedBought = ISNULL(IMP.EnergyTradedBought,0)
	FROM BmeStatementDataMpCategoryHourly MH 
	INNER JOIN CategoryEnergyTradedBought_CTE as IMP ON
	MH.BmeStatementData_PartyRegisteration_Id=IMP.BmeStatementData_BuyerPartyRegisteration_Id 
	and MH.BmeStatementData_NtdcDateTime=IMP.BmeStatementData_NtdcDateTime
    and MH.BmeStatementData_PartyCategory_Code=imp.BmeStatementData_BuyerPartyCategory_Code
    AND MH.BmeStatementData_CongestedZoneID=IMP.BmeStatementData_CongestedZoneID
    where MH.BmeStatementData_Year = @Year and MH.BmeStatementData_Month = @Month and MH.BmeStatementData_StatementProcessId=@StatementProcessId;


-----------------------------------------------------
    UPDATE BmeStatementDataMpCategoryHourly set
    BmeStatementData_EnergyTraded = ISNULL(BmeStatementData_EnergyTradedBought,0) - ISNULL(BmeStatementData_EnergyTradedSold,0)
    where BmeStatementData_Year=@Year and BmeStatementData_Month=@Month and BmeStatementData_StatementProcessId=@StatementProcessId;

/*
UPDATE BmeStatementDataMpCategoryHourly set
    BmeStatementData_EnergyTradedBought = ISNULL(IMP.EnergyTradedBought,0)
	FROM BmeStatementDataMpCategoryHourly MH 
	INNER JOIN (
	SELECT 
	C.BmeStatementData_BuyerPartyRegisteration_Id,C.BmeStatementData_BuyerPartyCategory_Code
	,C.BmeStatementData_CongestedZoneID
	,C.BmeStatementData_NtdcDateTime,
     SUM(C.BmeStatementData_EnergyTradedBought)  as EnergyTradedBought
	FROM BmeStatementDataMpContractHourly C
    where C.BmeStatementData_Year = @Year and C.BmeStatementData_Month = @Month and C.BmeStatementData_StatementProcessId=@StatementProcessId
	GROUP BY C.BmeStatementData_BuyerPartyRegisteration_Id,C.BmeStatementData_BuyerPartyCategory_Code
	,C.BmeStatementData_CongestedZoneID
	,C.BmeStatementData_NtdcDateTime) as IMP ON

	MH.BmeStatementData_PartyRegisteration_Id=IMP.BmeStatementData_BuyerPartyRegisteration_Id 
	and MH.BmeStatementData_NtdcDateTime=IMP.BmeStatementData_NtdcDateTime
    and MH.BmeStatementData_PartyCategory_Code=IMP.BmeStatementData_BuyerPartyCategory_Code
    and MH.BmeStatementData_CongestedZoneID=IMP.BmeStatementData_CongestedZoneID
    where MH.BmeStatementData_Year = @Year and MH.BmeStatementData_Month = @Month and MH.BmeStatementData_StatementProcessId=@StatementProcessId;

---------------------------------------

 UPDATE BmeStatementDataMpCategoryHourly set
    BmeStatementData_EnergyTraded = ISNULL(BmeStatementData_EnergyTradedBought,0) - ISNULL(BmeStatementData_EnergyTradedSold,0)
    where BmeStatementData_Year=@Year and BmeStatementData_Month=@Month and BmeStatementData_StatementProcessId=@StatementProcessId;
*/



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
