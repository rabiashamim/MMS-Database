/****** Object:  Procedure [dbo].[GETMonthlySettlementListing]    Committed by VersionSQL https://www.versionsql.com ******/

 --======================================================================      
--Author  : Sadaf Malik      
--Reviewer : <>      
--CreatedDate : 01 Mar 2022      
--Comments :       
--======================================================================      
--use mms      
--[dbo].[GETMonthlySettlementListing] 2    
 CREATE PROCEDURE [dbo].[GETMonthlySettlementListing]            
 @pSettlementProcessId as decimal(18,0)=null    
 AS            
 BEGIN            
    
select      
    
 MtStatementProcess_ID    
 ,SrProcessDef_ID
 ,ProcessName=(select CONCAT(SPD.SrProcessDef_Name,' - ',SSD.SrStatementDef_Name) from SrStatementDef SSD   inner join SrProcessDef SPD on SPD.SrStatementDef_ID=SSD.SrStatementDef_ID where      SPD.SrProcessDef_ID=MtStatementProcess.SrProcessDef_ID)    
 ,EssSettlementPeriod=(select LuAccountingMonth_MonthName from LuAccountingMonth where LuAccountingMonth_Id=MtStatementProcess.LuAccountingMonth_Id)    
 ,LuAccountingMonth_MonthName as SettlementPeriod    
 ,LuAccountingMonth_Month as Month    
 ,LuAccountingMonth_Year as Year    
 ,MtStatementProcess_Status    
 ,MtStatementProcess_ApprovalStatus    
 ,MtStatementProcess_ExecutionStartDate    
 ,MtStatementProcess_ExecutionFinishDate as approvalDate    
 ,MtStatementProcess_UpdatedDate as UpdatedDate    
 ,MtStatementProcess_ExecutionStartDate     
 ,MtStatementProcess_ExecutionFinishDate    
 ,MtStatementProcess_CreatedOn  
from MtStatementProcess    
    
inner join LuAccountingMonth on LuAccountingMonth.LuAccountingMonth_Id=MtStatementProcess.LuAccountingMonth_Id_Current    
    
where IsNull(MtStatementProcess_IsDeleted,0)=0 and (    
@pSettlementProcessId is null OR    
(@pSettlementProcessId is not null and MtStatementProcess.MtStatementProcess_ID=@pSettlementProcessId)    
)    
    
order by LuAccountingMonth_Year desc, LuAccountingMonth_Month DESC, MtStatementProcess_ID ASC    
END 
