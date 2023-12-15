/****** Object:  Procedure [dbo].[Sp_GetLuMonth]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================      
-- Author:  <Aymen Khalid>      
-- Create date: <24-01-2022>      
-- Description: <Get Months in settings>      
-- =============================================      
CREATE PROCEDURE dbo.Sp_GetLuMonth      
 -- Add the parameters for the stored procedure here      
 
      
AS      
BEGIN      
 -- SET NOCOUNT ON added to prevent extra result sets from      
 -- interfering with SELECT statements.      
 SET NOCOUNT ON;      
      
SELECT 
	lmn.Lu_Month_Name, 
	lmn.Lu_Month_Name 
FROM 
	LuMonthName lmn
    
END 
