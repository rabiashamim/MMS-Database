/****** Object:  Procedure [dbo].[RemoveSettlementProcess]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[RemoveSettlementProcess]    
@pSettlementProcessId Decimal(18,0)    
AS    
BEGIN    
if exists(Select 1 from MtStatementProcess where MtStatementProcess_ID=@pSettlementProcessId and MtStatementProcess_ApprovalStatus!='Draft')  
begin   
select -1 error_code,'Process is in Approval, Can not be deleted'  
end  
else   
begin  
 UPDATE     
  MtStatementProcess     
  SET      
   MtStatementProcess_IsDeleted=1     
  WHERE     
   MtStatementProcess_ID=@pSettlementProcessId  
   select 1 error_code,'Process deleted Successfully'  
end     
END 
