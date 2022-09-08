/****** Object:  Procedure [dbo].[BME_Step7APerform_OLD]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[BME_Step7APerform_OLD]
@Year int,
@Month int
AS
BEGIN

	----1----------Insert distinct party Ids in MpHourly Table
INSERT INTO [dbo].[BmeStatementDataCdpContractHourly]
           (
		   [BmeStatementData_NtdcDateTime]
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
       )
     	select distinct 

		  DATEADD(HOUR,MtBilateralContract_Hour,CAST(MtBilateralContract_Date as datetime)) as BmeStatementData_NtdcDateTime
      ,DATEPART(YEAR, MtBilateralContract_Date) AS BmeStatementData_Year
      ,DATEPART(MONTH,MtBilateralContract_Date) AS BmeStatementData_Month
      ,DATEPART(DAY, MtBilateralContract_Date) AS BmeStatementData_Day
      ,Cast(MtBilateralContract_Hour as int) AS BmeStatementData_Hour 
	   ,[SellerPartyRegisteration_Id]
           ,[SellerPartyRegisteration_Name]
           ,[SellerPartyCategory_Code]
           ,[SellerPartyType_Code]
           ,[BuyerPartyRegisteration_Id]
           ,[BuyerPartyRegisteration_Name]
           ,[BuyerPartyCategory_Code]
           ,[BuyerPartyType_Code]
      , [MtBilateralContract_ContractId]
      ,[MtBilateralContract_CDPID]
      ,[MtBilateralContract_ContractType]     
      ,[MtBilateralContract_ContractedQuantity]
      ,[MtBilateralContract_CapQuantity]
      ,[MtBilateralContract_AncillaryServices]
      ,[MtBilateralContract_Id]
      ,[MtBilateralContract_Percentage]
      ,[SrContractType_Id]
	  ,ContractSubType_Id
	  from dbo.Bme_ContractParties
	 WHERE DATEPART(YEAR, MtBilateralContract_Date)  = @Year and DATEPART(MONTH,MtBilateralContract_Date) = @Month


	 ---------------------------------------------------------------
--  1.1  Update Energy Traded Sold --Generation Following 
------------------

------------------
UPDATE BmeStatementDataMpHourly set
 BmeStatementData_EnergyTradedSold= ISNULL(MPH.BmeStatementData_EnergyTradedSold,0) + ISNULL(cdp.BmeStatementData_EnergyTradedSold,0)
FROM BmeStatementDataMpHourly MPH
INNER JOIN (select BC.BmeStatementData_SellerPartyRegisteration_Id,BC.BmeStatementData_NtdcDateTime , 
Sum(
	   	    (
		ISNULL( CASE WHEN CDPH.BmeStatementData_ToPartyType_Code='MP'
		 THEN
	      CDPH.BmeStatementData_AdjustedEnergyImport
		  END ,0)
		  +
		ISNULL( CASE WHEN CDPH.BmeStatementData_FromPartyType_Code='MP'
		 THEN
	      CDPH.BmeStatementData_AdjustedEnergyExport
		END,0)
		)
		* BC.BmeStatementData_Percentage * 0.01

	) as BmeStatementData_EnergyTradedSold	

	from BmeStatementDataCdpHourly CDPH	
	INNER JOIN [BmeStatementDataCdpContractHourly] BC     
    on BC.BmeStatementData_CdpId=CDPH.BmeStatementData_CdpId
    AND CDPH.BmeStatementData_NtdcDateTime=BC.BmeStatementData_NtdcDateTime

where BC.BmeStatementData_Year = @Year and BC.BmeStatementData_Month =  @Month
and BC.BmeStatementData_ContractType_Id=1
GROUP by BC.BmeStatementData_SellerPartyRegisteration_Id,BC.BmeStatementData_NtdcDateTime	
) as cdp 
on MPH.BmeStatementData_PartyRegisteration_Id=cdp.BmeStatementData_SellerPartyRegisteration_Id 
	and MPH.BmeStatementData_NtdcDateTime = cdp.BmeStatementData_NtdcDateTime;
	-------------------------------------
----  1.2  Update Energy Traded Bought --Generation Following 
UPDATE BmeStatementDataMpHourly set BmeStatementData_EnergyTradedBought =ISNULL(MPH.BmeStatementData_EnergyTradedBought,0) + cdp.BmeStatementData_EnergyTradedBought
FROM BmeStatementDataMpHourly MPH
INNER JOIN (select BC.BmeStatementData_BuyerPartyRegisteration_Id,BC.BmeStatementData_NtdcDateTime ,
Sum(
	    (
		ISNULL( CASE WHEN CDPH.BmeStatementData_ToPartyType_Code='MP'
		 THEN
	      CDPH.BmeStatementData_AdjustedEnergyImport
		  END ,0)
		  +
		ISNULL( CASE WHEN CDPH.BmeStatementData_FromPartyType_Code='MP'
		 THEN
	      CDPH.BmeStatementData_AdjustedEnergyExport
		END,0)
		)
		* BC.BmeStatementData_Percentage * 0.01

	) as BmeStatementData_EnergyTradedBought
	from BmeStatementDataCdpHourly CDPH	
	INNER JOIN [BmeStatementDataCdpContractHourly] BC     
    on BC.BmeStatementData_CdpId=CDPH.BmeStatementData_CdpId
    AND CDPH.BmeStatementData_NtdcDateTime=BC.BmeStatementData_NtdcDateTime
where BC.BmeStatementData_Year = @Year and BC.BmeStatementData_Month = @Month
and BC.BmeStatementData_ContractType_Id=1
GROUP by BC.BmeStatementData_BuyerPartyRegisteration_Id,BC.BmeStatementData_NtdcDateTime
) as cdp 
on MPH.BmeStatementData_PartyRegisteration_Id=cdp.BmeStatementData_BuyerPartyRegisteration_Id 
	and MPH.BmeStatementData_NtdcDateTime = cdp.BmeStatementData_NtdcDateTime;
----------------------------------------------------------------

--  2.1  Update Energy Traded Sold --Load Following 
------------------

------------------

UPDATE BmeStatementDataMpHourly set
BmeStatementData_EnergyTradedSold= ISNULL(BmeStatementDataMpHourly.BmeStatementData_EnergyTradedSold,0) + (ISNULL(cdp.BmeStatementData_EnergyTradedSold,0)*ISNULL((1 + BmeStatementData_UpliftTransmissionLosses),0))

	FROM BmeStatementDataMpHourly
	INNER JOIN (
select r.BmeStatementData_SellerPartyRegisteration_Id,r.BmeStatementData_NtdcDateTime,

SUM(ISNULL(r.Case1ActualEnergy,0)+ISNULL(r.Case2ActualEnergy,0)+ISNULL(r.Case3ActualEnergy,0)+ISNULL(r.Case4ActualEnergy,0)) as BmeStatementData_EnergyTradedSold from
  (select BC.BmeStatementData_SellerPartyRegisteration_Id

	,CDPH.BmeStatementData_NtdcDateTime,

    		CASE  WHEN  CDPH.BmeStatementData_ToPartyType_Code='SP' AND Exists(select top (1) 1 from MtPartyCategory as c
  inner join MtConnectedMeter as mm
  on c.MtPartyCategory_Id=mm.MtPartyCategory_Id
  inner join RuCDPDetail as cdp
  on  cdp.RuCDPDetail_Id=mm.MtCDPDetail_Id where MtPartyRegisteration_Id=BC.BmeStatementData_BuyerPartyRegisteration_Id and cdp.RuCDPDetail_CdpId=CDPH.BmeStatementData_CdpId and c.SrCategory_Code in ('BPC','PAKT','INTT','CSUP','GEN','CGEN'))
	THEN	
	ISNULL(CDPH.BmeStatementData_AdjustedEnergyImport,0) * BC.BmeStatementData_Percentage * 0.01
	end as Case1ActualEnergy,
	
	CASE WHEN CDPH.BmeStatementData_FromPartyType_Code='SP' AND Exists(select top (1) 1 from MtPartyCategory as c
  inner join MtConnectedMeter as mm
  on c.MtPartyCategory_Id=mm.MtPartyCategory_Id
  inner join RuCDPDetail as cdp
  on  cdp.RuCDPDetail_Id=mm.MtCDPDetail_Id where MtPartyRegisteration_Id=BC.BmeStatementData_BuyerPartyRegisteration_Id and cdp.RuCDPDetail_CdpId=CDPH.BmeStatementData_CdpId and c.SrCategory_Code in ('BPC','PAKT','INTT','CSUP','GEN','CGEN'))
	THEN
	ISNULL(CDPH.BmeStatementData_AdjustedEnergyExport,0) * BC.BmeStatementData_Percentage * 0.01
	end as Case2ActualEnergy,
	
	CASE WHEN  CDPH.BmeStatementData_FromPartyType_Code ='SP' and CDPH.BmeStatementData_FromPartyCategory_Code='DSP' AND Exists(select top (1) 1 from MtPartyCategory as c
  inner join MtConnectedMeter as mm
  on c.MtPartyCategory_Id=mm.MtPartyCategory_Id
  inner join RuCDPDetail as cdp
  on  cdp.RuCDPDetail_Id=mm.MtCDPDetail_Id where MtPartyRegisteration_Id=BC.BmeStatementData_BuyerPartyRegisteration_Id and cdp.RuCDPDetail_CdpId=CDPH.BmeStatementData_CdpId and c.SrCategory_Code='BSUP')
    
	and  exists (SELECT 1 FROM RuRelation_DSP_BSUP 
		WHERE RuRelation_DSP_BSUP_BSUP_Id=BC.BmeStatementData_BuyerPartyRegisteration_Id
		AND RuRelation_DSP_BSUP_DSP_Id=CDPH.BmeStatementData_FromPartyRegisteration_Id
		)
	
	THEN
     (ISNULL(CDPH.BmeStatementData_AdjustedEnergyImport,0) - ISNULL(CDPH.BmeStatementData_AdjustedEnergyExport,0)) * BC.BmeStatementData_Percentage * 0.01
 end as Case3ActualEnergy,
  
  CASE WHEN  CDPH.BmeStatementData_ToPartyType_Code ='SP' and CDPH.BmeStatementData_ToPartyCategory_Code='DSP' AND Exists(select top (1) 1 from MtPartyCategory as c
  inner join MtConnectedMeter as mm
  on c.MtPartyCategory_Id=mm.MtPartyCategory_Id
  inner join RuCDPDetail as cdp
  on  cdp.RuCDPDetail_Id=mm.MtCDPDetail_Id where MtPartyRegisteration_Id=BC.BmeStatementData_BuyerPartyRegisteration_Id and cdp.RuCDPDetail_CdpId=CDPH.BmeStatementData_CdpId and c.SrCategory_Code='BSUP')
  
	
	and  exists (SELECT 1 FROM RuRelation_DSP_BSUP 
		WHERE RuRelation_DSP_BSUP_BSUP_Id=BC.BmeStatementData_BuyerPartyRegisteration_Id
		AND RuRelation_DSP_BSUP_DSP_Id=CDPH.BmeStatementData_ToPartyRegisteration_Id
		)	
	THEN
	
    (ISNULL(CDPH.BmeStatementData_AdjustedEnergyExport,0)- ISNULL(CDPH.BmeStatementData_AdjustedEnergyImport,0)) * BC.BmeStatementData_Percentage * 0.01
	END as Case4ActualEnergy


       

	from BmeStatementDataCdpHourly CDPH	
	INNER JOIN [BmeStatementDataCdpContractHourly] BC     
    on BC.BmeStatementData_CdpId=CDPH.BmeStatementData_CdpId
    AND CDPH.BmeStatementData_NtdcDateTime=BC.BmeStatementData_NtdcDateTime

	
	where CDPH.BmeStatementData_Year = @Year and CDPH.BmeStatementData_Month = @Month
	and BC.BmeStatementData_ContractType_Id=2 and BC.BmeStatementData_ContractSubType_Id = 21
	) as r
	GROUP by r.BmeStatementData_SellerPartyRegisteration_Id, r.BmeStatementData_NtdcDateTime)  as cdp 
	on BmeStatementDataMpHourly.BmeStatementData_PartyRegisteration_Id=cdp.BmeStatementData_SellerPartyRegisteration_Id 
	and BmeStatementDataMpHourly.BmeStatementData_NtdcDateTime = cdp.BmeStatementData_NtdcDateTime;			
	


----  2.2  Update Energy Traded Bought --Load Following 


UPDATE BmeStatementDataMpHourly set
BmeStatementData_EnergyTradedBought= ISNULL(BmeStatementDataMpHourly.BmeStatementData_EnergyTradedBought,0) + (ISNULL(cdp.BmeStatementData_EnergyTradedBought,0)*ISNULL((1 + BmeStatementData_UpliftTransmissionLosses),0))

	FROM BmeStatementDataMpHourly
	INNER JOIN (
select r.BmeStatementData_BuyerPartyRegisteration_Id,r.BmeStatementData_NtdcDateTime,SUM(ISNULL(r.Case1ActualEnergy,0)+ISNULL(r.Case2ActualEnergy,0)+ISNULL(r.Case3ActualEnergy,0)+ISNULL(r.Case4ActualEnergy,0)) as BmeStatementData_EnergyTradedBought from
  (select BC.BmeStatementData_BuyerPartyRegisteration_Id

	,CDPH.BmeStatementData_NtdcDateTime,
	
	CASE  WHEN  CDPH.BmeStatementData_ToPartyType_Code='SP' AND Exists(select top (1) 1 from MtPartyCategory as c
  inner join MtConnectedMeter as mm
  on c.MtPartyCategory_Id=mm.MtPartyCategory_Id
  inner join RuCDPDetail as cdp
  on  cdp.RuCDPDetail_Id=mm.MtCDPDetail_Id where MtPartyRegisteration_Id=BC.BmeStatementData_BuyerPartyRegisteration_Id and cdp.RuCDPDetail_CdpId=CDPH.BmeStatementData_CdpId and c.SrCategory_Code in ('BPC','PAKT','INTT','CSUP','GEN','CGEN'))
	THEN	
	ISNULL(CDPH.BmeStatementData_AdjustedEnergyImport,0) * BC.BmeStatementData_Percentage * 0.01
	end as Case1ActualEnergy,
	
	CASE WHEN CDPH.BmeStatementData_FromPartyType_Code='SP' AND Exists(select top (1) 1 from MtPartyCategory as c
  inner join MtConnectedMeter as mm
  on c.MtPartyCategory_Id=mm.MtPartyCategory_Id
  inner join RuCDPDetail as cdp
  on  cdp.RuCDPDetail_Id=mm.MtCDPDetail_Id where MtPartyRegisteration_Id=BC.BmeStatementData_BuyerPartyRegisteration_Id and cdp.RuCDPDetail_CdpId=CDPH.BmeStatementData_CdpId and c.SrCategory_Code in ('BPC','PAKT','INTT','CSUP','GEN','CGEN'))
	THEN
	ISNULL(CDPH.BmeStatementData_AdjustedEnergyExport,0) * BC.BmeStatementData_Percentage * 0.01
	end as Case2ActualEnergy,
	
	CASE WHEN  CDPH.BmeStatementData_FromPartyType_Code ='SP' and CDPH.BmeStatementData_FromPartyCategory_Code='DSP' AND Exists(select top (1) 1 from MtPartyCategory as c
  inner join MtConnectedMeter as mm
  on c.MtPartyCategory_Id=mm.MtPartyCategory_Id
  inner join RuCDPDetail as cdp
  on  cdp.RuCDPDetail_Id=mm.MtCDPDetail_Id where MtPartyRegisteration_Id=BC.BmeStatementData_BuyerPartyRegisteration_Id and cdp.RuCDPDetail_CdpId=CDPH.BmeStatementData_CdpId and c.SrCategory_Code='BSUP')
    
	and  exists (SELECT 1 FROM RuRelation_DSP_BSUP 
		WHERE RuRelation_DSP_BSUP_BSUP_Id=BC.BmeStatementData_BuyerPartyRegisteration_Id
		AND RuRelation_DSP_BSUP_DSP_Id=CDPH.BmeStatementData_FromPartyRegisteration_Id
		)
	
	THEN
     (ISNULL(CDPH.BmeStatementData_AdjustedEnergyImport,0) - ISNULL(CDPH.BmeStatementData_AdjustedEnergyExport,0)) * BC.BmeStatementData_Percentage * 0.01
 end as Case3ActualEnergy,
  
  CASE WHEN  CDPH.BmeStatementData_ToPartyType_Code ='SP' and CDPH.BmeStatementData_ToPartyCategory_Code='DSP' AND Exists(select top (1) 1 from MtPartyCategory as c
  inner join MtConnectedMeter as mm
  on c.MtPartyCategory_Id=mm.MtPartyCategory_Id
  inner join RuCDPDetail as cdp
  on  cdp.RuCDPDetail_Id=mm.MtCDPDetail_Id where MtPartyRegisteration_Id=BC.BmeStatementData_BuyerPartyRegisteration_Id and cdp.RuCDPDetail_CdpId=CDPH.BmeStatementData_CdpId and c.SrCategory_Code='BSUP')
  
	
	and  exists (SELECT 1 FROM RuRelation_DSP_BSUP 
		WHERE RuRelation_DSP_BSUP_BSUP_Id=BC.BmeStatementData_BuyerPartyRegisteration_Id
		AND RuRelation_DSP_BSUP_DSP_Id=CDPH.BmeStatementData_ToPartyRegisteration_Id
		)	
	THEN
	
    (ISNULL(CDPH.BmeStatementData_AdjustedEnergyExport,0)- ISNULL(CDPH.BmeStatementData_AdjustedEnergyImport,0)) * BC.BmeStatementData_Percentage * 0.01
	END as Case4ActualEnergy


       
	from BmeStatementDataCdpHourly CDPH	
	INNER JOIN [BmeStatementDataCdpContractHourly] BC     
    on BC.BmeStatementData_CdpId=CDPH.BmeStatementData_CdpId
    AND CDPH.BmeStatementData_NtdcDateTime=BC.BmeStatementData_NtdcDateTime
	
	where CDPH.BmeStatementData_Year = @Year and CDPH.BmeStatementData_Month = @Month
	and BC.BmeStatementData_ContractType_Id=2 and BC.BmeStatementData_ContractSubType_Id = 21
	) as r
	GROUP by r.BmeStatementData_BuyerPartyRegisteration_Id, r.BmeStatementData_NtdcDateTime)  as cdp 
	on BmeStatementDataMpHourly.BmeStatementData_PartyRegisteration_Id=cdp.BmeStatementData_BuyerPartyRegisteration_Id 
	and BmeStatementDataMpHourly.BmeStatementData_NtdcDateTime = cdp.BmeStatementData_NtdcDateTime;	






--UPDATE BmeStatementDataMpHourly set BmeStatementData_EnergyTradedBought =ISNULL(MPH.BmeStatementData_EnergyTradedBought,0) + cdp.BmeStatementData_EnergyTradedBought
--FROM BmeStatementDataMpHourly MPH
--INNER JOIN (select OP.BmeStatementData_OwnerPartyRegisteration_Id,BC.BmeStatementData_NtdcDateTime , SUM(CDPH.BmeStatementData_ActualEnergy * BC.BmeStatementData_Percentage * 0.01) as BmeStatementData_EnergyTradedBought
--from BmeStatementDataCdpHourly CDPH
--	INNER JOIN  BmeStatementDataCdpOwnerParty  OP 
--	on OP.BmeStatementData_CdpId=CDPH.BmeStatementData_CdpId
--	AND OP.BmeStatementData_FromPartyRegisteration_Id = CDPH.BmeStatementData_FromPartyRegisteration_Id
--	and OP.BmeStatementData_ToPartyRegisteration_Id = CDPH.BmeStatementData_ToPartyRegisteration_Id	

--INNER JOIN [BmeStatementDataCdpContractHourly] BC 
--ON OP.BmeStatementData_OwnerPartyRegisteration_Id =BC.BmeStatementData_BuyerPartyRegisteration_Id
--AND BC.BmeStatementData_CdpId=CDPH.BmeStatementData_CdpId
--AND CDPH.BmeStatementData_NtdcDateTime=BC.BmeStatementData_NtdcDateTime
--where BC.BmeStatementData_Year = @Year and BC.BmeStatementData_Month = @Month
--and BC.BmeStatementData_ContractType_Id=1
--GROUP by OP.BmeStatementData_OwnerPartyRegisteration_Id,BC.BmeStatementData_NtdcDateTime
--) as cdp 
--on MPH.BmeStatementData_PartyRegisteration_Id=cdp.BmeStatementData_OwnerPartyRegisteration_Id 
--	and MPH.BmeStatementData_NtdcDateTime = cdp.BmeStatementData_NtdcDateTime;
----------------------------------------------------------------

-----------------------------------------------------------------
----  3.1  Update Energy Traded Sold --Fixed Quantity 
--------------------
UPDATE BmeStatementDataMpHourly set BmeStatementData_EnergyTradedSold = ISNULL(BmeStatementData_EnergyTradedSold,0)+ISNULL(cdp.BmeStatementData_ContractedQuantity,0)
FROM BmeStatementDataMpHourly MPH
INNER JOIN (select BC.BmeStatementData_SellerPartyRegisteration_Id,BmeStatementData_NtdcDateTime, Sum(BmeStatementData_ContractedQuantity) as BmeStatementData_ContractedQuantity	
from [BmeStatementDataCdpContractHourly] BC
where BC.BmeStatementData_Year = @Year and BC.BmeStatementData_Month = @Month
and BC.BmeStatementData_ContractType_Id=3
GROUP by BC.BmeStatementData_SellerPartyRegisteration_Id,BmeStatementData_NtdcDateTime	
) as cdp 
on MPH.BmeStatementData_PartyRegisteration_Id=cdp.BmeStatementData_SellerPartyRegisteration_Id 
	and MPH.BmeStatementData_NtdcDateTime = cdp.BmeStatementData_NtdcDateTime;

-----------------------------------------------------------------
----  3.2  Update Energy Traded Bought -- Fixed Quantity
UPDATE BmeStatementDataMpHourly set BmeStatementData_EnergyTradedBought =ISNULL(MPH.BmeStatementData_EnergyTradedBought,0) + ISNULL(cdp.BmeStatementData_ContractedQuantity,0)
FROM BmeStatementDataMpHourly MPH
INNER JOIN (select BC.BmeStatementData_BuyerPartyRegisteration_Id,BmeStatementData_NtdcDateTime, Sum(BmeStatementData_ContractedQuantity) as BmeStatementData_ContractedQuantity	
from [BmeStatementDataCdpContractHourly] BC
where BC.BmeStatementData_Year = @Year and BC.BmeStatementData_Month = @Month
and BC.BmeStatementData_ContractType_Id=3
GROUP by BC.BmeStatementData_BuyerPartyRegisteration_Id,BmeStatementData_NtdcDateTime	
) as cdp 
on MPH.BmeStatementData_PartyRegisteration_Id=cdp.BmeStatementData_BuyerPartyRegisteration_Id 
	and MPH.BmeStatementData_NtdcDateTime = cdp.BmeStatementData_NtdcDateTime;

--	---------------------------------- 


----  4.1  Update Energy Traded Sold --Customized
--UPDATE BmeStatementDataMpHourly set
--BmeStatementData_EnergyTradedSold=ISNULL(BmeStatementData_EnergyTradedSold,0)+

SELECT 
cdp.BmeStatementData_SellerPartyRegisteration_Id,
cdp.BmeStatementData_BuyerPartyRegisteration_Id,
cdp.BmeStatementData_ContractId,
 cdp.BmeStatementData_NtdcDateTime
,BmeStatementDataMpHourly.BmeStatementData_Hour
,BmeStatementDataMpHourly.BmeStatementData_Day
,ISNULL(

case when cdp.BmeStatementData_CapQuantity>0
THEN
	case when cdp.BmeStatementData_CapQuantity>cdp.BmeStatementData_ActualEnergy*ISNULL((1 + BmeStatementDataMpHourly.BmeStatementData_UpliftTransmissionLosses),0) then  cdp.BmeStatementData_ActualEnergy*ISNULL((1 + BmeStatementDataMpHourly.BmeStatementData_UpliftTransmissionLosses),0)
	ELSE cdp.BmeStatementData_CapQuantity end

ELSE

case when BmeStatementDataMpHourly.BmeStatementData_CAPLegacy>cdp.BmeStatementData_ActualEnergy*ISNULL((1 + BmeStatementDataMpHourly.BmeStatementData_UpliftTransmissionLosses),0) then  cdp.BmeStatementData_ActualEnergy*ISNULL((1 + BmeStatementDataMpHourly.BmeStatementData_UpliftTransmissionLosses),0)

ELSE BmeStatementDataMpHourly.BmeStatementData_CAPLegacy end
END
,0) as EnergyTradedSold
INTO #TempEnergyTradedSold
 FROM BmeStatementDataMpHourly
	INNER JOIN (
select r.BmeStatementData_SellerPartyRegisteration_Id,r.BmeStatementData_BuyerPartyRegisteration_Id,r.BmeStatementData_ContractId, r.BmeStatementData_NtdcDateTime,ISNULL(r.BmeStatementData_CapQuantity,0) as BmeStatementData_CapQuantity ,SUM(ISNULL(r.Case1ActualEnergy,0)+ISNULL(r.Case2ActualEnergy,0)+ISNULL(r.Case3ActualEnergy,0)+ISNULL(r.Case4ActualEnergy,0)) as BmeStatementData_ActualEnergy from
  (select BC.BmeStatementData_SellerPartyRegisteration_Id
        ,BC.BmeStatementData_BuyerPartyRegisteration_Id
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
    
	and  exists (SELECT 1 FROM RuRelation_DSP_BSUP 
		WHERE RuRelation_DSP_BSUP_BSUP_Id=BC.BmeStatementData_BuyerPartyRegisteration_Id
		AND RuRelation_DSP_BSUP_DSP_Id=CDPH.BmeStatementData_FromPartyRegisteration_Id
		)
	
	THEN
 ISNULL(CDPH.BmeStatementData_AdjustedEnergyImport,0) - ISNULL(CDPH.BmeStatementData_AdjustedEnergyExport,0)
 end as Case3ActualEnergy,
  
  CASE WHEN  CDPH.BmeStatementData_ToPartyType_Code ='SP' and CDPH.BmeStatementData_ToPartyCategory_Code='DSP' AND Exists(select top (1) 1 from MtPartyCategory as c
  inner join MtConnectedMeter as mm
  on c.MtPartyCategory_Id=mm.MtPartyCategory_Id
  inner join RuCDPDetail as cdp
  on  cdp.RuCDPDetail_Id=mm.MtCDPDetail_Id where MtPartyRegisteration_Id=BC.BmeStatementData_BuyerPartyRegisteration_Id and cdp.RuCDPDetail_CdpId=CDPH.BmeStatementData_CdpId and c.SrCategory_Code='BSUP')
  
	
	and  exists (SELECT 1 FROM RuRelation_DSP_BSUP 
		WHERE RuRelation_DSP_BSUP_BSUP_Id=BC.BmeStatementData_BuyerPartyRegisteration_Id
		AND RuRelation_DSP_BSUP_DSP_Id=CDPH.BmeStatementData_ToPartyRegisteration_Id
		)	
	THEN
	
    ISNULL(CDPH.BmeStatementData_AdjustedEnergyExport,0)- ISNULL(CDPH.BmeStatementData_AdjustedEnergyImport,0)
	END as Case4ActualEnergy


	from BmeStatementDataCdpHourly CDPH	
	INNER JOIN [BmeStatementDataCdpContractHourly] BC     
    on BC.BmeStatementData_CdpId=CDPH.BmeStatementData_CdpId
    AND CDPH.BmeStatementData_NtdcDateTime=BC.BmeStatementData_NtdcDateTime
	
	where CDPH.BmeStatementData_Year = @Year and CDPH.BmeStatementData_Month = @Month
	and BC.BmeStatementData_ContractType_Id=4
	) as r
	GROUP by r.BmeStatementData_SellerPartyRegisteration_Id, r.BmeStatementData_BuyerPartyRegisteration_Id,r.BmeStatementData_ContractId, r.BmeStatementData_NtdcDateTime,r.BmeStatementData_CapQuantity
    )  as cdp 
	on BmeStatementDataMpHourly.BmeStatementData_PartyRegisteration_Id=cdp.BmeStatementData_BuyerPartyRegisteration_Id 
	and BmeStatementDataMpHourly.BmeStatementData_NtdcDateTime = cdp.BmeStatementData_NtdcDateTime;		

		UPDATE BmeStatementDataMpHourly set
    BmeStatementData_EnergyTradedSold=ISNULL(BmeStatementData_EnergyTradedSold,0)+ISNULL(IMP.EnergyTradedSold,0)
	FROM BmeStatementDataMpHourly
	INNER JOIN (
	SELECT 
	ttb.BmeStatementData_SellerPartyRegisteration_Id,ttb.BmeStatementData_NtdcDateTime, SUM(ttb.EnergyTradedSold)  as EnergyTradedSold
	FROM #TempEnergyTradedSold   ttb
	GROUP BY ttb.BmeStatementData_SellerPartyRegisteration_Id,ttb.BmeStatementData_NtdcDateTime) as IMP ON
	BmeStatementDataMpHourly.BmeStatementData_PartyRegisteration_Id=IMP.BmeStatementData_SellerPartyRegisteration_Id 
	and IMP.BmeStatementData_NtdcDateTime=BmeStatementDataMpHourly.BmeStatementData_NtdcDateTime;

----  4.2  Update Energy Traded Bought --Customized

    UPDATE BmeStatementDataMpHourly set
    BmeStatementData_EnergyTradedBought=ISNULL(BmeStatementData_EnergyTradedBought,0)+ISNULL(IMP.EnergyTradedSold,0)
	FROM BmeStatementDataMpHourly
	INNER JOIN (
	SELECT 
	ttb.BmeStatementData_BuyerPartyRegisteration_Id,ttb.BmeStatementData_NtdcDateTime, SUM(ttb.EnergyTradedSold)  as EnergyTradedSold
	FROM #TempEnergyTradedSold   ttb
	GROUP BY ttb.BmeStatementData_BuyerPartyRegisteration_Id,ttb.BmeStatementData_NtdcDateTime) as IMP ON
	BmeStatementDataMpHourly.BmeStatementData_PartyRegisteration_Id=IMP.BmeStatementData_BuyerPartyRegisteration_Id 
	and IMP.BmeStatementData_NtdcDateTime=BmeStatementDataMpHourly.BmeStatementData_NtdcDateTime;

	
-----------------------------------------------------



-- load following 22  meter

	------------------

UPDATE BmeStatementDataMpHourly set
BmeStatementData_EnergyTradedSold= ISNULL(BmeStatementDataMpHourly.BmeStatementData_EnergyTradedSold,0) + (ISNULL(cdp.BmeStatementData_EnergyTradedSold,0))

	FROM BmeStatementDataMpHourly
	INNER JOIN (
select r.BmeStatementData_SellerPartyRegisteration_Id,r.BmeStatementData_NtdcDateTime,

SUM(ISNULL(r.BmeStatementData_IncEnergyImport,0)) as BmeStatementData_EnergyTradedSold from
  (select BC.BmeStatementData_SellerPartyRegisteration_Id
     ,CDPH.BmeStatementData_IncEnergyImport
	,CDPH.BmeStatementData_NtdcDateTime
			

	from BmeStatementDataCdpHourly CDPH	
	INNER JOIN [BmeStatementDataCdpContractHourly] BC     
    on BC.BmeStatementData_CdpId=CDPH.BmeStatementData_CdpId
    AND CDPH.BmeStatementData_NtdcDateTime=BC.BmeStatementData_NtdcDateTime

	
	where CDPH.BmeStatementData_Year = @Year and CDPH.BmeStatementData_Month = @Month
	and BC.BmeStatementData_ContractType_Id=2 and BC.BmeStatementData_ContractSubType_Id = 22
	) as r
	GROUP by r.BmeStatementData_SellerPartyRegisteration_Id, r.BmeStatementData_NtdcDateTime)  as cdp 
	on BmeStatementDataMpHourly.BmeStatementData_PartyRegisteration_Id=cdp.BmeStatementData_SellerPartyRegisteration_Id 
	and BmeStatementDataMpHourly.BmeStatementData_NtdcDateTime = cdp.BmeStatementData_NtdcDateTime;			
	
-- load following 22  meter

	-------------------

	UPDATE BmeStatementDataMpHourly set
BmeStatementData_EnergyTradedBought= ISNULL(BmeStatementDataMpHourly.BmeStatementData_EnergyTradedBought,0) + (ISNULL(cdp.BmeStatementData_EnergyTradedBought,0))
	FROM BmeStatementDataMpHourly
	INNER JOIN (
select r.BmeStatementData_BuyerPartyRegisteration_Id,r.BmeStatementData_NtdcDateTime
,SUM(ISNULL(r.BmeStatementData_IncEnergyImport,0)) as BmeStatementData_EnergyTradedBought from
  (select BC.BmeStatementData_BuyerPartyRegisteration_Id
    ,CDPH.BmeStatementData_IncEnergyImport
	,CDPH.BmeStatementData_NtdcDateTime
	
	from BmeStatementDataCdpHourly CDPH	
	INNER JOIN [BmeStatementDataCdpContractHourly] BC     
    on BC.BmeStatementData_CdpId=CDPH.BmeStatementData_CdpId
    AND CDPH.BmeStatementData_NtdcDateTime=BC.BmeStatementData_NtdcDateTime
	
	where CDPH.BmeStatementData_Year = @Year and CDPH.BmeStatementData_Month = @Month
	and BC.BmeStatementData_ContractType_Id=2 and BC.BmeStatementData_ContractSubType_Id = 22
	) as r
	GROUP by r.BmeStatementData_BuyerPartyRegisteration_Id, r.BmeStatementData_NtdcDateTime)  as cdp 
	on BmeStatementDataMpHourly.BmeStatementData_PartyRegisteration_Id=cdp.BmeStatementData_BuyerPartyRegisteration_Id 
	and BmeStatementDataMpHourly.BmeStatementData_NtdcDateTime = cdp.BmeStatementData_NtdcDateTime;


-- load following 23 adjusted
--------


UPDATE BmeStatementDataMpHourly set
BmeStatementData_EnergyTradedSold= ISNULL(BmeStatementDataMpHourly.BmeStatementData_EnergyTradedSold,0) + (ISNULL(cdp.BmeStatementData_EnergyTradedSold,0))

	FROM BmeStatementDataMpHourly
	INNER JOIN (
select r.BmeStatementData_SellerPartyRegisteration_Id,r.BmeStatementData_NtdcDateTime,

SUM(ISNULL(r.BmeStatementData_AdjustedEnergyImport,0)) as BmeStatementData_EnergyTradedSold from
  (select BC.BmeStatementData_SellerPartyRegisteration_Id
     ,CDPH.BmeStatementData_AdjustedEnergyImport
	,CDPH.BmeStatementData_NtdcDateTime
			

	from BmeStatementDataCdpHourly CDPH	
	INNER JOIN [BmeStatementDataCdpContractHourly] BC     
    on BC.BmeStatementData_CdpId=CDPH.BmeStatementData_CdpId
    AND CDPH.BmeStatementData_NtdcDateTime=BC.BmeStatementData_NtdcDateTime

	
	where CDPH.BmeStatementData_Year = @Year and CDPH.BmeStatementData_Month = @Month
	and BC.BmeStatementData_ContractType_Id=2 and BC.BmeStatementData_ContractSubType_Id = 23
	) as r
	GROUP by r.BmeStatementData_SellerPartyRegisteration_Id, r.BmeStatementData_NtdcDateTime)  as cdp 
	on BmeStatementDataMpHourly.BmeStatementData_PartyRegisteration_Id=cdp.BmeStatementData_SellerPartyRegisteration_Id 
	and BmeStatementDataMpHourly.BmeStatementData_NtdcDateTime = cdp.BmeStatementData_NtdcDateTime;	


	

--------

-- load following 23  adjusted


	UPDATE BmeStatementDataMpHourly set
BmeStatementData_EnergyTradedBought= ISNULL(BmeStatementDataMpHourly.BmeStatementData_EnergyTradedBought,0) + (ISNULL(cdp.BmeStatementData_EnergyTradedBought,0))
	FROM BmeStatementDataMpHourly
	INNER JOIN (
select r.BmeStatementData_BuyerPartyRegisteration_Id,r.BmeStatementData_NtdcDateTime
,SUM(ISNULL(r.BmeStatementData_AdjustedEnergyImport,0)) as BmeStatementData_EnergyTradedBought from
  (select BC.BmeStatementData_BuyerPartyRegisteration_Id
    ,CDPH.BmeStatementData_AdjustedEnergyImport
	,CDPH.BmeStatementData_NtdcDateTime
	


	from BmeStatementDataCdpHourly CDPH	
	INNER JOIN [BmeStatementDataCdpContractHourly] BC     
    on BC.BmeStatementData_CdpId=CDPH.BmeStatementData_CdpId
    AND CDPH.BmeStatementData_NtdcDateTime=BC.BmeStatementData_NtdcDateTime
	
	where CDPH.BmeStatementData_Year = @Year and CDPH.BmeStatementData_Month = @Month
	and BC.BmeStatementData_ContractType_Id=2 and BC.BmeStatementData_ContractSubType_Id = 23
	) as r
	GROUP by r.BmeStatementData_BuyerPartyRegisteration_Id, r.BmeStatementData_NtdcDateTime)  as cdp 
	on BmeStatementDataMpHourly.BmeStatementData_PartyRegisteration_Id=cdp.BmeStatementData_BuyerPartyRegisteration_Id 
	and BmeStatementDataMpHourly.BmeStatementData_NtdcDateTime = cdp.BmeStatementData_NtdcDateTime;








UPDATE BmeStatementDataMpHourly set BmeStatementData_EnergyTraded =ISNULL(BmeStatementData_EnergyTradedBought,0) - ISNULL(BmeStatementData_EnergyTradedSold,0) 
where BmeStatementData_Year = @Year and BmeStatementData_Month = @Month




















-----------------------------------------------------------------
----   2.1   Update Energy Traded Sold --Generation Following 
--update MPH set MPH.BmeStatementData_EnergyTradedSold = ISNULL(BmeStatementData_EnergyTradedSold,0)+ (MPH.BmeStatementData_EnergySuppliedGenerated * BC.MtBilateralContract_Percentage * 0.01)
--FROM
--BmeStatementDataMpHourly MPH
--JOIN MtBilateralContract BC ON MPH.BmeStatementData_PartyRegisteration_Id=BC.MtBilateralContract_SellerMPId
--where BC.SrContractType_Id=1
--and MPH.BmeStatementData_Year=@Year and MPH.BmeStatementData_Month=@Month
--;

----   2.2  Update Energy Traded Bought -- Fixed Quantity
--update MPH set MPH.BmeStatementData_EnergyTradedBought= ISNULL(BmeStatementData_EnergyTradedBought,0)+ (
--			(select MP1.BmeStatementData_EnergySuppliedGenerated from BmeStatementDataMpHourly MP1 where MP1.BmeStatementData_PartyRegisteration_Id=BC.MtBilateralContract_SellerMPId and BC.MtBilateralContract_Hour=MP1.BmeStatementData_Hour and DatePart(Day,BC.MtBilateralContract_Date)=MP1.BmeStatementData_Day)
--	* BC.MtBilateralContract_Percentage * 0.01)
--FROM
--BmeStatementDataMpHourly MPH

--JOIN MtBilateralContract BC ON MPH.BmeStatementData_PartyRegisteration_Id=BC.MtBilateralContract_BuyerMPId
--where BC.SrContractType_Id=1
--and MPH.BmeStatementData_Year=@Year and MPH.BmeStatementData_Month=@Month
--;

-----------------------------------------------------------------
----   3.1   Update Energy Traded Sold --Generation Following 
--update MPH set MPH.BmeStatementData_EnergyTradedSold = ISNULL(BmeStatementData_EnergyTradedSold,0)+ (
--			(select MP1.BmeStatementData_EnergySuppliedGenerated from BmeStatementDataMpHourly MP1 where MP1.BmeStatementData_PartyRegisteration_Id=BC.MtBilateralContract_BuyerMPId and BC.MtBilateralContract_Hour=MP1.BmeStatementData_Hour and DatePart(Day,BC.MtBilateralContract_Date)=MP1.BmeStatementData_Day)
--			* BC.MtBilateralContract_Percentage * 0.01)
--FROM
--BmeStatementDataMpHourly MPH
--JOIN MtBilateralContract BC ON MPH.BmeStatementData_PartyRegisteration_Id=BC.MtBilateralContract_SellerMPId
--where BC.SrContractType_Id=2
--and MPH.BmeStatementData_Year=@Year and MPH.BmeStatementData_Month=@Month
--;

----   3.2  Update Energy Traded Bought -- Fixed Quantity
--update MPH set MPH.BmeStatementData_EnergyTradedBought = ISNULL(BmeStatementData_EnergyTradedBought,0)+ (
--			MPH.BmeStatementData_EnergySuppliedGenerated * BC.MtBilateralContract_Percentage * 0.01)
--FROM
--BmeStatementDataMpHourly MPH

--JOIN MtBilateralContract BC ON MPH.BmeStatementData_PartyRegisteration_Id=BC.MtBilateralContract_BuyerMPId
--where BC.SrContractType_Id=2
--and MPH.BmeStatementData_Year=@Year and MPH.BmeStatementData_Month=@Month
;
END
