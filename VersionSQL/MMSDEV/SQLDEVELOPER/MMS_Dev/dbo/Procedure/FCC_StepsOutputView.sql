/****** Object:  Procedure [dbo].[FCC_StepsOutputView]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE dbo.FCC_StepsOutputView @pFCCMasterID DECIMAL(18, 0),
@pStepId INT
AS
BEGIN

	DECLARE @vGenerator_Id DECIMAL(18, 0) = 0;

	SELECT
		@vGenerator_Id = MtGenerator_Id
	FROM MtFCCMaster fcc
	WHERE MtFCCMaster_Id = @pFCCMasterID

	;
	WITH cte_ToBeCancelledFCCs
	AS
	(SELECT
			fcc.MtGenerator_Id
		   ,COUNT(MtFCCDetails_ToBeCanceledFlag) AS ToBeCancelledCount
		   ,MAX(MtFCCDetails_ToBeCanceledDate) AS ToBeCancelledDate
		FROM MtFCCDetails FCCD
		INNER JOIN MtFCCMaster fcc
			ON fcc.MtFCCMaster_Id = FCCD.MtFCCMaster_Id
		WHERE fcc.MtGenerator_Id = @vGenerator_Id
		GROUP BY fcc.MtGenerator_Id)


	SELECT
	DISTINCT
		(SELECT TOP 1
				LuAccountingMonth_MonthName
			FROM LuAccountingMonth
			WHERE LuAccountingMonth_Id = FM.LuAccountingMonth_Id
			AND LuAccountingMonth_IsDeleted=0
			) AS [FCD Period]
	   ,ag.Generator_Id AS [Generator ID]
	   ,ag.Generator_Name AS [Generator]
	   ,lfct.LuFirmCapacityType_Name AS [Type]
	   ,fcdg.MtFCDGenerators_InitialFirmCapacity
	   ,fcc.MtFCCMaster_TotalCertificates AS [Number of Certificates]
	   ,CAST(fcc.MtFCCMaster_IssuanceDate AS DATE) AS [Issuance Date]
	   ,CAST(fcc.MtFCCMaster_ExpiryDate AS DATE) AS [Expiry Date]
	   ,ToBeCancelledCount
	   ,CASE
			WHEN ToBeCancelledCount > 0 THEN 'True'
			ELSE 'False'
		END AS [Contracts Revision Required]
	   ,ToBeCancelledDate AS [Due Date]
	FROM vw_ActiveGenerator ag
	INNER JOIN MtFCCMaster fcc
		ON ag.Generator_Id = fcc.MtGenerator_Id
	INNER JOIN MtFCDMaster FM
		ON FM.MtFCDMaster_Id = fcc.MtFCDMaster_Id
	INNER JOIN LuFirmCapacityType lfct
		ON fcc.LuFirmCapacityType_Id = lfct.LuFirmCapacityType_Id
	INNER JOIN MtFCDGenerators fcdg
		ON fcdg.MtFCDMaster_Id = fcc.MtFCDMaster_Id
			AND fcdg.MtGenerator_Id = fcc.MtGenerator_Id
	INNER JOIN cte_ToBeCancelledFCCs TBC
		ON TBC.MtGenerator_Id = fcc.MtGenerator_Id
	WHERE fcc.MtFCCMaster_Id = @pFCCMasterID




	SELECT
		mf.MtFCCDetails_CertificateId AS [Certificate ID]
	   ,CASE
			WHEN mf.MtFCCDetails_IsCancelled = 0 THEN CASE
					WHEN mf.MtFCCDetails_Status = 0 THEN 'Available'
					ELSE 'Blocked'
				END
			ELSE 'Cancelled'
		END AS Status
	   ,MtFCCDetails_ToBeCanceledFlag AS [FCC to be Cancelled]
	FROM MtFCCDetails mf
	INNER JOIN MtFCCMaster fcc
		ON fcc.MtFCCMaster_Id = mf.MtFCCMaster_Id
	WHERE fcc.MtGenerator_Id = @vGenerator_Id
	AND ISNULL(mf.MtFCCDetails_IsDeleted, 0) = 0

	ORDER BY mf.MtFCCDetails_CertificateId ASC






END
