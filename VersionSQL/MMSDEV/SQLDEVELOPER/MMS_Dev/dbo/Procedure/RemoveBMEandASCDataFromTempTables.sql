/****** Object:  Procedure [dbo].[RemoveBMEandASCDataFromTempTables]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================  
-- Author:  Ali Imran 
-- CREATE date: 
-- ALTER date: 06 sep 2023
-- Description: Refactoring and Delete properly.
-- Parameters: 
-- =============================================        
CREATE   Procedure dbo.RemoveBMEandASCDataFromTempTables        
	@Year int,        
	@Month int,        
    @StatementProcessId decimal(18,0) ,
	@pUserId int
AS        
BEGIN        
select 1;        
    
	DECLARE 
	 @vName NVARCHAR(MAX)
	,@vOutput VARCHAR(max)
	,@vStatementProcessIdMonthName VARCHAR(20) 
	,@vMonth INT
	,@vYear INT
	,@vMonthId_Current VARCHAR(MAX)
	,@vProcessName VARCHAR(4);  



select @vProcessName=D.SrProcessDef_Name from MtStatementProcess SP  
JOIN SrProcessDef D ON SP.SrProcessDef_ID=D.SrProcessDef_ID  
where MtStatementProcess_ID=@StatementProcessId

/*---------------------------------------------------------------------------------------------------------------------------------
Remove BME
-----------------------------------------------------------------------------------------------------------------------------------*/ 
 IF @vProcessName='BME'  
 BEGIN  

              
            
 /*---------------------------------------------------------------------------------------------------------------------------------
Delete tables involve during process
-----------------------------------------------------------------------------------------------------------------------------------*/  
 DELETE from [dbo].[BmeStatementDataFinalOutputs] where MtStatementProcess_ID=@StatementProcessId          
           
 DELETE FROM BmeStatementDataMpCategoryMonthly WHERE  BmeStatementData_Year=@Year and BmeStatementData_Month=@Month and BmeStatementData_StatementProcessId=@StatementProcessId;          
   
 DELETE FROM BmeStatementDataMpCategoryHourly WHERE  BmeStatementData_Year=@Year and BmeStatementData_Month=@Month and BmeStatementData_StatementProcessId=@StatementProcessId;          
      
 DELETE FROM [BmeStatementDataMpMonthly] WHERE  BmeStatementData_Year=@Year and BmeStatementData_Month=@Month  and BmeStatementData_StatementProcessId=@StatementProcessId;          
      
 DELETE FROM BmeStatementDataMpContractHourly WHERE  BmeStatementData_Year=@Year and BmeStatementData_Month=@Month  and BmeStatementData_StatementProcessId=@StatementProcessId;          
      
 DELETE FROM BmeStatementDataCdpContractHourly WHERE  BmeStatementData_Year=@Year and BmeStatementData_Month=@Month  and BmeStatementData_StatementProcessId=@StatementProcessId;          
      
 DELETE FROM BmeStatementDataMpHourly WHERE  BmeStatementData_Year=@Year and BmeStatementData_Month=@Month and BmeStatementData_StatementProcessId=@StatementProcessId;          
      
 DELETE FROM BmeStatementDataHourly WHERE  BmeStatementData_Year=@Year and BmeStatementData_Month=@Month and BmeStatementData_StatementProcessId=@StatementProcessId;          
      
 DELETE FROM BmeStatementDataTspHourly WHERE  BmeStatementData_Year=@Year and BmeStatementData_Month=@Month and BmeStatementData_StatementProcessId=@StatementProcessId;          
      
 DELETE FROM BmeStatementDataGenUnitHourly WHERE  BmeStatementData_Year=@Year and BmeStatementData_Month=@Month and BmeStatementData_StatementProcessId=@StatementProcessId;          
   
 DELETE FROM BmeStatementDataCdpHourly WHERE  BmeStatementData_Year=@Year and BmeStatementData_Month=@Month and BmeStatementData_StatementProcessId=@StatementProcessId;          
      
 DELETE FROM BmeStatementDataCdpOwnerParty WHERE  BmeStatementData_StatementProcessId=@StatementProcessId;    
 

 
 END         

/*--------------------------------------------------------------------------------------------------------------------------------------  
* ASC Remove  
*--------------------------------------------------------------------------------------------------------------------------------------*/   
 ELSE IF @vProcessName='ASC'  
 BEGIN  
      

/*---------------------------------------------------------------------------------------------------------------------------------
Delete tables involve during process
-----------------------------------------------------------------------------------------------------------------------------------*/
   
 DELETE from [dbo].[BmeStatementDataFinalOutputs] where MtStatementProcess_ID=@StatementProcessId     
   
 DELETE FROM [dbo].[AscStatementDataMpMonthly] WHERE AscStatementData_Year=@Year and AscStatementData_Month=@Month and AscStatementData_StatementProcessId= @StatementProcessId      
      
 DELETE FROM [dbo].[AscStatementDataMpZoneMonthly] WHERE AscStatementData_Year=@Year and AscStatementData_Month=@Month and AscStatementData_StatementProcessId=@StatementProcessId      
   
 DELETE FROM [dbo].[AscStatementDataZoneMonthly] WHERE AscStatementData_Year=@Year and AscStatementData_Month=@Month  and AscStatementData_StatementProcessId=@StatementProcessId      
   
 DELETE FROM [dbo].[AscStatementDataGenMonthly] WHERE AscStatementData_Year=@Year and AscStatementData_Month=@Month  and AscStatementData_StatementProcessId=@StatementProcessId      
   
 DELETE FROM [dbo].[AscStatementDataGuMonthly] WHERE AscStatementData_Year=@Year and AscStatementData_Month=@Month and AscStatementData_StatementProcessId=@StatementProcessId      
      
 DELETE FROM [dbo].[AscStatementDataGuHourly] WHERE  AscStatementData_Year=@Year and AscStatementData_Month=@Month and AscStatementData_StatementProcessId=@StatementProcessId      
   
 DELETE FROM [dbo].[AscStatementDataCdpGuParty] WHERE AscStatementData_StatementProcessId= @StatementProcessId      
  
 END  	  

/*---------------------------------------------------------------------------------------------------------------------------------
For logs  get Process Name and Month Id
-----------------------------------------------------------------------------------------------------------------------------------*/ 

	SELECT   
		@vName	=	CONCAT(SrProcessDef_Name, '-', SrStatementDef_Name)   
	   ,@vMonthId_Current	=	LuAccountingMonth_Id_Current
	FROM MtStatementProcess    
	INNER JOIN SrProcessDef    ON SrProcessDef.SrProcessDef_ID = MtStatementProcess.SrProcessDef_ID    
	INNER JOIN SrStatementDef    ON SrStatementDef.SrStatementDef_ID = SrProcessDef.SrStatementDef_ID    
	WHERE MtStatementProcess_ID = @StatementProcessId     

	  
	
/*---------------------------------------------------------------------------------------------------------------------------------
For logs get Month Complete Name
-----------------------------------------------------------------------------------------------------------------------------------*/ 	   

	SET @vStatementProcessIdMonthName = [dbo].[GetSettlementMonthYear](@vMonthId_Current)    
          

/*---------------------------------------------------------------------------------------------------------------------------------
Set log message
-----------------------------------------------------------------------------------------------------------------------------------*/ 	
	
	SET @vOutput = 'Remove data from temp tables:' + @vName + ', Settlement Period:' + CONVERT(VARCHAR(MAX), @vStatementProcessIdMonthName)    
  
	EXEC [dbo].[SystemLogs] @user=@pUserId, @moduleName = 'Settlements'     ,@CrudOperationName = 'Update'    ,@logMessage = @vOutput;    
 
 

END     
