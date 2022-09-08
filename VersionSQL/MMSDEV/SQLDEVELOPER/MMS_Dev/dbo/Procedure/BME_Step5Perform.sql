/****** Object:  Procedure [dbo].[BME_Step5Perform]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--[dbo].[BME_Step5Perform] 2022,5,18
CREATE   Procedure [dbo].[BME_Step5Perform](			 
			@Year int,
			@Month int
			,@StatementProcessId decimal(18,0) = null)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
BEGIN TRY
	----1----------Insert distinct party Ids in MpHourly Table
IF NOT EXISTS(SELECT TOP 1 BmeStatementData_Id FROM [BmeStatementDataMpHourly] WHERE  BmeStatementData_Year=@Year and BmeStatementData_Month=@Month and BmeStatementData_StatementProcessId=@StatementProcessId)
BEGIN
	
	

	INSERT INTO [dbo].[BmeStatementDataMpHourly]
           (
               [BmeStatementData_StatementProcessId]
		    ,[BmeStatementData_PartyRegisteration_Id]
           ,[BmeStatementData_PartyName]          
           ,[BmeStatementData_PartyType_Code]	
		   ,[BmeStatementData_Year]
           ,[BmeStatementData_Month]
		    ,[BmeStatementData_Day]
		    ,[BmeStatementData_Hour]
		   ,[BmeStatementData_NtdcDateTime]         
		   ,[BmeStatementData_IsPowerPool]		   
		)
		select distinct 
            @StatementProcessId
		   ,BmeParty.[BmeStatementData_OwnerPartyRegisteration_Id]
           ,BmeParty.[BmeStatementData_OwnerPartyRegisteration_Name]
           ,BmeParty.[BmeStatementData_OwnerPartyType_Code]
			
			,Cdp.[BmeStatementData_Year]
			,Cdp.[BmeStatementData_Month]
			,Cdp.[BmeStatementData_Day]
			,Cdp.[BmeStatementData_Hour] 
			,Cdp.[BmeStatementData_NtdcDateTime]
            ,Isnull(BmeParty.[BmeStatementData_IsPowerPool],0) 		
			
	from  [dbo].[BmeStatementDataCdpOwnerParty] BmeParty
	inner join BmeStatementDataCdpHourly cdp
	on Cdp.BmeStatementData_CdpId=BmeParty.BmeStatementData_CdpId
    and Cdp.BmeStatementData_StatementProcessId=BmeParty.BmeStatementData_StatementProcessId
	 WHERE  Cdp.BmeStatementData_Year=@Year and Cdp.BmeStatementData_Month=@Month and Cdp.BmeStatementData_StatementProcessId=@StatementProcessId AND
	  BmeParty.BmeStatementData_StatementProcessId=@StatementProcessId;
	    	/**************************		Temp Table for Generators Information ********************************/
	/*****************************************************************************************************/
	select DISTINCT cdp.RuCDPDetail_CdpId,
g.MtGenerator_Name 
,g.MtGenerator_Id
,gu.MtGenerationUnit_Id
INTO #tempCdpGen
FROM MtGenerator g
inner join MtGenerationUnit gu on gu.MtGenerator_Id=g.MtGenerator_Id
inner JOIN MtConnectedMeter mcm on mcm.MtConnectedMeter_UnitId=gu.MtGenerationUnit_Id
inner join RuCDPDetail cdp on cdp.RuCDPDetail_Id=mcm.MtCDPDetail_Id
where isnull( g.MtGenerator_IsDeleted,0)=0
and isnull(gu.MtGenerationUnit_IsDeleted,0)=0
and isnull(mcm.MtConnectedMeter_isDeleted,0)=0
AND ISNULL(g.isDeleted,0)=0;

	/**************************  Except power pool ***************************************************************************/
	--1 mp wise actual energy case 1
	/*****************************************************************************************************/

WITH ActualEnergy_CTE
AS
(
select r.BmeStatementData_OwnerPartyRegisteration_Id,r.BmeStatementData_NtdcDateTime

,SUM(ISNULL(r.Case1ActualEnergy,0)+ISNULL(r.Case2ActualEnergy,0)+ISNULL(r.Case3ActualEnergy,0)+ISNULL(r.Case4ActualEnergy,0)) 
as BmeStatementData_ActualEnergy 
,SUM(ISNULL(r.Case1ActualEnergy_Metered,0)+ISNULL(r.Case2ActualEnergy_Metered,0)+ISNULL(r.Case3ActualEnergy_Metered,0)+ISNULL(r.Case4ActualEnergy_Metered,0)) 
as BmeStatementData_ActualEnergy_Metered 
from
  (select OP.BmeStatementData_OwnerPartyRegisteration_Id

	,BmeStatementData_NtdcDateTime,

	/*********************
	CASE 1 Adjusted
	*********************/
		CASE  WHEN  CDPH.BmeStatementData_ToPartyType_Code='SP'
		AND OP.BmeStatementData_OwnerPartyCategory_Code in ('BPC','PAKT','INTT','CSUP','GEN','CGEN','EGEN','EBPC')  

	THEN	
	 ISNULL(CDPH.BmeStatementData_AdjustedEnergyImport,0) 
	
	end as Case1ActualEnergy,
	/*********************
	CASE 1 Metered
	*********************/
		CASE  WHEN  CDPH.BmeStatementData_ToPartyType_Code='SP'
		AND OP.BmeStatementData_OwnerPartyCategory_Code in ('BPC','PAKT','INTT','CSUP','GEN','CGEN','EGEN','EBPC')  

	THEN	
	 ISNULL(CDPH.BmeStatementData_IncEnergyImport,0) 
	
	end as Case1ActualEnergy_Metered,

	/*********************
	CASE 2 Adjusted
	*********************/
	
	CASE WHEN CDPH.BmeStatementData_FromPartyType_Code='SP' AND OP.BmeStatementData_OwnerPartyCategory_Code in ('BPC','PAKT','INTT','CSUP','GEN','CGEN','EGEN','EBPC')
	THEN
	 ISNULL(CDPH.BmeStatementData_AdjustedEnergyExport,0)
	end as Case2ActualEnergy,

	/*********************
	CASE 2 Metered
	*********************/
	
	CASE WHEN CDPH.BmeStatementData_FromPartyType_Code='SP' AND OP.BmeStatementData_OwnerPartyCategory_Code in ('BPC','PAKT','INTT','CSUP','GEN','CGEN','EGEN','EBPC')
	THEN
	 ISNULL(CDPH.BmeStatementData_IncEnergyExport,0)
	end as Case2ActualEnergy_Metered,

	/*********************
	CASE 3 Adjusted
	*********************/

	CASE WHEN  CDPH.BmeStatementData_FromPartyType_Code ='SP' and CDPH.BmeStatementData_FromPartyCategory_Code='DSP' AND OP.BmeStatementData_OwnerPartyCategory_Code='BSUP'
    
	and  exists (SELECT 1 FROM Bme_Parties P
		WHERE P.PartyRegisteration_Id=CDPH.BmeStatementData_FromPartyRegisteration_Id
        and P.MPId = OP.BmeStatementData_OwnerPartyRegisteration_Id		 
		)
	
	THEN
 ISNULL(CDPH.BmeStatementData_AdjustedEnergyImport,0) - ISNULL(CDPH.BmeStatementData_AdjustedEnergyExport,0)
 end as Case3ActualEnergy,
 /*********************
	CASE 3 Metered
	*********************/

	CASE WHEN  CDPH.BmeStatementData_FromPartyType_Code ='SP' and CDPH.BmeStatementData_FromPartyCategory_Code='DSP' AND OP.BmeStatementData_OwnerPartyCategory_Code='BSUP'
    
	and  exists (SELECT 1 FROM Bme_Parties P
		WHERE P.PartyRegisteration_Id=CDPH.BmeStatementData_FromPartyRegisteration_Id
        and P.MPId = OP.BmeStatementData_OwnerPartyRegisteration_Id		 
		)
	
	THEN
 ISNULL(CDPH.BmeStatementData_IncEnergyImport,0) - ISNULL(CDPH.BmeStatementData_IncEnergyExport,0)
 end as Case3ActualEnergy_Metered,

	/*********************
	CASE 4 Adjusted
	*********************/
  
  CASE WHEN  CDPH.BmeStatementData_ToPartyType_Code ='SP' and CDPH.BmeStatementData_ToPartyCategory_Code='DSP' AND OP.BmeStatementData_OwnerPartyCategory_Code='BSUP'
  
	
	and  exists (SELECT 1 FROM Bme_Parties P
		WHERE P.PartyRegisteration_Id=CDPH.BmeStatementData_ToPartyRegisteration_Id
        and P.MPId = OP.BmeStatementData_OwnerPartyRegisteration_Id		 
		)
	THEN
	
    ISNULL(CDPH.BmeStatementData_AdjustedEnergyExport,0)- ISNULL(CDPH.BmeStatementData_AdjustedEnergyImport,0)
	END as Case4ActualEnergy,
	/*********************
	CASE 4 Metered
	*********************/
  
  CASE WHEN  CDPH.BmeStatementData_ToPartyType_Code ='SP' and CDPH.BmeStatementData_ToPartyCategory_Code='DSP' AND OP.BmeStatementData_OwnerPartyCategory_Code='BSUP'
  
	
	and  exists (SELECT 1 FROM Bme_Parties P
		WHERE P.PartyRegisteration_Id=CDPH.BmeStatementData_ToPartyRegisteration_Id
        and P.MPId = OP.BmeStatementData_OwnerPartyRegisteration_Id		 
		)
	THEN
	
    ISNULL(CDPH.BmeStatementData_IncEnergyExport,0)- ISNULL(CDPH.BmeStatementData_IncEnergyImport,0)
	END as Case4ActualEnergy_Metered


	from BmeStatementDataCdpHourly CDPH
	INNER JOIN  BmeStatementDataCdpOwnerParty  OP 
	ON OP.BmeStatementData_CdpId=CDPH.BmeStatementData_CdpId  
    and OP.BmeStatementData_StatementProcessId=CDPH.BmeStatementData_StatementProcessId	
	where CDPH.BmeStatementData_Year = @Year and CDPH.BmeStatementData_Month = @Month AND CDPH.BmeStatementData_StatementProcessId=@StatementProcessId
and op.BmeStatementData_IsPowerPool <>1
	) as r
	GROUP by r.BmeStatementData_OwnerPartyRegisteration_Id, r.BmeStatementData_NtdcDateTime
)


UPDATE BmeStatementDataMpHourly 
set BmeStatementData_ActualEnergy 
= IsNull(BmeStatementDataMpHourly.BmeStatementData_ActualEnergy,0)+cdp.BmeStatementData_ActualEnergy
,BmeStatementData_ActualEnergy_Metered 
= IsNull(BmeStatementDataMpHourly.BmeStatementData_ActualEnergy_Metered,0)+cdp.BmeStatementData_ActualEnergy_Metered
	FROM BmeStatementDataMpHourly
	INNER JOIN  ActualEnergy_CTE as cdp 
	on BmeStatementDataMpHourly.BmeStatementData_PartyRegisteration_Id=cdp.BmeStatementData_OwnerPartyRegisteration_Id 
	and BmeStatementDataMpHourly.BmeStatementData_NtdcDateTime = cdp.BmeStatementData_NtdcDateTime
    where BmeStatementData_Year = @Year and BmeStatementData_Month = @Month AND BmeStatementData_StatementProcessId=@StatementProcessId
    ;



	/*****************************************************************************************************/
	--2 mp wise actual energy case 2
	/*****************************************************************************************************/

WITH ActualEnergy_CTE2
AS
(
select r.BmeStatementData_OwnerPartyRegisteration_Id,r.BmeStatementData_NtdcDateTime

,SUM(ISNULL(r.Case1ActualEnergy,0)+ISNULL(r.Case2ActualEnergy,0)+ISNULL(r.Case3ActualEnergy,0)+ISNULL(r.Case4ActualEnergy,0)) 
as BmeStatementData_ActualEnergy
,SUM(ISNULL(r.Case1ActualEnergy_Metered,0)+ISNULL(r.Case2ActualEnergy_Metered,0)+ISNULL(r.Case3ActualEnergy_Metered,0)+ISNULL(r.Case4ActualEnergy_Metered,0)) 
as BmeStatementData_ActualEnergy_Metered
from
  (select OP.BmeStatementData_OwnerPartyRegisteration_Id

	,BmeStatementData_NtdcDateTime,
	
	/*********************
	CASE 1 Adjusted
	*********************/
		CASE  WHEN  CDPH.BmeStatementData_ToPartyType_Code='SP'
		AND OP.BmeStatementData_OwnerPartyCategory_Code in ('BPC','PAKT','INTT','CSUP','GEN','CGEN','EGEN','EBPC')  

	THEN	
	 ISNULL(CDPH.BmeStatementData_AdjustedEnergyImport,0) 
	
	end as Case1ActualEnergy,

	/*********************
	CASE 1 Metered
	*********************/
		CASE  WHEN  CDPH.BmeStatementData_ToPartyType_Code='SP'
		AND OP.BmeStatementData_OwnerPartyCategory_Code in ('BPC','PAKT','INTT','CSUP','GEN','CGEN','EGEN','EBPC')  

	THEN	
	 ISNULL(CDPH.BmeStatementData_IncEnergyImport,0) 
	
	end as Case1ActualEnergy_Metered,

	/*********************
	CASE 2 Adjusted
	*********************/
	CASE WHEN CDPH.BmeStatementData_FromPartyType_Code='SP' AND OP.BmeStatementData_OwnerPartyCategory_Code in ('BPC','PAKT','INTT','CSUP','GEN','CGEN','EGEN','EBPC')
	THEN
	 ISNULL(CDPH.BmeStatementData_AdjustedEnergyExport,0)
	 
	end as Case2ActualEnergy,
	/*********************
	CASE 2 Metered
	*********************/
	CASE WHEN CDPH.BmeStatementData_FromPartyType_Code='SP' AND OP.BmeStatementData_OwnerPartyCategory_Code in ('BPC','PAKT','INTT','CSUP','GEN','CGEN','EGEN','EBPC')
	THEN
	 ISNULL(CDPH.BmeStatementData_IncEnergyExport,0)
	 
	end as Case2ActualEnergy_Metered,
	/*********************
	CASE 3 Adjusted
	*********************/

	CASE WHEN  CDPH.BmeStatementData_FromPartyType_Code ='SP' and CDPH.BmeStatementData_FromPartyCategory_Code='DSP' AND OP.BmeStatementData_OwnerPartyCategory_Code='BSUP'
    
	and  exists (SELECT 1 FROM Bme_Parties P
		WHERE P.PartyRegisteration_Id=CDPH.BmeStatementData_FromPartyRegisteration_Id
        and P.MPId = OP.BmeStatementData_OwnerPartyRegisteration_Id		 
		)
	
	THEN
 ISNULL(CDPH.BmeStatementData_AdjustedEnergyImport,0) - ISNULL(CDPH.BmeStatementData_AdjustedEnergyExport,0)
 end as Case3ActualEnergy,
 /*********************
	CASE 3 Metered
	*********************/

	CASE WHEN  CDPH.BmeStatementData_FromPartyType_Code ='SP' and CDPH.BmeStatementData_FromPartyCategory_Code='DSP' AND OP.BmeStatementData_OwnerPartyCategory_Code='BSUP'
    
	and  exists (SELECT 1 FROM Bme_Parties P
		WHERE P.PartyRegisteration_Id=CDPH.BmeStatementData_FromPartyRegisteration_Id
        and P.MPId = OP.BmeStatementData_OwnerPartyRegisteration_Id		 
		)
	
	THEN
 ISNULL(CDPH.BmeStatementData_IncEnergyImport,0) - ISNULL(CDPH.BmeStatementData_IncEnergyExport,0)
 end as Case3ActualEnergy_Metered,
  /*********************
	CASE 4 Adjusted
	*********************/
  CASE WHEN  CDPH.BmeStatementData_ToPartyType_Code ='SP' and CDPH.BmeStatementData_ToPartyCategory_Code='DSP' AND OP.BmeStatementData_OwnerPartyCategory_Code='BSUP'
  
	
	and  exists (SELECT 1 FROM Bme_Parties P
		WHERE P.PartyRegisteration_Id=CDPH.BmeStatementData_ToPartyRegisteration_Id
        and P.MPId = OP.BmeStatementData_OwnerPartyRegisteration_Id		 
		)
	THEN
	
    ISNULL(CDPH.BmeStatementData_AdjustedEnergyExport,0)- ISNULL(CDPH.BmeStatementData_AdjustedEnergyImport,0)
	END as Case4ActualEnergy,
  /*********************
	CASE 4 Metered
	*********************/
  CASE WHEN  CDPH.BmeStatementData_ToPartyType_Code ='SP' and CDPH.BmeStatementData_ToPartyCategory_Code='DSP' AND OP.BmeStatementData_OwnerPartyCategory_Code='BSUP'
  
	
	and  exists (SELECT 1 FROM Bme_Parties P
		WHERE P.PartyRegisteration_Id=CDPH.BmeStatementData_ToPartyRegisteration_Id
        and P.MPId = OP.BmeStatementData_OwnerPartyRegisteration_Id		 
		)
	THEN
	
    ISNULL(CDPH.BmeStatementData_IncEnergyExport,0)- ISNULL(CDPH.BmeStatementData_IncEnergyImport,0)
	END as Case4ActualEnergy_Metered

	from BmeStatementDataCdpHourly CDPH
	INNER JOIN  BmeStatementDataCdpOwnerParty  OP 
	ON OP.BmeStatementData_CdpId=CDPH.BmeStatementData_CdpId  
    and OP.BmeStatementData_StatementProcessId=CDPH.BmeStatementData_StatementProcessId	
	where CDPH.BmeStatementData_Year = @Year and CDPH.BmeStatementData_Month = @Month AND CDPH.BmeStatementData_StatementProcessId=@StatementProcessId
	and CDPH.IsBackfeedInclude=1
	AND op.BmeStatementData_IsPowerPool=1
	) as r
	GROUP by r.BmeStatementData_OwnerPartyRegisteration_Id, r.BmeStatementData_NtdcDateTime
)

UPDATE BmeStatementDataMpHourly set 
BmeStatementData_ActualEnergy
= IsNull(BmeStatementDataMpHourly.BmeStatementData_ActualEnergy,0)+cdp.BmeStatementData_ActualEnergy
,BmeStatementData_ActualEnergy_Metered 
= IsNull(BmeStatementDataMpHourly.BmeStatementData_ActualEnergy_Metered,0)+cdp.BmeStatementData_ActualEnergy_Metered
	FROM BmeStatementDataMpHourly
	INNER JOIN  ActualEnergy_CTE2 as cdp 
	on BmeStatementDataMpHourly.BmeStatementData_PartyRegisteration_Id=cdp.BmeStatementData_OwnerPartyRegisteration_Id 
	and BmeStatementDataMpHourly.BmeStatementData_NtdcDateTime = cdp.BmeStatementData_NtdcDateTime
    where BmeStatementData_Year = @Year and BmeStatementData_Month = @Month AND BmeStatementData_StatementProcessId=@StatementProcessId
    ;


	--************************************************		CTE 2 Started
	--3 Mp wise actual energy case 3
	--*******************************************************************

	
WITH ActualEnergy_CTE1
AS
(


select r.BmeStatementData_OwnerPartyRegisteration_Id,r.BmeStatementData_NtdcDateTime

,SUM(ISNULL(r.Case1ActualEnergy,0)+ISNULL(r.Case2ActualEnergy,0)) as BmeStatementData_ActualEnergy 
,SUM(ISNULL(r.Case1ActualEnergy_Metered,0)+ISNULL(r.Case2ActualEnergy_Metered,0)) as BmeStatementData_ActualEnergy_Metered 
from
  (
  
  SELECT  MtGenerator_Id,  BmeStatementData_OwnerPartyRegisteration_Id
	,BmeStatementData_NtdcDateTime
	,SUM(r1.Case1actualEnergy) AS Case1actualEnergy
	,SUM(r1.Case2ActualEnergy) AS Case2actualEnergy
	,SUM(r1.Case1actualEnergy_Metered) AS Case1actualEnergy_Metered
	,SUM(r1.Case2ActualEnergy_Metered) AS Case2actualEnergy_Metered
	FROM (
  SELECT distinct OP.BmeStatementData_OwnerPartyRegisteration_Id
	,BmeStatementData_NtdcDateTime
	,t.MtGenerator_Id
	
	/*********************
	CASE  Adjusted
	*********************/
	,	CASE WHEN 
		Sum(	
		
		CASE  WHEN  
		CDPH.BmeStatementData_ToPartyType_Code='SP'
		AND OP.BmeStatementData_OwnerPartyCategory_Code in ('BPC','PAKT','INTT','CSUP','GEN','CGEN','EGEN','EBPC')  
	THEN	
	ISNULL(BmeStatementData_AdjustedEnergyExport,0)- ISNULL(BmeStatementData_AdjustedEnergyImport,0)
    				 
	end
		)>0 THEN 0
		ELSE 
			ABS(Sum(	
		
		CASE  WHEN  
		CDPH.BmeStatementData_ToPartyType_Code='SP'
--		CDPH.BmeStatementData_ToPartyCategory_Code='TSP'
		AND OP.BmeStatementData_OwnerPartyCategory_Code in ('BPC','PAKT','INTT','CSUP','GEN','CGEN','EGEN','EBPC')  
	THEN	
	ISNULL(BmeStatementData_AdjustedEnergyExport,0)- ISNULL(BmeStatementData_AdjustedEnergyImport,0)
    				 
	end
		)) end
		as Case1ActualEnergy
		
		/*********************
	CASE  METERED
	*********************/
	,	CASE WHEN 
		Sum(	
		
		CASE  WHEN  
		CDPH.BmeStatementData_ToPartyType_Code='SP'
		AND OP.BmeStatementData_OwnerPartyCategory_Code in ('BPC','PAKT','INTT','CSUP','GEN','CGEN','EGEN','EBPC')  
	THEN	
	ISNULL(BmeStatementData_incEnergyExport,0)- ISNULL(BmeStatementData_IncEnergyImport,0)
    				 
	end
		)>0 THEN 0
		ELSE 
			ABS(Sum(	
		
		CASE  WHEN  
		CDPH.BmeStatementData_ToPartyType_Code='SP'
--		CDPH.BmeStatementData_ToPartyCategory_Code='TSP'
		AND OP.BmeStatementData_OwnerPartyCategory_Code in ('BPC','PAKT','INTT','CSUP','GEN','CGEN','EGEN','EBPC')  
	THEN	
	ISNULL(BmeStatementData_IncEnergyExport,0)- ISNULL(BmeStatementData_IncEnergyImport,0)
    				 
	end
		)) end
		as Case1ActualEnergy_Metered

 /*********************
	CASE  Adjusted
	*********************/

,CASE WHEN 
		Sum(	
		CASE WHEN 
		CDPH.BmeStatementData_FromPartyType_Code='SP' 
		AND OP.BmeStatementData_OwnerPartyCategory_Code in ('BPC','PAKT','INTT','CSUP','GEN','CGEN','EGEN','EBPC')
		
	THEN	
	ISNULL(BmeStatementData_AdjustedEnergyImport,0)- ISNULL(BmeStatementData_AdjustedEnergyExport,0)
    				 
	end
		)>0 THEN 0
		ELSE 
			ABS(Sum(	
		
		CASE  WHEN 
		CDPH.BmeStatementData_FromPartyType_Code='SP'
		AND OP.BmeStatementData_OwnerPartyCategory_Code in ('BPC','PAKT','INTT','CSUP','GEN','CGEN','EGEN','EBPC')  
	THEN	
	ISNULL(BmeStatementData_AdjustedEnergyImport,0)- ISNULL(BmeStatementData_AdjustedEnergyExport,0)
    				 
	end
		)) end
		as Case2ActualEnergy
 
/*********************
	CASE  METERED
	*********************/

,CASE WHEN 
		Sum(	
		CASE WHEN 
		CDPH.BmeStatementData_FromPartyType_Code='SP' 
		AND OP.BmeStatementData_OwnerPartyCategory_Code in ('BPC','PAKT','INTT','CSUP','GEN','CGEN','EGEN','EBPC')
		
	THEN	
	ISNULL(BmeStatementData_IncEnergyImport,0)- ISNULL(BmeStatementData_IncEnergyExport,0)
    				 
	end
		)>0 THEN 0
		ELSE 
			ABS(Sum(	
		
		CASE  WHEN 
		CDPH.BmeStatementData_FromPartyType_Code='SP'
		AND OP.BmeStatementData_OwnerPartyCategory_Code in ('BPC','PAKT','INTT','CSUP','GEN','CGEN','EGEN','EBPC')  
	THEN	
	ISNULL(BmeStatementData_IncEnergyImport,0)- ISNULL(BmeStatementData_IncEnergyExport,0)
    				 
	end
		)) end
		as Case2ActualEnergy_Metered 
	
	
	from BmeStatementDataCdpHourly CDPH
	INNER Join #tempCdpGen t on t.RuCDPDetail_CdpId=CDPH.BmeStatementData_CdpId
	INNER JOIN  BmeStatementDataCdpOwnerParty  OP 
	ON OP.BmeStatementData_CdpId=CDPH.BmeStatementData_CdpId  
    and OP.BmeStatementData_StatementProcessId=CDPH.BmeStatementData_StatementProcessId	
	where 
	CDPH.BmeStatementData_Year = @Year and CDPH.BmeStatementData_Month = @Month AND CDPH.BmeStatementData_StatementProcessId=@StatementProcessId
	-- CDPH.BmeStatementData_Year = 2022 and CDPH.BmeStatementData_Month = 6 AND CDPH.BmeStatementData_StatementProcessId=18
	--AND CDPH.BmeStatementData_Day=1 AND CDPH.BmeStatementData_Hour=1
	AND CDPH.IsBackfeedInclude=0

			GROUP by t.MtGenerator_Id,t.MtGenerationUnit_Id,  OP.BmeStatementData_OwnerPartyRegisteration_Id
	,BmeStatementData_NtdcDateTime
	) AS r1
GROUP by r1.MtGenerator_Id,  r1.BmeStatementData_OwnerPartyRegisteration_Id
	,r1.BmeStatementData_NtdcDateTime
	
	) as r
	GROUP by r.BmeStatementData_OwnerPartyRegisteration_Id, r.BmeStatementData_NtdcDateTime




)

UPDATE BmeStatementDataMpHourly set 
BmeStatementData_ActualEnergy =
IsNull(BmeStatementDataMpHourly.BmeStatementData_ActualEnergy,0)+cdp.BmeStatementData_ActualEnergy
,BmeStatementData_ActualEnergy_Metered =
IsNull(BmeStatementDataMpHourly.BmeStatementData_ActualEnergy_Metered,0)+cdp.BmeStatementData_ActualEnergy_Metered
FROM BmeStatementDataMpHourly
	INNER JOIN  ActualEnergy_CTE1 as cdp 
	on BmeStatementDataMpHourly.BmeStatementData_PartyRegisteration_Id=cdp.BmeStatementData_OwnerPartyRegisteration_Id 
	and BmeStatementDataMpHourly.BmeStatementData_NtdcDateTime = cdp.BmeStatementData_NtdcDateTime
    where BmeStatementData_Year = @Year and BmeStatementData_Month = @Month AND BmeStatementData_StatementProcessId=@StatementProcessId
    ;

----------------------------------------------------------------
--MP Category Zone Hourly
----------------------------------------------------------------
	----1----------Insert distinct party Ids in MpCategoryHourly Table
	insert into BmeStatementDataMpCategoryHourly (
        [BmeStatementData_StatementProcessId]
        ,[BmeStatementData_PartyRegisteration_Id]
		,[BmeStatementData_PartyName]
		,[BmeStatementData_PartyCategory_Code]
        ,[BmeStatementData_PartyType_Code]
		,[BmeStatementData_NtdcDateTime]
      ,[BmeStatementData_Year]
      ,[BmeStatementData_Month]
      ,[BmeStatementData_Day]
      ,[BmeStatementData_Hour]
      ,[BmeStatementData_IsPowerPool] 
	  ,BmeStatementData_CongestedZoneID
      ,BmeStatementData_CongestedZone
)
	select distinct 
            @StatementProcessId
		   ,BmeParty.[BmeStatementData_OwnerPartyRegisteration_Id]
           ,BmeParty.[BmeStatementData_OwnerPartyRegisteration_Name]
           ,BmeParty.[BmeStatementData_OwnerPartyCategory_Code]
           ,BmeParty.[BmeStatementData_OwnerPartyType_Code]
			,Cdp.[BmeStatementData_NtdcDateTime]
			,Cdp.[BmeStatementData_Year]
			,Cdp.[BmeStatementData_Month]
			,Cdp.[BmeStatementData_Day]
			,Cdp.[BmeStatementData_Hour]  
            ,Isnull(BmeParty.[BmeStatementData_IsPowerPool],0) 
			,cdp.BmeStatementData_CongestedZoneID
            ,cdp.BmeStatementData_CongestedZone
	from  [dbo].[BmeStatementDataCdpOwnerParty] BmeParty
	inner join BmeStatementDataCdpHourly cdp
	on Cdp.BmeStatementData_CdpId=BmeParty.BmeStatementData_CdpId
	WHERE  Cdp.BmeStatementData_Year=@Year and Cdp.BmeStatementData_Month=@Month and Cdp.BmeStatementData_StatementProcessId=@StatementProcessId AND
	  BmeParty.BmeStatementData_StatementProcessId=@StatementProcessId;

--DEclare @Year int=2021, @Month int=11;
-------------------------------------------------------------------------
/*
find actual enrgy BmeStatementDataMpCategoryHourly 
*/

---------------------------------

	/*****************************************************************************************************/
	--1 Category wise  actual energy case 1
	/*****************************************************************************************************/


WITH ActualEnergy_CTE_CategoryWise
AS
(
select  r.BmeStatementData_OwnerPartyRegisteration_Id,r.BmeStatementData_NtdcDateTime
,r.BmeStatementData_OwnerPartyCategory_Code,r.BmeStatementData_CongestedZoneID
,SUM(ISNULL(r.Case1ActualEnergy,0)+ISNULL(r.Case2ActualEnergy,0)+ISNULL(r.Case3ActualEnergy,0)+ISNULL(r.Case4ActualEnergy,0)) as BmeStatementData_ActualEnergy from
  (select 
     OP.BmeStatementData_OwnerPartyRegisteration_Id,OP.BmeStatementData_OwnerPartyCategory_Code,OP.BmeStatementData_CongestedZoneID
	,BmeStatementData_NtdcDateTime,
	
		CASE  WHEN  CDPH.BmeStatementData_ToPartyType_Code='SP'
		AND OP.BmeStatementData_OwnerPartyCategory_Code in ('BPC','PAKT','INTT','CSUP','GEN','CGEN','EGEN','EBPC')  

	THEN	
	 /*CASE WHEN ISNULL(CDPH.IsBackfeedInclude,0)=1 THEN */  ISNULL(CDPH.BmeStatementData_AdjustedEnergyImport,0) 
	-- ELSE 0 END
	end as Case1ActualEnergy,
	
	CASE WHEN CDPH.BmeStatementData_FromPartyType_Code='SP' AND OP.BmeStatementData_OwnerPartyCategory_Code in ('BPC','PAKT','INTT','CSUP','GEN','CGEN','EGEN','EBPC')
	THEN
	 /*CASE WHEN ISNULL(CDPH.IsBackfeedInclude,0)=1 THEN*/ ISNULL(CDPH.BmeStatementData_AdjustedEnergyExport,0)
	 --ELSE 0 END
	end as Case2ActualEnergy,
	

	CASE WHEN  CDPH.BmeStatementData_FromPartyType_Code ='SP' and CDPH.BmeStatementData_FromPartyCategory_Code='DSP' AND OP.BmeStatementData_OwnerPartyCategory_Code='BSUP'
    
	and  exists (SELECT 1 FROM Bme_Parties P
		WHERE P.PartyRegisteration_Id=CDPH.BmeStatementData_FromPartyRegisteration_Id
        and P.MPId = OP.BmeStatementData_OwnerPartyRegisteration_Id		 
		)
	
	THEN
 ISNULL(CDPH.BmeStatementData_AdjustedEnergyImport,0) - ISNULL(CDPH.BmeStatementData_AdjustedEnergyExport,0)
 end as Case3ActualEnergy,
  
  CASE WHEN  CDPH.BmeStatementData_ToPartyType_Code ='SP' and CDPH.BmeStatementData_ToPartyCategory_Code='DSP' AND OP.BmeStatementData_OwnerPartyCategory_Code='BSUP'
  
	
	and  exists (SELECT 1 FROM Bme_Parties P
		WHERE P.PartyRegisteration_Id=CDPH.BmeStatementData_ToPartyRegisteration_Id
        and P.MPId = OP.BmeStatementData_OwnerPartyRegisteration_Id		 
		)
	THEN
	
    ISNULL(CDPH.BmeStatementData_AdjustedEnergyExport,0)- ISNULL(CDPH.BmeStatementData_AdjustedEnergyImport,0)
	END as Case4ActualEnergy

	from BmeStatementDataCdpHourly CDPH
	INNER JOIN  BmeStatementDataCdpOwnerParty  OP 
	ON OP.BmeStatementData_CdpId=CDPH.BmeStatementData_CdpId  
    and OP.BmeStatementData_StatementProcessId=CDPH.BmeStatementData_StatementProcessId	
	where CDPH.BmeStatementData_Year = @Year and CDPH.BmeStatementData_Month = @Month AND CDPH.BmeStatementData_StatementProcessId=@StatementProcessId
and op.BmeStatementData_IsPowerPool <>1
	) as r
	GROUP by r.BmeStatementData_OwnerPartyRegisteration_Id,r.BmeStatementData_OwnerPartyCategory_Code,r.BmeStatementData_CongestedZoneID
	, r.BmeStatementData_NtdcDateTime
)


    UPDATE BmeStatementDataMpCategoryHourly set BmeStatementData_ActualEnergy = IsNull(CH.BmeStatementData_ActualEnergy,0)+cdp.BmeStatementData_ActualEnergy
	FROM BmeStatementDataMpCategoryHourly CH
	INNER JOIN  ActualEnergy_CTE_CategoryWise as cdp 
	on CH.BmeStatementData_PartyRegisteration_Id=cdp.BmeStatementData_OwnerPartyRegisteration_Id 
	and CH.BmeStatementData_NtdcDateTime = cdp.BmeStatementData_NtdcDateTime
	and CH.BmeStatementData_PartyCategory_Code=cdp.BmeStatementData_OwnerPartyCategory_Code 
	and CH.BmeStatementData_CongestedZoneID=cdp.BmeStatementData_CongestedZoneID 
      where CH.BmeStatementData_Year=@Year and CH.BmeStatementData_Month=@Month and CH.BmeStatementData_StatementProcessId=@StatementProcessId ;
    ;


	
	/*****************************************************************************************************/
	--2 Category mp wise actual energy case 2
	/*****************************************************************************************************/

WITH ActualEnergy_CTE_CategoryWise2
AS
(
select  r.BmeStatementData_OwnerPartyRegisteration_Id,r.BmeStatementData_NtdcDateTime
,r.BmeStatementData_OwnerPartyCategory_Code,r.BmeStatementData_CongestedZoneID

,SUM(ISNULL(r.Case1ActualEnergy,0)+ISNULL(r.Case2ActualEnergy,0)+ISNULL(r.Case3ActualEnergy,0)+ISNULL(r.Case4ActualEnergy,0)) as BmeStatementData_ActualEnergy from
  (
  select 
     OP.BmeStatementData_OwnerPartyRegisteration_Id,OP.BmeStatementData_OwnerPartyCategory_Code,OP.BmeStatementData_CongestedZoneID
	,BmeStatementData_NtdcDateTime,
	
		CASE  WHEN  CDPH.BmeStatementData_ToPartyType_Code='SP'
		AND OP.BmeStatementData_OwnerPartyCategory_Code in ('BPC','PAKT','INTT','CSUP','GEN','CGEN','EGEN','EBPC')  

	THEN	
	 ISNULL(CDPH.BmeStatementData_AdjustedEnergyImport,0) 
	
	end as Case1ActualEnergy,
	
	CASE WHEN CDPH.BmeStatementData_FromPartyType_Code='SP' AND OP.BmeStatementData_OwnerPartyCategory_Code in ('BPC','PAKT','INTT','CSUP','GEN','CGEN','EGEN','EBPC')
	THEN
	  ISNULL(CDPH.BmeStatementData_AdjustedEnergyExport,0)
	 
	end as Case2ActualEnergy,
	

	CASE WHEN  CDPH.BmeStatementData_FromPartyType_Code ='SP' and CDPH.BmeStatementData_FromPartyCategory_Code='DSP' AND OP.BmeStatementData_OwnerPartyCategory_Code='BSUP'
    
	and  exists (SELECT 1 FROM Bme_Parties P
		WHERE P.PartyRegisteration_Id=CDPH.BmeStatementData_FromPartyRegisteration_Id
        and P.MPId = OP.BmeStatementData_OwnerPartyRegisteration_Id		 
		)
	
	THEN
 ISNULL(CDPH.BmeStatementData_AdjustedEnergyImport,0) - ISNULL(CDPH.BmeStatementData_AdjustedEnergyExport,0)
 end as Case3ActualEnergy,
  
  CASE WHEN  CDPH.BmeStatementData_ToPartyType_Code ='SP' and CDPH.BmeStatementData_ToPartyCategory_Code='DSP' AND OP.BmeStatementData_OwnerPartyCategory_Code='BSUP'
  
	
	and  exists (SELECT 1 FROM Bme_Parties P
		WHERE P.PartyRegisteration_Id=CDPH.BmeStatementData_ToPartyRegisteration_Id
        and P.MPId = OP.BmeStatementData_OwnerPartyRegisteration_Id		 
		)
	THEN
	
    ISNULL(CDPH.BmeStatementData_AdjustedEnergyExport,0)- ISNULL(CDPH.BmeStatementData_AdjustedEnergyImport,0)
	END as Case4ActualEnergy

	from BmeStatementDataCdpHourly CDPH
	INNER JOIN  BmeStatementDataCdpOwnerParty  OP 
	ON OP.BmeStatementData_CdpId=CDPH.BmeStatementData_CdpId  
    and OP.BmeStatementData_StatementProcessId=CDPH.BmeStatementData_StatementProcessId	
	where CDPH.BmeStatementData_Year = @Year and CDPH.BmeStatementData_Month = @Month AND CDPH.BmeStatementData_StatementProcessId=@StatementProcessId
	and CDPH.IsBackfeedInclude=1
	AND op.BmeStatementData_IsPowerPool=1
	) as r
		GROUP by r.BmeStatementData_OwnerPartyRegisteration_Id,r.BmeStatementData_OwnerPartyCategory_Code,r.BmeStatementData_CongestedZoneID
	, r.BmeStatementData_NtdcDateTime
)


UPDATE BmeStatementDataMpCategoryHourly set BmeStatementData_ActualEnergy = IsNull(CH.BmeStatementData_ActualEnergy,0)+cdp.BmeStatementData_ActualEnergy
	FROM BmeStatementDataMpCategoryHourly CH
	INNER JOIN  ActualEnergy_CTE_CategoryWise2 as cdp 
	on CH.BmeStatementData_PartyRegisteration_Id=cdp.BmeStatementData_OwnerPartyRegisteration_Id 
	and CH.BmeStatementData_NtdcDateTime = cdp.BmeStatementData_NtdcDateTime
	and CH.BmeStatementData_PartyCategory_Code=cdp.BmeStatementData_OwnerPartyCategory_Code 
	and CH.BmeStatementData_CongestedZoneID=cdp.BmeStatementData_CongestedZoneID 
      where CH.BmeStatementData_Year=@Year and CH.BmeStatementData_Month=@Month and CH.BmeStatementData_StatementProcessId=@StatementProcessId ;
    ;

--************************************************		CTE 2 Started
	--3 Category wise actual energy case 3
--*******************************************************************

	
WITH ActualEnergy_CTE1_Category
AS
(

select  r.BmeStatementData_OwnerPartyRegisteration_Id,r.BmeStatementData_NtdcDateTime
,r.BmeStatementData_OwnerPartyCategory_Code,r.BmeStatementData_CongestedZoneID

,SUM(ISNULL(r.Case1ActualEnergy,0)
+ISNULL(r.Case2ActualEnergy,0)
) as BmeStatementData_ActualEnergy from
  (
  
  SELECT 
   BmeStatementData_OwnerPartyRegisteration_Id,BmeStatementData_OwnerPartyCategory_Code,BmeStatementData_CongestedZoneID
	,BmeStatementData_NtdcDateTime
 	,MtGenerator_Id

	,SUM(r1.Case1actualEnergy) AS Case1actualEnergy,SUM(r1.Case2ActualEnergy) AS Case2actualEnergy
	FROM (
  SELECT distinct
    OP.BmeStatementData_OwnerPartyRegisteration_Id,OP.BmeStatementData_OwnerPartyCategory_Code,OP.BmeStatementData_CongestedZoneID
	,BmeStatementData_NtdcDateTime
 	,t.MtGenerator_Id
	,	CASE WHEN 
		Sum(	
		
		CASE  WHEN  
		CDPH.BmeStatementData_ToPartyType_Code='SP'
		--CDPH.BmeStatementData_ToPartyCategory_Code='TSP'
		AND OP.BmeStatementData_OwnerPartyCategory_Code in ('BPC','PAKT','INTT','CSUP','GEN','CGEN','EGEN','EBPC')  
	THEN	
	ISNULL(BmeStatementData_AdjustedEnergyExport,0)- ISNULL(BmeStatementData_AdjustedEnergyImport,0)
    				 
	end
		)>0 THEN 0
		ELSE 
			ABS(Sum(	
		
		CASE  WHEN  
		CDPH.BmeStatementData_ToPartyType_Code='SP'
--		CDPH.BmeStatementData_ToPartyCategory_Code='TSP'
		AND OP.BmeStatementData_OwnerPartyCategory_Code in ('BPC','PAKT','INTT','CSUP','GEN','CGEN','EGEN','EBPC')  
	THEN	
	ISNULL(BmeStatementData_AdjustedEnergyExport,0)- ISNULL(BmeStatementData_AdjustedEnergyImport,0)
    				 
	end
		)) end
		as Case1ActualEnergy
,CASE WHEN 
		Sum(	
		CASE WHEN 
		CDPH.BmeStatementData_FromPartyType_Code='SP' 
--		CDPH.BmeStatementData_FromPartyCategory_Code='TSP'
		AND OP.BmeStatementData_OwnerPartyCategory_Code in ('BPC','PAKT','INTT','CSUP','GEN','CGEN','EGEN','EBPC')
		
	THEN	
	ISNULL(BmeStatementData_AdjustedEnergyImport,0)- ISNULL(BmeStatementData_AdjustedEnergyExport,0)
    				 
	end
		)>0 THEN 0
		ELSE 
			ABS(Sum(	
		
		CASE  WHEN 
		CDPH.BmeStatementData_FromPartyType_Code='SP'
			--	CDPH.BmeStatementData_FromPartyCategory_Code='TSP'

		AND OP.BmeStatementData_OwnerPartyCategory_Code in ('BPC','PAKT','INTT','CSUP','GEN','CGEN','EGEN','EBPC')  
	THEN	
	ISNULL(BmeStatementData_AdjustedEnergyImport,0)- ISNULL(BmeStatementData_AdjustedEnergyExport,0)
    				 
	end
		)) end
		as Case2ActualEnergy
    
	
	
	from BmeStatementDataCdpHourly CDPH
	INNER Join #tempCdpGen t on t.RuCDPDetail_CdpId=CDPH.BmeStatementData_CdpId
	INNER JOIN  BmeStatementDataCdpOwnerParty  OP 
	ON OP.BmeStatementData_CdpId=CDPH.BmeStatementData_CdpId  
    and OP.BmeStatementData_StatementProcessId=CDPH.BmeStatementData_StatementProcessId	
	where 
	CDPH.BmeStatementData_Year = @Year and CDPH.BmeStatementData_Month = @Month AND CDPH.BmeStatementData_StatementProcessId=@StatementProcessId
	-- CDPH.BmeStatementData_Year = 2022 and CDPH.BmeStatementData_Month = 6 AND CDPH.BmeStatementData_StatementProcessId=18
	--AND CDPH.BmeStatementData_Day=1 AND CDPH.BmeStatementData_Hour=1
	AND CDPH.IsBackfeedInclude=0

			GROUP by t.MtGenerator_Id,t.MtGenerationUnit_Id,  OP.BmeStatementData_OwnerPartyRegisteration_Id
			,op.BmeStatementData_OwnerPartyCategory_Code,op.BmeStatementData_CongestedZoneID
	,BmeStatementData_NtdcDateTime
	) AS r1
GROUP by r1.MtGenerator_Id,  r1.BmeStatementData_OwnerPartyRegisteration_Id
	,r1.BmeStatementData_OwnerPartyCategory_Code,r1.BmeStatementData_CongestedZoneID
	,r1.BmeStatementData_NtdcDateTime
	
	) as r
	GROUP by r.BmeStatementData_OwnerPartyRegisteration_Id,r.BmeStatementData_OwnerPartyCategory_Code,r.BmeStatementData_CongestedZoneID
	, r.BmeStatementData_NtdcDateTime



)


UPDATE BmeStatementDataMpCategoryHourly set BmeStatementData_ActualEnergy = IsNull(CH.BmeStatementData_ActualEnergy,0)+cdp.BmeStatementData_ActualEnergy
	FROM BmeStatementDataMpCategoryHourly CH
	INNER JOIN  ActualEnergy_CTE1_Category as cdp 
	on CH.BmeStatementData_PartyRegisteration_Id=cdp.BmeStatementData_OwnerPartyRegisteration_Id 
	and CH.BmeStatementData_NtdcDateTime = cdp.BmeStatementData_NtdcDateTime
	and CH.BmeStatementData_PartyCategory_Code=cdp.BmeStatementData_OwnerPartyCategory_Code 
	and CH.BmeStatementData_CongestedZoneID=cdp.BmeStatementData_CongestedZoneID 
      where CH.BmeStatementData_Year=@Year and CH.BmeStatementData_Month=@Month and CH.BmeStatementData_StatementProcessId=@StatementProcessId ;
    ;

   
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
