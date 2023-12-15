/****** Object:  Procedure [dbo].[WF_GetApprovalHistory_RS]    Committed by VersionSQL https://www.versionsql.com ******/

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  
    
      
        
          
            
              
                
                  
                    
                      
                        
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  
    
      
        
          
            
              
                
                  
                    
                      
                        
                        
 --WF_GetApprovalHistory 17,'1249'  ,2                       
                            
CREATE procedure dbo.WF_GetApprovalHistory_RS                                     
@RuModule_id int,  
@Process_Template_Id int,  
@MtWFHistory_Process_id decimal(18,0) ,                                                                    
@user_id  decimal(18,0)                                          
                                  
as                       
                
                
declare @RuWorkFlowHeader_id int,@RuModulesProcess_Id int                 
select @RuModulesProcess_Id=RuModulesProcess_Id from RuModulesProcess where RuModules_Id= @RuModule_id and  RuModulesProcess_ProcessTemplateId=@Process_Template_Id            
select @RuWorkFlowHeader_id=RuWorkFlowHeader_id from RuWorkFlow_header where RuModulesProcess_Id=@RuModulesProcess_Id                  
                
CREATE TABLE #WF_headers (wf_header_id INT)      
/*Party Registration*/  
IF ISNULL(@RuModule_id,0)=1                
BEGIN                 
INSERT INTO #WF_headers                
SELECT RuWorkFlowHeader_id FROM RuWorkFlow_header   
where RuModulesProcess_Id in (select RuModulesProcess_Id   
        from RuModulesProcess  
        where RuModules_Id= @RuModule_id)  
--BETWEEN 13 AND 18                
END    
/*Contract Registration*/  
ELSE      
if ISNULL(@RuModule_id,0)=12        
BEGIN                 
INSERT INTO #WF_headers                
SELECT RuWorkFlowHeader_id FROM RuWorkFlow_header   
where RuModulesProcess_Id in (select RuModulesProcess_Id   
        from RuModulesProcess  
        where RuModules_Id= @RuModule_id)  
--where RuModulesProcess_Id BETWEEN 21 AND 26                
END          
ELSE                 
BEGIN                
INSERT INTO #WF_headers                
SELECT @RuWorkFlowHeader_id                 
END                
                
                
select                                             
 RuWorkFlowHeader_id                                            
,MtWFHistory_Process_id                                            
,MtWFHistory_Process_name                                            
,MtWFHistory_LevelID                                            
,MtWFHistory_ActionDate                                            
,LuStatus_Name--MtWFHistory_Action                                            
,MtWFHistory_FromResource                                            
,u.FirstName+' '+u.LastName+' ('+Lu_Designation_Name+' - '+Lu_Department_Name+')'  FromResource_name                                          
,MtWFHistory_ToResource                                           
,u.FirstName+' '+u.LastName ToResource_name                                          
,MtWFHistory_comments                                           
,MtWFHistory_SequenceID    MtWFHistory_SequenceID_old                                 
,MtWFHistory_id                                    
into #resources                                          
from MtWFHistory w                                            
inner join [LuStatus] s on  w.MtWFHistory_Action=s.LuStatus_Code                                          
inner join AspNetUsers u on w.MtWFHistory_FromResource=u.UserId                          
 inner join Lu_Department d                          
on u.Lu_Department_Id=d.Lu_Department_Id                          
inner join Lu_Designation de on de.Lu_Designation_Id=u.Lu_Designation_Id                          
where RuWorkFlowHeader_id IN (SELECT wf_header_id FROM #WF_headers)                                             
  and MtWFHistory_Process_id=@MtWFHistory_Process_id                                           
                                
 update w                                            
 set  ToResource_name= u.FirstName+' '+u.LastName +' ('+Lu_Designation_Name+' - '+Lu_Department_Name+')'                            
 from #resources w inner join AspNetUsers u on w.MtWFHistory_ToResource=u.UserId                             
 inner join Lu_Department d                          
on u.Lu_Department_Id=d.Lu_Department_Id                          
inner join Lu_Designation de on de.Lu_Designation_Id=u.Lu_Designation_Id                          
                                      
                                          
 update w                                            
 set  ToResource_name= ''         
 from #resources w where w.MtWFHistory_ToResource is null                                      
                                           
 --select * from #resources order by MtWFHistory_ActionDate,MtWFHistory_SequenceID                 
            
                  
 select ROW_NUMBER()OVER (PARTITION BY 1 ORDER BY MtWFHistory_id desc )MtWFHistory_SequenceID, *         
 INTO #result from #resources order by MtWFHistory_id             
         
        
            
          
  ALTER TABLE #result add wf_process_name VARCHAR(250)           
            
UPDATE w            
SET wf_process_name=rmp.RuModulesProcess_Name            
FROM #result w INNER JOIN RuWorkFlow_header rwfh ON w.RuWorkFlowHeader_id=rwfh.RuWorkFlowHeader_id            
INNER JOIN RuModulesProcess rmp ON rwfh.RuModulesProcess_Id=rmp.RuModulesProcess_Id            
          
          
 SELECT * FROM #result ORDER BY MtWFHistory_SequenceID            
            
                
 DROP TABLE #WF_headers                
 DROP TABLE #resources
