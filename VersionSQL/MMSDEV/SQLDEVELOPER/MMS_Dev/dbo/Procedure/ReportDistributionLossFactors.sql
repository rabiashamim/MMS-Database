/****** Object:  Procedure [dbo].[ReportDistributionLossFactors]    Committed by VersionSQL https://www.versionsql.com ******/

 



--======================================================================

--Author  : Sadaf Malik

--CreatedDate : 17 Aug 2022

--Comments : Aggregated Reports Summary

--======================================================================

 

-- dbo.ReportDistributionLossFactors 144

CREATE   PROCEDURE dbo.ReportDistributionLossFactors

@pAggregatedStatementId INT=null

 

AS

BEGIN

Declare @EffectiveFromDate as Date=null

Declare @EffectiveToDate as Date=null

 

select @EffectiveFromDate=DATEFROMPARTS(LuAccountingMonth_Year,LuAccountingMonth_Month,1) from LuAccountingMonth where LuAccountingMonth_Id in (

select LuAccountingMonth_Id_Current from MtStatementProcess where MtStatementProcess_ID=@pAggregatedStatementId

);

 

set @EffectiveToDate=EOMONTH(@EffectiveFromDate);

 

with cte_DistLossGroup as(

select 

Lu_DistLosses_MP_Id    ,Lu_DistLosses_MP_Name    ,Lu_DistLosses_LineVoltage    

,Lu_DistLosses_Factor

--, case WHEN  Lu_DistLosses_LineVoltage in (220,400) then  1 else Lu_DistLosses_LineVoltage END as CombinedLineVoltage

from Lu_DistLosses where

 

                                           (    @EffectiveFromDate >= Lu_DistLosses_EffectiveFrom

  OR  Lu_DistLosses_EffectiveFrom  BETWEEN @EffectiveFromDate AND @EffectiveToDate  )

 

      and ISNULL(Lu_DistLosses_EffectiveTo,@EffectiveToDate)>=@EffectiveToDate


--Lu_DistLosses_EffectiveTo>@EffectiveToDate

)

,

/*cte_DistLossGroup as(

SELECT 

Lu_DistLosses_MP_Id

,Lu_DistLosses_MP_Name

,MAX(case when CombinedLineVoltage=1 then '220 KV, 400 KV'  else  CAST(Lu_DistLosses_LineVoltage as varchar(10)) + ' KV' end    ) as Lu_DistLosses_LineVoltage

,Lu_DistLosses_Factor--SUM(Lu_DistLosses_Factor) as Lu_DistLosses_Factor

FROM cte_groupedLineVoltage

group by Lu_DistLosses_MP_Id    ,Lu_DistLosses_MP_Name        ,CombinedLineVoltage

),*/

CTE_tempDistributionFactors AS(

SELECT 

Lu_DistLosses_LineVoltage    

,[LESCO DSP]

,[IESCO DSP]

,[FESCO DSP]

,[GEPCO DSP]

,[HESCO DSP]

,[SEPCO DSP]

,[MEPCO DSP]

,[PESCO & TESCO DSP]

,[QESCO DSP]

,[TESCO DSP]

FROM   

(SELECT 

Lu_DistLosses_MP_Name

,Lu_DistLosses_LineVoltage    

,Lu_DistLosses_Factor

FROM 

cte_DistLossGroup

)Tab1  

PIVOT  

(  

MIN(Lu_DistLosses_Factor) FOR Lu_DistLosses_MP_Name IN (

[LESCO DSP]

,[IESCO DSP]

,[FESCO DSP]

,[GEPCO DSP]

,[HESCO DSP]

,[SEPCO DSP]

,[MEPCO DSP]

,[PESCO & TESCO DSP]

,[QESCO DSP]

,[TESCO DSP]

 

)) AS Tab2  

)

 

select 

Lu_DistLosses_LineVoltage as [Loss Factor %]

,CAST(ISNULL( [LESCO DSP],0) as varchar(6))+'%' as [LESCO DSP] 

,CAST(ISNULL([IESCO DSP],0) as varchar(6))+'%' as [IESCO DSP] 

,CAST(ISNULL([FESCO DSP],0) as varchar(6))+'%' as [FESCO DSP] 

,CAST(ISNULL([GEPCO DSP],0) as varchar(6))+'%' as [GEPCO DSP] 

,CAST(ISNULL([HESCO DSP],0) as varchar(6))+'%' as [HESCO DSP] 

,CAST(ISNULL([SEPCO DSP],0) as varchar(6))+'%' as [SEPCO DSP] 

,CAST(ISNULL([MEPCO DSP],0) as varchar(6))+'%' as [MEPCO DSP] 

,CAST(ISNULL([PESCO & TESCO DSP],0) as varchar(6))+'%' as [PESCO DSP] 

,CAST(ISNULL([QESCO DSP],0) as varchar(6))+'%' as [QESCO DSP] 

,CAST(ISNULL([TESCO DSP],0) as varchar(6))+'%' as [TESCO DSP] 

from CTE_tempDistributionFactors

END

 
