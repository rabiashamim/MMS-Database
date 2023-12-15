/****** Object:  Procedure [dbo].[InsertInterfaceMtBvmReadingHistory]    Committed by VersionSQL https://www.versionsql.com ******/

--======================================================================
--Author  : Sadaf Malik| Ali Imran
--Reviewer : <>
--CreatedDate : 09/09/2022
--Comments : 
--======================================================================
CREATE PROCEDURE dbo.InsertInterfaceMtBvmReadingHistory
AS
BEGIN
	INSERT INTO [dbo].[InterfaceMtBvmReadingHistory] ([InterfaceMtBvmReading_Id]
	, [InterfaceMtBvmReadingIntf_NtdcDateTime]
	, [InterfaceRuCDPDetail_CdpId]
	, [InterfaceRuCdpMeters_MeterIdImport]
	, [InterfaceMtBvmReading_IncEnergyImport]
	, [InterfaceMtBvmReading_DataSourceImport]
	, [InterfaceRuCdpMeters_MeterIdExport]
	, [InterfaceMtBvmReading_IncEnergyExport]
	, [InterfaceMtBvmReading_DataSourceExport]
	, [InterfaceMtBvmReading_CreatedOn]
	, [InterfaceMtBvmReading_ModifiedOn]
	, [InterfaceMtBvmReading_IsDeleted]
	, [InterfaceMtBvmReading_MeterQualifierImport]
	, [InterfaceMtBvmReading_DataLabelImport]
	, [InterfaceMtBvmReading_DataStatusImport]
	, [InterfaceMtBvmReading_MeterQualifierExport]
	, [InterfaceMtBvmReading_DataLabelExport]
	, [InterfaceMtBvmReading_DataStatusExport]
	, [InterfaceMtBvmReadingHistory_CreatedOn]
	, [InterfaceMtBvmReadingHistory_IsDeleted])
		SELECT
			[InterfaceMtBvmReading_Id]
		   ,[InterfaceMtBvmReadingIntf_NtdcDateTime]
		   ,[InterfaceRuCDPDetail_CdpId]
		   ,[InterfaceRuCdpMeters_MeterIdImport]
		   ,[InterfaceMtBvmReading_IncEnergyImport]
		   ,[InterfaceMtBvmReading_DataSourceImport]
		   ,[InterfaceRuCdpMeters_MeterIdExport]
		   ,[InterfaceMtBvmReading_IncEnergyExport]
		   ,[InterfaceMtBvmReading_DataSourceExport]
		   ,[InterfaceMtBvmReading_CreatedOn]
		   ,[InterfaceMtBvmReading_ModifiedOn]
		   ,[InterfaceMtBvmReading_IsDeleted]
		   ,[InterfaceMtBvmReading_MeterQualifierImport]
		   ,[InterfaceMtBvmReading_DataLabelImport]
		   ,[InterfaceMtBvmReading_DataStatusImport]
		   ,[InterfaceMtBvmReading_MeterQualifierExport]
		   ,[InterfaceMtBvmReading_DataLabelExport]
		   ,[InterfaceMtBvmReading_DataStatusExport]
		   ,GETUTCDATE()
		   ,0
		FROM [dbo].[InterfaceMtBvmReading]


		TRUNCATE table InterfaceMtBvmReading

END
