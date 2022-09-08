/****** Object:  Function [dbo].[FN_CHK_FINAL_Approval]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================      
-- Author:      <Author, , Aymen Khalid>      
-- Create Date: <Create Date, , 01-09-20222>      
-- Description: <Description, , >      
-- =============================================      
CREATE FUNCTION dbo.[FN_CHK_FINAL_Approval]       
(      
@PROCESS_ID INT,      
@USER_ID INT      
      
)      
RETURNS BIT      
AS      
BEGIN      
      
      
DECLARE @CURRENT_USER_LEVEL AS int      
DECLARE @MAX_LEVEL AS int      
DECLARE @RESULT AS BIT      
      
SELECT @MAX_LEVEL = MAX(RuWorkFlow_detail_gen_level)      
      FROM RuWorkFlow_detail_Interface      
      WHERE is_deleted = 0 AND RuProcess_ID = @PROCESS_ID      
      
            
SELECT @CURRENT_USER_LEVEL = RuWorkFlow_detail_gen_level      
      FROM RuWorkFlow_detail_Interface      
      WHERE is_deleted = 0 AND AspNetUsers_UserId = @USER_ID AND RuProcess_ID = @PROCESS_ID       
if(@MAX_LEVEL = @CURRENT_USER_LEVEL)      
BEGIN      
 SELECT @RESULT = 1      
END      
ELSE      
BEGIN      
 SELECT @RESULT = 0      
END      
RETURN @RESULT      
          
END 
