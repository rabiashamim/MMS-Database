/****** Object:  Procedure [dbo].[GetGeneratorBlackStart]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[GetGeneratorBlackStart]
@pFileMasterId decimal(18,0)
AS
BEGIN

SELECT *,
GenerationUnitName = dbo.GetGenerationUnitName(MtGenerationUnit_Id) 
FROM MtGeneratorBS mgb
WHERE 
	MtSOFileMaster_Id=@pFileMasterId


END
