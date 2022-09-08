/****** Object:  Procedure [dbo].[QA_InsertDuplicate_MtBvmReading]    Committed by VersionSQL https://www.versionsql.com ******/

--======================================================================  
--Author  :   
--Reviewer :   
--CreatedDate :  
-- QA_InsertDuplicate_MtBvmReading 6,2021  
--======================================================================  
  
  
CREATE PROCEDURE [dbo].[QA_InsertDuplicate_MtBvmReading] @month INT,  
@year INT  
AS  
BEGIN  
--IF EXISTS(  
-- SELECT  
--  1  
-- FROM MtBvmReading mbr  
-- WHERE DATEPART(MONTH, mbr.MtBvmReadingIntf_NtdcDateTime) = @month  
-- AND DATEPART(YEAR, mbr.MtBvmReadingIntf_NtdcDateTime) = @year)  
-- BEGIN  
-- SELECT 'already exists'  
-- RETURN;  
-- END  
  
 INSERT INTO [dbo].[MtBvmReading]  
           ([MtMeteringImportInfo_Id]  
           ,[MtBvmReadingIntf_NtdcDateTime]  
           ,[RuCDPDetail_CdpId]  
           ,[RuCdpMeters_MeterIdImport]  
           ,[MtBvmReading_IncEnergyImport]  
           ,[MtBvmReading_DataSourceImport]  
           ,[RuCdpMeters_MeterIdExport]  
           ,[MtBvmReading_IncEnergyExport]  
           ,[MtBvmReading_DataSourceExport]  
           ,[MtBvmReading_CreatedBy]  
           ,[MtBvmReading_CreatedOn]  
           ,[MtBvmReading_ReadingDate]  
           ,[MtBvmReading_ReadingHour]  
           ,[IsAlreadyUsedInBME])  
  
 SELECT  
  [MtMeteringImportInfo_Id]  
    ,DATEADD(MONTH, @month - (DATEPART(MONTH, [MtBvmReadingIntf_NtdcDateTime])), [MtBvmReadingIntf_NtdcDateTime])  
    ,[RuCDPDetail_CdpId]  
    ,[RuCdpMeters_MeterIdImport]  
    ,[MtBvmReading_IncEnergyImport]  
    ,[MtBvmReading_DataSourceImport]  
    ,[RuCdpMeters_MeterIdExport]  
    ,[MtBvmReading_IncEnergyExport]  
    ,[MtBvmReading_DataSourceExport]  
    ,100  
    ,GETUTCDATE()  
    ,CAST(DATEADD(MONTH, @month - (DATEPART(MONTH, [MtBvmReadingIntf_NtdcDateTime])), [MtBvmReadingIntf_NtdcDateTime]) AS DATE)  
    ,[MtBvmReading_ReadingHour]  
    ,0  
 FROM MtBvmReading mbr  
 WHERE CAST(MtBvmReadingIntf_NtdcDateTime AS DATE) IN ('2021-11-26', '2021-11-27')  
  
END
