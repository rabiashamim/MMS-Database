/****** Object:  Procedure [dbo].[PermanentRemovesettlementProcess]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================      
-- Author:  Ali Imran (.Net/SQL Developer)      
-- CREATE date: 25 August  
-- ALTER date:   
-- Description:               
-- Parameters: @Year, @Month, @StatementProcessId      
-- =============================================       
        
CREATE     PROCEDURE dbo.PermanentRemovesettlementProcess          
 @Year int,          
 @Month int,          
    @StatementProcessId decimal(18,0)          
AS          
BEGIN          
  
/*--------------------------------------------------------------------------------------------------------------------------------------  
*  
*--------------------------------------------------------------------------------------------------------------------------------------*/       
      
 DECLARE   
  @moduleid INT = 0  
 ,@name NVARCHAR(MAX)  
 ,@output VARCHAR(max)  
 ,@StatementProcessId1 VARCHAR(20)   
 ,@vMonth INT  
 ,@vYear INT  
 ,@vProcessName VARCHAR(4);  
  
select @vProcessName=D.SrProcessDef_Name from MtStatementProcess SP  
JOIN SrProcessDef D ON SP.SrProcessDef_ID=D.SrProcessDef_ID  
where MtStatementProcess_ID=@StatementProcessId
  
/*--------------------------------------------------------------------------------------------------------------------------------------  
* BME remove  
*--------------------------------------------------------------------------------------------------------------------------------------*/     
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
  
 DELETE FROM BMEInputsSOFilesVersions WHERE  SettlementProcessId=@StatementProcessId;  
  
 END  
/*--------------------------------------------------------------------------------------------------------------------------------------  
* ASC Remove  
*--------------------------------------------------------------------------------------------------------------------------------------*/   
 ELSE IF @vProcessName='ASC'  
 BEGIN  
  
    DELETE FROM [dbo].[AscStatementDataMpMonthly_SettlementProcess] WHERE AscStatementData_Year=@Year and AscStatementData_Month=@Month and AscStatementData_StatementProcessId= @StatementProcessId      
      
 DELETE FROM [dbo].[AscStatementDataMpZoneMonthly_SettlementProcess] WHERE AscStatementData_Year=@Year and AscStatementData_Month=@Month and AscStatementData_StatementProcessId=@StatementProcessId      
   
 DELETE FROM [dbo].[AscStatementDataZoneMonthly_SettlementProcess] WHERE AscStatementData_Year=@Year and AscStatementData_Month=@Month  and AscStatementData_StatementProcessId=@StatementProcessId      
   
 DELETE FROM [dbo].[AscStatementDataGenMonthly_SettlementProcess] WHERE AscStatementData_Year=@Year and AscStatementData_Month=@Month  and AscStatementData_StatementProcessId=@StatementProcessId      
   
 DELETE FROM [dbo].[AscStatementDataGuMonthly_SettlementProcess] WHERE AscStatementData_Year=@Year and AscStatementData_Month=@Month and AscStatementData_StatementProcessId=@StatementProcessId      
      
 DELETE FROM [dbo].[AscStatementDataGuHourly_SettlementProcess] WHERE  AscStatementData_Year=@Year and AscStatementData_Month=@Month and AscStatementData_StatementProcessId=@StatementProcessId      
   
 DELETE FROM [dbo].[AscStatementDataCdpGuParty_SettlementProcess] WHERE AscStatementData_StatementProcessId= @StatementProcessId      
    
 DELETE FROM [dbo].[AscStatementDataMpMonthly] WHERE AscStatementData_Year=@Year and AscStatementData_Month=@Month and AscStatementData_StatementProcessId= @StatementProcessId      
      
 DELETE FROM [dbo].[AscStatementDataMpZoneMonthly] WHERE AscStatementData_Year=@Year and AscStatementData_Month=@Month and AscStatementData_StatementProcessId=@StatementProcessId      
   
 DELETE FROM [dbo].[AscStatementDataZoneMonthly] WHERE AscStatementData_Year=@Year and AscStatementData_Month=@Month  and AscStatementData_StatementProcessId=@StatementProcessId      
   
 DELETE FROM [dbo].[AscStatementDataGenMonthly] WHERE AscStatementData_Year=@Year and AscStatementData_Month=@Month  and AscStatementData_StatementProcessId=@StatementProcessId      
   
 DELETE FROM [dbo].[AscStatementDataGuMonthly] WHERE AscStatementData_Year=@Year and AscStatementData_Month=@Month and AscStatementData_StatementProcessId=@StatementProcessId      
      
 DELETE FROM [dbo].[AscStatementDataGuHourly] WHERE  AscStatementData_Year=@Year and AscStatementData_Month=@Month and AscStatementData_StatementProcessId=@StatementProcessId      
   
 DELETE FROM [dbo].[AscStatementDataCdpGuParty] WHERE AscStatementData_StatementProcessId= @StatementProcessId      
  
 END  
END
