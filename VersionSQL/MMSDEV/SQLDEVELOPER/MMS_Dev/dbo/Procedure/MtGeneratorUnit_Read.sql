/****** Object:  Procedure [dbo].[MtGeneratorUnit_Read]    Committed by VersionSQL https://www.versionsql.com ******/

--==========================================================================================      
-- Author: Ammama Gill    
-- CREATE date: 20 Sept 2023      
-- ALTER date:          
-- Description: Optimization of code - converting front end sql queries to SPs                    
--==========================================================================================    
CREATE PROCEDURE dbo.MtGeneratorUnit_Read (@pGeneratorId INT)
AS
BEGIN

	SELECT
		*
	FROM [dbo].[MtGenerationUnit] g
	INNER JOIN SrTechnologyType
		ON g.SrTechnologyType_Code = SrTechnologyType.SrTechnologyType_Code
	INNER JOIN SrFuelType
		ON g.SrFuelType_Code = SrFuelType.SrFuelType_Code
	Left JOIN Lu_CapUnitGenVari L
		ON L.Lu_CapUnitGenVari_Id = g.Lu_CapUnitGenVari_Id
	WHERE ISNULL(isDeleted, 0) = 0
	AND [MtGenerator_Id] = @pGeneratorId

END
