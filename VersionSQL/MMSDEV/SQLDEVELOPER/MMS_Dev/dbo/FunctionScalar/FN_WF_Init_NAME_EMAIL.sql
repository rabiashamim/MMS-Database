/****** Object:  ScalarFunction [dbo].[FN_WF_Init_NAME_EMAIL]    Committed by VersionSQL https://www.versionsql.com ******/

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    
CREATE FUNCTION DBO.[FN_WF_Init_NAME_EMAIL]               
(              
@PROCESS_ID INT,  
@WorkFlowHeader_id int  
)              
RETURNS VARCHAR(max)              
AS              
BEGIN              
              
              
DECLARE @INIT_NAME AS VARCHAR(max)      
    
 SELECT @INIT_NAME = CAST(B.FirstName AS VARCHAR) + ' ' + CAST(B.LastName AS VARCHAR) +' ('+ C.Lu_Designation_Name + ' - '+ D.Lu_Department_Name + ')¼'+ CAST(B.Email as VARCHAR)  FROM               
  MtWFHistory A JOIN AspNetUsers B               
   ON B.UserId = A.MtWFHistory_FromResource              
  JOIN Lu_Designation C               
   ON C.Lu_Designation_Id = B.Lu_Designation_Id              
  JOIN Lu_Department D              
   ON B.Lu_Department_Id = D. Lu_Department_Id                           
  WHERE a.RuWorkFlowHeader_id=@WorkFlowHeader_id  
  AND A.MtWFHistory_Process_id = @PROCESS_ID      
  AND A.MtWFHistory_LevelID = 1     
  AND A.MtWFHistory_SequenceID=(SELECT MAX(MtWFHistory_SequenceID) FROM MtWFHistory WHERE  RuWorkFlowHeader_id=@WorkFlowHeader_id  AND  MtWFHistory_Process_id = @PROCESS_ID  AND MtWFHistory_LevelID = 1  )     
     
    
          /*    
 SELECT @INIT_NAME = CAST(B.FirstName AS VARCHAR) + ' ' + CAST(B.LastName AS VARCHAR) +' ('+ C.Lu_Designation_Name + ' - '+ D.Lu_Department_Name + ')¼'+ CAST(B.Email as VARCHAR)  FROM               
  RuWorkFlow_detail_Interface A JOIN AspNetUsers B               
   ON B.UserId = A.AspNetUsers_UserId              
  JOIN Lu_Designation C               
   ON C.Lu_Designation_Id = B.Lu_Designation_Id              
  JOIN Lu_Department D              
   ON B.Lu_Department_Id = D. Lu_Department_Id              
                 
  WHERE A.RuProcess_ID = @PROCESS_ID  AND A.RuWorkFlow_detail_gen_level = 1 AND A.is_deleted = 0          
  --AND B.EmailConfirmed = 1      
  */    
RETURN @INIT_NAME              
                  
END 
