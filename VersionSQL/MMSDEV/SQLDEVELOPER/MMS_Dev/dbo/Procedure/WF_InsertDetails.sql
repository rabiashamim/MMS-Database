/****** Object:  Procedure [dbo].[WF_InsertDetails]    Committed by VersionSQL https://www.versionsql.com ******/

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE procedure WF_InsertDetails
    @RuWorkFlowHeader_id int = null,
    @RuWorkFlowHeader_name nvarchar(256),
    @RuWorkFlowHeader_description nvarchar(256),
    @RuModules_Id int,
    @action_flag int,    --1=insert ,2=update,3=delete    
    @Hierarchy_data xml, --<root><row><action_flag>1</action_flag><level_id></level_id><old_level_id></old_level_id><level_description>abc</level_description><user_id>203</user_id><Designation>203</Designation></row></root>'    
    @user_id decimal(18, 0)
as
if @action_flag = 1
begin
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
end
if @action_flag = 2
begin
    update RuWorkFlow_header
    set RuWorkFlowHeader_name = @RuWorkFlowHeader_name,
        RuWorkFlowHeader_description = @RuWorkFlowHeader_description
    where RuWorkFlowHeader_id = @RuWorkFlowHeader_id
end
if @action_flag = 3
begin
    if exists (select 1 from RuWorkFlow_detail_Interface)
    begin
        select -1 error_code,
               'Data exists for current hierarchy, Please contact Business Administrator.'
        return
    end
    else
    begin
        delete from RuWorkFlow_detail
        where RuWorkFlowHeader_id = @RuWorkFlowHeader_id
        delete from RuWorkFlow_header
        where RuWorkFlowHeader_id = @RuWorkFlowHeader_id
    end
end


/*get hierarchy detail in XML*/
select row_number() over (partition by 1 order by newid()) r,
       @RuWorkFlowHeader_id RuWorkFlowHeader_id,
       ISNULL(T.c.value('./action_flag[1]', 'int'), 0) action_flag,
       ISNULL(T.c.value('./level_id[1]', 'int'), 0) level_id,
       ISNULL(T.c.value('./old_level_id[1]', 'int'), 0) old_level_id,
       ISNULL(T.c.value('./level_description[1]', 'nvarchar(256)'), '') level_description,
       ISNULL(T.c.value('./user_id[1]', 'INT'), 0) [user_id],
       ISNULL(T.c.value('./Designation[1]', 'INT'), 0) Designation
into #xml_data
FROM @Hierarchy_data.nodes('/root/row')T(c)

if exists (select 1 from #xml_data)
BEGIN
    /*delete levels for which action flag=3 i.e. delete that level*/
    delete det
    from RuWorkFlow_detail det
        inner join #xml_data x_data
            on det.RuWorkFlowHeader_id = x_data.RuWorkFlowHeader_id
               and det.RuWorkFlow_detail_levelId = x_data.level_id
    where action_flag = 3




    update det
    set RuWorkFlow_detail_levelId = x_data.level_id,
        AspNetUsers_UserId = x_data.[user_id],
        Lu_Designation_Lu_Designation_Id = x_data.Designation,
        RuWorkFlow_detail_description = level_description,
        RuWorkFlow_detail_ModifiedBy = @user_id,
        RuWorkFlow_detail_ModifiedOn = getdate()
    from RuWorkFlow_detail det
        inner join #xml_data x_data
            on det.RuWorkFlowHeader_id = x_data.RuWorkFlowHeader_id
               and det.RuWorkFlow_detail_levelId = x_data.old_level_id
    where action_flag = 2

    --update to resource here in history table   
    ;
    with update_To
    as (Select max(MtWFHistory_SequenceID) MtWFHistory_SequenceID,
               MtWFHistory_Process_name,
               RuWorkFlowHeader_id,
               MtWFHistory_Process_id
        from MtWFHistory h
        where MtWFHistory_ProcessFinalApproval != 1
              and MtWFHistory_ProcessRejected != 1
        group by MtWFHistory_Process_name,
                 RuWorkFlowHeader_id,
                 MtWFHistory_Process_id
       ),
         levels
    as (select u.RuWorkFlowHeader_id,
               u.MtWFHistory_Process_id,
               MtWFHistory_LevelID,
               h.MtWFHistory_ToResource
        from update_To u
            inner join MtWFHistory h
                on u.RuWorkFlowHeader_id = h.RuWorkFlowHeader_id
                   and u.MtWFHistory_Process_id = h.MtWFHistory_Process_id
                   and u.MtWFHistory_SequenceID = h.MtWFHistory_SequenceID
        where h.MtWFHistory_Action not in ( 'WFRI', 'WFRA', 'WFRR' )
       )
    update h
    set MtWFHistory_ToResource = [user_id]
    from MtWFHistory h
        inner join levels t
            on h.RuWorkFlowHeader_id = t.RuWorkFlowHeader_id
               and h.MtWFHistory_Process_id = t.MtWFHistory_Process_id
               and h.MtWFHistory_LevelID = t.MtWFHistory_LevelID
        inner join #xml_data x
            on h.RuWorkFlowHeader_id = x.RuWorkFlowHeader_id
               and h.RuWorkFlow_detail_levelId = x.old_level_id
               and x.[user_id] != MtWFHistory_ToResource
    where action_flag = 2

    insert into RuWorkFlow_detail
    (
        RuWorkFlowHeader_id,
        RuWorkFlow_detail_levelId,
        RuWorkFlow_detail_description,
        AspNetUsers_UserId,
        Lu_Designation_Lu_Designation_Id,
        RuWorkFlow_detail_CreatedBy,
        RuWorkFlow_detail_CreatedOn
    )
    select @RuWorkFlowHeader_id,
           level_id,
           level_description,
           [user_id],
           Designation,
           @user_id,
           getdate()
    from #xml_data
    where action_flag = 1


    /*Approved and rejected processes should be removed from interface table*/
    delete from RuWorkFlow_detail_Interface
    where RuProcess_ID in (
                              select distinct
                                  MtWFHistory_Process_id
                              from MtWFHistory
                              where MtWFHistory_ProcessFinalApproval = 1
                                    or MtWFHistory_ProcessRejected = 1
                          )
    /*get all processes having chain count different from the current chain and reject them by system*/
    declare @chain_count int
    select @chain_count = count(*)
    from RuWorkFlow_detail
    where RuWorkFlowHeader_id = @RuWorkFlowHeader_id

    --get all in approval processes chain count from interface   
    select RuProcess_ID,
           RuWorkFlowHeader_id,
           count(RuWorkFlow_detail_levelId) RuWorkFlow_detail_levelId
    into #temp
    from RuWorkFlow_detail_Interface
    where RuWorkFlowHeader_id = @RuWorkFlowHeader_id
    group by RuProcess_ID,
             RuWorkFlowHeader_id

    delete from #temp
    where RuWorkFlow_detail_levelId = @chain_count

    if exists (Select 1 from #temp)
    begin
        alter table #temp
        add sequence_id int,
            max_level_id int,
            process_name nvarchar(512);
        with cte
        as (Select max(MtWFHistory_SequenceID) MtWFHistory_SequenceID,
                   MtWFHistory_Process_name,
                   t.RuWorkFlowHeader_id,
                   t.RuProcess_ID
            from MtWFHistory h
                inner join #temp t
                    on h.RuWorkFlowHeader_id = t.RuWorkFlowHeader_id
                       and h.RuProcess_ID = t.RuProcess_ID
            group by t.RuWorkFlowHeader_id,
                     t.RuProcess_ID,
                     MtWFHistory_Process_name
           )
        update t
        set sequence_id = MtWFHistory_SequenceID,
            process_name = MtWFHistory_Process_name
        from #temp t
            inner join cte c
                on t.RuWorkFlowHeader_id = c.RuWorkFlowHeader_id
                   and t.RuProcess_ID = c.RuProcess_ID
        update t
        set max_level_id = MtWFHistory_LevelID
        from MtWFHistory h
           inner join #temp t
                on h.RuWorkFlowHeader_id = t.RuWorkFlowHeader_id
                   and h.RuProcess_ID = t.RuProcess_ID
                   and t.sequence_id = MtWFHistory_SequenceID


        if exists
        (
     Select 1
            from MtWFHistory h
                inner join #temp t
                    on h.RuProcess_ID = t.RuProcess_ID
                       and h.RuWorkFlowHeader_id = t.RuWorkFlowHeader_id
            where RuWorkFlowHeader_id = @RuWorkFlowHeader_id
                  and MtWFHistory_ProcessFinalApproval != 1
                  and MtWFHistory_ProcessRejected != 1
        )
        begin
            insert into MtWFHistory
            select @RuWorkFlowHeader_id,
                   RuProcess_ID,
                   process_name,
                   max_level_id,
                   sequence_id + 1,
                   getdate(),
                   'WFRJ',
                   1,
                   1,
                   'Rejected by System',
                   0,
                   1,
                   'Rejected by System',
                   1,
                   getdate(),
                   null,
                   null
            from #temp

            update h
            set MtWFHistory_ProcessRejected = 1
            from MtWFHistory h
                inner join #temp t
                    on h.RuWorkFlowHeader_id = t.RuWorkFlowHeader_id
                       and h.RuProcess_ID = t.RuProcess_ID
            where RuWorkFlowHeader_id = @RuWorkFlowHeader_id

            select 1 error_code,
                   'Work Flow chain is modified,In-Approval Processes will be rejected by system. Please proceed accordingly.'


        end

    end






END
