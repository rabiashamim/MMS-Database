/****** Object:  Procedure [dbo].[MtMeteringImportInfo_InsertUpdate]    Committed by VersionSQL https://www.versionsql.com ******/

--==========================================================================================        
-- Author: AMMAMA GILL        
-- CREATE date: 02 OCT 2023        
-- ALTER date:            
-- Description: To insert / update data relevant to the MtMeteringImportInfo table        
---    and enhance grid read performance.        
--==========================================================================================        
--MtMeteringImportInfo_InsertUpdate  1700     

CREATE PROCEDURE MtMeteringImportInfo_InsertUpdate @pBatchNumber DECIMAL(18, 0)
AS
BEGIN

	DROP TABLE IF EXISTS #BvmData;

	SELECT
		RuCDPDetail_CdpId INTO #BvmData
	FROM MtBvmReading BVM
	INNER JOIN MtMeteringImportInfo MI
		ON BVM.MtMeteringImportInfo_Id = MI.MtMeteringImportInfo_Id
	WHERE MtMeteringImportInfo_BatchNo = @pBatchNumber


	;
	WITH cte_cdps
	AS
	(SELECT
			RuCDPDetail_CdpId
		   ,RuCDPDetail_CdpStatus
		   ,RuCDPDetail_ConnectedFromID
		   ,RuCDPDetail_ConnectedToID
		FROM RuCDPDetail)

	UPDATE MI
	SET MtMeteringImportInfo_TotalCDPs = (SELECT
				COUNT(DISTINCT RuCDPDetail_CdpId)
			FROM #BvmData)
	   ,MtMeteringImportInfo_TotalActiveCDPs = (SELECT
				COUNT(DISTINCT BD.RuCDPDetail_CdpId)
			FROM #BvmData BD
			INNER JOIN cte_cdps cdp
				ON BD.RuCDPDetail_CdpId = cdp.RuCDPDetail_CdpId
			WHERE RuCDPDetail_CdpStatus = 'Active')
	   ,MtMeteringImportInfo_BVMRecords = (SELECT
				COUNT(*)
			FROM #BvmData)
	   ,MtMeteringImportInfo_ConnectedCDPs = (SELECT
				COUNT(DISTINCT cdp.RuCDPDetail_CdpId)
			FROM #BvmData BD
			INNER JOIN cte_cdps cdp
				ON BD.RuCDPDetail_CdpId = cdp.RuCDPDetail_CdpId
			WHERE ISNULL(RuCDPDetail_ConnectedFromID, 0) > 0
			AND ISNULL(RuCDPDetail_ConnectedToID, 0) > 0
			AND RuCDPDetail_ConnectedFromID <> RuCDPDetail_ConnectedToID
			AND RuCDPDetail_CdpStatus = 'Active')
	   ,MtMeteringImportInfo_ModifiedOn = GETDATE()
	FROM MtMeteringImportInfo MI
	WHERE MtMeteringImportInfo_BatchNo = @pBatchNumber

	DROP TABLE IF EXISTS #BvmData;

END
