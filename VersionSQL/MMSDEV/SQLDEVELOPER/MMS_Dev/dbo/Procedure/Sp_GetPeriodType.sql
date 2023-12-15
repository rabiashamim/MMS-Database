/****** Object:  Procedure [dbo].[Sp_GetPeriodType]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================      
-- Author:  <Aymen Khalid>      
-- Create date: <24-01-2022>      
-- Description: <Returns the period type>      
-- =============================================      
CREATE PROCEDURE dbo.Sp_GetPeriodType      
 -- Add the parameters for the stored procedure here      
 
      
AS      
BEGIN      
 -- SET NOCOUNT ON added to prevent extra result sets from      
 -- interfering with SELECT statements.      
 SET NOCOUNT ON;      
      
SELECT  
	PeriodTypeID,
	PeriodTypeName 
FROM 
	dbo.PeriodType
    
END 
