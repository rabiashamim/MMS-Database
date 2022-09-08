/****** Object:  Procedure [dbo].[BME_Step5Perform_old]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--[dbo].[BME_Step5Perform] 2021,11
CREATE PROCEDURE [dbo].[BME_Step5Perform_old](			 
			@Year int,
			@Month int
			,@StatementProcessId decimal(18,0) = null)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
     IF NOT EXISTS(SELECT TOP 1 BmeStatementData_Id FROM BmeStatementDataMpHourly 
     WHERE  [BmeStatementData_Year] = @Year and [BmeStatementData_Month] = @Month)
    BEGIN

	  


	----1----------Insert distinct party Ids in MpHourly Table
insert into BmeStatementDataMpHourly (
        [BmeStatementData_PartyRegisteration_Id]
		,[BmeStatementData_PartyName]
		--,[BmeStatementData_PartyCategory_Code]
        ,[BmeStatementData_PartyType_Code]
		,[BmeStatementData_NtdcDateTime]
      ,[BmeStatementData_Year]
      ,[BmeStatementData_Month]
      ,[BmeStatementData_Day]
      ,[BmeStatementData_Hour]
      ,[BmeStatementData_IsPowerPool] 
)
	select distinct 
		   BmeParty.[BmeStatementData_OwnerPartyRegisteration_Id]
           ,BmeParty.[BmeStatementData_OwnerPartyRegisteration_Name]
          -- ,BmeParty.[BmeStatementData_OwnerPartyCategory_Code]
           ,BmeParty.[BmeStatementData_OwnerPartyType_Code]
			,Cdp.[BmeStatementData_NtdcDateTime]
			,Cdp.[BmeStatementData_Year]
			,Cdp.[BmeStatementData_Month]
			,Cdp.[BmeStatementData_Day]
			,Cdp.[BmeStatementData_Hour]  
            ,Isnull(BmeParty.[BmeStatementData_IsPowerPool],0) 
	from  [dbo].[BmeStatementDataCdpOwnerParty] BmeParty
	inner join BmeStatementDataCdpHourly cdp
	on Cdp.BmeStatementData_CdpId=BmeParty.BmeStatementData_CdpId
	 WHERE  [BmeStatementData_Year] = @Year and [BmeStatementData_Month] = @Month



-------------------------------------------------------------------------
UPDATE BmeStatementDataMpHourly set BmeStatementData_ActualEnergy = IsNull(BmeStatementDataMpHourly.BmeStatementData_ActualEnergy,0)+cdp.BmeStatementData_ActualEnergy
	FROM BmeStatementDataMpHourly
	INNER JOIN (
select r.BmeStatementData_OwnerPartyRegisteration_Id,r.BmeStatementData_NtdcDateTime,SUM(ISNULL(r.Case1ActualEnergy,0)+ISNULL(r.Case2ActualEnergy,0)+ISNULL(r.Case3ActualEnergy,0)+ISNULL(r.Case4ActualEnergy,0)) as BmeStatementData_ActualEnergy from
  (select OP.BmeStatementData_OwnerPartyRegisteration_Id

	,BmeStatementData_NtdcDateTime,
	
		CASE  WHEN  CDPH.BmeStatementData_ToPartyType_Code='SP' AND Exists(select top (1) 1 from MtPartyCategory as c
  inner join MtConnectedMeter as mm
  on c.MtPartyCategory_Id=mm.MtPartyCategory_Id
  inner join RuCDPDetail as cdp
  on  cdp.RuCDPDetail_Id=mm.MtCDPDetail_Id where MtPartyRegisteration_Id=OP.BmeStatementData_OwnerPartyRegisteration_Id and cdp.RuCDPDetail_CdpId=CDPH.BmeStatementData_CdpId and c.SrCategory_Code in ('BPC','PAKT','INTT','CSUP','GEN','CGEN'))
	THEN	
	ISNULL(CDPH.BmeStatementData_AdjustedEnergyImport,0)
	end as Case1ActualEnergy,
	
	CASE WHEN CDPH.BmeStatementData_FromPartyType_Code='SP' AND Exists(select top (1) 1 from MtPartyCategory as c
  inner join MtConnectedMeter as mm
  on c.MtPartyCategory_Id=mm.MtPartyCategory_Id
  inner join RuCDPDetail as cdp
  on  cdp.RuCDPDetail_Id=mm.MtCDPDetail_Id where MtPartyRegisteration_Id=OP.BmeStatementData_OwnerPartyRegisteration_Id and cdp.RuCDPDetail_CdpId=CDPH.BmeStatementData_CdpId and c.SrCategory_Code in ('BPC','PAKT','INTT','CSUP','GEN','CGEN'))
	THEN
	ISNULL(CDPH.BmeStatementData_AdjustedEnergyExport,0)
	end as Case2ActualEnergy,
	
	CASE WHEN  CDPH.BmeStatementData_FromPartyType_Code ='SP' and CDPH.BmeStatementData_FromPartyCategory_Code='DSP' AND Exists(select top (1) 1 from MtPartyCategory as c
  inner join MtConnectedMeter as mm
  on c.MtPartyCategory_Id=mm.MtPartyCategory_Id
  inner join RuCDPDetail as cdp
  on  cdp.RuCDPDetail_Id=mm.MtCDPDetail_Id where MtPartyRegisteration_Id=OP.BmeStatementData_OwnerPartyRegisteration_Id and cdp.RuCDPDetail_CdpId=CDPH.BmeStatementData_CdpId and c.SrCategory_Code='BSUP')
    
	and  exists (SELECT 1 FROM RuRelation_DSP_BSUP 
		WHERE RuRelation_DSP_BSUP_BSUP_Id=OP.BmeStatementData_OwnerPartyRegisteration_Id
		AND RuRelation_DSP_BSUP_DSP_Id=CDPH.BmeStatementData_FromPartyRegisteration_Id
		)
	
	THEN
 ISNULL(CDPH.BmeStatementData_AdjustedEnergyImport,0) - ISNULL(CDPH.BmeStatementData_AdjustedEnergyExport,0)
 end as Case3ActualEnergy,
  
  CASE WHEN  CDPH.BmeStatementData_ToPartyType_Code ='SP' and CDPH.BmeStatementData_ToPartyCategory_Code='DSP' AND Exists(select top (1) 1 from MtPartyCategory as c
  inner join MtConnectedMeter as mm
  on c.MtPartyCategory_Id=mm.MtPartyCategory_Id
  inner join RuCDPDetail as cdp
  on  cdp.RuCDPDetail_Id=mm.MtCDPDetail_Id where MtPartyRegisteration_Id=OP.BmeStatementData_OwnerPartyRegisteration_Id and cdp.RuCDPDetail_CdpId=CDPH.BmeStatementData_CdpId and c.SrCategory_Code='BSUP')
  
	
	and  exists (SELECT 1 FROM RuRelation_DSP_BSUP 
		WHERE RuRelation_DSP_BSUP_BSUP_Id=OP.BmeStatementData_OwnerPartyRegisteration_Id
		AND RuRelation_DSP_BSUP_DSP_Id=CDPH.BmeStatementData_ToPartyRegisteration_Id
		)	
	THEN
	
    ISNULL(CDPH.BmeStatementData_AdjustedEnergyExport,0)- ISNULL(CDPH.BmeStatementData_AdjustedEnergyImport,0)
	END as Case4ActualEnergy

	from BmeStatementDataCdpHourly CDPH
	INNER JOIN  BmeStatementDataCdpOwnerParty  OP 
	ON OP.BmeStatementData_ToPartyRegisteration_Id = CDPH.BmeStatementData_ToPartyRegisteration_Id
	AND OP.BmeStatementData_CdpId=CDPH.BmeStatementData_CdpId  
	AND OP.BmeStatementData_FromPartyRegisteration_Id=CDPH.BmeStatementData_FromPartyRegisteration_Id
	where CDPH.BmeStatementData_Year = @Year and CDPH.BmeStatementData_Month = @Month
	) as r
	GROUP by r.BmeStatementData_OwnerPartyRegisteration_Id, r.BmeStatementData_NtdcDateTime)  as cdp 
	on BmeStatementDataMpHourly.BmeStatementData_PartyRegisteration_Id=cdp.BmeStatementData_OwnerPartyRegisteration_Id 
	and BmeStatementDataMpHourly.BmeStatementData_NtdcDateTime = cdp.BmeStatementData_NtdcDateTime;			
	
	SELECT 1;
    --RETURN @@ROWCOUNT;
    END       
END
