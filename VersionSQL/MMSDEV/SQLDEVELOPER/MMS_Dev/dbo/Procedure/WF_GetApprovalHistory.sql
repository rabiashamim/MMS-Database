/****** Object:  Procedure [dbo].[WF_GetApprovalHistory]    Committed by VersionSQL https://www.versionsql.com ******/

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  
    
      
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  
    
      
      
        
          
CREATE procedure WF_GetApprovalHistory                    
@RuModule_id int,                          
@MtWFHistory_Process_id decimal(18,0) ,                                                  
@user_id  decimal(18,0)                        
                
as     

declare @RuWorkFlowHeader_id int

select @RuWorkFlowHeader_id=RuWorkFlowHeader_id from RuWorkFlow_header where RuModules_id=@RuModule_id
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
,MtWFHistory_SequenceID                  
,MtWFHistory_id                  
into #resources                        
from MtWFHistory w                          
inner join [LuStatus] s on w.MtWFHistory_Action=s.LuStatus_Code                        
inner join AspNetUsers u on w.MtWFHistory_FromResource=u.UserId        
 inner join Lu_Department d        
on u.Lu_Department_Id=d.Lu_Department_Id        
inner join Lu_Designation de on de.Lu_Designation_Id=u.Lu_Designation_Id        
where RuWorkFlowHeader_id=@RuWorkFlowHeader_id                           
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
                         
 select * from #resources order by MtWFHistory_SequenceID 
