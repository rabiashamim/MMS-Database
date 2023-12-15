/****** Object:  Procedure [dbo].[GetSODataConfiguration]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================      
-- Author:  Kapil Kumar  
-- CREATE date: Dec 02, 2022     
-- ALTER date:  Dec 02, 2022   
-- Reviewer:  
-- Description:     
-- =============================================    
-- GetSODataConfiguration 8  

CREATE Procedure GetSODataConfiguration    
@pLuSoFileTemplateId int
  
AS    
BEGIN    
  
  select LuDataConfiguration.LuDataConfiguration_Id from LuDataConfiguration
  join LuSOFileTemplate on LuSOFileTemplate.LuDataConfiguration_Id = LuDataConfiguration.LuDataConfiguration_Id
  where LuSOFileTemplate.LuSOFileTemplate_Id = @pLuSoFileTemplateId

END
