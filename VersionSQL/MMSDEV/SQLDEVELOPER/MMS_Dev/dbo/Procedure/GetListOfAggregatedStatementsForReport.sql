/****** Object:  Procedure [dbo].[GetListOfAggregatedStatementsForReport]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[GetListOfAggregatedStatementsForReport]
as
Begin

with cte_aggregatedStatements as (
select 
MtStatementProcess_ID
,LuAccountingMonth_Id_Current
,SrProcessDef_ID
from MtStatementProcess where SrProcessDef_ID in (10,11,12) and isnull(MtStatementProcess_IsDeleted,0)=0
)

select
case WHEN cte.SrProcessDef_ID=10 then 'Preliminary Settlement Statement' 
 WHEN cte.SrProcessDef_ID=11 then 'Final Settlement Statement'  
 WHEN cte.SrProcessDef_ID=12 then 'Extraordinary Settlement Statement' 
END as ProcessName,
(select spd.SrProcessDef_Name+' - '+ssd.SrStatementDef_Name from SrProcessDef spd 
inner join SrStatementDef ssd on ssd.SrStatementDef_ID=spd.SrStatementDef_ID
where spd.SrProcessDef_ID=cte.SrProcessDef_ID) as ProcessName_old,

(select LuAccountingMonth_MonthName from LuAccountingMonth where LuAccountingMonth_Id=cte.LuAccountingMonth_Id_Current
) as SettlementMonthName_old,

(select CONCAT( DateName( month , DateAdd( month , CAST(LuAccountingMonth_Month AS INT) , -1 ) ),' - ',LuAccountingMonth_Year) from LuAccountingMonth where LuAccountingMonth_Id=cte.LuAccountingMonth_Id_Current
) as SettlementMonthName

,cte.MtStatementProcess_ID

from cte_aggregatedStatements cte


END
