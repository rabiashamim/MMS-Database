/****** Object:  Procedure [dbo].[MtSOFile_delete]    Committed by VersionSQL https://www.versionsql.com ******/

      
    
--exec [dbo].[SOAvailabilityDataValidation] 295,100        
CREATE procedure [dbo].[MtSOFile_delete]           
@MtSOFileMaster_Id DECIMAL(18,0),            
@userID DECIMAL(18,0)            
AS            
BEGIN            
declare @LuSOFileTemplate_Id int,@LuStatus_Code varchar(4)    
    
SELECT @LuSOFileTemplate_Id=LuSOFileTemplate_Id ,@LuStatus_Code=LuStatus_Code FROM MtSOFileMaster where MtSOFileMaster_Id= @MtSOFileMaster_Id    
    
--if @LuSOFileTemplate_Id=1 /*Marginal Price*/    
--begin    
    
--end    
    
if @LuSOFileTemplate_Id=2 /*Generation Availability Data*/    
begin    
delete from MtAvailibilityData_Interface where MtSOFileMaster_Id=@MtSOFileMaster_Id    
delete from MtAvailibilityData where MtSOFileMaster_Id=@MtSOFileMaster_Id    
delete from MtSOFileMaster where MtSOFileMaster_Id=@MtSOFileMaster_Id    
end    
    
--if @LuSOFileTemplate_Id=3 /*Entitled Generators For Must Run*/    
--begin    
    
--end    
    
--if @LuSOFileTemplate_Id=4 /*Entitled Generators Start*/    
--begin    
    
--end    
    
if @LuSOFileTemplate_Id=5 /*Entitled Generators For ASC(Increased Generation) */    
begin    
delete from MtAscIG_Interface where MtSOFileMaster_Id=@MtSOFileMaster_Id    
delete from MtAscIG where MtSOFileMaster_Id=@MtSOFileMaster_Id    
delete from MtSOFileMaster where MtSOFileMaster_Id=@MtSOFileMaster_Id    
end    
    
  
  
    
    
if @LuSOFileTemplate_Id=6 /*Entitled Generators For ASC(Reduced Generation) */    
begin
delete from MtAscRG_Interface where MtSOFileMaster_Id=@MtSOFileMaster_Id    
delete from MtAscRG where MtSOFileMaster_Id=@MtSOFileMaster_Id    
delete from MtSOFileMaster where MtSOFileMaster_Id=@MtSOFileMaster_Id  
    
end    
    
    
--if @LuSOFileTemplate_Id=7 /*Black Start Capability*/    
--begin    
    
--end    
    
    
    
if @LuSOFileTemplate_Id=8 /*Bilateral Contract*/    
begin    
delete from MtBilateralContract_Interface where MtSOFileMaster_Id=@MtSOFileMaster_Id    
delete from MtBilateralContract where MtSOFileMaster_Id=@MtSOFileMaster_Id    
delete from MtSOFileMaster where MtSOFileMaster_Id=@MtSOFileMaster_Id    
end    
    
  update MtSOFileMaster set MtSOFileMaster_IsDeleted=1 where  LuStatus_Code <> 'APPR' and MtSOFileMaster_Id= @MtSOFileMaster_Id  
    
END
