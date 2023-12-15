/****** Object:  Procedure [dbo].[WF_InsertHeader]    Committed by VersionSQL https://www.versionsql.com ******/

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  
    
      
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  
    
      
      
        
CREATE procedure dbo.WF_InsertHeader          
    @RuWorkFlowHeader_id int = null,          
    @RuWorkFlowHeader_name nvarchar(256) = null,          
    @RuWorkFlowHeader_description nvarchar(256) = null,          
    @RuModulesProcess_Id int = null,          
    @action_flag int, --1=insert ,2=update,3=delete                            
    
  
    
      
      
        
        
                
    @user_id decimal(18, 0)          
as          
BEGIN          
    if @action_flag = 1          
    begin          
        if exists          
        (          
            Select 1          
            from RuWorkFlow_header          
            where RuModulesProcess_Id = @RuModulesProcess_Id    
   AND RuWorkFlowHeader_isDeleted=0  
        )          
        begin          
            select -1 error_code,          
                   'Workflow Already exists for this module.'          
            return          
        end          
          
        insert into RuWorkFlow_header          
        (          
            RuWorkFlowHeader_name,          
            RuWorkFlowHeader_description,          
            RuModulesProcess_Id,          
            RuWorkFlowHeader_CreatedBy,          
            RuWorkFlowHeader_CreatedOn,  
   RuWorkFlowHeader_isDeleted  
        )          
        select @RuWorkFlowHeader_name,          
               @RuWorkFlowHeader_description,          
               @RuModulesProcess_Id,          
               @user_id,          
               getdate() ,0         
        select @RuWorkFlowHeader_id = @@IDENTITY          
        select 0 error_code,          
               @RuWorkFlowHeader_id error_description          
    end          
    if @action_flag = 2          
    begin          
        if exists          
        (          
            Select 1          
            from RuWorkFlow_header          
            where RuModulesProcess_Id = @RuModulesProcess_Id          
                  and RuWorkFlowHeader_id != @RuWorkFlowHeader_id      
      AND RuWorkFlowHeader_isDeleted=0  
        )          
        begin          
            select -1 error_code,          
                   'Workflow Already exists for this module.' error_description          
            return          
        end          
        update RuWorkFlow_header          
        set RuWorkFlowHeader_name = @RuWorkFlowHeader_name,          
            RuWorkFlowHeader_description = @RuWorkFlowHeader_description,          
            RuModulesProcess_Id = @RuModulesProcess_Id          
        where RuWorkFlowHeader_id = @RuWorkFlowHeader_id          
        select 1 error_code,          
               @RuWorkFlowHeader_id error_description          
    end          
    if @action_flag = 3          
    begin          
        if exists          
        (          
            select 1          
            from RuWorkFlow_detail_Interface          
            where RuWorkFlowHeader_id = @RuWorkFlowHeader_id     
   and isnull(is_deleted,0)!=1    
        )          
        begin          
            select -1 error_code,          
                   'Data exists for current hierarchy, Please contact Business Administrator.' error_description          
            return          
        end        
        else          
        begin   
      update RuWorkFlow_header  
   set RuWorkFlowHeader_isDeleted =1  
   where RuWorkFlowHeader_id=@RuWorkFlowHeader_id  
     
   update RuWorkFlow_detail  
   set RuWorkFlow_detail_isDeleted=1   
   where RuWorkFlowHeader_id=@RuWorkFlowHeader_id  
  
            --delete from RuWorkFlow_detail          
            --where RuWorkFlowHeader_id = @RuWorkFlowHeader_id          
            --delete from RuWorkFlow_header          
            --where RuWorkFlowHeader_id = @RuWorkFlowHeader_id          
        end          
      select 1 error_code,          
               @RuWorkFlowHeader_id error_description          
          
      end          
          
          
END 
