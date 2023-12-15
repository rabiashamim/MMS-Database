/****** Object:  Procedure [dbo].[ContractReg_GenerateCapacityProfile]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================      
-- Author:  Ammama Gill                        
-- CREATE date: Nov 28, 2022                         
-- ALTER date:                         
-- Reviewer:                        
-- Description: Generate capacity profile of the given year and Master File ID.                        
-- =============================================                         
-- =============================================                         
--dbo.ContractReg_GenerateCapacityProfile 2040, 21,1                      
    
CREATE   PROCEDURE dbo.ContractReg_GenerateCapacityProfile (
@pEffectiveFromDate Date,
@pEffectiveToDate Date,
@psoFileMasterId DECIMAL(18, 0),    
@pUserId INT)    
AS    
BEGIN    
    
 BEGIN TRY    
    
    
    
  DROP TABLE IF EXISTS #YearDates    
  DROP TABLE IF EXISTS #CapacityContracts    ;
    
  -- 2. Generate a sequence of dates for the complete year.                    
  WITH dates_CTE (date)    
  AS    
  (SELECT    
    @pEffectiveFromDate    
   UNION ALL    
   SELECT    
    DATEADD(DAY, 1, date)    
   FROM dates_CTE    
   WHERE date < @pEffectiveToDate)    
  SELECT    
   * INTO #YearDates    
  FROM dates_CTE    
  OPTION (MAXRECURSION 0);    
    
  -- 3. Get the capacity profile of all the contracts which cover the year in question.                     
  SELECT    
   mcpc.MtContractRegistration_Id    
     ,mcpc.MtContractProfileCapacity_Id    
     ,mcpc.MtContractProfileCapacity_DateFrom    
     ,mcpc.MtContractProfileCapacity_DateTo    
     ,mcpc.MtContractProfileCapacity_ContractQuantity_MW    
     ,mcpc.MtContractProfileCapacity_CapQuantity_MW    
     ,mcpc.MtContractProfileCapacity_Percentage    
     ,mcpc.MtContractProfileCapacity_IsGuaranteed    
     ,mcr.MtContractRegistration_SellerId    
     ,mcr.MtContractRegistration_BuyerId    
     ,mcr.MtContractRegistration_BuyerCategoryId    
     ,mcr.MtContractRegistration_SellerCategoryId    
     ,mcr.SrContractType_Id INTO #CapacityContracts    
  FROM MtContractProfileCapacity mcpc    
  INNER JOIN MtContractRegistration mcr    
   ON mcpc.MtContractRegistration_Id = mcr.MtContractRegistration_Id    
  WHERE 
  --@pEffectiveFromDate >=mcr.MtContractRegistration_EffectiveFrom and @pEffectiveToDate<=mcr.MtContractRegistration_EffectiveTo
  (mcr.MtContractRegistration_EffectiveFrom between @pEffectiveFromDate and @pEffectiveToDate OR
mcr.MtContractRegistration_EffectiveTo between @pEffectiveFromDate and @pEffectiveToDate OR
(MtContractRegistration_EffectiveFrom <= @pEffectiveFromDate and MtContractRegistration_EffectiveTo>= @pEffectiveToDate))

  AND ISNULL(mcpc.MtContractProfileCapacity_IsDeleted, 0) = 0    
  AND ISNULL(mcr.MtContractRegistration_IsDeleted, 0) = 0    
  AND mcr.MtContractRegistration_Status = 'CATV'    
  AND mcr.MtContractRegistration_ApprovalStatus IN ('CAAP', 'CAMA','CAWA')
  --AND mcr.MtContractRegistration_ApprovalStatus IN ('CAAP', 'CAMA', 'CADG', 'CAMR', 'CASR', 'CAWA')    
    
  IF NOT EXISTS (SELECT    
     1    
    FROM #CapacityContracts cc)    
  BEGIN    
   DECLARE @vYearString VARCHAR(50) =CAST(@pEffectiveFromDate  AS VARCHAR(20)) + ' and ' +  CAST(@pEffectiveToDate  AS VARCHAR(20));
RAISERROR ('No active capacity contracts exist for the period %s', 16, -1, @vYearString)    
   RETURN;    
  END    
    
    
    
  -- 4. Insert into MtBilateralContractCapacity by taking a cartesian product of                     
  -- all the dates generated in step 1 and the data filtered in step 3.                    
  INSERT INTO MtBilateralContractCapacity (MtBilateralContractCapacity_RowNumber,    
  MtContractRegistration_Id,    
  MtSOFileMaster_Id,    
  MtBilateralContractCapacity_Date,    
  MtContractRegistration_SellerId,    
  MtContractRegistration_BuyerId,    
  MtContractRegistration_BuyerCategoryId,    
  MtContractRegistration_SellerCategoryId,    
  SrContractType_Id,    
  MtBilateralContractCapacity_IsGuarenteed,    
  MtBilateralContractCapacity_Percentage,    
  MtBilateralContractCapacity_ContractedQuantity,    
  MtBilateralContractCapacity_CapQuantity,    
  MtBilateralContractCapacity_CreatedBy,    
  MtBilateralContractCapacity_CreatedOn)    
   SELECT    
    ROW_NUMBER() OVER (ORDER BY cc.MtContractRegistration_Id) AS RowNumber    
      ,cc.MtContractRegistration_Id    
      ,@psoFileMasterId AS MtSOFileMaster_Id    
      ,yd.Date    
      ,cc.MtContractRegistration_SellerId    
      ,cc.MtContractRegistration_BuyerId    
      ,cc.MtContractRegistration_BuyerCategoryId    
      ,cc.MtContractRegistration_SellerCategoryId    
      ,cc.SrContractType_Id    
      ,cc.MtContractProfileCapacity_IsGuaranteed    
      ,cc.MtContractProfileCapacity_Percentage    
      ,cc.MtContractProfileCapacity_ContractQuantity_MW    
      ,cc.MtContractProfileCapacity_CapQuantity_MW    
      ,@pUserId    
      ,GETDATE()    
   FROM #YearDates yd    
    ,#CapacityContracts cc    
    
   WHERE cc.MtContractProfileCapacity_DateFrom <= yd.Date    
   AND cc.MtContractProfileCapacity_DateTo >= yd.Date    
    
   ORDER BY cc.MtContractRegistration_Id;    
    
    
  --5. Update the MtSoFileMaster table - set the total number of records.                
  DECLARE @vTotalRecords BIGINT = 0;    
  SELECT    
   @vTotalRecords = COUNT(1)    
  FROM MtBilateralContractCapacity    
  WHERE MtSOFileMaster_Id = @psoFileMasterId    
  AND ISNULL(MtBilateralContractCapacity_IsDeleted, 0) = 0;    
    
  UPDATE MtSOFileMaster    
  SET TotalRecords = @vTotalRecords    
  WHERE MtSOFileMaster_Id = @psoFileMasterId;    
    
 END TRY    
 BEGIN CATCH    
  SELECT    
   ERROR_NUMBER() AS ErrorNumber    
     ,ERROR_STATE() AS ErrorState    
     ,ERROR_SEVERITY() AS ErrorSeverity    
     ,ERROR_PROCEDURE() AS ErrorProcedure    
     ,ERROR_LINE() AS ErrorLine    
     ,ERROR_MESSAGE() AS ErrorMessage;    
 END CATCH;    
END
