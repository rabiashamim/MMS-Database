/****** Object:  Procedure [dbo].[MtCapacityObligationsSettings_GetAll]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================      
-- Author: Ali Imran    
-- CREATE date: May 16, 2023     
-- ALTER date:       
-- Description: GET ALL    
-- [MtCapacityObligationsSettings_GetAll]    
--      
-- =============================================       
    
CREATE   PROCEDUREdbo.MtCapacityObligationsSettings_GetAll    
AS    
 SELECT    
  MtCapacityObligationsSettings_Id    
    ,MtCapacityObligationsSettings_year    
 ,sc.LuCapacityObligationsYears_Discription as MtCapacityObligationsSettings_yearName  
    ,MtCapacityObligationsSettings_Percentage    
    ,CO.SrCategory_Code    
    ,SrCategory_Name AS SrCategory_Name    
    ,MtCapacityObligationsSettings_EffectiveFrom    
    ,  CO.MtCapacityObligationsSettings_EffectiveTo  
    ,MtCapacityObligationsSettings_IsDisabled    
 FROM [MtCapacityObligationsSettings]  CO  
inner join SrCategory S on S.SrCategory_Code =CO.SrCategory_Code  
inner join LuCapacityObligationsYears sc  on sc.LuCapacityObligationsYears_Name=CO.MtCapacityObligationsSettings_year  
-- WITH (NOLOCK)    
 ORDER BY MtCapacityObligationsSettings_Id DESC   
