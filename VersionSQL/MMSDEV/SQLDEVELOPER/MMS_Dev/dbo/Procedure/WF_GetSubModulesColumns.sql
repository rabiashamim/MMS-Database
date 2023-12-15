/****** Object:  Procedure [dbo].[WF_GetSubModulesColumns]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================            
-- Author:  <Aymen Khalid>            
-- Create date: <22-02-2022>            
-- Description: <Returns the Columns of respective Table>            
-- =============================================          
CREATE PROCEDURE dbo.WF_GetSubModulesColumns        
@psRuModulesProcess_LinkedObject as varchar(100)      
        
AS BEGIN        
        
SELECT COLUMN_NAME
  FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = @psRuModulesProcess_LinkedObject;     
       
END
