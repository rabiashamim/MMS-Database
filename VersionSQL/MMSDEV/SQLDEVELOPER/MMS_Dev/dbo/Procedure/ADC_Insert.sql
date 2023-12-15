/****** Object:  Procedure [dbo].[ADC_Insert]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================    
-- Author:  ALI IMRAN  
-- CREATE date: 7 march 2023  
-- ALTER date:   
-- Description:   
-- =============================================   
CREATE   PROCEDURE dbo.ADC_Insert @pADC_Id DECIMAL(18, 0) = NULL  
, @pGenerator_Id DECIMAL(18, 0)  
, @pADC_Date DATE  
, @pADC_Value DECIMAL(38, 13)  
, @pUserId DECIMAL(18, 0)  
AS  
BEGIN  
 SET NOCOUNT ON;  
BEGIN TRY     
  
/********************************************************************************************/  
  
  
  
IF EXISTS( SELECT  1 FROM [dbo].[MtAnnualDependableCapacityADC] WHERE (@pADC_Id IS NULL OR MtAnnualDependableCapacityADC_Id<>@pADC_Id)  
AND MtAnnualDependableCapacityADC_Date=@pADC_Date  
AND MtAnnualDependableCapacityADC_IsDeleted=0  
AND MtGenerator_Id=@pGenerator_Id)  
BEGIN  
RAISERROR('Generator with the same ADC Date already exists', 16, 1) 
RETURN
END  
  
IF EXISTS( select 1 from [dbo].[MtAnnualDependableCapacityADC] adc inner join MtGenerator
on MtGenerator.MtGenerator_Id=adc.MtGenerator_Id
where @pADC_Date < COD_Date AND MtGenerator.MtGenerator_Id=@pGenerator_Id )  --AND MtGenerator.MtGenerator_Id=@pGenerator_Id)  
BEGIN  
RAISERROR('ADC Date cannot be less than COD Date', 16, 1)
RETURN
END  
  
 IF ISNULL(@pADC_Id,0)=0  
 BEGIN  
  INSERT INTO [dbo].[MtAnnualDependableCapacityADC] ([MtGenerator_Id]  
  , [MtAnnualDependableCapacityADC_Date]  
  , [MtAnnualDependableCapacityADC_Value]  
  , [MtAnnualDependableCapacityADC_CreatedBy]  
  , [MtAnnualDependableCapacityADC_CreatedOn])  
  
   VALUES (@pGenerator_Id  
   , @pADC_Date  
   , @pADC_Value  
   , @pUserId, GETDATE())  
  
 END  
/********************************************************************************************/  
 ELSE  
 BEGIN  
  UPDATE [dbo].[MtAnnualDependableCapacityADC]  
  SET [MtGenerator_Id] = @pGenerator_Id  
     ,[MtAnnualDependableCapacityADC_Date] = @pADC_Date  
     ,[MtAnnualDependableCapacityADC_Value] = @pADC_Value  
     ,[MtAnnualDependableCapacityADC_ModifiedBy] = @pUserId  
     ,[MtAnnualDependableCapacityADC_ModifiedOn] = GETDATE()  
  
  WHERE MtAnnualDependableCapacityADC_Id = @pADC_Id  
 END  
/********************************************************************************************/  
 END TRY  
BEGIN CATCH  
  SELECT  
    ERROR_NUMBER() AS ErrorNumber,  
    ERROR_STATE() AS ErrorState,  
    ERROR_SEVERITY() AS ErrorSeverity,  
    ERROR_PROCEDURE() AS ErrorProcedure,  
    ERROR_LINE() AS ErrorLine,  
    ERROR_MESSAGE() AS ErrorMessage;  
END CATCH;  
  
  
END
