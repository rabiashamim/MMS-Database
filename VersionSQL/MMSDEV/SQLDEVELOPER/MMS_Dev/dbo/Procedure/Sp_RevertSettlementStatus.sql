/****** Object:  Procedure [dbo].[Sp_RevertSettlementStatus]    Committed by VersionSQL https://www.versionsql.com ******/

  -- =============================================  
-- Author:Aymen Khalid  
-- Create date:05-DEC-2022  
-- Description: <Revert Status to Initial>  
-- =============================================  
CREATE PROCEDURE dbo.Sp_RevertSettlementStatus  
  
 @ps_MtStatementProcess_ID int,
  @pi_userId int    
     
AS    
BEGIN    
  
  
    UPDATE MtStatementProcess   
SET MtStatementProcess_Status = 'Executed',  
 MtStatementProcess_ApprovalStatus = 'Draft',
MtStatementProcess_ModifiedBy = @pi_userId,
MtStatementProcess_ModifiedOn = GETDATE(),
MtStatementProcess_UpdatedDate = GETDATE()  
WHERE   
 MtStatementProcess_ID = @ps_MtStatementProcess_ID  
  
  INSERT INTO MtSattlementProcessLogs 
  VALUES 
  ( @ps_MtStatementProcess_ID ,
  'Monthly settlement process Status Reverted by Dpt.Manager/ Manager', 
   @pi_userId,
   GETDATE(),
   @pi_userId,
   GETDATE(),
   null)

 select @@rowcount  
END    
  
  
