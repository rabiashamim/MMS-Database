/****** Object:  ScalarFunction [dbo].[FN_CHK_FINAL_Approval]    Committed by VersionSQL https://www.versionsql.com ******/

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- =============================================              
-- Author:      <Author, , Aymen Khalid>              
-- Create Date: <Create Date, , 01-09-20222>              
-- Description: <Description, , >              
-- =============================================              
CREATE FUNCTION dbo.FN_CHK_FINAL_Approval               
(              
@PROCESS_ID INT,      
@RuWorkFlowHeader_id INT,              
@USER_ID INT              
              
)              
RETURNS BIT              
AS              
BEGIN  
DECLARE @RESULT AS BIT   
DECLARE @MtWFHistory_SequenceID int
 SELECT @MtWFHistory_SequenceID=MAX(MtWFHistory_SequenceID) FROM MtWFHistory WHERE RuWorkFlowHeader_id=@RuWorkFlowHeader_id AND MtWFHistory_Process_id=@PROCESS_ID

 IF EXISTS(SELECT 1 FROM MtWFHistory WHERE RuWorkFlowHeader_id=@RuWorkFlowHeader_id 
										AND MtWFHistory_Process_id=@PROCESS_ID 
										AND MtWFHistory_SequenceID=@MtWFHistory_SequenceID
									AND (MtWFHistory_ProcessFinalApproval=1 ))
BEGIN              
SELECT @RESULT = 1              
END
ELSE 
BEGIN 
SELECT @RESULT = 0
END 
  /*            
DECLARE @CURRENT_USER_LEVEL AS int              
DECLARE @MAX_LEVEL AS int              
DECLARE @RESULT AS BIT             
              
SELECT @MAX_LEVEL = MAX(RuWorkFlow_detail_gen_level)              
      FROM RuWorkFlow_detail_Interface              
      WHERE is_deleted = 0 AND RuProcess_ID = @PROCESS_ID  AND RuWorkFlowHeader_id = @RuWorkFlowHeader_id      
              
                    
SELECT @CURRENT_USER_LEVEL = RuWorkFlow_detail_gen_level              
      FROM RuWorkFlow_detail_Interface              
      WHERE is_deleted = 0 AND AspNetUsers_UserId = @USER_ID AND RuProcess_ID = @PROCESS_ID  AND RuWorkFlowHeader_id = @RuWorkFlowHeader_id      
if(@MAX_LEVEL = @CURRENT_USER_LEVEL)              
BEGIN              
 SELECT @RESULT = 1              
END              
ELSE              
BEGIN              
 SELECT @RESULT = 0              
END 
*/
RETURN @RESULT              
                  
END 
