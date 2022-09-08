/****** Object:  Procedure [dbo].[WF_InsertDetail_RS]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE procedure [dbo].[WF_InsertDetail_RS]  
@RuWorkFlowHeader_id int,   
@action_flag int,--1=insert ,2=update,3=delete    
@level_id int,  
@level_description varchar(256)=null,  
@level_user_id decimal (18,0) =null ,  
@Designation decimal (18,0)=null,  
@user_id decimal (18,0)    
as    
    
 /*delete levels for which action flag=3 i.e. delete that level*/    
 if @action_flag=3  
 begin   

	delete from RuWorkFlow_detail      
	where RuWorkFlowHeader_id=@RuWorkFlowHeader_id  
		and RuWorkFlow_detail_levelId=@level_id  

		/*update level hierarchy on any level deletion*/
	;with cte as
	(select row_number() over(partition by 1 order by RuWorkFlow_detail_levelId asc) new_level,*
	from RuWorkFlow_detail where RuWorkFlowHeader_id=@RuWorkFlowHeader_id 
	)
	update d    
	set     
	RuWorkFlow_detail_levelId=new_level   
	from RuWorkFlow_detail d inner join cte c on d.RuWorkFlowHeader_id=c.RuWorkFlowHeader_id  
	and  d.RuWorkFlow_detail_levelId=c.RuWorkFlow_detail_levelId  
	where d.RuWorkFlowHeader_id=@RuWorkFlowHeader_id 

 end  
  
 if @action_flag=2  
 BEGIN  
  update RuWorkFlow_detail    
  set     
  RuWorkFlow_detail_levelId=@level_id,  
  AspNetUsers_UserId=@level_user_id,    
  Lu_Designation_Id=@Designation,  
  RuWorkFlow_detail_description=@level_description,    
  RuWorkFlow_detail_ModifiedBy=@user_id,    
  RuWorkFlow_detail_ModifiedOn=getutcdate()    
  where  RuWorkFlowHeader_id=@RuWorkFlowHeader_id  
  and RuWorkFlow_detail_levelId=@level_id  
  
 --update to resource here in history table   
 --get max sequence id of the required level to update the resource  
 ;with update_To as  
  (Select max(MtWFHistory_SequenceID)MtWFHistory_SequenceID,MtWFHistory_Process_name ,RuWorkFlowHeader_id,MtWFHistory_Process_id  
     from MtWFHistory h   
     where MtWFHistory_ProcessFinalApproval!=1  
     and   MtWFHistory_ProcessRejected!=1  
     and   MtWFHistory_LevelID=@level_id  
     group by MtWFHistory_Process_name ,RuWorkFlowHeader_id,MtWFHistory_Process_id)  
  
  update h  
  set MtWFHistory_ToResource=@level_user_id  
  from MtWFHistory h   
  inner join update_To t on h.RuWorkFlowHeader_id=t.RuWorkFlowHeader_id  
      and h.MtWFHistory_Process_id=t.MtWFHistory_Process_id  
      and h.MtWFHistory_SequenceID=t.MtWFHistory_SequenceID  
      and h.MtWFHistory_LevelID=@level_id  
      and h.MtWFHistory_ToResource!=@level_user_id  
      and h.MtWFHistory_Action not in ('WFRI','WFRA','WFRR')  
  
END  
  
If @action_flag=1  
BEGIN  
  insert into RuWorkFlow_detail    
  (    
   RuWorkFlowHeader_id    
  ,RuWorkFlow_detail_levelId    
  ,RuWorkFlow_detail_description    
  ,AspNetUsers_UserId    
  ,Lu_Designation_Id    
  ,RuWorkFlow_detail_CreatedBy    
  ,RuWorkFlow_detail_CreatedOn    
  )    
  select     
   @RuWorkFlowHeader_id    
  ,@level_id    
  ,@level_description    
  ,@level_user_id    
  ,@Designation    
  ,@user_id    
  ,getutcdate()    
  
 END  
  
 --/*  
 /*Approved and rejected processes should be removed from interface table*/  
 delete from RuWorkFlow_detail_Interface  
where RuProcess_ID in (select distinct MtWFHistory_Process_id   
      from MtWFHistory  
      where MtWFHistory_ProcessFinalApproval=1 or MtWFHistory_ProcessRejected=1)  
      --*/  
/*get all processes having chain count different from the current chain and reject them by system*/  
 declare @chain_count int  
 select  @chain_count=count(*)  from RuWorkFlow_detail where RuWorkFlowHeader_id=@RuWorkFlowHeader_id   
  
 --get all in approval processes chain count from interface   
 select RuProcess_ID,RuWorkFlowHeader_id,count(RuWorkFlow_detail_levelId)RuWorkFlow_detail_levelId   
 into #temp  
 from RuWorkFlow_detail_Interface  
 where RuWorkFlowHeader_id=@RuWorkFlowHeader_id   
 group by  RuProcess_ID,RuWorkFlowHeader_id  
  
 delete from #temp where RuWorkFlow_detail_levelId=@chain_count  
  
 if exists(Select 1 from #temp)  
 begin   
  alter table #temp add sequence_id int,max_level_id int,process_name nvarchar(512)  
  ;with cte as (Select max(MtWFHistory_SequenceID)MtWFHistory_SequenceID,MtWFHistory_Process_name ,t.RuWorkFlowHeader_id,t.RuProcess_ID  
    from MtWFHistory h inner join #temp t on h.RuWorkFlowHeader_id=t.RuWorkFlowHeader_id  
              and h.MtWFHistory_Process_id=t.RuProcess_ID  
    group by t.RuWorkFlowHeader_id,t.RuProcess_ID,MtWFHistory_Process_name)  
  
 update t  
 set sequence_id=MtWFHistory_SequenceID,process_name=MtWFHistory_Process_name  
 from #temp t inner join cte c on t.RuWorkFlowHeader_id=c.RuWorkFlowHeader_id  
         and t.RuProcess_ID=c.RuProcess_ID  
 update t  
 set max_level_id=MtWFHistory_LevelID  
 from MtWFHistory h inner join #temp t on h.RuWorkFlowHeader_id=t.RuWorkFlowHeader_id  
           and h.MtWFHistory_Process_id=t.RuProcess_ID  
           and t.sequence_id=MtWFHistory_SequenceID  
  
  
 if exists(Select 1 from MtWFHistory h inner join #temp t on h.MtWFHistory_Process_id=t.RuProcess_ID and h.RuWorkFlowHeader_id=t.RuWorkFlowHeader_id  
      where h.RuWorkFlowHeader_id=@RuWorkFlowHeader_id   
      and h.MtWFHistory_ProcessFinalApproval!=1  
      and h.MtWFHistory_ProcessRejected!=1)  
  begin   
  insert into MtWFHistory  
  select @RuWorkFlowHeader_id,RuProcess_ID,process_name,max_level_id,sequence_id+1,GETUTCDATE(),'WFRJ',1,1,'Rejected by System'  
  ,0,1,'Rejected by System',1,GETUTCDATE(),null,null  
  from #temp  
  
  update h  
  set MtWFHistory_ProcessRejected= 1  
  from MtWFHistory h inner join #temp t on h.RuWorkFlowHeader_id=t.RuWorkFlowHeader_id  
            and h.MtWFHistory_Process_id=t.RuProcess_ID  
        where h.RuWorkFlowHeader_id=@RuWorkFlowHeader_id   
  
  select 1 error_code,'Work Flow chain is modified,In-Approval Processes will be rejected by system. Please proceed accordingly.'  
  
  
  end   
  
 end   
  
   
  
  
  
  
  
