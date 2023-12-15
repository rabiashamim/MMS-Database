/****** Object:  Procedure [dbo].[GETBVMDetailsList]    Committed by VersionSQL https://www.versionsql.com ******/

--use MMS_PreProd                              
/****************************************************************************************                                
Test Cases                                
*************************************************************************************************/
-- dbo.GETBVMDetailsList  @pSearchCriteria='Monthly',@pMonthYear='June 2022',@pageSize=10, @pageNumber=1                              
-- dbo.GETBVMDetailsList  @pSearchCriteria='Monthly',@pMonthYear='October, 2021',@pageSize=10, @pageNumber=3, @pCdpParameter=0                                
-- dbo.GETBVMDetailsList  @pSearchCriteria='Batch',@pBatchId=2,@pageSize=10, @pageNumber=1                                
-- dbo.GETBVMDetailsList  @pSearchCriteria='Batch',@pBatchId=2,@pageSize=10, @pageNumber=1,@pMonthParameter='November, 2021'                                
-- dbo.GETBVMDetailsList  @pSearchCriteria='Batch',@pBatchId=18,@pageSize=10, @pageNumber=1,@pMonthParameter='August, 2021',@pCdpParameter=null                                
CREATE PROCEDURE dbo.GETBVMDetailsList @pSearchCriteria VARCHAR(50) = NULL,--'Monthly',-- =null  ,--is month or batch                                
@pMonthYear VARCHAR(50) = NULL,--'October, 2021',--null, -- month,year(January, 2022) or batch                                 
@pBatchId INT = NULL,
@pageSize INT = NULL,
@pageNumber INT = NULL,
@pCdpParameter BIT = NULL,
@pMonthParameter VARCHAR(50) = NULL
, @pActiveCdpsParameter BIT = NULL,
@pNullValuesParameter BIT = NULL
, @pNewCdpsParameter BIT = NULL
, @pRuCDPDetail_CdpId VARCHAR(10) = NULL
, @pRuCDPDetail_CdpName VARCHAR(100) = NULL
, @pConnectedFrom VARCHAR(50) = NULL
, @pConnectedTo VARCHAR(50) = NULL
, @pFromCustomer VARCHAR(50) = NULL
, @pToCustomer VARCHAR(50) = NULL
AS
BEGIN


	/***********************************************************************************************                                
                                                                     
                                     *************************************************************************************************/

	--SELECT DISTINCT      
	-- MtBvmReading.MtBvmReading_Id      
	--   ,MtBvmReading.MtBvmReadingIntf_NtdcDateTime      
	--   ,MtBvmReading.RuCDPDetail_CdpId      
	--   ,CDP.RuCDPDetail_CdpName      
	--   ,CDP.RuCDPDetail_FromCustomer      
	--   ,CDP.RuCDPDetail_ToCustomer      
	--   ,RuCDPDetail_LineVoltage      
	--   ,MtBvmReading.MtBvmReading_IncEnergyImport      
	--   ,RuCdpMeters_MeterIdImport      
	--   ,MtBvmReading_DataSourceImport      
	--   ,MtBvmReading_MeterQualifierImport      
	--   ,MtBvmReading.MtBvmReading_IncEnergyExport      
	--   ,RuCdpMeters_MeterIdExport      
	--   ,MtBvmReading_DataSourceExport      
	--   ,MtBvmReading_MeterQualifierExport      
	--   ,PRT.MtPartyRegisteration_Name AS MMSConnectedFrom      
	--   ,PRF.MtPartyRegisteration_Name AS MMSConnectedTo      
	--   ,Concat(DATENAME(MONTH, MtBvmReadingIntf_NtdcDateTime), ' ', YEAR(MtBvmReadingIntf_NtdcDateTime)) AS NtdcMonthYear      
	--   ,MtMeteringImportInfo_BatchNo      
	--   ,MtMeteringImportInfo.MtMeteringImportInfo_ImportInMMSDate      
	--   ,CDP.RuCDPDetail_CdpStatus AS CdpActivityStatus      
	--   ,CdpStatus = (      
	-- CASE      
	--  WHEN CDP.RuCDPDetail_ConnectedFromID > 0 AND      
	--   CDP.RuCDPDetail_ConnectedToID > 0 AND      
	--   RuCDPDetail_CdpStatus = 'Active' THEN 'Connected'      
	--  ELSE 'Not Connected'      
	-- END)      
	-- --FROM RuCDPDetail R1      
	-- --WHERE R1.RuCDPDetail_CdpId = CDP.RuCDPDetail_CdpId)      
	--   ,NewCdp = (SELECT      
	--   CASE      
	--    WHEN MtBvmReading.RuCDPDetail_CdpId NOT IN (SELECT DISTINCT      
	--       RuCDPDetail_CdpId      
	--      FROM RuCDPDetail) THEN 1      
	--    ELSE 0      
	--   END) INTO #temp      
	--FROM MtBvmReading      
	--INNER JOIN MtMeteringImportInfo      
	-- ON MtBvmReading.MtMeteringImportInfo_Id = MtMeteringImportInfo.MtMeteringImportInfo_Id      
	--LEFT JOIN RuCDPDetail CDP      
	-- ON MtBvmReading.RuCDPDetail_CdpId = CDP.RuCDPDetail_CdpId      
	--LEFT JOIN MtConnectedMeter MC      
	-- ON MC.MtCDPDetail_Id = CDP.RuCDPDetail_Id      
	--  AND MC.IsAssigned = 1      
	--  AND MC.MtConnectedMeter_isDeleted = 0      
	--LEFT JOIN MtPartyRegisteration PRT      
	-- ON PRT.MtPartyRegisteration_Id = CDP.RuCDPDetail_ConnectedFromID      
	----MC.MtConnectedMeter_ConnectedTo                                
	--LEFT JOIN MtPartyRegisteration PRF      
	-- ON PRF.MtPartyRegisteration_Id =      
	--  CDP.RuCDPDetail_ConnectedToID      
	----MC.MtConnectedMeter_ConnectedFrom                                
	--WHERE (@pSearchCriteria = 'Batch'      
	--AND MtMeteringImportInfo_BatchNo = @pBatchId)      
	--OR (@pSearchCriteria = 'Monthly'      
	--AND Concat(DATENAME(MONTH, MtBvmReadingIntf_NtdcDateTime), ' ', YEAR(MtBvmReadingIntf_NtdcDateTime)) = @pMonthYear)      


	DROP TABLE IF EXISTS #mtBvmReadingTemp;
	DROP TABLE IF EXISTS #tempbvmData1
	DROP TABLE IF EXISTS #tempbvmData2

	SELECT
		MBR.MtBvmReading_Id
	   ,MBR.MtBvmReadingIntf_NtdcDateTime
	   ,MBR.RuCDPDetail_CdpId
	   ,MBR.MtBvmReading_IncEnergyImport
	   ,MBR.MtBvmReading_IncEnergyExport
	   ,MBR.MtBvmReading_DataSourceImport
	   ,MBR.MtBvmReading_DataSourceExport
	   ,MBR.MtBvmReading_MeterQualifierImport
	   ,MBR.MtBvmReading_MeterQualifierExport
	   ,MBR.MtMeteringImportInfo_Id
	   ,MBR.RuCdpMeters_MeterIdExport
	   ,MBR.RuCdpMeters_MeterIdImport
	   ,MII.MtMeteringImportInfo_BatchNo
	   ,MII.MtMeteringImportInfo_ImportInMMSDate INTO #mtBvmReadingTemp
	FROM MtBvmReading MBR
	INNER JOIN MtMeteringImportInfo MII
		ON MBR.MtMeteringImportInfo_Id = MII.MtMeteringImportInfo_Id
	WHERE (@pSearchCriteria = 'Batch'
	AND MtMeteringImportInfo_BatchNo = @pBatchId)
	OR (@pSearchCriteria = 'Monthly'
	AND Concat(DATENAME(MONTH, MtBvmReadingIntf_NtdcDateTime), ' ', YEAR(MtBvmReadingIntf_NtdcDateTime)) = @pMonthYear)

	;
	WITH cte_RuCDPs
	AS
	(SELECT DISTINCT
			RuCDPDetail_CdpID
		FROM RuCDPDetail)

	SELECT
		BVM.*
	   ,CDP.RuCDPDetail_CdpName
	   ,CDP.RuCDPDetail_FromCustomer
	   ,CDP.RuCDPDetail_ToCustomer
	   ,CDP.RuCDPDetail_LineVoltage
	   ,CDP.RuCDPDetail_CdpStatus AS CdpActivityStatus
	   ,PRT.MtPartyRegisteration_Name AS MMSConnectedFrom
	   ,PRF.MtPartyRegisteration_Name AS MMSConnectedTo

	   ,Concat(DATENAME(MONTH, MtBvmReadingIntf_NtdcDateTime), ' ', YEAR(MtBvmReadingIntf_NtdcDateTime)) AS NtdcMonthYear
	   ,CdpStatus = (
		CASE
			WHEN CDP.RuCDPDetail_ConnectedFromID > 0 AND
				CDP.RuCDPDetail_ConnectedToID > 0 AND
				RuCDPDetail_CdpStatus = 'Active' THEN 'Connected'
			ELSE 'Not Connected'
		END)
	   ,NewCdp = (SELECT
				CASE
					WHEN BVM.RuCDPDetail_CdpId NOT IN (SELECT DISTINCT
								RuCDPDetail_CdpId
							FROM cte_RuCDPs) THEN 1
					ELSE 0
				END) INTO #tempbvmData1
	FROM #mtBvmReadingTemp BVM
	LEFT JOIN RuCDPDetail CDP
		ON BVM.RuCDPDetail_CdpId = CDP.RuCDPDetail_CdpId
	LEFT JOIN MtPartyRegisteration PRT
		ON PRT.MtPartyRegisteration_Id = CDP.RuCDPDetail_ConnectedFromID
	LEFT JOIN MtPartyRegisteration PRF
		ON PRF.MtPartyRegisteration_Id = CDP.RuCDPDetail_ConnectedToID


	/***********************************************************************************************                                
                                  Filter if shows                                 
                                  1. connected                                 
                                  2. not connected                                 
                                  3. show for specific month only                                 
                                  AND save data in #temp2                                
                                  *************************************************************************************************/


	SELECT
	DISTINCT
		ROW_NUMBER() OVER (ORDER BY NewCdp, MtBvmReading_Id) rn
	   ,* INTO #tempbvmData2
	FROM #tempbvmData1
	WHERE (@pCdpParameter IS NULL
	OR (
	(@pCdpParameter = 1
	AND CdpStatus = 'Connected')
	OR (@pCdpParameter = 0
	AND CdpStatus = 'Not Connected')
	)
	)
	AND (@pMonthParameter IS NULL
	OR (ntdcmonthyear = @pMonthParameter)
	)
	AND (@pActiveCdpsParameter = 0
	OR (@pActiveCdpsParameter = 1
	AND #tempbvmData1.CdpActivityStatus = 'Active'))

	AND (@pNullValuesParameter = 0
	OR (
	@pNullValuesParameter = 1
	AND (#tempbvmData1.MtBvmReading_IncEnergyExport IS NULL
	OR #tempbvmData1.MtBvmReading_IncEnergyImport IS NULL)
	))

	AND (@pNewCdpsParameter = 0
	OR (@pNewCdpsParameter = 1
	AND (
	#tempbvmData1.RuCDPDetail_CdpId NOT IN (SELECT
			RuCDPDetail_CdpId
		FROM RuCDPDetail)
	)))
	AND (ISNULL(@pRuCDPDetail_CdpId, '') = ''
	OR RuCDPDetail_CdpId = @pRuCDPDetail_CdpId
	)

	AND (ISNULL(@pRuCDPDetail_CdpName, '') = ''
	OR RuCDPDetail_CdpName LIKE '%' + @pRuCDPDetail_CdpName + '%'
	)

	AND (ISNULL(@pFromCustomer, '') = ''
	OR RuCDPDetail_FromCustomer LIKE '%' + @pFromCustomer + '%'
	)

	AND (ISNULL(@pToCustomer, '') = ''
	OR RuCDPDetail_ToCustomer LIKE '%' + @pToCustomer + '%'
	)

	AND (ISNULL(@pConnectedFrom, '') = ''
	OR MMSConnectedFrom LIKE '%' + @pConnectedFrom + '%'
	)

	AND (ISNULL(@pConnectedTo, '') = ''
	OR MMSConnectedTo LIKE '%' + @pConnectedTo + '%'
	)



	/***********************************************************************************************                                
                                  Paggination                                
                                  *************************************************************************************************/
	SELECT
		*
	FROM #tempbvmData2
	WHERE (rn > ((@pageNumber - 1) * @pageSize)
	AND rn <= (@pageNumber * @pageSize))



	/***********************************************************************************************                                
                               Shows Top Summary                                
                               1. BVM Records                                
                               2. Total CDPs                       
                               3. Connected CDPs                                
                                -- dbo.GETBVMDetailsList  @pSearchCriteria='Batch',@pBatchId=2,@pageSize=10, @pageNumber=1,@pMonthParameter='November, 2021'                                
                *************************************************************************************************/
	SELECT
		COUNT(1) AS totalBVMRecords
	   ,COUNT(DISTINCT RuCDPDetail_CdpId) AS totalCdps
	   ,ConnectedCdps = (SELECT
				COUNT(DISTINCT (concat(RuCDPDetail_CdpId, CdpStatus)))
			FROM #tempbvmData1
			WHERE CdpStatus = 'Connected')
	   ,TotalActiveCdps = ISNULL((SELECT
				COUNT(DISTINCT RuCDPDetail_CdpId)
			FROM #tempbvmData1
			WHERE CdpActivityStatus = 'Active')
		, 0
		)
	   ,TotalNullValues = ISNULL((SELECT
				COUNT(DISTINCT concat(RuCDPDetail_CdpId, CAST(MtBvmReadingIntf_NtdcDateTime AS VARCHAR(100))))
			FROM #tempbvmData1
			WHERE MtBvmReading_IncEnergyExport IS NULL
			OR MtBvmReading_IncEnergyImport IS NULL)
		, 0)
	   ,NewCdps = ISNULL((SELECT

				COUNT(DISTINCT RuCDPDetail_CdpId)
			FROM #tempbvmData1
			WHERE RuCDPDetail_CdpId NOT IN (SELECT DISTINCT
					RuCDPDetail_CdpId
				FROM RuCDPDetail))
		, 0)
	FROM #tempbvmData1

	/***********************************************************************************************                                
                               Month wise summary        
                               *************************************************************************************************/

	SELECT DISTINCT
		Concat(DATENAME(MONTH, MtBvmReadingIntf_NtdcDateTime), ' ', YEAR(MtBvmReadingIntf_NtdcDateTime)) AS MonthYear
	   ,COUNT(Concat(DATENAME(MONTH, MtBvmReadingIntf_NtdcDateTime), ' ', YEAR(MtBvmReadingIntf_NtdcDateTime))) AS totalCount
	FROM #tempbvmData1

	GROUP BY Concat(DATENAME(MONTH, MtBvmReadingIntf_NtdcDateTime), ' ', YEAR(MtBvmReadingIntf_NtdcDateTime))
	ORDER BY Concat(DATENAME(MONTH, MtBvmReadingIntf_NtdcDateTime), ' ', YEAR(MtBvmReadingIntf_NtdcDateTime)) DESC

	/***********************************************************************************************                                
                               For Showing import date                                 
                               *************************************************************************************************/
	SELECT TOP 1
		MtMeteringImportInfo_ImportInMMSDate
	FROM MtMeteringImportInfo
	WHERE MtMeteringImportInfo_BatchNo = @pBatchId
	AND @pSearchCriteria = 'Batch'

	/***********************************************************************************************                                
                               FOR server side pagination we need total number of reccords.                                
                               *************************************************************************************************/
	SELECT
		COUNT(1) AS totalBVMRecords
	FROM #tempbvmData2



	DROP TABLE IF EXISTS #mtBvmReadingTemp;
	DROP TABLE IF EXISTS #tempbvmData1
	DROP TABLE IF EXISTS #tempbvmData2
END
