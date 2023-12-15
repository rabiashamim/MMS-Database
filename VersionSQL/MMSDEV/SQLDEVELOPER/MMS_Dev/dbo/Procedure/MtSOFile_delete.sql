/****** Object:  Procedure [dbo].[MtSOFile_delete]    Committed by VersionSQL https://www.versionsql.com ******/

            
  -- exec MtSOFile_delete @MtSOFileMaster_Id=N'861',@UserId=1       
--exec MtSOFile_delete @MtSOFileMaster_Id=N'835',@UserId=1        
--dbo.MtSOFile_delete 1,1      
CREATE procedure dbo.MtSOFile_delete                 
@MtSOFileMaster_Id DECIMAL(18,0),                  
@userID DECIMAL(18,0)                  
AS                  
BEGIN    
  
DECLARE @vMonthId_Current VARCHAR(MAX);    
DECLARE @period VARCHAR(20);   
declare @output VARCHAR(max);  
declare @LuSOFileTemplate_Id int,@LuStatus_Code varchar(4)    
    
SELECT    
 @LuSOFileTemplate_Id = LuSOFileTemplate_Id    
   ,@LuStatus_Code = LuStatus_Code    
FROM MtSOFileMaster    
WHERE MtSOFileMaster_Id = @MtSOFileMaster_Id    
    
    
DECLARE @version INT = 0;    
SELECT    
 @version = MtSOFileMaster_Version    
FROM MtSOFileMaster    
WHERE MtSOFileMaster_Id = @MtSOFileMaster_Id    
    
DECLARE @tempname NVARCHAR(MAX) = NULL;    
SELECT    
 @tempname = LuSOFileTemplate_Name    
FROM LuSOFileTemplate    
WHERE LuSOFileTemplate_Id = @LuSOFileTemplate_Id    
    
    
--if @LuSOFileTemplate_Id=1 /*Marginal Price*/          
--begin          
    
--end          
    
IF @LuSOFileTemplate_Id = 2 /*Generation Availability Data*/    
BEGIN    
DELETE FROM MtAvailibilityData_Interface    
WHERE MtSOFileMaster_Id = @MtSOFileMaster_Id    
DELETE FROM MtAvailibilityData    
WHERE MtSOFileMaster_Id = @MtSOFileMaster_Id    
DELETE FROM MtSOFileMaster    
WHERE MtSOFileMaster_Id = @MtSOFileMaster_Id    
  
  
-------------------------------    
    
--SELECT    
-- @vMonthId_Current = LuAccountingMonth_Id    
--FROM MtSOFileMaster    
--WHERE MtSOFileMaster_Id = @MtSOFileMaster_Id     
--SET @period = [dbo].[GetSettlementMonthYear](@vMonthId_Current)      
--SET @output = 'Data for' + @tempname + 'is removed. Settlement Period:' + CONVERT(VARCHAR(MAX), @period) + ' ,Version:' + CONVERT(VARCHAR(MAX), @version)    
   
--EXEC [dbo].[SystemLogs] @user = @userID    
--        ,@moduleName = 'Data Management'    
--        ,@CrudOperationName = 'Delete'    
--        ,@logMessage = @output    
END    
    
--if @LuSOFileTemplate_Id=3 /*Entitled Generators For Must Run*/          
--begin          
    
--end          
    
--if @LuSOFileTemplate_Id=4 /*Entitled Generators Start*/          
--begin          
    
--end          
    
IF @LuSOFileTemplate_Id = 5 /*Entitled Generators For ASC(Increased Generation) */    
BEGIN    
DELETE FROM MtAscIG_Interface    
WHERE MtSOFileMaster_Id = @MtSOFileMaster_Id    
DELETE FROM MtAscIG    
WHERE MtSOFileMaster_Id = @MtSOFileMaster_Id    
DELETE FROM MtSOFileMaster    
WHERE MtSOFileMaster_Id = @MtSOFileMaster_Id   
  
-----------------------------------  
   
--SELECT    
-- @vMonthId_Current = LuAccountingMonth_Id    
--FROM MtSOFileMaster    
--WHERE MtSOFileMaster_Id = @MtSOFileMaster_Id     
--SET @period = [dbo].[GetSettlementMonthYear](@vMonthId_Current)      
--SET @output= 'Data for' + @tempname + 'is removed. Settlement Period:' + CONVERT(VARCHAR(MAX), @period) + ' ,Version:' + CONVERT(VARCHAR(MAX), @version)    
   
--EXEC [dbo].[SystemLogs] @user = @userID    
--        ,@moduleName = 'Data Management'    
--        ,@CrudOperationName = 'Delete'    
--        ,@logMessage = @output  
END    
    
    
    
    
    
IF @LuSOFileTemplate_Id = 6 /*Entitled Generators For ASC(Reduced Generation) */    
BEGIN    
DELETE FROM MtAscRG_Interface    
WHERE MtSOFileMaster_Id = @MtSOFileMaster_Id    
DELETE FROM MtAscRG    
WHERE MtSOFileMaster_Id = @MtSOFileMaster_Id    
DELETE FROM MtSOFileMaster    
WHERE MtSOFileMaster_Id = @MtSOFileMaster_Id    
----------------------------------------    
  
   
END    
    
    
--if @LuSOFileTemplate_Id=7 /*Black Start Capability*/          
--begin          
    
--end          
    
    
    
IF @LuSOFileTemplate_Id = 8 /*Bilateral Contract*/    
BEGIN    
DELETE FROM MtBilateralContract_Interface    
WHERE MtSOFileMaster_Id = @MtSOFileMaster_Id    
DELETE FROM MtBilateralContract    
WHERE MtSOFileMaster_Id = @MtSOFileMaster_Id    
DELETE FROM MtSOFileMaster    
WHERE MtSOFileMaster_Id = @MtSOFileMaster_Id    
    
  
  
END    
    
UPDATE MtSOFileMaster    
SET MtSOFileMaster_IsDeleted = 1    
WHERE LuStatus_Code <> 'APPR'    
AND MtSOFileMaster_Id = @MtSOFileMaster_Id    
    
  SELECT    
 @vMonthId_Current = LuAccountingMonth_Id    
FROM MtSOFileMaster    
WHERE MtSOFileMaster_Id = @MtSOFileMaster_Id

SET @period = [dbo].[GetSettlementMonthYear](@vMonthId_Current)   
SET @output = 'Data for ' + @tempname + ' is removed. Settlement Period: ' + CONVERT(VARCHAR(MAX), @period) + ' ,Version:' + CONVERT(VARCHAR(MAX), @version)+ ', File Master Id: ' +CONVERT(VARCHAR(MAX), @MtSOFileMaster_Id)    
    
EXEC [dbo].[SystemLogs] @user = @userID    
        ,@moduleName = 'Data Management'    
        ,@CrudOperationName = 'Delete'    
        ,@logMessage = @output  
END
