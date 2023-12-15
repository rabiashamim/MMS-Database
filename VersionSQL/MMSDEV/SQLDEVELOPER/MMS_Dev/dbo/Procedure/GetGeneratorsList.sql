/****** Object:  Procedure [dbo].[GetGeneratorsList]    Committed by VersionSQL https://www.versionsql.com ******/

    
-- =============================================          
-- Author:  Sadaf Malik          
-- Create date: <Create Date,,>          
-- Description: <Description,,>          
-- =============================================          
--dbo.GetGeneratorsList 0      
CREATE   Procedure dbo.GetGeneratorsList @pMtPartyCategoryId DECIMAL(18, 0) = 0    
AS    
BEGIN    
    
;WITH cte_onlyGen AS(    
SELECT    
  c.MtPartyCategory_Id    
 FROM MtPartyRegisteration P    
 JOIN MtPartyCategory C    
  ON P.MtPartyRegisteration_Id = C.MtPartyRegisteration_Id    
 WHERE ISNULL(C.isDeleted, 0) = 0    
 AND ISNULL(P.isDeleted, 0) = 0    
 AND C.SrCategory_Code IN ('GEN','EGEN')    
)    
    
 SELECT    
  *    
 FROM [dbo].[MtGenerator] G    
 LEFT JOIN Lu_PowerPolicy PP    
  ON PP.Lu_PowerPolicy_Id = G.Lu_PowerPolicy_Id    
 LEFT JOIN Lu_CapUnitGenVari Cap    
  ON Cap.Lu_CapUnitGenVari_Id = G.Lu_CapUnitGenVari_Id    
 WHERE ISNULL(isDeleted, 0) = 0    
 AND ISNULL(MtGenerator_IsDeleted, 0) = 0    

 AND 
 (MtPartyCategory_Id = @pMtPartyCategoryId    
 
 OR (@pMtPartyCategoryId = 0    
 AND G.MtPartyCategory_Id IN (    
 SELECT * FROM cte_onlyGen    
 ))    
 )
 ORDER BY MtGenerator_Name    
    
END    
    
