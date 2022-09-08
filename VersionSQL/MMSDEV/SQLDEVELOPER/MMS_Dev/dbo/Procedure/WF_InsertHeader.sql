/****** Object:  Procedure [dbo].[WF_InsertHeader]    Committed by VersionSQL https://www.versionsql.com ******/

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  
  
    
CREATE procedure [dbo].[WF_InsertHeader]      
    @RuWorkFlowHeader_id int = null,      
    @RuWorkFlowHeader_name nvarchar(256) = null,      
    @RuWorkFlowHeader_description nvarchar(256) = null,      
    @RuModules_Id int = null,      
    @action_flag int, --1=insert ,2=update,3=delete                        
                      --@Hierarchy_data xml,--<root><row><action_flag>1</action_flag><level_id></level_id><old_level_id></old_level_id><level_description>abc</level_description><user_id>203</user_id><Designation>203</Designation></row></root>'            
  
  
    
    
            
    @user_id decimal(18, 0)      
as      
BEGIN      
    if @action_flag = 1      
    begin      
        if exists      
        (      
            Select 1      
            from RuWorkFlow_header      
            where RuModules_id = @RuModules_Id      
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
            RuModules_id,      
            RuWorkFlowHeader_CreatedBy,      
            RuWorkFlowHeader_CreatedOn      
        )      
        select @RuWorkFlowHeader_name,      
               @RuWorkFlowHeader_description,      
               @RuModules_Id,      
               @user_id,      
               getdate()      
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
            where RuModules_id = @RuModules_Id      
                  and RuWorkFlowHeader_id != @RuWorkFlowHeader_id      
        )      
        begin      
            select -1 error_code,      
                   'Workflow Already exists for this module.' error_description      
            return      
        end      
        update RuWorkFlow_header      
        set RuWorkFlowHeader_name = @RuWorkFlowHeader_name,      
            RuWorkFlowHeader_description = @RuWorkFlowHeader_description,      
            RuModules_id = @RuModules_Id      
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
            delete from RuWorkFlow_detail      
            where RuWorkFlowHeader_id = @RuWorkFlowHeader_id      
            delete from RuWorkFlow_header      
            where RuWorkFlowHeader_id = @RuWorkFlowHeader_id      
        end      
        select 1 error_code,      
               @RuWorkFlowHeader_id error_description      
      
      end      
      
      
END    
  
