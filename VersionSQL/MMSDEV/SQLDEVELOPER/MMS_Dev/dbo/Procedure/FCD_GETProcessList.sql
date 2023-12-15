/****** Object:  Procedure [dbo].[FCD_GETProcessList]    Committed by VersionSQL https://www.versionsql.com ******/

     
 CREATE PROCEDURE   dbo.FCD_GETProcessList   
 @pMtFCDMaster as decimal(18,0)=0  
 AS        
 BEGIN        
  
SELECT [MtFCDMaster_Id]    
  --    ,case when MtFCDMaster_Type=1 then 'All Generators'   
  -- when MtFCDMaster_Type=2 then 'All Dispatchable'   
  -- when MtFCDMaster_Type=3 then 'All Non-Dispatchable'   
  -- when MtFCDMaster_Type=4 then 'Individual Generators'   
  --END as  
  
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
   into #tempFirmCapacityList  
  FROM [dbo].[MtFCDMaster]  F  
  inner join LuAccountingMonth L on L.LuAccountingMonth_Id=F.LuAccountingMonth_Id  
  where isnull(MtFCDMaster_IsDeleted,0)=0  
    AND( @pMtFCDMaster=0 or MtFCDMaster_Id=@pMtFCDMaster)  
 --order by MtFCDMaster_CreatedOn desc  
  
 if(@pMtFCDMaster=0 )  
 BEGIN  
 select * from  #tempFirmCapacityList  
 END  
  
 ELSE   
 BEGIN  
 Declare @vFirmCapacityType as int  
 Declare @GeneratorNames as varchar(max)=NULL;  
   
 select @vFirmCapacityType=MtFCDMaster_TypeId from  #tempFirmCapacityList   
  
   if(@vFirmCapacityType=3)  
   BEGIN  
   select @GeneratorNames= STRING_AGG ( MtGenerator_Name, ',')  from MTGenerator G  
   inner join MtFCDGenerators FG on FG.MtGenerator_Id=G.MtGenerator_Id  
   inner join #tempFirmCapacityList T on T.MtFCDMaster_Id=FG.MtFCDMaster_Id  
   where isnull(MtFCDGenerators_IsDeleted,0)=0  
   and isnull(isDeleted,0)=0  
   and ISNULL(MtGenerator_IsDeleted,0)=0  
   --order by MtGenerator_Name ASC  
   END  
    select *, @GeneratorNames as GeneratorNames from  #tempFirmCapacityList 
	
	SELECT
    DISTINCT
    mf.LuEnergyResourceType_Code as Generator_TypeCode
FROM MtFCDGenerators mf
INNER JOIN MtGenerator mg
    ON mf.MtGenerator_Id = mg.MtGenerator_Id
WHERE mf.MtFCDMaster_Id = @pMtFCDMaster
  
  END  
END    
    
