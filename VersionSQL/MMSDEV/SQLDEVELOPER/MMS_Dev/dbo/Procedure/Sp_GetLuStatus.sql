/****** Object:  Procedure [dbo].[Sp_GetLuStatus]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================      
-- Author:  <Aymen Khalid>      
-- Create date: <24-01-2022>      
-- Description: <Returns the Status in settings>      
-- =============================================      
CREATE PROCEDURE dbo.Sp_GetLuStatus      
 -- Add the parameters for the stored procedure here      
 
      
AS      
BEGIN      
 -- SET NOCOUNT ON added to prevent extra result sets from      
 -- interfering with SELECT statements.      
 SET NOCOUNT ON;      
      
SELECT 
	ls.LuStatus_Code, 
	ls.LuStatus_Name 
FROM 
	LuStatus ls 
WHERE 
	ls.LuStatus_Category='Settlement Period' 
ORDER BY 2 
    
END 
