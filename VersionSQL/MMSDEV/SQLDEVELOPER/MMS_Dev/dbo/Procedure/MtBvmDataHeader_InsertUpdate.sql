/****** Object:  Procedure [dbo].[MtBvmDataHeader_InsertUpdate]    Committed by VersionSQL https://www.versionsql.com ******/

--==========================================================================================    
-- Author: AMMAMA GILL    
-- CREATE date: 28 SEP 2023    
-- ALTER date:        
-- Description: To insert / update data relevant to the MtBVMDataHeader table    
---    and enhance grid read performance.    
--==========================================================================================    
--MtBvmDataHeader_InsertUpdate  7,2023  
CREATE PROCEDURE MtBvmDataHeader_InsertUpdate (@pMonth INT, @pYear INT)
AS
BEGIN

	DROP TABLE IF EXISTS #BVMData;

	SELECT

		BR.MtBvmReading_ReadingDate
	   ,BR.RuCDPDetail_CdpId
	   ,CDP.RuCDPDetail_CdpStatus
	   ,BR.MtBvmReading_ModifiedOn
	   ,BR.MtBvmReading_CreatedOn
	   ,CDP.RuCDPDetail_ConnectedFromID
	   ,CDP.RuCDPDetail_ConnectedToID INTO #BVMData
	FROM MtBvmReading BR
	INNER JOIN RuCDPDetail CDP
		ON BR.RuCDPDetail_CdpId = CDP.RuCDPDetail_CdpId
	WHERE MONTH(MtBvmReading_ReadingDate) = @pMonth
	AND Year(MtBvmReading_ReadingDate) = @pYear

	DECLARE @vTotalCDPCount DECIMAL(18, 0)
		   ,@vTotalActiveCdps DECIMAL(18, 0)
		   ,@vConnectedCdps DECIMAL(18, 0)
		   ,@vMonthName VARCHAR(50)
		   ,@vTotalRecords DECIMAL(18, 0)
		   ,@vLastUpdatedOn DATETIME
		   ,@vDataStatus DECIMAL(18, 4);

	SELECT
		@vTotalCDPCount = COUNT(DISTINCT RuCDPDetail_CdpId)
	FROM #BVMData;

	SELECT
		@vTotalActiveCdps = COUNT(DISTINCT RuCDPDetail_CdpId)
	FROM #BVMData
	WHERE RuCDPDetail_CdpStatus = 'Active';

	SELECT
		@vConnectedCdps = COUNT(DISTINCT RuCDPDetail_CdpId)
	FROM #BVMData
	WHERE ISNULL(RuCDPDetail_ConnectedFromID, 0) > 0
	AND ISNULL(RuCDPDetail_ConnectedToID, 0) > 0
	AND RuCDPDetail_ConnectedFromID <> RuCDPDetail_ConnectedToID
	AND RuCDPDetail_CdpStatus = 'Active';

	SELECT
		@vTotalRecords = COUNT(*)
	FROM #BVMData;

	SELECT
		@vMonthName = concat(DATENAME(MONTH, MIN(BR.MtBvmReading_ReadingDate)), ' ', year(MIN(BR.MtBvmReading_ReadingDate)))
	FROM #BVMData BR

	SELECT
		@vLastUpdatedOn =
		CASE
			WHEN MAX(MtBvmReading_ModifiedOn) IS NULL OR
				MAX(MtBvmReading_ModifiedOn) < MAX(MtBvmReading_CreatedOn) THEN MAX(MtBvmReading_CreatedOn)
			ELSE MAX(MtBvmReading_ModifiedOn)
		END
	FROM #BVMData

	SELECT
		@vDataStatus =
		CASE
			WHEN @pMonth = MONTH(GETDATE()) AND
				@pYear = YEAR(GETDATE()) THEN CAST(CAST(@vTotalRecords AS DECIMAL(18, 5)) / CAST((@vTotalActiveCdps * DAY(GETDATE()) * 24) AS DECIMAL(18, 5)) AS DECIMAL(18, 5)) * 100
			ELSE CAST(CAST(@vTotalRecords AS DECIMAL(18, 5)) / CAST((@vTotalActiveCdps * DAY(EOMONTH(@vMonthName)) * 24) AS DECIMAL(18, 5)) AS DECIMAL(18, 5)) * 100
		END
	FROM #BVMData




	IF EXISTS (SELECT
				1
			FROM MtBVMDataHeader BVMH
			WHERE BVMH.MtBVMDataHeader_Month = @pMonth
			AND BVMH.MtBVMDataHeader_Year = @pYear)
	BEGIN
		UPDATE BVM
		SET BVM.MtBVMDataHeader_LastUpdatedOn = @vLastUpdatedOn
		   ,BVM.MtBVMDataHeader_TotalCDPs = @vTotalCDPCount
		   ,BVM.MtBVMDataHeader_BVMRecords = @vTotalRecords
		   ,BVM.MtBVMDataHeader_ConnectedCDPs = @vConnectedCdps
		   ,BVM.MtBVMDataHeader_DataStatus = @vDataStatus
		   ,BVM.MtBVMDataHeader_TotalActiveCDPs = @vTotalActiveCdps
		   ,BVM.MtBVMDataHeader_UpdatedBy = 1
		   ,BVM.MtBVMDataHeader_UpdatedOn = GETDATE()
		FROM MtBVMDataHeader BVM
		WHERE BVM.MtBVMDataHeader_Month = @pMonth
		AND BVM.MtBVMDataHeader_Year = @pYear

	END

	ELSE

	BEGIN
		INSERT INTO MtBVMDataHeader (MtBVMDataHeader_Month
		, MtBVMDataHeader_Year
		, MtBVMDataHeader_MonthName
		, MtBVMDataHeader_BVMRecords
		, MtBVMDataHeader_ConnectedCDPs
		, MtBVMDataHeader_DataStatus
		, MtBVMDataHeader_LastUpdatedOn
		, MtBVMDataHeader_TotalActiveCDPs
		, MtBVMDataHeader_TotalCDPs
		, MtBVMDataHeader_TotalRecords
		, MtBVMDataHeader_CreatedBy
		, MtBVMDataHeader_CreatedOn)
			SELECT
				@pMonth
			   ,@pYear
			   ,@vMonthName
			   ,@vTotalRecords
			   ,@vConnectedCdps
			   ,@vDataStatus
			   ,@vLastUpdatedOn
			   ,@vTotalActiveCdps
			   ,@vTotalCDPCount
			   ,@vTotalRecords
			   ,1
			   ,GETDATE()


	END



END
