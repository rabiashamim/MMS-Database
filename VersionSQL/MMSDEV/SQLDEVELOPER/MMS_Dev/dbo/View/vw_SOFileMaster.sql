/****** Object:  View [dbo].[vw_SOFileMaster]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE View  vw_SOFileMaster              
 as        
select  MtSOFileMaster_Id,      
LuSOFileTemplate_Name,        
LuAccountingMonth_MonthName,      
Format(ISNULL(MtSOFileMaster_CreatedOn,''), 'dd-MMM-yyyy hh:mm tt')  MtSOFileMaster_CreatedOn,     
--MtSOFileMaster_CreatedOn,       
MtSOFileMaster_Description,    
'V'+cast(MtSOFileMaster_Version as varchar(32))     MtSOFileMaster_Version
from MtSOFileMaster mt_p                                                    
    inner join LuAccountingMonth lu_acm                                                    
        on lu_acm.LuAccountingMonth_Id = mt_p.LuAccountingMonth_Id                                                    
  inner join LuSOFileTemplate SPD                                                    
        on SPD.LuSOFileTemplate_Id = mt_p.LuSOFileTemplate_Id                                                           
where IsNull(MtSOFileMaster_IsDeleted, 0) = 0 
