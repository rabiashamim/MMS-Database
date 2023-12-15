/****** Object:  ScalarFunction [dbo].[FN_WF_SENDER_NAME]    Committed by VersionSQL https://www.versionsql.com ******/

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  
    
        
CREATE FUNCTION DBO.[FN_WF_SENDER_NAME]         
(        
@PROCESS_ID NUMERIC(38,0),        
 @USER_ID AS NUMERIC(38,0),  
 @WorkFlowHeader_id int  
        
)        
RETURNS VARCHAR(MAX)        
AS        
BEGIN        
        
        
DECLARE @SENDER_NAME AS VARCHAR(MAX)        
        
 SELECT @SENDER_NAME = CAST(B.FirstName AS VARCHAR) + ' ' + CAST(B.LastName AS VARCHAR) +' ('+ C.Lu_Designation_Name + ' - '+ D.Lu_Department_Name + ')' FROM         
  RuWorkFlow_detail_Interface A JOIN AspNetUsers B         
   ON B.UserId = A.AspNetUsers_UserId        
  JOIN Lu_Designation C         
   ON C.Lu_Designation_Id = B.Lu_Designation_Id        
  JOIN Lu_Department D        
   ON B.Lu_Department_Id = D. Lu_Department_Id        
        
  WHERE a.RuWorkFlowHeader_id=@WorkFlowHeader_id  
  AND A.mtProcess_ID = @PROCESS_ID AND B.UserId = @USER_ID        
RETURN @SENDER_NAME        
            
END   
