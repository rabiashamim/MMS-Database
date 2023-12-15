/****** Object:  Procedure [dbo].[RollBacksettlementProcess_bk_29_08_2023]    Committed by VersionSQL https://www.versionsql.com ******/

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  
    
        
Create   PROCEDURE dbo.RollBacksettlementProcess_bk_29_08_2023        
	@Year int,        
	@Month int,        
    @StatementProcessId decimal(18,0)        
AS        
BEGIN        
select 1;        
    
	DECLARE 
	 @moduleid INT = 0
	,@name NVARCHAR(MAX)
	,@output VARCHAR(max)
	,@StatementProcessId1 VARCHAR(20) 
	,@vMonth INT
	,@vYear INT;
	 
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
          
      
       
	
	SELECT    @moduleid = SrProcessDef_ID    FROM MtStatementProcess    WHERE MtStatementProcess_ID = @StatementProcessId    

	   

	SELECT    @name = CONCAT(SrProcessDef_Name, '-', SrStatementDef_Name)    FROM MtStatementProcess    
	INNER JOIN SrProcessDef    ON SrProcessDef.SrProcessDef_ID = MtStatementProcess.SrProcessDef_ID    
	INNER JOIN SrStatementDef    ON SrStatementDef.SrStatementDef_ID = SrProcessDef.SrStatementDef_ID    
	WHERE MtStatementProcess_ID = @StatementProcessId    AND SrProcessDef.SrProcessDef_ID = @moduleid    

	DECLARE @vMonthId_Current VARCHAR(MAX);    
	
	SELECT    @vMonthId_Current = LuAccountingMonth_Id_Current    FROM MtStatementProcess    WHERE MtStatementProcess_ID = @StatementProcessId    
    
	   

	SET @StatementProcessId1 = [dbo].[GetSettlementMonthYear](@vMonthId_Current)    
          
	
	
	SET @output = 'Process Execution Roll-Backed:' + @name + ', Settlement Period:' + CONVERT(VARCHAR(MAX), @StatementProcessId1)    
  
	EXEC [dbo].[SystemLogs] @moduleName = 'Settlements'     ,@CrudOperationName = 'Update'    ,@logMessage = @output;    
 
 /*****************************************************************************************************
	UPDATED  on 17 august 2023
	Task Id: 3653
	short detail: ESS only works if some new data found, so on rollback we mush update metering data.	
    ******************************************************************************************************/
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
			
	
				SET @output = 'Table: MtBvmReading, Update: IsAlreadyUsedInBME, Count: '+ CAST( @@rowcount AS varchar)
				EXEC [dbo].[SystemLogs] @moduleName = 'Settlements'
						   ,@CrudOperationName = 'Update'
						   ,@logMessage = @output;
			
	END
	

END     
