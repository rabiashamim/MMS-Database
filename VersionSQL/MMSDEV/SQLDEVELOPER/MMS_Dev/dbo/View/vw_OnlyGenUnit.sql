/****** Object:  View [dbo].[vw_OnlyGenUnit]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Ali Imran
-- Create date: 20 Dec 2022
-- Description:	Only gen and gen unit info
-- =============================================
CREATE VIEW dbo.vw_OnlyGenUnit
AS

SELECT DISTINCT
	g.MtGenerator_Name AS GenName
   ,g.MtGenerator_Id AS GenId
   ,gu.MtGenerationUnit_Id AS GenUnitId
   ,gu.MtGenerationUnit_SOUnitId AS SoUnitId
FROM MtGenerator g
INNER JOIN MtGenerationUnit gu
	ON gu.MtGenerator_Id = g.MtGenerator_Id
INNER JOIN MtConnectedMeter mcm
	ON mcm.MtConnectedMeter_UnitId = gu.MtGenerationUnit_Id
WHERE ISNULL(g.MtGenerator_IsDeleted, 0) = 0
AND ISNULL(gu.MtGenerationUnit_IsDeleted, 0) = 0
AND ISNULL(g.isDeleted, 0) = 0
AND ISNULL(MCM.MtConnectedMeter_isDeleted,0)=0
