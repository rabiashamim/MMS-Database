/****** Object:  Procedure [dbo].[SystemLogs]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================  
-- Author:  <Alina Javed>  
-- Create date: <Create Date,,>  
-- Description: <Description,,>  
-- =============================================  
CREATE PROCEDURE dbo.SystemLogs   
  --@latestId  numeric(15),  
  @username varchar (max) = NULL,  
  @user varchar (50)=0,  
  @logMessage varchar(max),  
  @RegistrationID int=NULL,      
  @moduleId    int=0,  
  @crudOperationId  int=0,  
  @CategoryID int=0,  
  @featurePK int=NULL,  
  @moduleName varchar (50)=NULL,  
  @CrudOperationName varchar(10),  
  @getip int =NULL,  
  @date datetime=NULL  
         
   
AS  
BEGIN  
 declare @latestId int;  
select @latestId=IsNull(MAX(Mt_SystemLogs_Id) + 1, 1) FROM  [dbo].[Mt_SystemLogs]  
select @moduleId=RuModules_Id from [dbo].[RuModules] where RuModules_Name=@moduleName  
select @crudOperationId=Lu_CrudOperation_Id from [dbo].[Lu_CrudOperation] where Lu_CrudOperation_Name=@CrudOperationName  
--DECLARE @name VARCHAR(20);
select @username=CONCAT(FirstName,' ' ,LastName) from AspNetUsers where UserId=@user
  
   DECLARE @ClientIP VARCHAR(50)
    SELECT @ClientIP = client_net_address
    FROM sys.dm_exec_connections
    WHERE session_id = @@SPID
   -- select @ClientIP

  -- Insert statements for procedure 
 INSERT INTO Mt_SystemLogs  
           (Mt_SystemLogs_Id  
     ,Mt_SystemLogs_User             
     ,Mt_SystemLogs_ActionTime  
     ,Mt_SystemLogs_ModuleType_Id  
     ,Mt_SystemLogs_CrudOperation_Id  
           ,Mt_SystemLogs_Message  
     ,Mt_SystemLogs_IPAddress  
           ,Mt_SystemLogs_PartyRegistrationID  
     ,Mt_SystemLogs_PartyCategoryID  
     ,Mt_SystemLogs_FeaturePK   
     ,Mt_SystemLogs_UserName  
           )  
  VALUES  
  (@latestId,@user ,GETDATE(),@moduleId, @crudOperationId , @logMessage, @ClientIP,@RegistrationID, 0 , 0,@username  
  )          
   
END  
