/****** Object:  Procedure [dbo].[MmsErpIntegrationForSettlementData]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE    PROCEDURE dbo.MmsErpIntegrationForSettlementData

 @pAggregatedStatementId as decimal(18,0)
AS BEGIN

Insert into [dbo].[MmsErpData](
[MmsErpData_StatementProcessId],
[MmsErpData_StatementType] ,
[MmsErpData_Month] ,
[MmsErpData_MpId] ,
[MmsErpData_MpType] ,
[MmsErpData_SettlementType], 
[MmsErpData_PssAmount] ,
[MmsErpData_FssAmount] ,
[MmsErpData_TotalPssAmount] ,
[MmsErpData_TotalFssAmount] ,
[MmsErpData_CreatedOn] 
)



select 
@pAggregatedStatementId,
case when SrStatementDef_ID=1 then 'PSS' when SrStatementDef_ID=2 then 'FSS' end as SETT_STATEMENT_TYPE

--,CONCAT(SUBSTRING('JAN FEB MAR APR MAY JUN JUL AUG SEP OCT NOV DEC ', (StatementDataAggregated_Month * 4) - 3, 3),'-',StatementDataAggregated_Year) as SETTLEMENT_MONTH
,concat( UPPER(CONVERT(CHAR(3),DateName( month , DateAdd( month , StatementDataAggregated_Month , -1 )))),'-',StatementDataAggregated_Year)as SETTLEMENT_MONTH
, StatementDataAggregated_PartyRegisteration_Id as MP_ID

,[dbo].[GetPartyCategories](StatementDataAggregated_PartyRegisteration_Id) as MP_TYPE

,'BME' as SETTLEMENT_TYPE

,case when  SrStatementDef_ID=1 then isnull(StatementDataAggregated_BmeStatementData_AmountPayableReceivable,0) else 0 end as PSS_Amount--In case of FSS we should find Settlement Id of PSS of that month and use here instead of 0

,case when  SrStatementDef_ID=2 then isnull(StatementDataAggregated_BmeStatementData_AmountPayableReceivable,0) else 0 end as FSS_Amount

,case when  SrStatementDef_ID=1 then isnull((StatementDataAggregated_BmeStatementData_AmountPayableReceivable+StatementDataAggregated_AscStatementData_PAYABLE-StatementDataAggregated_AscStatementData_RECEIVABLE),0) else 0 end as TOTAL_PSS_AMOUNT --BME + ASC

,case when  SrStatementDef_ID=2 then isnull((StatementDataAggregated_BmeStatementData_AmountPayableReceivable+StatementDataAggregated_AscStatementData_PAYABLE-StatementDataAggregated_AscStatementData_RECEIVABLE),0) else 0 end as TOTAL_FSS_AMOUNT --BME + ASC

, GETDATE() as Creation_Date_Time

  from StatementDataAggregated

where MtStatementProcess_ID=@pAggregatedStatementId

and ISNULL(StatementDataAggregated_IsDeleted,0)=0

union 


select 
@pAggregatedStatementId,
case when SrStatementDef_ID=1 then 'PSS' when SrStatementDef_ID=2 then 'FSS' end as SETT_STATEMENT_TYPE

,CONCAT(SUBSTRING('JAN FEB MAR APR MAY JUN JUL AUG SEP OCT NOV DEC ', (StatementDataAggregated_Month * 4) - 3, 3),'-',StatementDataAggregated_Year) as SETTLEMENT_MONTH

, StatementDataAggregated_PartyRegisteration_Id as MP_ID

,[dbo].[GetPartyCategories](StatementDataAggregated_PartyRegisteration_Id) as MP_TYPE

,'ASC' as SETTLEMENT_TYPE

,case when  SrStatementDef_ID=1 then ISNULL(StatementDataAggregated_AscStatementData_PAYABLE,0)-ISNULL(StatementDataAggregated_AscStatementData_RECEIVABLE,0) else 0 end as PSS_Amount--In case of FSS we should find Settlement Id of PSS of that month and use here instead of 0

,case when  SrStatementDef_ID=2 then  ISNULL(StatementDataAggregated_AscStatementData_PAYABLE,0)-ISNULL(StatementDataAggregated_AscStatementData_RECEIVABLE,0) else 0 end as FSS_Amount

,case when  SrStatementDef_ID=1 then (ISNULL(StatementDataAggregated_BmeStatementData_AmountPayableReceivable,0)+ISNULL(StatementDataAggregated_AscStatementData_PAYABLE,0)-ISNULL(StatementDataAggregated_AscStatementData_RECEIVABLE,0)) else 0 end as TOTAL_PSS_AMOUNT --BME + ASC

,case when  SrStatementDef_ID=2 then (ISNULL(StatementDataAggregated_BmeStatementData_AmountPayableReceivable,0)+ISNULL(StatementDataAggregated_AscStatementData_PAYABLE,0)-ISNULL(StatementDataAggregated_AscStatementData_RECEIVABLE,0)) else 0 end as TOTAL_FSS_AMOUNT --BME + ASC

, GETDATE() as Creation_Date_Time

  from StatementDataAggregated

where MtStatementProcess_ID=@pAggregatedStatementId

and ISNULL(StatementDataAggregated_IsDeleted,0)=0


/************************************************************************
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Aggregated ESS Integration starts
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
*************************************************************************/

DECLARE @LuAccountingMonth_Id AS INT
DROP TABLE IF EXISTS #tempAggregatedESS
DROP TABLE IF EXISTS #tempAggregatedFSS
DROP TABLE IF EXISTS #tempAgrragatedFSSData
DROP TABLE IF EXISTS #tempAgrragatedESSData
DROP TABLE IF EXISTS #tempAdjustedESS
DROP TABLE IF EXISTS #tempAdjustedESSFinal
/************************************************************************************************************ 
************************************************************************************************************/
SELECT
	@LuAccountingMonth_Id = LuAccountingMonth_Id_Current
FROM MtStatementProcess
WHERE MtStatementProcess_ID = @pAggregatedStatementId;

PRINT @LuAccountingMonth_Id
/************************************************************************************************************ 
aggreagated ESS
************************************************************************************************************/
SELECT
	MtStatementProcess_ID
   ,SrProcessDef_ID
   ,LuAccountingMonth_Id
   ,LuAccountingMonth_Id_Current INTO #tempAggregatedESS
FROM MtStatementProcess
WHERE LuAccountingMonth_Id = @LuAccountingMonth_Id
AND SrProcessDef_ID IN (12) --12 means aggreagated ESS
AND ISNULL(MtStatementProcess_IsDeleted, 0) = 0


/************************************************************************************************************ 
aggreagated FSS of ESS for calculating net adjustments
************************************************************************************************************/


SELECT
	* INTO #tempAggregatedFSS
FROM MtStatementProcess msp
WHERE msp.LuAccountingMonth_Id_Current in (SELECT
		msp1.LuAccountingMonth_Id_Current
	FROM #tempAggregatedESS msp1)
AND msp.SrProcessDef_ID = 11 --11 means aggreagated FSS



/************************************************************************************************************ 
Net Adjustment: Aggregated ESS Oct - Aggregated FSS Oct
************************************************************************************************************/

SELECT
	* INTO #tempAgrragatedFSSData
FROM StatementDataAggregated
WHERE MtStatementProcess_ID in (SELECT
		ae.MtStatementProcess_ID
	FROM #tempAggregatedFSS ae);

SELECT
	* INTO #tempAgrragatedESSData
FROM StatementDataAggregated
WHERE MtStatementProcess_ID in (SELECT 
		ae.MtStatementProcess_ID
	FROM #tempAggregatedESS ae);

	/************************************************************************************************************ 
Calculate Net Adjustment Column: Aggregated ESS - Aggregated FSS
************************************************************************************************************/
SELECT
	ess.StatementDataAggregated_Month 
   ,ess.StatementDataAggregated_Year
   ,ess.StatementDataAggregated_PartyRegisteration_Id 
   ,ess.StatementDataAggregated_PartyName 
   ,(ISNULL(ess.StatementDataAggregated_BmeStatementData_AmountPayableReceivable, 0) + ISNULL(ess.StatementDataAggregated_AscStatementData_PAYABLE, 0) + ISNULL(ess.StatementDataAggregated_AscStatementData_RECEIVABLE, 0))
	- (ISNULL(fss.StatementDataAggregated_BmeStatementData_AmountPayableReceivable, 0) + ISNULL(fss.StatementDataAggregated_AscStatementData_PAYABLE, 0) + ISNULL(fss.StatementDataAggregated_AscStatementData_RECEIVABLE, 0))
	AS AdjustmentESS
INTO #tempAdjustedESS
FROM #tempAgrragatedFSSData fss
JOIN #tempAgrragatedESSData ess
	ON fss.StatementDataAggregated_PartyRegisteration_Id = ess.StatementDataAggregated_PartyRegisteration_Id
	AND Fss.StatementDataAggregated_Month=ess.StatementDataAggregated_Month
	AND FSS.StatementDataAggregated_Year=ess.StatementDataAggregated_Year


	if exists(select top 1 1 from #tempAdjustedESS)
	BEGIN
	/************************************************
	Insert operation for ESS
	*************************************************/
	
	Insert into [dbo].[MmsErpData](
[MmsErpData_StatementProcessId],
[MmsErpData_StatementType] ,
[MmsErpData_Month] ,
[MmsErpData_MpId] ,
[MmsErpData_MpType] ,
[MmsErpData_SettlementType], 
[MmsErpData_PssAmount] ,
[MmsErpData_FssAmount] ,
[MmsErpData_TotalPssAmount] ,
[MmsErpData_TotalFssAmount] ,
[MmsErpData_CreatedOn] 
)



select 
@pAggregatedStatementId,
'ESS'
,concat( UPPER(CONVERT(CHAR(3),DateName( month , DateAdd( month , StatementDataAggregated_Month , -1 )))),'-',StatementDataAggregated_Year)as SETTLEMENT_MONTH
, StatementDataAggregated_PartyRegisteration_Id as MP_ID
,[dbo].[GetPartyCategories](StatementDataAggregated_PartyRegisteration_Id) as MP_TYPE

,'ESS' as SETTLEMENT_TYPE

,0 as PSS_Amount--In case of FSS we should find Settlement Id of PSS of that month and use here instead of 0

,AdjustmentESS  as FSS_Amount

,0 as TOTAL_PSS_AMOUNT 

,AdjustmentESS as TOTAL_FSS_AMOUNT --BME + ASC

, GETDATE() as Creation_Date_Time

  from #tempAdjustedESS


/*************************************
Insert operation for ESS end here
*****************************************/
	END
/************************************************************************
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Aggregated ESS Integration ends
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
*************************************************************************/
Declare @vStatementDefId as int;
Declare @vLuAccountingMonth as int;
select  @vStatementDefId= SrStatementDef_ID, @vLuAccountingMonth=LuAccountingMonth_Id from StatementDataAggregated
where MtStatementProcess_ID=@pAggregatedStatementId 

--************** Calclulate Total PSS Amount ********************************************
 if(@vStatementDefId=1)
BEGIN

update E set MmsErpData_TotalPssAmount=T.MmsErpData_PssAmount_Sum
 from [dbo].[MmsErpData] E 
JOIN 
(select MmsErpData_MpId, SUM(isnull(MmsErpData_PssAmount,0))  as MmsErpData_PssAmount_Sum
 from [dbo].[MmsErpData] E1 
where E1.MmsErpData_StatementProcessId=@pAggregatedStatementId
and MmsErpData_StatementType='PSS'
group by MmsErpData_MpId) as T
 on E.MmsErpData_MpId=T.MmsErpData_MpId
 where E.MmsErpData_StatementProcessId=@pAggregatedStatementId

END
--********	Updated PSS Amount in case of FSS Statement **************************************************

 if(@vStatementDefId=2)
BEGIN

Declare @vPssStatementId as decimal(18,0);

select @vPssStatementId=MtStatementProcess_ID
from StatementDataAggregated where IsNull(StatementDataAggregated_IsDeleted,0)=0
and LuAccountingMonth_Id=@vLuAccountingMonth and SrStatementDef_ID=1

update E
set [MmsErpData_PssAmount]=ISnull(StatementDataAggregated_BmeStatementData_AmountPayableReceivable,0)
 from StatementDataAggregated S
inner join [dbo].[MmsErpData] E on E.[MmsErpData_MpId]=S.StatementDataAggregated_PartyRegisteration_Id
where MtStatementProcess_ID=@vPssStatementId
and ISNULL(StatementDataAggregated_IsDeleted,0)=0
and E.MmsErpData_StatementProcessId=@pAggregatedStatementId
and S.MtStatementProcess_ID=@vPssStatementId
and MmsErpData_SettlementType='BME'


update E
set [MmsErpData_PssAmount]=isnull(StatementDataAggregated_AscStatementData_PAYABLE,0)-ISNULL(StatementDataAggregated_AscStatementData_RECEIVABLE,0)
 from StatementDataAggregated S
inner join [dbo].[MmsErpData] E on E.[MmsErpData_MpId]=S.StatementDataAggregated_PartyRegisteration_Id
where MtStatementProcess_ID=@vPssStatementId
and ISNULL(StatementDataAggregated_IsDeleted,0)=0
and E.MmsErpData_StatementProcessId=@pAggregatedStatementId
and S.MtStatementProcess_ID=@vPssStatementId
and MmsErpData_SettlementType='ASC'


--************** Calclulate Total FSS Amount ********************************************
update E set MmsErpData_TotalPssAmount=T.MmsErpData_PssAmount_Sum
 from [dbo].[MmsErpData] E 
JOIN 
(select MmsErpData_MpId, SUM(isnull(MmsErpData_PssAmount,0))  as MmsErpData_PssAmount_Sum
 from [dbo].[MmsErpData] E1 
where E1.MmsErpData_StatementProcessId=@pAggregatedStatementId
and MmsErpData_StatementType='FSS'
group by MmsErpData_MpId) as T
 on E.MmsErpData_MpId=T.MmsErpData_MpId
 where E.MmsErpData_StatementProcessId=@pAggregatedStatementId

END
--********	Updated PSS Amount in case of FSS Statement **************************************************

--************** Calclulate Delta Amount ********************************************
update E
set MmsErpData_DeltaAmount=MmsErpData_FssAmount-MmsErpData_PssAmount,
MmsErpData_TotalDeltaAmount=MmsErpData_TotalFssAmount-MmsErpData_TotalPssAmount
 from [dbo].[MmsErpData] E 
where E.MmsErpData_StatementProcessId=@pAggregatedStatementId


END
