/****** Object:  Procedure [dbo].[BME_Step7APerform_old2]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[BME_Step7APerform_old2]
@Year int,
@Month int
,@StatementProcessId decimal(18,0) = null
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

	   BmeStatementData_NtdcDateTime
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
	 and   MtSOFileMaster_Id=dbo.GetMtSoFileMasterId(@StatementProcessId, 8)

----------------------------------------------
INSERT INTO [dbo].[BmeStatementDataMpContractHourly]
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
      ,[BmeStatementData_ContractType]     
      ,[BmeStatementData_ContractedQuantity]
      ,[BmeStatementData_CapQuantity]
      ,[BmeStatementData_AncillaryServices]      
      ,[BmeStatementData_Percentage]
      ,[BmeStatementData_ContractType_Id]
	  ,BmeStatementData_ContractSubType_Id
       )
     	select distinct 

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
      ,[BmeStatementData_ContractType]     
      ,[BmeStatementData_ContractedQuantity]
      ,[BmeStatementData_CapQuantity]
      ,[BmeStatementData_AncillaryServices]      
      ,[BmeStatementData_Percentage]
      ,[BmeStatementData_ContractType_Id]
	  ,BmeStatementData_ContractSubType_Id
	  from dbo.BmeStatementDataCdpContractHourly
	 WHERE BmeStatementData_Year= @Year and BmeStatementData_Month = @Month


	 ---------------------------------------------------------------
--  1.1  Update Energy Traded Sold --Generation Following 
------------------
UPDATE BmeStatementDataMpContractHourly set
 BmeStatementData_EnergyTradedSold = ET.EnergyTraded,
 BmeStatementData_EnergyTradedBought = ET.EnergyTraded
from BmeStatementDataMpContractHourly C INNER JOIN (
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
		)  AS EnergyTraded
		
	from BmeStatementDataCdpHourly CDPH	
	INNER JOIN [BmeStatementDataCdpContractHourly] BC     
    on BC.BmeStatementData_CdpId=CDPH.BmeStatementData_CdpId
    AND CDPH.BmeStatementData_NtdcDateTime=BC.BmeStatementData_NtdcDateTime

where BC.BmeStatementData_Year = @Year and BC.BmeStatementData_Month =  @Month
and BC.BmeStatementData_ContractType_Id=1
GROUP BY BC.BmeStatementData_ContractId,BC.BmeStatementData_NtdcDateTime
) as ET 
ON C.BmeStatementData_ContractId=ET.BmeStatementData_ContractId AND C.BmeStatementData_NtdcDateTime=ET.BmeStatementData_NtdcDateTime
;
 
------------------
	-------------------------------------
----------------------------------------------------------------

--  2.1  Update Energy Traded Sold --Load Following 
------------------

UPDATE BmeStatementDataMpContractHourly set
 BmeStatementData_EnergyTradedSold = ET.EnergyTraded,
 BmeStatementData_EnergyTradedBought = ET.EnergyTraded
from BmeStatementDataMpContractHourly C INNER JOIN 
(SELECT SE.BmeStatementData_ContractId,SE.BmeStatementData_NtdcDateTime,SUM( (SE.ActualEnergy*ISNULL((1 + H.BmeStatementData_UpliftTransmissionLosses),0)) *SE.BmeStatementData_Percentage*.01) AS EnergyTraded FROM 
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
    
	and  exists (SELECT 1 FROM RuRelation_DSP_BSUP 
		WHERE RuRelation_DSP_BSUP_BSUP_Id=BC.BmeStatementData_BuyerPartyRegisteration_Id
		AND RuRelation_DSP_BSUP_DSP_Id=CDPH.BmeStatementData_FromPartyRegisteration_Id
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
  
	
	and  exists (SELECT 1 FROM RuRelation_DSP_BSUP 
		WHERE RuRelation_DSP_BSUP_BSUP_Id=BC.BmeStatementData_BuyerPartyRegisteration_Id
		AND RuRelation_DSP_BSUP_DSP_Id=CDPH.BmeStatementData_ToPartyRegisteration_Id
		)	
	THEN	
    ISNULL(CDPH.BmeStatementData_AdjustedEnergyExport,0)- ISNULL(CDPH.BmeStatementData_AdjustedEnergyImport,0)
	END,0) --as Case4ActualEnergy
    ) AS ActualEnergy

		
	from BmeStatementDataCdpHourly CDPH	
	INNER JOIN [BmeStatementDataCdpContractHourly] BC     
    on BC.BmeStatementData_CdpId=CDPH.BmeStatementData_CdpId
    AND CDPH.BmeStatementData_NtdcDateTime=BC.BmeStatementData_NtdcDateTime
    
where BC.BmeStatementData_Year = @Year and BC.BmeStatementData_Month =  @Month
and BC.BmeStatementData_ContractType_Id=2 and BC.BmeStatementData_ContractSubType_Id = 21
) as SE 
INNER JOIN BmeStatementDataHourly H
    on SE.BmeStatementData_NtdcDateTime=H.BmeStatementData_NtdcDateTime
GROUP BY SE.BmeStatementData_ContractId,SE.BmeStatementData_NtdcDateTime
) AS ET
ON C.BmeStatementData_ContractId=ET.BmeStatementData_ContractId AND C.BmeStatementData_NtdcDateTime=ET.BmeStatementData_NtdcDateTime
;
-----------------------------------------------------------------
----  3.1  Update Energy Traded Sold --Fixed Quantity 
--------------------

UPDATE BmeStatementDataMpContractHourly set
 BmeStatementData_EnergyTradedSold = ET.EnergyTraded,
 BmeStatementData_EnergyTradedBought = ET.EnergyTraded
from BmeStatementDataMpContractHourly C INNER JOIN (
    SELECT BC.BmeStatementData_ContractId,BC.BmeStatementData_NtdcDateTime,
	   	SUM(ISNULL(BmeStatementData_ContractedQuantity ,0)) AS EnergyTraded
		
	from BmeStatementDataCdpHourly CDPH	
	INNER JOIN [BmeStatementDataCdpContractHourly] BC     
    on BC.BmeStatementData_CdpId=CDPH.BmeStatementData_CdpId
    AND CDPH.BmeStatementData_NtdcDateTime=BC.BmeStatementData_NtdcDateTime

where BC.BmeStatementData_Year = @Year and BC.BmeStatementData_Month =  @Month
and BC.BmeStatementData_ContractType_Id=3
GROUP BY BC.BmeStatementData_ContractId,BC.BmeStatementData_NtdcDateTime
) AS ET 
ON C.BmeStatementData_ContractId=ET.BmeStatementData_ContractId AND C.BmeStatementData_NtdcDateTime=ET.BmeStatementData_NtdcDateTime
;
--	---------------------------------- 

----  4.1  Update Energy Traded Sold --Customized

SELECT 
con.BmeStatementData_ContractId,
 con.BmeStatementData_NtdcDateTime
,BmeStatementDataMpHourly.BmeStatementData_Hour
,BmeStatementDataMpHourly.BmeStatementData_Day
,ISNULL(

case when con.BmeStatementData_CapQuantity>0
THEN
	case when con.BmeStatementData_CapQuantity>con.BmeStatementData_ActualEnergy*ISNULL((1 + BmeStatementDataMpHourly.BmeStatementData_UpliftTransmissionLosses),0) 
    then  con.BmeStatementData_ActualEnergy*ISNULL((1 + BmeStatementDataMpHourly.BmeStatementData_UpliftTransmissionLosses),0)
	ELSE con.BmeStatementData_CapQuantity end

ELSE

case when BmeStatementDataMpHourly.BmeStatementData_CAPLegacy>con.BmeStatementData_ActualEnergy*ISNULL((1 + BmeStatementDataMpHourly.BmeStatementData_UpliftTransmissionLosses),0) 
then  con.BmeStatementData_ActualEnergy*ISNULL((1 + BmeStatementDataMpHourly.BmeStatementData_UpliftTransmissionLosses),0)

ELSE BmeStatementDataMpHourly.BmeStatementData_CAPLegacy end
END
,0) as EnergyTradedSold
INTO #TempEnergyTradedSold
 FROM BmeStatementDataMpHourly
	INNER JOIN (
select r.BmeStatementData_BuyerPartyRegisteration_Id,r.BmeStatementData_ContractId, r.BmeStatementData_NtdcDateTime,Max(r.BmeStatementData_CapQuantity) as BmeStatementData_CapQuantity ,SUM(ISNULL(r.Case1ActualEnergy,0)+ISNULL(r.Case2ActualEnergy,0)+ISNULL(r.Case3ActualEnergy,0)+ISNULL(r.Case4ActualEnergy,0)) as BmeStatementData_ActualEnergy from
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
	and BC.BmeStatementData_ContractType_Id=4 and BC.BmeStatementData_ContractSubType_Id=41
	) as r
	GROUP by r.BmeStatementData_BuyerPartyRegisteration_Id,r.BmeStatementData_ContractId, r.BmeStatementData_NtdcDateTime
    )  as con 
	on BmeStatementDataMpHourly.BmeStatementData_PartyRegisteration_Id=con.BmeStatementData_BuyerPartyRegisteration_Id 
	and BmeStatementDataMpHourly.BmeStatementData_NtdcDateTime = con.BmeStatementData_NtdcDateTime
    ;		

-------------------------------------
	UPDATE BmeStatementDataMpContractHourly set
    BmeStatementData_EnergyTradedSold = ISNULL(IMP.EnergyTradedSold,0),
    BmeStatementData_EnergyTradedBought = ISNULL(IMP.EnergyTradedSold,0)
	FROM BmeStatementDataMpContractHourly As C
	INNER JOIN #TempEnergyTradedSold as IMP ON
	C.BmeStatementData_ContractId=IMP.BmeStatementData_ContractId 
	and C.BmeStatementData_NtdcDateTime=IMP.BmeStatementData_NtdcDateTime
    where C.BmeStatementData_Year = @Year and C.BmeStatementData_Month = @Month;

-------------------------------------------


    -- Customized - Load Following Meterd  42

	------------------
    SELECT 
con.BmeStatementData_ContractId,
 con.BmeStatementData_NtdcDateTime
,BmeStatementDataMpHourly.BmeStatementData_Hour
,BmeStatementDataMpHourly.BmeStatementData_Day
,ISNULL(

case when con.BmeStatementData_CapQuantity>0
THEN
	case when con.BmeStatementData_CapQuantity>con.EnergyTradedSold
    then  con.EnergyTradedSold
	ELSE con.BmeStatementData_CapQuantity end

ELSE

case when BmeStatementDataMpHourly.BmeStatementData_CAPLegacy>con.EnergyTradedSold 
then  con.EnergyTradedSold

ELSE BmeStatementDataMpHourly.BmeStatementData_CAPLegacy end
END
,0) as EnergyTradedSold
INTO #TempEnergyTradedSold42
 FROM BmeStatementDataMpHourly
	INNER JOIN (	
	select BC.BmeStatementData_BuyerPartyRegisteration_Id,BC.BmeStatementData_ContractId,BC.BmeStatementData_NtdcDateTime,
    Max(BC.BmeStatementData_CapQuantity) as BmeStatementData_CapQuantity
     ,SUM(ISNULL(CDPH.BmeStatementData_IncEnergyExport,0)) as EnergyTradedSold 
				
	from BmeStatementDataCdpHourly CDPH	
	INNER JOIN [BmeStatementDataCdpContractHourly] BC     
    on BC.BmeStatementData_CdpId=CDPH.BmeStatementData_CdpId
    AND CDPH.BmeStatementData_NtdcDateTime=BC.BmeStatementData_NtdcDateTime

	where CDPH.BmeStatementData_Year = @Year and CDPH.BmeStatementData_Month = @Month
	and BC.BmeStatementData_ContractType_Id=4 and BC.BmeStatementData_ContractSubType_Id = 42

    GROUP by BC.BmeStatementData_BuyerPartyRegisteration_Id,BC.BmeStatementData_ContractId,BC.BmeStatementData_NtdcDateTime
	) as con 
	on BmeStatementDataMpHourly.BmeStatementData_PartyRegisteration_Id=con.BmeStatementData_BuyerPartyRegisteration_Id 
	and BmeStatementDataMpHourly.BmeStatementData_NtdcDateTime = con.BmeStatementData_NtdcDateTime
    ;		

-------------------------------------
	UPDATE BmeStatementDataMpContractHourly set
    BmeStatementData_EnergyTradedSold = ISNULL(IMP.EnergyTradedSold,0),
    BmeStatementData_EnergyTradedBought = ISNULL(IMP.EnergyTradedSold,0)
	FROM BmeStatementDataMpContractHourly As C
	INNER JOIN #TempEnergyTradedSold42 as IMP ON
	C.BmeStatementData_ContractId=IMP.BmeStatementData_ContractId 
	and C.BmeStatementData_NtdcDateTime=IMP.BmeStatementData_NtdcDateTime
    where C.BmeStatementData_Year = @Year and C.BmeStatementData_Month = @Month;




-- load following 22  meter

	------------------

	UPDATE BmeStatementDataMpContractHourly set
    BmeStatementData_EnergyTradedSold = ISNULL(ET.EnergyTradedSold,0),
    BmeStatementData_EnergyTradedBought = ISNULL(ET.EnergyTradedSold,0)
	FROM BmeStatementDataMpContractHourly As C
	INNER JOIN 
  (select BC.BmeStatementData_ContractId,BC.BmeStatementData_NtdcDateTime
     ,SUM(ISNULL(CDPH.BmeStatementData_IncEnergyImport,0)) as EnergyTradedSold 
				
	from BmeStatementDataCdpHourly CDPH	
	INNER JOIN [BmeStatementDataCdpContractHourly] BC     
    on BC.BmeStatementData_CdpId=CDPH.BmeStatementData_CdpId
    AND CDPH.BmeStatementData_NtdcDateTime=BC.BmeStatementData_NtdcDateTime

	where CDPH.BmeStatementData_Year = @Year and CDPH.BmeStatementData_Month = @Month
	and BC.BmeStatementData_ContractType_Id=2 and BC.BmeStatementData_ContractSubType_Id = 22

    GROUP by BC.BmeStatementData_ContractId,BC.BmeStatementData_NtdcDateTime
	) as ET	
	on C.BmeStatementData_ContractId=ET.BmeStatementData_ContractId 
	and C.BmeStatementData_NtdcDateTime = ET.BmeStatementData_NtdcDateTime    
    ;		


-- load following 23 adjusted
--------

UPDATE BmeStatementDataMpContractHourly set
    BmeStatementData_EnergyTradedSold = ISNULL(ET.EnergyTradedSold,0),
    BmeStatementData_EnergyTradedBought = ISNULL(ET.EnergyTradedSold,0)
	FROM BmeStatementDataMpContractHourly As C
	INNER JOIN 
  (select BC.BmeStatementData_ContractId,BC.BmeStatementData_NtdcDateTime
     ,SUM(ISNULL(CDPH.BmeStatementData_AdjustedEnergyImport,0)) as EnergyTradedSold 
				
	from BmeStatementDataCdpHourly CDPH	
	INNER JOIN [BmeStatementDataCdpContractHourly] BC     
    on BC.BmeStatementData_CdpId=CDPH.BmeStatementData_CdpId
    AND CDPH.BmeStatementData_NtdcDateTime=BC.BmeStatementData_NtdcDateTime

	where CDPH.BmeStatementData_Year = @Year and CDPH.BmeStatementData_Month = @Month
	and BC.BmeStatementData_ContractType_Id=2 and BC.BmeStatementData_ContractSubType_Id = 23

    GROUP by BC.BmeStatementData_ContractId,BC.BmeStatementData_NtdcDateTime
	) as ET	
	on C.BmeStatementData_ContractId=ET.BmeStatementData_ContractId 
	and C.BmeStatementData_NtdcDateTime = ET.BmeStatementData_NtdcDateTime    
    ;		
--------------------------


------- Update MP EnergyTraded----------------------

    UPDATE BmeStatementDataMpHourly set
    BmeStatementData_EnergyTradedSold = ISNULL(IMP.EnergyTradedSold,0)
	FROM BmeStatementDataMpHourly MH 
	INNER JOIN (
	SELECT 
	C.BmeStatementData_SellerPartyRegisteration_Id,C.BmeStatementData_NtdcDateTime, SUM(C.BmeStatementData_EnergyTradedSold)  as EnergyTradedSold
	FROM BmeStatementDataMpContractHourly C
    where C.BmeStatementData_Year = @Year and C.BmeStatementData_Month = @Month
	GROUP BY C.BmeStatementData_SellerPartyRegisteration_Id,C.BmeStatementData_NtdcDateTime) as IMP ON
	MH.BmeStatementData_PartyRegisteration_Id=IMP.BmeStatementData_SellerPartyRegisteration_Id 
	and MH.BmeStatementData_NtdcDateTime=IMP.BmeStatementData_NtdcDateTime
    where MH.BmeStatementData_Year = @Year and MH.BmeStatementData_Month = @Month;
-------------------------------------------------
    UPDATE BmeStatementDataMpHourly set
    BmeStatementData_EnergyTradedBought = ISNULL(IMP.EnergyTradedBought,0)
	FROM BmeStatementDataMpHourly MH 
	INNER JOIN (
	SELECT 
	C.BmeStatementData_BuyerPartyRegisteration_Id,C.BmeStatementData_NtdcDateTime, SUM(C.BmeStatementData_EnergyTradedBought)  as EnergyTradedBought
	FROM BmeStatementDataMpContractHourly C
    where C.BmeStatementData_Year = @Year and C.BmeStatementData_Month = @Month
	GROUP BY C.BmeStatementData_BuyerPartyRegisteration_Id,C.BmeStatementData_NtdcDateTime) as IMP ON
	MH.BmeStatementData_PartyRegisteration_Id=IMP.BmeStatementData_BuyerPartyRegisteration_Id 
	and MH.BmeStatementData_NtdcDateTime=IMP.BmeStatementData_NtdcDateTime
    where MH.BmeStatementData_Year = @Year and MH.BmeStatementData_Month = @Month;


-----------------------------------------------------
    UPDATE BmeStatementDataMpHourly set
    BmeStatementData_EnergyTraded = ISNULL(BmeStatementData_EnergyTradedBought,0) - ISNULL(BmeStatementData_EnergyTradedSold,0)
    where BmeStatementData_Year = @Year and BmeStatementData_Month = @Month;




















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
