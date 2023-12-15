/****** Object:  Procedure [dbo].[FCC_Execution_bk24May23]    Committed by VersionSQL https://www.versionsql.com ******/

-- ================================================================================        
-- Author:  Ali IMRAN      
-- CREATE date: 10 Apr 2023      
-- ALTER date:       
-- Description:       
-- =================================================================================       
-- [dbo].[FCC_Execution] 1,63,52      
CREATE PROCEDURE dbo.FCC_Execution_bk24May23 @pUserId INT    
, @pGeneratorId DECIMAL(18, 0)    
, @pMtFCDMaster_Id DECIMAL(18, 0)    
AS    
BEGIN    
    
 BEGIN TRY    
     

 /*****************************************************************************************  
/*Get max approved FCC ID for reference IS to be used in revision process*/
*****************************************************************************************/    
declare @vMtFCCMaster_RefernceId decimal(18,9)
select @vMtFCCMaster_RefernceId=max(a.MtFCCMaster_Id) 
from MtFCCAMaster m inner join MtFCCAGenerator a on a.MtFCCAMaster_Id=m.MtFCCAMaster_Id
inner join MtFCCMaster b on a.MtFCCMaster_Id=b.MtFCCMaster_Id and b.MtGenerator_Id=a.MtGenerator_Id
where b.MtGenerator_Id=@pGeneratorId
and MtFCCAMaster_Status in ('Completed','Executed') 


    
  /*****************************************************************************************      
     Insert INTO Firm Capacity Certificate      
     *****************************************************************************************/    
  INSERT INTO [dbo].[MtFCCMaster] ([MtGenerator_Id]    
  , [MtPartyRegistration_Id]    
  , [MtFCDMaster_Id]    
  , [LuStatus_Code]    
  , [MtFCCMaster_ApprovalCode]    
  , [LuFirmCapacityType_Id]    
  , [MtFCCMaster_InitialFirmCapacity]    
  , [MtFCCMaster_TotalCertificates]    
  , [MtFCCMaster_CreatedBy]    
  , [MtFCCMaster_CreatedOn]
  , MtFCCMaster_RefernceId)    
   SELECT    
    FCDG.MtGenerator_Id AS [GeneratorID]    
      ,G.MtPartyRegisteration_Id    
      ,FCDG.MtFCDMaster_Id    
      ,'InProcess'    
      ,'Draft'    
      ,CASE    
     WHEN (G.COD_Date IS NULL OR    
      DATEDIFF(DAY, G.COD_Date, GETDATE()) < 1) THEN 1    
     WHEN DATEDIFF(DAY, G.COD_Date, GETDATE()) < 1095 THEN 2    
     WHEN DATEDIFF(DAY, G.COD_Date, GETDATE()) >= 1095 THEN 3    
     ELSE NULL    
    END    
      ,ISNULL(FCDG.MtFCDGenerators_InitialFirmCapacity, 0) AS [InitialFirmCapacity]    
    
      ,(SELECT    
      RV.RuReferenceValue_Value    
     FROM SrReferenceType RT    
     JOIN RuReferenceValue RV    
      ON RT.SrReferenceType_Id = RV.SrReferenceType_Id    
     WHERE RT.SrReferenceType_Name = 'Firm Capacity Certificate Unit')    
    * 100 * FCDG.MtFCDGenerators_InitialFirmCapacity    
      ,@pUserId    
      ,GETDATE()
	  ,@vMtFCCMaster_RefernceId
   FROM MtFCDGenerators FCDG    
   INNER JOIN vw_GeneratorParties G    
    ON FCDG.MtGenerator_Id = G.MtGenerator_Id    
   WHERE FCDG.MtGenerator_Id = @pGeneratorId    
   AND FCDG.MtFCDMaster_Id = @pMtFCDMaster_Id --Ammama      
    
  DECLARE @vFCCMasterId DECIMAL(18, 0) = @@identity    
    
    
  EXEC [dbo].[FCD_InsertProcessLogs] @pMtFCDMaster_Id = @vFCCMasterId    
            ,@pStepNo = 0    
            ,@pStatus = 1    
            ,@pMessage = 'Firm Capacity Certificates Step 0: Validations started'    
            ,@pUserId = @pUserId    
            ,@pSrFCDProcessDef_Id = 2    
    
  EXEC [dbo].[FCD_InsertProcessLogs] @pMtFCDMaster_Id = @vFCCMasterId    
            ,@pStepNo = 0    
            ,@pStatus = 2    
            ,@pMessage = 'Firm Capacity Certificates Step 0: Validations completed'    
            ,@pUserId = @pUserId    
            ,@pSrFCDProcessDef_Id = 2    
    
  EXEC [dbo].[FCD_InsertProcessLogs] @pMtFCDMaster_Id = @vFCCMasterId    
            ,@pStepNo = 1    
            ,@pStatus = 1    
            ,@pMessage = 'Firm Capacity Certificates Step 1: Generate Firm Capacity Certificates started'    
            ,@pUserId = @pUserId    
            ,@pSrFCDProcessDef_Id = 2    
    
    
  /**************************************************************************************************************/    
    
  /*****************************************************************************************      
     Temporary: Issuance Date – Date of Issuance      
     Initial-Permanent:  Issuance Date – Date of Issuance      
     Permanent: Issuance Date – Date of Issuance of Initial-Permanent      
     *****************************************************************************************/    
    
  UPDATE FCC    
    
  SET FCC.[MtFCCMaster_IssuanceDate] =    
  CASE    
   WHEN FCC.LuFirmCapacityType_Id IN (1, 2) THEN GETDATE()    
   WHEN FCC.[LuFirmCapacityType_Id] = 3 AND    
    FCC.[MtFCCMaster_IssuanceDate] IS NULL THEN GETDATE()    
  END,    
  FCC.MtFCCMaster_ExecutionTime = GETDATE()    
  FROM [dbo].[MtFCCMaster] FCC    
  WHERE FCC.MtFCCMaster_Id = @vFCCMasterId    
    
  /*****************************************************************************************      
     Temporary: Expiry – (Expected) COD date      
     Initial-Permanent: Expiry – 3 Years from date of issuance      
     Permanent: Expiry – 20 Years from date of issuance of Initial-Permanent      
     *****************************************************************************************/    
    
  --UPDATE FCC    
  --SET FCC.[MtFCCMaster_ExpiryDate] =    
  --CASE    
  -- WHEN FCC.[LuFirmCapacityType_Id] = 1 THEN G.COD_Date    
  -- WHEN FCC.LuFirmCapacityType_Id = 2 THEN DATEADD(YEAR, 3, FCC.MtFCCMaster_IssuanceDate)    
  -- WHEN FCC.LuFirmCapacityType_Id = 3 THEN DATEADD(YEAR, 20, FCC.MtFCCMaster_IssuanceDate)    
  --END    
  --FROM [dbo].[MtFCCMaster] FCC    
  --JOIN vw_GeneratorParties G    
  -- ON FCC.MtGenerator_Id = G.MtGenerator_Id    
  --WHERE FCC.MtFCCMaster_Id = @vFCCMasterId    
    
  UPDATE FCC    
  SET FCC.[MtFCCMaster_ExpiryDate] =    
  CASE    
   WHEN FCC.[LuFirmCapacityType_Id] = 1 THEN G.COD_Date    
   WHEN FCC.LuFirmCapacityType_Id = 2 THEN DATEADD(YEAR, 3, FCC.MtFCCMaster_IssuanceDate)    
   WHEN FCC.LuFirmCapacityType_Id = 3 THEN CASE    
    WHEN DATEDIFF(DAY, G.COD_Date, FCC.MtFCCMaster_IssuanceDate) > 1095 THEN DATEADD(YEAR, 20, G.COD_Date)    
    ELSE DATEADD(YEAR, 20, FCC.MtFCCMaster_IssuanceDate)    
   END    
  END    
  FROM [dbo].[MtFCCMaster] FCC    
  JOIN vw_GeneratorParties G    
   ON FCC.MtGenerator_Id = G.MtGenerator_Id    
  WHERE FCC.MtFCCMaster_Id = @vFCCMasterId    
    
  /*****************************************************************************************      
     Certificate Number Generation      
     *****************************************************************************************/    
    
  DECLARE @i INTEGER = 0;    
  DECLARE @vTotalCertificate INT    
      ,@vGeneratorId VARCHAR(4);    
    
  SELECT    
   @vGeneratorId = CAST(MtGenerator_Id AS VARCHAR(4))    
     ,@vTotalCertificate = FCC.MtFCCMaster_TotalCertificates    
  FROM MtFCCMaster FCC    
  WHERE MtFCCMaster_Id = @vFCCMasterId    
    
    
  DECLARE @vFuelTypeId VARCHAR(2) = (SELECT TOP 1    
    CAST(FT.SrFuelType_Id AS VARCHAR(5))    
   FROM MtGenerationUnit GU    
   JOIN SrFuelType FT    
    ON GU.SrFuelType_Code = FT.SrFuelType_Code    
   WHERE MtGenerator_Id = @vGeneratorId)    
    
  SET @vFuelTypeId = RIGHT('00' + @vFuelTypeId, 2)    
    
  SET @vGeneratorId = (SELECT    
    RIGHT('0000' + CAST(MtGenerator_Id AS VARCHAR(5)), 4)    
   FROM MtFCCMaster FCC    
   WHERE MtFCCMaster_Id = @vFCCMasterId)    
    
    
    
  DROP TABLE IF EXISTS #CertificateNumbers    
  CREATE TABLE #CertificateNumbers (    
   Certificate_Number NVARCHAR(MAX)    
  )    
    
  --SET @vTotalCertificate = 10; -- Ammama      
  SET @i = 0;    
  WHILE @i < @vTotalCertificate    
  BEGIN    
  INSERT INTO #CertificateNumbers    
   SELECT    
    @vGeneratorId    
    + '-' + @vFuelTypeId    
    + '-' + RIGHT('000000' + CAST(@i AS VARCHAR(6)), 6)    
    
  SET @i = @i + 1;    
  END;    
  /*****************************************************************************************      
     Insert into [MtFCCDetails]      
     *****************************************************************************************/    
  INSERT INTO [dbo].[MtFCCDetails] ([MtFCCMaster_Id]    
  , [MtFCCDetails_CertificateId]    
  , [MtFCCDetails_Status]    
  , [MtFCCDetails_IsCancelled]    
  , [MtFCCDetails_CreatedBy]    
  , [MtFCCDetails_CreatedOn])    
   SELECT    
    @vFCCMasterId    
      ,Certificate_Number    
      ,0    
      ,0    
      ,@pUserId    
      ,GETDATE()    
   FROM #CertificateNumbers    
    
  /*****************************************************************************************/    
    
  EXEC [dbo].[FCD_InsertProcessLogs] @pMtFCDMaster_Id = @vFCCMasterId    
            ,@pStepNo = 1    
            ,@pStatus = 2    
            ,@pMessage = 'Firm Capacity Certificates Step 1: Generate Firm Capacity Certificates completed'    
            ,@pUserId = @pUserId    
            ,@pSrFCDProcessDef_Id = 2    
    
  -- Set Execution status to 'Executed'            
  UPDATE MtFCCMaster    
  SET LuStatus_Code = 'Executed'    
  , MtFCCMaster_ModifiedBy=@pUserId    
  , MtFCCMaster_ModifiedOn=GETDATE()    
  WHERE MtFCCMaster_Id = @vFCCMasterId    
    
 END TRY    
 BEGIN CATCH    
  --interrupted state          
  DECLARE @vErrorMessage VARCHAR(MAX) = '';    
  SELECT    
   @vErrorMessage = ERROR_MESSAGE();    
    
  EXEC [dbo].[FCD_InsertProcessLogs] @pMtFCDMaster_Id = @vFCCMasterId    
            ,@pStepNo = 1    
            ,@pStatus = 3    
            ,@pMessage = @vErrorMessage    
            ,@pUserId = @pUserId    
            ,@pSrFCDProcessDef_Id = 2    
    
  UPDATE MtFCCMaster    
  SET LuStatus_Code = 'Interrupted'    
     ,MtFCCMaster_ApprovalCode = 'Draft'    
  WHERE MtFCCMaster_Id = @vFCCMasterId    
    
    
    
  RAISERROR (@vErrorMessage, 16, -1);    
  RETURN;    
 END CATCH    
    
END
