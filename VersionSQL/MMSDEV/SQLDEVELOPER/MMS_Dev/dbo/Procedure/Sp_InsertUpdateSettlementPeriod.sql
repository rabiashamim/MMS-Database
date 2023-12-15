/****** Object:  Procedure [dbo].[Sp_InsertUpdateSettlementPeriod]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================  
-- Author:  <Aymen Khalid>  
-- Create date: <24-01-2022>  
-- Description: <Insert & Update of Settlement Period in settings>  
-- =============================================  
CREATE PROCEDURE dbo.Sp_InsertUpdateSettlementPeriod  
 -- Add the parameters for the stored procedure here  
 @ps_LuAccountingMonth_Id int = null  
,@ps_LuAccountingMonth_Month varchar(255)  
,@ps_LuAccountingMonth_MonthShort varchar(255)  
,@ps_LuAccountingMonth_MonthName varchar(255)  
,@ps_LuAccountingMonth_Year int  
,@ps_LuAccountingMonth_IsDeleted bit  
,@ps_PeriodTypeID int   
,@ps_LuStatus_Code varchar(255)  
,@ps_LuAccountingMonth_Description varchar(255)  
,@pi_UserId INT
,@pd_LuAccountingMonth_FromDate DATE
,@pd_LuAccountingMonth_ToDate DATE
  
AS  
BEGIN  
  
IF(@ps_LuAccountingMonth_Id is null)  
BEGIN  
RAISERROR('error from sp',16,-1);
RETURN;
-----------------------------------Insertion Case-----------------------  
INSERT INTO [dbo].[LuAccountingMonth]  
                ([LuAccountingMonth_Id]  
                ,[LuAccountingMonth_Month]  
                ,[LuAccountingMonth_MonthShort]  
                ,[LuAccountingMonth_MonthName]  
                ,[LuAccountingMonth_Year]  
                ,[LuAccountingMonth_CreatedBy]  
                ,[LuAccountingMonth_CreatedOn]                                
                ,[LuAccountingMonth_IsDeleted]  
                ,[PeriodTypeID]  
                ,[LuStatus_Code]  
                ,[LuAccountingMonth_Description]
				,LuAccountingMonth_FromDate
				,LuAccountingMonth_ToDate)  
    OUTPUT Inserted.LuAccountingMonth_Id  
            VALUES(  
    (SELECT IsNull(MAX( LuAccountingMonth_Id ) + 1,1) from LuAccountingMonth)  
    ,@ps_LuAccountingMonth_Month  
    ,@ps_LuAccountingMonth_MonthShort   
    ,@ps_LuAccountingMonth_MonthName  
    ,@ps_LuAccountingMonth_Year   
    ,@pi_UserId   
    ,GETUTCDATE()    
    ,@ps_LuAccountingMonth_IsDeleted   
    ,@ps_PeriodTypeID    
    ,@ps_LuStatus_Code   
    ,@ps_LuAccountingMonth_Description
	,@pd_LuAccountingMonth_FromDate
	,@pd_LuAccountingMonth_ToDate
    )  
    -- SELECT SCOPE_IDENTITY()      
      
END  
ELSE  
BEGIN  
------------------------------Update Case---------------  
UPDATE [dbo].[LuAccountingMonth]  
    SET   
    [LuAccountingMonth_Month] = @ps_LuAccountingMonth_Month  
    ,[LuAccountingMonth_MonthName] = @ps_LuAccountingMonth_MonthName  
    ,[LuAccountingMonth_Year] = @ps_LuAccountingMonth_Year  
    ,[LuAccountingMonth_ModifiedBy] = @pi_UserId  
    ,[LuAccountingMonth_ModifiedOn] = GETUTCDATE()  
    ,[LuAccountingMonth_MonthShort] = @ps_LuAccountingMonth_MonthShort  
    ,[LuAccountingMonth_IsDeleted] = @ps_LuAccountingMonth_IsDeleted                                      
    ,[PeriodTypeID] = @ps_PeriodTypeID  
    ,[LuStatus_Code] = @ps_LuStatus_Code  
    ,[LuAccountingMonth_Description] = @ps_LuAccountingMonth_Description
	,[LuAccountingMonth_FromDate] = @pd_LuAccountingMonth_FromDate
	,[LuAccountingMonth_ToDate] = @pd_LuAccountingMonth_ToDate
 WHERE 
	[LuAccountingMonth_Id] = @ps_LuAccountingMonth_Id  
  
   SELECT @ps_LuAccountingMonth_Id  
END  
  
END  
