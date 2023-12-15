/****** Object:  Procedure [dbo].[WF_Getnotification_body]    Committed by VersionSQL https://www.versionsql.com ******/

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  
    
      
        
          
            
              
                
                  
                            
CREATE procedure dbo.WF_Getnotification_body                                                         
@RuWorkFlowHeader_id int,                            
@ProcessId INT,                                  
@user_id INT,                            
@action varchar(4)                            
as                            
     
     
  
declare                                                            
        @ProcessName nvarchar(256),                                                          
        @RuNotificationSetup_EmailSubject varchar(max),                                                            
        @RuNotificationSetup_EmailBody varchar(max)    ,                                  
        @RuModulesProcess_Id varchar(20)                      
                    
SELECT              
 @RuModulesProcess_Id = RuModulesProcess_Id              
FROM RuWorkFlow_header              
WHERE RuWorkFlowHeader_id = @RuWorkFlowHeader_id                 
                     
              
    
--IF @RuModules_Id = 4              
--BEGIN              
              
DECLARE @from_sql AS VARCHAR(MAX)              
    ,@where_query AS VARCHAR(MAX);              
DECLARE @query AS NVARCHAR(MAX)              
DECLARE @sql_query AS NVARCHAR(MAX)              
DECLARE @where AS VARCHAR(MAX)              
Declare @subject as nvarchar(max)              
declare @subject_query as nvarchar(max)              
            
            
SELECT              
 @ProcessName = RuModulesProcess_Name              
FROM RuModulesProcess              
WHERE RuModulesProcess_Id = @RuModulesProcess_Id           
    
              
select  @subject=STRING_AGG( CONCAT('cast(',RuModulesProcessDetails_ColumnName,' as NVARCHAR(MAX))' ),'+'' | ''+')  from RuModulesProcessDetails  
where RuModulesProcess_Id=@RuModulesProcess_Id and RuModulesProcessDetails_IsSubject=1       and isnull(RuModulesProcessDetails_IsDeleted,0)=0      
set @subject=''+@subject+''              
select @RuNotificationSetup_EmailSubject= CONCAT(''''+RuNotificationSetup_EmailSubject+ ''' ' , ' +', @subject)              
FROM RuNotificationSetup              
WHERE RuNotificationSetup_CategoryKey =case when @action in ('WFSM','WFAP') then 'Approved'    
           when @action in ('WFRJ','WFAJ') then 'Rejected'  
                                       end   
                 
SELECT              
 @where = RuModulesProcessDetails_ColumnName              
FROM RuModulesProcessDetails              
WHERE RuModulesProcess_Id = @RuModulesProcess_Id              
AND ISNULL(RuModulesProcessDetails_IsWhere, 0) = 1        
 and isnull(RuModulesProcessDetails_IsDeleted,0)=0      
              
              
select @subject_query=Concat('select @Result=',@RuNotificationSetup_EmailSubject, +' from ', RuModulesProcess_LinkedObject ,' where ',@where, '=',@ProcessId)            
from RuModulesProcess where RuModulesProcess_Id=@RuModulesProcess_Id          
      
         
DECLARE @outCount1 nvarchar(max)              
DECLARE @parameters NVARCHAR(255) = '@Result nvarchar(max) OUTPUT'               
EXEC sp_executeSQL @subject_query, @parameters, @Result = @outCount1 OUTPUT;              
    
SELECT              
 @RuNotificationSetup_EmailBody =  Concat('<tr><td colspan=2>',@ProcessName, ' ', RuNotificationSetup_EmailBody,'<br><br></td></tr>')    --CONCAT(@ProcessName, ' ', RuNotificationSetup_EmailBody)              
FROM RuNotificationSetup              
WHERE RuNotificationSetup_CategoryKey =case when @action in ('WFSM','WFAP') then 'Approved'    
           when @action in ('WFRJ','WFAJ') then 'Rejected'  
                                       end            
 
SELECT                
 @from_sql = STRING_AGG(CONCAT('<tr><td><b>', RuModulesProcessDetails_Label, ':</b></td><td>'' + isnull(cast(', ISNULL(RuModulesProcessDetails_ColumnName, ''), ' as NVARCHAR(MAX)),'''')+''</td></tr>'), '')                
FROM RuModulesProcessDetails                
WHERE RuModulesProcess_Id = @RuModulesProcess_Id   and isnull(RuModulesProcessDetails_IsDeleted,0)=0          
and isnull(RuModulesProcess_ShowOnScreen,0)=1              
SET @from_sql = '''' + @from_sql + ''''              
      
DECLARE @HTMLTable VARCHAR(MAX)              
              
DECLARE @tableValues as nvarchar(max)              
              
select @query=Concat('select @Result=', @from_sql,' from ', RuModulesProcess_LinkedObject ,' where ',@where, '=',@ProcessId)              
from RuModulesProcess where RuModulesProcess_Id=@RuModulesProcess_Id               
            
DECLARE @outCount NVARCHAR(MAX)              
DECLARE @params NVARCHAR(255) = '@Result nvarchar(max) OUTPUT'              
EXEC sp_executeSQL @query              
      ,@params              
      ,@Result = @outCount OUTPUT;              
              
DECLARE @EmailBody AS VARCHAR(MAX)              
SET @EmailBody = '              
<html>              
</head>              
<body>              
<table>'              
+              
@RuNotificationSetup_EmailBody              
+              
@outCount              
+              
'</table></body></html>'              
              
              
              
              
select @EmailBody  as NotificationBody   
