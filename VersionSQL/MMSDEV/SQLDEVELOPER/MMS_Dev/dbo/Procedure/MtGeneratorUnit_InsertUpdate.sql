/****** Object:  Procedure [dbo].[MtGeneratorUnit_InsertUpdate]    Committed by VersionSQL https://www.versionsql.com ******/

--==========================================================================================    
-- Author: Ammama Gill  
-- CREATE date: 19 Sept 2023    
-- ALTER date:        
-- Description: Optimization of code - converting front end sql queries to SPs                  
--==========================================================================================    

CREATE PROCEDURE MtGeneratorUnit_InsertUpdate (@pMtGeneratorUnit_Id INT = NULL,
@pMtGenerator_Id INT = NULL,
@pMtGenerationUnit_UnitName VARCHAR(100) = NULL,
@pSrTechnologyType_Code VARCHAR(10) = NULL,
@pSrFuelType_Code VARCHAR(10) = NULL,
@pMtGenerationUnit_UnitNumber VARCHAR(100) = NULL,
@pMtGenerationUnit_InstalledCapacity_KW DECIMAL(18, 5) = NULL,
@pMtGenerationUnit_location VARCHAR(100) = NULL,
@pMtGenerationUnit_IsDisabled BIT = NULL,
@pMtGenerationUnit_IsEnergyImported BIT = NULL,
@pMtGenerationUnit_EffectiveFrom DATETIME = NULL,
@pMtGenerationUnit_EffectiveTo DATETIME = NULL,
@pMtGenerationUnit_SOUnitId INT = NULL,
@pMtGenerationUnit_NewInstalledCapacity_KW DECIMAL(18, 5) = NULL,
@pCapUnitGenVari_Id INT = NULL,
@pUserId INT)
AS
BEGIN

	BEGIN TRY


		IF @pMtGeneratorUnit_Id IS NULL
		BEGIN

			DECLARE @vUnitNameExists BIT;
			SELECT
				@vUnitNameExists =
				CASE
					WHEN [MtGenerationUnit_UnitName] IS NULL THEN 0
					ELSE 1
				END
			FROM [dbo].[MtGenerationUnit]
			WHERE ISNULL(isDeleted, 0) = 0
			AND replace(MtGenerationUnit_UnitName,' ','') = replace(@pMtGenerationUnit_UnitName,' ','')
			AND MtGenerator_Id = @pMtGenerator_Id

			IF @vUnitNameExists = 1
			BEGIN
				RAISERROR ('This unit name already exists!', 16, -1);
				RETURN;
			END


			SELECT
				@pMtGeneratorUnit_Id = MAX(MtGenerationUnit_Id) + 1
			FROM MtGenerationUnit

			INSERT INTO MtGenerationUnit (MtGenerationUnit_Id,
			MtGenerator_Id
			, MtGenerationUnit_UnitName
			, SrTechnologyType_Code,
			SrFuelType_Code,
			MtGenerationUnit_UnitNumber,
			MtGenerationUnit_InstalledCapacity_KW, MtGenerationUnit_location, MtGenerationUnit_IsDisabled, MtGenerationUnit_IsEnergyImported,
			MtGenerationUnit_EffectiveFrom,
			MtGenerationUnit_EffectiveTo, MtGenerationUnit_SOUnitId, MtGeneratorUnit_NewInstalledCapacity
			, MtGenerationUnit_CreatedBy, MtGenerationUnit_CreatedOn, Lu_CapUnitGenVari_Id)
				VALUES (@pMtGeneratorUnit_Id, @pMtGenerator_Id, @pMtGenerationUnit_UnitName, @pSrTechnologyType_Code, @pSrFuelType_Code, @pMtGenerationUnit_UnitNumber, @pMtGenerationUnit_InstalledCapacity_KW, @pMtGenerationUnit_location, @pMtGenerationUnit_IsDisabled, @pMtGenerationUnit_IsEnergyImported, CAST(@pMtGenerationUnit_EffectiveFrom AS DATETIME), CAST(@pMtGenerationUnit_EffectiveTo AS DATETIME), @pMtGenerationUnit_SOUnitId, @pMtGenerationUnit_NewInstalledCapacity_KW, @pUserId, getutcdate(), @pCapUnitGenVari_Id)
		END

		ELSE
		BEGIN

			UPDATE MtGenerationUnit

			SET MtGenerationUnit_UnitName = @pMtGenerationUnit_UnitName
			   ,SrTechnologyType_Code = @pSrTechnologyType_Code
			   ,SrFuelType_Code = @pSrFuelType_Code
			   ,MtGenerationUnit_UnitNumber = @pMtGenerationUnit_UnitNumber
			   ,MtGenerationUnit_InstalledCapacity_KW = @pMtGenerationUnit_InstalledCapacity_KW
			   ,MtGenerationUnit_location = @pMtGenerationUnit_location
			   ,MtGenerationUnit_IsDisabled = @pMtGenerationUnit_IsDisabled
			   ,MtGenerationUnit_IsEnergyImported = @pMtGenerationUnit_IsEnergyImported
			   ,MtGenerationUnit_EffectiveFrom = @pMtGenerationUnit_EffectiveFrom
			   ,MtGenerationUnit_EffectiveTo = @pMtGenerationUnit_EffectiveTo
			   ,MtGenerationUnit_SOUnitId = @pMtGenerationUnit_SOUnitId
			   ,MtGeneratorUnit_NewInstalledCapacity = @pMtGenerationUnit_NewInstalledCapacity_KW
			   ,MtGenerationUnit_ModifiedBy = @pUserId
			   ,MtGenerationUnit_ModifiedOn = GETUTCDATE()
			   ,Lu_CapUnitGenVari_Id = @pCapUnitGenVari_Id
			WHERE MtGenerationUnit_Id = @pMtGeneratorUnit_Id
		END

		SELECT
			@pMtGeneratorUnit_Id;
	END TRY
	BEGIN CATCH
		DECLARE @verrorMessage VARCHAR(200);
		SET @verrorMessage = error_message();
		RAISERROR (@verrorMessage, 16, -1)
		RETURN;
	END CATCH

END
