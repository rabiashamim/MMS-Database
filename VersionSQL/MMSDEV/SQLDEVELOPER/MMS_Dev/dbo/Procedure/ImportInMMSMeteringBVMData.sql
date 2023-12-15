/****** Object:  Procedure [dbo].[ImportInMMSMeteringBVMData]    Committed by VersionSQL https://www.versionsql.com ******/

--======================================================================  
--Author  : Ali Imran  
--Reviewer : <>  
--CreatedDate : 15 Feb 2022  
--Comments : Import Metering BVM Reading tables  
--======================================================================  

CREATE   Procedure dbo.ImportInMMSMeteringBVMData
AS
BEGIN

	/*********************************************************************    
	This block only declare variables which we use with in this sp  
	*********************************************************************/

	DECLARE @vMtMeteringImportInfo_Id DECIMAL(18, 0)
		   ,@vInterface_LastRecordId DECIMAL(18, 0)
		   ,@vInterface_LastRecordDate DATETIME
		   ,@vLastImportDateInMMS DATETIME
		   ,@NewBatchNo INT
		   ,@BatchNo INT
		   ,@vMonth decimal(18,0)
		   ,@vYear decimal(18,0);

	/*********************************************************************      
	Get Last interface table record so that we can use this info    
	[MTMeteringInmportInfo while] saving the import info.  
	*********************************************************************/
	SELECT TOP 1
		@vInterface_LastRecordId = InterfaceMtBvmReading_Id
	   ,@vInterface_LastRecordDate = InterfaceMtBvmReadingIntf_NtdcDateTime
	   ,@vMonth =  DATEPart(month,InterfaceMtBvmReadingIntf_NtdcDateTime)
	   ,@vYear=DATEPart(year,InterfaceMtBvmReadingIntf_NtdcDateTime)
	FROM [dbo].[InterfaceMtBvmReading]
	WHERE ISNULL(InterfaceMtBvmReading_IsDeleted, 0) = 0
	ORDER BY InterfaceMtBvmReading_Id DESC

	/*********************************************************************      
   settings hours  
   *********************************************************************/

	SELECT
		InterfaceMtBvmReadingIntf_NtdcDateTime
	   ,CASE
			WHEN DATEPART(MINUTE, InterfaceMtBvmReadingIntf_NtdcDateTime) > 0 THEN DATEPART(HOUR, InterfaceMtBvmReadingIntf_NtdcDateTime) + 1
			WHEN DATEPART(HOUR, InterfaceMtBvmReadingIntf_NtdcDateTime) = 0 THEN 24
			ELSE DATEPART(HOUR, InterfaceMtBvmReadingIntf_NtdcDateTime)
		END AS ReadingHour

	   ,CASE
			WHEN DATEPART(HOUR, InterfaceMtBvmReadingIntf_NtdcDateTime) = 0 AND
				DATEPART(MINUTE, InterfaceMtBvmReadingIntf_NtdcDateTime) = 0 THEN CAST(DATEADD(DAY, -1, InterfaceMtBvmReadingIntf_NtdcDateTime) AS DATE)
			ELSE CAST(InterfaceMtBvmReadingIntf_NtdcDateTime AS DATE)
		END
		AS
		ReadingDate
	   ,InterfaceRuCDPDetail_CdpId
	   ,InterfaceRuCdpMeters_MeterIdImport
	   ,InterfaceMtBvmReading_IncEnergyImport
	   ,InterfaceMtBvmReading_DataSourceImport
	   ,InterfaceRuCdpMeters_MeterIdExport
	   ,InterfaceMtBvmReading_IncEnergyExport
	   ,InterfaceMtBvmReading_DataSourceExport
	   ,InterfaceMtBvmReading_IsDeleted INTO #temp0
	FROM [dbo].[InterfaceMtBvmReading] IBR


	/*********************************************************************      
	Convert half hourly info from interface table to hourly info and save in  
	#temp table.  
	*********************************************************************/
	SELECT
		MIN(InterfaceMtBvmReadingIntf_NtdcDateTime) AS ReadingDateTime
	   ,InterfaceRuCDPDetail_CdpId AS CdpId
	   ,InterfaceRuCdpMeters_MeterIdImport AS MeterIdImport
	   ,SUM(InterfaceMtBvmReading_IncEnergyImport) AS EnergyImport
	   ,MIN(InterfaceMtBvmReading_DataSourceImport) AS DateSourceImport
	   ,InterfaceRuCdpMeters_MeterIdExport AS MeterIdExport
	   ,SUM(InterfaceMtBvmReading_IncEnergyExport) AS EnergyExport
	   ,MIN(InterfaceMtBvmReading_DataSourceExport) AS DataSourceExport
	   ,ReadingDate
	   ,ReadingHour INTO #temp
	FROM #temp0
	WHERE ISNULL(InterfaceMtBvmReading_IsDeleted, 0) = 0
	GROUP BY InterfaceRuCDPDetail_CdpId
			,ReadingDate
			,ReadingHour
			,InterfaceRuCdpMeters_MeterIdImport
			 --,InterfaceMtBvmReading_DataSourceImport      
			,InterfaceRuCdpMeters_MeterIdExport
	--,InterfaceMtBvmReading_DataSourceExport      
	HAVING COUNT(ReadingDate) > 1

	/*********************************************************************      
	If no record found in interface or temp table not need to move.  
	*********************************************************************/

	IF NOT EXISTS (SELECT
				1
			FROM #temp)
	BEGIN
		SELECT
			'0' AS response
		RETURN;
	END

	/*********************************************************************      
	GET Metering master Info  
	*********************************************************************/

	SELECT TOP 1
		@vMtMeteringImportInfo_Id = ISNULL(MtMeteringImportInfo_Id, 0) + 1
	   ,@vLastImportDateInMMS = [MtMeteringImportInfo_ImportInMMSDate]
	   ,@BatchNo = MtMeteringImportInfo_BatchNo
	FROM [dbo].[MtMeteringImportInfo]
	ORDER BY MtMeteringImportInfo_Id DESC

	/*********************************************************************      
	Generate Batch  
	*********************************************************************/

	IF (@vLastImportDateInMMS IS NULL)
	BEGIN
		SET @NewBatchNo = 1
	END
	ELSE
	BEGIN

		SET @NewBatchNo = ISNULL(@BatchNo, 0) + 1

	END

	--select @vMtMeteringImportInfo_Id,@vLastImportDateInMMS as lastimportdate,@BatchNo,@NewBatchNo  
	--return;  



	/*********************************************************************      
    ROW_NUMBER added which we use as uique key for further prosessing  
   *********************************************************************/

	SELECT
		ROW_NUMBER() OVER (ORDER BY CdpId) AS rn
	   ,* INTO #Interface
	FROM #temp

	/*********************************************************************      
    find records in operational table IF already exists so that we can not insert again   
   *********************************************************************/
	SELECT
		rn
	   ,ReadingDateTime
	   ,CdpId
	   ,MeterIdImport
	   ,EnergyImport
	   ,DateSourceImport
	   ,MeterIdExport
	   ,EnergyExport
	   ,DataSourceExport INTO #AlreadyExist
	FROM #Interface t
	JOIN [dbo].[MtBvmReading] BVM
		ON BVM.MtBvmReadingIntf_NtdcDateTime = t.ReadingDateTime
			AND BVM.RuCDPDetail_CdpId = t.CdpId



	/*********************************************************************      
	Exclude already exists record and final data in interface tables.  
	*********************************************************************/

	SELECT
		* INTO #ReadyForOpertaion
	FROM #Interface
	WHERE rn NOT IN (SELECT
			rn
		FROM #AlreadyExist)


	/*********************************************************************      
	insert import master Information In MtMeteringImportInfo  
	*********************************************************************/

	IF EXISTS (SELECT
				1
			FROM #ReadyForOpertaion)
	BEGIN



		INSERT INTO [dbo].[MtMeteringImportInfo] ([MtMeteringImportInfo_Id]
		, [MtMeteringImportInfo_ImportInMMSDate]
		, [MtMeteringImportInfo_BatchNo]
		, [Interface_LastRecordId]
		, [Interface_LastRecordDate]
		, [MtMeteringImportInfo_CreatedBy]
		, [MtMeteringImportInfo_CreatedOn])
			VALUES (ISNULL(@vMtMeteringImportInfo_Id, 1), DATEADD(HOUR, 5, GetUTCDATE()), @NewBatchNo, @vInterface_LastRecordId, @vInterface_LastRecordDate, 1, DATEADD(HOUR, 5, GetUTCDATE()))

		/*********************************************************************      
		insert  into operational table from interface table  
		*********************************************************************/

		INSERT INTO [dbo].[MtBvmReading] (MtMeteringImportInfo_Id
		, [MtBvmReadingIntf_NtdcDateTime]
		, [RuCDPDetail_CdpId]
		, [RuCdpMeters_MeterIdImport]
		, [MtBvmReading_IncEnergyImport]
		, [MtBvmReading_DataSourceImport]
		, [RuCdpMeters_MeterIdExport]
		, [MtBvmReading_IncEnergyExport]
		, [MtBvmReading_DataSourceExport]
		, [MtBvmReading_CreatedBy]
		, [MtBvmReading_CreatedOn]
		, MtBvmReading_ReadingDate
		, MtBvmReading_ReadingHour)
			SELECT
				@vMtMeteringImportInfo_Id
			   ,ReadingDateTime
			   ,CdpId
			   ,MeterIdImport
			   ,EnergyImport
			   ,DateSourceImport
			   ,MeterIdExport
			   ,EnergyExport
			   ,DataSourceExport
			   ,1
			   ,DATEADD(HOUR, 5, GetUTCDATE())
			   ,ReadingDate
			   ,ReadingHour
			FROM #ReadyForOpertaion t


	END

	/*********************************************************************      
	Update [MtBvmReading] Already Exists records  
	*********************************************************************/
	IF EXISTS (SELECT
				1
			FROM #AlreadyExist)
	BEGIN
		UPDATE [dbo].[MtBvmReading]
		SET [RuCdpMeters_MeterIdImport] = MeterIdImport
		   ,[MtBvmReading_IncEnergyImport] = EnergyImport
		   ,[MtBvmReading_DataSourceImport] = DateSourceImport
		   ,[RuCdpMeters_MeterIdExport] = MeterIdExport
		   ,[MtBvmReading_IncEnergyExport] = EnergyExport
		   ,[MtBvmReading_DataSourceExport] = DataSourceExport
		   ,[IsAlreadyUsedInBME] = 0
		   ,[MtBvmReading_ModifiedBy] = 1
		   ,[MtBvmReading_ModifiedOn] = GETUTCDATE()

		FROM [dbo].[MtBvmReading] BVM
		JOIN #AlreadyExist AE
			ON AE.ReadingDateTime = BVM.MtBvmReadingIntf_NtdcDateTime
			AND BVM.RuCDPDetail_CdpId = AE.CdpId
		WHERE BVM.MtBvmReading_IncEnergyImport <> AE.EnergyImport
		OR BVM.MtBvmReading_IncEnergyExport <> AE.EnergyExport
		OR BVM.MtBvmReading_IncEnergyImport IS NULL
		OR  BVM.MtBvmReading_IncEnergyExport IS NULL
	END



/*********************************************************************      
Once the record is insert in operational table we need to clean it  
*********************************************************************/

-- Truncate Table  [dbo].[InterfaceMtBvmReading]  

	/*********************************************************************      
	Once Records are inserted in MtbvmReading and MtMeteringImportInfo 
	tables, we update relevant stats by calling the following SPs.
	*********************************************************************/
	exec MtMeteringImportInfo_InsertUpdate @NewBatchNo;

	

	SELECT
	TOP 1
		@vYear =Year(MtBvmReading_ReadingDate)
	,@vMonth=Month(MtBvmReading_ReadingDate)
	FROM MtBvmReading BR
	INNER JOIN MtMeteringImportInfo MI
		ON BR.MtMeteringImportInfo_Id = MI.MtMeteringImportInfo_Id
	WHERE MtMeteringImportInfo_BatchNo = @NewBatchNo

	exec MtBvmDataHeader_InsertUpdate @pMonth = @vMonth
									 ,@pYear = @vYear;


END
