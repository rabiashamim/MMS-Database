/****** Object:  Procedure [dbo].[Sp_GetLogs]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================            
-- Author:  <Aymen Khalid>            
-- Create date: <24-01-2022>            
-- Description: <Get Logs List with server side operation>            
-- =============================================            
CREATE PROCEDURE dbo.Sp_GetLogs            
 -- Add the parameters for the stored procedure here            
@pActionTime datetime = null  
,@pUserName  NVARCHAR(MAX) = null  
,@pModuleType_Name  NVARCHAR(MAX) = null  
,@pCrudOperation_Name  NVARCHAR(MAX) = null  
,@pIPAddress  NVARCHAR(MAX) = null  
,@pPageNumber INT         
,@pPageSize INT   
,@pOrderBy NVARCHAR(MAX) = NULL    
  
            
AS            
BEGIN            
 -- SET NOCOUNT ON added to prevent extra result sets from            
 -- interfering with SELECT statements.            
 SET NOCOUNT ON;            
            
SELECT 
Mt_SystemLogs_Id
,Mt_SystemLogs_ActionTime
,Mt_SystemLogs_ModuleType_Id
,Mt_SystemLogs_CrudOperation_Id
,Mt_SystemLogs_Message
,Mt_SystemLogs_IPAddress
,Mt_SystemLogs_DeviceType
,Mt_SystemLogs_CreatedOn
,Mt_SystemLogs_CreatedBy
,Mt_SystemLogs_User
,Mt_SystemLogs_UserName
,Mt_SystemLogs_PartyRegistrationID
,Mt_SystemLogs_PartyCategoryID
,Mt_SystemLogs_FeaturePK 
,Lu_CrudOperation_Name
,RuModules_Name
,ROW_NUMBER() OVER(ORDER BY Mt_SystemLogs_ActionTime DESC) as Mt_SystemLogs_IdRowNumberId  
  
into #innerTable    
 FROM [dbo].[Mt_SystemLogs]  
 JOIN 
	RuModules 
 ON 
	RuModules_Id = Mt_SystemLogs_ModuleType_Id
 JOIN
	Lu_CrudOperation
 ON
	Lu_CrudOperation_Id = Mt_SystemLogs_CrudOperation_Id
   
--ORDER BY Mt_SystemLogs_IdRowNumberId



          
  
select * INTO #RESULT from       
#innerTable    
where Mt_SystemLogs_IdRowNumberId > ((@pPageNumber - 1) * @pPageSize)       
AND Mt_SystemLogs_IdRowNumberId <= (@pPageNumber * @pPageSize)      
AND (@pIPAddress IS NULL OR Mt_SystemLogs_IPAddress LIKE ('%' + @pIPAddress + '%'))      
AND (@pCrudOperation_Name IS NULL  OR Lu_CrudOperation_Name LIKE ('%' + @pCrudOperation_Name + '%'))    
AND (@pModuleType_Name IS NULL  OR RuModules_Name LIKE ('%' + @pModuleType_Name + '%'))      
AND (@pUserName IS NULL  OR Mt_SystemLogs_UserName LIKE ('%' + @pUserName + '%'))      
AND(@pActionTime IS NULL OR CONVERT(VARCHAR(10), Mt_SystemLogs_ActionTime, 101) = @pActionTime)      
     
    
    
DECLARE @QUERY NVARCHAR(MAX)    
    
IF(@pOrderBy is NULL)    
BEGIN    
SET @QUERY='SELECT * FROM #RESULT order by Mt_SystemLogs_IdRowNumberId '    
END    
ELSE    
BEGIN    
SET @QUERY='SELECT * FROM #RESULT ORDER BY '+ @pOrderBy    
END     
    
EXEC (@QUERY)     
    
SELECT COUNT(1) as TotalRows FROM       
#innerTable      
WHERE    
 (@pIPAddress IS NULL OR Mt_SystemLogs_IPAddress LIKE ('%' + @pIPAddress + '%'))      
AND (@pCrudOperation_Name IS NULL  OR Lu_CrudOperation_Name LIKE ('%' + @pCrudOperation_Name + '%'))    
AND (@pModuleType_Name IS NULL  OR RuModules_Name LIKE ('%' + @pModuleType_Name + '%'))      
AND (@pUserName IS NULL OR Mt_SystemLogs_UserName LIKE ('%' + @pUserName + '%'))      
AND(@pActionTime IS NULL OR CONVERT(VARCHAR(10), Mt_SystemLogs_ActionTime, 101) = @pActionTime  )
  
END 
