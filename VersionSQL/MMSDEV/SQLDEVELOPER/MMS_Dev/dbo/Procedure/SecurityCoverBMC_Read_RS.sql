/****** Object:  Procedure [dbo].[SecurityCoverBMC_Read_RS]    Committed by VersionSQL https://www.versionsql.com ******/

/********************************************************/
-- =============================================                              
-- Author: Sadaf Malik                                       
-- CREATE date:  3/1/2023                                             
-- ALTER date:                                                 
-- Reviewer:                                                
-- Description: Additional Validations for Critical hours.                                           
-- =============================================                                                 
-- =============================================                         
--[SecurityCoverBMC_Read] 819,1,10      

CREATE PROCEDURE dbo.SecurityCoverBMC_Read_RS @pMtSOFileMaster_Id DECIMAL(18, 0)
, @pPageNumber INT
, @pPageSize INT
, @pPartyId DECIMAL(18, 0) = NULL
, @pPartyName VARCHAR(100) = NULL
, @pSubmittedSecurityCover DECIMAL(38, 13) = NULL
, @pRequiredSecurityCover DECIMAL(38, 13) = NULL
, @pIsValid BIT = NULL

AS
BEGIN
	BEGIN TRY
		DECLARE @vStatus VARCHAR(5);
		SELECT
			@vStatus = LuStatus_Code
		FROM MtSOFileMaster
		WHERE MtSOFileMaster_Id = @pMtSOFileMaster_Id;

		IF @vStatus = 'UPL'
		BEGIN


			SELECT
				[MtSecurityCoverMP_Id]
			   ,[MtSOFileMaster_Id]
				--      ,[MtBmcSecurityCover_RowNumber]      
			   ,ROW_NUMBER() OVER (ORDER BY MPR.MtPartyRegisteration_Id, SC.MtSecurityCoverMP_IsValid, SC.MtSecurityCoverMP_RowNumber) AS [MtSecurityCoverMP_RowNumber]
			   ,SC.[MtPartyRegisteration_Id]
			   ,MPR.MtPartyRegisteration_Name
			   --,MtSecurityCoverMP_SubmittedSecurityCover
			 --  ,CASE
				--	WHEN SC.MtSecurityCoverMP_IsValid = 1 THEN CAST([MtSecurityCoverMP_RequiredSecurityCover] AS DECIMAL(18, 0))
				--	ELSE [MtSecurityCoverMP_RequiredSecurityCover]
				--END AS MtSecurityCoverMP_RequiredSecurityCover
				,CASE
					WHEN SC.MtSecurityCoverMP_IsValid = 1 THEN CAST([MtSecurityCoverMP_SubmittedSecurityCover] AS DECIMAL(18, 0))
					ELSE nullif(ISNULL([MtSecurityCoverMP_SubmittedSecurityCover],''),'')
				END AS MtSecurityCoverMP_SubmittedSecurityCover
			   ,[MtSecurityCoverMP_IsValid]
			   ,[MtSecurityCoverMP_Message]
			   ,[MtSecurityCoverMP_CreatedBy]
			   ,[MtSecurityCoverMP_CreatedOn]
			   ,[MtSecurityCoverMP_ModifiedBy]
			   ,[MtSecurityCoverMP_ModifiedOn]
			   ,[MtSecurityCoverMP_IsDeleted] INTO #tempSecurityCoverInterface
			FROM [dbo].[MtSecurityCoverMP_Interface] SC
			LEFT JOIN MtPartyRegisteration MPR
				ON MPR.MtPartyRegisteration_Id =
					CASE
						WHEN ISNUMERIC(SC.MtPartyRegisteration_Id) = 0 THEN 0
						ELSE SC.MtPartyRegisteration_Id
					END
			WHERE MtSOFileMaster_Id = @pMtSOFileMaster_Id
			AND ISNULL(MtSecurityCoverMP_IsDeleted, 0) = 0
			AND ISNULL(MPR.isDeleted, 0) = 0
			AND (@pPartyId IS NULL
			OR SC.MtPartyRegisteration_Id = @pPartyId)
			AND (@pRequiredSecurityCover IS NULL
			OR SC.MtSecurityCoverMP_RequiredSecurityCover = @pRequiredSecurityCover)
			AND (@pSubmittedSecurityCover IS NULL
			OR SC.MtSecurityCoverMP_SubmittedSecurityCover = @pSubmittedSecurityCover)
			AND (@pIsValid IS NULL
			OR SC.MtSecurityCoverMP_IsValid = @pIsValid)
			AND (@pPartyName IS NULL
			OR (SELECT
					MtPartyRegisteration_Name
				FROM MtPartyRegisteration
				WHERE MtPartyRegisteration_Id = SC.MtPartyRegisteration_Id
				AND ISNULL(isDeleted, 0) = 0)
			LIKE '%' + @pPartyName + '%')


			SELECT
				*
			FROM #tempSecurityCoverInterface TC
			WHERE (MtSecurityCoverMP_RowNumber > ((@pPageNumber - 1) * @pPageSize)
			AND MtSecurityCoverMP_RowNumber <= (@pPageNumber * @pPageSize))
			ORDER BY MtSecurityCoverMP_RowNumber ASC

			SELECT
				COUNT(1) AS FilteredRows
			FROM #tempSecurityCoverInterface TC;

		END
		ELSE
		BEGIN


			SELECT
				[MtSecurityCoverMP_Id]
			   ,[MtSOFileMaster_Id]
				--    ,[MtBmcSecurityCover_RowNumber]      
			   ,ROW_NUMBER() OVER (ORDER BY MPR.MtPartyRegisteration_Id, SC.MtSecurityCoverMP_RowNumber) AS [MtSecurityCoverMP_RowNumber]
			   ,SC.[MtPartyRegisteration_Id]
			   ,MPR.MtPartyRegisteration_Name
			   ,[MtSecurityCoverMP_RequiredSecurityCover]
			   ,[MtSecurityCoverMP_SubmittedSecurityCover]
			   ,[MtSecurityCoverMP_CreatedBy]
			   ,[MtSecurityCoverMP_CreatedOn]
			   ,[MtSecurityCoverMP_ModifiedBy]
			   ,[MtSecurityCoverMP_ModifiedOn]
			   ,[MtSecurityCoverMP_IsDeleted] INTO #tempSecurityCover
			FROM [dbo].[MtSecurityCoverMP] SC
			INNER JOIN MtPartyRegisteration MPR
				ON MPR.MtPartyRegisteration_Id = SC.MtPartyRegisteration_Id
			WHERE MtSOFileMaster_Id = @pMtSOFileMaster_Id
			AND ISNULL(MtSecurityCoverMP_IsDeleted, 0) = 0
			AND ISNULL(MPR.isDeleted, 0) = 0
			AND (@pPartyId IS NULL
			OR SC.MtPartyRegisteration_Id = @pPartyId)
			AND (@pRequiredSecurityCover IS NULL
			OR SC.MtSecurityCoverMP_RequiredSecurityCover = @pRequiredSecurityCover)
			AND (@pSubmittedSecurityCover IS NULL
			OR SC.MtSecurityCoverMP_SubmittedSecurityCover = @pSubmittedSecurityCover)
			AND (@pPartyName IS NULL
			OR (SELECT
					MtPartyRegisteration_Name
				FROM MtPartyRegisteration
				WHERE MtPartyRegisteration_Id = SC.MtPartyRegisteration_Id
				AND ISNULL(isDeleted, 0) = 0)
			LIKE '%' + @pPartyName + '%')
			ORDER BY MPR.MtPartyRegisteration_Id;


			SELECT
				*
			FROM #tempSecurityCover TC
			WHERE ([MtSecurityCoverMP_RowNumber] > ((@pPageNumber - 1) * @pPageSize)
			AND [MtSecurityCoverMP_RowNumber] <= (@pPageNumber * @pPageSize))
			ORDER BY [MtSecurityCoverMP_RowNumber] ASC

			SELECT
				COUNT(1) AS FilteredRows
			FROM #tempSecurityCover TC;

		END


	END TRY
	BEGIN CATCH
		SELECT
			ERROR_NUMBER() AS ErrorNumber
		   ,ERROR_STATE() AS ErrorState
		   ,ERROR_SEVERITY() AS ErrorSeverity
		   ,ERROR_PROCEDURE() AS ErrorProcedure
		   ,ERROR_LINE() AS ErrorLine
		   ,ERROR_MESSAGE() AS ErrorMessage;
	END CATCH

END
