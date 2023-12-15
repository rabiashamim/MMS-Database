/****** Object:  Procedure [dbo].[RollBacksettlementProcess]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================  
-- Author:  Ali Imran 
-- CREATE date: 
-- ALTER date: 29 august 2023
-- Description: Refactoring and Delete properly.
-- Parameters: 
-- =============================================        
CREATE   Proceduredbo.RollBacksettlementProcess        
	@Year int,        
	@Month int,        
    @StatementProcessId decimal(18,0) ,
	@pIsRollBack BIT=0,
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

 DELETE from MtStatementProcessSteps where MtStatementProcess_ID=@StatementProcessId          
  
 DELETE from [dbo].[BmeStatementDataFinalOutputs_SettlementProcess] where MtStatementProcess_ID=@StatementProcessId          
           
 DELETE FROM BmeStatementDataMpCategoryMonthly_SettlementProcess WHERE  BmeStatementData_Year=@Year and BmeStatementData_Month=@Month and BmeStatementData_StatementProcessId=@StatementProcessId;          

 DELETE FROM BmeStatementDataMpCategoryHourly_SettlementProcess WHERE  BmeStatementData_Year=@Year and BmeStatementData_Month=@Month and BmeStatementData_StatementProcessId=@StatementProcessId;          
      
 DELETE FROM [BmeStatementDataMpMonthly_SettlementProcess] WHERE  BmeStatementData_Year=@Year and BmeStatementData_Month=@Month  and BmeStatementData_StatementProcessId=@StatementProcessId;          

 DELETE FROM BmeStatementDataMpContractHourly_SettlementProcess WHERE  BmeStatementData_Year=@Year and BmeStatementData_Month=@Month  and BmeStatementData_StatementProcessId=@StatementProcessId;          

 DELETE FROM BmeStatementDataCdpContractHourly_SettlementProcess WHERE  BmeStatementData_Year=@Year and BmeStatementData_Month=@Month  and BmeStatementData_StatementProcessId=@StatementProcessId;          
      
 DELETE FROM BmeStatementDataMpHourly_SettlementProcess WHERE  BmeStatementData_Year=@Year and BmeStatementData_Month=@Month and BmeStatementData_StatementProcessId=@StatementProcessId;          
      
 DELETE FROM BmeStatementDataHourly_SettlementProcess WHERE  BmeStatementData_Year=@Year and BmeStatementData_Month=@Month and BmeStatementData_StatementProcessId=@StatementProcessId;          
      
 DELETE FROM BmeStatementDataTspHourly_SettlementProcess WHERE  BmeStatementData_Year=@Year and BmeStatementData_Month=@Month and BmeStatementData_StatementProcessId=@StatementProcessId;          
      
 DELETE FROM BmeStatementDataGenUnitHourly_SettlementProcess WHERE  BmeStatementData_Year=@Year and BmeStatementData_Month=@Month and BmeStatementData_StatementProcessId=@StatementProcessId;          
   
 DELETE FROM BmeStatementDataCdpHourly_SettlementProcess WHERE  BmeStatementData_Year=@Year and BmeStatementData_Month=@Month and BmeStatementData_StatementProcessId=@StatementProcessId;          
      
 DELETE FROM BmeStatementDataCdpOwnerParty_SettlementProcess WHERE  BmeStatementData_StatementProcessId=@StatementProcessId;          
            
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
 
 DELETE FROM BmeStatementDataCDPGenUnit WHERE  BmeStatementData_StatementProcessId=@StatementProcessId;    
 
 IF(@pIsRollBack=0)
 BEGIN
 DELETE FROM BMEInputsSOFilesVersions WHERE  SettlementProcessId=@StatementProcessId;  
 END
 
 END         

/*--------------------------------------------------------------------------------------------------------------------------------------  
* ASC Remove  
*--------------------------------------------------------------------------------------------------------------------------------------*/   
 ELSE IF @vProcessName='ASC'  
 BEGIN  
 
 DELETE from MtStatementProcessSteps where MtStatementProcess_ID=@StatementProcessId   

 DELETE FROM [dbo].[AscStatementDataMpMonthly_SettlementProcess] WHERE AscStatementData_Year=@Year and AscStatementData_Month=@Month and AscStatementData_StatementProcessId= @StatementProcessId      
      
 DELETE FROM [dbo].[AscStatementDataMpZoneMonthly_SettlementProcess] WHERE AscStatementData_Year=@Year and AscStatementData_Month=@Month and AscStatementData_StatementProcessId=@StatementProcessId      
   
 DELETE FROM [dbo].[AscStatementDataZoneMonthly_SettlementProcess] WHERE AscStatementData_Year=@Year and AscStatementData_Month=@Month  and AscStatementData_StatementProcessId=@StatementProcessId      
   
 DELETE FROM [dbo].[AscStatementDataGenMonthly_SettlementProcess] WHERE AscStatementData_Year=@Year and AscStatementData_Month=@Month  and AscStatementData_StatementProcessId=@StatementProcessId      
   
 DELETE FROM [dbo].[AscStatementDataGuMonthly_SettlementProcess] WHERE AscStatementData_Year=@Year and AscStatementData_Month=@Month and AscStatementData_StatementProcessId=@StatementProcessId      
      
 DELETE FROM [dbo].[AscStatementDataGuHourly_SettlementProcess] WHERE  AscStatementData_Year=@Year and AscStatementData_Month=@Month and AscStatementData_StatementProcessId=@StatementProcessId      
   
 DELETE FROM [dbo].[AscStatementDataCdpGuParty_SettlementProcess] WHERE AscStatementData_StatementProcessId= @StatementProcessId      

/*---------------------------------------------------------------------------------------------------------------------------------
Delete tables involve during process
-----------------------------------------------------------------------------------------------------------------------------------*/
    
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
	
	SET @vOutput = 'Process Execution Roll-Backed:' + @vName + ', Settlement Period:' + CONVERT(VARCHAR(MAX), @vStatementProcessIdMonthName)    
  
	EXEC [dbo].[SystemLogs] @user=@pUserId, @moduleName = 'Settlements'     ,@CrudOperationName = 'Update'    ,@logMessage = @vOutput;    
 
 /*****************************************************************************************************
	UPDATED  on 17 august 2023
	Task Id: 3653
	short detail: ESS only works if some new data found, so on rollback we mush update metering data.	
  ******************************************************************************************************/
 IF @vProcessName='BME'  
 BEGIN  

	IF EXISTS(
	SELECT PD.SrStatementDef_ID FROM MtStatementProcess SP
	JOIN SrProcessDef PD ON PD.SrProcessDef_ID=SP.SrProcessDef_ID
	WHERE SP.MtStatementProcess_ID=@StatementProcessId--209
	AND  PD.SrStatementDef_ID=3--ESS
	)
	BEGIN
			

			SELECT @vMonth=M.LuAccountingMonth_Month,@vYear=M.LuAccountingMonth_Year 
			FROM MtStatementProcess SP
			JOIN LuAccountingMonth  M ON M.LuAccountingMonth_Id=LuAccountingMonth_Id_Current
			WHERE MtStatementProcess_ID=@StatementProcessId--209

			UPDATE bvm 
			SET 
				IsAlreadyUsedInBME=0
			FROM 
				MtBvmReading BVM
			WHERE 
				DATEPART(Month,MtBvmReadingIntf_NtdcDateTime)=@vMonth
				AND 	DATEPART(YEAR,MtBvmReadingIntf_NtdcDateTime)=@vYear
				AND IsAlreadyUsedInBME=2
			
/*---------------------------------------------------------------------------------------------------------------------------------
Set log message
-----------------------------------------------------------------------------------------------------------------------------------*/ 
				SET @vOutput = 'Table: MtBvmReading, Update: IsAlreadyUsedInBME, Count: '+ CAST( @@rowcount AS varchar)
				EXEC [dbo].[SystemLogs] @moduleName = 'Settlements'
						   ,@CrudOperationName = 'Update'
						   ,@logMessage = @vOutput;
			
	END
	
END
END     
