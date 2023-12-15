/****** Object:  View [dbo].[vw_FirmCapacityDetermination]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE View  vw_FirmCapacityDetermination          
 as
 SELECT f.MtFCDMaster_Id      
,case when MtFCDMaster_Type=1 then 'All Generators without determined Firm Capacity'     
   when MtFCDMaster_Type=2 then 'All Generators with expired Firm Capacity Certificates'     
   when MtFCDMaster_Type=3 then 'Manual Selection of Generators'     
  END as    
   [MtFCDMaster_Type]      
   ,MtFCDMaster_Type as MtFCDMaster_TypeId    
   ,F.[LuAccountingMonth_Id]    
   ,SrFCDProcessDef_Id    
   ,L.LuAccountingMonth_MonthName as Period    
      ,[MtFCDMaster_ProcessStatus]      
      ,[MtFCDMaster_ApprovalStatus]   
   ,[MtFCDMaster_ExecutionStartDate]  
      ,[MtFCDMaster_CreatedBy]      
      ,[MtFCDMaster_CreatedOn]      
      ,[MtFCDMaster_ModifiedBy]      
      ,[MtFCDMaster_ModifiedOn] 
	  ,(select STRING_AGG ( MtGenerator_Name, ',')
	  from MtFCDGenerators FG 
      inner join MTGenerator g on FG.MtGenerator_Id=G.MtGenerator_Id
	  where  FG.MtFCDMaster_Id=f.MtFCDMaster_Id)MtGenerator_Name
  FROM [dbo].[MtFCDMaster]  F    
  inner join LuAccountingMonth L on L.LuAccountingMonth_Id=F.LuAccountingMonth_Id    
  where isnull(MtFCDMaster_IsDeleted,0)=0  
    

  
