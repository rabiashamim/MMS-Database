/****** Object:  Procedure [dbo].[WF_Approvals_listget]    Committed by VersionSQL https://www.versionsql.com ******/

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  
    
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  
    
    
      
CREATE procedure [dbo].[WF_Approvals_listget]  --80       
@RuWorkFlowHeader_id int = null --if id not given then show data in list only ,if header id is given then show detail data as well            
as        
if isnull(@RuWorkFlowHeader_id, 0) = 0        
begin        
    select RuWorkFlowHeader_id,        
           RuWorkFlowHeader_name,        
           RuWorkFlowHeader_description        
    from RuWorkFlow_header        
    order by RuWorkFlowHeader_id        
end        
else        
begin        
    select 
	       RuWorkFlow_detail_id,
		   h.RuWorkFlowHeader_id,        
           RuWorkFlowHeader_name,        
           RuWorkFlowHeader_description,        
           RuModules_id,        
           RuWorkFlow_detail_levelId,        
           RuWorkFlow_detail_description,        
           r.FirstName + ' ' + r.LastName as resource_name,        
           r.userid,      
           l.Lu_Designation_Name Designation,       
           l.Lu_Designation_Id    
  into #temp  
    from RuWorkFlow_header h        
        left join RuWorkFlow_detail d        
            on h.RuWorkFlowHeader_id = d.RuWorkFlowHeader_id        
        inner join AspNetUsers r        
            on r.UserId = d.AspNetUsers_UserId        
        left join Lu_Designation l        
            on l.Lu_Designation_Id = d.Lu_Designation_Id      
        left join Lu_Department dp    
   on r.Lu_Department_Id=dp.Lu_Department_Id    
    
    where h.RuWorkFlowHeader_id = @RuWorkFlowHeader_id        
    order by RuWorkFlow_detail_levelId    
   
 select 
     RuWorkFlow_detail_id,
	 RuWorkFlowHeader_id,        
     RuWorkFlowHeader_name,        
     RuWorkFlowHeader_description,        
     RuModules_id,        
     RuWorkFlow_detail_levelId,        
     RuWorkFlow_detail_description,        
     replace(resource_name+' ('+l.Lu_Designation_Name+' - '+dp.Lu_Department_Name+')','( - )','') as resource_name,        
     t.userid,      
     t.Designation,       
     t.Lu_Designation_Id    
from #temp t  
inner join AspNetUsers r        
            on t.UserId = r.UserId    
        left join Lu_Designation l        
            on l.Lu_Designation_Id = r.Lu_Designation_Id      
        left join Lu_Department dp    
   on r.Lu_Department_Id=dp.Lu_Department_Id    
 order by RuWorkFlow_detail_levelId    
end      
    
  
                              
