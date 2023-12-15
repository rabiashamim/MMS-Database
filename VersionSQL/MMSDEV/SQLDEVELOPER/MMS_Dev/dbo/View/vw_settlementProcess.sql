/****** Object:  View [dbo].[vw_settlementProcess]    Committed by VersionSQL https://www.versionsql.com ******/

create view vw_settlementProcess  
as  
select  CONCAT(SPD.SrProcessDef_Name, ' - ', SSD.SrStatementDef_Name) ProcessName,                                                
 LuAccountingMonth_MonthName LuAccountingMonth_MonthName,                                                
        MtStatementProcess_ExecutionFinishDate  MtStatementProcess_ExecutionFinishDate   ,  
  MtStatementProcess_ID   MtStatementProcess_ID
from MtStatementProcess mt_p                                                
    inner join LuAccountingMonth lu_acm                                                
        on lu_acm.LuAccountingMonth_Id = mt_p.LuAccountingMonth_Id_Current                                                
    inner join SrProcessDef SPD                                                
        on SPD.SrProcessDef_ID = mt_p.SrProcessDef_ID                                                
    inner join SrStatementDef SSD                                                
        on SPD.SrStatementDef_ID = SSD.SrStatementDef_ID                                                
where IsNull(MtStatementProcess_IsDeleted, 0) = 0 
